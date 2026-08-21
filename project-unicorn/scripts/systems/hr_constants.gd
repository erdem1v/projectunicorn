class_name HRConstants
extends RefCounted

# THE single tunables block for the HR module (GDD v2 ch. 07 rev 2): roles and
# departments, the six skill AREAS, the seven jobs, traits, the Atlas search, morale,
# annual leave, player actions, department overtime and the HR economy labels.
# EVERY number here is a WORKING PLACEHOLDER — calibration is a separate last pass
# (PROJECT_SPEC §10: numbers last). Pure statics; no state, no scene dependency.
#
# NO HR NUMBER LIVES ANYWHERE ELSE. If an HR formula needs a knob it comes from here;
# the badge threshold that used to be a literal in left_tabs.gd is MORALE_BURNOUT below.
#
# Scope note: the two SHIM tables this header used to advertise were deleted by the HR
# Coupling task, which rescaled the coefficients instead. Three comments elsewhere still
# name them; they are corrected in the same commit as this line.


# ============================ Skill AREAS (0-9) ==============================
# GDD v2 ch. 07 rev 2 §2. Skills are AREAS, not roles: everyone carries a number in all
# six, plus Liderlik. The founder additionally carries Karizma (rev 2 §2, last line).
#
# WHY AREAS AND NOT THE OLD THREE AXES: with `expertise`/`pace`/`rapport` the axis keys
# were identical for every role and only their MEANING changed per role, so a one-person
# team had holes nothing could fill. Areas close that: a Software Engineer with Test 1 can
# cover QA badly rather than not at all, and a PM with Tasarım 1 can cover design badly.
# rev 2 §2 states the bargain in one line — "böylece tek kişilik ekipte boşluk kalmaz" —
# and §5 is its price (working outside your key area is more tiring).
#
# The three retired axes are listed in RETIRED_SKILL_KEYS below and TRIPWIRED, mirroring
# FounderConstants.OLD_SKILLS: a stray "pace" must scream, not load as a dropped key.
const AREA_PRODUCT := "product"                     # Ürün — tasarım turları, özellik kararları
const AREA_DESIGN := "design"                       # Tasarım — tasarım tavanı, Deneyim ekseni
const AREA_ENGINEERING := "engineering"             # Yazılım — geliştirme hızı, bug oranı
const AREA_QA := "qa"                               # Test — beta keşif hızı, canlı bug aşınması
const AREA_SALES := "sales"                         # Satış — kapanış olasılığı, anlaşma boyutu
const AREA_CUSTOMER_SUCCESS := "customer_success"   # Müşteri Başarısı — bilet, memnuniyet, churn
const AREAS := ["product", "design", "engineering", "qa", "sales", "customer_success"]

# Liderlik is on EVERYONE (rev 2 §2) — it stopped being founder-only. Karizma stays
# founder-only and lives in FounderConstants.
const SKILL_LEADERSHIP := "leadership"
# The exact key set an employee's role_stats must hold: six areas + Liderlik.
const EMPLOYEE_SKILL_KEYS := ["product", "design", "engineering", "qa", "sales",
	"customer_success", "leadership"]

const AREA_MIN := 0
const AREA_MAX := 9

# TRIPWIRE. FounderConstants.OLD_SKILLS is the precedent (game_state.get_founder_skill
# push_errors on a retired founder key). Employee axes had no such guard, so a rename
# would have landed silently as a dropped key on load (save_codec drops unknown keys by
# design). Hız was DELETED outright by rev 2 §2; Uyum stopped being a number and moved
# into traits ("cam kalp vb.").
const RETIRED_SKILL_KEYS := ["expertise", "pace", "rapport"]

# NAMESPACE COLLISION, on purpose and worth knowing: "sales" is three different things —
# the area id above, the job id JOB_SALES below, and the department id DEPT_SALES. They
# never meet in one dictionary, but a grep for "sales" hits all three.
#
# Title case in data; every uppercase surface renders through UiTokens.tr_upper. There is
# no label table here: the label is DERIVED from the id (HR_AREA_ + ID). See the note over
# role_label for why every label table in this file left for strings.csv.


static func area_label(area_key: String) -> String:
	return _derived("HR_AREA_", area_key)


static func default_employee_skills() -> Dictionary:
	# The exact-key shape every employee must hold. Mid-band middle values, Liderlik low:
	# leading is the exception, not the default, and rev 2 §2 hangs real team effects on it.
	return {"product": 5, "design": 5, "engineering": 5, "qa": 5, "sales": 5,
		"customer_success": 5, "leadership": 2}


static func validate_employee_skills(role_stats: Dictionary) -> bool:
	# EXACTLY the six areas + Liderlik, each inside the ruler. Mirrors
	# FounderConstants.validate_alloc's grammar so a founder dict handed to an employee
	# (or vice versa) fails loudly rather than half-reading.
	if role_stats.size() != EMPLOYEE_SKILL_KEYS.size():
		return false
	for skill_key in EMPLOYEE_SKILL_KEYS:
		if not role_stats.has(skill_key):
			return false
		var v: int = int(role_stats[skill_key])
		if v < AREA_MIN or v > AREA_MAX:
			return false
	return true


static func has_retired_skill_key(role_stats: Dictionary) -> bool:
	## True when a dict still carries expertise/pace/rapport. Callers scream; see the
	## TRIPWIRE note above.
	for k in RETIRED_SKILL_KEYS:
		if role_stats.has(k):
			return true
	return false


# ===================== Role → area, and the seven jobs =======================
# ROLE_AREAS (rev 2 §2/§3): the role is a TITLE; these two areas are what the closed row
# shows ("Product Manager: Ürün ★★★ · Tasarım ★") and where the candidate generator puts a
# file's peak. rev 2 supplies two of the six rows verbatim — product_manager and developer
# — and Erdem ruled the symmetric completion 2026-08-21.
const ROLE_AREAS := {
	"product_manager": {"key": "product", "secondary": "design"},
	"designer": {"key": "design", "secondary": "product"},
	"developer": {"key": "engineering", "secondary": "qa"},
	"tester": {"key": "qa", "secondary": "engineering"},
	"sales_rep": {"key": "sales", "secondary": "customer_success"},
	"customer_rep": {"key": "customer_success", "secondary": "sales"},
}

# The seven jobs of rev 2 §4. ASSIGNMENT IS TO A JOB, not to an area (Erdem 2026-08-21):
# §4's table is headed "İş", the founder clause says "bir işe atandığında", and ch. 03 §8
# ("yeni sürüme başlayınca ekip destekten çekilir") plus ch. 06 §1.3 ("covering head =
# anyone assigned to support/CS") both need Build and Destek to be separately assignable.
# Areas do three things only: say who is ELIGIBLE, say which number the formula reads, and
# say whether that job is the person's key area (normal) or a secondary one (§5, tiring).
const JOB_BUILD := "build"          # aktif sürüm — hız, tavan, bug oranı
const JOB_TEST := "test"            # beta keşif hızı
const JOB_SUPPORT := "support"      # canlı ürün — bilet çözümü, yanıt süresi
const JOB_ACCOUNTS := "accounts"    # hesap sahipliği — memnuniyet, risk kartları
const JOB_SALES := "sales"          # lead işleme, kapanış
const JOB_RESEARCH := "research"    # özellik kilidi açılır
const JOB_COST := "cost"            # servis maliyeti ↓, teknik borç ↓
const JOBS := ["build", "test", "support", "accounts", "sales", "research", "cost"]

