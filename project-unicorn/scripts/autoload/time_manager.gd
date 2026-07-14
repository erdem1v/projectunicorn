extends Node

# Game clock per TECH_SPEC §6.1, §8.1, §8.2.
#
# Time rule (§8.1):
#   At 1x speed, one real second equals one in-game hour.
#   One in-game day = 24 in-game hours = 24 real seconds at 1x.
#   Speed multipliers: pause=0, 1x=1, 2x=2, 4x=4.
#
# Initial state (TECH_SPEC §20 Decision Log entry 2026-05-15):
#   Day 1 starts at 09:00 (business-day-start). First day runs 09:00 → 24:00 =
#   15 in-game hours = 15 real seconds at 1x. Subsequent days start at 00:00
#   and run a full 24 in-game hours per cycle.
#
# Pause policy:
#   speed = 0 flips get_tree().paused = true. Pauses every PAUSABLE node
#   (TimeManager + future Finance/Sales/HR) while NewsTicker (ALWAYS) keeps
#   scrolling — game systems stop, ambient chrome continues.
#
# Single source of truth:
#   GameState owns day and current_hour. TimeManager only calls
#   GameState.advance_day() / GameState.set_current_hour(h). No local copy.
#
# Tick dispatch (§8.2):
#   Hourly tick fires on every hour boundary (light, 2 slots) — rollover'ın
#   kendisi de saat-0 tiki atar, gün = TAM 24 saatlik tik (eskiden 23'tü —
#   saat-0 tiki sessizce düşüyordu; build'ler günde 1 saat kaybediyordu).
#   Daily tick fires on every day boundary (ordered slots; endings scan is
#   slot 9, month summary slot 10 — see _dispatch_daily_tick).
#   Day rollover order: hour-0 hourly tick → daily tick.
#
# SENKRON KURALI: _in_game_hours (float accumulator) ile GameState.current_hour
# bağımsız sayaçlar — current_hour dışarıdan (initialize_run) yazılırsa
# sync_to_current_hour() ÇAĞRILMALI, yoksa accumulator geride kalır ve ilk gün
# boyunca Case-1 hiç tetiklenmez ("ilk gün ölü" bug'ı).

const SPEED_MULTIPLIERS := [0.0, 1.0, 2.0, 4.0]  # idx: 0=pause, 1=1x, 2=2x, 3=4x
const HOURS_PER_DAY := 24
const INITIAL_HOUR := 9                          # Game starts at 09:00 on Day 1

var current_speed: int = 1                       # Default 1x — TopBar visually active at 1x
var last_running_speed: int = 1                  # Last non-zero speed; Space-toggle (GameShell) resumes to this

# Emitted after current_speed actually changes. UI (TopBar) subscribes here
# rather than mirroring EventBus.speed_change_requested directly, so visuals
# stay in sync no matter who initiated the change (player click, post-event
# restore via main.gd._pre_event_speed, build commit, etc).
signal speed_changed(new_speed: int)
var _in_game_hours: float = float(INITIAL_HOUR)  # Accumulator within current day (0-24)

# Debug-only: track real-time delta between daily ticks for tempo verification
var _last_tick_msec: int = 0


func _ready() -> void:
	get_tree().paused = false
	# Sync GameState with our initial accumulator so TopBar paints "Day 1 · 09:00".
	GameState.set_current_hour(INITIAL_HOUR)
	EventBus.speed_change_requested.connect(_on_speed_change_requested)


func _process(delta: float) -> void:
	if not GameState.run_active:
		# Terminal reached (ENDGAME_DESIGN.md §7.3): world stops. No hours accrue,
		# no MRR behind the ending screen.
		return
	var multiplier: float = SPEED_MULTIPLIERS[current_speed]
	if multiplier == 0.0:
		# Defensive: get_tree().paused already prevents this _process from
		# running when speed=0. Guard kept for debug paths that set speed
		# without pausing the tree.
		return

	_in_game_hours += multiplier * delta
	_drain_boundaries()


# --- Boundary drain (hour & day) ---

