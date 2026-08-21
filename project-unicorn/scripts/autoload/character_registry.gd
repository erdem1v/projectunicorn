extends Node

# Character registry per TECH_SPEC §6.1.
# Single source of truth for all characters — employees, mentor, NPCs — and
# their relationships, traits, morale, and compensation.
#
# Mutations route through registry methods. State changes emit on EventBus
# (TECH_SPEC §13) so scenes (HR tab, ODA) update themselves without the registry
# knowing who is listening.
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
# to onboarding or to the mentor surfaces. Flip to true to restore the
# Debug Engineer A / Debug Designer B placeholders for HR/Finance pipeline tests.
const DEBUG_SEED := false

# Frank'in portresi. Portre politikası (GDD 14 §7): çalışanların yüzü yok, baş harf;
# Frank'in ve portre taşıyan adlı karakterlerin portresi var. Frank iki yerde kuruluyor
# (_seed_debug_characters ve ensure_mentor), yol tek yerde dursun diye burada.
const MENTOR_PORTRAIT := "res://assets/art/investors/portrait_frank.webp"

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


# --- DENEYİM / EĞİTİM sızdırmazlıkları (Terminal UI görevi) ---
# WRITE-THROUGH YASASI: `area_experience`, `trainings_done`, `training_days_left`,
# `training_area` ve `assigned_jobs` alanlarını bu dosyanın DIŞINDA kimse yazmaz.
# Hepsi sinyal atar, çünkü defter satırı bu değerleri çiziyor ve HR sekmesi
# yapı-anahtarıyla yeniden kuruluyor.

## Deneyim ekler — ALAN BAŞINA (rev 2 §8 learn-by-doing). KURUCU DAİL (2026-08-22):
## Kişisel sekmesinin kurucu kartı bir DENEYİM çubuğu çiziyor, ve kurucu bu kanaldan
## dışlanırsa o çubuk sonsuza dek %0 okur — yani ekran yalan söyler.
## DOLDUĞUNDA O ALAN +1 OLUR ve sayaç sıfırlanır: bu ÜCRETSİZ kanaldır ve ücretli
## eğitimden bağımsızdır (§8 ikisini ayrı satırlarda sayıyor). `true` döner yalnız
## bir puan kazanıldıysa.
func add_area_experience(id: String, area_key: String, amount: int) -> bool:
	var c: Character = _characters.get(id, null)
	if c == null:
		push_warning("[CharacterRegistry] add_area_experience on unknown id: %s" % id)
		return false
	if c.category not in ["employee", "founder"]:
		return false
	if area_key == "" or not HRConstants.AREAS.has(area_key):
		return false
	var cur: int = int(c.area_experience.get(area_key, 0))
	var raised: int = cur + maxi(amount, 0)
	if raised < HRConstants.EXPERIENCE_MAX:
		if raised == cur:
			return false
		c.area_experience[area_key] = raised
		EventBus.employee_experience_changed.emit(id, raised)
		return false
	# Tavandaki bir alan deneyim BİRİKTİRMEZ: sayaç dolar, puan verilemez, ve dolu
	# sayaç oyuncuya "burada yapacak bir şey kalmadı" diye durur.
	var area_value: int = int(c.role_stats.get(area_key, 0))
	if area_value >= HRConstants.AREA_MAX:
		c.area_experience[area_key] = HRConstants.EXPERIENCE_MAX
		EventBus.employee_experience_changed.emit(id, HRConstants.EXPERIENCE_MAX)
		return false
	c.role_stats[area_key] = area_value + 1
	c.area_experience[area_key] = 0
	EventBus.employee_experience_changed.emit(id, 0)
	return true


## Eğitime uygun mu? Edilgen olmayan bir çalışan ya da KURUCU, ve SEÇİLEN yetenek tavanın
## altındayken. DENEYİM ŞARTI YOK (rev 2 §8): eğitim parayla alınan ayrı bir kanal,
## learn-by-doing'in devamı değil. Tavandaki bir alana eğitim GÖNDERİLEMEZ: ücreti
## alıp hiçbir şey vermemek §10'un yasakladığı şeyin aynası olurdu.
##
## İKİ KAPI 2026-08-22'de AÇILDI. (1) KURUCU: onaylı tasarımın Kişisel kartında
## EĞİTİME GÖNDER düğmesi var. (2) LİDERLİK: eğitim tablosunun üçüncü satırı Liderlik,
## ve Liderlik `AREAS`'ta olmadığı için eski kapı onu sessizce reddediyordu. Yazılan
## anahtar `role_stats["leadership"]`, yani +1 yolu zaten çalışıyordu.
func can_train(id: String, area_key: String = "") -> bool:
	var c: Character = _characters.get(id, null)
	if c == null or c.category not in ["employee", "founder"]:
		return false
	if c.status != HRConstants.STATUS_ACTIVE:
		return false
	if area_key == "":
		# Alan verilmediyse "herhangi bir yetenekte eğitilebilir mi" sorusudur — defterin
		# ve menünün EĞİTİME GÖNDER satırı bunu sorar, yeteneği modal seçtirir.
		for a in HRConstants.trainable_keys():
			if int(c.role_stats.get(String(a), 0)) < HRConstants.AREA_TRAIN_CAP:
				return true
		return false
	if not HRConstants.is_trainable_key(area_key):
		return false
	return int(c.role_stats.get(area_key, 0)) < HRConstants.AREA_TRAIN_CAP


