class_name SummarySystem
extends RefCounted

# The calendar-month close and the period summary.
#
# Slot 0 (begin_day), before any system writes the new tick. A tick belongs to its Thursday's
# month (GameState.get_date_dict, never the economy constant DAYS_PER_MONTH). When the tick opens
# a new month, the month that ended is pushed onto month_history, month_ended is emitted and the
# new month's ledger opens, so this week's money flow lands in the new month. When the player's
# summary frequency closes a period on this tick, its payload is built from the state the last
# week left and the next period opens.
# Slot 10 (daily_tick), after the endings scan: the payload is posted to the inbox and goes out
# as summary_ready, and the month-close and runway lines go to the ticker, only while the run is
# on, so an ending on the same tick wins. A running Kepenk does not suppress the summary: it
# matters most mid-countdown. The payload is numbers and keys; `display` renders it.
#
# Persistent state lives on GameState: month_ledger (the month's opening cash and customer
# counts plus the accruals the two accrue_* seams write), month_history, summary_ledger (the
# period's opening snapshot), month_highlight* (the period's highlight) and runway_warn_band.

const SETTING_FREQUENCY := "summary_frequency"
const FREQUENCIES: Array[String] = ["weekly", "monthly", "quarterly", "yearly"]
const QUARTER_FIRST_MONTHS := [1, 4, 7, 10]

# Per frequency: the title, the highlight caption, the quiet-period highlight and the footer.
const PERIOD_KEYS := {
	"weekly": {"title": "SUMMARY_TITLE_WEEK", "caption": "SUMMARY_EVENT_WEEK",
		"quiet": "SUMMARY_HIGHLIGHT_FALLBACK_WEEK", "footer": "SUMMARY_AUTO_WEEK"},
	"monthly": {"title": "MONTH_TITLE", "caption": "MONTH_EVENT_OF_THE_MONTH",
		"quiet": "MONTH_HIGHLIGHT_FALLBACK", "footer": "MONTH_AUTO_SUMMARY"},
	"quarterly": {"title": "SUMMARY_TITLE_QUARTER", "caption": "SUMMARY_EVENT_QUARTER",
		"quiet": "SUMMARY_HIGHLIGHT_FALLBACK_QUARTER", "footer": "SUMMARY_AUTO_QUARTER"},
	"yearly": {"title": "SUMMARY_TITLE_YEAR", "caption": "SUMMARY_EVENT_YEAR",
		"quiet": "SUMMARY_HIGHLIGHT_FALLBACK_YEAR", "footer": "SUMMARY_AUTO_YEAR"},
}

# Frank's other summary lines say "month"; outside monthly mode only these two may speak.
const PERIOD_NEUTRAL_FRANK := ["MONTH_FRANK_BURNING_BUT_SELLING", "MONTH_FRANK_SHRINKING"]

# Smoke and the probe pin the frequency here: Settings.set_value would write the player's file.
static var frequency_override: String = ""

# Built at slot 0, sent and cleared at slot 10 of the same tick.
static var _summary: Dictionary = {}
static var _month_line: String = ""


## Run start (GameState.initialize_run, fresh runs): the first month and summary period open,
## and the runway band starts where runway already is, so the first tick announces nothing.
static func snapshot() -> void:
	_open_month()
	_open_period()
	GameState.runway_warn_band = FinanceSystem.runway_band(GameState.get_runway_months())


## Daily slot 0, right after advance_day.
static func begin_day() -> void:
	var month: int = int(GameState.get_date_dict().month)
	var month_turned: bool = month != int(GameState.get_date_dict(GameState.day - 1).month)
	var freq: String = _frequency()
	var due: bool
	match freq:
		"weekly":
			due = true
		"monthly":
			due = month_turned
		"quarterly":
			due = month_turned and QUARTER_FIRST_MONTHS.has(month)
		_:
			due = month_turned and month == 1
	if due:
		_summary = _build_summary_data(freq, GameState.day - 1)
		_open_period()
	if month_turned:
		_close_month()


