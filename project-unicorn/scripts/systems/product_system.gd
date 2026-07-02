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

# --- Phase machinery ---
const ITERATION_LENGTH_DAYS := 4
const DEVELOPMENT_DAYS_BASE := 6
# Product Lifecycle Part 2B: total feature count a version build (v1 union + new) may carry.
const MAX_VERSION_FEATURES := 8
# Pool-deepening (feature-exhaustion unlock): when the pool is exhausted the player
# STRENGTHENS existing features instead of adding new ones. Cap on picks per version + a
# flat per-day growth bonus to each strengthened feature's dominant axis (on top of the
# weight redistribution in FeatureBuild) so the targeted axis visibly outgrows a plain
# rebuild. BALANCE-TUNABLE.
const STRENGTHEN_MAX_PER_VERSION := 2
const STRENGTHEN_FLAT_PER_DAY := 1.5
const POLISH_BUG_FIX_PER_DAY := 4        # bugs cleared per day during bugfix
const HOURS_PER_BUILD_DAY := 24          # quality/bugs accrue hourly (~daily_raw / 24)

# --- Development bug accrual (Blok C: complexity-driven, tech reduces NOT zeros) ---
# Per-HOUR fractional bug rate = max(BUG_FLOOR, Σcomplexity·COEF − tech·REDUCER).
# Complex product + low tech = bug rain; simple + high tech = clean-but-few (never 0).
# All BALANCE-TUNABLE.
const BUG_COMPLEXITY_COEF := 0.006
const BUG_TECH_REDUCER := 0.005
const BUG_FLOOR := 0.010
# Tech-debt taken via dev events converts to real bugs at development→bugfix.
const TECH_DEBT_BUG_PENALTY := 5

# --- Multi-dimensional per-phase quality growth (Product Lifecycle Part 1) ---
# Per-tick raw growth per axis, routed through QualityModel.grow(_, _, ASYMPTOTE)
# so every gain is bounded below the structural ceiling (a Phase-1 build's each
# axis stays < PHASE1_AXIS_ASYMPTOTE forever). Shaped by the build's feature
# dimension mix (_shaped_raw). All BALANCE-TUNABLE (Erdem tunes last).
const ITER_INNO := 2.0            # iteration = design exploration → innovation
const ITER_USAB := 1.5            #            + usability
const DEV_STAB_BASE := 1.5        # development = build-out → stability (+ tech)
const DEV_USAB := 1.0             #            + usability
const TECH_STAB_COEF := 0.75      # founder tech skill → stability/tick
const BUGFIX_STAB := 2.0          # bugfix = hardening → stability
const BUGFIX_USAB := 0.5
# Feature-mix shaping: effective raw = raw * (DIM_BASE_SHARE + DIM_FEATURE_SHARE *
# axis_share*3). Equal mix (share 1/3 → *3 = 1) → neutral 1.0; a favored axis grows
# faster, a starved one slower but never zero.
const DIM_BASE_SHARE := 0.5
const DIM_FEATURE_SHARE := 0.5

# Bonus bug count applied at launch when the player left a critical bug
# in (ev_mvp_bugfix_001_critical_bug "Bırak, gönder" choice → flag).
const CRITICAL_BUG_LAUNCH_PENALTY := 5

