extends Node

# Game clock.
#
# One game day (tick) is one week (TimeModel). Tempo is REAL SECONDS PER IN-GAME HOUR, one entry
# per speed (TimeModel.SECONDS_PER_HOUR). A day is ALWAYS 24 hourly ticks; only the real-time
# delivery rate changes, so game-time behaviour is identical at every speed.
#
# The week starts at WEEK_START_HOUR. The night (from the workday end to WEEK_START_HOUR) is
# derived every frame from game state, never latched: once the office is empty the rest of it is
# simulated in one batch, so its hours still tick and only their real time is skipped.
#
# Speed 0 flips get_tree().paused: every PAUSABLE node stops while NewsTicker (ALWAYS) keeps
# scrolling. freeze_clock only stops accumulation and leaves the tree and the speed alone.
#
# GameState owns day and current_hour; this node writes the clock through advance_day() /
# set_current_hour() / start_work_week().
# Day rollover order: hour-0 hourly tick → advance_day() → daily tick.
#
# SENKRON KURALI: _in_game_hours ile GameState.current_hour bağımsız sayaçlar. Üretim kodunda
# saati ileri taşıyan iki dış kapı var: advance_hours(n) (toplantı kapanışı, smoke, probe) ve
# skip_night() (gece). İkisi de _run_batch → _step_hour'dan geçer ve her adım akümülatörü saate
# eşitler, çünkü 00:00 autosave'i adımın içinde yazılır.
# current_hour başka bir yoldan yazılırsa (initialize_run) sync_to_current_hour() ÇAĞRILMALI,
# yoksa akümülatör geride kalır ve saatlik tik atılmaz.

const _NIGHT := "night"

var current_speed: int = 1
var last_running_speed: int = 1                  # last non-zero speed; Space-toggle resumes to it

# Emitted after current_speed actually changes, whoever initiated it (TopBar paints from this).
signal speed_changed(new_speed: int)
var _in_game_hours: float = float(TimeModel.WEEK_START_HOUR)   # accumulator within the day (0-24)

# Hard stop for _process, held by SaveManager.apply_loaded_state for a whole load. The tree is
# not paused during a load, so one frame mid-restore would tick a day against a half-restored
# world. Speed 0 cannot do this job: speed is player state the restore itself overwrites.
var _suspended: bool = false

# Clock holds: a surface that must keep the clock stopped until IT closes, whatever opens and
# closes on top of it (the milestone paper). A hold swallows every speed > 0 request until the
# holder releases it and restores the speed itself.
var _holds: Dictionary = {}                      # reason -> true

# Freezes stop accumulation only: the office keeps walking under them (the founder's trip out,
# the night walk-out), which a paused tree would not.
var _freezes: Dictionary = {}                    # reason -> true

# The office view's "everyone is out" predicate and how long the night waits for it. Counted
# from _process delta, so a pause holds the wait and the walk together.
var _night_gate: Callable = Callable()
var _night_max_wait_s: float = 0.0
var _night_wait_s: float = 0.0

var _advancing: bool = false                     # inside _step_hour
var _batching: bool = false                      # inside advance_hours / skip_night
var _batch_meeting: bool = false                 # the batch is a meeting's skipped hours


func _ready() -> void:
	get_tree().paused = false
	GameState.set_current_hour(TimeModel.WEEK_START_HOUR)
	EventBus.speed_change_requested.connect(_on_speed_change_requested)
	# The news feed's "Biz" source captures the non-modal notification channel; wired here so
	# the static system needs no bootstrap.
	EventBus.headline_added.connect(NewsFeedSystem.on_headline_added)


## In-game hours per real second at a speed index, derived from TimeModel.SECONDS_PER_HOUR.
## Pause and out-of-range indices = 0.0.
static func hours_per_real_second(idx: int) -> float:
	if idx <= 0 or idx >= TimeModel.SECONDS_PER_HOUR.size():
		return 0.0
	return 1.0 / float(TimeModel.SECONDS_PER_HOUR[idx])


func _process(delta: float) -> void:
	_advance_real(delta)


func _advance_real(delta: float) -> void:
	if _suspended or not GameState.run_active:
		return
	# The night is read every frame, not latched at an hour boundary: a save loaded at night and
	# the 00:00 autosave land here too.
	if not is_night():
		if _freezes.has(_NIGHT):
			_end_night()                         # the day was lengthened during the walk-out
		if not _freezes.is_empty():
			return
		_in_game_hours += hours_per_real_second(current_speed) * delta
		_drain_boundaries()
		if not is_night():
			return
		delta = 0.0                              # the night began inside this frame's hours
	freeze_clock(_NIGHT)
	_night_wait_s += delta
	if _night_gate.is_valid() and not bool(_night_gate.call()) and _night_wait_s < _night_max_wait_s:
		return
	# A surface that paused inside this frame's steps keeps the night behind it.
	if current_speed == 0:
		return
	# is_night() was read in this frame, so the player cannot have lengthened the day since.
	skip_night()