## Daily slot 10, after the endings scan.
static func daily_tick() -> void:
	var summary: Dictionary = _summary
	var month_line: String = _month_line
	_summary = {}
	_month_line = ""
	if not GameState.run_active:
		return
	var source: String = TranslationServer.translate("NOTICE_SRC_FINANCE")
	if month_line != "":
		EventBus.ticker_live_line.emit(source, month_line)
	if GameState.cash >= 0:
		var runway_line: String = _runway_line()
		if runway_line != "":
			EventBus.ticker_live_line.emit(source, runway_line)
	if not summary.is_empty():
		MessageSystem.post("summary", String(PERIOD_KEYS[summary.freq].title), summary)
		EventBus.summary_ready.emit(summary)


static func _frequency() -> String:
	if frequency_override != "":
		return frequency_override
	return Settings.get_choice(SETTING_FREQUENCY, FREQUENCIES)


static func _close_month() -> void:
	# The closed month's accruals become one entry of GameState.month_history. MRR is the
	# CLOSE value (the month-over-month growth streak compares closes).
	var l: Dictionary = GameState.month_ledger
	var income: int = int(l.get("income", 0))
	var expense: int = int(l.get("expense", 0))
	var close := {
		"start_day": int(l.get("start_day", 1)),
		"end_day": GameState.day,
		"mrr_close": GameState.mrr,
		"income": income,
		"expense": expense,
		"net": income - expense,
		"red_weeks": int(l.get("red_weeks", 0)),
	}
	GameState.push_month_close(close)
	var cash_delta: int = GameState.cash - int(l.get("cash", GameState.cash))
	_month_line = TranslationServer.translate("MONTH_CLOSED_TICKER").format({
		"month": Fmt.month_name(int(GameState.get_date_dict(GameState.day - 1).month)),
		"mrr": Fmt.money(GameState.mrr),
		"delta": ("+" if cash_delta > 0 else "") + Fmt.money(cash_delta),
	})
	_open_month()
	EventBus.month_ended.emit(close)


static func _open_month() -> void:
	GameState.month_ledger = {
		"start_day": GameState.day,
		"cash": GameState.cash,
		# Month-start baselines of the run-cumulative customer counters, so the Sales pulse
		# strip can read a THIS-MONTH delta (gained/lost/net) read-only.
		"customers_signed": GameState.run_customers_signed,
		"customers_lost": GameState.run_customers_lost,
		# Accrual keys of the OPEN month — written by
		# GameState.accrue_month_flow / accrue_month_expense, read by _close_month.
		"income": 0,
		"expense": 0,
		"red_weeks": 0,
	}


static func _open_period() -> void:
	GameState.summary_ledger = {
		"start_day": GameState.day,
		"mrr": GameState.mrr,
		"cash": GameState.cash,
		"employees": _team_size(),
		"brand": GameState.brand,
	}
	GameState.month_highlight.clear()
	GameState.month_highlight_priority = -1


## Announces only the lowest threshold crossed on the way down. A threshold re-arms once runway
## climbs RUNWAY_ALERT_REARM_MONTHS above it (an infinite runway re-arms them all).
static func _runway_line() -> String:
	var months: float = GameState.get_runway_months()
	var alerts: Array = FinanceSystem.RUNWAY_ALERT_MONTHS
	var band: int = GameState.runway_warn_band
	while band > 0 and months >= band + FinanceSystem.RUNWAY_ALERT_REARM_MONTHS:
		var i: int = alerts.find(band)
		band = int(alerts[i - 1]) if i > 0 else 0
	var now: int = FinanceSystem.runway_band(months)
	var line: String = ""
	if now > 0 and (band == 0 or now < band):
		band = now
		line = TranslationServer.translate(Fmt.count_key("RUNWAY_CROSS_TICKER", now)).format(
			{"n": now})
	GameState.runway_warn_band = band
	return line