# --- Post-ship wear (Product Lifecycle Part 2A) ---
# Live product accrues bugs hourly: more users = more edge cases; complex product
# wears faster; founder tech reduces but NEVER zeros (WEAR_FLOOR). BALANCE-TUNABLE.
# Part 2B rebalance: wear was too aggressive ("a bug every day, sprint every minute").
# Softened so bug accrual takes DAYS of neglect, and tech is now decisive (tech 0 drowns,
# high tech coasts, floor keeps it > 0 forever). All BALANCE-TUNABLE (Erdem tunes last).
const WEAR_AUD_COEF := 0.00004       # per audience member / hour
const WEAR_CPLX_COEF := 0.0012       # per total feature-complexity point / hour
const WEAR_TECH_REDUCER := 0.005     # founder tech skill → less wear (raised: tech now matters)
const WEAR_FLOOR := 0.002            # baseline wear (always > 0)
# Bug sprint (Part 2A): clears live bugs over a few days; duration scales with bugs.
# Part 2B: MIN dropped to 1 + slower per-day rate so 1 bug ≈ 1 day but 10+ bugs is visibly longer.
const SPRINT_BUG_FIX_PER_DAY := 4    # live bugs cleared per day during a sprint
const MIN_SPRINT_DAYS := 1
const MAX_SPRINT_DAYS := 7
# HR-bridge seed (light): too-frequent sprints → needs_engineer signal (no real hire).
const ENGINEER_SPRINT_THRESHOLD := 3   # sprints within the window → "need an engineer"
const ENGINEER_WINDOW_DAYS := 20

static var active_build: FeatureBuild = null


# --- Entry point (called by TimeManager._tick_product at slot 1) ---

static func daily_tick() -> void:
	# Daily = phase COUNTERS + transitions + bugfix bug-clearing only. Quality growth
	# and bug ACCRUAL are hourly now (hourly_tick) so they read smooth, not day-jumps.
	if active_build == null:
		return
	match active_build.current_phase:
		"iteration":
			_tick_iteration_day()
		"development":
			_tick_development_day()
		"bugfix":
			_tick_bugfix_day()
		"bug_sprint":
			_tick_bug_sprint_day()
		# planning / shipped / cancelled — no daily work
	EventBus.build_progress_changed.emit()


# --- Daily phase-counter ticks (transitions only; growth is hourly) ---

static func _tick_iteration_day() -> void:
	# Idle while the player owes an iteration decision — no counter movement.
	if active_build.iteration_decision_pending:
		return
	active_build.iteration_days_in_current = max(0, active_build.iteration_days_in_current - 1)
	if active_build.iteration_days_in_current == 0:
		active_build.iteration_decision_pending = true
		EventBus.build_iteration_decision_pending.emit(true)


static func _tick_development_day() -> void:
	active_build.development_days_elapsed += 1
	if active_build.development_days_elapsed >= active_build.development_days_total:
		# Tech-debt taken during dev events now comes due as real bugs (C2).
		if GameState.get_flag("tech_debt_birikti", false):
			active_build.bug_count += TECH_DEBT_BUG_PENALTY
			GameState.set_flag("tech_debt_birikti", false)
		active_build.current_phase = "bugfix"
		active_build._sync_status_from_phase()
		# Snapshot bug count at bugfix entry so PostShipView / HUD can read
		# "started with M, shipped with N". Keyed by build id.
		GameState.set_flag("bug_count_at_bugfix_start_%s" % active_build.id, active_build.bug_count)
		_sync_legacy_quality(active_build)
		EventBus.build_phase_changed.emit("bugfix")
		if OS.is_debug_build():
			print("[ProductSystem] Development complete → bugfix. quality=%d bugs=%d" % [active_build.quality, active_build.bug_count])


static func _tick_bugfix_day() -> void:
	# Open-ended — no auto shipping. Bugs fall in daily chunks; quality hardens hourly.
	active_build.bug_count = max(0, active_build.bug_count - POLISH_BUG_FIX_PER_DAY)
	_sync_legacy_quality(active_build)


# --- Hourly tick (Product Lifecycle Part 1): smooth quality + bug accrual ---
# Called by TimeManager._tick_product_hourly. Quality breathes hour by hour (from
# 0), instead of jumping on day boundaries.

