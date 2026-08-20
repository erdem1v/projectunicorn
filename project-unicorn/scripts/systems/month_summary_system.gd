class_name MonthSummarySystem
extends RefCounted

# Month-End Summary — daily tick slot 10 per ENDGAME_DESIGN.md §1.1 (Spec 3).
#
# At the end of every CALENDAR month (real 28/30/31-day months via
# GameState.get_date_dict — never the economy constant DAYS_PER_MONTH), builds
# a one-screen recap payload and emits EventBus.month_ended. main.gd mounts
# MonthSummaryModal on it. Six beats across a run; doubles as the data seam
# the newspaper ending screen will consume later (run counters live on
# GameState and are write-only here — this summary shows MonthLedger deltas,
# never the counters; two data shapes, two questions).
#
# Ordering: slot 10 runs AFTER the endings scan (slot 9). If a terminal fired
# the same day, run_active is already false and the summary is suppressed —
# the ending wins (§7.1/§7.2 logic). Kepenk active is deliberately NOT a
# suppressor: the recap is most valuable mid-countdown.
# The FISCAL CLOSE lands here too (Calibration Round A §3/§9): the month that just ended
# is pushed onto GameState.month_history before the recap, so slot 8 (the Series A gate's
# growth streak) and slot 9 (the profitability condition) read the closed month the NEXT
# day — a one-day lag, deliberate: the recap is seen before a month-driven gate or ending.
#
# Static, stateless (FinanceSystem pattern); all persistent state lives on
# GameState (§7.9): month_ledger (snapshot keys written by snapshot(); accrual keys by
# the two accrue_* seams), month_history (the closed-month ring), month_highlight_*.

# Fallback highlight when nothing claimed the month. Not a const — a const is evaluated
# at load, before a locale exists.
static func highlight_fallback() -> String:
	return TranslationServer.translate("MONTH_HIGHLIGHT_FALLBACK")


static func daily_tick() -> void:
	if not GameState.run_active:
		return  # terminal-wins guard (belt-and-braces on top of slot order)
	if GameState.day <= 1:
		return
	var today: Dictionary = GameState.get_date_dict()
	if int(today.day) != 1:
		return  # month closes when the rollover lands on the 1st of the next month
	_close_fiscal_month()
	EventBus.month_ended.emit(_build_summary_data())
	snapshot()  # open the new month's ledger + clear the highlight


static func _close_fiscal_month() -> void:
	# The closed month's accruals become one entry of GameState.month_history. MRR is the
	# CLOSE value (the month-over-month growth streak compares closes).
	var l: Dictionary = GameState.month_ledger
	var income: int = int(l.get("income", 0))
	var expense: int = int(l.get("expense", 0))
	GameState.push_month_close({
		"start_day": int(l.get("start_day", 1)),
		"end_day": GameState.day,
		"mrr_close": GameState.mrr,
		"income": income,
		"expense": expense,
		"net": income - expense,
		"red_days": int(l.get("red_days", 0)),
	})


static func snapshot() -> void:
	# Month-start snapshot. Also called at the end of initialize_run (month 1).
	GameState.month_ledger = {
		"start_day": GameState.day,
		"mrr": GameState.mrr,
		"cash": GameState.cash,
		"employees": _team_size(),
		"brand": GameState.brand,
		# Month-start baselines of the run-cumulative customer counters, so the Sales
		# pulse strip can read a THIS-MONTH delta (gained/lost/net) read-only. The month
		# modal ignores these (it shows mrr/cash/team/brand deltas — two data shapes).
		"customers_signed": GameState.run_customers_signed,
		"customers_lost": GameState.run_customers_lost,
		# Accrual keys of the OPEN month (Calibration Round A §3/§9) — written by
		# GameState.accrue_month_flow / accrue_month_expense, read by _close_fiscal_month.
		"income": 0,
		"expense": 0,
		"red_days": 0,
	}
	GameState.month_highlight_text = ""
	GameState.month_highlight_priority = -1


