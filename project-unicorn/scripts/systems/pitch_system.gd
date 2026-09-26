class_name PitchSystem
extends RefCounted

# The event channel's door into the sales pipeline, and the shared signing-satisfaction seed.
#
# `spawn_prospect(size, source)`: Satış §3 routes the whale role through "kahraman hesap / olay
# kanalı", and the engine's `add_prospect` effect is that channel and names this symbol. Its
# card (`customer/frank_intro.json`) speaks the three-tier size ids, so the translation to a
# STAR happens here, once, rather than in every card.
#
# `signing_satisfaction_seed()` is the shared expression that decides what a fresh account
# feels on day one. Both signing paths — the played meeting and the rep's own close — read
# it, which is what stops the two from drifting apart under a later edit.


## The event channel's entry into the pipeline. `size` is the three-tier id the card speaks;
## the star is the truth on the other side of this call.
static func spawn_prospect(size: String, source: String) -> Prospect:
	var star: int = int(SalesFaucetSystem.LEGACY_SIZE_TO_STAR.get(size, 1))
	return SalesFaucetSystem.spawn(star, source)


## A signed B2B account's opening satisfaction: Stability + Experience, off effective quality
## — reliability and ease, which is what a business buyer feels on day one.
static func signing_satisfaction_seed() -> int:
	var dims: Dictionary = QualityModel.economy_dims_from_flags()
	return int(round(
		(QualityModel.axis_score(dims, "stability") + QualityModel.axis_score(dims, "experience")) * 0.5))
