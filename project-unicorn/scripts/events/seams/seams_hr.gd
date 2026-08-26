class_name EvSeamsHR
extends RefCounted

# The `hr.` and `founder.` namespaces (docs/SEAM_REGISTRY.md §1, §6).
#
# Most of this file is one line per seam because Ekip rev11 already did the work: §15.3 of that
# GDD opened a named read catalogue deliberately ahead of this engine ("Katalog Ekip'in
# sorumluluğudur ve bu inşayla birlikte açılır — olay motorunu beklemez"), and
# endgame_smoke.gd:8092 contract-tests that the names exist. Where a row is a one-line binding,
# that is Ekip's foresight paying off, not this file being thin.
#
# TWO KINDS OF ROW, and the difference matters when reading it:
#
#   BINDING — the named query already exists. `hr.morale` is HRSystem.morale. If Ekip changes
#   how morale is computed, this line does not move.
#
#   WRAPPER — the value is reachable but unnamed (`Character.level` is a field). The wrapper
#   lives here so content still gets a stable name today, and it is marked so that when Ekip
#   next opens its own query the wrapper retires and the binding replaces it. Nothing
#   content-side changes on that day, which is the whole argument for naming the query rather
#   than the field.
#
# The adapter shape. Every entity seam takes an ID, never an object: an id is what History
# stores, what a frozen queue context stores, and what survives a save. Handing a Character
# around instead would put a Resource in places that must hold scalars only.

static func install() -> void:
	_install_people()
	_install_company()
	_install_founder()


static func _emp(id: String) -> Character:
	return CharacterRegistry.get_character(id)


# --- Per-person -------------------------------------------------------------

static func _install_people() -> void:
	var E := EvSeams.Kind.ENTITY

	# BINDINGS — Ekip §15.3, already named and contract-tested.
	EvSeams.register("hr.morale", E, TYPE_INT,
		func(id: String) -> int: return HRSystem.morale(_emp(id)),
		"HR", "0-100")
	EvSeams.register("hr.morale_band", E, TYPE_STRING,
		func(id: String) -> String: return HRSystem.morale_band(_emp(id)),
		"HR", "high | mid | low, at 80 / 50 / 35")
	EvSeams.register("hr.status", E, TYPE_STRING,
		func(id: String) -> String: return HRSystem.status(_emp(id)),
		"HR", "active | on_leave | training")
	EvSeams.register("hr.is_busy", E, TYPE_BOOL,
		func(id: String) -> bool: return HRSystem.is_busy(_emp(id)),
		"HR", "leave or training, plus pitch prep for the founder")
	EvSeams.register("hr.tenure_days", E, TYPE_INT,
		func(id: String) -> int: return HRSystem.tenure_days(_emp(id)),
		"HR", "days on the payroll; 0 when hire_day was never stamped")
	EvSeams.register("hr.work_hours", E, TYPE_INT,
		func(id: String) -> int: return HRSystem.work_hours(_emp(id)),
		"HR", "5-11, the resolved inheritance chain, default 8")
	EvSeams.register("hr.overtime_active", E, TYPE_BOOL,
		func(id: String) -> bool: return HRSystem.overtime_active(_emp(id)),
		"HR", "hours above 8")
	EvSeams.register("hr.short_day_active", E, TYPE_BOOL,
		func(id: String) -> bool: return HRSystem.short_day_active(_emp(id)),
		"HR", "hours below 8")
	EvSeams.register("hr.job_count", E, TYPE_INT,
		func(id: String) -> int: return HRSystem.job_count(_emp(id)),
		"HR", "0, 1 or 2")
	EvSeams.register("hr.is_overloaded", E, TYPE_BOOL,
		func(id: String) -> bool: return HRSystem.is_overloaded(_emp(id)),
		"HR", "more than one job")
	EvSeams.register("hr.is_idle", E, TYPE_BOOL,
		func(id: String) -> bool: return HRSystem.is_idle(_emp(id)),
		"HR", "an employee with no job at all")
	EvSeams.register("hr.account_count", E, TYPE_INT,
		func(id: String) -> int: return HRSystem.accounts_of(_emp(id)).size(),
		"HR", "how many accounts this person carries")

	# WRAPPERS — reachable, unnamed. Each retires when Ekip names it.
	EvSeams.register("hr.level", E, TYPE_INT,
		func(id: String) -> int:
			var c: Character = _emp(id)
			return c.level if c != null else 0,
		"HR", "WRAPPER over Character.level. 0 = junior, 1 = mid, 2 = senior")
	EvSeams.register("hr.salary", E, TYPE_INT,
		func(id: String) -> int:
			var c: Character = _emp(id)
			return c.monthly_salary if c != null else 0,
		"HR", "WRAPPER over Character.monthly_salary, USD/month")
	EvSeams.register("hr.experience_ratio", E, TYPE_FLOAT,
		func(id: String) -> float:
			var c: Character = _emp(id)
			return CharacterRegistry.experience_ratio(c) if c != null else 0.0,
		"HR", "0.0-1.0 toward the next threshold")
	EvSeams.register("hr.flight_risk", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Character = _emp(id)
			return c != null and HRConstants.is_flight_risk(c.morale),
		"HR", "WRAPPER: morale under 35")
	EvSeams.register("hr.raise_cooldown_left", E, TYPE_INT,
		func(id: String) -> int:
			var c: Character = _emp(id)
			return HRActions.raise_cooldown_left(c) if c != null else 0,
		"HR", "days until a raise is allowed again; 0 means now")

	# hr.salary_band_position — the seam the GDD's own §9.7 table lists as YOK.
	#
	# It is the retention modifier "maaşı bandın altında", and without it that hover line
	# cannot be written at all (I7: no seam, no modifier). Both halves exist —
	# HRConstants.salary_band_for_level and Character.monthly_salary — but nothing in
	# production compares a sitting employee to the band, and hr_actions.gd:140-143 documents
	# the OPPOSITE rule on purpose: a promotion raises by the chosen percent and does not
	# reseat the salary into the new band, so promoted staff drift below it by design.
	#
	# So the drift is real, intended, and unread. This wrapper reads it. Filed to Ekip as
	# hr.salary_vs_band; when that lands, this retires.
	#
	# Returns the position in the band as 0.0 (at the floor) to 1.0 (at the ceiling), and
	# BELOW ZERO when the salary has fallen under the band entirely — which is the case the
	# modifier line is actually about.
	EvSeams.register("hr.salary_band_position", E, TYPE_FLOAT,
		func(id: String) -> float:
			var c: Character = _emp(id)
			if c == null:
				return 0.0
			var band: Array = HRConstants.salary_band_for_level(c.role, c.level)
			if band.size() != 2:
				return 0.0
			var low: float = float(band[0])
			var high: float = float(band[1])
			if high <= low:
				return 0.0
			return (float(c.monthly_salary) - low) / (high - low),
		"HR", "WRAPPER, filed as YOK: <0 under the band, 0..1 inside it")


