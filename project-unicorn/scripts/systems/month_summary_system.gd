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
#
# Static, stateless (FinanceSystem pattern); all persistent state lives on
# GameState (§7.9): month_ledger, month_highlight_*.

const HIGHLIGHT_FALLBACK := "Sakin bir ay. Sakin aylar ucuz değildir."


static func daily_tick() -> void:
	if not GameState.run_active:
		return  # terminal-wins guard (belt-and-braces on top of slot order)
	if GameState.day <= 1:
		return
	var today: Dictionary = GameState.get_date_dict()
	if int(today.day) != 1:
		return  # month closes when the rollover lands on the 1st of the next month
	EventBus.month_ended.emit(_build_summary_data())
	snapshot()  # open the new month's ledger + clear the highlight


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
	}
	GameState.month_highlight_text = ""
	GameState.month_highlight_priority = -1


static func _build_summary_data() -> Dictionary:
	# Contract consumed by MonthSummaryModal.populate(). The closed month is
	# YESTERDAY's month (this runs on the 1st of the new one).
	var closed: Dictionary = GameState.get_date_dict(GameState.day - 1)
	var ledger: Dictionary = GameState.month_ledger
	var phase_names := ["Bootstrap", "Traction", "Series A"]  # TopBar display names
	var data := {
		"month_title": "%s %d" % [GameState.MONTH_NAMES_TR[int(closed.month) - 1], int(closed.year)],
		"day_range": "Gün %d–%d" % [int(ledger.get("start_day", 1)), GameState.day - 1],
		"phase_name": phase_names[clampi(GameState.phase - 1, 0, phase_names.size() - 1)],
		"mrr": {"from": int(ledger.get("mrr", 0)), "to": GameState.mrr},
		"cash": {"from": int(ledger.get("cash", 0)), "to": GameState.cash},
		"team": {"from": int(ledger.get("employees", 1)), "to": _team_size()},
		"brand": {"from": int(ledger.get("brand", 50)), "to": GameState.brand},
		"runway_text": UiTokens.net_runway_text(GameState.get_runway_months()),
		"highlight": GameState.month_highlight_text if GameState.month_highlight_text != "" else HIGHLIGHT_FALLBACK,
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
	# stress test ("$999.9K → $1.2M", 3-digit team) stays reproducible.
	if extreme:
		EventBus.month_ended.emit({
			"month_title": "AĞUSTOS 2026",
			"day_range": "Gün 212–242",
			"phase_name": "Series A",
			"mrr": {"from": 999_900, "to": 1_200_000},
			"cash": {"from": 999_900, "to": 1_200_000},
			"team": {"from": 98, "to": 120},
			"brand": {"from": 12, "to": 100},
			"runway_text": "8 ay",
			"highlight": "Uzun bir başlık taşma testi — satın alma teklifi masada, Nordica $1.2K/ay imzalandı",
			"frank_line": "İyi bir ay. Not al — nadir gelirler.",
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
		return "Kepenk sayıyor. Özet güzel görünse de sayıyor."
	if cash_delta < 0 and mrr_delta > 0:
		return "Para yakıyorsun ama bir şey satıyorsun. Şimdilik doğru sıradasın."
	if mrr_delta < 0:
		return "Küçülen rakam yalan söylemez. Sebebini sen bul."
	if mrr_delta > 0 and cash_delta > 0 and team_delta > 0 and brand_delta > 0:
		return "İyi bir ay. Not al — nadir gelirler."
	return "Bir ay daha. Ayakta olmak da bir metrik."