# rev 2 §4 "Kimler" column. Order matters: the FIRST area a person is strong in is the one
# the job reads (see area_for_job).
const JOB_AREAS := {
	"build": ["product", "design", "engineering"],
	"test": ["qa"],
	"support": ["engineering", "customer_success"],
	"accounts": ["customer_success", "sales"],
	"sales": ["sales"],
	"research": ["product", "design", "engineering"],
	"cost": ["engineering"],
}

# Where a fresh hire lands so nobody is born idle. This is what keeps every downstream
# formula seeing the roster it saw before the assignment layer existed: the model is real
# from this commit, the PRESSURE switches on when the Görevler tab can move people.
const ROLE_DEFAULT_JOB := {
	"product_manager": "build",
	"designer": "build",
	"developer": "build",
	"tester": "test",
	"sales_rep": "sales",
	"customer_rep": "accounts",
}

# --- Aşırı yüklenme (rev 2 §5). Every number [WORKING]; §11 lists them as open. ---
# "Aşırı yük kısa süre tolere edilir, uzun sürerse moral düşer ve kaçma riskine gider."
const OVERLOAD_TOLERANCE_DAYS := 5      # [WORKING] grace before the cost starts
const OVERLOAD_OUTPUT_MULT := 0.75      # [WORKING] output while carrying 2+ jobs
const OVERLOAD_MORALE_MULT := 1.6       # [WORKING] multiplier on NEGATIVE morale deltas
const SECONDARY_AREA_MULT := 0.7        # [WORKING] output when a job reads a secondary area


static func role_key_area(role_id: String) -> String:
	var row: Dictionary = ROLE_AREAS.get(role_id, {})
	return String(row.get("key", ""))


static func role_secondary_area(role_id: String) -> String:
	var row: Dictionary = ROLE_AREAS.get(role_id, {})
	return String(row.get("secondary", ""))


static func job_areas(job_id: String) -> Array:
	return JOB_AREAS.get(job_id, [])


static func default_job_for_role(role_id: String) -> String:
	return String(ROLE_DEFAULT_JOB.get(role_id, ""))


static func area_for_job(role_stats: Dictionary, job_id: String) -> String:
	## Which of the job's eligible areas this person actually works it through: their
	## strongest. Ties break on JOB_AREAS order, which is why that order is canon.
	var best: String = ""
	var best_v: int = -1
	for area_key in job_areas(job_id):
		var v: int = int(role_stats.get(String(area_key), 0))
		if v > best_v:
			best_v = v
			best = String(area_key)
	return best


static func experience_gain_mult(lead_leadership: int) -> float:
	## rev 2 §2: the team lead's Liderlik moves "deneyim kazanım hızı" as well as output and
	## morale. Neutral at 0 so a leaderless desk learns at exactly today's rate — the
	## migration must not quietly speed the game up.
	var t: float = clampf(float(lead_leadership) / float(AREA_MAX), 0.0, 1.0)
	return 1.0 + (EXPERIENCE_LEAD_BONUS_MAX - 1.0) * t


static func seed_skills(role_id: String, key_value: int, rest_value: int,
		leadership_value: int = 2) -> Dictionary:
	## A full, key-lock-valid employee skill dict shaped by the ROLE: key area at
	## `key_value`, the role's secondary area one step under it, every other area at
	## `rest_value`. The single home for hand-built rosters — debug seeds, shot fixtures
	## and smoke factories all call this, so the shape can never drift from the key lock.
	var out: Dictionary = {}
	var key_area: String = role_key_area(role_id)
	var secondary: String = role_secondary_area(role_id)
	for area_key in AREAS:
		var a: String = String(area_key)
		if a == key_area:
			out[a] = clampi(key_value, AREA_MIN, AREA_MAX)
		elif a == secondary:
			out[a] = clampi(key_value - 1, AREA_MIN, AREA_MAX)
		else:
			out[a] = clampi(rest_value, AREA_MIN, AREA_MAX)
	out[SKILL_LEADERSHIP] = clampi(leadership_value, AREA_MIN, AREA_MAX)
	return out


static func job_fatigue_mult(role_id: String, job_id: String, role_stats: Dictionary) -> float:
	## rev 2 §5: "ana alanında çalışmak normal, ikincil alanında çalışmak daha yorucudur."
	## The job is read through area_for_job; if that is the role's KEY area the person is
	## home and pays nothing, otherwise they pay SECONDARY_AREA_MULT.
	var worked: String = area_for_job(role_stats, job_id)
	if worked != "" and worked == role_key_area(role_id):
		return 1.0
	return SECONDARY_AREA_MULT


# =========================== Formula-coefficient homes ========================
# The SHIM tables that used to live here are GONE — the HR Coupling task deleted them and
# rescaled the formulas for the 0-9 ruler instead, which is what they existed to defer.
#
# Where an axis coefficient lives is decided by whose formula it belongs to, not by the fact
# that an axis feeds it. This file owns the PEOPLE numbers (bands, morale, traits, leave,
# overtime, and the Liderlik climate/coordination curves, which are Liderlik's definition).
# The build and customer formulas keep their own coefficients next to the arithmetic that
# uses them, exactly where they were before this task:
#   ProductSystem.FOUNDER_SPEED_COEF / EMPLOYEE_SPEED_COEF   build speed per axis point
#   ProductSystem.LEAD_EXPERTISE_WEIGHT                      bug/wear team-average weighting
#   ProductSystem.SEED_EXPERTISE_PIVOT / _SLOPE              at-commit bug seed multiplier
#   ProductSystem.PM_EXPERIENCE_* / TESTER_*                 design + beta role effects
#   B2BConstants.CS_DAMPEN_PER_POINT                         churn suppression per UZMANLIK point
# Splitting them the other way would put build calibration in a file the build does not own.


# ======================= Roles, departments, sections =========================
# Typed ids — no free-text role comparison survives anywhere. `category` remains the
# founder/mentor/staff discriminator (audit §3); role is typing + display only.
const ROLE_PRODUCT_MANAGER := "product_manager"
const ROLE_DESIGNER := "designer"
const ROLE_DEVELOPER := "developer"
const ROLE_TESTER := "tester"
const ROLE_SALES_REP := "sales_rep"
const ROLE_CUSTOMER_REP := "customer_rep"
# Non-staff ids: they carry a label so nothing prints a raw code, and nothing else.
const ROLE_FOUNDER := "founder"
const ROLE_MENTOR := "mentor"

const EMPLOYEE_ROLES := ["product_manager", "designer", "developer", "tester", "sales_rep", "customer_rep"]

