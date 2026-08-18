class_name HRMoraleSystem
extends RefCounted

# The morale machine (design doc §6), yıllık izin (§8) and the departure paths.
# Ticked DAILY from HRSystem.daily_tick (slot 3), in the order that file fixes and for the
# reasons it gives:
#   1. tick_leave_returns    — status flips back FIRST, so everything below reads the
#                              restored `active` (capacity, ek mesai, badges).
#   2. tick_leave_departures — next, so today's capacity already excludes whoever left.
#   5. tick_thresholds       — AFTER HROvertimeSystem, so a person pushed under KAÇMA RİSKİ
#                              by tonight's mesai starts their count today, not tomorrow.
#   6. tick_trait_effects    — periodic (not daily), reads the settled morale picture.
#   7. tick_positive_events  — the RECOVERY channel, last, on the settled picture.
#
# Owns: every movement of Character.morale (the only writer in the game besides the event
# modifiers), Character.status / leave_until_day / leave_taken_year / flight_risk_days, the
# flight-risk counter and its resignation roll, the pending-departure latch, the
# same-department trait nudges, the positive-event trigger surface, and
# GameState.hr_last_positive_event_day.
#
# THERE IS NO DRIFT. The old ±1/day-toward-50 tick is DELETED, not tuned to zero: on a day
# with no event, no ek mesai, no aşırı yük and no player action, morale does not move by a
# single point. Morale moves only from played causes (design doc §6). That is also why a
# negative delta which scales below half a point is DROPPED instead of rounded to -1
# (see scaled_delta) — a rounding rule is exactly how a deleted drift grows back.
#
# WRITE-THROUGH LAW: morale ONLY through CharacterRegistry.set_morale (never `emp.morale =`),
# which clamps and emits morale_changed; departures ONLY through CharacterRegistry.remove
# (which increments run_departures and emits character_removed); one-time money ONLY through
# FinanceSystem.apply_one_time_cost (this file charges nothing — a resignation has no
# severance); player-facing beats ONLY through EventManager.enqueue (the modal queue) and
# EventBus.headline_added (the non-interrupting ticker). The employment fields above have no
# registry seam and this system is their owner, so they are written here and nowhere else.
# Every HR tunable comes from HRConstants: there is no HR number in this file.


# --- Local, non-tunable constants (keys and sentinels, not knobs) ---

# SUPERSEDED by RngStreams.STREAM_HR_MORALE, which salts `run_seed ^ <name>.hash()` with
# exactly the same technique for exactly the reason recorded here. Kept as a named constant
# because HRConstants.resign_voice and the file's own header both cite it, and because it
# documents WHY the salt is a string hash rather than a magic number: String.hash() is
# stable for a given string. Nothing seeds from it any more — see _roll().
const RNG_SALT := "hr_morale_system"

# Per-record marker for "this leave was the MANUAL vacation, not the automatic annual one",
# because the two owe different return bonuses and the return lands up to LEAVE_DAYS later.
# Character has no field for it and the model is a shared file, so the marker lives in
# GameState.flags — the same per-record flag pattern B2BSalesSystem uses for
# "b2b_broke_<customer_id>", and it travels with GameState instead of dying with a static var.
const FLAG_MANUAL_LEAVE_PREFIX := "hr_manual_leave_"

# "Hiç olmadı" for the days_since_* reads. It has to be distinguishable from 0, because 0
# means TODAY and the ship/signing triggers compare against 0 exactly.
const NEVER := -1


# --- Static state ---
# THE GENERATOR MOVED, THE REASONING DID NOT. This file used to hold a private
# RandomNumberGenerator because SkillCheck ended in a bare randf() drawing from the one
# global seed that event triggers and EventManager's shuffle also consumed — so an HR roll
# could displace that stream and flip a long-horizon case with nothing to do with HR. That
# insight is now the whole design: RngStreams gives events, skill and hr_morale one named
# stream each, and this file draws from RngStreams.STREAM_HR_MORALE. The private _rng and
# its _seeded_for cursor are gone (RngStreams keeps that cursor for all three streams), and
# in exchange the HR sequence is now RESUMABLE from a save rather than only from birth.
# Pending-departure latch. A resignation event sits in the queue until the player acknowledges
# it; without this the roll would be re-attempted every day in between, and even though
# EventManager.enqueue dedupes the event, the wasted draws would push the effective odds
# silently above HRConstants.RESIGN_CHANCE_PER_DAY. Held HERE, not on the event: a synthetic
# event bypasses _is_eligible entirely, so `one_shot` does nothing (HREventFactory's header).
static var _pending: Array[String] = []