func _drain_boundaries() -> void:
	# One hour at a time. A step that lands on the night drops the rest of the frame's hours: a
	# hitch cannot carry the clock past the workday end. The rollover is never stepped here: 00:00
	# is always night, so a workday ending at 24:00 hands hour 23 → 0 to skip_night's batch, where
	# the daily tick's cards wait for 08:00.
	while _in_game_hours >= float(GameState.current_hour + 1) and _can_step() \
			and GameState.current_hour < TimeModel.HOURS_PER_DAY - 1:
		var carry: float = _in_game_hours - float(GameState.current_hour + 1)
		_step_hour(0.0)
		if is_night():
			return
		_in_game_hours += carry


## One in-game hour: the hour and its hourly tick, at 00:00 the rollover and the daily tick. The
## accumulator is set to the new hour (plus the kept fraction) before the dispatch, so a save
## written inside the step stores a clock that agrees with itself.
func _step_hour(frac: float) -> void:
	assert(not _advancing, "[TimeManager] the clock was advanced from inside an hour step")
	_advancing = true
	var hour: int = (GameState.current_hour + 1) % TimeModel.HOURS_PER_DAY
	_in_game_hours = float(hour) + frac
	GameState.set_current_hour(hour)
	if hour == TimeModel.WEEK_START_HOUR:
		GameState.start_work_week()
	_dispatch_hourly_tick(hour)
	if hour == 0:
		GameState.advance_day()
		_dispatch_daily_tick()
	_advancing = false


## Every step stops when the run ended (the ending paper) or a hold was taken (the milestone
## paper). The night is derived, so an interrupted skip resumes once the hold is released.
func _can_step() -> bool:
	return GameState.run_active and _holds.is_empty()


## Simulates n hours through the real hourly path; the fraction of the current hour is kept
## (10:45 + 2 = 12:45). The skip stops before 00:00 so the rollover and its daily tick never run
## inside a meeting batch (founder_output_factor would reach into the next week). A meeting's hours
## cost the founder the weekly share through founder_output_factor(); the sitting has released the
## founder before calling, so nothing zeroes them.
func advance_hours(n: int, meeting: bool = false) -> void:
	if meeting:
		var last_hour: int = mini(WorkHoursSystem.end_hour_for(CharacterRegistry.get_founder()), TimeModel.HOURS_PER_DAY - 1)
		n = mini(n, maxi(0, last_hour - GameState.current_hour))
		GameState.add_founder_meeting_hours(n)
	_run_batch(n, fposmod(_in_game_hours, 1.0), meeting)


## Skips the night to the absolute target, the next WEEK_START_HOUR. Its hours, the 00:00
## rollover, the daily tick and its autosave run inside. night_skipped only on arrival.
func skip_night() -> void:
	var steps: int = posmod(TimeModel.WEEK_START_HOUR - GameState.current_hour, TimeModel.HOURS_PER_DAY)
	if steps == 0:
		return
	_run_batch(steps, 0.0, false)
	if GameState.current_hour == TimeModel.WEEK_START_HOUR:
		_end_night()
		EventBus.night_skipped.emit()


func _run_batch(steps: int, frac: float, meeting: bool) -> void:
	assert(not _batching, "[TimeManager] a batch was started from inside another batch")
	_batching = true
	_batch_meeting = meeting
	for _i in steps:
		if not _can_step():
			break
		_step_hour(frac)
	_batching = false
	_batch_meeting = false
	EventBus.clock_batch_ended.emit()


func is_batching() -> bool:
	return _batching


## The accumulator term is the one moment the hour cannot show: a workday ending at 24:00 has
## reached its end while the clock still reads 23.
func is_night() -> bool:
	return GameState.current_hour >= WorkHoursSystem.workday_end() \
		or GameState.current_hour < TimeModel.WEEK_START_HOUR \
		or _in_game_hours >= float(TimeModel.HOURS_PER_DAY)


## The founder's output share during a batch: a meeting's skipped hour leaves 1 − 24/40 of it,
## so the whole meeting costs hours / WEEK_WORK_HOURS of the week.
func founder_output_factor() -> float:
	if _batch_meeting:
		return 1.0 - float(TimeModel.HOURS_PER_DAY) / float(TimeModel.WEEK_WORK_HOURS)
	return 1.0


func _end_night() -> void:
	_night_wait_s = 0.0
	thaw_clock(_NIGHT)


