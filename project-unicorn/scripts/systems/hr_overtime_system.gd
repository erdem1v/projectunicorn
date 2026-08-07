class_name HROvertimeSystem
extends RefCounted

# Ek mesai (HR design doc §7b) — department-wide overtime blocks, started from a MAIN
# department header and never from a sub-section. Pure static logic, no instance state
# beyond the pay stamp below, no scene dependency.
#
# Dispatched DAILY from HRSystem.daily_tick (slot 3), fourth in that file's fixed order,
# and every neighbour in that order is load-bearing here:
#   - leave RETURNS and DEPARTURES ran first, so `status` is settled and today's
#     participant list is final before a single dollar or morale point moves;
#   - HRMoraleSystem.tick_thresholds() runs immediately AFTER, so a person pushed under
#     KAÇMA RİSKİ by tonight's mesai starts their flight-risk count TODAY, not tomorrow;
#   - FinanceSystem is two slots later (slot 5), which is what lets today's pay be a
#     PULL (pay_accrued_today) instead of a push into a burn category.
#
# Ownership — nothing else may compute any of these: the per-department block record on
# GameState.hr_overtime, the 1-based day index inside a block, the daily money accrual
# Finance pulls, the daily morale cost, the per-block safety-valve latch, the run-long
# "Devam et" memory, and the two multipliers.
#
# STATE, NOT APPLICATION: this system owns speed_multiplier() and bug_multiplier() and
# applies NEITHER to a build, sales or CS formula. The HR Coupling task (task 2) wires
# them in. One formula home per concept: the overtime machine stays unit-testable on its
# own, and the build speed formula keeps living in ProductSystem.
#
# WRITE-THROUGH LAW: money reaches burn ONLY because FinanceSystem pulls
# pay_accrued_today() into burn_breakdown["overtime"] (this file never writes a burn
# category and never touches cash); morale moves ONLY through HRMoraleSystem.apply_delta,
# which already folds in the carrier's trait multiplier and the founder's Liderlik climate
# coefficient (so they are never applied here — that would double them); the safety valve
# reaches the player ONLY through EventManager.enqueue(HREventFactory.build_overtime_valve);
# the one non-modal notice goes out on EventBus.headline_added. The only fields written
# outside those seams are the ones this system owns by name: GameState.hr_overtime,
# GameState.hr_last_overtime_day, and Character.overtime_days (no seam exists for the last
# one and nothing reacts to it by signal, so it is written directly — same pattern as
# B2BSalesSystem writing c.cs_escalated / c.retain_stalls on the record it owns).


# --- Keys of the per-department block record on GameState.hr_overtime ---
# block_days / day_index are the two names GameState's own field comment documents.
const KEY_BLOCK_DAYS := "block_days"
const KEY_DAY_INDEX := "day_index"
const KEY_STARTED_DAY := "started_day"   # RESERVED: stored for the HR tab's "X. günden beri"
const KEY_VALVE_FIRED := "valve_fired"   # per-block latch: character ids already warned
const KEY_CHARGED_DAY := "charged_day"   # the last calendar day this block was billed

# day_index is 1-BASED inside the current block: HRConstants.overtime_morale_drop(1) is
# the first mesai night. A block record is created at day_index 0 (started, not yet
# worked) and the first daily tick advances it to BLOCK_FIRST_DAY.
const BLOCK_FIRST_DAY := 1

# Category discriminator (Character.category) — the same literal CharacterRegistry filters
# on. Named here only so the assertion in participants() reads as an assertion.
const CATEGORY_EMPLOYEE := "employee"

# Run-long "Devam et" memory rides on GameState.flags under this prefix, exactly like
# B2BSalesSystem's "b2b_broke_%s" credibility flag. See note_valve_continued().
const VALVE_FLAG_PREFIX := "hr_valve_continued_"


# Today's accrued overtime money, stamped by daily_tick and PULLED by FinanceSystem two
# slots later. Static (not on GameState) because it is a single-day scratch total, not run
# state; _pay_stamped_day makes the stamp self-verifying so a stale read can never be
# charged twice. Cleared by reset() for the debug onboarding re-trigger, which reuses the
# process and would otherwise carry the last run's stamp into day 1 of the next one.
static var _pay_today: int = 0
static var _pay_stamped_day: int = -1

