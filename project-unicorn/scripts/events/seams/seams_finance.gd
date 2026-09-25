class_name EvSeamsFinance
extends RefCounted

# The `finance.` namespace (docs/SEAM_REGISTRY.md §4).
#
# Unlike HR, Ürün and Ar-Ge, Finance never opened a named read surface — its numbers live as
# public vars on GameState. So most of this file is WRAPPERS, and they are honest about it:
# each one names the field it stands in front of, and each retires the day Finance names its
# own query. Content does not have to wait for that day.

static func install() -> void:
	var G := EvSeams.Kind.GLOBAL

	EvSeams.register("finance.cash", G, TYPE_INT,
		func() -> int: return GameState.cash,
		"Finance", "WRAPPER over GameState.cash; MAY BE NEGATIVE, which is what starts the shutter")
	EvSeams.register("finance.mrr", G, TYPE_INT,
		func() -> int: return GameState.mrr, "Finance", "WRAPPER; the headline revenue number")
	EvSeams.register("finance.peak_mrr", G, TYPE_INT,
		func() -> int: return GameState.run_peak_mrr, "Finance", "WRAPPER; high-water mark")
	EvSeams.register("finance.daily_burn", G, TYPE_INT,
		func() -> int: return GameState.daily_burn, "Finance", "WRAPPER; day 1 is $50")
	EvSeams.register("finance.daily_net", G, TYPE_INT,
		func() -> int: return GameState.get_net_daily_flow(), "Finance", "signed")
	EvSeams.register("finance.brand", G, TYPE_INT,
		func() -> int: return GameState.brand, "Finance", "WRAPPER; clamped 0-100")
	EvSeams.register("finance.reputation", G, TYPE_INT,
		func() -> int: return GameState.reputation, "Finance", "WRAPPER; clamped -10..100")

	# Runway. INF when the company is default-alive, and that is not a rounding artefact — it
	# is the state the game calls "Artıda". A condition comparing against it must therefore be
	# written as "runway BELOW x", never "above", or it reads true forever the moment the
	# company turns profitable.
	EvSeams.register("finance.runway_months", G, TYPE_FLOAT,
		func() -> float: return GameState.get_runway_months(),
		"Finance", "INF when net >= 0 — compare with '<', never '>'")

	# finance.runway_days — the day-valued runway the shutter and the soft cap think in.
	# YOK as data: the only day figure in the codebase lives inside display code
	# (ui_tokens.gd:785, and its helper is private). Wrapped here, with INF handled rather
	# than multiplied — 30 * INF is not a number anyone wants in a condition.
	EvSeams.register("finance.runway_days", G, TYPE_INT,
		func() -> int:
			var months: float = GameState.get_runway_months()
			if is_inf(months) or months < 0.0:
				return 9999
			return int(round(months * 30.0)),
		"Finance", "WRAPPER, filed as YOK; 9999 stands for default-alive")

	EvSeams.register("finance.shutter_days_left", G, TYPE_INT,
		func() -> int: return GameState.shutter_days_left,
		"Finance", "WRAPPER; -1 when not counting, else counts down")

	# The seam that kills defect 9. END_META_BANKRUPTCY_FRANK says "yedi gün" while the
	# constant has been 30 since the Frank v6 pass — a sentence that went stale because a
	# number was typed into prose. §8.4's rule is that the number lives here and the copy
	# interpolates it, so the sentence cannot lie again.
	EvSeams.register("finance.shutter_days_total", G, TYPE_INT,
		func() -> int: return EndingsSystem.SHUTTER_DAYS,
		"Finance", "the shutter window; card text interpolates this rather than typing it")

	EvSeams.register("finance.profit_streak_months", G, TYPE_INT,
		func() -> int: return GameState.get_profitable_month_streak(),
		"Finance", "consecutive closed months in the black with no red days")
	EvSeams.register("finance.growth_streak_months", G, TYPE_INT,
		func() -> int: return GameState.get_mrr_growth_streak(PhaseGateSystem.GROWTH_MIN_PCT),
		"Finance", "consecutive closed months of MRR growth; no longer a Series A gate condition (K1)")
	EvSeams.register("finance.months_closed", G, TYPE_INT,
		func() -> int: return GameState.month_history.size(),
		"Finance", "WRAPPER; capped at 12 by the ledger")
	EvSeams.register("finance.investor_equity_pct", G, TYPE_INT,
		func() -> int: return GameState.get_investor_equity_pct(), "Finance", "0-100")
	EvSeams.register("finance.total_raised", G, TYPE_INT,
		func() -> int: return GameState.get_total_raised(), "Finance", "cash in from all rounds")