func sync_to_current_hour() -> void:
	_in_game_hours = float(GameState.current_hour)


## Minutes past midnight with the hour's progress. The accumulator is the hour plus its fraction
## (SENKRON KURALI); at a 24:00 end it holds at 24 while the night waits, and never wraps back.
func day_minute() -> float:
	return minf(_in_game_hours, float(TimeModel.HOURS_PER_DAY)) * 60.0


# --- Freezes and the night gate ---

func freeze_clock(reason: String) -> void:
	_freezes[reason] = true


func thaw_clock(reason: String) -> void:
	_freezes.erase(reason)


## The office view registers its "office is empty" predicate; the night waits for it at most
## max_wait_s. With no gate (headless, smoke, probe) the night is skipped at once.
func register_night_gate(is_empty: Callable, max_wait_s: float) -> void:
	_night_gate = is_empty
	_night_max_wait_s = max_wait_s


func unregister_night_gate() -> void:
	_night_gate = Callable()


# --- Run boundary + save (SaveManager) ---

func set_suspended(value: bool) -> void:
	_suspended = value


func reset() -> void:
	# Run-boundary reset (SaveManager.reset_all_owners); a restart must not inherit the old
	# run's speed. _suspended is NOT touched: it is a lock held by the caller, and
	# apply_loaded_state takes it before reset_all_owners lands here.
	current_speed = 1
	last_running_speed = 1
	_in_game_hours = float(TimeModel.WEEK_START_HOUR)
	_holds.clear()
	_freezes.clear()
	_night_wait_s = 0.0
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
	# Outside a step int(_in_game_hours) == current_hour, except the moment a 24:00 workday has
	# ended (24 against hour 23). Any other disagreement is corrupt, and trusting the float would
	# replay or skip part of the day.
	var restored_hours: float = minf(float(d.get("in_game_hours", float(GameState.current_hour))),
		float(TimeModel.HOURS_PER_DAY))
	if mini(int(restored_hours), TimeModel.HOURS_PER_DAY - 1) != GameState.current_hour:
		push_warning("[TimeManager] save disagrees with itself: in_game_hours %.3f vs current_hour %d — using the hour"
			% [restored_hours, GameState.current_hour])
		restored_hours = float(GameState.current_hour)
	_in_game_hours = restored_hours
	last_running_speed = clampi(int(d.get("last_running_speed", 1)), 1, TimeModel.SECONDS_PER_HOUR.size() - 1)
	# A load always comes back PAUSED: the player may not have seen this company for days.
	# The saved speed survives as last_running_speed for the Space-toggle.
	current_speed = 0
	get_tree().paused = true
	speed_changed.emit(0)


# --- Speed control ---

func _on_speed_change_requested(speed: int) -> void:
	if speed < 0 or speed >= TimeModel.SECONDS_PER_HOUR.size():
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
	# 0 · Period summary: the month closes before this week's flow is written to it.
	SummarySystem.begin_day()
	# 1 · Product. Destek önce: günlük memnuniyet zararını o uygular ve altyapı aşımı o
	# zararın tavanına (§8.3) girer. §19 kenar sinyalleri en sonda, bugünün durumundan okunur.
	ProductSystem.daily_tick()
	SupportSystem.daily_tick()
	InfraSystem.daily_tick()
	ProductRead.emit_edges()
	# 2 · R&D
	RnDSystem.daily_tick()
	EventBus.research_progress_changed.emit()
	# 3 · HR, 4 · Sales (aggregates MRR), rivals, 5 · Finance (applies the week's net flow).
	HRSystem.daily_tick()
	SalesSystem.daily_tick()
	RivalRegistry.advance_all()
	FinanceSystem.daily_tick()
	# A move lands before the event slot, so a card reading office.current sees today's office.
	OfficeSystem.daily_tick()
	# Gate latches run after Finance (MRR and brand must be settled) and BEFORE the event slot:
	# `funding.gate_traction` / `funding.seed_door` read the ratchets set here, and evaluated
	# after the engine the card would arrive the morning after its own condition.
	PhaseGateSystem.daily_tick()
	SeedRoundSystem.daily_tick()
	# 6 · Events: cash triggers see the week's net flow applied.
	EventGate.daily_tick()
	# 7 · News feed composes the day's lines from settled sales and rival state.
	NewsFeedSystem.daily_tick()
	# 8 · VC clocks, BEFORE Endings so the cascade-defer inputs (active_sheets /
	# pending_meeting) are fresh when EndingsSystem reads them.
	VCPitchSystem.daily_tick()
	# 9 · Terminal scan; can end the run.
	EndingsSystem.daily_tick()
	# 10 · Summary, after Endings: if a terminal fired today the ending wins.
	SummarySystem.daily_tick()
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