# Money owed for a day that was billed AFTER Finance already pulled. An early stop can only
# ever happen during hours 1..23, i.e. after slot 5 has run for today, so its pay would be
# zeroed by tomorrow's reset before Finance ever saw it. It rides here for one day instead
# and is folded into tomorrow's total at the top of daily_tick, ahead of the pull.
static var _pay_carry: int = 0


# --- Daily entry (called by HRSystem.daily_tick, slot 3) ---

static func daily_tick() -> void:
	# THE PAY-TIMING TRAP, and the one line that defuses it: the stamp is cleared HERE, at
	# the START of the day, and NOWHERE else. HR ticks at slot 3 and Finance pulls at slot
	# 5 of the SAME day, so a block that auto-ends tonight must leave tonight's total
	# readable — clearing on block end would work the final night for free.
	_pay_today = _pay_carry
	_pay_carry = 0
	_pay_stamped_day = GameState.day
	if GameState.hr_overtime.is_empty():
		return   # no block anywhere: zero roster reads, zero cost
	# Fixed department order (never dictionary order) so the accrual total, the morale
	# writes and any valve enqueue land in the same sequence every run.
	for entry in HRConstants.DEPARTMENTS:
		var dept_id: String = String(entry)
		if is_active(dept_id):
			_tick_department(dept_id)


static func _tick_department(dept_id: String) -> void:
	var block: Dictionary = GameState.hr_overtime[dept_id]
	if not block.has(KEY_VALVE_FIRED):
		block[KEY_VALVE_FIRED] = []   # defensive: a partial record still gets its latch
	# Contract order inside the tick: advance the index, apply the morale cost at the NEW
	# index, stamp the pay, bump each participant's counter, stamp the calm-period cursor,
	# then auto-end.
	_charge_day(dept_id, block, true)
	if int(block.get(KEY_DAY_INDEX, 0)) >= _block_length(block):
		# Auto-end on the final night. Today's stamp is deliberately untouched.
		_end_block(dept_id, false)


# THE ONE PLACE A MESAI DAY IS BILLED — morale to every participant, money into today's
# total, each participant's own counter, and the calm-period cursor. Both the daily tick
# and an early stop route through here, which is what makes "a day you started mesai is a
# day you paid for" true however the day ends.
#
# `to_carry` sends the money to tomorrow's total instead of today's: an early stop happens
# during hours 1..23, so Finance has already pulled for today and a same-day credit would
# be wiped by tomorrow's reset before the pull. Morale is NOT carried — it lands the
# instant it is spent, which is what the player feels.
static func _charge_day(dept_id: String, block: Dictionary, fire_valve: bool, to_carry: bool = false) -> void:
	var idx: int = int(block.get(KEY_DAY_INDEX, 0)) + 1
	block[KEY_DAY_INDEX] = idx
	block[KEY_CHARGED_DAY] = GameState.day
	var drop: int = HRConstants.overtime_morale_drop(idx)
	var crew: Array[Character] = participants(dept_id)
	for emp in crew:
		# The trait multiplier and the Liderlik climate coefficient are applied INSIDE
		# apply_delta. Folding either in here would apply it twice.
		HRMoraleSystem.apply_delta(emp, -drop, HRConstants.REASON_OVERTIME)
		emp.overtime_days += 1
		var pay: int = HRConstants.overtime_daily_pay(emp.monthly_salary)
		if to_carry:
			_pay_carry += pay
		else:
			_pay_today += pay
		if fire_valve:
			# Valve check AFTER the drop lands, so tonight's mesai is what trips it.
			_maybe_enqueue_valve(block, emp, dept_id)
	# The "sakin dönem" positive event reads this cursor (HRMoraleSystem.days_since_last_
	# overtime). Stamped on every day a block actually runs, even if the crew is empty.
	GameState.hr_last_overtime_day = GameState.day


# --- Start / stop ---