static func hourly_tick(_hour: int) -> void:
	if active_build == null:
		# Product Lifecycle Part 2A: no build → if a product is live, it WEARS.
		if GameState.get_flag("mvp_shipped", false):
			_post_ship_wear_hourly()
		return
	match active_build.current_phase:
		"iteration":
			if active_build.iteration_decision_pending:
				return  # idling on the player's decision — no accrual
			_grow_hourly(active_build, "innovation", ITER_INNO)
			_grow_hourly(active_build, "usability", ITER_USAB)
			_accrue_bugs_hourly()
		"development":
			var tech: int = GameState.get_founder_skill("tech")
			_grow_hourly(active_build, "stability", DEV_STAB_BASE + float(tech) * TECH_STAB_COEF)
			_grow_hourly(active_build, "usability", DEV_USAB)
			_accrue_bugs_hourly()
		"bugfix":
			_grow_hourly(active_build, "stability", BUGFIX_STAB)
			_grow_hourly(active_build, "usability", BUGFIX_USAB)
		"bug_sprint":
			_tick_bug_sprint_hourly()
		_:
			return
	# Pool-deepening: strengthened features push their dominant axis a little every growth
	# hour in ALL growth phases (no-op unless this is a strengthen build). Runs only after a
	# non-returning growth phase above; bug_sprint carries an empty strengthen list.
	if active_build.current_phase in ["iteration", "development", "bugfix"]:
		_apply_strengthen_growth_hourly(active_build)
	EventBus.build_progress_changed.emit()


static func _grow_hourly(b: FeatureBuild, axis: String, daily_raw: float) -> void:
	_grow_build(b, axis, _shaped_raw(b, axis, daily_raw) / float(HOURS_PER_BUILD_DAY))


static func _accrue_bugs_hourly() -> void:
	# Complexity-driven, tech reduces but never zeros (BUG_FLOOR). Fractional bugs
	# accumulate on bug_progress and tick bug_count up as they cross 1.0.
	var b := active_build
	var tech: int = GameState.get_founder_skill("tech")
	var rate: float = maxf(BUG_FLOOR, float(b.get_total_complexity()) * BUG_COMPLEXITY_COEF - float(tech) * BUG_TECH_REDUCER)
	b.bug_progress += rate
	while b.bug_progress >= 1.0:
		b.bug_count += 1
		b.bug_progress -= 1.0
	_sync_legacy_quality(b)


# --- Post-ship wear (Product Lifecycle Part 2A) ---

static func _post_ship_wear_hourly() -> void:
	# Live product accrues bugs from usage (audience) + complexity, minus founder
	# tech, floored positive. Fractional on mvp_live_bug_progress → mvp_live_bug_count
	# ticks up smoothly. Audience/MRR then erode automatically (economy reads live bug).
	var audience: float = float(GameState.get_flag("b2c_audience", 0))
	var complexity: int = _shipped_total_complexity()
	var tech: int = GameState.get_founder_skill("tech")
	var rate: float = maxf(WEAR_FLOOR, audience * WEAR_AUD_COEF + float(complexity) * WEAR_CPLX_COEF - float(tech) * WEAR_TECH_REDUCER)
	var prog: float = float(GameState.get_flag("mvp_live_bug_progress", 0.0)) + rate
	var count: int = int(GameState.get_flag("mvp_live_bug_count", 0))
	while prog >= 1.0:
		count += 1
		prog -= 1.0
	GameState.set_flag("mvp_live_bug_progress", prog)
	GameState.set_flag("mvp_live_bug_count", count)
	EventBus.build_progress_changed.emit()   # PostShip status block repaints hourly


static func _shipped_total_complexity() -> int:
	var total: int = 0
	for fid in GameState.get_flag("mvp_components", []):
		total += int(ProductCatalog.get_feature_by_id(String(fid)).get("complexity", 0))
	return total


# --- Bug sprint (Product Lifecycle Part 2A) — the founder's repair action ---

static func sprint_duration_for(bug_count: int) -> int:
	# Days to clear `bug_count` at the sprint rate, clamped. Shown pre-commit (§10).
	return clampi(int(ceil(float(bug_count) / float(SPRINT_BUG_FIX_PER_DAY))), MIN_SPRINT_DAYS, MAX_SPRINT_DAYS)


