extends Node

# Character registry per TECH_SPEC §6.1.
# Single source of truth for all characters — employees, mentor, NPCs — and
# their relationships, traits, morale, and compensation.
#
# Mutations route through registry methods. State changes emit on EventBus
# (TECH_SPEC §13) so scenes (RightPanel, future HR Tab) update themselves
# without the registry knowing who is listening.
#
# Tick interaction (TECH_SPEC §8.2):
#   - HRSystem.daily_tick (slot 3) reads employees and writes morale via set_morale
#   - FinanceSystem.daily_tick (slot 5) pulls get_total_monthly_salaries
#   The pull pattern keeps systems decoupled — Sales (slot 4) will slot in
#   between without changing any wiring.
#
# Naming caution: get_character (not get) — `Object.get(prop)` is reserved
# and shadowing it produces subtle bugs (TECH_SPEC §7 naming-collision note).

# Manual toggle for deliberate registry integration testing. Off in normal runs
# so a fresh game starts with zero employees and zero salary burn (Economic
# Outcome Principle, PROJECT_SPEC §10). With this off, the mentor is still
# provisioned by ensure_mentor() during GameState.initialize_run — no regression
# to onboarding or the RightPanel mentor section. Flip to true to restore the
# Debug Engineer A / Debug Designer B placeholders for HR/Finance pipeline tests.
const DEBUG_SEED := false

var _characters: Dictionary = {}  # id (String) -> Character


func _ready() -> void:
	if DEBUG_SEED:
		_seed_debug_characters()


# --- Read API ---

func get_character(id: String) -> Character:
	return _characters.get(id, null)


func get_all() -> Array[Character]:
	var out: Array[Character] = []
	for c in _characters.values():
		out.append(c)
	return out


func get_employees() -> Array[Character]:
	# EVERY employee, on leave or not. Payroll, morale and all display surfaces read this
	# (an on-leave employee is genuinely still on the team). Anything that measures WORK
	# reads get_active_employees() instead — see its header for the decision list.
	var out: Array[Character] = []
	for c in _characters.values():
		if c.category == "employee":
			out.append(c)
	return out


func get_active_employees() -> Array[Character]:
	# Employees currently AT work (status active). Sibling of get_employees() rather than a
	# filter inside it, because an on-leave employee is genuinely present for payroll and
	# genuinely absent for capacity — one "correct" list would be wrong half the time.
	#
	# EXCLUDES on-leave: build capacity (ProductSystem.capacity_total), team speed
	#   (_speed_for_lead), SORUMLU selection (creation_flow), CS churn dampen
	#   (B2BSalesSystem), overtime participation (HROvertimeSystem).
	# INCLUDES on-leave (i.e. uses get_employees): payroll (paid leave — deliberate),
	#   the morale machine (leave RESTORES morale), HR badge, team size, run ledger,
	#   endings data, founder equity, cap table, and the VC team-domain checks (a company
	#   with one developer on holiday has not become a solo founder).
	var out: Array[Character] = []
	for c in _characters.values():
		if c.category == "employee" and c.status == HRConstants.STATUS_ACTIVE:
			out.append(c)
	return out


func get_customer_reps() -> Array[Character]:
	# Müşteri Temsilcisi — a hired employee type (category "employee") so they count
	# toward payroll + run_hires + the morale machine, distinguished by role (not category).
	var out: Array[Character] = []
	for c in _characters.values():
		if c.category == "employee" and c.role == HRConstants.ROLE_CUSTOMER_REP:
			out.append(c)
	return out


func count_customer_reps() -> int:
	return get_customer_reps().size()


func count_developers() -> int:
	# ALL developers regardless of leave — the narrative/headcount lens (VC team domain:
	# "does this company have engineers at all"). Capacity uses the active count below.
	var n: int = 0
	for c in get_employees():
		if c.role == HRConstants.ROLE_DEVELOPER:
			n += 1
	return n


