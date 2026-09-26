extends Node

# Game clock.
#
# Time rule (ladder retuned 2026-07-29):
#   Tempo is expressed as REAL SECONDS PER IN-GAME DAY, one entry per speed —
#   1x=12s, 2x=6s, 3x=3s. See SECONDS_PER_DAY below (the single home). The 4x rung
#   (1.5 s/day) was removed 2026-08-19: the ladder is 1×/2×/3×.
#   A day is ALWAYS HOURS_PER_DAY hourly ticks; only the real-time rate of
#   delivery changes, so game-time behaviour is identical at every speed.
#   (The old rule was "1 real second = 1 in-game hour" → 24s/day at 1x.)
#
# Initial state:
#   Day 1 starts at 09:00 (business-day-start). First day runs 09:00 → 24:00 =
#   15 in-game hours = 7.5 real seconds at 1x. Subsequent days start at 00:00
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
# Tick dispatch:
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

# THE tempo home. Real seconds one in-game day takes, by speed index.
# idx: 0=pause, 1=1x, 2=2x, 3=3x
# Retuning the pace = editing this array and nothing else. Values are WORKING
# (numbers are tuned last); the ladder shape is the locked part.
# The 4x rung (1.5 s/day) is gone — the canon ladder
# is 1×/2×/3×. A save that stored last_running_speed 4 clamps to 3 on load (from_dict reads
# the array's size), KEY_4 is inert in game_shell, TopBar lost Speed4Btn.
const SECONDS_PER_DAY := [0.0, 12.0, 6.0, 3.0]
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

# Hard stop for _process, independent of speed and of get_tree().paused. Held by
# SaveManager.apply_loaded_state for the duration of a load.
#
# WHY IT HAS TO EXIST: a load runs across several statements — reset every owner, re-init
# GameState, restore the registries, restore the systems. The tree is NOT paused during
# that (main.gd has just freed the shell, so nothing is holding a pause), which means this
# node's _process is still live and a single frame landing mid-restore would tick a day
# against a half-restored world: employees reset but customers not yet seated, a build
# already back but the clock still on the old run's hour. Speed-0 would not be enough —
# it is player-facing state that the restore itself then overwrites.
var _suspended: bool = false

# CLOCK HOLDS — a surface that must keep the clock stopped until IT closes, whatever else
# opens and closes on top of it. The milestone paper is the case: an event card, the month
# summary or a settings panel can close while it is up, and each of those restores the
# speed it saw before it opened. A hold swallows every speed > 0 request (the same rule a
# dead run gets below) until the holder releases it and restores the speed itself.
var _holds: Dictionary = {}                      # reason -> true


func _ready() -> void:
	get_tree().paused = false
	# Sync GameState with our initial accumulator so TopBar paints "Day 1 · 09:00".
	GameState.set_current_hour(INITIAL_HOUR)
	EventBus.speed_change_requested.connect(_on_speed_change_requested)
	# News feed "Biz" source: the feed passively captures the existing non-modal
	# notification channel (deal closes, HR notices; future milestone emitters land
	# here for free). Wired at the tick owner so the static system needs no bootstrap.
	EventBus.headline_added.connect(NewsFeedSystem.on_headline_added)


static func hours_per_real_second(idx: int) -> float:
	# In-game hours accrued per real second at a given speed. DERIVED from the
	# ladder, never stored separately — that is what keeps SECONDS_PER_DAY the
	# only place tempo is expressed. Pause (and any out-of-range index) = 0.0.
	# NOT to be confused with the product build's own speed multipliers or
	# ProductSystem.capacity_speed_factor() — those are build throughput, not clock rate.
	if idx <= 0 or idx >= SECONDS_PER_DAY.size():
		return 0.0
	return float(HOURS_PER_DAY) / float(SECONDS_PER_DAY[idx])


func _process(delta: float) -> void:
	if _suspended:
		return  # a load is rebuilding the world; see _suspended
	if not GameState.run_active:
		# Terminal reached: world stops. No hours accrue,
		# no MRR behind the ending screen.
		return
	var multiplier: float = hours_per_real_second(current_speed)
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
	# GameState.current_hour dışarıdan yazıldığında (initialize_run / debug skip / save
	# restore) accumulator'ı aynı saate kilitler — ilk günün saatlik tikleri ilk saatten
	# itibaren akar ("ilk gün ölü" bug fix'i).
	_in_game_hours = float(GameState.current_hour)


# --- Run boundary + save (SaveManager) ---

func set_suspended(value: bool) -> void:
	# See _suspended. Deliberately NOT routed through the speed system: speed is player
	# state that a load restores, and borrowing it as a load lock would mean the restore
	# has to guess what to hand back.
	_suspended = value


