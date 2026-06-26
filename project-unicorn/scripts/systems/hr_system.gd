class_name HRSystem
extends RefCounted

# Pure-logic system per TECH_SPEC §8.3 — no scene dependency, no instance.
# Driven by TimeManager.daily_tick slot 3 (TECH_SPEC §8.2 ordered dispatch).
#
# Responsibilities (this turn — HR mini-spec §4):
#   - Iterate employees; apply baseline morale drift toward 50 (±1/day).
#
# The rich morale drivers from PROJECT_SPEC §5.2 (workload, comp fairness,
# ship success, scandal exposure, mentor relationship, peer dynamics) are
# additive signed deltas that future systems will apply BEFORE the clamp.
# The drift here is intentionally tiny so those drivers will dominate.
#
# Salary→Finance link: HRSystem does NOT push payroll to Finance.
# FinanceSystem pulls from CharacterRegistry.get_total_monthly_salaries() at
# the top of its own daily_tick (slot 5, two slots later). One-way pull,
# single source of truth — Sales (slot 4) can slot in between without
# anyone changing the wiring.


static func daily_tick() -> void:
	var employees: Array[Character] = CharacterRegistry.get_employees()
	for emp in employees:
		_baseline_morale_tick(emp)

	if OS.is_debug_build():
		print("[HRSystem] Daily tick — %d employees" % employees.size())


static func _baseline_morale_tick(emp: Character) -> void:
	# Fixed-point guard: don't oscillate at 49↔50 or 51↔50.
	if absi(emp.morale - 50) <= 1:
		return
	var delta: int = 1 if emp.morale < 50 else -1
	CharacterRegistry.set_morale(emp.id, emp.morale + delta)
