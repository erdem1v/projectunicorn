extends Node

# Game clock.
#
# Tempo is REAL SECONDS PER IN-GAME DAY, one entry per speed (SECONDS_PER_DAY). A day is
# ALWAYS HOURS_PER_DAY hourly ticks; only the real-time delivery rate changes, so game-time
# behaviour is identical at every speed.
#
# Day 1 starts at 09:00; later days run 00:00 → 24:00.
#
# Speed 0 flips get_tree().paused: every PAUSABLE node stops while NewsTicker (ALWAYS) keeps
# scrolling.
#
# GameState owns day and current_hour; this node only calls advance_day() / set_current_hour().
# Day rollover order: hour-0 hourly tick → advance_day() → daily tick.
#
# SENKRON KURALI: _in_game_hours ile GameState.current_hour bağımsız sayaçlar. current_hour
# dışarıdan (initialize_run) yazılırsa sync_to_current_hour() ÇAĞRILMALI, yoksa accumulator
# geride kalır ve ilk gün boyunca saatlik tik atılmaz.

# Real seconds one in-game day takes, by speed index (0=pause, 1=1x, 2=2x, 3=3x). The only place
# tempo is expressed. A save's last_running_speed clamps to this array's size on load.
const SECONDS_PER_DAY := [0.0, 12.0, 6.0, 3.0]
const HOURS_PER_DAY := 24
const INITIAL_HOUR := 9

var current_speed: int = 1
var last_running_speed: int = 1                  # last non-zero speed; Space-toggle resumes to it

# Emitted after current_speed actually changes, whoever initiated it (TopBar paints from this).
signal speed_changed(new_speed: int)
var _in_game_hours: float = float(INITIAL_HOUR)  # accumulator within the current day (0-24)

# Hard stop for _process, held by SaveManager.apply_loaded_state for a whole load. The tree is
# not paused during a load, so one frame mid-restore would tick a day against a half-restored
# world. Speed 0 cannot do this job: speed is player state the restore itself overwrites.
var _suspended: bool = false

# Clock holds: a surface that must keep the clock stopped until IT closes, whatever opens and
# closes on top of it (the milestone paper). A hold swallows every speed > 0 request until the
# holder releases it and restores the speed itself.
var _holds: Dictionary = {}                      # reason -> true


func _ready() -> void:
	get_tree().paused = false
	GameState.set_current_hour(INITIAL_HOUR)
	EventBus.speed_change_requested.connect(_on_speed_change_requested)
	# The news feed's "Biz" source captures the non-modal notification channel; wired here so
	# the static system needs no bootstrap.
	EventBus.headline_added.connect(NewsFeedSystem.on_headline_added)


## In-game hours per real second at a speed index, derived from SECONDS_PER_DAY.
## Pause and out-of-range indices = 0.0.
static func hours_per_real_second(idx: int) -> float:
	if idx <= 0 or idx >= SECONDS_PER_DAY.size():
		return 0.0
	return float(HOURS_PER_DAY) / float(SECONDS_PER_DAY[idx])


func _process(delta: float) -> void:
	if _suspended or not GameState.run_active:
		return
	_in_game_hours += hours_per_real_second(current_speed) * delta
	_drain_boundaries()


func _drain_boundaries() -> void:
	# Hour boundaries first (one hour at a time up to 23), then the day rollover, so hour 23
	# fires before the daily tick even when a frame hitch crosses several hours.
	for _i in 100:
		if int(_in_game_hours) > GameState.current_hour and GameState.current_hour < HOURS_PER_DAY - 1:
			var new_hour: int = GameState.current_hour + 1
			GameState.set_current_hour(new_hour)
			_dispatch_hourly_tick(new_hour)
		elif GameState.current_hour >= HOURS_PER_DAY - 1 and _in_game_hours >= float(HOURS_PER_DAY):
			# Hour 0's hourly tick fires here: without it a day would be 23 ticks.
			_in_game_hours -= float(HOURS_PER_DAY)
			GameState.set_current_hour(0)
			_dispatch_hourly_tick(0)
			GameState.advance_day()
			_dispatch_daily_tick()
		else:
			break


func sync_to_current_hour() -> void:
	_in_game_hours = float(GameState.current_hour)


# --- Run boundary + save (SaveManager) ---

func set_suspended(value: bool) -> void:
	_suspended = value


func reset() -> void:
	# Run-boundary reset (SaveManager.reset_all_owners); a restart must not inherit the old
	# run's speed. _suspended is NOT touched: it is a lock held by the caller, and
	# apply_loaded_state takes it before reset_all_owners lands here.
	current_speed = 1
	last_running_speed = 1
	_in_game_hours = float(INITIAL_HOUR)
	_holds.clear()
	get_tree().paused = false