# Rol adları tam Türkçe; melez adlar kullanılmaz (design doc §1). The mockups' English
# DESIGNER/DEVELOPER/TESTER chips are pre-canon.
# ROLE_LABELS, DEPT_LABELS, SECTION_LABELS, BAND_LABELS and BADGE_LABELS all left this
# file for strings.csv (Lokalizasyon Faz 2 · B2). The label is now DERIVED from the id the
# code already carries — HR_ROLE_ + ID, HR_DEPT_ + ID, and so on — so one id yields one row
# in both languages and a table can no longer drift from the CSV.
#
# "Operating Partner" is still BYTE-EXACT in both columns: it is already on screen via
# mentor_intro_modal and the three live JSON events whose character_id is char_mentor_frank,
# and the glossary rules it untranslatable. It is a CSV row now, but the same row twice.
#
# Derived keys are invisible to a grep for tr("LITERAL"), so `loc_hr_derived_keys` walks the
# real id lists and asserts each key resolves in both locales.

# One-line, founder-voice effect per role — what hiring this person actually buys you,
# in the player's own language (iç-not sicili emekli: "TASARIM fazına ikincil hız" tarzı
# satırlar kurucu cümlesine çevrildi). Still keyed to ProductSystem.PHASE_CREW AND the
# iteration ceiling law (designer/developer/PM raise their axis ceilings —
# ProductSystem.ITER_CEIL_AXIS_ROLE), so the copy cannot drift from the mechanics
# without this comment being wrong too. The Coupling task's UI obligation stands:
# "oyuncu 'yazılımcı aldım, tasarım hızlanmadı' şaşkınlığını yaşamasın, bunu bilerek alsın."
# WORKING TR (voice pass later).

const DEPT_PRODUCT_DEV := "product_dev"
const DEPT_SALES := "sales"
const DEPT_CUSTOMER := "customer"
# Overtime is started per MAIN department, never per sub-section (design doc §7b).
const DEPARTMENTS := ["product_dev", "sales", "customer"]


const SECTION_DESIGN := "design"
const SECTION_DEVELOPMENT := "development"
const SECTION_TEST := "test"


# Department and section are DERIVED from role, never stored on Character — one source
# of truth, no sync risk (the audit's §5 recommendation). Sales and Müşteri are
# single-level departments, hence the empty section.
const ROLE_DEPARTMENT := {
	"product_manager": "product_dev",
	"designer": "product_dev",
	"developer": "product_dev",
	"tester": "product_dev",
	"sales_rep": "sales",
	"customer_rep": "customer",
}
const ROLE_SECTION := {
	"product_manager": "design",
	"designer": "design",
	"developer": "development",
	"tester": "test",
	"sales_rep": "",
	"customer_rep": "",
}


## Never let a raw internal code reach the screen: an unknown id screams in the log and
## falls back to itself, so a typo surfaces there rather than silently in the UI.
static func role_label(role_id: String) -> String:
	if not ROLE_DEPARTMENT.has(role_id) and role_id not in [ROLE_FOUNDER, ROLE_MENTOR]:
		push_error("[HRConstants] role_label on unknown role id: '%s'" % role_id)
		return role_id
	return _derived("HR_ROLE_", role_id)


## id -> localized label. TranslationServer (not tr()) because this file is all statics;
## an unresolved key returns the id itself, which the callers above already treat as the
## "screamed" case rather than rendering a raw token as if it were copy.
static func _derived(prefix: String, id: String) -> String:
	if id == "":
		return ""
	var key: String = prefix + id.to_upper()
	var out: String = TranslationServer.translate(key)
	return out if out != key else id


static func is_employee_role(role_id: String) -> bool:
	return EMPLOYEE_ROLES.has(role_id)


static func department_of(role_id: String) -> String:
	return String(ROLE_DEPARTMENT.get(role_id, ""))


static func section_of(role_id: String) -> String:
	return String(ROLE_SECTION.get(role_id, ""))


static func department_label(dept_id: String) -> String:
	return _derived("HR_DEPT_", dept_id)


static func section_label(section_id: String) -> String:
	return _derived("HR_SECTION_", section_id)


static func roles_in_department(dept_id: String) -> Array:
	var out: Array = []
	for role_id in EMPLOYEE_ROLES:
		if String(ROLE_DEPARTMENT.get(role_id, "")) == dept_id:
			out.append(role_id)
	return out


static func section_ids_in_department(dept_id: String) -> Array:
	# Sub-section ids of a department, in CANON ORDER (Tasarım → Geliştirme → Test), deduped.
	# The order is a design fact, not a UI preference — the Ekip page renders headers in it —
	# so it lives here rather than being re-asserted by whatever draws the page.
	# Empty for single-level departments (Satış, Müşteri), whose cards sit straight under the
	# main header with no sub-header.
	var out: Array = []
	for role_id in roles_in_department(dept_id):
		var section_id: String = String(ROLE_SECTION.get(role_id, ""))
		if section_id != "" and not out.has(section_id):
			out.append(section_id)
	return out


## One line naming what this role accelerates. Empty for non-employee roles (founder /
## mentor advertise no build-phase contribution) — the caller renders nothing.
static func role_phase_hint(role_id: String) -> String:
	if not is_employee_role(role_id):
		return ""
	return _derived("HR_ROLE_HINT_", role_id)


static func role_lock_reason_key(role_id: String) -> String:
	# "" = this role is hireable right now. Otherwise a CSV key naming, in the player's
	# words, WHY it is not — the game's coming-soon grammar (locked, visible, explained),
	# never a silently absent option.
	#
	# LOCKED, NOT HIDDEN, and EMPLOYEE_ROLES deliberately stays a flat six-id array:
	# HRCandidateGenerator derives its seed index from find() on that array, and the smoke
	# contract asserts its size, so filtering it would silently reshuffle every candidate
	# pool in the game.
	match role_id:
		ROLE_SALES_REP:
			# The enterprise desk only exists in a B2B market; a Satış Uzmanı hired into a
			# consumer run used to mint enterprise prospects and close contracts with no
			# pitch ever played.
			return "" if ProductSystem.has_b2b_product() else "HR_ROLE_LOCK_SALES"
		ROLE_CUSTOMER_REP:
			# Same gate today, because the request/stewardship channel this role works is
			# part of the B2B customer engine.
			return "" if ProductSystem.has_b2b_product() else "HR_ROLE_LOCK_CS"
	return ""


static func is_role_hireable(role_id: String) -> bool:
	return role_lock_reason_key(role_id) == ""


