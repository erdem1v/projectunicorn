class_name HRSearchSystem
extends RefCounted

# Atlas Seçme & Yerleştirme — the hiring search (HR design doc §2/§3).
#
# Dispatch slot: ticked DAILY from HRSystem.daily_tick (slot 3), third of that file's seven HR
# steps. It runs after the two leave steps (a returning employee must already read `active`
# before anything counts the roster) and before the overtime and morale steps, because
# delivering files can add an employee and everything below iterates that roster.
#
# Owns: GameState.hr_search — the whole state machine idle → searching → files_ready →
# (hire | dismiss) → idle, one search at a time — plus the arrival day, the stored generator
# seed, the two Atlas fees and the hire itself. Owns no tunable: every number comes from
# HRConstants, and the mixer consts below are arithmetic, not balance.
#
# WRITE-THROUGH LAW: cash moves ONLY through FinanceSystem.apply_one_time_cost (the retainer
# and the commission, both under HRConstants.COST_LABEL_HIRE); the employee is created ONLY
# through CharacterRegistry.add, which stamps hire_day/leave_month, key-locks role/axes/traits
# and counts run_hires; the arrival reaches the player ONLY as EventBus.headline_added. Payroll
# never gets pushed anywhere — FinanceSystem PULLS it at slot 5, so a hire changes burn by
# existing in the registry. GameState.hr_search is this system's own field (game_state.gd:114,
# "the owning system writes each one"), so it is written here directly and nowhere else.
#
# ARRIVAL IS NOT A MODAL. Candidate files are not an interruption: they land as one ticker line
# and a badge (HRSystem.attention_count reads has_files_ready). Nothing is enqueued, nothing
# steals the screen — the player walks over when they are ready and the files wait.
#
# NO AFFORDABILITY GATE, deliberately, on the same contract as the build-commit seam: the
# retainer and the commission can push cash negative through the ordinary bankruptcy channel.
# preview_search / preview_hire carry the economic warning (runway before → after) instead of a
# disabled button. Cancelling does NOT refund the retainer; dismissing the files costs nothing.


# GameState.hr_search keys — the shape documented at game_state.gd:114. Named so a typo in a
# write cannot silently diverge from a read.
const KEY_STATE := "state"
const KEY_ROLE := "role"
const KEY_BAND := "band"
const KEY_SEED := "seed"
const KEY_STARTED_DAY := "started_day"
const KEY_ARRIVAL_DAY := "arrival_day"
const KEY_FILES := "files"

# ProductSystem's "mühendis lazım" signal (written by ProductSystem's bug-sprint frequency
# check, cleared here on a developer hire). Cited by SYMBOL, not by line: the old
# `product_system.gd:462` pointer had drifted onto the iteration sub-machine, which is a
# worse failure than a stale number because the reader believes what they find there.
const FLAG_NEEDS_ENGINEER := "needs_engineer"

# Arrival-day mixer (arithmetic, NOT tunables). The window itself is
# HRConstants.SEARCH_ARRIVAL_MIN_DAYS..MAX_DAYS; this only picks a day inside it out of the
# stored seed, because "2-4 gün" has to be unpredictable to the player and identical on reload.
# Same no-RNG rule as HRCandidateGenerator: the global RNG stream belongs to the event deck and
# the resignation roll, and commissioning a search must never displace a draw from it.
const ARRIVAL_MIX_MODULUS := 100003
const ARRIVAL_MIX_MULTIPLIER := 16807
const ARRIVAL_MIX_INCREMENT := 4711


# --- Daily entry (called by HRSystem.daily_tick, slot 3) ---

static func daily_tick() -> void:
	# Idle or waiting on the player: nothing ticks, nothing is generated, no state moves. This
	# early return is why a run that never opens the HR tab is byte-identical to one without
	# this system at all.
	if get_state() != HRConstants.SEARCH_SEARCHING:
		return
	# `<` rather than `!=` on purpose: if a day ever passes without this tick running, the files
	# still land on the next one instead of the search hanging forever.
	if GameState.day < int(GameState.hr_search.get(KEY_ARRIVAL_DAY, 0)):
		return
	_deliver_files()


# --- State reads ---

