class_name CustomerArchetypes
extends RefCounted

# THE single data home for B2B customer-archetype numbers ("small" | "mid" | "enterprise").
# Values moved VERBATIM (2026-07-21 centralization sweep) from: SalesSystem._seats_for_archetype,
# B2BConstants.EXPANSION_SEATS, PitchSystem.MRR_BANDS, B2BConstants.roll_scale bases,
# PitchSystem._difficulty_for / _budget_for. Those five sites are now readers.
#
# KNOWN DIVERGENCES kept as-is (director decision at the curve session — do not harmonize):
#   - initial seats 40/12/4 (stock at signing) vs expansion_seats 12/6/3 (per-upsell step);
#   - scale_base 5/3/2 (account size → tolerance seed / support load / the sales-tab star
#     widget) vs difficulty_stars 4/2/1 (pitch close difficulty) — two independent size
#     encodings of the same three-tier ordinal.
# Tolerance seeds (B2BConstants.TOLERANCE_*) are SCALE-keyed, not archetype-keyed —
# archetype reaches them indirectly through scale_base; they stay in B2BConstants.
# Unknown/blank archetype falls back to DEFAULT_ARCHETYPE, matching every prior
# per-table default (4 seats / 3 expansion / small band / base 2 / 1 star / "low").

const DEFAULT_ARCHETYPE := "small"

const TABLE := {
	"small": {
		"seats": 4,
		"expansion_seats": 3,
		"mrr_band": {"low": 200, "high": 500},
		"scale_base": 2,
		"difficulty_stars": 1,
		"budget_band": "low",
	},
	"mid": {
		"seats": 12,
		"expansion_seats": 6,
		"mrr_band": {"low": 800, "high": 2000},
		"scale_base": 3,
		"difficulty_stars": 2,
		"budget_band": "mid",
	},
	"enterprise": {
		"seats": 40,
		"expansion_seats": 12,
		"mrr_band": {"low": 3000, "high": 8000},
		"scale_base": 5,
		"difficulty_stars": 4,
		"budget_band": "high",
	},
}


static func _row(archetype: String) -> Dictionary:
	return TABLE.get(archetype, TABLE[DEFAULT_ARCHETYPE])


static func seats(archetype: String) -> int:
	return int(_row(archetype)["seats"])


static func expansion_seats(archetype: String) -> int:
	return int(_row(archetype)["expansion_seats"])


static func mrr_band(archetype: String) -> Dictionary:
	# Read-only const dict {low, high} — callers must not mutate.
	return _row(archetype)["mrr_band"]


static func scale_base(archetype: String) -> int:
	return int(_row(archetype)["scale_base"])


static func difficulty_stars(archetype: String) -> int:
	return int(_row(archetype)["difficulty_stars"])


static func budget_band(archetype: String) -> String:
	return String(_row(archetype)["budget_band"])