func to_dict() -> Dictionary:
	# The float accumulator is the load-bearing one: current_hour is only its floor, so
	# restoring the hour alone would hand back up to an hour of free build progress.
	return {
		"in_game_hours": _in_game_hours,
		"current_speed": current_speed,
		"last_running_speed": last_running_speed,
	}


func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	# Outside a drain int(_in_game_hours) == current_hour; a save where they disagree is corrupt,
	# and trusting the float would replay or skip part of the day.
	var restored_hours: float = float(d.get("in_game_hours", float(GameState.current_hour)))
	if int(restored_hours) != GameState.current_hour:
		push_warning("[TimeManager] save disagrees with itself: in_game_hours %.3f vs current_hour %d — using the hour"
			% [restored_hours, GameState.current_hour])
		restored_hours = float(GameState.current_hour)
	_in_game_hours = restored_hours
	last_running_speed = clampi(int(d.get("last_running_speed", 1)), 1, SECONDS_PER_DAY.size() - 1)
	# A load always comes back PAUSED: the player may not have seen this company for days.
	# The saved speed survives as last_running_speed for the Space-toggle.
	current_speed = 0
	get_tree().paused = true
	speed_changed.emit(0)


# --- Speed control ---

func _on_speed_change_requested(speed: int) -> void:
	if speed < 0 or speed >= SECONDS_PER_DAY.size():
		push_warning("[TimeManager] Invalid speed requested: %d" % speed)
		return
	# A dead run or a held clock cannot be unpaused; speed-0 requests still pass.
	if speed > 0 and (not GameState.run_active or not _holds.is_empty()):
		return
	current_speed = speed
	if speed > 0:
		last_running_speed = speed
	get_tree().paused = (speed == 0)
	speed_changed.emit(speed)


## Stop the clock and keep it stopped until release_clock(reason). Idempotent per reason.
func hold_clock(reason: String) -> void:
	_holds[reason] = true
	_on_speed_change_requested(0)


## Drop one hold. The caller restores the speed it wants; this does not resume anything.
func release_clock(reason: String) -> void:
	_holds.erase(reason)


func is_clock_held() -> bool:
	return not _holds.is_empty()


## Resume to the last running speed if paused; a running speed is left alone.
func resume_if_paused() -> void:
	if current_speed == 0:
		_on_speed_change_requested(last_running_speed)


# --- Daily tick dispatch ---

func _dispatch_daily_tick() -> void:
	# Order matters: each slot reads state settled by the ones before it.
	if not GameState.run_active:
		return  # direct calls from the smoke harness
	# 1 · Product. Destek önce: günlük memnuniyet zararını o uygular ve altyapı aşımı o
	# zararın tavanına (§8.3) girer. §19 kenar sinyalleri en sonda, bugünün durumundan okunur.
	ProductSystem.daily_tick()
	SupportSystem.daily_tick()
	InfraSystem.daily_tick()
	ProductRead.emit_edges()
	# 2 · R&D
	RnDSystem.daily_tick()
	EventBus.research_progress_changed.emit()
	# 3 · HR, 4 · Sales (aggregates MRR), rivals, 5 · Finance (applies the day's net flow).
	HRSystem.daily_tick()
	SalesSystem.daily_tick()
	RivalRegistry.advance_all()
	FinanceSystem.daily_tick()
	# Gate latches run after Finance (MRR and brand must be settled) and BEFORE the event slot:
	# `funding.gate_traction` / `funding.seed_door` read the ratchets set here, and evaluated
	# after the engine the card would arrive the morning after its own condition.
	PhaseGateSystem.daily_tick()
	SeedRoundSystem.daily_tick()
	# 6 · Events: cash triggers see the day's net flow applied.
	EventGate.daily_tick()
	# 7 · News feed composes the day's lines from settled sales and rival state.
	NewsFeedSystem.daily_tick()
	# 8 · VC clocks, BEFORE Endings so the cascade-defer inputs (active_sheets /
	# pending_meeting) are fresh when EndingsSystem reads them.
	VCPitchSystem.daily_tick()
	# 9 · Terminal scan; can end the run.
	EndingsSystem.daily_tick()
	# 10 · Month summary, after Endings: if a terminal fired today the ending wins.
	MonthSummarySystem.daily_tick()
	# The autosave boundary: the only moment every system has finished the day.
	EventBus.day_tick_completed.emit(GameState.day)


# --- Hourly tick dispatch ---

func _dispatch_hourly_tick(hour: int) -> void:
	if not GameState.run_active:
		return
	# Build quality/bugs and support flow (§8, §9) move hourly so a mid-day assignment
	# shows the same day.
	ProductSystem.hourly_tick(hour)
	SupportSystem.hourly_tick(hour)
	# B2C audience and MRR derive every in-game hour.
	SalesSystem.hourly_tick(hour)
	# Ambient events evaluate hourly so their allowed_hours windows are honest.
	EventGate.hourly_tick(hour)