static func get_state() -> String:
	# An empty dictionary IS idle, which is what makes GameState.initialize_run's
	# hr_search.clear() a complete reset with no extra bookkeeping here.
	return String(GameState.hr_search.get(KEY_STATE, HRConstants.SEARCH_IDLE))


static func has_files_ready() -> bool:
	# The left-rail HR badge reads this through HRSystem.attention_count: the design wants the
	# arrival as a badge the player answers in their own time, never as a forced modal.
	return get_state() == HRConstants.SEARCH_FILES_READY


static func can_start() -> bool:
	# One search at a time (demo scope). Deliberately NOT an affordability check — see the
	# header: the money warning lives in preview_search, not in a disabled button.
	return get_state() == HRConstants.SEARCH_IDLE


static func get_files() -> Array:
	# The live array, not a copy: candidate files are read-only display data and the HR tab
	# re-reads them on every redraw. Empty while `searching` — the files do not exist until the
	# arrival tick generates them from the stored seed.
	var stored: Variant = GameState.hr_search.get(KEY_FILES, [])
	if stored is Array:
		return stored as Array
	return []


static func days_waiting() -> int:
	# How long the CURRENT search has been on the table, counted from the day the player
	# commissioned it — the day the retainer left the account. One meaning in both `searching`
	# and `files_ready`, so a card can print "3 gündür" without first asking which state it is
	# in. 0 when idle.
	if get_state() == HRConstants.SEARCH_IDLE:
		return 0
	return maxi(0, GameState.day - int(GameState.hr_search.get(KEY_STARTED_DAY, GameState.day)))


static func current_role() -> String:
	# What the in-flight search is looking for. The waiting strip has to name the role and the
	# band, and without these two the only way to get them was to reach into GameState.hr_search
	# from the UI — i.e. past the system that owns that dictionary. "" when idle.
	return String(GameState.hr_search.get(KEY_ROLE, ""))


static func current_band() -> String:
	return String(GameState.hr_search.get(KEY_BAND, ""))


# --- Commissioning a search ---

static func start_search(role_id: String, band_id: String) -> bool:
	if not can_start():
		push_warning("[HRSearchSystem] start_search while state is '%s' — one search at a time" % get_state())
		return false
	if not HRConstants.is_employee_role(role_id):
		push_warning("[HRSearchSystem] start_search with non-employee role '%s' — see HRConstants.EMPLOYEE_ROLES" % role_id)
		return false
	# Engine-side back-stop for the Atlas's visual lock: the UI must not be the only thing
	# standing between a consumer run and an enterprise hire.
	if not HRConstants.is_role_hireable(role_id):
		push_warning("[HRSearchSystem] start_search for locked role '%s' — see HRConstants.role_lock_reason_key" % role_id)
		return false
	if not HRConstants.BANDS.has(band_id):
		push_warning("[HRSearchSystem] start_search with unknown band '%s' — see HRConstants.BANDS" % band_id)
		return false

	# The SEED is stored, not the files. seed_for() reads GameState.day, which has moved on by
	# the time the files land, so deriving it again at arrival would hand back different people
	# — and a save/load mid-search would reshuffle a table the player was already thinking about.
	var seed_value: int = HRCandidateGenerator.seed_for(role_id, band_id)
	GameState.hr_search = {
		KEY_STATE: HRConstants.SEARCH_SEARCHING,
		KEY_ROLE: role_id,
		KEY_BAND: band_id,
		KEY_SEED: seed_value,
		KEY_STARTED_DAY: GameState.day,
		KEY_ARRIVAL_DAY: GameState.day + _arrival_delay(seed_value),
		KEY_FILES: [],
	}
	# Peşin retainer, charged ONCE here and never refunded (design doc §2, çift ücret). Same
	# ledger label as the commission: both lines are what Atlas costs.
	FinanceSystem.apply_one_time_cost(HRConstants.SEARCH_RETAINER, HRConstants.COST_LABEL_HIRE)
	return true


static func cancel_search() -> bool:
	# İptal: the retainer is NOT refunded — peşin ücret yanmıştır (design doc §2). Cancelling is
	# only legal while Atlas is still looking; once the files are on the table the way out is
	# dismiss_files().
	if get_state() != HRConstants.SEARCH_SEARCHING:
		return false
	_clear()
	return true