## Bu çalışanın bu alandaki eğitiminin ücreti — kademeli + tekrarda zamlı (§8).
func training_fee_for(id: String, area_key: String) -> int:
	var c: Character = _characters.get(id, null)
	if c == null:
		return HRConstants.TRAINING_FEE
	return HRConstants.training_fee(int(c.role_stats.get(area_key, 0)),
		int(c.trainings_done.get(area_key, 0)), area_key)


## Eğitimi BAŞLATIR. Ücreti burada TAHSİL ETMEZ — para FinanceSystem'in işi ve
## çağıran taraf (HRSystem.send_to_training) o sızdırmazlıktan geçirir.
func begin_training(id: String, area_key: String) -> void:
	var c: Character = _characters.get(id, null)
	if c == null:
		push_warning("[CharacterRegistry] begin_training on unknown id: %s" % id)
		return
	if not HRConstants.is_trainable_key(area_key):
		push_error("[CharacterRegistry] begin_training with an untrainable target: '%s'" % area_key)
		return
	c.training_days_left = HRConstants.TRAINING_DAYS
	c.training_area = area_key
	c.status = HRConstants.STATUS_TRAINING
	EventBus.employee_training_changed.emit(id, c.training_days_left)


## Bir eğitim gününü işler. Biten eğitimde SEÇİLEN ALAN +1 (tavanla), tekrar sayacı
## artar, durum ACTIVE. `true` döner yalnız eğitim BİTTİYSE — haber satırını çağıran atar.
func tick_training(id: String) -> bool:
	var c: Character = _characters.get(id, null)
	if c == null or c.training_days_left <= 0:
		return false
	c.training_days_left -= 1
	if c.training_days_left > 0:
		EventBus.employee_training_changed.emit(id, c.training_days_left)
		return false
	var area_key: String = c.training_area
	if HRConstants.is_trainable_key(area_key):
		var cur: int = int(c.role_stats.get(area_key, 0))
		c.role_stats[area_key] = mini(cur + 1, HRConstants.AREA_TRAIN_CAP)
		c.trainings_done[area_key] = int(c.trainings_done.get(area_key, 0)) + 1
		c.area_experience[area_key] = 0
	c.training_area = ""
	c.status = HRConstants.STATUS_ACTIVE
	EventBus.employee_training_changed.emit(id, 0)
	EventBus.employee_experience_changed.emit(id, 0)
	return true


# =========================== Alan ataması (rev 2 §4) ========================
# TEK YAZAR. `assigned_jobs` yalnız buradan değişir; WRITE-THROUGH YASASI.
# (Alanın kendisi değişti, alanın AD I değil: dizinin adı `assigned_jobs` kaldı ki kayıt
# şemasının alan adı sabit kalsın; içindeki değerler artık HRConstants.ASSIGNABLE.)

## Bir ALANA atar. Kurucu AYNI ANDA TEK ALAN taşır (ch. 02 §5) — ikinci bir alan sessizce
## eklenmez, reddedilir ve gerekçe döner. Çalışan birden fazla alan taşıyabilir; o
## AŞIRI YÜKLENMEDİR (§5) ve bedeli HRSystem'de ölçülür, burada değil.
## Boş dize = kabul edildi.
func assign_area(id: String, area_id: String) -> String:
	var c: Character = _characters.get(id, null)
	if c == null:
		return "unknown"
	if not HRConstants.is_assignable(area_id):
		push_error("[CharacterRegistry] assign_area with an unknown area: '%s'" % area_id)
		return "unknown_area"
	if c.assigned_jobs.has(area_id):
		return ""
	if c.status != HRConstants.STATUS_ACTIVE:
		return "inactive"
	if c.category == "founder" and not c.assigned_jobs.is_empty():
		# ch. 02 §5: "While assigned, the other actions are locked-visible with a reason."
		return "founder_busy"
	if not HRConstants.can_hold_area(c.role, area_id, c.category):
		# Tasarımın "ALANI YOK · ATANAMAZ" hücresi, kural olarak: bir çalışan yalnız ANA ya da
		# İKİNCİL alanında çalışabilir. Matris o sütunları zaten kesikli çiziyor ve tıklamıyor;
		# bu kapı arayüze güvenmemek için.
		return "not_your_area"
	c.assigned_jobs.append(area_id)
	EventBus.assignment_changed.emit(id)
	return ""