func count_active_in_department(dept_id: String) -> int:
	# Everyone AT WORK in a main department (HRConstants.department_of). The capacity pool
	# reads this rather than the developer count, because a tester or a designer is just as
	# occupied by the build as a developer is.
	var n: int = 0
	for c in get_active_employees():
		if HRConstants.department_of(c.role) == dept_id:
			n += 1
	return n


func count_active_developers() -> int:
	# Kapasite havuzu (ProductSystem.capacity_total): kurucu + çalışan yazılımcı sayısı.
	# İzindeki yazılımcı kapasiteye SAYILMAZ (izinde kapasite dışıdır — design doc §8).
	var n: int = 0
	for c in get_active_employees():
		if c.role == HRConstants.ROLE_DEVELOPER:
			n += 1
	return n


func get_in_department(dept_id: String) -> Array[Character]:
	# Roster of a main department, ON-LEAVE INCLUDED — the DISPLAY lens, sibling of
	# count_active_in_department() above, which is the WORK lens and excludes leave.
	# The distinction is load-bearing for the Ekip page: a department whose only member is on
	# holiday must render that person's card, not an "Henüz kimse yok" empty row.
	# Insertion-ordered (hire order) because _characters is a Dictionary — deterministic.
	var out: Array[Character] = []
	for c in get_employees():
		if HRConstants.department_of(c.role) == dept_id:
			out.append(c)
	return out


func get_in_section(section_id: String) -> Array[Character]:
	# Same display lens, one level down (Tasarım / Geliştirme / Test). Single-level departments
	# have no sections, so this is never called for Satış or Müşteri.
	var out: Array[Character] = []
	for c in get_employees():
		if HRConstants.section_of(c.role) == section_id:
			out.append(c)
	return out


func count_employees() -> int:
	return get_employees().size()


func count_on_leave() -> int:
	# The Ekip header's "N izinde". Was previously computed inline inside a debug print in
	# HRSystem.daily_tick, i.e. not available to anything that had to render it.
	var n: int = 0
	for c in get_employees():
		if c.status == HRConstants.STATUS_ON_LEAVE:
			n += 1
	return n


func get_mentor() -> Character:
	for c in _characters.values():
		if c.category == "mentor":
			return c
	return null


func get_founder() -> Character:
	# Player avatar — written once by GameState.initialize_run on onboarding
	# completion. Null before that (registry empty / debug-seed only).
	for c in _characters.values():
		if c.category == "founder":
			return c
	return null


# --- System seed (idempotent) ---

func ensure_mentor() -> void:
	# Called from GameState.initialize_run. Idempotent: _seed_debug_characters
	# already places Frank from _ready, but this defensive call keeps the
	# state-write seam self-contained — if the debug seed is ever removed
	# the mentor still gets created during onboarding completion.
	# Direct insert (no add()) so character_added does not fire for the
	# system-seeded mentor; UI fixtures read get_mentor() at _ready.
	if get_mentor() != null:
		return
	var m := Character.new()
	m.id = "char_mentor_frank"
	m.character_name = "Frank Köseoğlu"
	# Typed id whose label is the byte-exact "Operating Partner" already on screen via
	# MentorIntroModal and the three live JSON events that speak as Frank.
	m.role = HRConstants.ROLE_MENTOR
	m.category = "mentor"
	m.monthly_salary = 0
	m.equity_pct = 0.0
	m.morale = 50
	_characters[m.id] = m


# --- Queries (consumed by FinanceSystem and future systems) ---

func get_total_monthly_salaries() -> int:
	# Sum payroll across employees only (mentor/NPC excluded).
	# DELIBERATELY NOT status-filtered: annual leave is PAID leave (design doc §8 /
	# HR Core consumer table), so an on-leave employee keeps drawing salary. The cost of
	# leave is lost capacity, not saved payroll.
	var total: int = 0
	for c in _characters.values():
		if c.category == "employee":
			total += c.monthly_salary
	return total


# --- Write API (public — for future hire/fire flow) ---