static func dismiss_files() -> bool:
	# Beğenmedin: no commission, no charge of any kind. The retainer stays spent, so a
	# throwaway search is a real (small) loss rather than a free look.
	if get_state() != HRConstants.SEARCH_FILES_READY:
		return false
	_clear()
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
	# Day + ordinal, the same readable id shape PitchSystem.spawn_prospect uses for leads.
	# run_hires increments inside CharacterRegistry.add for every employee, so no two hires in a
	# run can collide even on the same day.
	emp.id = "char_emp_%d_%d" % [GameState.day, GameState.run_hires]
	emp.character_name = String(file.get("name", ""))
	emp.role = role_id
	emp.category = "employee"          # THE founder/mentor/staff discriminator; Frank is never this
	emp.monthly_salary = salary
	emp.equity_pct = 0.0               # hires get no equity: employee equity is not in the HR design
	emp.morale = HRConstants.MORALE_HIRE_START
	emp.status = HRConstants.STATUS_ACTIVE
	emp.role_stats = _axes_copy(file.get("axes", {}))
	emp.traits = _traits_copy(file.get("traits", []))

	CharacterRegistry.add(emp)
	if CharacterRegistry.get_character(emp.id) == null:
		# add() refuses an id collision with a warning and returns void, so the insert is
		# verified before any money moves: a rejected hire must not charge a commission.
		push_error("[HRSearchSystem] CharacterRegistry.add rejected '%s' — no charge, no state change" % emp.id)
		return null
	# add() stamps hire_day = today. The design says a hire starts the NEXT day at full
	# performance (no ramp), so the stamp is corrected AFTER add() returns — before it, add()
	# would simply overwrite it. Kıdem reads from here too: severance_months floors at
	# SEVERANCE_MIN_MONTHS, so a same-day dismissal pays one month rather than a negative tenure.
	emp.hire_day = GameState.day + 1
	# Komisyon: charged ONCE, here, on the hire only — dismissing the files charges nothing.
	FinanceSystem.apply_one_time_cost(HRConstants.commission_for(salary), HRConstants.COST_LABEL_HIRE)
	if role_id == HRConstants.ROLE_DEVELOPER:
		# needs_engineer is ProductSystem's bug-sprint pressure signal, and a hire is that
		# flag's answer — so the answer clears the question. HRMoraleSystem.is_capacity_overloaded
		# reads the same flag for the AŞIRI YÜKLÜ badge, which is what finally gives it a reader.
		GameState.set_flag(FLAG_NEEDS_ENGINEER, false)
	_clear()
	if OS.is_debug_build():
		print("[HRSearchSystem] hire: %s (%s) $%d/mo, komisyon $%d" % [
			emp.character_name, role_id, salary, HRConstants.commission_for(salary),
		])
	return emp


# --- Previews (what the UI prints BEFORE the player commits) ---