# ============================================================================
#  Daily steps, called in this order by HRSystem.daily_tick
# ============================================================================

static func tick_leave_returns() -> void:
	# Runs FIRST so the restored `active` status is what the rest of the day reads.
	for emp in CharacterRegistry.get_employees():
		if emp.category != "employee":
			continue   # Frank is filtered by get_employees; verified again, not assumed
		if emp.status != HRConstants.STATUS_ON_LEAVE:
			continue
		if GameState.day < emp.leave_until_day:
			continue
		var was_manual: bool = bool(GameState.get_flag(FLAG_MANUAL_LEAVE_PREFIX + emp.id, false))
		CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ACTIVE)
		emp.leave_until_day = 0
		GameState.set_flag(FLAG_MANUAL_LEAVE_PREFIX + emp.id, false)
		# İzin dönüşü moral getirir; manuel TATİLE GÖNDER daha büyük (design doc §7).
		# The TÜKENİYOR badge clears by itself as soon as morale crosses back over
		# MORALE_BURNOUT — nothing here touches badges, they are derived.
		if was_manual:
			apply_delta(emp, HRConstants.MORALE_VACATION_RETURN, HRConstants.REASON_VACATION_RETURN)
		else:
			apply_delta(emp, HRConstants.MORALE_LEAVE_RETURN, HRConstants.REASON_LEAVE_RETURN)
		var whence: String = TranslationServer.translate("HR_WHENCE_HOLIDAY") if was_manual else TranslationServer.translate("HR_WHENCE_LEAVE")
		EventBus.headline_added.emit(HRConstants.notice_source_hr(), TranslationServer.translate("HR_NEWS_BACK_FROM").format({"name": emp.character_name, "whence": whence}))


static func tick_leave_departures() -> void:
	# İzin ayı geldiğinde çalışan OTOMATİK izne çıkar, oyuncu onayı istenmez (design doc §8).
	var date: Dictionary = GameState.get_date_dict()
	var month: int = int(date.month)
	var year: int = int(date.year)
	for emp in CharacterRegistry.get_employees():
		if emp.category != "employee":
			continue
		if emp.status != HRConstants.STATUS_ACTIVE:
			continue
		if emp.leave_month <= 0 or emp.leave_month != month:
			continue
		if emp.leave_taken_year == year:
			# Already had this year's leave. This guard is ALSO what makes the
			# returns-before-departures order safe on its own: whoever returned earlier in
			# this same tick is already stamped for the current year, so they cannot be
			# re-sent today no matter which step runs first.
			continue
		send_on_leave(emp, HRConstants.LEAVE_DAYS, false)


static func tick_thresholds() -> void:
	# KAÇMA RİSKİ counter, then the resignation roll. Runs AFTER HROvertimeSystem so tonight's
	# mesai is already in the morale number this reads.
	for emp in CharacterRegistry.get_employees():
		if emp.category != "employee":
			continue
		if emp.status == HRConstants.STATUS_ON_LEAVE:
			# WORKING: the counter FREEZES while someone is away (it is not reset, so neglect
			# is not laundered by a holiday) and no roll is taken. Otherwise the player's own
			# recovery action could be answered with a resignation on day 3 of the holiday it
			# paid for, which would break the loop the recovery channel exists to close.
			continue
		if not HRConstants.is_flight_risk(emp.morale):
			if emp.flight_risk_days != 0:
				emp.flight_risk_days = 0
			continue
		# Under the threshold: another consecutive day on the counter. Asked through
		# HRConstants.is_flight_risk so the counter, the badge and the overtime valve share ONE
		# comparison and cannot disagree about the boundary. Note this moves
		# NO morale — a quiet bad day costs the player time, not points.
		emp.flight_risk_days += 1
		_maybe_resign(emp)