func add(character: Character) -> void:
	if character == null or character.id == "":
		push_warning("[CharacterRegistry] add() called with null or missing id")
		return
	if _characters.has(character.id):
		push_warning("[CharacterRegistry] add() id collision: %s" % character.id)
		return
	_validate_shape(character)
	if character.category == "employee":
		# Employment stamps land HERE, not in the hire flow, so an event-spawned hire
		# (add_character modifier) gets them too. hire_ordinal = how many employees were
		# hired before this one, which is what spreads leave months apart.
		var hire_ordinal: int = GameState.run_hires
		# Stamped as TODAY here. HRSearchSystem.hire() deliberately re-stamps this to
		# GameState.day + 1 immediately after add() returns, because the design says a hire
		# starts the NEXT day at full performance (no ramp) — do not "fix" that away.
		character.hire_day = GameState.day
		if character.leave_month <= 0:
			var hire_month: int = int(GameState.get_date_dict().month)
			character.leave_month = HRConstants.leave_month_for(hire_month, hire_ordinal)
		# Run counter seam (Spec 3 §3): counted HERE, not at the add_character
		# event modifier, so the future hire flow counts automatically. Founder
		# (category "founder") is excluded; mentor never passes through add().
		GameState.run_hires += 1
	_characters[character.id] = character
	EventBus.character_added.emit(character.id)


func _validate_shape(character: Character) -> void:
	# KEY LOCK: employees and the founder store different things in the same role_stats
	# dict, and get_founder_skill returns 0 for an unknown key without complaining — so a
	# founder accidentally given employee axes (or an employee given founder skills) would
	# be silent. Scream instead. NON-BLOCKING on purpose (mirrors _build_founder's
	# validators): the character is still added, the log carries the defect.
	if character.category == "employee":
		if not HRConstants.is_employee_role(character.role):
			push_error("[CharacterRegistry] employee '%s' has non-employee role '%s' — see HRConstants.EMPLOYEE_ROLES"
				% [character.id, character.role])
		if not HRConstants.validate_employee_axes(character.role_stats):
			push_error("[CharacterRegistry] employee '%s' role_stats must hold EXACTLY %s on 0-%d: %s"
				% [character.id, str(HRConstants.AXES), HRConstants.AXIS_MAX, str(character.role_stats)])
		if not HRConstants.validate_employee_traits(character.traits):
			push_error("[CharacterRegistry] employee '%s' traits failed the employee trait formula: %s"
				% [character.id, str(character.traits)])
	elif character.category == "founder":
		var keys: Array = character.role_stats.keys()
		if keys.size() != FounderConstants.SKILLS.size():
			push_error("[CharacterRegistry] founder role_stats must hold EXACTLY the %d canonical skills: %s"
				% [FounderConstants.SKILLS.size(), str(keys)])
		for skill_key in FounderConstants.SKILLS:
			if not character.role_stats.has(skill_key):
				push_error("[CharacterRegistry] founder role_stats missing skill '%s'" % skill_key)


func remove(id: String) -> void:
	if not _characters.has(id):
		return
	# Run counter seam (mirrors add()'s employee guard): read category BEFORE erase.
	# Reads 0 today — no fire/quit flow calls remove() with an employee yet; the seam
	# is here so a future departure flow counts automatically.
	var c: Character = _characters[id]
	if c != null and c.category == "employee":
		GameState.run_departures += 1
	_characters.erase(id)
	EventBus.character_removed.emit(id)


# --- Debug reset (onboarding re-trigger) ---
# Clears the roster so a re-triggered initialize_run re-provisions mentor + a fresh
# founder without the char_founder id-collision that add() would otherwise drop.
# Direct clear (no character_removed emits) — the shell is torn down alongside, so
# no listeners remain; mirrors ensure_mentor/_seed inserting directly without signals.
func reset() -> void:
	_characters.clear()


func set_salary(id: String, value: int) -> void:
	# Compensation write seam (HR Core: the ZAM YAP action). Exists because the
	# WRITE-THROUGH LAW says build the seam rather than poke the field "just this once" —
	# HRActions.apply_raise routes through here.
	# No signal: Finance PULLS payroll every daily tick (get_total_monthly_salaries), so
	# burn already follows without one. When the HR tab needs a live card repaint, the
	# signal belongs here as `EventBus.employee_salary_changed(id, value)` — deliberately
	# not declared yet rather than shipped with no listener.
	var c: Character = _characters.get(id, null)
	if c == null:
		push_warning("[CharacterRegistry] set_salary on unknown id: %s" % id)
		return
	c.monthly_salary = max(value, 0)