static func can_start(dept_id: String) -> bool:
	if not HRConstants.DEPARTMENTS.has(dept_id):
		return false
	if is_active(dept_id):
		return false
	# WORKING: at least one cost-bearing participant is required. A block with nobody to
	# pay and nobody to tire would be a free multiplier, which is exactly what Calibration
	# Law 1 and the played-cost principle forbid — and for product_dev it would let a solo
	# founder buy speed with nothing but bug risk. Overtime is a lever over a TEAM, so it
	# unlocks with the first hire in that department.
	return not participants(dept_id).is_empty()


static func start(dept_id: String, block_days: int) -> bool:
	if not can_start(dept_id):
		return false
	if not HRConstants.OVERTIME_BLOCKS.has(block_days):
		push_warning("[HROvertimeSystem] start(%s) with a block length that is not in HRConstants.OVERTIME_BLOCKS: %d"
			% [dept_id, block_days])
		return false
	GameState.hr_overtime[dept_id] = {
		KEY_BLOCK_DAYS: block_days,
		KEY_DAY_INDEX: 0,          # started tonight, not yet worked; first tick makes it 1
		KEY_STARTED_DAY: GameState.day,
		KEY_VALVE_FIRED: [],
	}
	# overtime_days counts days worked in the CURRENT block, so it starts from zero for the
	# whole department (see _reset_overtime_days on why on-leave people are included).
	_reset_overtime_days(dept_id)
	if OS.is_debug_build():
		print("[HROvertimeSystem] %s ek mesai başladı — %d gün, %d kişi"
			% [dept_id, block_days, participants(dept_id).size()])
	return true


static func stop(dept_id: String) -> bool:
	# Early stop is fully supported: the days already worked stay paid (nothing is
	# refunded), nothing further accrues because the record is gone, and no morale cost
	# lands again afterwards. Stopping the morning after the 4th night therefore totals
	# exactly 4 days of pay.
	#
	# WHAT IS NOT FREE ANY MORE: the day being stopped, if it has not been billed yet. The
	# speed bonus is consumed on the HOURLY tick while the cost was charged only on the
	# daily one, so a block whose whole life fit between two daily ticks — start at 10:00,
	# "Bitir" at 22:00 — delivered up to 23 hours of +%30 build speed for zero money and
	# zero morale, every single day, and the panel's own copy invited it. A day the crew
	# worked is a day the company pays for, however the day ends.
	if not is_active(dept_id):
		return false
	var block: Dictionary = GameState.hr_overtime[dept_id]
	if int(block.get(KEY_CHARGED_DAY, -1)) != GameState.day:
		# The valve is deliberately NOT fired here: "devam edelim mi?" is not a question to
		# ask about a block that is ending this second.
		_charge_day(dept_id, block, false, true)
	_end_block(dept_id, true)
	return true


# --- Reads (the surface task 3's HR tab and task 2's coupling consume) ---

static func is_active(dept_id: String) -> bool:
	# Presence of the record IS the running state; _end_block erases it.
	return GameState.hr_overtime.has(dept_id)


static func day_index(dept_id: String) -> int:
	# 1-based within the current block. 0 means "not working overtime tonight" — which
	# covers both an inactive department and the start day, before the first daily tick has
	# advanced the index (see speed_multiplier for why that day still carries the bonus).
	if not is_active(dept_id):
		return 0
	var block: Dictionary = GameState.hr_overtime[dept_id]
	return int(block.get(KEY_DAY_INDEX, 0))


static func current_block_days(dept_id: String) -> int:
	# ADDED to the contract's read surface (reported to the lead): the HR tab prints
	# "Gün 3 / 7", and without this the UI would have to reach into GameState.hr_overtime
	# and read the record directly. 0 when nothing is running. NOT named block_days —
	# that identifier is already a parameter name on start() and preview_block(), and a
	# method sharing it would have every one of those parameters shadowing it.
	if not is_active(dept_id):
		return 0
	return _block_length(GameState.hr_overtime[dept_id])


