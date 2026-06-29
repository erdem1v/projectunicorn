class_name ProductSystem
extends RefCounted

# Slot 1 daily tick per TECH_SPEC §8.2. Pure logic (TECH_SPEC §8.3).
#
# Spec #4 phase model (Software Inc.-style, replaces Spec #2's iteration-duration
# selection): planning → iteration ⇄ iteration → development → bugfix → shipped.
# The player commits no up-front duration; they advance phases by choosing on
# the right-top BuildHUDPanel. Iteration cycles freely (advance vs. enter
# development), development auto-ticks to completion, bugfix is open-ended
# until the player presses LAUNCH.
#
# Ship moment remains narrative-only — flags shift, no economic delta. The
# `launch()` body consolidates what used to be commit_to_ship_early /
# commit_to_ship_from_polish / ship_active_build into a single entry point.
#
# Iteration end does NOT pause the game. We set `iteration_decision_pending`
# on the build and emit EventBus.build_iteration_decision_pending(true);
# BuildHUDPanel lights up its buttons and the player picks on their own time
# while the clock keeps ticking. This is intentional — Software Inc. fidelity,
# and it avoids tangling iteration decisions with the §A event-pause restore.

const QUALITY_BASELINE := 50

# Iteration phase tunables — Working Values §F.2 / §F.3
const BASE_QUALITY_GROWTH := 1.5
const TECH_QUALITY_MOD := 1.0
const BASE_BUG_RATE := 1.2
const TECH_BUG_MOD := 0.4

# Spec #4 phase machinery — Working Values §F.5
const ITERATION_LENGTH_DAYS := 4
const QUALITY_PER_ITERATION := 5
const BASE_BUG_RATE_REDUCTION_PER_ITER := 0.1
const DEVELOPMENT_DAYS_BASE := 6

# Bugfix phase tunables — Working Values §F.4 (renamed from polish_*)
const POLISH_BUG_FIX_PER_DAY := 4
const POLISH_QUALITY_BUMP_PER_DAY := 1

# Bonus bug count applied at launch when the player left a critical bug
# in (ev_mvp_bugfix_001_critical_bug "Bırak, gönder" choice → flag).
const CRITICAL_BUG_LAUNCH_PENALTY := 5

static var active_build: FeatureBuild = null


# --- Entry point (called by TimeManager._tick_product at slot 1) ---

static func daily_tick() -> void:
	if active_build == null:
		return
	match active_build.current_phase:
		"iteration":
			_tick_iteration_phase()
		"development":
			_tick_development_phase()
		"bugfix":
			_tick_bugfix_phase()
		# planning / shipped / cancelled — no daily work
	# Repaint progress bars AFTER the phase counters advanced this tick. The HUD
	# also refreshes on day_advanced, but that fires before this tick decrements
	# the counter, so without this the bar lags a day (Faz 1 bug 1.1).
	EventBus.build_progress_changed.emit()


# --- Phase ticks ---

static func _tick_iteration_phase() -> void:
	# If the iteration counter is already at 0 we're idling, waiting for the
	# player to pick. No quality/bug accrual while idling — only the chosen
	# iterations count toward quality.
	if active_build.iteration_decision_pending:
		return
	active_build.iteration_days_in_current = max(0, active_build.iteration_days_in_current - 1)
	var tech: int = GameState.get_founder_skill("tech")
	# Quality growth (clamped 0-100). Quality tavanı QUALITY_PER_ITERATION
	# kadar yukarı kaydı her advance_iteration'da; daily growth o tavana doğru
	# çalışır. Şimdilik basit: doğrudan kalite += her gün.
	var quality_delta: float = BASE_QUALITY_GROWTH + (float(tech) * TECH_QUALITY_MOD)
	active_build.quality = clampi(active_build.quality + int(round(quality_delta)), 0, 100)
	# Bug accumulation, reduced as iteration_count grows (yeni iterasyonlar
	# bug rate'ini azaltır — Spec #4 §F.5).
	var bug_rate_modifier: float = 1.0 - (BASE_BUG_RATE_REDUCTION_PER_ITER * float(max(0, active_build.iteration_count - 1)))
	bug_rate_modifier = max(0.2, bug_rate_modifier)
	var bug_delta: float = max(0.0, BASE_BUG_RATE - (float(tech) * TECH_BUG_MOD)) * bug_rate_modifier
	active_build.bug_count += int(round(bug_delta))
	# Iteration counter hit 0 — flag pending so BuildHUDPanel activates its
	# decision buttons. Game keeps running.
	if active_build.iteration_days_in_current == 0:
		active_build.iteration_decision_pending = true
		EventBus.build_iteration_decision_pending.emit(true)


