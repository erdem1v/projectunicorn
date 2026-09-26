class_name HRSearchSystem
extends RefCounted

# Atlas Seçme & Yerleştirme — the hiring search (§10).
#
# Ticked DAILY from HRSystem.daily_tick, after the two leave steps and before the morale steps,
# because delivering files can add an employee and everything below iterates that roster.
#
# Owns GameState.hr_search — the state machine idle → searching → files_ready → (hire | dismiss)
# → idle, one search at a time — plus the stored generator seed and the hire itself. Every
# number comes from HRConstants.
#
# WRITE-THROUGH LAW: cash moves ONLY through FinanceSystem.apply_one_time_cost (the commission);
# the employee is created ONLY through CharacterRegistry.add, which stamps hire_day/leave_month,
# key-locks role/axes/traits and counts run_hires; the arrival reaches the player ONLY as
# EventBus.headline_added. Payroll is never pushed — FinanceSystem PULLS it, so a hire changes
# burn by existing in the registry.
#
# ARRIVAL IS NOT A MODAL. Candidate files land as one ticker line and a badge
# (HRSystem.attention_count reads has_files_ready); the files wait for the player.
#
# THE SEARCH IS FREE (§10). "Aday araması Atlas Recruitment modalinden yürür ve ücretsizdir.
# ... Retainer YOKTUR; tek ücret komisyondur." Commissioning, cancelling and dismissing move
# zero cash; the ONLY charge is the commission, on the hire. It has no affordability gate: it
# can push cash negative through the ordinary bankruptcy channel, and preview_hire carries the
# warning instead of a disabled button.


# GameState.hr_search keys. Named so a typo in a write cannot silently diverge from a read.
const KEY_STATE := "state"
const KEY_ROLE := "role"
## §3 SEVİYE. Eski kayıtlardaki arama "band" taşıyabilir; current_level ikisini de tanır.
const KEY_LEVEL := "level"
const KEY_SEED := "seed"
const KEY_STARTED_DAY := "started_day"
const KEY_ARRIVAL_DAY := "arrival_day"
const KEY_FILES := "files"


static func daily_tick() -> void:
	if get_state() != HRConstants.SEARCH_SEARCHING:
		return
	# `<` rather than `!=`: if a day ever passes without this tick running, the files still land
	# on the next one instead of the search hanging forever.
	if GameState.day < int(GameState.hr_search.get(KEY_ARRIVAL_DAY, 0)):
		return
	_deliver_files()


# --- State reads ---

static func get_state() -> String:
	# An empty dictionary IS idle, which is what makes initialize_run's hr_search.clear() a
	# complete reset.
	return String(GameState.hr_search.get(KEY_STATE, HRConstants.SEARCH_IDLE))


static func has_files_ready() -> bool:
	return get_state() == HRConstants.SEARCH_FILES_READY


static func can_start() -> bool:
	# One search at a time. Deliberately NOT an affordability check (§10 — the search is free).
	return get_state() == HRConstants.SEARCH_IDLE


static func get_files() -> Array:
	# The live array: files are read-only display data. Empty while `searching` — the files do
	# not exist until the arrival tick generates them from the stored seed.
	var stored: Variant = GameState.hr_search.get(KEY_FILES, [])
	return stored as Array if stored is Array else []


static func days_waiting() -> int:
	# Counted from the day the player commissioned the search, in both `searching` and
	# `files_ready`. 0 when idle.
	if get_state() == HRConstants.SEARCH_IDLE:
		return 0
	return maxi(0, GameState.day - int(GameState.hr_search.get(KEY_STARTED_DAY, GameState.day)))


static func current_role() -> String:
	return String(GameState.hr_search.get(KEY_ROLE, ""))


static func current_level() -> int:
	if GameState.hr_search.has(KEY_LEVEL):
		return clampi(int(GameState.hr_search[KEY_LEVEL]),
			HRConstants.LEVEL_JUNIOR, HRConstants.LEVEL_SENIOR)
	# Eski kaydın "band" dizeleri seviye sırasıyla aynı sıradadır (junior · mid · senior).
	# Sessizce Junior saymak yanlış adayları getirirdi.
	var legacy: int = ["junior", "mid", "senior"].find(String(GameState.hr_search.get("band", "")))
	return legacy if legacy >= 0 else HRConstants.LEVEL_MID


# --- Commissioning a search ---