static func tick_trait_effects() -> void:
	# PERIODIC, NOT DAILY: dept_morale_weekly is a weekly cadence
	# (HRConstants.TRAIT_DEPT_MORALE_PERIOD_DAYS), so on six days out of seven this function
	# is a single modulo and a return. On the seventh it still does nothing at all unless
	# somebody actually carries "Kol kanat gerer" / "Havayı bozar" — no carrier, no writes.
	if HRConstants.TRAIT_DEPT_MORALE_PERIOD_DAYS <= 0:
		return
	if GameState.day % HRConstants.TRAIT_DEPT_MORALE_PERIOD_DAYS != 0:
		return
	# İzindeki kimse odada değil: an absent carrier supports nobody and sours nobody, and an
	# absent colleague feels neither. Same reading as B2BSalesSystem's on-leave CS rep, who
	# dampens nothing while away.
	var roster: Array[Character] = CharacterRegistry.get_active_employees()
	var per_department: Dictionary = {}   # dept id -> summed nudge from its carriers
	var own_share: Dictionary = {}        # character id -> what THAT person contributes
	for emp in roster:
		if emp.category != "employee":
			continue
		var own: int = int(round(HRConstants.trait_sum(emp.traits, "dept_morale_weekly")))
		if own == 0:
			continue
		var dept: String = HRConstants.department_of(emp.role)
		if dept == "":
			continue
		per_department[dept] = int(per_department.get(dept, 0)) + own
		own_share[emp.id] = own
	if per_department.is_empty():
		return   # nobody carries a room trait: this day moves nothing
	for emp in roster:
		if emp.category != "employee":
			continue
		var dept_id: String = HRConstants.department_of(emp.role)
		if not per_department.has(dept_id):
			continue
		# A carrier does not nudge THEMSELVES, which is also why a lone carrier in an
		# otherwise empty department changes nothing: total minus own share is zero.
		var delta: int = int(per_department[dept_id]) - int(own_share.get(emp.id, 0))
		if delta == 0:
			continue
		apply_delta(emp, delta, HRConstants.REASON_TRAIT_PEER)


static func tick_positive_events() -> void:
	# THE RECOVERY CHANNEL (design doc §6 + §12.8). Morale never self-heals, so without these
	# the demo would be one-directional. Placeholders on the trigger surface: the copy is the
	# content sprint's, the triggers and the effect channel are ours. The morale itself rides
	# the EXISTING morale_all_employees modifier inside the factory events, so it lands when
	# the player reads the beat, and nothing is applied from here.
	var roster: Array[Character] = CharacterRegistry.get_employees()
	if roster.is_empty():
		return   # no team, no team morale (and average_morale() would read 0 and always pass)
	if not _positive_off_cooldown():
		return
	# One per tick, freshest cause first: today's ship outranks today's signature, which
	# outranks a standing calm stretch. Deterministic order, never a shuffle.
	if days_since_last_ship() == 0:
		var ship: Dictionary = _latest_ship()
		_fire_positive(HREventFactory.build_ship_glow(int(ship.get("version", 1))))
		return
	var signing: Customer = _big_signing_today()
	if signing != null:
		_fire_positive(HREventFactory.build_big_signing(signing.company_name, signing.mrr))
		return
	var calm: int = days_since_last_overtime()
	if calm >= HRConstants.CALM_STRETCH_DAYS and average_morale() < float(HRConstants.CALM_STRETCH_MAX_MORALE):
		_fire_positive(HREventFactory.build_calm_stretch(calm))


# ============================================================================
#  THE morale seam
# ============================================================================

