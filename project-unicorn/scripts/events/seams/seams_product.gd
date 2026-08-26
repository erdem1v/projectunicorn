class_name EvSeamsProduct
extends RefCounted

# The `urun.` and `arge.` namespaces (docs/SEAM_REGISTRY.md §2, §3).
#
# Almost every row here is a one-line binding, and that is Ürün rev 6.1 and Ar-Ge rev 1.4
# paying forward: both GDDs opened a named read surface before this engine existed, on the
# stated principle that "olay motoru geldiğinde işi bunları okumak olacak, keşfetmek değil".
# ProductRead's own header says ProductRead.X IS the GDD's urun.X. So this file mostly agrees
# with two documents rather than inventing anything.
#
# ⚠️ Ar-Ge is under active development by another agent as this is written. The bindings are by
# NAME, and rnd_system.gd:652-654 declares those names stable ("Names are STABLE; each signal
# has exactly one publisher"), so line drift underneath is harmless. If a NAME moves, that is a
# broken contract on their side and the linter will say so on the next run.

static func install() -> void:
	_install_product()
	_install_rnd()


static func _install_product() -> void:
	var G := EvSeams.Kind.GLOBAL

	EvSeams.register("urun.phase", G, TYPE_STRING,
		func() -> String: return ProductRead.phase(),
		"Product", "concept | design | development | beta | support; empty before anything exists")
	EvSeams.register("urun.build_active", G, TYPE_BOOL,
		func() -> bool: return ProductRead.build_active(),
		"Product", "a version is being built")
	EvSeams.register("urun.is_live", G, TYPE_BOOL,
		func() -> bool: return ProductState.is_live(),
		"Product", "something has shipped")
	EvSeams.register("urun.version", G, TYPE_INT,
		func() -> int: return ProductState.version(),
		"Product", "shipped version number")
	EvSeams.register("urun.version_age", G, TYPE_INT,
		func() -> int: return ProductRead.version_age(),
		"Product", "days since THIS VERSION shipped, not since the product was born")
	EvSeams.register("urun.market_type", G, TYPE_STRING,
		func() -> String: return ProductState.market_type(),
		"Product", "b2b | b2c; empty until the first ship writes it")
	EvSeams.register("urun.subtype", G, TYPE_STRING,
		func() -> String: return ProductState.subtype(),
		"Product", "one of the sub-product ids")

	# Quality. Axis readings, not a single score — §17's triangle rule says the player reads
	# the asymmetry, so content asks about an axis and never about "quality" as one number.
	EvSeams.register("urun.axis_innovation", G, TYPE_INT,
		func() -> int: return ProductRead.axis_reading("", "innovation"), "Product", "0-120")
	EvSeams.register("urun.axis_stability", G, TYPE_INT,
		func() -> int: return ProductRead.axis_reading("", "stability"), "Product", "0-120")
	EvSeams.register("urun.axis_experience", G, TYPE_INT,
		func() -> int: return ProductRead.axis_reading("", "experience"), "Product", "0-120")

	# The floor ladder's trigger (§14 of the Ürün GDD): "" / warning at floor+20% / crossed.
	# This is what the three-step event ladder reads, and it is why that ladder is buildable
	# here without any new Product code.
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
		"Product", "0-100, refreshed on publish, 30-day half-life")
	EvSeams.register("urun.usage", G, TYPE_FLOAT,
		func() -> float: return ProductRead.usage(), "Product", "load multiplier")
	EvSeams.register("urun.capacity_tier", G, TYPE_INT,
		func() -> int: return ProductRead.capacity_tier(), "Product", "provisioned infra units")
	EvSeams.register("urun.support_staffed", G, TYPE_BOOL,
		func() -> bool: return ProductRead.support_staffed(),
		"Product", "the module's central pressure reads from this one boolean")
	EvSeams.register("urun.lines_open", G, TYPE_INT,
		func() -> int: return ProductRead.lines_open(), "Product", "0-9 feature lines opened")
	EvSeams.register("urun.steps_shipped", G, TYPE_INT,
		func() -> int: return ProductRead.steps_shipped(), "Product", "feature steps live")
	EvSeams.register("urun.build_progress", G, TYPE_FLOAT,
		func() -> float: return ProductSystem.build_progress(), "Product", "0.0-1.0")
	EvSeams.register("urun.build_paused", G, TYPE_BOOL,
		func() -> bool: return ProductSystem.build_paused(), "Product", "auto or manual")

	# WRAPPER, and honestly labelled: tech debt is a BOOLEAN in the demo, not a level. Ürün
	# rev6.1 §20 lists it among the things deliberately removed for now, so a card may ask
	# whether it exists and may not ask how much.
	EvSeams.register("urun.tech_debt", G, TYPE_BOOL,
		func() -> bool: return bool(GameState.get_flag("tech_debt_birikti", false)),
		"Product", "WRAPPER over a flag; boolean by design in the demo")


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