static func start_search(role_id: String, level: int) -> bool:
	if not can_start():
		push_warning("[HRSearchSystem] start_search while state is '%s' — one search at a time" % get_state())
		return false
	if not HRConstants.is_employee_role(role_id):
		push_warning("[HRSearchSystem] start_search with non-employee role '%s'" % role_id)
		return false
	# Engine-side back-stop for the Atlas's visual lock.
	if not HRConstants.is_role_hireable(role_id):
		push_warning("[HRSearchSystem] start_search for locked role '%s'" % role_id)
		return false
	if not HRConstants.is_level(level):
		push_warning("[HRSearchSystem] start_search with unknown level %d" % level)
		return false

	# The SEED is stored, not the files. seed_for() reads GameState.day, which has moved on by
	# the time the files land, and a save/load mid-search must not reshuffle the table.
	# §10: "bir çalışan ayrıldığında ya da bir iş tıkandığında oyuncu boşluğu O GÜN kapatamaz,
	# arada geçen haftayı yönetmek zorundadır."
	GameState.hr_search = {
		KEY_STATE: HRConstants.SEARCH_SEARCHING,
		KEY_ROLE: role_id,
		KEY_LEVEL: level,
		KEY_SEED: HRCandidateGenerator.seed_for(role_id, level),
		KEY_STARTED_DAY: GameState.day,
		KEY_ARRIVAL_DAY: GameState.day + HRConstants.SEARCH_ARRIVAL_DAYS,
		KEY_FILES: [],
	}
	return true


## İptal: nothing to refund (§10). Only legal while Atlas is still looking; once the files are
## on the table the way out is dismiss_files().
static func cancel_search() -> bool:
	if get_state() != HRConstants.SEARCH_SEARCHING:
		return false
	GameState.hr_search.clear()
	return true


## Beğenmedin: no charge. A throwaway search costs the week it took (§10).
static func dismiss_files() -> bool:
	if get_state() != HRConstants.SEARCH_FILES_READY:
		return false
	GameState.hr_search.clear()
	return true


# --- The hire ---

static func hire(candidate_index: int) -> Character:
	if get_state() != HRConstants.SEARCH_FILES_READY:
		push_warning("[HRSearchSystem] hire() with no files on the table (state '%s')" % get_state())
		return null
	var files: Array = get_files()
	if candidate_index < 0 or candidate_index >= files.size():
		push_warning("[HRSearchSystem] hire() index %d outside the %d file(s) on the table" % [candidate_index, files.size()])
		return null
	var file: Dictionary = files[candidate_index]
	var role_id: String = String(file.get("role", ""))
	var salary: int = int(file.get("salary", 0))

	var emp := Character.new()
	# run_hires increments inside CharacterRegistry.add, so no two hires collide even on one day.
	emp.id = "char_emp_%d_%d" % [GameState.day, GameState.run_hires]
	emp.character_name = String(file.get("name", ""))
	emp.role = role_id
	emp.category = "employee"
	emp.monthly_salary = salary
	# §3 SEVİYE KİŞİDE SAKLANIR; unvan ondan TÜRETİLİR (HRConstants.job_title).
	emp.level = clampi(int(file.get("level", HRConstants.level_for_salary(role_id, salary))),
		HRConstants.LEVEL_JUNIOR, HRConstants.LEVEL_SENIOR)
	# §9.1 "maaş hiçbir zaman DÜŞÜRÜLMEZ" — tabanı işe alım maaşıdır.
	emp.salary_floor = salary
	emp.morale = HRConstants.MORALE_HIRE_START
	emp.status = HRConstants.STATUS_ACTIVE
	# Copies the Character owns: the file's own containers die with the search.
	var axes: Dictionary = file.get("axes", {})
	for skill_key in HRConstants.EMPLOYEE_SKILL_KEYS:
		emp.role_stats[String(skill_key)] = clampi(
			int(axes.get(skill_key, HRConstants.AREA_MIN)), HRConstants.AREA_MIN, HRConstants.AREA_MAX)
	for trait_id in file.get("traits", []):
		emp.traits.append(String(trait_id))

	CharacterRegistry.add(emp)
	if CharacterRegistry.get_character(emp.id) == null:
		# add() refuses an id collision and returns void, so the insert is verified before any
		# money moves: a rejected hire must not charge a commission.
		push_error("[HRSearchSystem] CharacterRegistry.add rejected '%s' — no charge, no state change" % emp.id)
		return null
	# A hire starts the NEXT day at full performance (no ramp). add() stamps hire_day = today,
	# so the correction must come after it.
	emp.hire_day = GameState.day + 1
	FinanceSystem.apply_one_time_cost(HRConstants.commission_for(salary), "hire")
	GameState.hr_search.clear()
	return emp


