class_name Rival
extends Resource

# Rival data model (Product Lifecycle Part 1). A competing product in the same
# sub-product-type market. Plain data container held by RivalRegistry, mirrors the
# Customer/Character model convention (@export fields + forward-compat reserves).
#
# Three tiers structure the competitive field (rival_registry.gd enforces that a
# Phase-1 player can NEVER reach the giant band):
#   startup      — the player's league; real, catchable rivals.
#   established  — ahead; a late-Phase-1 player may brush the bottom.
#   giant        — aspirational, structurally unreachable in Phase 1.
#
# Dimensions mirror QualityModel's canonical axes (open-ended floats). `momentum`
# is the per-day growth rate rivals gain via RivalRegistry.advance_all (0 = static).

@export var id: String = ""                    # "rv_<subtype>_<n>" per TECH_SPEC §12 prefix spirit
@export var product_name: String = ""
@export var sub_product_type_id: String = ""
@export var tier: String = "startup"           # "giant" | "established" | "startup"
@export var innovation: float = 0.0
@export var stability: float = 0.0
@export var usability: float = 0.0
@export var momentum: float = 0.0              # per-day dim growth rate (0 for giants)
@export var status: String = "QUIET"           # display band (DOMINANT/STEADY/SCALING/QUIET)

# --- forward-compat reserves (mirror Customer/Character) ---
@export var founder_name: String = ""
@export var narrative_tags: Array[String] = []
@export var notes: String = ""


# Type-weighted composite (same math the player uses) — for ranking + display.
func composite(quality_axes: Array = []) -> float:
	return QualityModel.composite_quality(
		{"innovation": innovation, "stability": stability, "usability": usability}, quality_axes)