static func apply_delta(emp: Character, delta: int, reason: String) -> void:
	# The single morale entry point for the whole HR module: ek mesai (HROvertimeSystem), the
	# three player actions (HRActions), izin dönüşü and the trait nudges all land here, so the
	# carrier's trait multiplier and the founder's Liderlik climate are folded in exactly once
	# and in one place. Callers pass the NOMINAL design number and never pre-scale it.
	if emp == null or delta == 0:
		return
	if emp.category != "employee":
		# The founder ("founder") and Frank ("mentor") are not morale-managed: founder burnout
		# is out of demo scope and the mentor is not staff. Silent rather than loud on purpose
		# — HROvertimeSystem counts the founder as a mesai participant, so this seam being
		# tolerant is what keeps that system from having to special-case him.
		return
	var effective: int = scaled_delta(emp, delta)
	if effective == 0:
		return
	var before: int = emp.morale
	CharacterRegistry.set_morale(emp.id, before + effective)   # clamps + emits morale_changed
	if OS.is_debug_build():
		print("[HRMoraleSystem] %s moral %d → %d (%s)" % [emp.id, before, emp.morale, reason])


static func scaled_delta(emp: Character, delta: int) -> int:
	# What apply_delta WOULD write, expressed as a delta, without touching any state: trait
	# multiplier, Liderlik climate, the trait floor and the registry's clamp. HRActions'
	# previews print `emp.morale + scaled_delta(...)`, so the number on the confirm card is
	# exactly the number the action produces — one formula, one home, no drift between the
	# promise and the effect.
	if emp == null or delta == 0 or emp.category != "employee":
		return 0
	# LİDERLİK'İN OYUNDAKİ İLK MEKANİK OKUMASI — noted honestly: until this line the skill
	# existed in onboarding, on the founder card and in the audit only. It stays out of the
	# sales, bug and negotiation formulas (design doc §4); here it is İKLİM, and KOORDİNASYON
	# is wired later by the HR Coupling task.
	var leadership: int = GameState.get_founder_skill("leadership")
	var scaled: int
	if delta < 0:
		scaled = int(round(float(delta)
			* HRConstants.trait_mult(emp.traits, "morale_drop_mult")
			* HRConstants.climate_drop_mult(leadership)))
	else:
		scaled = int(round(float(delta) * HRConstants.climate_gain_mult(leadership)))
	if scaled == 0:
		return 0   # NO DRIFT: a drop worth less than half a point is nothing, not -1.
	var target: int = emp.morale + scaled
	if scaled < 0:
		# "Çabuk ısınır": morale does not fall below the carried floor. The floor CATCHES a fall
		# from above and does nothing otherwise — it must never PUSH morale up (that would be
		# drift by another name), and it must never FREEZE someone already beneath it either.
		# Clamping to mini(current, floor) does both jobs at once and gets the second one wrong:
		# for anyone below their own floor it pins the target at today's value, which turns the
		# trait into total immunity from every morale cost in the game. So the floor only binds
		# while the person is still above it.
		var floor_value: int = HRConstants.trait_floor(emp.traits)
		if floor_value > 0 and emp.morale > floor_value:
			target = maxi(target, floor_value)
	return clampi(target, HRConstants.MORALE_MIN, HRConstants.MORALE_MAX) - emp.morale


# ============================================================================
#  Derived read surface (HR tab task 3 + the left-rail badge)
# ============================================================================

static func badges_for(emp: Character) -> Array[String]:
	# DERIVED, never stored: one person can wear two at once and Character.attention_flag is a
	# single String. Worst first, so a UI that only has room for one badge shows the right one.
	var out: Array[String] = []
	if emp == null or emp.category != "employee":
		return out
	if HRConstants.is_flight_risk(emp.morale):
		out.append(HRConstants.BADGE_FLIGHT_RISK)
	if HRConstants.is_burning_out(emp.morale):
		out.append(HRConstants.BADGE_BURNING_OUT)
	# AŞIRI YÜKLÜ is the company-level `needs_engineer` signal read per PERSON: the shortage
	# belongs to the company, the badge belongs to whoever carries it, and that is exactly why
	# only product_dev members wear it — a Satış Uzmanı is not overloaded by a missing
	# engineer. İzindeki kimse de aşırı yüklü değil (WORKING).
	if is_capacity_overloaded():
		var in_product_dev: bool = HRConstants.department_of(emp.role) == HRConstants.DEPT_PRODUCT_DEV
		if in_product_dev and emp.status == HRConstants.STATUS_ACTIVE:
			out.append(HRConstants.BADGE_OVERLOADED)
	return out