# ================================== Traits ===================================
# Trait'ler skill tekrarı DEĞİL davranış tanımıdır (design doc §4): "Dağınık = kılık
# değiştirmiş düşük UZMANLIK" YANLIŞ; "Yalnız çalışır: ekip katkısı vermez" DOĞRU.
# 5 iyi + 5 kötü. Gizli trait YOKTUR — hepsi aday dosyasında etkisiyle birlikte yazar.
#
# Effect keys and who reads them:
#   morale_floor        HRSystem — moral bu değerin altına inmez
#   morale_drop_mult    HRSystem + HROvertimeSystem — olay düşüşleri VE mesai bedeli
#   dept_morale_weekly  HRSystem — aynı departmandaki diğerlerine haftalık dokunuş
#   resign_chance_mult  HRSystem — istifa roll'unun çarpanı
#   coordination_bonus  DORMANT — koordinasyon çarpanı, HR Coupling (task 2) uygular
#   no_team_bonus       DORMANT — ekip taraflı bonus terimleri, Coupling uygular
#   non_lead_mult       DORMANT — sorumlu değilken katkı çarpanı, Coupling uygular
# Copy fields (label / effect_text) LEFT this table for strings.csv; what remains is the
# MECHANICS (polarity and the effect numbers). The words are derived from the trait id —
# HR_TRAIT_<ID>_LABEL / _EFFECT — so a trait cannot exist with a label in one language only.
const TRAITS := {
	"warms_up_fast": {
		"polarity": "positive",
		"morale_floor": 35,
	},
	"pressure_proof": {
		"polarity": "positive",
		"morale_drop_mult": 0.5,
	},
	"mentors_peers": {
		"polarity": "positive",
		"dept_morale_weekly": 2,
	},
	"wont_jump_ship": {
		"polarity": "positive",
		"resign_chance_mult": 0.6,
	},
	"natural_leader": {
		"polarity": "positive",
		"coordination_bonus": 0.05,
	},
	"works_alone": {
		"polarity": "negative",
		"no_team_bonus": true,
	},
	"glass_heart": {
		"polarity": "negative",
		"morale_drop_mult": 2.0,
	},
	"sours_the_room": {
		"polarity": "negative",
		"dept_morale_weekly": -2,
	},
	"one_foot_out": {
		"polarity": "negative",
		"resign_chance_mult": 1.6,
	},
	"needs_direction": {
		"polarity": "negative",
		"non_lead_mult": 0.5,
	},
}

# Employee trait formula — DELIBERATELY NOT FounderConstants' formula (that one is
# founder-specific: 2 positives force exactly 1 negative). Employees: 1-2 positive,
# at most 1 negative, and roughly half of generated candidates carry that negative.
const TRAIT_MIN_POSITIVE := 1
const TRAIT_MAX_POSITIVE := 2
const TRAIT_MAX_NEGATIVE := 1
const TRAIT_NEGATIVE_SHARE := 0.5   # üretilen adaylarda kötü trait taşıma oranı

# Weekly cadence for the same-department morale traits (dept_morale_weekly).
const TRAIT_DEPT_MORALE_PERIOD_DAYS := 7


static func trait_label(trait_id: String) -> String:
	return _derived("HR_TRAIT_", trait_id + "_LABEL")


static func trait_effect_text(trait_id: String) -> String:
	if not TRAITS.has(trait_id):
		return ""
	return _derived("HR_TRAIT_", trait_id + "_EFFECT")


static func trait_polarity(trait_id: String) -> String:
	return String((TRAITS.get(trait_id, {}) as Dictionary).get("polarity", ""))


static func positive_trait_ids() -> Array:
	var out: Array = []
	for trait_id in TRAITS.keys():
		if String(TRAITS[trait_id].get("polarity", "")) == "positive":
			out.append(trait_id)
	out.sort()   # deterministic order — the generator indexes into this
	return out


static func negative_trait_ids() -> Array:
	var out: Array = []
	for trait_id in TRAITS.keys():
		if String(TRAITS[trait_id].get("polarity", "")) == "negative":
			out.append(trait_id)
	out.sort()
	return out


static func validate_employee_traits(trait_ids: Array) -> bool:
	var pos: int = 0
	var neg: int = 0
	var seen: Array = []
	for trait_id in trait_ids:
		var tid: String = String(trait_id)
		if not TRAITS.has(tid):
			return false
		if seen.has(tid):
			return false   # no duplicates
		seen.append(tid)
		if trait_polarity(tid) == "positive":
			pos += 1
		else:
			neg += 1
	if pos < TRAIT_MIN_POSITIVE or pos > TRAIT_MAX_POSITIVE:
		return false
	return neg <= TRAIT_MAX_NEGATIVE


static func trait_mult(trait_ids: Array, effect_key: String) -> float:
	# Multiplicative accumulator for morale_drop_mult / resign_chance_mult. Two traits
	# pulling opposite ways cancel out, which is the intended reading of a mixed file.
	var m: float = 1.0
	for trait_id in trait_ids:
		var entry: Dictionary = TRAITS.get(String(trait_id), {})
		if entry.has(effect_key):
			m *= float(entry[effect_key])
	return m


static func trait_sum(trait_ids: Array, effect_key: String) -> float:
	# Additive accumulator for dept_morale_weekly / coordination_bonus.
	var total: float = 0.0
	for trait_id in trait_ids:
		var entry: Dictionary = TRAITS.get(String(trait_id), {})
		if entry.has(effect_key):
			total += float(entry[effect_key])
	return total


static func trait_has(trait_ids: Array, effect_key: String) -> bool:
	for trait_id in trait_ids:
		if (TRAITS.get(String(trait_id), {}) as Dictionary).has(effect_key):
			return true
	return false


static func trait_floor(trait_ids: Array) -> int:
	# Highest morale floor any carried trait grants; 0 = no floor.
	var floor_value: int = 0
	for trait_id in trait_ids:
		var entry: Dictionary = TRAITS.get(String(trait_id), {})
		floor_value = maxi(floor_value, int(entry.get("morale_floor", 0)))
	return floor_value


# ============================ Salary bands (Atlas) ===========================
# Bütçe bandı üç AYRIK seçenektir, slider değil (design doc §2). Rol × tier → aylık
# maaş aralığı; üç aday da bandın içinde ve birbirine yakın maaş ister.
const BAND_JUNIOR := "junior"
const BAND_MID := "mid"
const BAND_SENIOR := "senior"
const BANDS := ["junior", "mid", "senior"]
# Bant adları BÜTÇE SEVİYESİ söyler, havuz boyutu değil — aday sayısı her bantta
# CANDIDATE_COUNT'tur ("dar havuz" daha az aday İMA ettiği için emekli edildi).
# WORKING TR (voice pass later).


# Developer bands are the mockup anchor ($5-8K / $8-12K / $12-18K); the other roles
# are offsets from it. ALL WORKING — the balance pass owns these.
const SALARY_BANDS := {
	"developer": {"junior": [5000, 8000], "mid": [8000, 12000], "senior": [12000, 18000]},
	"product_manager": {"junior": [5500, 8500], "mid": [8500, 12500], "senior": [12500, 18000]},
	"designer": {"junior": [4500, 7000], "mid": [7000, 10500], "senior": [10500, 15000]},
	"tester": {"junior": [4000, 6500], "mid": [6500, 9500], "senior": [9500, 14000]},
	"sales_rep": {"junior": [4500, 7500], "mid": [7500, 11000], "senior": [11000, 16000]},
	"customer_rep": {"junior": [4000, 6500], "mid": [6500, 9500], "senior": [9500, 13500]},
}