static func preview_search(role_id: String, band_id: String) -> Dictionary:
	# Plain values, no formatting: money stays int, both runway numbers stay float. NOTE
	# GameState.get_runway_months() returns INF on non-negative net flow, so the card must send
	# these two through UiTokens.net_runway_parts — the single home for the INF-vs-months
	# decision. A system file does not own that formatting.
	var retainer: int = HRConstants.SEARCH_RETAINER
	var net_daily: int = GameState.get_net_daily_flow()
	var cash_after: int = GameState.cash - retainer
	var warnings: Array[String] = []
	if GameState.cash < retainer:
		warnings.append("Peşin ücret kasadaki nakitten fazla, bu ödeme kasayı eksiye düşürür.")
	if not can_start():
		warnings.append("Zaten açık bir arayış var, kapanmadan yenisi başlamaz.")
	var valid: bool = HRConstants.is_employee_role(role_id) and HRConstants.BANDS.has(band_id)
	var band: Array = HRConstants.salary_band(role_id, band_id)
	var band_low: int = 0
	var band_high: int = 0
	if band.size() >= 2:
		band_low = mini(int(band[0]), int(band[1]))
		band_high = maxi(int(band[0]), int(band[1]))
	return {
		"valid": valid,
		"can_start": can_start(),
		"role": role_id,
		# role_label push_errors on an unknown id by design, so it is only called on a known one.
		"role_label": HRConstants.role_label(role_id) if HRConstants.is_employee_role(role_id) else role_id,
		"band": band_id,
		"band_label": HRConstants.band_label(band_id),
		# What UZMANLIK and HIZ actually drive for THIS role (design doc §4 table) — the help
		# copy the arayış card prints so the player picks a band for a reason.
		"axis_meaning": HRConstants.ROLE_AXIS_MEANING.get(role_id, {}),
		"candidate_count": HRConstants.CANDIDATE_COUNT,
		"retainer": retainer,
		"arrival_min_days": HRConstants.SEARCH_ARRIVAL_MIN_DAYS,
		"arrival_max_days": HRConstants.SEARCH_ARRIVAL_MAX_DAYS,
		"salary_band_low": band_low,
		"salary_band_high": band_high,
		# The commission is a share of the accepted salary, so the band edges bracket it.
		"commission_low": HRConstants.commission_for(band_low),
		"commission_high": HRConstants.commission_for(band_high),
		"cash_before": GameState.cash,
		"cash_after": cash_after,
		"runway_before": GameState.get_runway_months(),
		# The retainer moves cash only, never the flow, so the "after" reuses today's net.
		"runway_after": _runway_after(cash_after, net_daily),
		"affordable": GameState.cash >= retainer,
		"warnings": warnings,
	}