static func average_morale() -> float:
	# Employees only: the founder and Frank are NOT part of the team's morale picture (the
	# founder has no morale mechanic and the mentor is not staff). get_employees() already
	# filters by category; the guard below verifies it instead of trusting it.
	var total: int = 0
	var n: int = 0
	for emp in CharacterRegistry.get_employees():
		if emp.category != "employee":
			continue
		total += emp.morale
		n += 1
	if n == 0:
		return 0.0
	return float(total) / float(n)


static func days_since_last_overtime() -> int:
	# HROvertimeSystem stamps GameState.hr_last_overtime_day. 0 means "hiç mesai olmadı", and
	# then the calm stretch is measured from the founding day (day 1) — a team that never
	# worked a late night has genuinely had a quiet stretch, and it must still be able to
	# reach the recovery event, because nothing else lifts morale on its own. Safe to measure
	# this way (unlike the two reads below) because its trigger is a >= comparison, never == 0.
	return GameState.day - maxi(GameState.hr_last_overtime_day, 1)


static func days_since_last_ship() -> int:
	# Reads the mvp_version_history flag ProductSystem appends a {version, day} record to on
	# every ship. NEVER (not 0) when nothing has shipped: 0 means TODAY and a false "today"
	# would fire the ship-glow event on day 1 of a run with no product.
	var latest: Dictionary = _latest_ship()
	if latest.is_empty():
		return NEVER
	return GameState.day - int(latest.get("day", GameState.day))


static func days_since_last_signing() -> int:
	# Reads Customer.acquired_on_day across the registry. NEVER when no account exists, for
	# the same reason as above.
	var newest: int = NEVER
	for c in CustomerRegistry.get_all():
		newest = maxi(newest, c.acquired_on_day)
	if newest <= 0:
		return NEVER
	return GameState.day - newest


static func is_capacity_overloaded() -> bool:
	# FIRST READER of `needs_engineer`. ProductSystem has been setting it since the Part 2 HR
	# bridge (ENGINEER_SPRINT_THRESHOLD sprints inside ENGINEER_WINDOW_DAYS) and nothing has
	# ever read it — the flag's answer was always "hire someone", and this is the module that
	# can finally say so. COMPANY-level signal; the badge it feeds is per-employee, which is
	# why badges_for only hands it to product_dev members.
	return bool(GameState.get_flag("needs_engineer", false))


static func days_until_return(emp: Character) -> int:
	# Remaining leave days for an on-leave employee, for the "İZİNDE · N gün kaldı" line.
	# Character.leave_until_day is the raw absolute day; the subtraction lives here because
	# leave is this file's domain and a card must not do arithmetic on engine state.
	# 0 for anyone at work, and never negative (tick_leave_returns brings them back at 0).
	if emp == null or emp.status != HRConstants.STATUS_ON_LEAVE:
		return 0
	return maxi(emp.leave_until_day - GameState.day, 0)


static func has_pending_departure(character_id: String) -> bool:
	# A resignation event for this person is queued and unresolved. HRActions refuses every
	# card action while it is: the person is already leaving, and acting behind an open modal
	# about them would contradict what the player is reading.
	return _pending.has(character_id)


# ============================================================================
#  Leave + departure seams
# ============================================================================