static func _build_summary_data(freq: String, last_day: int) -> Dictionary:
	# The period runs from the summary_ledger snapshot through the week of last_day.
	var ledger: Dictionary = GameState.summary_ledger
	var data := {
		"freq": freq,
		"start_day": int(ledger.get("start_day", 1)),
		"last_day": last_day,
		"phase": GameState.phase,
		"mrr": {"from": int(ledger.get("mrr", 0)), "to": GameState.mrr},
		"cash": {"from": int(ledger.get("cash", 0)), "to": GameState.cash},
		"team": {"from": int(ledger.get("employees", 1)), "to": _team_size()},
		"brand": {"from": int(ledger.get("brand", 50)), "to": GameState.brand},
		"net": GameState.get_net_daily_flow(),   # the runway is rebuilt from cash and this
		"shutter": GameState.shutter_weeks_left >= 0,
		"highlight": GameState.month_highlight.duplicate(true),
	}
	data["frank_key"] = _pick_frank_line(data, freq == "monthly")
	return data


## The payload's text in the current language, as the inbox's report mail reads it.
static func display(p: Dictionary) -> Dictionary:
	var keys: Dictionary = PERIOD_KEYS[p.freq]
	var start_day: int = int(p.start_day)
	var last_day: int = int(p.last_day)
	var last: Dictionary = GameState.get_date_dict(last_day)
	var cash_to: int = int(p.cash.to)
	var highlight: Dictionary = p.highlight
	return {
		"title": TranslationServer.translate(String(keys.title)).format({
			"week": int(last.week), "month": Fmt.month_name(int(last.month)),
			"quarter": ceili(int(last.month) / 3.0), "year": int(last.year)}),
		"range": TranslationServer.translate(
			Fmt.count_key("SUMMARY_RANGE", last_day - start_day + 1)).format(
			{"from": int(GameState.get_date_dict(start_day).week), "to": int(last.week)}),
		"phase_name": GameState.phase_display_name(int(p.phase)),
		# A company in the red has no runway, whatever its flow.
		"runway_text": UiTokens.net_runway_text(
			0.0 if cash_to < 0 else GameState.runway_months_for(cash_to, int(p.net))),
		"caption": TranslationServer.translate(String(keys.caption)),
		"highlight": TranslationServer.translate(String(keys.quiet)) if highlight.is_empty()
			else TranslationServer.translate(String(highlight.key)).format(highlight.args),
		"footer": TranslationServer.translate(String(keys.footer)),
		"frank_line": TranslationServer.translate(String(p.frank_key)),
	}


static func _team_size() -> int:
	# "Ekip" = founder + payroll employees; the mentor is an advisor, not team.
	return 1 + CharacterRegistry.count_employees()



static func _pick_frank_line(data: Dictionary, monthly: bool) -> String:
	# First matching rule, top-down. Outside monthly mode a month-worded rule is skipped, so a
	# later neutral rule still speaks; "" leaves Frank silent.
	var mrr_delta: int = int(data.mrr.to) - int(data.mrr.from)
	var cash_delta: int = int(data.cash.to) - int(data.cash.from)
	var rules := [
		["MONTH_FRANK_SHUTTER", bool(data.shutter)],
		["MONTH_FRANK_BURNING_BUT_SELLING", cash_delta < 0 and mrr_delta > 0],
		["MONTH_FRANK_SHRINKING", mrr_delta < 0],
		["MONTH_FRANK_GOOD", mrr_delta > 0 and cash_delta > 0
			and int(data.team.to) > int(data.team.from) and int(data.brand.to) > int(data.brand.from)],
		["MONTH_FRANK_ANOTHER", true],
	]
	for rule in rules:
		if rule[1] and (monthly or PERIOD_NEUTRAL_FRANK.has(rule[0])):
			return rule[0]
	return ""