# --- Previews (what the UI prints BEFORE the player commits) ---

static func preview_search(role_id: String, level: int) -> Dictionary:
	# §10 THE SEARCH IS FREE, so there is no cash question here: the economic reading belongs
	# to preview_hire.
	var warnings: Array[String] = []
	if not can_start():
		warnings.append(TranslationServer.translate("HR_WARN_SEARCH_OPEN"))
	return {
		"can_start": can_start(),
		# §3's derived unvan, so the player reads "Kıdemli Yazılım Mühendisi" rather than a role
		# and a level they have to combine. job_title push_errors on an unknown role.
		"job_title": HRConstants.job_title(role_id, level) if HRConstants.is_employee_role(role_id) else role_id,
		"warnings": warnings,
	}


static func preview_hire(candidate_index: int) -> Dictionary:
	# Every key is present even for an invalid index, so the UI never guards a missing key.
	# runway_before/runway_after can be INF (non-negative net flow). Both go through the same
	# maxf so the strip never compares a raw "before" with a floored "after".
	var runway_before: float = maxf(0.0, GameState.get_runway_months())
	var warnings: Array[String] = []
	var out: Dictionary = {
		"job_title": "",
		"commission": 0,
		"runway_before": runway_before,
		"runway_after": runway_before,
		"affordable": true,
		"warnings": warnings,
	}
	var files: Array = get_files()
	if candidate_index < 0 or candidate_index >= files.size():
		return out

	var file: Dictionary = files[candidate_index]
	var role_id: String = String(file.get("role", ""))
	var salary: int = int(file.get("salary", 0))
	var commission: int = HRConstants.commission_for(salary)
	# FinanceSystem PULLS the whole payroll and converts it in ONE rounding pass, so tomorrow's
	# burn is today's published total with the salary slice swapped out. Adding this salary
	# rounded on its own would sit a dollar off, and would double-count a hire made today (the
	# registry already holds that salary, the published burn does not yet).
	var payroll_after: int = CharacterRegistry.get_total_monthly_salaries() + salary
	var salaries_now: int = int(FinanceSystem.burn_breakdown.get("salaries", 0))
	var burn_after: int = GameState.daily_burn - salaries_now + FinanceSystem.daily_salary_for(payroll_after)
	var net_after: int = GameState.get_daily_revenue() - burn_after
	var cash_after: int = GameState.cash - commission
	if GameState.cash < commission:
		warnings.append(TranslationServer.translate("HR_WARN_COMMISSION_CASH"))
	if GameState.get_net_daily_flow() >= 0 and net_after < 0:
		warnings.append(TranslationServer.translate("HR_WARN_SALARY_CASHFLOW"))

	var level: int = clampi(int(file.get("level", HRConstants.LEVEL_JUNIOR)),
		HRConstants.LEVEL_JUNIOR, HRConstants.LEVEL_SENIOR)
	# §10.3 aday kartı "ad, UNVAN, rol açıklaması" istiyor — unvan türetilir (§3).
	out["job_title"] = HRConstants.job_title(role_id, level) if HRConstants.is_employee_role(role_id) else role_id
	out["commission"] = commission
	# An empty account reads 0.0 rather than a negative month count; maxf leaves INF alone.
	out["runway_after"] = maxf(0.0, GameState.runway_months_for(cash_after, net_after))
	out["affordable"] = GameState.cash >= commission
	return out


# --- Internals ---

static func _deliver_files() -> void:
	var role_id: String = String(GameState.hr_search.get(KEY_ROLE, ""))
	var files: Array = HRCandidateGenerator.generate(role_id, current_level(),
		int(GameState.hr_search.get(KEY_SEED, 0)))
	GameState.hr_search[KEY_FILES] = files
	GameState.hr_search[KEY_STATE] = HRConstants.SEARCH_FILES_READY
	EventBus.headline_added.emit(
		HRConstants.search_agency_name(),
		TranslationServer.translate("HR_NEWS_FILES_READY").format({"role": HRConstants.role_label(role_id), "n": files.size()})
	)