static func send_on_leave(emp: Character, days: int, is_manual: bool) -> void:
	# The one door to on_leave, used by the automatic annual leave and by TATİLE GÖNDER.
	# Ücretli izin: maaş akmaya devam eder (CharacterRegistry.get_total_monthly_salaries is
	# deliberately NOT status-filtered), kapasite/hız/CS/mesai katkısı durur.
	if emp == null or emp.category != "employee":
		return
	if days <= 0:
		return
	if emp.status == HRConstants.STATUS_ON_LEAVE:
		return   # idempotent: never restart a running leave
	CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ON_LEAVE)
	emp.leave_until_day = GameState.day + days
	# Once-per-year latch. The MANUAL vacation stamps it too, because TATİLE GÖNDER consumes
	# that year's automatic leave (design doc §7) — which is also what keeps a +20 recovery
	# from becoming a fountain the player re-runs every week.
	emp.leave_taken_year = int(GameState.get_date_dict().year)
	GameState.set_flag(FLAG_MANUAL_LEAVE_PREFIX + emp.id, is_manual)
	# Non-interrupting notice: nobody is asked to APPROVE leave (design doc §8), so this is a
	# ticker line and never a modal.
	if is_manual:
		EventBus.headline_added.emit(HRConstants.notice_source_hr(), TranslationServer.translate("HR_NEWS_ON_HOLIDAY").format({"name": emp.character_name, "n": days}))
	else:
		EventBus.headline_added.emit(HRConstants.notice_source_hr(), TranslationServer.translate("HR_NEWS_ON_LEAVE_MONTH").format({"name": emp.character_name}))


static func confirm_departure(character_id: String) -> void:
	# Called by the hr_departure event modifier when the player acknowledges a resignation
	# (EventManager._apply_modifiers). The roll already happened in tick_thresholds; this is
	# the removal, and the ONLY place a resignation leaves the roster.
	if character_id == "":
		return
	var emp: Character = CharacterRegistry.get_character(character_id)
	forget_employee(character_id)   # clears the latch even if the record is already gone
	if emp == null:
		return
	if emp.category != "employee":
		push_error("[HRMoraleSystem] confirm_departure on a non-employee ('%s', category '%s') — the founder and the mentor never leave through this path" % [character_id, emp.category])
		return
	# İSTİFADA TAZMİNAT YOKTUR (HRConstants.SEVERANCE_ON_RESIGN == 0, design doc §6). Nothing
	# is charged here on purpose: the price of neglect was the person, not a payment.
	CharacterRegistry.remove(character_id)   # run_departures++ and character_removed


static func forget_employee(character_id: String) -> void:
	# Drop every HR-side latch a leaver held so nothing outlives the record: the
	# pending-departure entry and the manual-vacation marker. Called by confirm_departure and
	# by HRActions.fire BEFORE CharacterRegistry.remove, while the id is still meaningful.
	if character_id == "":
		return
	_pending.erase(character_id)
	GameState.set_flag(FLAG_MANUAL_LEAVE_PREFIX + character_id, false)


static func reset_rng() -> void:
	# Called by HRSystem.reset() from GameState.initialize_run, which runs it AFTER run_seed
	# is assigned (it used to run before, which would have keyed the generator to the
	# PREVIOUS run's seed). RngStreams.get_stream() keeps the belt-and-braces re-key at the
	# first roll, so a future reordering cannot silently break determinism again.
	#
	# NOTE ON THE LOAD PATH: this re-keys the hr_morale stream from run_seed, i.e. back to
	# the START of the sequence. That is correct for a fresh run and would be wrong for a
	# load — which is why SaveCodec.restore_systems runs RngStreams.from_dict() AFTER
	# initialize_run has finished, restoring the saved position over this re-key.
	RngStreams.reseed(GameState.run_seed)
	_pending.clear()


static func to_dict() -> Dictionary:
	# _pending is the resignation latch: an employee whose roll already succeeded sits here
	# until the player acknowledges the event, and without it the roll is re-attempted every
	# day in between, pushing the effective odds silently above RESIGN_CHANCE_PER_DAY.
	#
	# It is PROVABLY empty at every save point today (the latch is set in the same breath as
	# the enqueue, and SaveManager.can_save() refuses while EventManager.has_pending()), so
	# this could have been justified as an exclusion. It is saved anyway: that invariant
	# lives in a different file, and a schema that silently depends on another module's gate
	# staying exactly this strict is a trap for whoever loosens it.
	return {"pending_departures": _pending.duplicate()}


static func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	_pending.clear()
	for id in (d.get("pending_departures", []) as Array):
		_pending.append(String(id))