func set_status(id: String, value: String) -> void:
	# Employment status seam (HR Core: annual leave + manual vacation). Same reasoning as
	# set_salary — capacity, team speed, the SORUMLU list, CS dampen and overtime all read
	# `status`, so it must not be written from four different files.
	var c: Character = _characters.get(id, null)
	if c == null:
		push_warning("[CharacterRegistry] set_status on unknown id: %s" % id)
		return
	if value != HRConstants.STATUS_ACTIVE and value != HRConstants.STATUS_ON_LEAVE:
		push_error("[CharacterRegistry] unknown employee status '%s' for %s" % [value, id])
		return
	c.status = value


func set_morale(id: String, value: int) -> void:
	# Placeholder clamp range — spec leaves bounds undefined; 0..100 mirrors
	# brand (game_state.gd) and is the natural choice. See PROJECT_SPEC §9
	# if the designer later locks formal morale bounds.
	var c: Character = _characters.get(id, null)
	if c == null:
		push_warning("[CharacterRegistry] set_morale on unknown id: %s" % id)
		return
	var clamped: int = clampi(value, 0, 100)
	if c.morale == clamped:
		return  # No-op: don't emit a redundant signal
	c.morale = clamped
	EventBus.morale_changed.emit(id, clamped)


# --- Debug seed (writes directly to _characters; does NOT call add() so no
#     phantom character_added signals fire on startup) ---

func _seed_debug_characters() -> void:
	# DEBUG SEED — Frank Köseoğlu name placeholder originated in the RightPanel
	# turn. Not in PROJECT_SPEC; canonical mentor identity is a Content Phase
	# decision. Keep marker so future agents know this is unblessed.
	var mentor := Character.new()
	mentor.id = "char_mentor_frank"
	mentor.character_name = "Frank Köseoğlu"
	# Was "Mentor" here and "Operating Partner" in ensure_mentor — two strings for one
	# role. Typing collapses the divergence onto the id whose label is the visible one.
	mentor.role = HRConstants.ROLE_MENTOR
	mentor.category = "mentor"
	mentor.monthly_salary = 0
	_characters[mentor.id] = mentor

	# DEBUG SEED — placeholder employees so HR + Finance integration can be
	# verified. Remove when data/characters/employees.json + hire flow exist.
	# Names use explicit DEBUG markers to prevent accidental canonization.
	# Morale chosen either side of the burnout threshold so the badge derivation is
	# visibly exercised during dev verification.
	# pace 4 is the ANCHOR value: at EMPLOYEE_SPEED_COEF 0.25 it contributes exactly
	# 1.0 efor/day, which is what a pre-Coupling assist engineer contributed.
	var eng := Character.new()
	eng.id = "char_debug_eng_a"
	eng.character_name = "Debug Engineer A"
	eng.role = HRConstants.ROLE_DEVELOPER
	eng.category = "employee"
	eng.monthly_salary = 6000
	eng.morale = 60
	eng.role_stats = {"expertise": 5, "pace": 4, "rapport": 5}
	eng.traits = ["pressure_proof"]
	eng.hire_day = 1
	eng.leave_month = HRConstants.leave_month_for(1, 0)
	_characters[eng.id] = eng

	var des := Character.new()
	des.id = "char_debug_des_b"
	des.character_name = "Debug Designer B"
	des.role = HRConstants.ROLE_DESIGNER
	des.category = "employee"
	des.monthly_salary = 5000
	des.morale = 40
	des.role_stats = {"expertise": 5, "pace": 4, "rapport": 4}
	des.traits = ["warms_up_fast", "glass_heart"]
	des.hire_day = 1
	des.leave_month = HRConstants.leave_month_for(1, 1)
	_characters[des.id] = des