func _drain_boundaries() -> void:
	# Single-loop boundary processor. Order: hour boundaries first (Case 1
	# advances hour-by-hour up to 23), then day rollover (Case 2). This
	# guarantees the "hour 23 fires before daily tick" rule even under a
	# frame hitch that crosses multiple hours in one frame.
	var safety: int = 0
	while safety < 100:
		safety += 1

		# Case 1: hour boundary within current day (advance one hour at a time)
		if int(_in_game_hours) > GameState.current_hour and GameState.current_hour < HOURS_PER_DAY - 1:
			var new_hour: int = GameState.current_hour + 1
			GameState.set_current_hour(new_hour)
			_dispatch_hourly_tick(new_hour)
			continue

		# Case 2: hour=23 AND accumulator passed 24 → day rollover.
		# Saat-0'ın hourly tiki BURADA atılır (Case 1 yalnız 1..23 arasını atar;
		# bu tik olmadan gün 23 tikte kalıyordu — kronik %4 build yavaşlaması).
		if GameState.current_hour >= HOURS_PER_DAY - 1 and _in_game_hours >= float(HOURS_PER_DAY):
			_in_game_hours -= float(HOURS_PER_DAY)
			GameState.set_current_hour(0)
			_dispatch_hourly_tick(0)
			GameState.advance_day()
			_dispatch_daily_tick()
			continue

		# No more boundaries this frame
		break


func sync_to_current_hour() -> void:
	# GameState.current_hour dışarıdan yazıldığında (initialize_run / debug skip)
	# accumulator'ı aynı saate kilitler — ilk günün saatlik tikleri ilk saatten
	# itibaren akar ("ilk gün ölü" bug fix'i).
	_in_game_hours = float(GameState.current_hour)


# --- Speed control ---

func _on_speed_change_requested(speed: int) -> void:
	if speed < 0 or speed >= SPEED_MULTIPLIERS.size():
		push_warning("[TimeManager] Invalid speed requested: %d" % speed)
		return
	if speed > 0 and not GameState.run_active:
		# Dead run cannot be unpaused (§7.3) — blocks Space-toggle, TopBar buttons,
		# and main.gd's post-modal speed restore. Speed-0 requests still pass so
		# the terminal path can freeze the clock.
		return
	current_speed = speed
	if speed > 0:
		last_running_speed = speed   # remember for Space-toggle resume
	get_tree().paused = (speed == 0)
	speed_changed.emit(speed)


func resume_if_paused() -> void:
	# Aksiyon butonları (build commit, sprint start): pause'daysa son koşan hıza
	# döner; koşuyorsa hıza DOKUNMAZ (speed-hijack fix — mevcut 2x/4x korunur).
	# Ölü run'da _on_speed_change_requested zaten yutar (§7.3).
	if current_speed == 0:
		_on_speed_change_requested(last_running_speed)


# --- Daily tick dispatch (TECH_SPEC §8.2) ---

func _dispatch_daily_tick() -> void:
	# Order matters: each system reads state set by the previous ones.
	# Finance after Sales (revenue depends on closed deals); Events after
	# most systems (trigger conditions read current state); Endings last
	# because it can terminate the run.
	if not GameState.run_active:
		return  # belt-and-braces for direct calls (debug / smoke harness)
	_tick_product()
	_tick_rnd()
	_tick_hr()
	_tick_sales()
	_tick_rivals()
	_tick_finance()
	_tick_events()
	_tick_industry_events()
	_tick_phase_check()
	_tick_pitch()
	_tick_endings_check()
	_tick_month_summary()

	if OS.is_debug_build():
		var now: int = Time.get_ticks_msec()
		var delta_ms: int = (now - _last_tick_msec) if _last_tick_msec > 0 else 0
		_last_tick_msec = now
		print("[TimeManager] Daily tick — Day %d (Δ %d ms)" % [GameState.day, delta_ms])


# --- Hourly tick dispatch (lighter; for time-of-day events + schedule) ---

func _dispatch_hourly_tick(hour: int) -> void:
	# Saatlik granularity event-driven olduğu için daily'ye göre az slot.
	# Sistemler geldikçe slot doldurulur, dispatch yapısı dokunulmaz kalır.
	if not GameState.run_active:
		return  # terminal reached — no hourly economy behind the ending screen
	_tick_product_hourly(hour)
	_tick_sales_hourly(hour)
	_tick_hourly_events(hour)
	_tick_hourly_schedule(hour)


# --- Daily tick slots (9, ordered per §8.2) ---