static func start_bug_sprint() -> bool:
	# A founder decision: reuse active_build as a light "bug_sprint" carrier, routed
	# to PostShipView (pricing stays live) — see product_tab._refresh_view.
	if active_build != null:
		push_warning("[ProductSystem] start_bug_sprint while a build/sprint is active")
		return false
	if not GameState.get_flag("mvp_shipped", false):
		return false
	var bugs: int = int(GameState.get_flag("mvp_live_bug_count", 0))
	if bugs <= 0:
		return false
	var b := FeatureBuild.new()
	b.id = "bug_sprint"
	b.is_bug_sprint = true
	b.current_phase = "bug_sprint"
	b.sub_product_type_id = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	b.product_name = String(GameState.get_flag("mvp_product_name", ""))
	b.bug_count = bugs
	b.bug_progress = 0.0
	b.development_days_total = sprint_duration_for(bugs)
	b.development_days_elapsed = 0
	active_build = b
	GameState.set_flag("mvp_bug_sprint_active", true)   # SalesSystem freezes audience while set
	_record_sprint_and_check_engineer()
	EventBus.build_phase_changed.emit("bug_sprint")
	if OS.is_debug_build():
		print("[ProductSystem] Bug sprint started: %d bugs, %d days" % [bugs, b.development_days_total])
	return true


static func _tick_bug_sprint_hourly() -> void:
	# Smooth bug clearing (bugfix rate ÷ 24), synced live to mvp_live_bug_count so the
	# PostShip status block shows bugs dropping + effective stability recovering. No new
	# bugs (wear doesn't run while a build/sprint is active).
	var b := active_build
	b.bug_progress -= float(SPRINT_BUG_FIX_PER_DAY) / float(HOURS_PER_BUILD_DAY)
	while b.bug_progress <= -1.0 and b.bug_count > 0:
		b.bug_count -= 1
		b.bug_progress += 1.0
	b.bug_count = max(0, b.bug_count)
	GameState.set_flag("mvp_live_bug_count", b.bug_count)
	GameState.set_flag("mvp_live_bug_progress", 0.0)


static func _tick_bug_sprint_day() -> void:
	active_build.development_days_elapsed += 1
	if active_build.development_days_elapsed >= active_build.development_days_total:
		# Done: persist the cleared live bug count, drop the sprint, resume normal PostShip.
		GameState.set_flag("mvp_live_bug_count", active_build.bug_count)
		GameState.set_flag("mvp_live_bug_progress", 0.0)
		GameState.set_flag("mvp_bug_sprint_active", false)
		GameState.set_flag("bug_sprint_just_done", true)   # one-shot, consumed by Frank
		active_build = null
		EventBus.build_phase_changed.emit("shipped")   # router → normal PostShipView
		if OS.is_debug_build():
			print("[ProductSystem] Bug sprint complete. live_bug now %d" % int(GameState.get_flag("mvp_live_bug_count", 0)))


static func _record_sprint_and_check_engineer() -> void:
	# HR-bridge seed (light): remember recent sprint days; too many in the window → a
	# needs_engineer signal + Frank line. NO real hire (separate HR task).
	var history: Array = GameState.get_flag("bug_sprint_days", [])
	var recent: Array = []
	for d in history:
		if GameState.day - int(d) < ENGINEER_WINDOW_DAYS:
			recent.append(int(d))
	recent.append(GameState.day)
	GameState.set_flag("bug_sprint_days", recent)
	if recent.size() >= ENGINEER_SPRINT_THRESHOLD:
		GameState.set_flag("needs_engineer", true)


# --- Multi-dimensional growth helpers (Product Lifecycle Part 1) ---

static func _grow_build(b: FeatureBuild, axis: String, raw: float) -> void:
	# Every axis gain flows through QualityModel.grow with the Phase-1 asymptote →
	# open-ended but structurally ceilinged (< PHASE1_AXIS_ASYMPTOTE forever).
	var a: float = QualityModel.PHASE1_AXIS_ASYMPTOTE
	match axis:
		"innovation": b.innovation = QualityModel.grow(b.innovation, raw, a)
		"stability":  b.stability = QualityModel.grow(b.stability, raw, a)
		"usability":  b.usability = QualityModel.grow(b.usability, raw, a)
	_sync_legacy_quality(b)