# --- Company-wide -----------------------------------------------------------

static func _install_company() -> void:
	var G := EvSeams.Kind.GLOBAL

	EvSeams.register("hr.headcount", G, TYPE_INT,
		func() -> int: return HRSystem.headcount(),
		"HR", "active employees; excludes the founder and the mentor by construction")
	EvSeams.register("hr.morale_avg", G, TYPE_FLOAT,
		func() -> float: return HRMoraleSystem.average_morale(),
		"HR", "0.0-100.0, and 0.0 when there are no employees at all")
	EvSeams.register("hr.idle_count", G, TYPE_INT,
		func() -> int: return HRSystem.idle_count(),
		"HR", "employees with no job")
	EvSeams.register("hr.unstaffed_job_count", G, TYPE_INT,
		func() -> int: return HRSystem.unstaffed_jobs().size(),
		"HR", "jobs nobody is assigned to")
	EvSeams.register("hr.attention_count", G, TYPE_INT,
		func() -> int: return HRSystem.attention_count(),
		"HR", "what the rail badge counts")
	EvSeams.register("hr.payroll_monthly", G, TYPE_INT,
		func() -> int: return CharacterRegistry.get_total_monthly_salaries(),
		"HR", "not status-filtered: leave is paid")
	EvSeams.register("hr.work_hours_company", G, TYPE_INT,
		func() -> int: return int(HRSystem.work_hours_company().get("hours", 8)),
		"HR", "the company base, 5-11")
	EvSeams.register("hr.candidates_ready", G, TYPE_BOOL,
		func() -> bool: return HRSearchSystem.has_files_ready(),
		"HR", "the Atlas search has delivered")


# --- Founder ----------------------------------------------------------------

static func _install_founder() -> void:
	var G := EvSeams.Kind.GLOBAL

	# The founder is a Character with category == "founder" (game_state.gd:948-1006), not a
	# separate class — but he is a separate SCOPE TYPE (§4.3), and the data model already
	# enforces that: CharacterRegistry.get_employees() filters him out, so hr.headcount cannot
	# count him and the employee selector cannot return him. The rule holds without the engine
	# doing anything.
	EvSeams.register("founder.charisma", G, TYPE_INT,
		func() -> int: return GameState.get_founder_skill(FounderConstants.SKILL_CHARISMA),
		"HR", "0-10 on the shared ruler; pitch and scandal outcomes read it")
	EvSeams.register("founder.leadership", G, TYPE_INT,
		func() -> int: return GameState.get_founder_skill("leadership"),
		"HR", "0-10; the morale ceiling and the team output multiplier")
	EvSeams.register("founder.task_state", G, TYPE_STRING,
		func() -> String: return HRSystem.founder_task_state(),
		"HR", "build | sales | support | research | pitch_prep | training | idle")
	EvSeams.register("founder.is_busy", G, TYPE_BOOL,
		func() -> bool: return HRSystem.is_busy(CharacterRegistry.get_founder()),
		"HR", "assigned, in training, or preparing a pitch")
	EvSeams.register("founder.origin", G, TYPE_STRING,
		func() -> String: return GameState.origin,
		"HR", "self_made | heir | corporate_refugee")
	EvSeams.register("founder.equity_pct", G, TYPE_INT,
		func() -> int: return 100 - GameState.get_investor_equity_pct(),
		"HR", "WRAPPER: the complement of the investor total")