static func _tick_development_phase() -> void:
	active_build.development_days_elapsed += 1
	var tech: int = GameState.get_founder_skill("tech")
	var quality_delta: float = BASE_QUALITY_GROWTH + (float(tech) * TECH_QUALITY_MOD)
	active_build.quality = clampi(active_build.quality + int(round(quality_delta)), 0, 100)
	var bug_delta: float = max(0.0, BASE_BUG_RATE - (float(tech) * TECH_BUG_MOD))
	active_build.bug_count += int(round(bug_delta))
	if active_build.development_days_elapsed >= active_build.development_days_total:
		active_build.current_phase = "bugfix"
		active_build._sync_status_from_phase()
		# Snapshot bug count at bugfix entry so PostShipView / HUD can read
		# "started with M, shipped with N". Keyed by build id.
		GameState.set_flag("bug_count_at_bugfix_start_%s" % active_build.id, active_build.bug_count)
		EventBus.build_phase_changed.emit("bugfix")
		if OS.is_debug_build():
			print("[ProductSystem] Development complete → bugfix. quality=%d bugs=%d" % [active_build.quality, active_build.bug_count])


static func _tick_bugfix_phase() -> void:
	# Open-ended — no auto shipping. Player presses LAUNCH on BuildHUDPanel.
	active_build.bug_count = max(0, active_build.bug_count - POLISH_BUG_FIX_PER_DAY)
	active_build.quality = clampi(active_build.quality + POLISH_QUALITY_BUMP_PER_DAY, 0, 100)


# --- Public phase-advance API (called by BuildHUDPanel buttons) ---

static func advance_iteration() -> void:
	if active_build == null or active_build.current_phase != "iteration":
		push_warning("[ProductSystem] advance_iteration called outside iteration phase")
		return
	active_build.iteration_count += 1
	active_build.iteration_days_in_current = ITERATION_LENGTH_DAYS
	active_build.iteration_decision_pending = false
	# Quality ceiling bump — every iteration buys headroom.
	active_build.quality = clampi(active_build.quality + QUALITY_PER_ITERATION, 0, 100)
	EventBus.build_iteration_decision_pending.emit(false)
	if OS.is_debug_build():
		print("[ProductSystem] advance_iteration → iter %d, quality=%d" % [active_build.iteration_count, active_build.quality])


static func enter_development() -> void:
	if active_build == null or active_build.current_phase != "iteration":
		push_warning("[ProductSystem] enter_development called outside iteration phase")
		return
	active_build.current_phase = "development"
	active_build.development_days_elapsed = 0
	active_build.iteration_decision_pending = false
	active_build._sync_status_from_phase()
	EventBus.build_iteration_decision_pending.emit(false)
	EventBus.build_phase_changed.emit("development")
	if OS.is_debug_build():
		print("[ProductSystem] enter_development. dev_days_total=%d iter_count=%d" % [active_build.development_days_total, active_build.iteration_count])


static func launch() -> void:
	# Player pressed LAUNCH on BuildHUDPanel. Stamp launch state, fire ship
	# moment cinematic, then ship_active_build clears active_build when the
	# player dismisses the modal (via the choice's ship_active_build modifier).
	if active_build == null:
		push_warning("[ProductSystem] launch called with no active build")
		return
	if active_build.current_phase != "bugfix":
		push_warning("[ProductSystem] launch called outside bugfix phase (was %s)" % active_build.current_phase)
		return
	# Apply critical-bug penalty if the player chose to ship with an unfixed
	# bug (set by ev_mvp_bugfix_001_critical_bug "Bırak, gönder"). Per-run flag
	# is consumed here.
	if GameState.get_flag("critical_bug_unfixed", false):
		active_build.bug_count += CRITICAL_BUG_LAUNCH_PENALTY
		GameState.set_flag("critical_bug_unfixed", false)
	GameState.set_flag("mvp_quality", active_build.quality)
	GameState.set_flag("mvp_bug_count_at_launch", active_build.bug_count)
	GameState.set_flag("mvp_iteration_count", active_build.iteration_count)
	# PostShip sales model selectors — SalesSystem / PostShipView branch on these.
	GameState.set_flag("mvp_sub_product_type_id", active_build.sub_product_type_id)
	GameState.set_flag("mvp_market_type", ProductCatalog.get_market_type(active_build.sub_product_type_id))
	_trigger_ship_moment()


# --- Public helpers ---

static func get_active_build() -> FeatureBuild:
	return active_build