static func _shaped_raw(b: FeatureBuild, axis: String, raw: float) -> float:
	# Feature mix steers which axis climbs fastest. share*3 ≈ [0..3] (equal = 1).
	var share: float = float(b.get_dimension_weights().get(axis, 1.0 / 3.0)) * 3.0
	return raw * (DIM_BASE_SHARE + DIM_FEATURE_SHARE * share)


# --- Pool-deepening growth (feature-exhaustion unlock) ---

static func _dominant_axis_of(fid: String) -> String:
	# The axis a feature feeds most (deterministic inno→stab→usab tiebreak).
	var dc: Dictionary = ProductCatalog.get_feature_by_id(fid).get("dimension_contribution", {})
	var best: String = "innovation"
	var best_v: float = -INF
	for ax in QualityModel.AXES:
		var v: float = float(dc.get(ax, 0.0))
		if v > best_v:
			best_v = v
			best = ax
	return best


static func _apply_strengthen_growth_hourly(b: FeatureBuild) -> void:
	# Flat additive deepening: each strengthened feature pushes its dominant axis a little
	# every growth hour, in EVERY growth phase → the targeted axis climbs where a plain
	# rebuild grows it by 0 (e.g. innovation in development). Bounded by grow()'s asymptote.
	if b.strengthened_feature_ids.is_empty():
		return
	for fid in b.strengthened_feature_ids:
		_grow_build(b, _dominant_axis_of(fid), STRENGTHEN_FLAT_PER_DAY / float(HOURS_PER_BUILD_DAY))


static func _sync_legacy_quality(b: FeatureBuild) -> void:
	# Keep the derived legacy `quality` int aligned with the normalized economy
	# composite (effective stability) so any not-yet-migrated b.quality reader works.
	var axes: Array = ProductCatalog.get_quality_axes(b.sub_product_type_id)
	b.quality = int(round(QualityModel.normalized_from_dims(QualityModel.economy_dims_from_build(b), axes)))


# --- Public phase-advance API (called by BuildHUDPanel buttons) ---

static func advance_iteration() -> void:
	if active_build == null or active_build.current_phase != "iteration":
		push_warning("[ProductSystem] advance_iteration called outside iteration phase")
		return
	active_build.iteration_count += 1
	active_build.iteration_days_in_current = ITERATION_LENGTH_DAYS
	active_build.iteration_decision_pending = false
	# No instant jump (Product Lifecycle Part 1): another iteration buys more
	# design-exploration TIME — innovation/usability keep climbing (asymptotically)
	# across the added days. The cost is days + runway, not a free +5.
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
	# Product Lifecycle Part 2B: is this a v2+ ship (increment version, merge grown axes) or
	# the first launch (version 1)? Captured before the snapshot below.
	var is_ver: bool = active_build.is_version_build
	# Redesign (display-only): snapshot the PREVIOUS version's axes BEFORE overwriting, so the
	# PostShip control panel can show a version-over-version delta ("this version grew İnovasyon
	# +2" — the visible proof a v-build/strengthen worked). First launch has no prior flag →
	# default to the new value → delta 0. No calculation reads these; pure display.
	GameState.set_flag("mvp_innovation_prev", GameState.get_flag("mvp_innovation", active_build.innovation))
	GameState.set_flag("mvp_stability_prev", GameState.get_flag("mvp_stability", active_build.stability))
	GameState.set_flag("mvp_usability_prev", GameState.get_flag("mvp_usability", active_build.usability))
	# Multi-dimensional snapshot (Product Lifecycle Part 1). Bug penalty above is
	# already applied, so effective stability reflects it downstream. For a version build
	# these axes are the GROWN values (seed + growth) written back over mvp_* = the merge.
	GameState.set_flag("mvp_innovation", active_build.innovation)
	GameState.set_flag("mvp_stability", active_build.stability)
	GameState.set_flag("mvp_usability", active_build.usability)
	GameState.set_flag("mvp_bug_count_at_launch", active_build.bug_count)   # frozen historical snapshot
	# Product Lifecycle Part 2A: the LIVE bug count starts at launch value, then
	# accrues via post-ship wear (economy reads this one).
	GameState.set_flag("mvp_live_bug_count", active_build.bug_count)
	GameState.set_flag("mvp_live_bug_progress", 0.0)
	# Part 2B: v2+ increments the version (title shows "· v2 · canlı"); first launch = 1.
	if is_ver:
		GameState.set_flag("mvp_version", int(GameState.get_flag("mvp_version", 1)) + 1)
	else:
		GameState.set_flag("mvp_version", 1)
	# Backward-compat bridge: derived normalized composite (economy dims) so any
	# not-yet-migrated get_flag("mvp_quality", …) reader can't silently fall to 50.
	var launch_axes: Array = ProductCatalog.get_quality_axes(active_build.sub_product_type_id)
	GameState.set_flag("mvp_quality", int(round(
		QualityModel.normalized_from_dims(QualityModel.economy_dims_from_build(active_build), launch_axes))))
	GameState.set_flag("mvp_iteration_count", active_build.iteration_count)
	GameState.set_flag("mvp_product_name", active_build.product_name)
	# PostShip sales model selectors — SalesSystem / PostShipView branch on these.
	GameState.set_flag("mvp_sub_product_type_id", active_build.sub_product_type_id)
	GameState.set_flag("mvp_market_type", ProductCatalog.get_market_type(active_build.sub_product_type_id))
	_trigger_ship_moment(is_ver)