static func _build_summary_data() -> Dictionary:
	# Contract consumed by MonthSummaryModal.populate(). The closed month is
	# YESTERDAY's month (this runs on the 1st of the new one).
	var closed: Dictionary = GameState.get_date_dict(GameState.day - 1)
	var ledger: Dictionary = GameState.month_ledger
	var data := {
		"month_title": TranslationServer.translate("MONTH_TITLE").format(
			{"month": Fmt.month_upper(int(closed.month)), "year": int(closed.year)}),
		"day_range": TranslationServer.translate("MONTH_DAY_RANGE").format(
			{"from": int(ledger.get("start_day", 1)), "to": GameState.day - 1}),
		"phase_name": GameState.phase_display_name(GameState.phase),  # single home (game_state.gd)
		"mrr": {"from": int(ledger.get("mrr", 0)), "to": GameState.mrr},
		"cash": {"from": int(ledger.get("cash", 0)), "to": GameState.cash},
		"team": {"from": int(ledger.get("employees", 1)), "to": _team_size()},
		"brand": {"from": int(ledger.get("brand", 50)), "to": GameState.brand},
		"runway_text": UiTokens.net_runway_text(GameState.get_runway_months()),
		"highlight": GameState.month_highlight_text if GameState.month_highlight_text != "" else highlight_fallback(),
		"shutter_active": GameState.shutter_days_left >= 0,
	}
	data["frank_line"] = _pick_frank_line(data)
	return data


static func _team_size() -> int:
	# "Ekip" = founder + payroll employees; the mentor is an advisor, not team.
	return 1 + CharacterRegistry.get_employees().size()


# --- Debug (F11 / Shift+F11 in game_shell) ---

static func debug_force_summary(extreme: bool = false) -> void:
	# F11: emit the summary NOW with live data (layout/flow check without
	# waiting a month). Shift+F11: extreme-value fixture — the spec §5 layout
	# stress test ("$999.9K → $1.2M", 3-digit team) stays reproducible. Its strings are a
	# FIXTURE, not shipped copy: the point is a long Turkish headline overflowing the band,
	# so keying them would defeat the test. Debug build only (F11 is gated on it).
	if extreme:
		EventBus.month_ended.emit({
			"month_title": "AĞUSTOS 2026",   # LOC-DATA layout fixture
			"day_range": "Gün 212–242",   # LOC-DATA layout fixture
			"phase_name": "Series A",   # LOC-DATA layout fixture
			"mrr": {"from": 999_900, "to": 1_200_000},
			"cash": {"from": 999_900, "to": 1_200_000},
			"team": {"from": 98, "to": 120},
			"brand": {"from": 12, "to": 100},
			"runway_text": "8 ay",   # LOC-DATA layout fixture
			"highlight": "Uzun bir başlık taşma testi — satın alma teklifi masada, Nordica $1.2K/ay imzalandı",   # LOC-DATA layout fixture
			"frank_line": "İyi bir ay. Not al — nadir gelirler.",   # LOC-DATA layout fixture
			"shutter_active": false,
		})
		return
	EventBus.month_ended.emit(_build_summary_data())


static func _pick_frank_line(data: Dictionary) -> String:
	# First matching rule, top-down (Spec 3 §7). Working TR copy; content
	# phase replaces. NPC register: short, dry, no scene-setting.
	var mrr_delta: int = int(data.mrr.to) - int(data.mrr.from)
	var cash_delta: int = int(data.cash.to) - int(data.cash.from)
	var team_delta: int = int(data.team.to) - int(data.team.from)
	var brand_delta: int = int(data.brand.to) - int(data.brand.from)
	if bool(data.shutter_active):
		return TranslationServer.translate("MONTH_FRANK_SHUTTER")
	if cash_delta < 0 and mrr_delta > 0:
		return TranslationServer.translate("MONTH_FRANK_BURNING_BUT_SELLING")
	if mrr_delta < 0:
		return TranslationServer.translate("MONTH_FRANK_SHRINKING")
	if mrr_delta > 0 and cash_delta > 0 and team_delta > 0 and brand_delta > 0:
		return TranslationServer.translate("MONTH_FRANK_GOOD")
	return TranslationServer.translate("MONTH_FRANK_ANOTHER")
