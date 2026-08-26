class_name PitchSystem
extends RefCounted

# WHAT IS LEFT OF THE OLD PITCH — and why anything is left at all.
#
# SATIŞ rev 6 §19 retires this file's entire machine: the four-beat script (intro / value /
# pricing / close), the two-day cooldown, CALLBACK's infinite lead, the archetype-band deal
# MRR, the sector-affinity narrowing and the 65-name catalogue's sole-supply role. All of it
# is gone. Act 1 is `SalesMeetingSystem`, Act 2 is `NegotiationSystem`, and the supply is
# `SalesFaucetSystem`.
#
# TWO FUNCTIONS SURVIVE, AND NEITHER IS A COURTESY:
#
# 1. `spawn_prospect(size, source)` is a LIVE REQUIREMENT, not a legacy shim. §3 rules that
#    the whale role "karışımdan değil, kahraman hesap / olay kanalından gelir" — the faucet
#    deliberately does not produce whales, the event channel does. The engine's `add_prospect`
#    effect (scripts/events/core/effects.gd) is that channel and it names this symbol. Two
#    shipped cards use it today (`customer/frank_intro.json`, `customer/referral.json`) and
#    both speak the retired three-tier size ids, so the translation to a STAR happens here,
#    once, rather than in every card.
#
# 2. `signing_satisfaction_seed()` is the shared expression that decides what a fresh account
#    feels on day one. Both signing paths — the played meeting and the rep's own close — read
#    it, which is what stops the two from drifting apart under a later edit.
#
# The class name stays because the engine binds to it by name and this module edits no engine
# file. That is the whole reason, stated here so the next reader does not "clean it up".


## The event channel's entry into the pipeline. `size` is the retired three-tier id the
## shipped cards still speak; the star is the truth on the other side of this call.
static func spawn_prospect(size: String, source: String) -> Prospect:
	var star: int = int(SalesFaucetSystem.LEGACY_SIZE_TO_STAR.get(size, 1))
	return SalesFaucetSystem.spawn(star, source)


## A signed B2B account's opening satisfaction: Stability + Experience, off effective quality
## — reliability and ease, which is what a business buyer feels on day one.
static func signing_satisfaction_seed() -> int:
	var dims: Dictionary = QualityModel.economy_dims_from_flags()
	return int(round(
		(QualityModel.axis_score(dims, "stability") + QualityModel.axis_score(dims, "experience")) * 0.5))


## Kept for SaveManager.reset_all_owners, whose ordered list names this owner. There is no
## sitting-scoped state left here — the meeting and the negotiation own theirs — so the reset
## delegates to the two systems that actually hold one.
static func reset() -> void:
	SalesMeetingSystem.reset()
	NegotiationSystem.reset()