func unassign_area(id: String, area_id: String) -> void:
	var c: Character = _characters.get(id, null)
	if c == null or not c.assigned_jobs.has(area_id):
		return
	c.assigned_jobs.erase(area_id)
	if c.assigned_jobs.size() <= 1:
		c.overload_days = 0
	EventBus.assignment_changed.emit(id)


func clear_areas(id: String) -> void:
	## Ayrılma anı (§9): kişinin alanları BOŞALIR. Otomatik devir YOK — "otomatik kurucuya
	## devir varsayılan değildir", boş kalan alan oyuncuya Görevler ekranında görünür.
	var c: Character = _characters.get(id, null)
	if c == null or c.assigned_jobs.is_empty():
		return
	c.assigned_jobs.clear()
	c.overload_days = 0
	EventBus.assignment_changed.emit(id)


func set_overload_days(id: String, days: int) -> void:
	var c: Character = _characters.get(id, null)
	if c == null:
		return
	c.overload_days = maxi(days, 0)


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


func get_active_by_role(role_id: String) -> Array[Character]:
	# Task 2b work lens: everyone AT WORK in one role. The sales and customer desks read this
	# rather than get_customer_reps() above, which is the leave-INCLUSIVE payroll/headcount
	# lens — an on-leave rep is still on the payroll and still counts as a hire, but they are
	# not prospecting and not answering tickets today (the same split get_active_employees
	# documents). Sorted by id so every desk that ranks its people ranks them deterministically.
	var out: Array[Character] = []
	for c in get_active_employees():
		if c.role == role_id:
			out.append(c)
	out.sort_custom(func(a: Character, b: Character) -> bool: return a.id < b.id)
	return out


func count_active_by_role(role_id: String) -> int:
	# The cheap guard the two new desks test FIRST — zero people in the role means the whole
	# channel returns before touching any state, which is what keeps a run with no sales/CS
	# staff byte-identical to before Task 2b.
	var n: int = 0
	for c in get_active_employees():
		if c.role == role_id:
			n += 1
	return n


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
	m.character_name = TranslationServer.translate("MENTOR_NAME")
	# Typed id whose label is the byte-exact "Operating Partner" already on screen via
	# MentorIntroModal and the three live JSON events that speak as Frank.
	m.role = HRConstants.ROLE_MENTOR
	m.category = "mentor"
	m.monthly_salary = 0
	m.equity_pct = 0.0
	m.morale = 50
	m.portrait_path = MENTOR_PORTRAIT
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
		# rev 2 §4: an unassigned person stands idle and still draws salary. A HIRE is not
		# where the player wants to meet that — they just paid a retainer and a commission.
		# So a fresh hire lands on their OWN KEY AREA (HRConstants.default_area_for_role),
		# which is also what keeps every downstream formula seeing the roster it saw before
		# the assignment layer existed. Moving people is the Görevler tab's job.
		if character.assigned_jobs.is_empty():
			var default_area: String = HRConstants.default_area_for_role(character.role)
			if default_area != "":
				character.assigned_jobs.append(default_area)
		if character.area_experience.is_empty():
			for area_key in HRConstants.AREAS:
				character.area_experience[String(area_key)] = 0
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
	# KEY LOCK: employees and the founder share one role_stats dict but not one key set —
	# since the 2026-08-21 area migration they share the SIX AREAS and differ only in the
	# tail (employee: + Liderlik · founder: + Liderlik + Karizma). get_founder_skill returns
	# 0 for an unknown key without complaining, so a half-migrated record would be silent.
	# Scream instead. NON-BLOCKING on purpose (mirrors _build_founder's validators): the
	# character is still added, the log carries the defect.
	#
	# The RETIRED-KEY check is the tripwire FounderConstants.OLD_SKILLS has always had and
	# employee axes never did: a stray "pace" surviving a bad migration would otherwise load
	# as a dropped key (save_codec drops unknown keys by design) and read as a silent 0.
	if HRConstants.has_retired_skill_key(character.role_stats):
		push_error("[CharacterRegistry] '%s' still carries a RETIRED skill key %s — expertise/pace/rapport were replaced by HRConstants.AREAS on 2026-08-21: %s"
			% [character.id, str(HRConstants.RETIRED_SKILL_KEYS), str(character.role_stats)])
	if character.category == "employee":
		if not HRConstants.is_employee_role(character.role):
			push_error("[CharacterRegistry] employee '%s' has non-employee role '%s' — see HRConstants.EMPLOYEE_ROLES"
				% [character.id, character.role])
		if not HRConstants.validate_employee_skills(character.role_stats):
			push_error("[CharacterRegistry] employee '%s' role_stats must hold EXACTLY %s on 0-%d: %s"
				% [character.id, str(HRConstants.EMPLOYEE_SKILL_KEYS), HRConstants.AREA_MAX, str(character.role_stats)])
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
	# Assignment shape is checked for EVERYONE: an area id that is not in ASSIGNABLE would
	# make every read seam quietly skip the person.
	for area_id in character.assigned_jobs:
		if not HRConstants.is_assignable(String(area_id)):
			push_error("[CharacterRegistry] '%s' assigned to unknown area '%s' — see HRConstants.ASSIGNABLE"
				% [character.id, String(area_id)])
		elif not HRConstants.can_hold_area(character.role, String(area_id), character.category):
			push_error("[CharacterRegistry] '%s' (%s) assigned to '%s', which is neither their key nor their secondary area"
				% [character.id, character.role, String(area_id)])
	if character.category == "founder" and character.assigned_jobs.size() > 1:
		push_error("[CharacterRegistry] founder holds %d areas — ch. 02 §5 allows exactly one"
			% character.assigned_jobs.size())


