class_name QualityModel
extends RefCounted

# Product Lifecycle Part 1 — the SINGLE choke point between open-ended,
# multi-dimensional quality and the ratio-based economy (SalesSystem).
#
# Three canonical, engine-internal axes (never localized — presentation renames
# happen via ProductCatalog quality_axes[].display_label):
#   innovation — distinctiveness / tech wow / premium pricing power
#   stability  — bug-freeness / crash resistance / low churn
#   usability  — ease of use / onboarding / satisfaction
#
# Each axis is OPEN-ENDED (floor 0, NO upper clamp). The ceiling is STRUCTURAL,
# enforced by grow()'s diminishing-returns law + PHASE1_AXIS_ASYMPTOTE — not a
# clamp. See scripts/autoload/rival_registry.gd for the tier bands that keep a
# Phase-1 player structurally below the giant league.
#
# Pure statics (RefCounted, no state) — matches ProductSystem / SalesSystem /
# ProductCatalog convention. Runs on BOTH quality surfaces:
#   - live build:  dims_from_build(FeatureBuild)
#   - post-ship:   dims_from_flags()  (mvp_innovation/stability/usability)
# Every consumer calls QualityModel.x(); nobody re-derives quality inline, so the
# 12-consumer rewrite is safe and R1/R6 cannot drift.
#
# NOTE (Erdem decision): axes are BORN AT 0 — a v1 product is genuinely raw and
# climbs into the startup league hour by hour. The old baseline-50 feel is gone.

# --- Canonical axes (engine ids) ---
const AXES := ["innovation", "stability", "usability"]

# Fallback weights + labels when a sub-type omits quality_axes (equal blend).
const DEFAULT_AXES := [
	{"axis": "innovation", "weight": 1.0, "display_label": "İnovasyon"},
	{"axis": "stability",  "weight": 1.0, "display_label": "Kararlılık"},
	{"axis": "usability",  "weight": 1.0, "display_label": "Kullanılabilirlik"},
]

# --- BALANCE-TUNABLE constants (Erdem tunes at the last pass) ---
# Saturation half-point: the composite value that maps to normalized 50. This is
# the knob that decides where a shipped v1 lands on the 0-100 market-quality band.
const NORMALIZE_HALF_SAT := 50.0
# Per-axis soft asymptote for a single Phase-1 build. grow() approaches but NEVER
# reaches it, so player_composite < this by construction (structural ceiling proof
# in the plan / rival_registry.gd). Later versions (Part 2) raise this per-version.
const PHASE1_AXIS_ASYMPTOTE := 110.0
# How much each open (launch) bug erodes the Stability axis the economy reads.
# Bugs are the live face of Stability (Erdem decision): features feed it, bugs eat it.
# Part 2B: softened 1.5→0.8 so a few bugs are tolerable, heavy neglect still bites (global —
# also softens the in-build/launch bug penalty, intended).
const BUG_STABILITY_COEF := 0.8


# =========================================================================
#  Core math
# =========================================================================

# Diminishing-returns accumulator — THE structural-ceiling primitive.
# Positive raw is scaled by remaining headroom so `current` asymptotes below
# `asymptote` forever (for any raw < asymptote). Negative raw (a penalty) applies
# fully, floored at 0. Used by BOTH player growth and rival advancement.
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


# Saturation: open-ended composite → the ~0-100 band the ratio economy expects.
# Strictly < 100 for every finite input, so conversion_rate's optimal/price and
# similar ratios never blow up when dims run open-ended.
static func normalized_quality(composite: float) -> float:
	var c := maxf(0.0, composite)
	return 100.0 * c / (c + NORMALIZE_HALF_SAT)


static func normalized_from_dims(dims: Dictionary, quality_axes: Array = []) -> float:
	return normalized_quality(composite_quality(dims, quality_axes))


# Single-axis 0-100 score (R2 usability seed, R3 stability gate, R5 per-axis lines,
# BuildHUD gauges). Pass economy dims when you want bug-eroded stability.
static func axis_score(dims: Dictionary, axis: String) -> float:
	return normalized_quality(float(dims.get(axis, 0.0)))


# Bugs are the live face of Stability: the economy reads THIS, not the raw axis.
static func effective_stability(stability: float, bug_count: int) -> float:
	return maxf(0.0, stability - BUG_STABILITY_COEF * float(bug_count))


# =========================================================================
#  Surface adapters — the SAME math runs live (build) and post-ship (flags)
# =========================================================================

# Raw design-time dims (no bug erosion). Use for pure per-axis design display.
static func dims_from_build(b: FeatureBuild) -> Dictionary:
	return {"innovation": b.innovation, "stability": b.stability, "usability": b.usability}


# Economy dims — Stability replaced by effective_stability(bug_count). Everything
# the ECONOMY reads (audience, price, satisfaction) goes through this.
static func economy_dims_from_build(b: FeatureBuild) -> Dictionary:
	return {
		"innovation": b.innovation,
		"stability": effective_stability(b.stability, b.bug_count),
		"usability": b.usability,
	}


static func dims_from_flags() -> Dictionary:
	return {
		"innovation": float(GameState.get_flag("mvp_innovation", 0.0)),
		"stability":  float(GameState.get_flag("mvp_stability", 0.0)),
		"usability":  float(GameState.get_flag("mvp_usability", 0.0)),
	}


static func economy_dims_from_flags() -> Dictionary:
	# Product Lifecycle Part 2A: reads the LIVE bug count (accrues post-ship via
	# wear), not the frozen launch snapshot. Falls back to the snapshot for any
	# pre-Part-2A shipped state that lacks the live flag.
	var bugs: int = int(GameState.get_flag("mvp_live_bug_count", GameState.get_flag("mvp_bug_count_at_launch", 0)))
	return {
		"innovation": float(GameState.get_flag("mvp_innovation", 0.0)),
		"stability":  effective_stability(float(GameState.get_flag("mvp_stability", 0.0)), bugs),
		"usability":  float(GameState.get_flag("mvp_usability", 0.0)),
	}


# THE market-facing quality number. R1 (_tick_b2c_audience) and R6 (growth_band)
# BOTH call this → they cannot drift. Post-ship snapshot, effective stability.
static func shipped_normalized() -> float:
	var sub := String(GameState.get_flag("mvp_sub_product_type_id", ""))
	return normalized_from_dims(economy_dims_from_flags(), ProductCatalog.get_quality_axes(sub))


# Post-ship composite (effective) — for rival ranking after ship.
static func shipped_composite() -> float:
	var sub := String(GameState.get_flag("mvp_sub_product_type_id", ""))
	return composite_quality(economy_dims_from_flags(), ProductCatalog.get_quality_axes(sub))