func _tick_product() -> void:
	# Pure-logic system filling slot 1. Manages the active product build's
	# countdown, quality, and ship-moment trigger. Ship moment is narrative-only
	# (no economic delta) per the narrative-strategy design principle.
	# See scripts/systems/product_system.gd.
	ProductSystem.daily_tick()

func _tick_rnd() -> void:
	pass  # TODO when RnDSystem comes online: RnDSystem.daily_tick()

func _tick_hr() -> void:
	# Pure-logic system filling slot 3. Iterates employees, applies baseline
	# morale drift. Salary→Finance flows via Finance pull at slot 5.
	# See scripts/systems/hr_system.gd.
	HRSystem.daily_tick()

func _tick_sales() -> void:
	# Pure-logic system filling slot 4. Aggregates MRR across active customers
	# and pushes to GameState.mrr (TopBar listens; Finance pulls at slot 5).
	# See scripts/systems/sales_system.gd.
	SalesSystem.daily_tick()

func _tick_rivals() -> void:
	# Product Lifecycle Part 1: rival products evolve slowly (startups fast,
	# established slow, giants static) so a stalled player gets passed. Daily, not
	# hourly, to avoid UI churn. See scripts/autoload/rival_registry.gd.
	RivalRegistry.advance_all()

func _tick_finance() -> void:
	# Pure-logic system filling slot 5. Computes daily revenue + burn,
	# applies net flow to GameState.cash, recalculates runway.
	# See scripts/systems/finance_system.gd.
	FinanceSystem.daily_tick()

func _tick_events() -> void:
	# Slot 6: reactive event eligibility check + queue management.
	# Runs after Finance so cash_below/cash_above triggers see the day's
	# net flow applied. See scripts/autoload/event_manager.gd.
	EventManager.daily_tick()

func _tick_industry_events() -> void:
	pass  # TODO when IndustryEventScheduler comes online

func _tick_phase_check() -> void:
	# Slot 8: gate evaluator per docs/ENDGAME_DESIGN.md §2. Opens gates (latch +
	# Frank scene); the phase itself only changes via GameState.advance_phase().
	PhaseGateSystem.daily_tick()

func _tick_pitch() -> void:
	# Slot 8b (Spec 4): VC sheet clocks, callbacks, delayed delivery, meeting-day
	# prompt. BEFORE Endings so the cascade-defer inputs (active_sheets/pending_meeting)
	# are fresh when EndingsSystem._check_vc_cascade reads them (ledger 17).
	VCPitchSystem.daily_tick()

func _tick_endings_check() -> void:
	# Slot 9: terminal scan per docs/ENDGAME_DESIGN.md §3-4. Can end the run
	# (run_active = false halts this loop from the next frame on).
	EndingsSystem.daily_tick()

func _tick_month_summary() -> void:
	# Slot 10: Month-End Summary (Spec 3 / ENDGAME_DESIGN.md §1.1). AFTER the
	# endings scan on purpose — if a terminal fired today, run_active is false
	# and the summary is suppressed (the ending wins).
	MonthSummarySystem.daily_tick()


# --- Hourly tick slots (3, lighter) ---

func _tick_product_hourly(hour: int) -> void:
	# Product Lifecycle Part 1: the active build's quality accrues hourly (from 0,
	# smooth) + development bugs accumulate hourly. Phase counters stay daily.
	# See scripts/systems/product_system.gd.
	ProductSystem.hourly_tick(hour)

func _tick_sales_hourly(hour: int) -> void:
	# Economy Model v2: B2C audience flows (bidirectional) and MRR derives every
	# in-game hour, so the economy reads as live. See scripts/systems/sales_system.gd.
	SalesSystem.hourly_tick(hour)

func _tick_hourly_events(hour: int) -> void:
	# Ambient (random-trigger) reactive events evaluate hourly so time-of-day
	# windows (allowed_hours in the event JSON) are mechanically honest — a
	# 02:17 bug event fires at night, not at the midnight daily tick.
	# Deterministic beat events stay on the daily path (slot 6, daily_tick).
	# See scripts/autoload/event_manager.gd (D-A).
	EventManager.hourly_tick(hour)

func _tick_hourly_schedule(hour: int) -> void:
	pass  # TODO when CharacterRegistry exposes schedule queries
	# (e.g. mentor available 09:00-18:00, sales reps idle after 18:00)