# Skill PROFILES per band tier — CANDIDATE_COUNT profiles per band, cheapest first.
#
# THE THREE NUMBERS CHANGED MEANING (rev 2, 2026-08-21) BUT NOT VALUE. They used to be
# [axis0, axis1, axis2] and the generator rotated them so each file's peak landed on a
# different axis. With areas, a rotation would put a Designer's peak in Satış — nonsense.
# They are now [KEY AREA, SECONDARY AREA, EVERY OTHER AREA], read against ROLE_AREAS, so a
# file's peak is always where its title says it should be. The values are untouched, and
# _shape_premium still prices the 3-long shape, so quoted salaries did not move a lira.
#
# The files still have to differ QUALITATIVELY, not just in price — that is what the
# rotation used to buy. It is now a +1 bump on a rotating one of the four non-role areas
# (HRCandidateGenerator._skills_for), which is also what gives the one-person-team promise
# of rev 2 §2 its texture: this developer happens to know a little Ürün, that one a little
# Satış. Per-profile INVARIANT: peak > mid >= low
# (a flat profile has no strict max). Per-band INVARIANTS (contract case asserts):
#   - totals STRICTLY increase across profiles — non-dominance is then automatic
#     once the quotes strictly increase too (A >= B on all axes forces
#     total(A) >= total(B), and the pricier file can never undercut on salary);
#   - adjacent (peak+total) gaps stay wide enough that the quote NEVER rounds two
#     files onto one number in the tightest salary window: gap >= 4 (junior) / 3
#     (mid, senior) at SALARY_ROUND_TO 50 — the arithmetic lives at
#     HRCandidateGenerator._shape_premium.
# ALL WORKING — the balance pass owns the numbers, the invariants own the structure.
const BAND_SHAPE := {
	"junior": [[3, 2, 1], [4, 3, 2], [5, 4, 3]],
	"mid": [[5, 4, 3], [6, 5, 3], [7, 5, 4]],
	"senior": [[7, 6, 5], [8, 7, 5], [9, 7, 6]],
}


static func salary_band(role_id: String, band_id: String) -> Array:
	var per_role: Dictionary = SALARY_BANDS.get(role_id, {})
	return per_role.get(band_id, [5000, 8000])


static func band_label(band_id: String) -> String:
	return _derived("HR_BAND_", band_id)


static func band_shape(band_id: String, profile_index: int = 0) -> Array:
	var profiles: Array = BAND_SHAPE.get(band_id, BAND_SHAPE["mid"])
	if profiles.is_empty():
		return []
	return profiles[clampi(profile_index, 0, profiles.size() - 1)]


# ========================= Search (Atlas Seçme & Yerleştirme) ================
# Çift ücret (design doc §2, KANON): peşin retainer + işe alımda komisyon.
# The agency is a PROPER NOUN and stays itself in both languages, on the same rule that
# keeps "Ekonomi Postası" untranslated on the ending gazette (glossary §6). It is a CSV
# row so it is not residue, but the row carries the same value twice.
static func search_agency_name() -> String:
	return TranslationServer.translate("HR_AGENCY_NAME")
const SEARCH_RETAINER := 600            # peşin, iptalde İADE EDİLMEZ
const SEARCH_COMMISSION_PCT := 0.15     # işe alımda ilk ay maaşının oranı
const SEARCH_ARRIVAL_MIN_DAYS := 2      # dosyalar en erken bu kadar gün sonra gelir
const SEARCH_ARRIVAL_MAX_DAYS := 4      # ve en geç bu kadar
const CANDIDATE_COUNT := 3              # her arayış üç dosya getirir
const SALARY_SPREAD_MAX := 0.15         # en pahalı/en ucuz − 1 üst sınırı
const SALARY_PEAK_PREMIUM := 0.10       # WORKING: keskin uzman, düz profilden bu oranda pahalı

# Finance one-time charge labels (FinanceSystem.apply_one_time_cost's ledger hook).
# Cost labels are FUNCTIONS now, not consts: a const is evaluated once at load, long before
# a locale can be chosen, so it would have frozen whichever language happened to be active.
static func cost_label_hire() -> String:
	return TranslationServer.translate("HR_COST_HIRING")


static func cost_label_severance() -> String:
	return TranslationServer.translate("HR_COST_SEVERANCE")


static func cost_label_training() -> String:
	return TranslationServer.translate("HR_COST_TRAINING")

# Ticker attribution (EventBus.headline_added source). Shared so the HR systems do not each
# hold their own copy of the same literal.
# Localized at emit time; see the sibling note in B2BConstants for the staleness contract.
static func notice_source_hr() -> String:
	return TranslationServer.translate("HR_LABEL_HR")

# apply_delta reason vocabulary — debug/telemetry only, never player-facing, but it needs a
# single home or every caller invents its own spelling.
const REASON_OVERTIME := "overtime"
const REASON_LEAVE_RETURN := "leave_return"
const REASON_VACATION_RETURN := "vacation_return"
const REASON_RAISE := "raise"
const REASON_TEAMMATE_FIRED := "teammate_fired"
const REASON_TRAIT_PEER := "trait_peer"

# Search state machine values (GameState.hr_search.state).
const SEARCH_IDLE := "idle"
const SEARCH_SEARCHING := "searching"
const SEARCH_FILES_READY := "files_ready"


static func commission_for(monthly_salary: int) -> int:
	return int(round(float(monthly_salary) * SEARCH_COMMISSION_PCT))


# ================================ Morale =====================================
# Decay YOK (design doc §6): moral yalnız ek mesai, aşırı yük, event'ler, oyuncu
# aksiyonları ve izin dönüşünden hareket eder. Kendiliğinden toparlanma yoktur;
# toparlanma kanalları aksiyonlar + izin + pozitif moral event'leridir.
# Bounds mirror CharacterRegistry.set_morale's clamp. Named here so a PREVIEW can promise
# exactly what the write will produce instead of over-promising past the ceiling.
const MORALE_MIN := 0
const MORALE_MAX := 100
const MORALE_BURNOUT := 40          # altı → TÜKENİYOR rozeti (BURNING_OUT)
const MORALE_FLIGHT_RISK := 25      # altı → KAÇMA RİSKİ rozeti (FLIGHT_RISK)
const MORALE_HIRE_START := 75       # WORKING: yeni işe alınanın başlangıç morali
const MORALE_LEAVE_RETURN := 10     # otomatik yıllık izin dönüşü
const MORALE_VACATION_RETURN := 20  # manuel TATİLE GÖNDER dönüşü (design doc §7)
const MORALE_FIRE_TEAM := 5         # işten çıkarmada kalan ekipteki DÜŞÜŞ büyüklüğü
const MORALE_RAISE_AT_MIN_PCT := 4  # %3 zamda moral kazancı  (WORKING)
const MORALE_RAISE_AT_MAX_PCT := 16 # %15 zamda moral kazancı (WORKING)

# Badge ids reuse Character.attention_flag's declared vocabulary so the model does not
# carry two badge concepts — but badges are DERIVED (HRSystem.badges_for), because an
# employee can hold two at once and a single String field cannot.
const BADGE_FLIGHT_RISK := "FLIGHT_RISK"
const BADGE_BURNING_OUT := "BURNING_OUT"
const BADGE_OVERLOADED := "OVERLOADED"

# Worst-first severity, matching the order HRSystem.badges_for returns. Exposed so a card
# list can sort "needs attention" rows to the top without re-deciding which badge is worse.
const BADGE_SEVERITY := {
	"FLIGHT_RISK": 3,
	"BURNING_OUT": 2,
	"OVERLOADED": 1,
}

# YENİ is INFORMATIONAL, not an attention badge — it must never enter badges_for(), because
# that array is what attention_count() counts and what lights the left-rail badge. A fresh
# hire is good news; it does not belong in the same channel as "this person is about to quit".
const BADGE_NEW := "NEW"
const NEW_HIRE_BADGE_DAYS := 3      # WORKING: kaç gün "Yeni" etiketi taşınır

