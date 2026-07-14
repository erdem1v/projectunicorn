class_name FeatureBuild
extends Resource

# Build artifact per Spec #1 §D, extended in Spec #2 §B for the canonical
# 3-phase build flow (planning → iteration → polish → shipped). Represents
# a single product feature build — the MVP for Spec #1, future feature builds
# use the same machinery.
#
# NO `mrr_potential` field — shipping a build does not produce MRR per the
# narrative-strategy design principle (Decision Log 2026-05-16). Ship sets
# flags["mvp_shipped"] + mvp_innovation/stability/usability; no economic delta.
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
# Product Lifecycle Part 1: player-chosen product name (empty → falls back to the
# sub-type name at display time). lead_engineer_id is a reserve seed (= founder for
# now; HR wires the real effect later).
@export var product_name: String = ""
@export var lead_engineer_id: String = ""
# planning / iteration / development / bugfix / shipped / cancelled.
# Note: "polish" is the legacy name for "bugfix" — _sync_status_from_phase()
# accepts both so older saves don't crash; new code only writes "bugfix".
@export var current_phase: String = "planning"
@export var bug_count: int = 0
@export var min_estimation_days: int = 0

# --- Multi-dimensional quality (Product Lifecycle Part 1) ---
# Three open-ended canonical axes, BORN AT 0 (Erdem: a v1 is genuinely raw and
# climbs hour by hour). ProductSystem grows these via QualityModel.grow(); the
# legacy `quality` int above is now a DERIVED mirror kept in sync each tick
# (_sync_legacy_quality) so anything still reading b.quality keeps working.
@export var innovation: float = 0.0
@export var stability: float = 0.0
@export var usability: float = 0.0
# Fractional bug accumulator (Blok C hourly accrual): ticks bug_count up as it crosses 1.0.
@export var bug_progress: float = 0.0
# --- Beta bulunan/çözülen modeli (Build Tracker Card, dört-faz akış) ---
# bug_count TÜM AÇIK bug'ların sayısı olarak kalır (gizli + bulunan-çözülmemiş) →
# effective_stability ve diğer tüm mevcut tüketiciler değişmeden çalışır.
# İnvaryantlar: gizli = bug_count - (bugs_found - bugs_fixed); KALAN = found - fixed;
# bir fix bugs_fixed'i artırır VE bug_count'u düşürür.
@export var bugs_found: int = 0
@export var bugs_fixed: int = 0
@export var bug_find_progress: float = 0.0
@export var bug_fix_progress: float = 0.0
# DEPRECATED (canlı-yaşam-döngüsü fix'i): sprint artık FeatureBuild taşıyıcısı
# kullanmıyor — durumu mvp_sprint_* flag'lerinde (ProductSystem). Alan save-compat
# için duruyor; yeni kod hep false yazar/okur.
@export var is_bug_sprint: bool = false
# Product Lifecycle Part 2B: a version build (v2+) reuses the full build flow but SEEDS
# axes from the live product (not 0) and increments mvp_version at launch. Tracker
# Card'ta normal build gibi akar; orta alan PostShipView'da kalır (canlı ürün yönetimi).
@export var is_version_build: bool = false
# Pool-deepening (feature-exhaustion unlock): ids (⊆ feature_ids) the player chose to
# STRENGTHEN this build. Their dimension_contribution is amplified (get_dimension_weights)
# and their dominant axis gets a flat hourly bonus (ProductSystem). Empty for every normal
# build and every version-ADD build → zero behavior change.
@export var strengthened_feature_ids: Array[String] = []

# --- Software Inc.-style phase machinery (Spec #4) ---
# How many iterations the player has committed to so far. Each iteration nudges
# quality ceiling up and bug spawn rate down — see ProductSystem constants.
@export var iteration_count: int = 0
# Days remaining inside the current iteration. When this hits 0 we don't pause
# the game — we flip a "decision pending" flag so BuildHUDPanel lights up its
# advance/development buttons and the player picks on their own time.
# B2: FLOAT so it decrements hourly (1/24 per hour) and the progress reads
# smooth instead of jumping a whole day at a time. Displays int-cast for "N gün".
@export var iteration_days_in_current: float = 0.0
# Bu turun TOPLAM uzunluğu (payda). Normalde ITERATION_LENGTH_DAYS; delay_days
# event'leri BUNU uzatır (kalan sayacı değil — "Gün 2/4"+2 → "Gün 2/6", geri
# gitme bug fix'i). Tur bitince const'a döner (uzatma sonraki tura taşınmaz).
# 0 = eski save → okuma tarafı const'a düşer (forward-compat).
@export var iteration_round_days: float = 0.0
# DEPRECATED (Tracker Card dört-faz akışı): iterasyonlar artık otomatik döner,
# karar-bekleme modeli kalktı. Alan save-compat için duruyor, hep false.
@export var iteration_decision_pending: bool = false
# Development phase span — derived from feature complexity at start_build()
# time and ticked down during _tick_development_phase().
@export var development_days_total: int = 0
# B2: FLOAT so development/sprint progress advances hourly (1/24 per hour) and
# reads smooth. development_days_total stays an int (whole-day duration).
@export var development_days_elapsed: float = 0.0

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


# A strengthened feature contributes as if its dimension_contribution were multiplied by
# this factor (pool-deepening) — redistribution only, so the COST is that the other axes'
# normalized share drops. BALANCE-TUNABLE.
const STRENGTHEN_CONTRIB_FACTOR := 3.0


# Normalized per-axis share (sums to 1) of the selected features' quality focus.
# Steers WHICH axis climbs fastest during the build (ProductSystem scales phase
# raws by this). Reads each feature's `dimension_contribution` {innovation,
# stability, usability}; falls back to an equal split when features carry no
# contribution data yet (safe pre-Blok-B).
func get_dimension_weights() -> Dictionary:
	var acc := {"innovation": 0.0, "stability": 0.0, "usability": 0.0}
	var any := false
	for fid in feature_ids:
		var f: Dictionary = ProductCatalog.get_feature_by_id(fid)
		var dc: Dictionary = f.get("dimension_contribution", {})
		# Strengthened features weigh more → their axes climb faster, the others slower.
		var boost: float = STRENGTHEN_CONTRIB_FACTOR if strengthened_feature_ids.has(fid) else 1.0
		for axis in acc.keys():
			var v: float = float(dc.get(axis, 0.0)) * boost
			if v > 0.0:
				any = true
			acc[axis] += v
	var total: float = acc["innovation"] + acc["stability"] + acc["usability"]
	if not any or total <= 0.0:
		return {"innovation": 1.0 / 3.0, "stability": 1.0 / 3.0, "usability": 1.0 / 3.0}
	return {
		"innovation": acc["innovation"] / total,
		"stability": acc["stability"] / total,
		"usability": acc["usability"] / total,
	}


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