static func speed_multiplier(dept_id: String) -> float:
	# STATE ONLY — the Coupling task applies this to the build/sales/CS formulas.
	# Exactly 1.0 when no block runs, so multiplying by it is always safe.
	#
	# On the START day the index still reads 0 and the block is already active, so the
	# opening rate applies from the next hourly tick onward.
	#
	# THE OLD JUSTIFICATION HERE WAS NOT MERELY STALE, IT WAS INVERTED, and that is what
	# hid the exploit for so long. It argued that ProductSystem reads this multiplier at
	# daily slot 1, before HR ticks at slot 3, and concluded that "a start-and-stop inside
	# one day is a pure loss." There is no such read: ProductSystem.daily_tick only appends
	# to mvp_bug_history, and the ONLY product-side consumer is _tick_build_hourly — up to
	# 24 reads a day, both before and after slot 3. So the same-day start/stop was the
	# opposite of a loss; it was free speed. stop() now bills the day it ends, which is
	# what makes the sentence below true rather than aspirational.
	#
	# (Historic note kept because it is still the right way to think about the shape —
	# the bonus is collected on the days where the index reads 0..block_days-1, against
	# block_days paid nights. The hourly bug accrual runs at OVERTIME_BUG_MULT throughout.)
	if not is_active(dept_id):
		return 1.0
	return 1.0 + HRConstants.overtime_speed_bonus(day_index(dept_id))


static func bug_multiplier() -> float:
	# Only product_dev overtime degrades quality (design doc §7b): tired hands write bugs,
	# a tired sales rep does not. Global (not per-department) because there is one bug
	# counter on the active build. STATE ONLY — ProductSystem applies it via Coupling.
	if is_active(HRConstants.DEPT_PRODUCT_DEV):
		return HRConstants.OVERTIME_BUG_MULT
	return 1.0


static func participants(dept_id: String) -> Array[Character]:
	# The COST-BEARING roster: employees of this department who are AT WORK. An on-leave
	# employee never participates (izinde kapasite dışıdır — design doc §8), which also
	# makes annual leave a genuine escape hatch mid-block: they stop being paid overtime,
	# stop taking the morale hit, and their overtime_days freezes where it stood.
	#
	# THE FOUNDER IS NOT AN ARRAY ELEMENT. Founder participation in a product_dev block is
	# modelled as a CONSTANT PRESENCE instead (founder_participates() below) — which is
	# also why speed_multiplier is a flat department-wide rate that does not scale with
	# head count: whoever is in the room, the department is working nights. Keeping the
	# founder out of this array makes "never paid, no morale cost" STRUCTURAL instead of a
	# filter inside three loops that a later edit could quietly drop, and founder burnout
	# is out of demo scope so there is no founder morale channel to feed anyway.
	var out: Array[Character] = []
	if not HRConstants.DEPARTMENTS.has(dept_id):
		return out
	for emp in CharacterRegistry.get_active_employees():
		# ASSERTED, not assumed (contract §C): Frank is category "mentor" and the founder
		# is category "founder". get_active_employees() already filters to "employee", and
		# HRConstants.department_of(ROLE_MENTOR) is "" on top of that, so a hit here means
		# one of those two barriers changed under us. Scream and skip — non-blocking, the
		# same grammar as CharacterRegistry._validate_shape.
		if emp.category != CATEGORY_EMPLOYEE:
			push_error("[HROvertimeSystem] '%s' (category '%s') reached the overtime roster — only employees ever work a block"
				% [emp.id, emp.category])
			continue
		if HRConstants.department_of(emp.role) != dept_id:
			continue
		out.append(emp)
	return out


static func founder_participates(dept_id: String) -> bool:
	# ADDED to the contract's read surface (reported to the lead) so the "kurucu da dahil"
	# line on the HR card reads this rule from its owner instead of re-deciding it in the
	# UI. The founder pulls the all-nighter with the product team and only with them; they
	# are never paid for it and never take its morale cost.
	return dept_id == HRConstants.DEPT_PRODUCT_DEV and is_active(dept_id)


static func pay_accrued_today() -> int:
	# Finance PULLS this at slot 5 into burn_breakdown["overtime"]. 0 while inactive, and 0
	# on any day this system did not stamp — a stamp is only ever today's.
	if _pay_stamped_day != GameState.day:
		return 0
	return _pay_today


