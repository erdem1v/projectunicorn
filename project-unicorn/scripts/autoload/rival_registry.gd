extends Node

# Rival registry (Product Lifecycle Part 1) — single source of truth for the
# competitive field. Mirrors CustomerRegistry: a Dictionary id→Rival, read-only
# query API, mutations emit on EventBus so scenes (RightPanel) self-update.
#
# Seeded from RivalCatalog at _ready. Rivals evolve slowly on the daily tick
# (advance_all, called by TimeManager) — startups fast, established slow, giants
# static — so a player who stops feeding their product gets passed.
#
# STRUCTURAL CEILING: rival advancement uses QualityModel.grow with per-tier
# asymptotes. The player's Rev3 axes are bounded by the catalog pool sums (+
# strengthen accretion paid in efor/time), which sit far below the giant band
# (composite ≈ 285). Enforced by the number bands, not a clamp.

const TIER_ASYMPTOTE := {"startup": 100.0, "established": 200.0, "giant": 330.0}

var _rivals: Dictionary = {}   # id -> Rival


func _ready() -> void:
	for r in RivalCatalog.build_all():
		r.status = _status_for(r)
		_rivals[r.id] = r
		EventBus.rival_added.emit(r.id)


# --- Read API ---

func get_rival(rival_id: String) -> Rival:
	return _rivals.get(rival_id, null)


func get_all() -> Array[Rival]:
	var out: Array[Rival] = []
	for r in _rivals.values():
		out.append(r)
	return out


func get_by_type(sub_type_id: String) -> Array[Rival]:
	var out: Array[Rival] = []
	for r in _rivals.values():
		if r.sub_product_type_id == sub_type_id:
			out.append(r)
	return out


func get_by_tier(tier: String) -> Array[Rival]:
	var out: Array[Rival] = []
	for r in _rivals.values():
		if r.tier == tier:
			out.append(r)
	return out


# Rank the player among same-type STARTUP rivals. Returns {rank, total, text}.
# rank is 1-based (1 = ahead of every startup rival). total = startup rivals + the
# player. `player_composite` should be the player's type-weighted composite.
func get_player_rank_in_startup_league(sub_type_id: String, player_composite: float) -> Dictionary:
	var axes: Array = ProductCatalog.get_quality_axes(sub_type_id)
	var league: int = 0
	var better: int = 0
	for r in _rivals.values():
		if r.tier == "startup" and r.sub_product_type_id == sub_type_id:
			league += 1
			if r.composite(axes) > player_composite:
				better += 1
	var total: int = league + 1
	var rank: int = better + 1
	return {"rank": rank, "total": total, "text": "startup liginde %d/%d" % [rank, total]}


# --- Advancement (called daily by TimeManager) ---

func advance_all(days: int = 1) -> void:
	var any_changed: bool = false
	for r in _rivals.values():
		if r.momentum <= 0.0:
			continue   # giants are static
		var a: float = float(TIER_ASYMPTOTE.get(r.tier, 100.0))
		for _i in days:
			r.innovation = QualityModel.grow(r.innovation, r.momentum, a)
			r.stability = QualityModel.grow(r.stability, r.momentum, a)
			r.experience = QualityModel.grow(r.experience, r.momentum, a)
		var new_status: String = _status_for(r)
		if new_status != r.status:
			r.status = new_status
			EventBus.rival_status_changed.emit(r.id, new_status)
		any_changed = true
	if any_changed:
		EventBus.rival_advanced.emit()


func _status_for(r: Rival) -> String:
	if r.tier == "giant":
		return "DOMINANT"
	if r.tier == "established":
		return "STEADY"
	return "SCALING" if r.momentum >= 0.6 else "QUIET"