static func start_build(
	sub_product_type_id: String,
	feature_ids: Array,
	assigned_engineer_id: String
) -> bool:
	if active_build != null:
		push_warning("[ProductSystem] start_build called while build already active")
		return false
	# Validate sub-product type
	var sub_type: Dictionary = ProductCatalog.get_sub_product_type_by_id(sub_product_type_id)
	if sub_type.is_empty():
		push_warning("[ProductSystem] start_build invalid sub_product_type_id: %s" % sub_product_type_id)
		return false
	# Validate feature count
	if feature_ids.size() < 2 or feature_ids.size() > 4:
		push_warning("[ProductSystem] start_build invalid feature count: %d (want 2-4)" % feature_ids.size())
		return false
	# Validate all features belong to the sub-product type's pool
	var pool: Array = ProductCatalog.get_feature_pool(sub_product_type_id)
	var pool_ids: Array[String] = []
	for f in pool:
		pool_ids.append(String(f.get("id", "")))
	for fid in feature_ids:
		if not pool_ids.has(String(fid)):
			push_warning("[ProductSystem] start_build feature %s not in pool for %s" % [fid, sub_product_type_id])
			return false
	var b: FeatureBuild = FeatureBuild.new()
	b.id = "mvp_build_001"
	b.sub_product_type_id = sub_product_type_id
	var typed_features: Array[String] = []
	for fid in feature_ids:
		typed_features.append(String(fid))
	b.feature_ids = typed_features
	b.assigned_engineer_id = assigned_engineer_id
	b.start_day = GameState.day
	b.quality = QUALITY_BASELINE
	b.bug_count = 0
	b.is_mvp = true
	b.current_phase = "iteration"
	b.iteration_count = 1
	b.iteration_days_in_current = ITERATION_LENGTH_DAYS
	b.iteration_decision_pending = false
	b.development_days_total = DEVELOPMENT_DAYS_BASE + b.get_total_complexity()
	b.development_days_elapsed = 0
	b.min_estimation_days = max(5, b.get_total_complexity() + 2)
	# Backward compat — populate legacy fields with sensible defaults
	b.component_ids = typed_features
	b.total_days = b.development_days_total
	b.days_remaining = b.development_days_total
	b._sync_status_from_phase()
	active_build = b
	EventBus.build_phase_changed.emit("iteration")
	if OS.is_debug_build():
		print("[ProductSystem] Build started: %s with %d features, dev_days_total=%d" % [b.id, b.feature_ids.size(), b.development_days_total])
	return true


static func cancel_build() -> void:
	if active_build == null:
		return
	active_build.current_phase = "cancelled"
	active_build._sync_status_from_phase()
	EventBus.build_phase_changed.emit("cancelled")
	active_build = null


# --- Event modifier hooks ---

static func apply_speed_bonus(days: int) -> void:
	# days is negative to speed up; positive to slow down. Phase-aware — applies
	# to whichever phase counter is currently active. Bugfix is open-ended so
	# speed bonuses there are no-ops (player decides when to LAUNCH).
	if active_build == null:
		return
	match active_build.current_phase:
		"iteration":
			active_build.iteration_days_in_current = max(0, active_build.iteration_days_in_current + days)
		"development":
			active_build.development_days_total = max(active_build.development_days_elapsed, active_build.development_days_total + days)


static func apply_quality_bonus(amount: int) -> void:
	if active_build == null:
		return
	active_build.quality = clamp(active_build.quality + amount, 0, 100)


static func ship_active_build() -> void:
	# Narrative-only — sets world-state flags, clears active build.
	# NO economic delta (no set_mrr / set_cash / set_brand / set_reputation).
	# Called via the ship_moment modal's ship_active_build modifier after the
	# player dismisses the cinematic.
	if active_build == null:
		push_warning("[ProductSystem] ship_active_build called with no active build")
		return
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("product_quality", active_build.quality)
	GameState.set_flag("mvp_components", active_build.component_ids)
	active_build.status = "shipped"
	active_build.current_phase = "shipped"
	EventBus.build_phase_changed.emit("shipped")
	active_build = null
	if OS.is_debug_build():
		print("[ProductSystem] Build shipped. mvp_shipped flag set.")


# --- Synthetic ship-moment event ---

static func _trigger_ship_moment() -> void:
	var ev: GameEvent = _build_ship_moment_event()
	EventManager.enqueue(ev)


static func _build_ship_moment_event() -> GameEvent:
	var ev: GameEvent = GameEvent.new()
	ev.id = "ev_mvp_ship_moment"
	ev.category = "reactive"
	ev.title = "İlk versiyonun hazır"
	ev.subtitle = ""
	ev.illustration_path = ""
	ev.character_id = "char_mentor_frank"
	ev.body_text = "Demo'ya bir kez daha bakıyorsun. Frank arkanda duruyor, telefonuna bakmıyor.\n\n\"Tamam,\" diyor. \"Bu kadar kötü değil.\"\n\nYayına alıyorsun. Birkaç dakika sonra GitHub'da repo public, küçük bir landing page canlı, Frank elini cebine atıyor.\n\n\"Şimdi zor kısmı başlıyor. Bunun parasını verecek birini bulmamız lazım.\""
	ev.cooldown_days = 0
	ev.one_shot = true
	ev.priority = 10
	# build_safe so EventManager._is_eligible() doesn't suppress the ship
	# cinematic itself during the active build it's meant to close out.
	ev.tags = ["build_safe", "ship_moment"]
	ev.trigger_conditions = []
	var choice: EventChoice = EventChoice.new()
	choice.label = "Ship'le"
	choice.modifiers = [{"type": "ship_active_build"}]
	choice.unlock_condition = {}
	choice.unlock_reason_text = ""
	var choices: Array[EventChoice] = []
	choices.append(choice)
	ev.choices = choices
	return ev