static func preview_block(dept_id: String, block_days: int) -> Dictionary:
	# What task 3's UI prints under each block card, so it never recomputes a rule.
	# Projection for a FULL block from day 1 over TODAY's participants; deliberately
	# independent of any block already running.
	#   days            block length in days
	#   speed_bonus_pct opening speed gain, whole percent. A 14-day block drops to
	#                   HRConstants.overtime_speed_bonus(OVERTIME_DIMINISH_DAY) from day 8;
	#                   that late rate is a pure constant, so the card can read it straight
	#                   off HRConstants without any state from here.
	#   est_pay         whole block's projected money across current participants. The
	#                   founder contributes nothing (never paid) — structurally, because
	#                   participants() does not contain them.
	#   morale_cost     cumulative RAW drop one participant takes across the whole block,
	#                   summed tier by tier from HRConstants.overtime_morale_drop (never a
	#                   hardcoded total). Raw on purpose: apply_delta folds in each
	#                   person's traits and the Liderlik climate, and those differ per
	#                   person, so the card shows the ladder and the person shows the rest.
	#   bug_pct         quality cost, whole percent, 0 outside product_dev.
	var days: int = maxi(block_days, 0)
	var daily_pay: int = 0
	for emp in participants(dept_id):
		daily_pay += HRConstants.overtime_daily_pay(emp.monthly_salary)
	var morale_cost: int = 0
	for d in range(BLOCK_FIRST_DAY, days + 1):
		morale_cost += HRConstants.overtime_morale_drop(d)
	var bug_pct: int = 0
	if dept_id == HRConstants.DEPT_PRODUCT_DEV:
		bug_pct = int(round((HRConstants.OVERTIME_BUG_MULT - 1.0) * 100.0))
	return {
		"days": days,
		"speed_bonus_pct": int(round(HRConstants.overtime_speed_bonus(BLOCK_FIRST_DAY) * 100.0)),
		"est_pay": daily_pay * days,
		"morale_cost": morale_cost,
		"bug_pct": bug_pct,
	}


# --- Safety valve (design doc §7b): a CHOICE, never a silent exclusion ---

static func _maybe_enqueue_valve(block: Dictionary, emp: Character, dept_id: String) -> void:
	# NOBODY IS EVER AUTO-REMOVED from overtime. Crossing the line raises an event with two
	# real options ("Mesaiyi durdur" / "Devam et"); running the risk is the player's
	# informed decision, and that is the whole point of the valve.
	#
	# ONCE PER PERSON PER BLOCK, and the latch is held HERE, in this system's own state:
	# EventManager.enqueue bypasses _is_eligible, so the event's own one_shot field does
	# nothing, and it dedupes only on the same GameEvent INSTANCE — HREventFactory builds a
	# fresh one each call, so without this latch the same person would raise the same modal
	# every single night. Latch lives in the block record, so it clears itself when the
	# block ends, exactly matching "per block" (the same shape as B2BSalesSystem holding
	# cs_escalated on the customer record).
	#
	# Fires on exactly the condition that paints the KAÇMA RİSKİ badge — asked through
	# HRConstants.is_flight_risk so the valve and the badge can never disagree about the
	# boundary (an employee warned by a modal with no badge on their card would be a bug).
	if not HRConstants.is_flight_risk(emp.morale):
		return
	var fired: Array = block[KEY_VALVE_FIRED]
	if fired.has(emp.id):
		return
	fired.append(emp.id)
	EventManager.enqueue(HREventFactory.build_overtime_valve(emp, dept_id))