# Employee status (Character.status) — deliberately NOT attention_flag.
const STATUS_ACTIVE := "active"
const STATUS_ON_LEAVE := "on_leave"
# EĞİTİMDE: çıktı üretmeyen ÜÇÜNCÜ durum. İzinde ile mekanik olarak aynı
# (kapasite dışı, mesai dışı, SORUMLU seçilemez) ama sebebi ve süresi farklı,
# ve satırda kendi çipini taşır. Ayrı bir status olması şart: `on_leave` sayılsaydı
# yıllık izin latch'i ve izin-dönüşü moral ödülü yanlışlıkla tetiklenirdi.
const STATUS_TRAINING := "training"

# --- DENEYİM / EĞİTİM (Terminal UI görevi, 2026-08-08) ---
# Onaylı defterdeki [PROPOSAL] DENEYİM sütununun mekaniği. TÜM SAYILAR WORKING:
# şema değişmeden yeniden ayarlanabilsin diye bilerek basit tutuldu.
# §10 KORUNUR: burada OTOMATİK bir ekonomik kazanç YOK — ücret ve yokluk,
# oynanmış bir kararın oynanmış bedelidir.
const EXPERIENCE_MAX := 100          # WORKING: eğitime uygunluk eşiği
const EXPERIENCE_PER_DAY := 1        # WORKING: çalışan ve EDİLGEN OLMAYAN her gün
const EXPERIENCE_PER_BUILD_DAY := 2  # WORKING: bir geliştirme fazı koşarken
const EXPERIENCE_LEAD_BONUS_MAX := 1.5  # WORKING: Liderlik 9'daki lider altında öğrenme hızı
const TRAINING_DAYS := 14            # rev 2 §8: "Süre iki hafta" (5 idi)
const TRAINING_FEE := 500            # WORKING: TABAN ücret; gerçek ücret kademeli, aşağıya bak
const AREA_TRAIN_CAP := 8            # WORKING: eğitimin alan tavanı (AREA_MAX 9'un altında bilerek)
# rev 2 §8 "Ücret kademeli: düşük yıldızdan yükseltmek ucuz, yüksek yıldızdan yükseltmek
# pahalı" + "Tekrarında azalan getiri". İkisi de TEK kanaldan ödenir: ücret. Getiri hep +1
# puandır (tam sayı cetvelde başka türlüsü okunmaz), azalan olan aynı +1'in FİYATIDIR.
const TRAINING_FEE_PER_POINT := 220  # WORKING: mevcut alan değeri başına ek ücret
const TRAINING_REPEAT_SURCHARGE := 0.35  # WORKING: aynı alandaki her tekrarda oransal zam


static func training_fee(current_area_value: int, trainings_done_in_area: int) -> int:
	## Kademeli ücret + azalan getiri, tek yerde. Çağıran yalnız bu sayıyı görür.
	var base: float = float(TRAINING_FEE) + float(maxi(current_area_value, 0)) * float(TRAINING_FEE_PER_POINT)
	var repeat: float = 1.0 + float(maxi(trainings_done_in_area, 0)) * TRAINING_REPEAT_SURCHARGE
	return int(round(base * repeat))


static func badge_label(badge_id: String) -> String:
	return _derived("HR_BADGE_", badge_id)


static func badge_severity(badge_id: String) -> int:
	# 0 for anything that is not an attention badge (including BADGE_NEW), so an
	# informational tag can never out-rank a real warning in a sort.
	return int(BADGE_SEVERITY.get(badge_id, 0))


static func is_new_hire(hire_day: int, today: int) -> bool:
	# Fresh-hire window. hire_day is stamped to the day AFTER the hire (HRSearchSystem: a hire
	# starts the next day), so on the day the player pays, today < hire_day — hence the
	# two-sided test rather than a plain subtraction.
	return today <= hire_day + NEW_HIRE_BADGE_DAYS


# ONE comparison home for the two thresholds. The design says "moral < 40" and "moral < 25"
# (strictly below), and more than one system asks the question — the badge derivation, the
# flight-risk counter, the resignation window, the overtime safety valve. If each wrote its
# own comparison, an employee at exactly 25 could get a "Mesai sınırı" modal with no KAÇMA
# RİSKİ badge on their card. Every caller asks here instead.
static func is_burning_out(morale: int) -> bool:
	return morale < MORALE_BURNOUT


static func is_flight_risk(morale: int) -> bool:
	return morale < MORALE_FLIGHT_RISK


# ===================== Founder Liderlik: iklim + koordinasyon =================
# Liderlik iki iş yapar (design doc §4) ve HER İKİSİ de "liderlik" kelimesinin gerçekten
# anlattığı şey. Satış, bug ve pazarlık formüllerine GİRMEZ.
#   1) İKLİM — kötü olaylarda moral düşüşlerini küçültür, toparlanmaları büyütür,
#      ek mesainin moral bedelini düşürür. Bu task uygular.
#   2) KOORDİNASYON — sorumludan gelen build hızı çarpanı. ProductSystem._speed_for_lead
#      uygular (HR Coupling task'ı bağladı).
const CLIMATE_DROP_PER_POINT := 0.05   # her Liderlik puanı moral düşüşlerini bu oranda kısar
const CLIMATE_DROP_FLOOR := 0.50       # en iyi liderlikte bile düşüşün yarısı kalır
const CLIMATE_GAIN_PER_POINT := 0.05   # her puan toparlanmaları bu oranda büyütür
const CLIMATE_GAIN_CAP := 1.50

const COORD_MIN := 0.85                # zayıf ÇALIŞAN sorumlu — ekip birbirini bekler
const COORD_MAX := 1.20                # güçlü sorumlu (her iki kaynak için de tavan)
const COORD_MAX_WITH_TRAIT := 1.25     # "Doğal lider" tavanı da yükseltir
const COORD_NATURAL_LEADER_BONUS := 0.05
# Founder-as-lead is NEUTRAL at Liderlik 0 and only rises: "CEO olarak ekibin başında olmak
# hız cezası DEĞİL, liderliğine güven meselesidir" (design doc §4). A single two-sided mapping
# would have made a Liderlik-0 founder a 15% speed penalty, which both contradicts that
# sentence and breaks the equivalence anchor that founder tech-3 solo stays 3.0 efor/gün.
const COORD_FOUNDER_NEUTRAL := 1.0


static func climate_drop_mult(leadership: int) -> float:
	# Applied to every negative morale delta (events, overtime, overload).
	return clampf(1.0 - float(maxi(leadership, 0)) * CLIMATE_DROP_PER_POINT, CLIMATE_DROP_FLOOR, 1.0)


static func climate_gain_mult(leadership: int) -> float:
	# Applied to every positive morale delta (raise, vacation, leave return, good events).
	return clampf(1.0 + float(maxi(leadership, 0)) * CLIMATE_GAIN_PER_POINT, 1.0, CLIMATE_GAIN_CAP)


