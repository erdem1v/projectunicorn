class_name TimeModel
extends RefCounted

# One game day (tick) is one week. The settings block below is the only place tempo and workday
# constants live. Durations are week data and are read through ticks(); per-day rates stay day
# data and are applied per tick through per_tick().

# --- Günün süresi ---
const SECONDS_PER_HOUR := [0.0, 2.5, 1.25, 2.5 / 3.0]   # pause / 1× / 2× / 3× [WORKING]
const WEEK_START_HOUR := 8            # a new week starts at 08:00
const WORKDAY_LATEST_END := 24        # the workday ends at 00:00 at the latest
const OVERTIME_HOUR_YIELD := 0.5      # output of each hour past eight [WORKING]
const WEEK_WORK_HOURS := 40           # a meeting costs the founder hours / 40 of the week [WORKING]
const CLOCK_STEP_MIN := 5             # the clock on screen moves in steps of this many game minutes

# --- Units ---
const DAYS_PER_TICK := 7
const DAYS_PER_MONTH := 30            # the economy month
const HOURS_PER_DAY := 24             # hourly ticks per tick
const WEEKS_PER_YEAR := 52            # severance counts whole years of weeks


## Week data → ticks. One to one, but every duration read goes through here.
static func ticks(weeks: int) -> int:
	return weeks


## A per-day rate → its per-tick amount.
static func per_tick(rate_per_day: float) -> float:
	return rate_per_day * DAYS_PER_TICK


## Ticks → calendar days, for formulas that want days.
static func days(t: float) -> float:
	return t * DAYS_PER_TICK


## Ticks → economy months.
static func months(t: float) -> float:
	return t * DAYS_PER_TICK / DAYS_PER_MONTH


## Real seconds one tick takes at a speed with the default workday (the night is skipped).
static func seconds_per_tick(speed: int) -> float:
	return (HRConstants.START_HOUR_DEFAULT + HRConstants.WORK_HOURS_DEFAULT - WEEK_START_HOUR) \
		* float(SECONDS_PER_HOUR[speed])