func insert_raw(character: Character) -> void:
	# SAVE RESTORE ONLY. add() is the wrong door for a load and every reason is a real bug:
	# it re-stamps hire_day to TODAY (so a founding engineer becomes a day-140 hire), it
	# assigns a leave_month when the record already carries the one it was hired with, it
	# increments GameState.run_hires (so loading a run inflates its own hire counter every
	# time), and it emits character_added into a shell that is not in the tree yet.
	# The precedent for a direct insert is ensure_mentor() above, which documents the same
	# reasoning for the same reason: "Direct insert (no add()) so character_added does not
	# fire for the system-seeded mentor".
	# _validate_shape IS still run — a save carrying a malformed employee should scream
	# exactly as loudly as a live hire would; it is non-blocking, so the record still lands.
	if character == null or character.id == "":
		push_warning("[CharacterRegistry] insert_raw() called with null or missing id")
		return
	_validate_shape(character)
	_characters[character.id] = character


func remove(id: String) -> void:
	if not _characters.has(id):
		return
	# Run counter seam (mirrors add()'s employee guard): read category BEFORE erase.
	# Reads 0 today — no fire/quit flow calls remove() with an employee yet; the seam
	# is here so a future departure flow counts automatically.
	var c: Character = _characters[id]
	if c != null and c.category == "employee":
		GameState.run_departures += 1
	# rev 2 §9: "Ayrılan kişinin işleri boşalır." The jobs are vacated and NOT handed to
	# anyone — "otomatik kurucuya devir varsayılan değildir". Any job lead seat this person
	# held is cleared too, so the next resolution falls through to the live roster rather
	# than pointing at a ghost (the same class of bug ProductSystem._lead_coordination
	# documents for a stale lead_engineer_id).
	if c != null:
		c.assigned_jobs.clear()
	GameState.release_area_leads(id)
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
	if value != HRConstants.STATUS_ACTIVE and value != HRConstants.STATUS_ON_LEAVE \
			and value != HRConstants.STATUS_TRAINING:
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
	mentor.character_name = TranslationServer.translate("MENTOR_NAME")
	# Was "Mentor" here and "Operating Partner" in ensure_mentor — two strings for one
	# role. Typing collapses the divergence onto the id whose label is the visible one.
	mentor.role = HRConstants.ROLE_MENTOR
	mentor.category = "mentor"
	mentor.monthly_salary = 0
	mentor.portrait_path = MENTOR_PORTRAIT
	_characters[mentor.id] = mentor

	# DEBUG SEED — placeholder employees so HR + Finance integration can be
	# verified. Remove when data/characters/employees.json + hire flow exist.
	# Names use explicit DEBUG markers to prevent accidental canonization.
	# Morale chosen either side of the burnout threshold so the badge derivation is
	# visibly exercised during dev verification.
	# The key area at 4 is the ANCHOR value: at EMPLOYEE_SPEED_COEF 0.25 it contributes
	# exactly 1.0 efor/day, which is what a pre-Coupling assist engineer contributed.
	var eng := Character.new()
	eng.id = "char_debug_eng_a"
	eng.character_name = "Debug Engineer A"
	eng.role = HRConstants.ROLE_DEVELOPER
	eng.category = "employee"
	eng.monthly_salary = 6000
	eng.morale = 60
	eng.role_stats = HRConstants.seed_skills(HRConstants.ROLE_DEVELOPER, 4, 3)
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
	des.role_stats = HRConstants.seed_skills(HRConstants.ROLE_DESIGNER, 4, 3)
	des.traits = ["glass_heart"]   # TEK TRAIT (HRConstants.TRAIT_COUNT, 2026-08-22)
	des.hire_day = 1
	des.leave_month = HRConstants.leave_month_for(1, 1)
	_characters[des.id] = des