func reset() -> void:
	# Run-boundary reset (SaveManager.reset_all_owners). TimeManager had no reset, so an
	# in-place restart inherited the previous run's clock: _in_game_hours frozen wherever
	# the old company stopped (initialize_run's sync_to_current_hour repaired that one by
	# luck, not by contract) and — the part nothing repaired — the SPEED, so a new run
	# opened at whatever 3x the last one was left running at.
	current_speed = 1
	last_running_speed = 1
	_in_game_hours = float(INITIAL_HOUR)
	_last_tick_msec = 0
	_holds.clear()
	get_tree().paused = false
	# _suspended IS DELIBERATELY NOT TOUCHED. It is a lock held by the CALLER, not a piece of
	# clock state: SaveManager.apply_loaded_state takes it and then calls reset_all_owners(),
	# which lands here — so clearing it would hand the clock back mid-rebuild, which is the
	# exact frame this lock exists to prevent. On the standalone restart path nobody has
	# taken it, so it is already false and there is nothing to clear.


func to_dict() -> Dictionary:
	# The float accumulator is the load-bearing one: GameState.current_hour is only its
	# integer floor, so restoring the hour alone would round the day's position down and
	# hand the player back up to an hour of free build progress on every load.
	return {
		"in_game_hours": _in_game_hours,
		"current_speed": current_speed,
		"last_running_speed": last_running_speed,
	}


func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	# The accumulator is authoritative over GameState.current_hour, which is only its integer
	# floor — but only while the two AGREE. _drain_boundaries maintains the invariant
	# int(_in_game_hours) == GameState.current_hour outside a drain, so a save where they
	# disagree is a corrupt or hand-edited file, and trusting the float there would either
	# replay hours already lived or skip a stretch of the day. Fall back to the integer hour
	# and say so, rather than restoring a clock that lies.
	var restored_hours: float = float(d.get("in_game_hours", float(GameState.current_hour)))
	if int(restored_hours) != GameState.current_hour:
		push_warning("[TimeManager] save disagrees with itself: in_game_hours %.3f vs current_hour %d — using the hour"
			% [restored_hours, GameState.current_hour])
		restored_hours = float(GameState.current_hour)
	_in_game_hours = restored_hours
	last_running_speed = clampi(int(d.get("last_running_speed", 1)), 1, SECONDS_PER_DAY.size() - 1)
	# The clock comes back PAUSED regardless of the speed the save was written at, and that
	# is a decision rather than an omission: a load drops the player into a company they may
	# not have seen for days, and resuming at 3x would spend that company's next day before
	# they had read the top bar. The saved speed survives as last_running_speed, so the
	# Space-toggle (or any TopBar click) resumes exactly where they left off.
	current_speed = 0
	get_tree().paused = true
	speed_changed.emit(0)


# --- Speed control ---

func _on_speed_change_requested(speed: int) -> void:
	if speed < 0 or speed >= SECONDS_PER_DAY.size():
		push_warning("[TimeManager] Invalid speed requested: %d" % speed)
		return
	if speed > 0 and not GameState.run_active:
		# Dead run cannot be unpaused — blocks Space-toggle, TopBar buttons,
		# and main.gd's post-modal speed restore. Speed-0 requests still pass so
		# the terminal path can freeze the clock.
		return
	if speed > 0 and not _holds.is_empty():
		return                  # a hold is up (see _holds); its owner restores the speed
	current_speed = speed
	if speed > 0:
		last_running_speed = speed   # remember for Space-toggle resume
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


func resume_if_paused() -> void:
	# Aksiyon butonları (build commit, sprint start): pause'daysa son koşan hıza
	# döner; koşuyorsa hıza DOKUNMAZ (speed-hijack fix — mevcut 2x/3x korunur).
	# Ölü run'da _on_speed_change_requested zaten yutar.
	if current_speed == 0:
		_on_speed_change_requested(last_running_speed)


# --- Daily tick dispatch ---

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
	_tick_phase_check()
	_tick_events()
	_tick_industry_events()
	_tick_pitch()
	_tick_endings_check()
	_tick_month_summary()

	if OS.is_debug_build():
		var now: int = Time.get_ticks_msec()
		var delta_ms: int = (now - _last_tick_msec) if _last_tick_msec > 0 else 0
		_last_tick_msec = now
		print("[TimeManager] Daily tick — Day %d (Δ %d ms)" % [GameState.day, delta_ms])

	# THE LAST LINE OF THE DAY, and it has to be. This is the autosave boundary, and the
	# only moment at which "the day is finished" is true for every system at once.
	# NOT EventBus.day_advanced, which is the obvious-looking choice and is wrong: that one
	# fires inside GameState.advance_day(), i.e. BEFORE the twelve slots above have run — a
	# save taken there would record the new day number against yesterday's product, finance,
	# sales and event state. (HRSystem.daily_tick's closing hr_day_processed emit documents
	# the same trap for the same reason, one scope down.)
	EventBus.day_tick_completed.emit(GameState.day)


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


# --- Daily tick slots (9, ordered) ---