static func preview_hire(candidate_index: int) -> Dictionary:
	# The candidate card's economic line. Every key is present even when the index is invalid,
	# so the UI never has to guard a missing key — the money fields simply read today's truth.
	# Same INF caveat as preview_search: runway_before/runway_after can be INF.
	var payroll_before: int = CharacterRegistry.get_total_monthly_salaries()
	var net_before: int = GameState.get_net_daily_flow()
	var runway_before: float = GameState.get_runway_months()
	var warnings: Array[String] = []
	var no_traits: Array[String] = []
	var out: Dictionary = {
		"valid": false,
		"index": candidate_index,
		"name": "",
		"role": "",
		"role_label": "",
		"band": "",
		"band_label": "",
		"axes": {},
		"traits": no_traits,
		"note": "",
		"salary": 0,
		"commission": 0,
		"payroll_before": payroll_before,
		"payroll_after": payroll_before,
		"daily_burn_before": GameState.daily_burn,
		"daily_burn_after": GameState.daily_burn,
		"cash_before": GameState.cash,
		"cash_after": GameState.cash,
		"runway_before": runway_before,
		"runway_after": runway_before,
		"morale_start": HRConstants.MORALE_HIRE_START,
		"starts_on_day": GameState.day + 1,
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
	var payroll_after: int = payroll_before + salary
	# FinanceSystem PULLS the whole payroll and converts it in ONE rounding pass
	# (FinanceSystem.daily_tick), so tomorrow's burn is today's published total with the salary slice
	# swapped out. NOT today's total plus this salary rounded on its own: that would sit a dollar
	# off the figure Finance publishes, and it would double-count if the player already hired
	# today (the registry already holds that salary, the published burn does not yet).
	var salaries_now: int = int(FinanceSystem.burn_breakdown.get("salaries", 0))
	var burn_after: int = GameState.daily_burn - salaries_now + FinanceSystem.daily_salary_for(payroll_after)
	var net_after: int = GameState.get_daily_revenue() - burn_after
	var cash_after: int = GameState.cash - commission
	if GameState.cash < commission:
		warnings.append("Komisyon kasadaki nakitten fazla, bu ödeme kasayı eksiye düşürür.")
	if net_before >= 0 and net_after < 0:
		warnings.append("Bu maaş nakit akışını eksiye çevirir, kasa erimeye başlar.")

	out["valid"] = true
	out["name"] = String(file.get("name", ""))
	out["role"] = role_id
	out["role_label"] = HRConstants.role_label(role_id) if HRConstants.is_employee_role(role_id) else role_id
	out["band"] = String(file.get("band", ""))
	out["band_label"] = HRConstants.band_label(String(file.get("band", "")))
	out["axes"] = _axes_copy(file.get("axes", {}))
	out["traits"] = _traits_copy(file.get("traits", []))
	out["note"] = String(file.get("note", ""))
	out["salary"] = salary
	out["commission"] = commission
	out["payroll_after"] = payroll_after
	out["daily_burn_after"] = burn_after
	out["cash_after"] = cash_after
	out["runway_after"] = _runway_after(cash_after, net_after)
	out["affordable"] = GameState.cash >= commission
	# The same array instance is already in `out` (Arrays are references, so the appends above
	# already landed); re-stated so that is not a subtlety a reader has to spot.
	out["warnings"] = warnings
	return out


# --- Internals ---

static func _deliver_files() -> void:
	var role_id: String = String(GameState.hr_search.get(KEY_ROLE, ""))
	var band_id: String = String(GameState.hr_search.get(KEY_BAND, ""))
	var seed_value: int = int(GameState.hr_search.get(KEY_SEED, 0))
	var files: Array = HRCandidateGenerator.generate(role_id, band_id, seed_value)
	GameState.hr_search[KEY_FILES] = files
	GameState.hr_search[KEY_STATE] = HRConstants.SEARCH_FILES_READY
	# NOT a modal and NOT an enqueued event: one ticker line, then the HR badge carries it until
	# the player looks. Interrupting the day for a piece of post would be the wrong register for
	# a beat the player asked for and is already waiting on.
	EventBus.headline_added.emit(
		HRConstants.SEARCH_AGENCY_NAME,
		"%s arayışı için %d aday dosyası masanda." % [HRConstants.role_label(role_id), files.size()]
	)
	if OS.is_debug_build():
		print("[HRSearchSystem] %d aday dosyası hazır (%s / %s, seed %d)" % [files.size(), role_id, band_id, seed_value])


static func _clear() -> void:
	# Back to idle by emptying the dictionary rather than writing state = idle: get_state() reads
	# an empty dict as idle, and this is the same idiom GameState.initialize_run uses, so there
	# is exactly one shape for "no search" instead of two.
	GameState.hr_search.clear()


static func _arrival_delay(seed_value: int) -> int:
	# A day inside [SEARCH_ARRIVAL_MIN_DAYS, SEARCH_ARRIVAL_MAX_DAYS], derived — never rolled.
	# Stored on the search, so the wait cannot be re-diced by reloading.
	var low: int = HRConstants.SEARCH_ARRIVAL_MIN_DAYS
	var high: int = maxi(HRConstants.SEARCH_ARRIVAL_MAX_DAYS, low)
	var span: int = high - low + 1
	var n: int = (absi(seed_value) % ARRIVAL_MIX_MODULUS) * ARRIVAL_MIX_MULTIPLIER + ARRIVAL_MIX_INCREMENT
	return low + (n % ARRIVAL_MIX_MODULUS) % span


static func _axes_copy(source: Dictionary) -> Dictionary:
	# EXACTLY HRConstants.AXES, ints, in a dictionary the Character owns — never the candidate
	# file's own dict, which dies with _clear() and which CharacterRegistry key-locks the shape of.
	var axes: Dictionary = {}
	for axis_key in HRConstants.AXES:
		axes[String(axis_key)] = clampi(
			int(source.get(axis_key, HRConstants.AXIS_MIN)), HRConstants.AXIS_MIN, HRConstants.AXIS_MAX
		)
	return axes


static func _traits_copy(source: Array) -> Array[String]:
	# Character.traits is Array[String]; a value read back out of a Dictionary arrives untyped,
	# so it is rebuilt typed instead of assigned across.
	var out: Array[String] = []
	for trait_id in source:
		out.append(String(trait_id))
	return out


static func _runway_after(cash_value: int, daily_net: int) -> float:
	# The arithmetic lives on its owner (GameState.runway_months_for) — this is only the
	# PRESENTATION guard on top of it: an empty account reads 0.0 rather than a negative month
	# count, the same edge VCPitchSystem._gross_runway_months guards. maxf leaves INF alone.
	return maxf(0.0, GameState.runway_months_for(cash_value, daily_net))