# --- Public helpers ---

static func get_active_build() -> FeatureBuild:
	return active_build


static func start_build(
	sub_product_type_id: String,
	feature_ids: Array,
	assigned_engineer_id: String,
	product_name: String = ""
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
	b.lead_engineer_id = assigned_engineer_id   # reserve seed; HR wires the real effect later
	var st_name: String = String(sub_type.get("name_human", sub_type.get("name", sub_product_type_id)))
	b.product_name = product_name.strip_edges() if product_name.strip_edges() != "" else st_name
	b.start_day = GameState.day
	# Axes born at 0 (Erdem) — a v1 is genuinely raw and climbs from nothing.
	b.innovation = 0.0
	b.stability = 0.0
	b.usability = 0.0
	b.bug_count = 0
	b.bug_progress = 0.0
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
	_sync_legacy_quality(b)   # derive legacy quality from the (zeroed) axes
	active_build = b
	EventBus.build_phase_changed.emit("iteration")
	if OS.is_debug_build():
		print("[ProductSystem] Build started: %s with %d features, dev_days_total=%d" % [b.id, b.feature_ids.size(), b.development_days_total])
	return true


# --- Version build (Product Lifecycle Part 2B) — the growth arm ---

static func start_version_build(new_feature_ids: Array, assigned_engineer_id: String = "", strengthen_feature_ids: Array = []) -> bool:
	# v2+ reuses the whole build flow, but SEEDS axes from the live product (not 0) and
	# unions new features onto the shipped set. Routed to BuildProgressView (a real build).
	# §10 cost: time + growth freezes (SalesSystem reads mvp_version_build_active) + new bugs.
	# Pool-deepening: when the pool is exhausted, pass strengthen_feature_ids (⊆ mvp_components)
	# instead of new features → the build deepens those axes and never locks.
	if active_build != null:
		push_warning("[ProductSystem] start_version_build while a build is active")
		return false
	if not GameState.get_flag("mvp_shipped", false):
		push_warning("[ProductSystem] start_version_build with no live product")
		return false
	var sub_id: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	# Validate new features belong to the sub-type pool (mirror start_build).
	var pool_ids: Array[String] = []
	for f in ProductCatalog.get_feature_pool(sub_id):
		pool_ids.append(String(f.get("id", "")))
	# Union = existing shipped components + new (dedup, order-stable).
	var union_ids: Array[String] = []
	for fid in GameState.get_flag("mvp_components", []):
		union_ids.append(String(fid))
	var existing_count: int = union_ids.size()
	# Pool-deepening: strengthen picks must be EXISTING product features (⊆ mvp_components).
	# Validated here while union_ids is still exactly the shipped set. Dedup + clamp to the cap
	# (defense — the UI also enforces STRENGTHEN_MAX_PER_VERSION).
	var typed_strengthen: Array[String] = []
	for sid in strengthen_feature_ids:
		var ss: String = String(sid)
		if not union_ids.has(ss):
			push_warning("[ProductSystem] strengthen %s not in mvp_components" % ss)
			return false
		if not typed_strengthen.has(ss) and typed_strengthen.size() < STRENGTHEN_MAX_PER_VERSION:
			typed_strengthen.append(ss)
	for fid in new_feature_ids:
		var s: String = String(fid)
		if not pool_ids.has(s):
			push_warning("[ProductSystem] v2 feature %s not in pool for %s" % [s, sub_id])
			return false
		if not union_ids.has(s):
			union_ids.append(s)
	# THE LOCK, now CONDITIONAL: a new feature is required ONLY when not strengthening. When
	# the pool is exhausted the player strengthens instead → the version build never locks.
	if union_ids.size() <= existing_count and typed_strengthen.is_empty():
		push_warning("[ProductSystem] v2 needs >=1 new feature OR >=1 strengthen")
		return false
	if union_ids.size() > MAX_VERSION_FEATURES:
		push_warning("[ProductSystem] v2 exceeds MAX_VERSION_FEATURES (%d)" % MAX_VERSION_FEATURES)
		return false

	var next_version: int = int(GameState.get_flag("mvp_version", 1)) + 1
	var b: FeatureBuild = FeatureBuild.new()
	b.id = "mvp_build_v%d" % next_version
	b.sub_product_type_id = sub_id
	b.feature_ids = union_ids
	b.component_ids = union_ids
	b.strengthened_feature_ids = typed_strengthen   # pool-deepening: amplifies these axes
	b.assigned_engineer_id = assigned_engineer_id
	b.lead_engineer_id = assigned_engineer_id
	b.product_name = String(GameState.get_flag("mvp_product_name", ""))
	b.start_day = GameState.day
	# KEY DIFFERENCE from start_build (axes born at 0): v2 SEEDS from the live product, so a
	# high axis has little grow() headroom and a weak axis has lots → feeding the weak axis
	# grows fastest (the intended "strengthen your weak side, pass the rival" loop).
	b.innovation = float(GameState.get_flag("mvp_innovation", 0.0))
	b.stability = float(GameState.get_flag("mvp_stability", 0.0))
	b.usability = float(GameState.get_flag("mvp_usability", 0.0))
	b.bug_count = int(GameState.get_flag("mvp_live_bug_count", 0))   # inherit live bugs (sprint first for a clean v2)
	b.bug_progress = 0.0
	b.is_mvp = true
	b.is_version_build = true
	b.current_phase = "iteration"
	b.iteration_count = 1
	b.iteration_days_in_current = ITERATION_LENGTH_DAYS
	b.iteration_decision_pending = false
	b.development_days_total = DEVELOPMENT_DAYS_BASE + b.get_total_complexity()   # bigger union → longer
	b.development_days_elapsed = 0
	b.min_estimation_days = max(5, b.get_total_complexity() + 2)
	b.total_days = b.development_days_total
	b.days_remaining = b.development_days_total
	b._sync_status_from_phase()
	_sync_legacy_quality(b)
	active_build = b
	GameState.set_flag("mvp_version_build_active", true)   # SalesSystem freezes audience growth+erosion
	EventBus.build_phase_changed.emit("iteration")
	if OS.is_debug_build():
		print("[ProductSystem] v%d build started: %d features (union), dev_days_total=%d, seeded I%d/S%d/U%d bugs=%d" % [
			next_version, b.feature_ids.size(), b.development_days_total,
			int(b.innovation), int(b.stability), int(b.usability), b.bug_count])
	return true


static func cancel_build() -> void:
	if active_build == null:
		return
	active_build.current_phase = "cancelled"
	active_build._sync_status_from_phase()
	# A bailed v2 must un-freeze the live economy (else audience stays frozen forever).
	GameState.set_flag("mvp_version_build_active", false)
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
	# Legacy event modifier alias → innovation axis (bounded via grow()).
	apply_dimension_delta("innovation", amount)


static func apply_dimension_delta(axis: String, amount: int) -> void:
	# Build-event modifier (Product Lifecycle Part 1): grow (+) or penalize (−) one
	# quality axis. grow() keeps positive gains bounded; negatives floor at 0.
	if active_build == null:
		return
	if not (axis in QualityModel.AXES):
		axis = "innovation"
	_grow_build(active_build, axis, float(amount))


static func apply_bug_delta(amount: int) -> void:
	# Build-event modifier: add (+) or clear (−) bugs directly.
	if active_build == null:
		return
	active_build.bug_count = max(0, active_build.bug_count + amount)
	_sync_legacy_quality(active_build)


static func ship_active_build() -> void:
	# Narrative-only — sets world-state flags, clears active build.
	# NO economic delta (no set_mrr / set_cash / set_brand / set_reputation).
	# Called via the ship_moment modal's ship_active_build modifier after the
	# player dismisses the cinematic.
	if active_build == null:
		push_warning("[ProductSystem] ship_active_build called with no active build")
		return
	GameState.set_flag("mvp_shipped", true)
	# Redesign (display-only): stamp the FIRST ship day once, so the PostShip status chip can
	# read the product's live age ("N gün canlı"). Not overwritten on later versions (product
	# age is from first ship). No calculation reads it; pure display.
	if not GameState.has_flag("mvp_launch_day"):
		GameState.set_flag("mvp_launch_day", GameState.day)
	# (dead `product_quality` write removed — nobody read it; mvp_* is canonical.)
	GameState.set_flag("mvp_components", active_build.component_ids)
	# Part 2B: a version build carried the union feature set → mvp_components now reflects the
	# larger product (wear reads the new complexity). Lift the growth freeze (v2 done shipping).
	GameState.set_flag("mvp_version_build_active", false)
	active_build.status = "shipped"
	active_build.current_phase = "shipped"
	EventBus.build_phase_changed.emit("shipped")
	active_build = null
	if OS.is_debug_build():
		print("[ProductSystem] Build shipped. mvp_shipped flag set.")


# --- Synthetic ship-moment event ---

static func _trigger_ship_moment(is_version: bool = false) -> void:
	var ev: GameEvent = _build_version_ship_moment_event() if is_version else _build_ship_moment_event()
	EventManager.enqueue(ev)


static func _build_version_ship_moment_event() -> GameEvent:
	# Lighter, version-aware ship moment (Part 2B). Not one-shot — each v2/v3 fires it.
	var ev: GameEvent = GameEvent.new()
	ev.id = "ev_mvp_version_ship_moment"
	ev.category = "reactive"
	var ver: int = int(GameState.get_flag("mvp_version", 2))
	ev.title = "v%d yayında" % ver
	ev.subtitle = ""
	ev.illustration_path = ""
	ev.character_id = "char_mentor_frank"
	ev.body_text = "Yeni sürümü push'luyorsun. Frank ekrana bakıyor, başını hafifçe sallıyor.\n\n\"Büyüdü. Yeni feature'lar tuttu — ama yeni yüzey, yeni bug demek. Gözünü ayırma.\"\n\nKullanıcılar farkı görecek. Rakipler de."
	ev.cooldown_days = 0
	ev.one_shot = false
	ev.priority = 10
	ev.tags = ["build_safe", "ship_moment"]
	ev.trigger_conditions = []
	var choice: EventChoice = EventChoice.new()
	choice.label = "Yayına devam"
	choice.modifiers = [{"type": "ship_active_build"}]
	choice.unlock_condition = {}
	choice.unlock_reason_text = ""
	var choices: Array[EventChoice] = []
	choices.append(choice)
	ev.choices = choices
	return ev


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