func _tick_product() -> void:
	# Pure-logic system filling slot 1. Manages the active product build's
	# countdown, quality, and ship-moment trigger. Ship moment is narrative-only
	# (no economic delta) per the narrative-strategy design principle.
	# See scripts/systems/product_system.gd.
	ProductSystem.daily_tick()
	# Ürün rev 6.1: DESTEK (§8) ve ALTYAPI (§10) ürün yaşam döngüsünün parçası ama
	# ayrı sistemler. Sıra ÖNEMLİ: destek önce, çünkü günlük memnuniyet zararını o
	# uygular ve altyapı aşımı o zararın tavanına (§8.3'ün −2,0'ı) girer.
	SupportSystem.daily_tick()
	InfraSystem.daily_tick()
	# §19 — okuma yüzeyinin KENAR sinyalleri EN SONDA: duraklama, doğrulama,
	# ısınma bandı, taban ve çıta hepsi bugünün yerleşmiş durumundan okunur.
	ProductRead.emit_edges()

func _tick_rnd() -> void:
	RnDSystem.daily_tick()
	EventBus.research_progress_changed.emit()

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
	# net flow applied. See scripts/events/core/engine.gd.
	EventGate.daily_tick()

func _tick_industry_events() -> void:
	# Slot 7a: the news feed composes the day's ticker lines (sektör/rakip/biz) —
	# runs AFTER sales and rivals so it reads the day's settled state. The slot is
	# SHARED, not consumed: calendar industry events (TC Disrupt, YC Demo Day —
	# the original IndustryEventScheduler reservation) still land here when built.
	NewsFeedSystem.daily_tick()

# SLOT 8a IS GONE. It existed to give Frank's cheque a place in the day's order, and the whole
# comment that used to live here was about beating PhaseGateSystem to the modal: "on a day when
# two systems both inject, the FIRST caller owns the modal." Neither system injects any more.
# Both cheque and gate are cards; the engine admits the day's candidates in slot 6 and assigns
# their presentation class over the whole set at once, so priority is declared (§11.2) rather
# than won by call order. That is the same hazard this comment named, deleted rather than
# mitigated.


func _tick_phase_check() -> void:
	# Gate evaluator. Opens gates (the latch only); the phase
	# itself changes via GameState.advance_phase(), inside the card the player answers.
	#
	# IT MOVED IN FRONT OF THE EVENT SLOT, and the move is the whole reason the gate card can
	# fire on the day the gate opens. `funding.gate_traction` reads `phase.gate_ready` — the
	# ratchet this line sets. Evaluated after the engine, the ratchet would be one tick behind
	# every day of the run and the card would arrive the morning after its own condition.
	# It runs after Finance for the same reason the event slot does: MRR and brand have to be
	# the day's settled numbers, not yesterday's.
	PhaseGateSystem.daily_tick()
	# The seed door latches in the SAME slot and immediately after, for the identical reason
	# spelled out above: `funding.seed_door` reads the ratchet this line writes, and a card
	# evaluated before its own condition arrives the morning after the bar is crossed.
	SeedRoundSystem.daily_tick()

func _tick_pitch() -> void:
	# Slot 8b: VC sheet clocks, callbacks, delayed delivery, meeting-day
	# prompt. BEFORE Endings so the cascade-defer inputs (active_sheets/pending_meeting)
	# are fresh when EndingsSystem._check_vc_cascade reads them.
	VCPitchSystem.daily_tick()

func _tick_endings_check() -> void:
	# Slot 9: terminal scan. Can end the run
	# (run_active = false halts this loop from the next frame on).
	EndingsSystem.daily_tick()

func _tick_month_summary() -> void:
	# Slot 10: Month-End Summary. AFTER the
	# endings scan on purpose — if a terminal fired today, run_active is false
	# and the summary is suppressed (the ending wins).
	MonthSummarySystem.daily_tick()


# --- Hourly tick slots (3, lighter) ---

func _tick_product_hourly(hour: int) -> void:
	# Product Lifecycle Part 1: the active build's quality accrues hourly (from 0,
	# smooth) + development bugs accumulate hourly. Phase counters stay daily.
	# See scripts/systems/product_system.gd.
	ProductSystem.hourly_tick(hour)
	# §9 bildirim akışı, §8.2 doğrulama ve §8.4 düzeltme koşusu SAATLİK ilerler
	# (her biri günlük oranın 1/24'ü), çünkü oyuncu gün ortasında masaya birini
	# atayabilir ve etkisini aynı gün görmelidir.
	SupportSystem.hourly_tick(hour)

func _tick_sales_hourly(hour: int) -> void:
	# B2C audience flows (bidirectional) and MRR derives every
	# in-game hour, so the economy reads as live. See scripts/systems/sales_system.gd.
	SalesSystem.hourly_tick(hour)

func _tick_hourly_events(hour: int) -> void:
	# Ambient (random-trigger) reactive events evaluate hourly so time-of-day
	# windows (allowed_hours in the event JSON) are mechanically honest — a
	# 02:17 bug event fires at night, not at the midnight daily tick.
	# Deterministic beat events stay on the daily path (slot 6, daily_tick).
	# See scripts/autoload/event_manager.gd (D-A).
	EventGate.hourly_tick(hour)

func _tick_hourly_schedule(hour: int) -> void:
	pass  # TODO when CharacterRegistry exposes schedule queries
	# (e.g. mentor available 09:00-18:00, sales reps idle after 18:00)
