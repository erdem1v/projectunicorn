class_name HRSystem
extends RefCounted

# Pure-logic system per TECH_SPEC §8.3 — no scene dependency, no instance.
# Driven by TimeManager.daily_tick slot 3 (TECH_SPEC §8.2 ordered dispatch).
#
# HR Core: this file is the DAILY ORCHESTRATOR only. It owns the order the HR
# sub-systems run in and nothing else; every rule lives in the system that owns it.
#   HRSearchSystem     — Atlas arayışı, aday dosyaları, işe alım
#   HRMoraleSystem     — moral, izin, eşikler, istifa, pozitif event'ler
#   HROvertimeSystem   — departman bazlı ek mesai
#   HRActions          — zam / tatil / işten çıkarma (oyuncu tetikler, tick'te değil)
#   HRConstants        — her HR sayısının TEK evi
#
# THE AUTONOMOUS MORALE DRIFT IS GONE — deleted, not tuned to zero. It used to pull every
# employee ±1/day toward 50 from here. The design says morale moves only from played
# causes: ek mesai, aşırı yük, event'ler, oyuncu aksiyonları, izin dönüşü (design doc §6).
# Dead machinery invites a future reader to switch it back on, so there is nothing left to
# switch on. That is also why this task ships the RECOVERY channel (HRMoraleSystem's
# placeholder positive events) and not only the costs — morale never self-heals, so a
# one-directional loop would be a broken demo, not a hard one.
#
# Salary→Finance link: HRSystem does NOT push payroll to Finance. FinanceSystem pulls
# CharacterRegistry.get_total_monthly_salaries() AND HROvertimeSystem.pay_accrued_today()
# at the top of its own daily_tick (slot 5, two slots later). One-way pull, single source
# of truth — nobody writes a burn category from here, which is what keeps GameState's
# daily_burn from ever publishing fresh overtime against stale salaries.
#
# Frank (category "mentor") is excluded from every one of these paths because they all
# iterate get_employees()/get_active_employees(), which filter on category == "employee".
# He is never hireable, fireable, salaried as staff, morale-managed, or on overtime.


static func daily_tick() -> void:
	# Order matters, and each step reads state the previous one settled:
	#  1. Leave RETURNS first, so anything below sees the restored `active` status.
	#  2. Leave DEPARTURES next, so today's capacity/speed/overtime already excludes them.
	#  3. Search arrival — independent, but it can add an employee, so it lands before
	#     anything that iterates the roster for morale.
	#  4. Overtime — applies today's morale cost and stamps the pay Finance pulls at slot 5.
	#  5. Thresholds AFTER overtime, so a person pushed under KAÇMA RİSKİ by tonight's
	#     mesai starts their flight-risk count today rather than tomorrow.
	#  6. Trait effects and positive events last: they read the settled morale picture.
	HRMoraleSystem.tick_leave_returns()
	HRMoraleSystem.tick_leave_departures()
	HRSearchSystem.daily_tick()
	HROvertimeSystem.daily_tick()
	HRMoraleSystem.tick_thresholds()
	HRMoraleSystem.tick_trait_effects()
	HRMoraleSystem.tick_positive_events()

	if OS.is_debug_build():
		var employees: Array[Character] = CharacterRegistry.get_employees()
		var on_leave: int = employees.size() - CharacterRegistry.get_active_employees().size()
		print("[HRSystem] Daily tick — %d employees (%d izinde)" % [employees.size(), on_leave])


# --- Run reset (called from GameState.initialize_run, after the flags clear) ---

static func reset() -> void:
	# Static state in the HR sub-systems must not survive into a fresh run (the smoke
	# harness runs one case per process, but the debug onboarding re-trigger does not).
	HRMoraleSystem.reset_rng()
	HROvertimeSystem.reset()


# --- Read surface for the HR tab (task 3) and the left-rail badge ---

static func badges_for(emp: Character) -> Array[String]:
	# Badges are DERIVED, never stored: an employee can carry TÜKENİYOR and AŞIRI YÜKLÜ at
	# the same time and Character.attention_flag is a single String. Same vocabulary as
	# that field so the model does not end up with two badge concepts.
	return HRMoraleSystem.badges_for(emp)


static func attention_count() -> int:
	# What the left-rail HR badge counts: people who need looking at, plus a waiting
	# candidate file. Kept here so the UI reads one number from one place.
	var n: int = 0
	for emp in CharacterRegistry.get_employees():
		if not HRMoraleSystem.badges_for(emp).is_empty():
			n += 1
	if HRSearchSystem.has_files_ready():
		n += 1
	return n
