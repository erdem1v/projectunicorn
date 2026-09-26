class_name EvSeamsFinance
extends RefCounted

# The `finance.` namespace. Finance has no named read surface — its numbers are public vars on
# GameState — so most rows are WRAPPERS that name the field they stand in front of.

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

	# INF when default-alive ("Artıda"), so a condition must test "runway BELOW x"; "above"
	# reads true forever once the company turns profitable.
	EvSeams.register("finance.runway_months", G, TYPE_FLOAT,
		func() -> float: return GameState.get_runway_months(),
		"Finance", "INF when net >= 0 — compare with '<', never '>'")

	# The day-valued runway the shutter and the soft cap think in, with INF mapped to 9999
	# rather than multiplied.
	EvSeams.register("finance.runway_days", G, TYPE_INT,
		func() -> int:
			var months: float = GameState.get_runway_months()
			if is_inf(months) or months < 0.0:
				return 9999
			return int(round(months * 30.0)),
		"Finance", "WRAPPER; 9999 stands for default-alive")

	EvSeams.register("finance.shutter_days_left", G, TYPE_INT,
		func() -> int: return GameState.shutter_days_left,
		"Finance", "WRAPPER; -1 when not counting, else counts down")

	# §8.4: the number lives here and copy interpolates it, so a sentence cannot go stale.
	EvSeams.register("finance.shutter_days_total", G, TYPE_INT,
		func() -> int: return EndingsSystem.SHUTTER_DAYS,
		"Finance", "the shutter window; card text interpolates this rather than typing it")

	EvSeams.register("finance.profit_streak_months", G, TYPE_INT,
		func() -> int: return GameState.get_profitable_month_streak(),
		"Finance", "consecutive closed months in the black with no red days")
	EvSeams.register("finance.growth_streak_months", G, TYPE_INT,
		func() -> int: return GameState.get_mrr_growth_streak(PhaseGateSystem.GROWTH_MIN_PCT),
		"Finance", "consecutive closed months of MRR growth")
	EvSeams.register("finance.months_closed", G, TYPE_INT,
		func() -> int: return GameState.month_history.size(),
		"Finance", "WRAPPER; capped at 12 by the ledger")
	EvSeams.register("finance.investor_equity_pct", G, TYPE_INT,
		func() -> int: return GameState.get_investor_equity_pct(), "Finance", "0-100")
	EvSeams.register("finance.total_raised", G, TYPE_INT,
		func() -> int: return GameState.get_total_raised(), "Finance", "cash in from all rounds")