# The multiplier is ASYMMETRIC BY SOURCE, which is not a fudge — the two sources answer two
# different questions. A founder is always in the room whether or not he is any good at leading,
# so his Liderlik can only ADD; putting the CEO in charge must never be a speed tax (design doc
# §4). A CHOSEN employee lead is a real bet: a low-UYUM one genuinely does coordinate worse, and
# that downside is what makes "kimi sorumlu yapacağım" a decision rather than a formality.
# ProductSystem._speed_for_lead picks the right one from the lead's identity.

static func coordination_for_founder(leadership: int, has_natural_leader: bool = false) -> float:
	# Neutral at 0, rising to COORD_MAX at the top of the ruler. Onboarding caps Liderlik at 3,
	# so a fresh founder sits at 1.00-1.07 — the anchor "tech-3 solo = 3.0 efor/gün" holds because
	# the multiplier at Liderlik 0 is exactly 1.0.
	var span: float = COORD_MAX - COORD_FOUNDER_NEUTRAL
	var t: float = clampf(float(leadership) / float(AREA_MAX), 0.0, 1.0)
	var m: float = COORD_FOUNDER_NEUTRAL + span * t
	if has_natural_leader:
		m += COORD_NATURAL_LEADER_BONUS
	return clampf(m, COORD_FOUNDER_NEUTRAL, COORD_MAX_WITH_TRAIT)


static func coordination_for_lead(leadership: int, has_natural_leader: bool = false) -> float:
	# rev 2 §2 moved Liderlik onto EVERYONE, which collapsed two curves into one: the old
	# coordination_for_employee read the lead's UYUM, and UYUM stopped being a number.
	# Two-sided across the whole ruler on purpose — Liderlik 0 → COORD_MIN (the team waits on
	# each other), Liderlik 9 → COORD_MAX — so choosing a lead stays a real bet, which is
	# exactly what the retired UYUM curve was for. The founder keeps his own neutral-at-0
	# curve above: he is the DEFAULT lead, and a default must not be a penalty.
	var t: float = clampf(float(leadership) / float(AREA_MAX), 0.0, 1.0)
	var m: float = lerpf(COORD_MIN, COORD_MAX, t)
	if has_natural_leader:
		m += COORD_NATURAL_LEADER_BONUS
	return clampf(m, COORD_MIN, COORD_MAX_WITH_TRAIT)


# ============================ Resignation (istifa) ===========================
# KAÇMA RİSKİ ihmal edilirse istifa event'i tetiklenir (design doc §6, roll'lu).
# The played decision is upstream: the badge is visible for the whole window and the
# three card actions are available the entire time — neglect IS the decision.
const RESIGN_WINDOW_MIN_DAYS := 10      # KAÇMA RİSKİ bu kadar gün sürerse roll başlar
const RESIGN_WINDOW_MAX_DAYS := 14      # pencerenin üst sınırı (kanon aralık)
const RESIGN_CHANCE_PER_DAY := 0.25     # WORKING: pencere boyunca ~%76 birikimli
const RESIGN_VALVE_PENALTY := 0.15      # "Devam et" seçiminin o kişiye eklediği günlük şans
const SEVERANCE_ON_RESIGN := 0          # istifada tazminat YOKTUR (design doc §6)


static func resign_chance(trait_ids: Array, valve_continued: bool) -> float:
	var chance: float = RESIGN_CHANCE_PER_DAY * trait_mult(trait_ids, "resign_chance_mult")
	if valve_continued:
		chance += RESIGN_VALVE_PENALTY
	return clampf(chance, 0.0, 1.0)


# ========================== Yıllık izin (otomatik) ===========================
# İzin ayı işe alımda atanır; ay gelince çalışan OTOMATİK izne çıkar, oyuncu onayı
# istenmez. Ücretli izin: maaş akmaya devam eder, kapasite/hız/CS/mesai katkısı durur.
const LEAVE_DAYS := 7
const LEAVE_MONTH_MIN_GAP := 2     # işe alındığı aydan en az bu kadar ay sonra
# Stride over the ALLOWED SPAN (12 - MIN_GAP = 10 months), not over 12. It must be coprime
# with that span or consecutive hires collapse onto a couple of months: with a span of 10,
# a stride of 5 yields only two distinct offsets. 7 is coprime with 10, so ten consecutive
# hires land on ten different months before any repeat.
const LEAVE_MONTH_STRIDE := 7


static func leave_month_for(hire_month: int, hire_ordinal: int) -> int:
	# Distribution rule: offset the leave month MIN_GAP..11 months after the hire month, so
	# a fresh hire never vacations in their first weeks AND never in the hire month itself.
	# hire_ordinal = how many employees were hired before this one.
	#
	# The naive form (stride over all 12 months) wrapped back ONTO the hire month: a January
	# hire at ordinal 2 got January, and went on annual leave the day after starting. Walking
	# the allowed span instead makes that structurally impossible.
	var span: int = 12 - LEAVE_MONTH_MIN_GAP
	var offset: int = LEAVE_MONTH_MIN_GAP + (LEAVE_MONTH_STRIDE * maxi(hire_ordinal, 0)) % span
	return ((hire_month - 1 + offset) % 12) + 1


static func leave_month_label(month: int) -> String:
	# Character.leave_month is a bare 1-12 int and preview_vacation passes it through raw, so
	# every consumer would otherwise print a number where a month belongs. Fmt.month_name is
	# the single home for month words in either language (it used to read the calendar's
	# Turkish Title-Case table, which stayed Turkish in the English build).
	if month < 1 or month > 12:
		return ""
	return Fmt.month_name(month)


# ======================= Player actions (çalışan kartı) ======================
const RAISE_MIN_PCT := 3           # zam slider alt sınırı (design doc §7)
const RAISE_MAX_PCT := 15          # üst sınır — ONAYLI (design doc §12.3)
const SEVERANCE_MIN_MONTHS := 1    # her tam çalışılan yıl için 1 ay, minimum 1 ay
const VACATION_DAYS := 7           # manuel TATİLE GÖNDER süresi
const DAYS_PER_YEAR := 365         # kıdem hesabı (hire_day → tam yıl)


static func raise_morale_gain(pct: int) -> int:
	# Moral etkisi oranla ölçeklenir (design doc §7): %3 → MIN, %15 → MAX, arası doğrusal.
	var p: int = clampi(pct, RAISE_MIN_PCT, RAISE_MAX_PCT)
	var span: int = maxi(1, RAISE_MAX_PCT - RAISE_MIN_PCT)
	var t: float = float(p - RAISE_MIN_PCT) / float(span)
	return int(round(lerpf(float(MORALE_RAISE_AT_MIN_PCT), float(MORALE_RAISE_AT_MAX_PCT), t)))


static func severance_months(days_served: int) -> int:
	# Her TAM çalışılan yıl için 1 aylık maaş, en az 1 ay (design doc §7).
	return maxi(SEVERANCE_MIN_MONTHS, int(floor(float(maxi(days_served, 0)) / float(DAYS_PER_YEAR))))


static func severance_amount(monthly_salary: int, days_served: int) -> int:
	return monthly_salary * severance_months(days_served)


# ========================= Ek mesai (departman bazlı) ========================
# Üç blok; departman başlığından başlatılır, alt bölümden değil (design doc §7b).
# Founder katılır ama EK ÜCRET ALMAZ. İzindeki çalışan asla katılmaz.
const OVERTIME_BLOCKS := [3, 7, 14]           # gün: 3 gün · 1 hafta · 2 hafta

