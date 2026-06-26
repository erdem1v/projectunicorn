class_name FeatureBuild
extends Resource

# Build artifact per Spec #1 §D, extended in Spec #2 §B for the canonical
# 3-phase build flow (planning → iteration → polish → shipped). Represents
# a single product feature build — the MVP for Spec #1, future feature builds
# use the same machinery.
#
# NO `mrr_potential` field — shipping a build does not produce MRR per the
# narrative-strategy design principle (Decision Log 2026-05-16). Ship sets
# flags["mvp_shipped"] and flags["product_quality"]; no economic delta.
#
# Forward-compat fields (equity_impact, revenue_share, tags, quality_modifiers)
# follow the Character forward-compat pattern — declared so future systems
# wire in without retrofit.

# --- Spec #1 fields (preserved) ---
@export var id: String = ""
# DEPRECATED (Spec #2): superseded by `feature_ids`. Kept for save backward
# compat and populated alongside `feature_ids` by ProductSystem.start_build.
@export var component_ids: Array[String] = []
@export var assigned_engineer_id: String = ""
@export var start_day: int = 0
@export var total_days: int = 12
@export var days_remaining: int = 12
# DEPRECATED (Spec #2): superseded by `current_phase`. Kept aligned via
# `_sync_status_from_phase()` for any legacy reader / save backward compat.
@export var status: String = "planning"   # planning / in_progress / ready_to_ship / shipped / cancelled
@export var quality: int = 50
@export var is_mvp: bool = false

# Forward-compat reserves (no consumer yet)
@export var equity_impact: float = 0.0
@export var revenue_share: float = 1.0
@export var tags: Array[String] = []
@export var quality_modifiers: Array = []

# --- Spec #2 additions ---
@export var sub_product_type_id: String = ""
@export var feature_ids: Array[String] = []
# planning / iteration / development / bugfix / shipped / cancelled.
# Note: "polish" is the legacy name for "bugfix" — _sync_status_from_phase()
# accepts both so older saves don't crash; new code only writes "bugfix".
@export var current_phase: String = "planning"
@export var bug_count: int = 0
@export var min_estimation_days: int = 0

# --- Software Inc.-style phase machinery (Spec #4) ---
# How many iterations the player has committed to so far. Each iteration nudges
# quality ceiling up and bug spawn rate down — see ProductSystem constants.
@export var iteration_count: int = 0
# Days remaining inside the current iteration. When this hits 0 we don't pause
# the game — we flip a "decision pending" flag so BuildHUDPanel lights up its
# advance/development buttons and the player picks on their own time.
@export var iteration_days_in_current: int = 0
# Whether the player owes a decision for the just-completed iteration.
# Persisted on the build (not the system) so saving mid-decision restores
# cleanly.
@export var iteration_decision_pending: bool = false
# Development phase span — derived from feature complexity at start_build()
# time and ticked down during _tick_development_phase().
@export var development_days_total: int = 0
@export var development_days_elapsed: int = 0

# --- DEPRECATED Spec #2 fields (kept for save compat — do not read in new code) ---
# Player no longer picks a duration up front (Spec #4 removed Rushed/Standard/
# Polished). Old saves with these populated still load; ProductSystem ignores
# them. New saves write 0.
@export var iteration_duration_days: int = 0
@export var polish_duration_days: int = 3
@export var polish_days_remaining: int = 0


func is_active() -> bool:
	return status in ["planning", "in_progress", "ready_to_ship"]


func to_display_string() -> String:
	if component_ids.is_empty():
		return "(no components)"
	return ", ".join(component_ids)


# --- Spec #2 helpers ---

func get_total_complexity() -> int:
	var total: int = 0
	for fid in feature_ids:
		var f: Dictionary = ProductCatalog.get_feature_by_id(fid)
		total += int(f.get("complexity", 0))
	return total


func is_in_phase(phase: String) -> bool:
	return current_phase == phase


func _sync_status_from_phase() -> void:
	# Keeps legacy `status` field aligned with new `current_phase`. "polish"
	# is the legacy alias for "bugfix" — accepted on load so older saves don't
	# crash. New code only writes "bugfix".
	match current_phase:
		"iteration": status = "in_progress"
		"development": status = "in_progress"
		"bugfix": status = "in_progress"
		"polish": status = "in_progress"  # legacy alias
		"shipped": status = "shipped"
		"cancelled": status = "cancelled"
		_: status = "planning"