static func note_valve_continued(dept_id: String, character_id: String) -> void:
	# The player chose "Devam et" on that person's valve event (EventManager's
	# hr_overtime_continue modifier). HRMoraleSystem reads it back through
	# valve_continued_for() and adds HRConstants.RESIGN_VALVE_PENALTY to their daily
	# resignation odds. Nothing else happens: they stay on the block.
	#
	# WORKING — the memory PERSISTS FOR THE REST OF THE RUN, not just this block. The
	# person remembers being told to keep going after they said they could not; the block
	# ending does not unsay it. It is per PERSON, not per department, for the same reason.
	# It rides on GameState.flags (house precedent: B2BSalesSystem's "b2b_broke_%s"
	# credibility flag) so it survives a save/load the way run state must, and dies with
	# initialize_run's flags.clear().
	if character_id == "":
		push_warning("[HROvertimeSystem] note_valve_continued requires a character_id")
		return
	GameState.set_flag(_valve_flag(character_id), true)
	if OS.is_debug_build():
		print("[HROvertimeSystem] '%s' stays on %s ek mesai — istifa riski arttı"
			% [character_id, dept_id])


static func valve_continued_for(character_id: String) -> bool:
	# Read by HRMoraleSystem when it rolls resignation (HRConstants.resign_chance's second
	# argument). True for the rest of the run once the player has said "Devam et" to this
	# person, whether or not a block is running now.
	if character_id == "":
		return false
	return bool(GameState.get_flag(_valve_flag(character_id), false))


# --- Run reset (HRSystem.reset ← GameState.initialize_run) ---

static func reset() -> void:
	# The block records live on GameState.hr_overtime and initialize_run clears them; the
	# run-long "Devam et" memory lives in GameState.flags and dies with flags.clear(). What
	# neither of those touches is the static pay stamp below, and a fresh process would not
	# clear it either — the debug onboarding re-trigger reuses the process, so last run's
	# stamp would otherwise be pulled into burn on day 1 of the next one.
	_pay_today = 0
	_pay_stamped_day = -1
	_pay_carry = 0


# --- Internals ---

static func _end_block(dept_id: String, was_stopped: bool) -> void:
	# TODAY'S PAY STAMP IS NOT TOUCHED HERE. Finance pulls it two slots after this runs, so
	# clearing it on end would work the last night for free. It clears at the top of
	# tomorrow's daily_tick and nowhere else.
	var block: Dictionary = GameState.hr_overtime[dept_id]
	var length: int = _block_length(block)
	_reset_overtime_days(dept_id)
	GameState.hr_overtime.erase(dept_id)
	if not was_stopped:
		# The one notice this system raises. An early stop is already visible to the player
		# (they pressed it, or resolved the valve event whose badge says "Ek mesai durur"),
		# but a block reaching its final night ends on its own — and a speed bonus that
		# silently disappears is exactly the invisible state change Calibration Law 3
		# forbids. Non-modal on purpose: this must not interrupt anyone.
		EventBus.headline_added.emit(HRConstants.NOTICE_SOURCE_HR, "%s bölümünde %s süren ek mesai bitti." % [
			HRConstants.department_label(dept_id), _block_label(length),
		])
	if OS.is_debug_build():
		print("[HROvertimeSystem] %s ek mesai bitti (%s)"
			% [dept_id, "durduruldu" if was_stopped else "blok tamamlandı"])


static func _reset_overtime_days(dept_id: String) -> void:
	# Character.overtime_days means "days worked in the CURRENT block", so it is zeroed at
	# both ends of a block. Deliberately over get_employees() (not participants()): someone
	# who was on leave when the block ended still holds the count from the nights they DID
	# work, and leaving it there would carry a stale number into the next block.
	for emp in CharacterRegistry.get_employees():
		if HRConstants.department_of(emp.role) == dept_id and emp.overtime_days != 0:
			emp.overtime_days = 0


static func _block_length(block: Dictionary) -> int:
	# start() only ever stores a length from HRConstants.OVERTIME_BLOCKS; the floor is
	# defensive against a malformed record, so a corrupt 0 cannot make a block immortal.
	return maxi(int(block.get(KEY_BLOCK_DAYS, 0)), BLOCK_FIRST_DAY)


static func _block_label(length: int) -> String:
	# "3 gün" / "1 hafta" / "2 hafta" from HRConstants; a non-canon length still prints
	# readable Turkish rather than a raw number.
	return String(HRConstants.OVERTIME_BLOCK_LABELS.get(length, "%d gün" % length))


static func _valve_flag(character_id: String) -> String:
	return "%s%s" % [VALVE_FLAG_PREFIX, character_id]
