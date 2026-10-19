class_name QualityModel
extends RefCounted

# The rival model's math: three open-ended dimensions (innovation, stability, experience) that grow with diminishing
# returns and blend into one composite by the weights of the rival's sub-type. The player's product has no such
# dimensions: its quality is the level of its areas (ProductQuality).
# grow()'s diminishing returns ceilings rival advancement (rival_registry.gd tier asymptotes keep the giant band
# structurally out of reach).

# Equal blend when a sub-type omits its row in RivalCatalog.COMPOSITE_AXES.
const DEFAULT_AXES := [
	{"axis": "innovation", "weight": 1.0},
	{"axis": "stability",  "weight": 1.0},
	{"axis": "experience", "weight": 1.0},
]


# Diminishing-returns accumulator — THE structural-ceiling primitive.
# Positive raw is scaled by remaining headroom so `current` asymptotes below
# `asymptote` forever (for any raw < asymptote). Negative raw (a penalty) applies
# fully, floored at 0.
static func grow(current: float, raw: float, asymptote: float) -> float:
	if raw <= 0.0:
		return maxf(0.0, current + raw)
	return current + raw * maxf(0.0, 1.0 - current / asymptote)


# Open-ended type-weighted composite of the three axes.
static func composite_quality(dims: Dictionary, quality_axes: Array = []) -> float:
	var axes: Array = quality_axes if not quality_axes.is_empty() else DEFAULT_AXES
	var acc := 0.0
	var wsum := 0.0
	for a in axes:
		var w := float(a.get("weight", 0.0))
		acc += w * float(dims.get(String(a.get("axis", "")), 0.0))
		wsum += w
	return acc / wsum if wsum > 0.0 else 0.0
