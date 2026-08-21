class_name SalesRepSystem
extends RefCounted

# The SATIŞ MASASI — what a hired Satış Uzmanı actually does (Task 2b, HR × Sales coupling).
# Pure static logic, no scene dependency. Dispatched DAILY from B2BSalesSystem.daily_tick,
# LAST, after the customer lifecycle sweep. Ordering is load-bearing: an autonomous close
# creates a Customer, and that account must not be lifecycle-ticked on its own signing day —
# a founder-pitched account never is, because the pitch resolves mid-day after slot 4.
#
# WHAT THIS FILE IS ALLOWED TO DO (§10 Economic Outcome Principle):
#   A sales employee GENERATES opportunities and ADVANCES them. That is capacity, exactly what
#   §10 says hiring buys. A ROUTINE close — an account whose archetype band ceiling is at or
#   under B2BConstants.AUTONOMOUS_CLOSE_MRR_MAX, and which needs no concession — may resolve
#   on its own and is REPORTED as a legible line naming the closer, the customer and the MRR.
#   Everything bigger, and anything needing a promise or a discount, still goes through the
#   played pitch. This file therefore never calls PromiseRegistry.create and never applies a
#   discount: those levers exist only inside PitchSystem's close stage and the retention modal,
#   so "concession deals stay played" is structural here, not a check that could be forgotten.
#
# NO RNG. Not one draw. Two reasons, both learned the hard way elsewhere in this codebase:
# HRMoraleSystem's header records that a bare randf() displaces the single global stream that
# event random-triggers and EventManager's per-priority shuffle also consume, and this system
# would draw EVERY day a rep is employed; and a rep working a lead is WORK, which this game
# models as an accumulator (efor_spent / total_efor), not a coin flip. It also makes
# "Kerem dört gündür Ege Sigorta ile çalışıyor" a readable cause instead of a hidden roll.
#
# THE ADDITIVITY INVARIANT: with no active Satış Uzmanı every entry point returns before it
# touches any state. A run without one is byte-identical to the game before Task 2b.


# --- Daily entry (called by B2BSalesSystem.daily_tick, last) ---
static func daily_tick() -> void:
	# rev 2 §4: the SATIŞ AREA staffs the pipeline, not the job title. Nobody assigned →
	# the desk is shut, exactly as it was with nobody hired. Today a sales_rep hire lands
	# on this job automatically, so the additivity invariant below still holds byte-for-byte.
	if HRSystem.assigned_to(HRConstants.AREA_SALES).is_empty():
		return
	# Generate BEFORE advancing, so ProspectRegistry only ever grows within a tick. Fresh
	# leads start at zero warmth, so they cannot close on the day they appear.
	_tick_lead_generation()
	_tick_prospect_progress()


# --- The ranked team ---

static func _ranked(axis: String) -> Array:
	# Everyone ASSIGNED to the sales job and at work, best-on-Satış first. On-leave and
	# in-training people are excluded by HRSystem.assigned_to: they keep the assignment
	# (they return to it) but they are not prospecting today.
	# The founder is included when he is assigned — ch. 02 §5's "sales capacity with no
	# sales hire = founder only, and only while assigned to selling" lands exactly here.
	var reps: Array = []
	for c in HRSystem.assigned_to(HRConstants.AREA_SALES):
		reps.append(c)
	reps.sort_custom(func(a: Character, b: Character) -> bool:
		var av: int = int(a.role_stats.get(axis, 0))
		var bv: int = int(b.role_stats.get(axis, 0))
		if av == bv:
			return a.id < b.id     # deterministic tiebreak; get_active_by_role is already id-sorted
		return av > bv)
	return reps