# ============================================================================
#  Internals
# ============================================================================

static func _maybe_resign(emp: Character) -> void:
	# KAÇMA RİSKİ ihmal edilirse istifa (design doc §6). The played decision is upstream: the
	# badge is visible for the whole window and all three card actions are available the
	# entire time, so neglect IS the decision.
	#
	# THE GUARD ORDER MATTERS: every cheap integer test runs before the RNG is touched, so a
	# healthy team consumes literally zero draws and cannot displace anything.
	if emp.flight_risk_days <= 0:
		return
	if emp.flight_risk_days < HRConstants.RESIGN_WINDOW_MIN_DAYS:
		return
	if _pending.has(emp.id):
		return
	var chance: float = HRConstants.resign_chance(
		emp.traits, HROvertimeSystem.valve_continued_for(emp.id))
	if emp.flight_risk_days >= HRConstants.RESIGN_WINDOW_MAX_DAYS:
		# WORKING: the far edge of the canon 10-14 gün window is a CERTAINTY, not a coin flip
		# that keeps failing. Rolling forever would leave a permanently neglected employee in
		# limbo with a red badge the player can never resolve; stopping the roll at day 14
		# would do the same and also make ~24% of neglected people immortal. Rolled on days
		# 10-13, certain on day 14 — so "ignored for two weeks" is a rule the player can learn.
		chance = 1.0
	if not _roll(chance):
		return
	# Latch BEFORE enqueueing, so a re-entrant enqueue path can never double-fire.
	_pending.append(emp.id)
	EventManager.enqueue(HREventFactory.build_resignation(emp))


static func _roll(chance: float) -> bool:
	# Same force-flag shape as SkillCheck.roll_against / SkillCheck.resolve, so the smoke
	# suite can pin a resignation without pinning the whole global stream:
	# flags["debug_hr_force"] = "pass" | "fail", debug builds only.
	var forced: String = String(GameState.get_flag("debug_hr_force", ""))
	if OS.is_debug_build() and forced == "pass":
		return true
	if OS.is_debug_build() and forced == "fail":
		return false
	return RngStreams.get_stream(RngStreams.STREAM_HR_MORALE).randf() < chance


static func _positive_off_cooldown() -> bool:
	# GameState.hr_last_positive_event_day is ours. 0 = hiç tetiklenmedi, which must not read
	# as "fired on day 0" and gate the first one.
	if GameState.hr_last_positive_event_day <= 0:
		return true
	return GameState.day - GameState.hr_last_positive_event_day >= HRConstants.POSITIVE_EVENT_COOLDOWN_DAYS


static func _fire_positive(ev: GameEvent) -> void:
	# The cooldown stamp IS the once-only latch for these three: their factory ids are shared
	# (not per-character like the resignation), and a synthetic event ignores one_shot. Stamped
	# at ENQUEUE, never at resolve, so an unread beat still blocks the next one.
	GameState.hr_last_positive_event_day = GameState.day
	EventManager.enqueue(ev)


static func _latest_ship() -> Dictionary:
	# mvp_version_history is an Array of {version, day}; ProductSystem appends on every ship.
	var history: Array = GameState.get_flag("mvp_version_history", [])
	var best: Dictionary = {}
	for entry in history:
		if not (entry is Dictionary):
			continue
		var e: Dictionary = entry
		if best.is_empty() or int(e.get("day", 0)) >= int(best.get("day", 0)):
			best = e
	return best


static func _big_signing_today() -> Customer:
	# BÜYÜK İMZA: an account signed TODAY at or above HRConstants.BIG_SIGNING_MRR. Largest
	# wins so the beat names the biggest name; ties resolve by registry insertion order, which
	# is stable. No market_type filter — a $1.500+ account is a big signature either way, and
	# B2C is aggregate audience rather than discrete records.
	var best: Customer = null
	for c in CustomerRegistry.get_all():
		if c.acquired_on_day != GameState.day:
			continue
		if c.mrr < HRConstants.BIG_SIGNING_MRR:
			continue
		if best == null or c.mrr > best.mrr:
			best = c
	return best