# Kazanç — bu task yalnız SORGULANABİLİR yapar; build/satış/CS formüllerine bağlamak
# HR Coupling (task 2) işidir (state vs application: tek formül evi korunur).
const OVERTIME_SPEED_BONUS_EARLY := 0.30      # 1-7. gün hız kazancı
const OVERTIME_SPEED_BONUS_LATE := 0.15       # azalan verim: 8. günden itibaren
const OVERTIME_DIMINISH_DAY := 8              # bu günden itibaren LATE geçerli
const OVERTIME_BUG_MULT := 1.25               # yalnız product_dev mesaisinde bug oranı
# Bedel 1, para: her mesai günü, o çalışanın GÜNLÜK maaşının bu oranı kadar ek tahakkuk
# (fazla mesainin yasal 1.5× saat karşılığından türetilmiştir).
const OVERTIME_PAY_PCT := 0.40
# Bedel 2, moral: birikimli günlük düşüş. through_day = -1 → sınırsız (son basamak).
const OVERTIME_MORALE_TIERS := [
	{"through_day": 3, "drop": 2},
	{"through_day": 7, "drop": 4},
	{"through_day": -1, "drop": 7},
]


static func overtime_speed_bonus(day_index: int) -> float:
	# day_index is 1-based within the CURRENT block.
	if day_index >= OVERTIME_DIMINISH_DAY:
		return OVERTIME_SPEED_BONUS_LATE
	return OVERTIME_SPEED_BONUS_EARLY


static func overtime_morale_drop(day_index: int) -> int:
	for tier in OVERTIME_MORALE_TIERS:
		var through: int = int(tier["through_day"])
		if through < 0 or day_index <= through:
			return int(tier["drop"])
	return int(OVERTIME_MORALE_TIERS[OVERTIME_MORALE_TIERS.size() - 1]["drop"])


static func overtime_daily_pay(monthly_salary: int) -> int:
	# Günlük maaş = aylık / 30 (mevcut salary pull ile aynı bölen), ×PAY_PCT.
	return int(round(float(monthly_salary) / 30.0 * OVERTIME_PAY_PCT))


# ================== Pozitif moral event'leri (placeholder) ===================
# Moral kendiliğinden toparlanmadığı için demo'nun döngüyü KAPATTIĞINI kanıtlayacak
# 2-3 placeholder pozitif event ile çıkılır (design doc §6 + §12.8). Content sprint
# bunları gerçek yazımla değiştirir; motor tarafındaki tetikleyici alanlar
# (ortalama moral, son mesaiden bu yana gün, son ship, son büyük imza) okunabilir.
const CALM_STRETCH_DAYS := 21          # bu kadar gün ek mesai yoksa "sakin dönem"
const CALM_STRETCH_MORALE := 5
const CALM_STRETCH_MAX_MORALE := 70    # ekip zaten mutluysa event tetiklenmez
const BIG_SIGNING_MRR := 1500          # bu MRR üstü bir imza → "büyük imza"
const BIG_SIGNING_MORALE := 4
const SHIP_GLOW_MORALE := 6            # yeni sürüm çıktı → "ürün iyi gidiyor"
const POSITIVE_EVENT_COOLDOWN_DAYS := 14


# ============================== Event copy pools =============================
# Deterministically indexed by character id (String.hash is stable for a given string),
# so the same person always says the same line. WORKING TR — the content sprint replaces
# the copy, not the mechanism. Ayrılış isim ve yüzle, TEK REPLİKLİ event olarak sunulur
# (design doc §6), so these are one line each and stay in first person.
# RESIGN_VOICE left this file for strings.csv: the lines are copy, and an array of copy in
# code cannot carry a second language. RESIGN_VOICE_COUNT is the pool size; resign_voice_line(i)
# resolves the row. Index stays the selector, so the deterministic
# id-hash pick that chose a line still chooses the same one.
const RESIGN_VOICE_COUNT := 4


static func resign_voice_line(index: int) -> String:
	return TranslationServer.translate("HR_RESIGN_VOICE_%d" % (posmod(index, RESIGN_VOICE_COUNT) + 1))
# VALVE_VOICE left this file for strings.csv: the lines are copy, and an array of copy in
# code cannot carry a second language. VALVE_VOICE_COUNT is the pool size; valve_voice_line(i)
# resolves the row. Index stays the selector, so the deterministic
# id-hash pick that chose a line still chooses the same one.
const VALVE_VOICE_COUNT := 3


static func valve_voice_line(index: int) -> String:
	return TranslationServer.translate("HR_VALVE_VOICE_%d" % (posmod(index, VALVE_VOICE_COUNT) + 1))


## Deterministically indexed by character id, so the same person always says the same
## line — the index is the selector, the sentence lives in strings.csv.
static func resign_voice(character_id: String) -> String:
	return resign_voice_line(absi(character_id.hash()))


static func valve_voice(character_id: String) -> String:
	return valve_voice_line(absi(character_id.hash()))


## HR money. DELEGATES to Fmt now: this used to be a private dot-grouping copy, and its own
## comment already admitted "the wider codebase has several private copies of this". A
## private copy is a locale bug waiting to happen, and it was one — the English HR page
## rendered a Turkish-grouped "$43.600" until this line changed.
static func money_tr(amount: int) -> String:
	return Fmt.money_exact(amount)


# ============================ Aday dosyası içeriği ===========================
# WORKING content — deterministically indexed by the generator's pure hash, never RNG.
const FIRST_NAMES := [
	"Kerem", "Selin", "Arda", "Deniz", "Ece", "Mert", "Zeynep", "Baran",   # LOC-DATA name pool
	"Elif", "Onur", "Sena", "Kaan", "Bilge", "Tolga", "Nehir", "Emre",   # LOC-DATA name pool
]
const LAST_NAMES := [
	"Aksoy", "Koç", "Güneş", "Demir", "Kaya", "Arslan", "Yıldız", "Çetin",   # LOC-DATA name pool
	"Doğan", "Şahin", "Erdem", "Polat", "Tekin", "Uysal",   # LOC-DATA name pool
]
# Tek satırlık dosya notu — mizaç verir, skill tekrarı yapmaz.
# FILE_NOTES left this file for strings.csv: the lines are copy, and an array of copy in
# code cannot carry a second language. FILE_NOTES_COUNT is the pool size; file_notes_line(i)
# resolves the row. Index stays the selector, so the deterministic
# id-hash pick that chose a line still chooses the same one.
const FILE_NOTES_COUNT := 12


static func file_notes_line(index: int) -> String:
	return TranslationServer.translate("HR_FILE_NOTE_%d" % (posmod(index, FILE_NOTES_COUNT) + 1))


## What a role's key / secondary AREA buys the player, as help copy. Derived from the role
## id and the area id together (HR_AREA_MEANING_<ROLE>_<AREA>). Only the role's own two
## areas have a row — rev 2 §3 forbids showing all six in a flat list, so there is nothing
## to say about a Satış Temsilcisi's Test number on the closed card.
static func role_area_meaning(role_id: String, area_key: String) -> String:
	if not is_employee_role(role_id):
		return ""
	return _derived("HR_AREA_MEANING_", role_id + "_" + area_key)