static func _diminished_sum(axis: String) -> float:
	# DIMINISHING RETURNS, stated: rank-0 counts full, rank-1 counts REP_STACK_DECAY, rank-2
	# that squared, and so on. The falloff is STRUCTURAL — more people working one pipeline
	# get in each other's way. It is deliberately NOT a leadership reading: rev 2 §4 gives
	# the sales job a lead like any other, but a lead multiplies a TEAM's output, and this
	# curve is about the pipeline being one object that several hands crowd.
	var total: float = 0.0
	var weight: float = 1.0
	for c in _ranked(axis):
		# §5: aşırı yük ve ikincil alan çarpanları burada da geçerli. `no_team_bonus`
		# EMEKLİ (2026-08-21) — sekiz trait'lik sette "yalnız çalışır" yok; yerine gelen
		# çarpanlar kişinin KENDİ verimini değiştiriyor, istifini değil.
		total += weight * float(int(c.role_stats.get(axis, 0))) \
			* HRSystem.output_mult_for_area(c, HRConstants.AREA_SALES) \
			* HRConstants.trait_mult(c.traits, "output_mult") \
			* HRConstants.trait_mult(c.traits, "speed_mult")
		weight *= B2BConstants.REP_STACK_DECAY
	return total


static func _top_expertise() -> int:
	var reps: Array = _ranked(HRConstants.AREA_SALES)
	if reps.is_empty():
		return 0
	return int(reps[0].role_stats.get(HRConstants.AREA_SALES, 0))


static func _overtime_mult() -> float:
	# Exactly 1.0 when no Satış block runs. Before Task 2b a player could start one, pay for it
	# in cash AND morale, and receive nothing: HROvertimeSystem.speed_multiplier was only ever
	# read with DEPT_PRODUCT_DEV. This is the sales desk's half of closing that.
	return HROvertimeSystem.speed_multiplier(HRConstants.DEPT_SALES)


# --- BULMA: the pipeline ---

static func lead_rate_per_day() -> float:
	# Public so the UI and the smoke suite can read the same number the tick uses.
	return B2BConstants.LEAD_PER_PACE_POINT * _diminished_sum(HRConstants.AREA_SALES) * _overtime_mult()


static func _tick_lead_generation() -> void:
	var progress: float = float(GameState.get_flag("sales_lead_progress", 0.0)) + lead_rate_per_day()
	var emitted: int = 0
	while progress >= 1.0 and emitted < B2BConstants.LEAD_DAILY_MAX:
		# Anti-snowball (Calibration Law 1) and legible: a full column reads as "you are not
		# pitching", never as "your reps stopped working".
		if ProspectRegistry.count() >= B2BConstants.PIPELINE_SOFT_CAP:
			break
		# Same archetype mix rule as the founder's own "Aday bul" button (sales_tab.gd), so
		# the pipeline's COMPOSITION is unchanged in character no matter who filled it.
		var archetype: String = "mid" if (GameState.day + emitted) % 3 == 0 else "small"
		var lead: Prospect = PitchSystem.spawn_prospect(archetype, "sales_rep")
		if lead == null:
			break   # catalog exhausted (Fix 1 null contract): defer — progress stays banked
		progress -= 1.0
		emitted += 1
	# Never bank more than one lead's worth: a soft-capped pipeline must not release a burst
	# the moment the player pitches one lead away.
	GameState.set_flag("sales_lead_progress", minf(progress, 1.0))


# --- KAPAMA: warming, and the §10 fork ---

static func is_auto_closable(p: Prospect) -> bool:
	# THE §10 GATE, in one place so there is exactly one answer to "may a rep close this?".
	if p == null:
		return false
	# (1) Size. Gate on the archetype's band CEILING, not the computed deal value: the line is
	# tier-based and cannot be gamed by pricing a bigger account low.
	if int(CustomerArchetypes.mrr_band(p.archetype)["high"]) > B2BConstants.AUTONOMOUS_CLOSE_MRR_MAX:
		return false
	# (2) Concession. If the pain this lead voices maps to a feature the product has NOT
	# shipped, closing it means promising it — and giving the company's word is the founder's
	# act, not the rep's. Straight off existing data; no new field.
	#
	# An UNMAPPABLE pain is the conservative case, not the permissive one. This branch used
	# to return true — so the gate opened widest exactly where the engine knew least, and
	# `mvp_components` was never consulted at all. A lead whose need we cannot even name is
	# the clearest possible "route this to the founder's played pitch".
	if p.pain_feature_id == "":
		return false
	var live: Array = GameState.get_flag("mvp_components", [])
	return live.has(p.pain_feature_id)


static func warm_bonus_for(p: Prospect) -> int:
	# What the founder INHERITS on a lead the desk warmed but was not allowed to close. Rides
	# the pitch's existing _accum_bonus channel, so the rep's groundwork shows up in the odds
	# without SkillCheck ever reading an employee: the founder is the one in the room.
	if p == null:
		return 0
	return clampi(int(floor(p.warm_progress)), 0, B2BConstants.WARM_BONUS_MAX)


static func _warm_gain(p: Prospect, expertise_sum: float) -> float:
	# One rate for the whole pool. difficulty_stars (1/2/4) divides it — that divisor is the
	# only job the field has outside the pitch close roll, and it is what makes a small account
	# a few days of work and an enterprise account weeks of it.
	var stars: float = float(maxi(p.difficulty_stars, 1))
	return B2BConstants.WARM_PER_EXPERTISE_POINT * expertise_sum / stars


static func _tick_prospect_progress() -> void:
	var expertise_sum: float = _diminished_sum(HRConstants.AREA_SALES) * _overtime_mult()
	if expertise_sum <= 0.0:
		return
	# Snapshot: _try_auto_close removes from the registry, and get_all() already hands back a
	# fresh array, but iterating a copy keeps that guarantee local and obvious.
	var pool: Array[Prospect] = ProspectRegistry.get_all()
	pool.sort_custom(func(a: Prospect, b: Prospect) -> bool:
		if is_equal_approx(a.warm_progress, b.warm_progress):
			return a.id < b.id     # deterministic: warmest first, id breaks ties
		return a.warm_progress > b.warm_progress)
	for p in pool:
		p.warm_progress += _warm_gain(p, expertise_sum)
		if p.warm_progress < B2BConstants.AUTO_CLOSE_PROGRESS:
			continue
		if is_auto_closable(p):
			_close(p)
		# A warmed-but-too-big lead keeps accumulating: warm_bonus_for clamps the payoff at
		# WARM_BONUS_MAX, so it stops mattering on its own without a flag to maintain.


static func _close(p: Prospect) -> void:
	var reps: Array = _ranked(HRConstants.AREA_SALES)
	if reps.is_empty():
		return
	var closer: Character = reps[0]
	var band: Dictionary = CustomerArchetypes.mrr_band(p.archetype)
	# A better closer places higher in the band — but a small deal can never leave the small
	# band, so a rep-closed account can never cross AUTONOMOUS_CLOSE_MRR_MAX from below.
	var frac: float = clampf(B2BConstants.AUTO_CLOSE_MRR_FRAC
		+ B2BConstants.AUTO_CLOSE_MRR_PER_EXPERTISE * float(_top_expertise()), 0.0, 1.0)
	var mrr: int = int(round(lerpf(float(band["low"]), float(band["high"]), frac)))
	# Same signing seam and the SAME satisfaction seed as a played pitch — shared static, so
	# the two paths cannot drift apart under a later edit.
	var c: Customer = SalesSystem.add_b2b_customer(p, mrr,
		PitchSystem.signing_satisfaction_seed(), "sales_rep:%s" % closer.id)
	ProspectRegistry.remove(p.id)
	# The legible cause, in both channels: who closed it, which customer, what MRR.
	SalesSystem.record_sales_event("auto_close", closer.character_name, c.company_name, c.mrr)
	EventBus.headline_added.emit(B2BConstants.notice_source_sales(),
		TranslationServer.translate("SALES_LOG_REP_CLOSED").format({"rep": closer.character_name, "company": c.company_name}))
	# Deliberately does NOT touch next_pitch_day: a rep closing an account of their own does
	# not consume the founder's meeting slot.
