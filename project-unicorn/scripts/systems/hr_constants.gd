class_name HRConstants
extends RefCounted

# THE single tunables block for the HR module (GDD v2 ch. 07 rev 2): roles and
# departments, the six skill AREAS, the seven jobs, traits, the Atlas search, morale,
# annual leave, player actions, department overtime and the HR economy labels.
# EVERY number here is a WORKING PLACEHOLDER — calibration is a separate last pass
# (PROJECT_SPEC §10: numbers last). Pure statics; no state, no scene dependency.
#
# NO HR NUMBER LIVES ANYWHERE ELSE. If an HR formula needs a knob it comes from here;
# the badge threshold that used to be a literal in left_tabs.gd is MORALE_FLIGHT_RISK below.
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
## 10, not 9, since 2026-08-21: the approved skin draws every skill as FIVE stars with a
## real half star, and the only mapping that makes both ends of the ruler honest is
## 2 points = 1 star. At 9 the top of the ruler was 4½ stars and five could never fill.
##
## Raising the ceiling moved no existing value — but it DID move quoted salaries, because
## _shape_premium prices against AREA_MAX × 4. Taken deliberately (Erdem 2026-08-21);
## hr_candidate_invariants is the guard that the three quotes stay distinct.
const AREA_MAX := 10

## The star ruler. One home, so the ledger, the matrix, the founder card and the training
## modal can never disagree about what a number looks like.
const STAR_MAX := 5
const POINTS_PER_STAR := 2

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
	# §4.4 KISIT: cross-cover YALNIZ ürün tarafının kendi içindedir. Satışçı satış yapar,
	# müşteri temsilcisi müşteriyle ilgilenir; ikisi de ürün tarafına geçmez, ürün tarafı da
	# onların yerine geçmez. Boş ikincil bir eksiklik değil, verilmiş bir hükümdür.
	"sales_rep": {"key": "sales", "secondary": ""},
	"customer_rep": {"key": "customer_success", "secondary": ""},
}

# ATAMA CETVELİ — rev 2 §4. NOT THE SKILL RULER: `AREAS` above is what a person IS good at,
# this is what they are DOING today. The two lists overlap by six ids and differ by one, and
# keeping them apart is the whole reason `research` can be assignable without anybody
# carrying a Araştırma number.
#
# SECOND RULING ON THE SAME SENTENCE (2026-08-21). §4 says "alanlar işaretlenir" but its
# table is headed "İş", and the first pass (18d27e3) read it as SEVEN JOBS — build · test ·
# support · accounts · sales · research · cost. The approved skin settles it the other way:
# the Görevler matrix carries one column per AREA plus Araştırma, and names
# Build/Destek/Hesap/Maliyet as retired. So the assignment unit is the AREA and the four job
# ids with no area of their own are gone. `support` and `accounts` both collapse onto
# Müşteri İlişkileri — which is what ch. 06 §1.3's "covering head" was counting all along.

# ATANABİLİR ALAN LİSTESİ = ALTI ALAN. `ASSIGNABLE` ayrı bir dizi olarak vardı çünkü
# yedincisi (Araştırma) bir atama hedefiydi; §12.0 onu kaldırdı ("Araştırma bir atama hedefi
# değildir"), ve geriye kalan liste `AREAS`'ın kendisi. İki adı olan tek bir liste §15.2'nin
# yasakladığı şeydir.

# ============================== İŞLER — §12.0 ================================
# rev 11 §12.0 ATAMA BİRİMİNİ İŞ YAPAR.
#
# İki liste FARKLI şeyler söyler: `AREAS` kişinin neyde İYİ olduğu, `JOBS` ne YAPTIĞI.
# `JOB_AREAS` köprüdür.
const JOB_BUILD := "build"          # Build ekibi (aktif yapım)
const JOB_TEST := "test"            # Test
const JOB_SUPPORT := "support"      # Destek (canlı ürün)
const JOB_ACCOUNTS := "accounts"    # Hesap sahipliği
const JOB_SALES := "sales"          # Satış
const JOBS := ["build", "test", "support", "accounts", "sales"]

## Hangi ALANLAR her işi taşır (§12.0, bağlayıcı). Bir kişi işin alanlarından en az birini
## taşıyorsa o işi tutabilir; NE KADAR İYİ yaptığı §4.5'in formülüdür, bu tablo değil.
##
## Destek bir istisna DEĞİLDİR (§4.4): Yazılım VE Müşteri İlişkileri taşır, yani bir
## developer destek masasında çalışabilir — bilet → hata düzeltme hattı bu yüzden vardır —
## ama bunu Yazılım üzerinden yapar ve Müşteri İlişkileri kazanmaz.
const JOB_AREAS := {
	"build": ["product", "design", "engineering"],
	"test": ["qa"],
	"support": ["engineering", "customer_success"],
	"accounts": ["customer_success", "sales"],
	"sales": ["sales"],
}

## §12 "Bir kişiye en fazla iki iş verilebilir. Bu bir tavandır, bir öneri değil."
## TEK EV (§15.2): matris kilidi ve yazma tarafı aynı sayıyı okur.
const MAX_JOBS_PER_PERSON := 2

## §12.1 odak katsayısı. ZAMAN hakkında; §4.3 YETKİNLİK hakkında. İkisi çarpılır,
## birbirinin yerine geçmez. Tek iş 1,00 · iki iş 0,50 (her iki işe AYRI AYRI).
const FOCUS_MULT_SINGLE := 1.0
const FOCUS_MULT_SPLIT := 0.5


static func job_areas(job_id: String) -> Array:
	return (JOB_AREAS.get(job_id, []) as Array).duplicate()


static func is_job(job_id: String) -> bool:
	return JOBS.has(job_id)


## İş adı — matris başlığı ve GÖREV hücresi buradan okur. Bilinmeyen bir id kendi kendini
## döndürür ve logda bağırır (role_label ile aynı "asla ham token çizme" kuralı).
static func job_label(job_id: String) -> String:
	if not JOBS.has(job_id):
		push_error("[HRConstants] job_label with an unknown job: '%s'" % job_id)
		return job_id
	return _derived("HR_JOB_", job_id)


## Bir rol bu işi tutabilir mi, ve hangi katsayıyla. §4.4'ün türetilmiş atanabilirlik
## tablosu BU FONKSİYONDAN çıkar; ayrıca saklanmaz (§15.2).
## Döner: 1.0 ana alan · SECONDARY_AREA_MULT ikincil · 0.0 alanı yok.
static func job_coefficient(role_id: String, job_id: String, category: String = "employee") -> float:
	if category == "founder":
		return 1.0 if is_job(job_id) else 0.0
	var key: String = role_key_area(role_id)
	var sec: String = role_secondary_area(role_id)
	var best: float = 0.0
	for area_id in job_areas(job_id):
		if String(area_id) == key:
			return 1.0
		if sec != "" and String(area_id) == sec:
			best = SECONDARY_AREA_MULT
	return best


static func can_hold_job(role_id: String, job_id: String, category: String = "employee") -> bool:
	return job_coefficient(role_id, job_id, category) > 0.0


## §12.1 odak katsayısı, atanmış iş sayısından.
static func focus_mult(job_count: int) -> float:
	return FOCUS_MULT_SINGLE if job_count <= 1 else FOCUS_MULT_SPLIT


## ALAN → o alanın BİRİNCİL işi. TEK EV (§15.2): hem v6→v7 göçü hem de eski alan yazma
## yolunun adaptörü buradan okur, yoksa iki yerde iki farklı "engineering hangi işe düşer"
## cevabı olurdu.
##
## Çoğu alan iki işe girebilir (engineering hem Build hem Destek taşır); bu tablo
## AMBİGÜİTEYİ ÇÖZER, işleri saymaz. Kişiyi başka bir işe taşımak Görevler matrisinin işi.
## `research` bilerek "" döner: §12.0 Araştırma'yı atama hedefi olmaktan çıkardı.
const AREA_PRIMARY_JOB := {
	"product": "build",
	"design": "build",
	"engineering": "build",
	"qa": "test",
	"customer_success": "accounts",
	"sales": "sales",
}


static func primary_job_for_area(area_id: String) -> String:
	return String(AREA_PRIMARY_JOB.get(area_id, ""))


## Yeni işe alınanın oturduğu iş. §12.2 "Boşta çalışan maaş yemeye devam eder" doğrudur ama
## bir İŞE ALIM oyuncunun bununla tanışmak isteyeceği an değildir — parayı yeni ödedi.
static func default_job_for_role(role_id: String) -> String:
	return primary_job_for_area(default_area_for_role(role_id))


## Bir kişinin işlerinden TÜRETİLEN alan listesi — eski `assigned_jobs` alanının içeriği.
## Kişinin gerçekten taşıdığı alanlara daraltılır: bir developer Destek'te çalışırken
## Yazılım üzerinden çalışır ve Müşteri İlişkileri KAZANMAZ (§4.4).
static func areas_for_jobs(role_id: String, category: String, job_ids: Array) -> Array:
	var out: Array = []
	var owned: Array = []
	if category == "founder":
		owned = AREAS.duplicate()
	else:
		var key: String = role_key_area(role_id)
		var sec: String = role_secondary_area(role_id)
		if key != "":
			owned.append(key)
		if sec != "":
			owned.append(sec)
	for job_id in job_ids:
		for area_id in job_areas(String(job_id)):
			if owned.has(String(area_id)) and not out.has(String(area_id)):
				out.append(String(area_id))
	return out

# --- Aşırı yüklenme (rev 2 §5). Every number [WORKING]; §11 lists them as open. ---
# "Aşırı yük kısa süre tolere edilir, uzun sürerse moral düşer ve kaçma riskine gider."
const OVERLOAD_TOLERANCE_DAYS := 5      # [WORKING] grace before the cost starts
const OVERLOAD_OUTPUT_MULT := 0.75      # [WORKING] output while carrying 2+ jobs
const OVERLOAD_MORALE_MULT := 1.6       # [WORKING] multiplier on NEGATIVE morale deltas
## §4.3 ikincil alan ×0,8 — 0,6 DEĞİL ve gerekçe belgede: kişinin o alandaki zayıflığı
## zaten yıldızlarında yazılı, katsayının işi onu ikinci kez kesmek değil rol kimliğini
## korumak. (0,7 idi; rev 11 §4.3 sayıyı mühürledi.)
const SECONDARY_AREA_MULT := 0.8


static func role_key_area(role_id: String) -> String:
	var row: Dictionary = ROLE_AREAS.get(role_id, {})
	return String(row.get("key", ""))


static func role_secondary_area(role_id: String) -> String:
	var row: Dictionary = ROLE_AREAS.get(role_id, {})
	return String(row.get("secondary", ""))


static func is_assignable(area_id: String) -> bool:
	return AREAS.has(area_id)


static func default_area_for_role(role_id: String) -> String:
	## Where a fresh hire lands so nobody is born idle: their own key area. Replaces
	## ROLE_DEFAULT_JOB, which had to name a job because three areas shared one.
	return role_key_area(role_id)


static func can_hold_area(role_id: String, area_id: String, category: String) -> bool:
	## The skin's "ALANI YOK · ATANAMAZ" cell, as a rule. An employee may only work their
	## KEY or SECONDARY area — which is exactly why every other column in the matrix is drawn
	## dashed and refuses the click. The founder has no role and no key area, so all seven are
	## his; ch. 02 §5 limits him by COUNT (one at a time), never by which one.
	if not is_assignable(area_id):
		return false
	if category == "founder":
		return true
	return area_id == role_key_area(role_id) or area_id == role_secondary_area(role_id)


static func stars_for(points: int) -> float:
	## Points -> stars, the single mapping. Half stars are real: POINTS_PER_STAR is 2, so an
	## odd number renders as a half-inked glyph instead of rounding a whole star away.
	return clampf(float(points) / float(POINTS_PER_STAR), 0.0, float(STAR_MAX))


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


static func area_fatigue_mult(role_id: String, area_id: String) -> float:
	## rev 2 §5: "ana alanında çalışmak normal, ikincil alanında çalışmak daha yorucudur."
	## No lookup left to do — the assignment IS an area now. The founder has no key/secondary
	## split, so he is never charged the secondary rate.
	if role_id == "" or role_id == ROLE_FOUNDER:
		return 1.0
	if area_id == role_key_area(role_id):
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

# KADRO GRUPLARI — §13.1'in DÖRT BANDI, ve modülün TEK insan taksonomisi.
#
# Yanında iki tane daha vardı ve ikisi de gitti: DEPARTMAN (üç tane) yalnız ek mesai
# BLOKLARININ birimiydi ve §8.2 blokları kaldırdı; BÖLÜM (üç tane) hiç çağrılmamıştı ve
# strings.csv'de karşılığı bile yoktu, yani section_label ham id döndürürdü. §15.2 tek
# kaynak istiyor, ve §8.1 grubu ikinci bir tüketiciye — çalışma saati kapsamına — bağlayınca
# hangisinin kalacağı da belli oldu.
const GROUP_PRODUCT_DESIGN := "product_design"
const GROUP_DEVELOPMENT := "development"
const GROUP_SALES := "sales"
const GROUP_CUSTOMER_SUCCESS := "customer_success"
const ROSTER_GROUPS := ["product_design", "development", "sales", "customer_success"]
const ROLE_GROUP := {
	"product_manager": "product_design",
	"designer": "product_design",
	"developer": "development",
	"tester": "development",
	"sales_rep": "sales",
	"customer_rep": "customer_success",
}
## Never let a raw internal code reach the screen: an unknown id screams in the log and
## falls back to itself, so a typo surfaces there rather than silently in the UI.
static func role_label(role_id: String) -> String:
	if not ROLE_GROUP.has(role_id) and role_id not in [ROLE_FOUNDER, ROLE_MENTOR]:
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


static func group_label(group_id: String) -> String:
	return _derived("HR_GROUP_", group_id)


static func roles_in_group(group_id: String) -> Array:
	var out: Array = []
	for role_id in EMPLOYEE_ROLES:
		if String(ROLE_GROUP.get(role_id, "")) == group_id:
			out.append(role_id)
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


## §10.6 · ATLAS'IN İKİ KİLİTLİ-GÖRÜNÜR KARTI. "Kartlar çizilir, sönüktür, tıklanamaz, kilit
## gerekçesini gösterir. Kilitli kart GİZLENMEZ. Oyuncu tam sürümde ne geleceğini burada
## görür."
##
## EMPLOYEE_ROLES'A GİRMEZLER, kasten: o dizi altı id'de sözleşmeyle sabit ve
## HRCandidateGenerator.seed_for indeksini ondan türetiyor — araya bir id sokmak oyundaki
## HER aday havuzunu sessizce yeniden kararırdı. Bunlar rol DEĞİL, vitrin.
const FUTURE_ROLES := ["marketing", "hr_inhouse"]
const FUTURE_ROLE_LOCK_KEY := "HR_ROLE_LOCK_FULL_VERSION"


static func is_future_role(role_id: String) -> bool:
	return FUTURE_ROLES.has(role_id)


static func future_role_label(role_id: String) -> String:
	return _derived("HR_ROLE_", role_id)


static func future_role_hint(role_id: String) -> String:
	return _derived("HR_ROLE_HINT_", role_id)


# ================================== Traits ===================================
# Trait'ler skill tekrarı DEĞİL davranış tanımıdır. SEKİZ TRAIT (2026-08-21, onaylı
# ikon sayfası + Erdem R3): on trait sekize indi, adları ve etkileri sayfadan geldi.
# Gizli trait YOKTUR — hepsi aday dosyasında etkisiyle birlikte yazar.
#
# `polarity` EMEKLİ, yerine `carries_cost` (R4). İki sebep, ikisi de ölçüldü:
#   1. Trait'ler iyi ya da kötü DEĞİLDİR; yeşil/kırmızı rozet ayrımı kalktı ve
#      HİÇBİR ÇİZİM bu alanı okumuyor — tek okuyucu aday üreticisi.
#   2. Üretici yine de bir ayrım istiyor ("bir dosya daha sert olanı taşır"), ve o
#      ayrım artık görevin kendi tablosundan TÜRETİLMİŞ: Cost sütunu dolu olan beş
#      trait `carries_cost = true`, boş olan üçü false. İcat edilmiş bir sınıflama değil.
#
# Effect keys and who reads them (Ö = bu turda bağlandı):
#   resign_chance_mult      HRMoraleSystem — istifa roll'unun çarpanı
#   overtime_morale_mult  Ö HROvertimeSystem — YALNIZ mesai moral bedeli
#   experience_mult       Ö HRSystem.tick_experience — kendi deneyim kazancı
#   lead_experience_mult  Ö HRSystem.tick_experience — SORUMLUSU olduğu alandakiler
#   departure_morale_extra Ö HRMoraleSystem — ayrılışın ekibe EK moral bedeli
#   bug_rate_mult         Ö ProductSystem._accrue_bugs_hourly
#   speed_mult            Ö ProductSystem._phase_area_sum — kişinin katkı çarpanı
#   output_mult           Ö ProductSystem._phase_area_sum — aynı yer, ters yön
#   promise_chance_mult   Ö PromiseRegistry — söz olaylarının bu kişide ateşlenme oranı
#   satisfaction_bonus    Ö CustomerRepSystem — hesaplarında memnuniyet
#   dept_morale_decay_mult Ö HRMoraleSystem — ekibinin moral ERİME hızı
#
# EMEKLİ EKSENLER: morale_floor · morale_drop_mult · dept_morale_weekly ·
# coordination_bonus · no_team_bonus · non_lead_mult. Taşıyan trait kalmadı.
#
# Copy fields (label / effect_text) LEFT this table for strings.csv; what remains is the
# MECHANICS. The words are derived from the trait id — HR_TRAIT_<ID>_LABEL / _EFFECT —
# so a trait cannot exist with a label in one language only.
#
# KALİBRASYON YÜZEYİ: aşağıdaki her sayı ya emekli bir trait'in AYNI büyüklüğü, ya da
# yeni bir eksen için ilk değer. Hiçbiri ölçülmüş değil; teslimde liste veriliyor.
const TRAITS := {
	# --- bedelsiz üç ------------------------------------------------------
	"loyal": {                                # SADIK
		"carries_cost": false,
		"resign_chance_mult": 0.6,            # `wont_jump_ship`'in büyüklüğü, birebir
	},
	"picks_it_up_fast": {                     # ÇABUK KAPAR
		"carries_cost": false,
		"experience_mult": 1.5,               # YENİ eksen — "belirgin şekilde hızlı"
	},
	"last_one_out": {                         # İŞKOLİK
		"carries_cost": false,
		"overtime_morale_mult": 0.5,          # `pressure_proof`'un büyüklüğü, ama
		                                      # YALNIZ mesaide (o hepsinde geçerliydi)
	},
	# --- bedelli beş -------------------------------------------------------
	"takes_them_under": {                     # GERÇEK LİDER
		"carries_cost": true,
		"lead_experience_mult": 1.5,          # YENİ — picks_it_up_fast ile aynı kademe
		"departure_morale_extra": -5,         # §: başkaları −5 alırken bunlar −10
	},
	"double_checker": {                       # TİTİZ
		"carries_cost": true,
		"bug_rate_mult": 0.5,                 # YENİ — "çok daha az hata"
		"speed_mult": 0.85,                   # YENİ — hız bedeli
	},
	"cant_say_no": {                          # HAYIR DİYEMEZ
		"carries_cost": true,
		"promise_chance_mult": 1.6,           # YENİ — one_foot_out'un kademesi
		"satisfaction_bonus": 5,              # YENİ — hesaplarında memnuniyet
	},
	"bag_packed": {                           # GÖZÜ YÜKSEKTE
		"carries_cost": true,
		"resign_chance_mult": 1.6,            # `one_foot_out`'un büyüklüğü, birebir
		"output_mult": 1.15,                  # YENİ — "yüksek verim"
	},
	"mood_buster": {                          # TAT KAÇIRAN
		"carries_cost": true,
		"dept_morale_decay_mult": 1.25,       # YENİ — "hafifçe" yükseltir
		# ŞİKAYETİN KENDİSİ (olay kartı) BAĞLANMADI: içerik henüz yazılmadı.
	},
}

# Employee trait formula — DELIBERATELY NOT FounderConstants' formula (that one is
# founder-specific: 2 positives force exactly 1 negative). Employees: 1-2 positive,
# at most 1 negative, and roughly half of generated candidates carry that negative.
## TEK TRAIT (2026-08-22). Onaylı tasarım herkeste bir tane çiziyor — defterin TRAIT
## sütununda bir ikon, aday kartında bir çip — ve dosyalardan birinin tek trait'i OLUMSUZ
## (11b · Kerem Çetin · HAVAYI BOZAR). Eski kural en az bir OLUMLU istiyordu, yani "yalnız
## olumsuz" bir dosya geçersizdi; artık bir kişi TAM BİR trait taşır ve o trait iki
## kutuptan biri olabilir. Bir aday artık saf bir yük olabilir — bu bilinçli bir denge
## kararıydı (Erdem 2026-08-22), yan etkisi değil.
##
## KURUCU ETKİLENMEZ: FounderConstants.validate_traits ayrı bir formül ve Kişisel kartı
## (10a) kurucuda İKİ trait çiziyor.
const TRAIT_COUNT := 1
## ÜRETİCİNİN tek ayarı. TRAIT_MIN/MAX_POSITIVE emekli — ikisi de tanımlıydı ve
## HİÇBİR YERDE OKUNMUYORDU (2026-08-21 taraması).
const TRAIT_MAX_COST := 1
const TRAIT_COST_SHARE := 0.5   # üretilen adaylarda BEDELLİ trait taşıma oranı


static func trait_label(trait_id: String) -> String:
	return _derived("HR_TRAIT_", trait_id + "_LABEL")


static func trait_effect_text(trait_id: String) -> String:
	if not TRAITS.has(trait_id):
		return ""
	return _derived("HR_TRAIT_", trait_id + "_EFFECT")


## Bedelli mi — YALNIZ aday üreticisi okur. Bir çizim bunu okuyorsa R4 ihlalidir.
static func trait_carries_cost(trait_id: String) -> bool:
	return bool((TRAITS.get(trait_id, {}) as Dictionary).get("carries_cost", false))


static func free_trait_ids() -> Array:
	var out: Array = []
	for trait_id in TRAITS.keys():
		if not bool(TRAITS[trait_id].get("carries_cost", false)):
			out.append(trait_id)
	out.sort()   # deterministic order — the generator indexes into this
	return out


static func cost_trait_ids() -> Array:
	var out: Array = []
	for trait_id in TRAITS.keys():
		if bool(TRAITS[trait_id].get("carries_cost", false)):
			out.append(trait_id)
	out.sort()
	return out


static func validate_employee_traits(trait_ids: Array) -> bool:
	## TAM BİR geçerli trait, kutbu serbest (bkz. TRAIT_COUNT). Sayı kuralının kendisi
	## sabitten okunuyor ki bir sonraki tasarım turu iki'ye çıkarmak isterse tek yer değişsin.
	if trait_ids.size() != TRAIT_COUNT:
		return false
	var seen: Array = []
	for trait_id in trait_ids:
		var tid: String = String(trait_id)
		if not TRAITS.has(tid):
			return false
		if seen.has(tid):
			return false   # no duplicates
		seen.append(tid)
	return true


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


# ============================ Salary bands (Atlas) ===========================
# Bütçe bandı üç AYRIK seçenektir, slider değil (design doc §2). Rol × tier → aylık
# maaş aralığı; üç aday da bandın içinde ve birbirine yakın maaş ister.
# ==================== SEVİYELER — §3, §9.1, §10.2 ============================
# BANT DEĞİL SEVİYE. Yukarıdaki BAND_* bir BÜTÇE seçeneğiydi ve işe alımda ATILIYORDU:
# aday üretilirken okunuyor, Character'a hiç yazılmıyordu. §3 onu bir ALAN yapıyor — her rol
# üç seviyede bulunur, seviye kişide saklanır, terfinin değiştirdiği alan budur (§15).
# BAND_* Faz 5b'de Atlas çevrilene kadar duruyor (Faz 7 silme listesinde).
const LEVEL_JUNIOR := 0
const LEVEL_MID := 1
const LEVEL_SENIOR := 2
const LEVELS := [0, 1, 2]

## §3 unvan TÜRETİLİR, saklanmaz: unvan = ön ek + rol adı; ORTA seviyede ön ek YOKTUR.
## §3.1: Junior iki dilde de "Junior" kalır ("Kıdemsiz" ve "Yeni Mezun" kullanılmaz);
## Kıdemli'nin İngilizcesi "Senior".
const LEVEL_PREFIX_KEYS := {0: "HR_LEVEL_PREFIX_JUNIOR", 1: "", 2: "HR_LEVEL_PREFIX_SENIOR"}

## Seviyenin ADI — ön ekinden AYRI. §3'ün tablosu ikisini ayrı sütunda tutuyor: Orta'nın
## ön eki YOKTUR ama adı vardır ve Atlas'ın seçim şeridi adı gösterir. Onaylı 16. turun
## "Uzman / Specialist" etiketi §3'ün karşısındaydı; §3 kazanır.
const LEVEL_NAME_KEYS := {0: "HR_LEVEL_JUNIOR", 1: "HR_LEVEL_MID", 2: "HR_LEVEL_SENIOR"}


static func level_label(level: int) -> String:
	return TranslationServer.translate(
		String(LEVEL_NAME_KEYS.get(clampi(level, LEVEL_JUNIOR, LEVEL_SENIOR), "")))


## Bir seviye id'sinin geçerliliği — start_search ve üretici aynı kapıdan geçer.
static func is_level(level: int) -> bool:
	return LEVELS.has(level)


static func level_prefix(level: int) -> String:
	var key: String = String(LEVEL_PREFIX_KEYS.get(clampi(level, LEVEL_JUNIOR, LEVEL_SENIOR), ""))
	return "" if key == "" else TranslationServer.translate(key)


## Unvanın TEK evi. Kadro satırı, aday kartı, terfi modali ve Kişisel hep buradan okur;
## hiçbiri ön ekle rol adını kendi birleştirmez.
static func job_title(role_id: String, level: int) -> String:
	var prefix: String = level_prefix(level)
	var name: String = role_label(role_id)
	return name if prefix == "" else "%s %s" % [prefix, name]


## §9.1 MAAŞ BANTLARI — TEK KAYNAK (§15.2). İşe alım, terfi ve zam önizlemesi aynı tablodan
## okur. Hiyerarşi §9.1'den: Yazılım Mühendisi en üstte · Ürün Yöneticisi ve Test Mühendisi
## eşit, altında · UX/UI Designer, Satış Temsilcisi ve Müşteri Temsilcisi eşit, en altta.
## Bantlar sınırlarda KASTEN örtüşür — güçlü bir junior ile zayıf bir orta aynı parayı
## isteyebilir; yarım yıldız sisteminin fiyatlayacağı yer burasıdır. Aylık USD, 1:1.
const SALARY_BANDS_BY_LEVEL := {
	"developer":       [[2000, 3000], [3000, 6000], [6000, 10000]],
	"product_manager": [[1800, 2700], [2700, 5400], [5400, 9000]],
	"tester":          [[1800, 2700], [2700, 5400], [5400, 9000]],
	"designer":        [[1500, 2250], [2250, 4500], [4500, 7500]],
	"sales_rep":       [[1500, 2250], [2250, 4500], [4500, 7500]],
	"customer_rep":    [[1500, 2250], [2250, 4500], [4500, 7500]],
}


static func salary_band_for_level(role_id: String, level: int) -> Array:
	var per_role: Array = SALARY_BANDS_BY_LEVEL.get(role_id, SALARY_BANDS_BY_LEVEL["developer"]) as Array
	return (per_role[clampi(level, LEVEL_JUNIOR, LEVEL_SENIOR)] as Array).duplicate()


## Bir maaşın hangi seviyeye düştüğü — göç ve terfi önizlemesi için. Bantlar örtüştüğü için
## EN YÜKSEK uyan seviye kazanır.
static func level_for_salary(role_id: String, monthly_salary: int) -> int:
	for lvl in [LEVEL_SENIOR, LEVEL_MID]:
		if monthly_salary >= int(salary_band_for_level(role_id, int(lvl))[0]):
			return int(lvl)
	return LEVEL_JUNIOR


# ------------------------- §10.2 aday arketipleri ----------------------------
# Üç aday RASTGELE üretilmez; her aramada sabit bir üçlü çekilir, çünkü amaç oyuncunun her
# aramada GERÇEK ve savunulabilir bir karar vermesidir.
const ARCHETYPE_UZMAN := "uzman"        # ana alanda üçlünün en yükseği, diğerleri zayıf
const ARCHETYPE_DENGELI := "dengeli"    # tepe noktası yok, ana ve ikincilde makul
const ARCHETYPE_PAZARLIK := "pazarlik"  # bir alanda gerçekten iyi, en az birinde kırık
const ARCHETYPES := ["uzman", "dengeli", "pazarlik"]

## [ANA ALAN, İKİNCİL ALAN, DİĞER HER ALAN] — seviye başına. Taban L = 3 · 5 · 7; Uzman ve
## Pazarlık ana alanda L+2, Dengeli L. Üçlü arasındaki ana alan farkı böylece TAM OLARAK
## 1 yıldız (2 ham puan): §10.2'nin tavanı, aşılmadan kullanılıyor. Adaylar
## karşılaştırılabilir kalmalı — biri diğerinden iki yıldız iyiyse seçim ortadan kalkar.
## ANA >= İKİNCİL >= DİĞER, üç arketipte de. Junior Uzman'ın ikincili bir tur boyunca
## DİĞER ALANLARIN ALTINDAYDI ([5, 0, 1]) — yani rolünün TAŞIDIĞI alanda taşımadığı
## alanlardan zayıftı. §4.3 ikincili rolün kendi alanı sayıyor (×0,8); orada alakasız bir
## alanın altına düşmek şeklin anlamını çeliyordu. Sayılar aynı kaldı, sıra düzeldi.
const ARCHETYPE_SHAPE := {
	0: {"uzman": [5, 1, 0], "dengeli": [3, 2, 2], "pazarlik": [5, 0, 0]},
	1: {"uzman": [7, 2, 2], "dengeli": [5, 4, 3], "pazarlik": [7, 1, 1]},
	2: {"uzman": [9, 4, 3], "dengeli": [7, 6, 5], "pazarlik": [9, 3, 2]},
}


static func archetype_shape(level: int, archetype: String) -> Array:
	var per_level: Dictionary = ARCHETYPE_SHAPE.get(clampi(level, LEVEL_JUNIOR, LEVEL_SENIOR), ARCHETYPE_SHAPE[1]) as Dictionary
	return ((per_level.get(archetype, per_level["dengeli"])) as Array).duplicate()


## §10.2 fiyat kuralları. Dengeli üçlünün EN PAHALISI (tepe yok ama hiçbir yeri kırık da
## değil), Pazarlık en ucuzu. Fark %20–45: alt sınır kararı anlamlı yapar, üst sınır
## "pahalı olan zaten daha iyi" refleksini engeller. Eski tek üst sınır (%15) §10.2'nin ALT
## sınırının bile altındaydı — üç dosya birbirine o kadar yakın fiyatlanıyordu ki fiyat bir
## kaldıraç olmaktan çıkıyordu.
const SALARY_SPREAD_MIN_R11 := 0.20
const SALARY_SPREAD_MAX_R11 := 0.45

## §10.2 FİYAT SIRASI. Dengeli üçlünün EN PAHALISI, Pazarlık en ucuzu, Uzman "orta–yüksek" —
## tablonun kendi üç kelimesi. Uzman'ın en ucuz ile en pahalı arasındaki YERİ bir kalibrasyon
## sayısıdır: 0,6 onu tepeye yakın tutar ("orta–yüksek"), 0,5 ortaya koyardı ve tabloyu
## yalanlardı. Aradaki iki boşluk da yuvarlama adımından (50) büyük, yani üç dosya ASLA aynı
## rakama düşmez: en dar hâlde 1500 × 0,20 × 0,6 = 180 ve 1500 × 0,20 × 0,4 = 120.
const ARCHETYPE_PRICE_UZMAN_SHARE := 0.6

## §10.2 LİDERLİK — arketipin kendi "diğer alanlar" değerinden DEĞİL, SEVİYEDEN okunur.
## Türetilmiş hâlinde Uzman ile Pazarlık junior'da Liderlik'te berabere kalıyordu ve üçlünün
## bu ekseni tamamen ölüydü; seviyeden okumak onu üç ayrı değere açar. Dağılım tablonun
## kendi sıfatlarından: Dengeli en iyi lider ("genellikle güvenli", tepe noktası yok ama
## hiçbir yeri kırık da değil), Uzman en zayıfı (dar olmak arketipin kendisidir), Pazarlık
## ortada.
##
## HÂKİMİYETİ KIRAN ŞEY BU DEĞİLDİR — ölçüldü. Non-dominance'ı fiyat sırası ve rotasyon
## bump'ı taşıyor (endgame_smoke._case_hr_candidate_invariants'in falsifikasyon notu). Bu
## satırın gerekçesi tasarımdır, bir invariant değil.
const LEVEL_LEAD_BASE := [1, 2, 3]
const ARCHETYPE_LEAD_OFFSET := {"uzman": -1, "dengeli": 1, "pazarlik": 0}


static func archetype_leadership(level: int, archetype: String) -> int:
	var base: int = int(LEVEL_LEAD_BASE[clampi(level, LEVEL_JUNIOR, LEVEL_SENIOR)])
	return clampi(base + int(ARCHETYPE_LEAD_OFFSET.get(archetype, 0)), AREA_MIN, AREA_MAX)


## §10.2 huy rolleri, tablodan: Pazarlık "genellikle bedelli huy taşır" -> HER ZAMAN taşır,
## çünkü ayırt edici eksen huydur ve TRIO_COST_TRAIT_MIN'i garantiyle karşılayan tek yol
## budur. Uzman "nötr ya da HAFİF RİSKLİ" -> seed'e bağlı bir yazı-tura. Dengeli "genellikle
## güvenli" -> hep bedelsiz: üçlünün karşıtlığını çizen şey buysa, Dengeli'nin de bazen bedel
## taşıması o karşıtlığı bulandırır.
const UZMAN_COST_TRAIT_CHANCE := 0.35

## §10.2 beş yıldızlı aday: NADİR, yalnız Kıdemli bantta, maaş talebi bandın TAVANINDA.
const FIVE_STAR_CHANCE := 0.08
## §10.2 ayırt edici eksen HUYDUR: üçlüden en az biri bedelli bir huy taşır — olasılık
## değil GARANTİ; üretimden sonra kontrol edilir.
const TRIO_COST_TRAIT_MIN := 1
# Bant adları BÜTÇE SEVİYESİ söyler, havuz boyutu değil — aday sayısı her bantta
# CANDIDATE_COUNT'tur ("dar havuz" daha az aday İMA ettiği için emekli edildi).
# WORKING TR (voice pass later).


# ========================= Search (Atlas Seçme & Yerleştirme) ================
# Çift ücret (design doc §2, KANON): peşin retainer + işe alımda komisyon.
# The agency is a PROPER NOUN and stays itself in both languages, on the same rule that
# keeps "Ekonomi Postası" untranslated on the ending gazette (glossary §6). It is a CSV
# row so it is not residue, but the row carries the same value twice.
static func search_agency_name() -> String:
	return TranslationServer.translate("HR_AGENCY_NAME")
## §10 TEK ÜCRET. "Aday araması Atlas Recruitment modalinden yürür ve ÜCRETSİZDİR."
## Peşin retainer SİLİNDİ: Atlas modali, iki uyarı satırı ve tahsilat yolu birlikte gitti.
## §10: "bir aylık maaşın %50'si komisyon olarak ödenir. $3.000'lik bir çalışanın maliyeti
## $4.500'dür." 0,15'ti; tek ücret modeli farkı komisyona yüklüyor.
const SEARCH_COMMISSION_PCT := 0.50
## §10: "Arama başlatıldıktan BİR HAFTA sonra aday listesi gelir." Aralık değil, TEK SAYI.
## Gecikme kastedilmiştir: bir çalışan ayrıldığında oyuncu boşluğu o gün kapatamaz.
const SEARCH_ARRIVAL_DAYS := 7
const CANDIDATE_COUNT := 3              # her arayış üç dosya getirir

# ========================= ÇALIŞMA SAATLERİ — §8 =============================
# AYRI BİR "EK MESAİ" MEKANİĞİ YOKTUR (§8.2). Ek mesai çalışma aralığının bir SONUCUDUR:
# kişinin devraldığı süre sekizi aşarsa mesaidir, altına inerse kısa gündür. Getiri saatin
# kendisidir (§8.4) — ayrı bir hız çarpanı yok, ayrı bir kalite cezası yok.
#
# Aşağıdaki "Ek mesai (departman bazlı)" bloğu — bloklar, hız bonusu, bug çarpanı, %40
# gecelik ücret, emniyet valfi — HÂLÂ DURUYOR ve bilerek duruyor: ürün, satış, CS, finans ve
# ODA onu okuyor. Tüketiciler Faz 3'te bu modele çevrilir, blok sistemi Faz 7'de silinir.
const WORK_HOURS_MIN := 5           # §8.1 en kısa gün
const WORK_HOURS_MAX := 11          # §8.1 en uzun gün — İş Kanunu md.63'ün günlük sınırı
const WORK_HOURS_DEFAULT := 8       # §8.1 şirket kapsamı varsayılanı; herkes bunu devralır
const WORK_HOURS_STEP := 1          # tam saat — yarım saat yoktur

## §8.1: başlangıç saati YALNIZ şirket kapsamındadır. Grup ve çalışan yalnız SÜREYİ
## değiştirir, başlangıcı değil — ofis tek saatte açılır, değişen kimin ne zaman çıktığıdır.
const START_HOUR_DEFAULT := 9
const START_HOUR_MIN := 6
const START_HOUR_MAX := 11

## §7.1'in YEDİ SATIRLIK tablosu — TEK EV (§15.2). Modalin gösterdiği kademe ifadesi,
## kontrolün izin verdiği aralık ve motorun uyguladığı çarpan hep buradan okunur.
## Çarpan TABAN moral sürüklenmesine uygulanır; sıfırın altına indiğinde işaret döner ve
## moral YÜKSELMEYE başlar. Eğri yukarı doğru hızlanır (ilk saat ucuz, üçüncü saat pahalı),
## aşağı doğru üç okunaklı dönüm noktası taşır: yedide durur, altıda yükselir, beşte
## belirgin yükselir.
const HOUR_MORALE_MULT := {
	5: -1.0,
	6: -0.5,
	7: 0.0,
	8: 1.0,
	9: 1.1,
	10: 1.3,
	11: 1.5,
}

## §12.1 aşırı yük çarpanı. Çarpanlar ÇARPILIR, toplanmaz: 11 saat + aşırı yük = ×2,25.
## (Eski OVERLOAD_MORALE_MULT 1.6 yukarıda duruyor ve REPO'DA TEK OKUYUCUSU YOKTU —
## kendi bildirimi dışında hiçbir yerde geçmiyordu. Bu sabit onun YERİNE geçen, gerçekten
## okunan olanı; eskisi Faz 7'de silinir.)
const OVERLOAD_MORALE_MULT_R11 := 1.5

## §8.2 ek mesai ücreti: aşan saatler için saatlik ücretin %50 fazlası. YALNIZ aşan saatler;
## ilk sekiz saat normal ücrettir. Dayanak İş Kanunu md.41'in zorunlu %50 zammı.
const OVERTIME_WAGE_MULT := 1.5

## Aylık maaş → saatlik ücret dönüşümünün TEK sabiti (§8.2, §15.2). 22 iş günü × 8 saat.
## Ek mesai hesabı, modaldeki burn önizlemesi ve Finans'ın tahakkuku aynı sayıdan okur;
## maaş kaydında saatlik ücret alanı YOKTUR, saklanan tek rakam aylık maaştır.
## §8.4 SAATİN ÇIKTIYA ORANI. Standart gün 1,0'dır — yani sekiz saatte hiçbir şey ölçek
## değiştirmez ve Ürün/Satış/CS'nin bütün kalibre sabitleri olduğu gibi kalır. Ham saatle
## çarpmak (§4.5'in harfi) aynı sabitlerin hepsini sekizle çarpardı, ki bunun bir tasarım
## gerekçesi yok; §8.1 ve §8.3 zaten ORANI veriyor ve bu fonksiyon tam olarak o iki sayıyı
## üretiyor: 11 saat → 1,375 ("en fazla +%37,5 çıktı"), 5 saat → 0,625 ("sekiz saatlik günün
## %62,5'i kadar iş").
static func hours_output_mult(hours: int) -> float:
	return float(clampi(hours, WORK_HOURS_MIN, WORK_HOURS_MAX)) / float(WORK_HOURS_DEFAULT)


const HOURS_PER_MONTH := 176


static func hour_morale_mult(hours: int) -> float:
	return float(HOUR_MORALE_MULT.get(clampi(hours, WORK_HOURS_MIN, WORK_HOURS_MAX), 1.0))


static func is_overtime_hours(hours: int) -> bool:
	return hours > WORK_HOURS_DEFAULT


static func is_short_day_hours(hours: int) -> bool:
	return hours < WORK_HOURS_DEFAULT


static func hourly_wage(monthly_salary: int) -> float:
	return float(maxi(monthly_salary, 0)) / float(HOURS_PER_MONTH)


## Bir günün ek mesai TAHAKKUKU. Yalnız sekizin üstündeki saatler, %50 fazlasıyla.
## İzindeki/eğitimdeki çalışan için çağrılmaz (§8.6): mesai ücreti tahakkuk etmez.
static func overtime_pay_for_day(monthly_salary: int, hours: int) -> int:
	var extra: int = maxi(hours - WORK_HOURS_DEFAULT, 0)
	if extra <= 0:
		return 0
	return int(round(hourly_wage(monthly_salary) * float(extra) * OVERTIME_WAGE_MULT))

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

## §7 BANTLARI — TEK EV (§15.2). Moral YALNIZ hızı etkiler: kaliteye, hata üretimine ya da
## yıldızlara dokunmaz, çünkü kalite zaten yıldızlarda ve TİTİZ huyunda temsil ediliyor.
## §7 DÖRT BAND, ÜÇ ROZET. TÜKENİYOR (40 eşiği) rev 2'nindi ve rev 11 onu saymıyor; sabiti,
## karşılaştırıcısı ve rozeti birlikte gitti. Eskiden burada duran not, sabiti okuyan
## yüzeyler Faz 5a'da çevrilene kadar derlenmeye devam etmeli (Faz 7 silme listesinde).
const MORALE_BAND_HIGH := 80        # ve üstü → +%10 hız
const MORALE_BAND_LOW := 50         # altı → −%15 hız
const MORALE_BAND_HIGH_MULT := 1.10
const MORALE_BAND_MID_MULT := 1.0
const MORALE_BAND_LOW_MULT := 0.85

## Taban günlük düşüş. §7.1'in saat çarpanı YALNIZ buna uygulanır — olay deltaları ham
## gelir, ham uygulanır, yoksa tek bir saat ayarı moral sistemini tamamen kapatırdı.
##
## 0,25 = ayda 7,5 puan; sekiz saatlik günde 75'ten 35'e ~160 gün. Sekiz saat böylece bir
## geri sayım değil HAFİF bir baskı olur, yedi saat de zorunlu olmayan gerçek bir rahatlama
## kalır — oyuncu kadranı kullanmaya devam eder. (Erdem 2026-08-23; 0,5 denendi ve aşırı
## yük senaryosunu 36 güne indiriyordu ama bunu baskı altında OLMAYAN herkesi iki kat hızlı
## eriterek satın alıyordu. 0,25'te o senaryo 72 gün — hâlâ bir koşuda rahat görülür.)
## §4.2 LİDERLİK KATSAYILARI. Ayrım kasıtlıdır ve GDD gerekçesini yazıyor: liderlik bir
## ÜRETİM istatistiği değil bir İNSAN istatistiğidir. Çıktı tarafı ölçülü tutulur ki moral
## bandı modülün birincil hız kaldıracı olarak kalsın; moral tarafı cömert tutulur ki
## "iyi lider ekibi ayakta tutar" gerçekten hissedilsin.
##   yarım yıldız (= 1 ham puan) başına: çıktı +%1 · moral düşüş hızı −%2
##   beş yıldızda (10 ham puan):        çıktı +%10 · moral düşüş hızı −%20
## YÜZDELER EKRANDA GÖRÜNMEZ (§4.2): oyuncu sebebi görür, katsayıyı görmez.
const LEAD_OUTPUT_PER_POINT := 0.01
const LEAD_MORALE_PER_POINT := 0.02

const MORALE_BASE_DRIFT_PER_DAY := 0.25

## §7 "hedefe doğru sürüklenir, anında sıçramaz". Delta HEDEFE yazılır; görünen moral
## hedefe doğru günde en fazla bu kadar yürür. −15'lik bir olay beş günde iner ve
## oyuncunun tepki penceresi budur.
const MORALE_EASE_PER_DAY := 3.0

const MORALE_LEAVE_DEFER := 5            # §11.4 erteleme bedeli
const MORALE_PROMOTION_AT_MIN_PCT := 8   # %10 terfi zammında
const MORALE_PROMOTION_AT_MAX_PCT := 20  # %25 terfi zammında — onaylı 2b: %15 → +12


static func morale_band_mult(morale: int) -> float:
	if morale >= MORALE_BAND_HIGH:
		return MORALE_BAND_HIGH_MULT
	if morale < MORALE_BAND_LOW:
		return MORALE_BAND_LOW_MULT
	return MORALE_BAND_MID_MULT


## §15.3 hr.morale_band(kişi) — bant KİMLİĞİ, sayı değil.
static func morale_band_id(morale: int) -> String:
	if morale >= MORALE_BAND_HIGH:
		return "high"
	if morale < MORALE_BAND_LOW:
		return "low"
	return "mid"
const MORALE_FLIGHT_RISK := 35      # §7: altı → Ayrılabilir (25 idi)
const MORALE_HIRE_START := 75       # WORKING: yeni işe alınanın başlangıç morali
const MORALE_LEAVE_RETURN := 15     # §11.4 izin dönüşü, tek seferde (10 idi)
const MORALE_VACATION_RETURN := 20  # manuel TATİLE GÖNDER dönüşü (design doc §7)
const MORALE_FIRE_TEAM := 5         # işten çıkarmada kalan ekipteki DÜŞÜŞ büyüklüğü
const MORALE_RAISE_AT_MIN_PCT := 4  # %3 zamda moral kazancı  (WORKING)
const MORALE_RAISE_AT_MAX_PCT := 10 # %10 zamda moral kazancı — onaylı 2a: 75 → 85

# Badge ids reuse Character.attention_flag's declared vocabulary so the model does not
# carry two badge concepts — but badges are DERIVED (HRSystem.badges_for), because an
# employee can hold two at once and a single String field cannot.
const BADGE_FLIGHT_RISK := "FLIGHT_RISK"
## §13.3'ün AŞIRI YÜK rozeti — atanmış iş sayısı 2. Eskiden BADGE_OVERLOADED da vardı ve
## FARKLI bir şeydir (şirket çapındaki "mühendise ihtiyaç var" bayrağı); §16 aynı kelimenin
## iki durumu adlandırmasını yasaklıyor, o yüzden yeni rozet kendi id'sini alıyor ve eskisi
## Faz 5a'da yüzeyden, Faz 7'de koddan kalkıyor.
const BADGE_OVERLOAD_JOBS := "OVERLOAD_JOBS"

# Worst-first severity, matching the order HRSystem.badges_for returns. Exposed so a card
# list can sort "needs attention" rows to the top without re-deciding which badge is worse.
## §7'nin dört bandının karşılığı ÜÇ rozettir: Ayrılabilir · AŞIRI YÜK · YENİ.
## TÜKENİYOR (BURNING_OUT) rev 11'de YOK — 40 eşiği rev 2'nindi ve §7 onu saymıyor.
## Sabit ve etiketi Faz 7'ye kadar duruyor, ama artık hiçbir rozet listesine girmiyor.
const BADGE_SEVERITY := {
	"FLIGHT_RISK": 3,
	"OVERLOAD_JOBS": 1,
}

# YENİ is INFORMATIONAL, not an attention badge — it must never enter badges_for(), because
# that array is what attention_count() counts and what lights the left-rail badge. A fresh
# hire is good news; it does not belong in the same channel as "this person is about to quit".
const BADGE_NEW := "NEW"
## §17.4 kalibrasyon yüzeyi. 3 gündü: 1x hızda 12 sn/gün ile 36 SANİYE, görünmüyordu.
## 14 gün Atlas'ın bir haftalık bekleyişini ve üstüne bir yerleşme süresini taşır.
const NEW_HIRE_BADGE_DAYS := 14

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
const EXPERIENCE_LEAD_BONUS_MAX := 1.5  # WORKING: Liderlik 9'daki lider altında öğrenme hızı

## §5.1 DENEYİM — TEK BAR, alan bazlı DEĞİL. Ekranda hep 0–100; değişen arkasındaki eşik.
## İşbaşı öğrenme EMEKLİ: deneyim kendiliğinden yıldıza dönüşmez, tek çıkışı eğitimdir.
## Eski alan-başına deneyim sabitleri (EXPERIENCE_MAX/PER_DAY/PER_BUILD_DAY) silindi;
## duruyor (Faz 7 silme listesinde).
const EXPERIENCE_PER_WORKED_DAY := 2   # en az bir işe atanmış ve edilgen olmayan her gün
const EXPERIENCE_BUILD_BONUS := 1      # bir geliştirme fazı koşarken üstüne (toplam 3)

## Eşik gelişmişlikle büyür: eşik = BASE + PER_POINT × (altı alan + Liderlik ham toplamı).
## Tohumlanmış junior (T≈12) ≈37 iş gününde, dört yıldızlı kıdemli (T≈25) ≈63 günde
## doldurur. 1,7× fark §5.1'in "belirgin şekilde uzun"unu karşılar ama iki yıllık koşuda
## kıdemliyi eğitilemez yapmaz. Girdi TRAININGS DEĞİL İSTATİSTİK: dışarıdan alınan beş
## yıldızlı bir çalışan hiç eğitim almamıştır ve yine de yavaş olmalıdır.
const EXPERIENCE_THRESHOLD_BASE := 40
const EXPERIENCE_THRESHOLD_PER_POINT := 6


static func experience_threshold(total_skill_points: int) -> int:
	return EXPERIENCE_THRESHOLD_BASE + EXPERIENCE_THRESHOLD_PER_POINT * maxi(total_skill_points, 0)


## §5.3 KADEMELİ BEDEL: ücret = BASE × GROWTH^(mevcut ham puan). KADEME YARIM YILDIZDIR,
## tam yıldız DEĞİL — §5.3 kendi örneğini yarım kademelerle veriyor ("0★→0,5★ ucuzdur;
## 4,5★→5,0★ pahalıdır") ve §5.5 farkın SATIRDA OKUNMASINI istiyor.
##
## Bu bir F5 bulgusudur: kademe tam yıldızdayken (floor(puan/2)) eğitim modalinin üç satırı
## 3,0★ / 3,0★ / 3,5★ iken de AYNI rakamı yazıyordu. Yarım yıldızlık gelişme fiyat ekseninde
## görünmüyordu, yani §5.5'in "bu fark satırda okunur" cümlesi ekranda yalandı.
##
## MERDİVEN: 400 · 528 · 697 · 920 · 1.214 · 1.603 · 2.116 · 2.793 · 3.687 · 4.867
## Onaylı 11c'nin üç rakamı TAM YILDIZ aralıklarında birebir tutuyor — 0★ $400 · 1★ $697
## (~700) · 2★ $1.214 (~1.200) — çünkü 1,32² = 1,74 ve 11c'nin adımı da o. Erişilebilir son
## kademe (4,5★→5,0★) ilkin 12 KATIDIR: §5.3'ün "pahalıdır"ı bir sıfat değil, ölçülen bir
## sayı. Tekrar zammı ve Liderlik çarpanı YOK: §5.3 bedeli YALNIZ hedef alanın mevcut yıldız
## seviyesine göre kademelendirir.
const TRAINING_FEE_BASE := 400
const TRAINING_FEE_GROWTH := 1.32


static func training_fee_tiered(current_area_value: int) -> int:
	var rung: int = clampi(current_area_value, AREA_MIN, AREA_MAX)
	return int(round(float(TRAINING_FEE_BASE) * pow(TRAINING_FEE_GROWTH, float(rung))))
const TRAINING_DAYS := 14            # §5.2: "Çalışan İKİ HAFTA eğitimde kalır"

## §5.5: "Süre metni HESAPLANIR, sabit yazılmaz. Modal 'iki hafta' ifadesini GÜN SAYISINDAN
## türetir. Sabit bir metin anahtarına gömülmez; süre değiştiğinde metnin yalan söylemesi
## mümkün olmamalıdır (§16)." Tam haftaya bölünüyorsa hafta, bölünmüyorsa gün okunur — çünkü
## "2,4 hafta" bir insanın söyleyeceği şey değil.
static func training_duration_text() -> String:
	if TRAINING_DAYS % 7 == 0:
		return TranslationServer.translate("HR_DURATION_WEEKS").format({"n": TRAINING_DAYS / 7})
	return TranslationServer.translate("HR_DURATION_DAYS").format({"n": TRAINING_DAYS})
const TRAINING_FEE := 500            # WORKING: TABAN ücret; gerçek ücret kademeli, aşağıya bak
## İKİ KANAL, İKİ TAVAN. Parayla eğitim 8'de, yani DÖRT YILDIZDA durur; BEŞ yıldıza yalnız
## işi yaparak (add_area_experience, tavanı AREA_MAX) ya da üst segment bir adayı işe alarak
## çıkılır. Boşluk bilinçli: para her şeyi satın alamaz.
## LİDERLİK daha pahalı — tasarımın eğitim tablosunda aynı seviyede Liderlik satırı alan
## satırlarının üstünde fiyatlanıyor. [WORKING]
const TRAINING_LEADERSHIP_MULT := 1.35
# rev 2 §8 "Ücret kademeli: düşük yıldızdan yükseltmek ucuz, yüksek yıldızdan yükseltmek
# pahalı" + "Tekrarında azalan getiri". İkisi de TEK kanaldan ödenir: ücret. Getiri hep +1
# puandır (tam sayı cetvelde başka türlüsü okunmaz), azalan olan aynı +1'in FİYATIDIR.
const TRAINING_FEE_PER_POINT := 220  # WORKING: mevcut alan değeri başına ek ücret
const TRAINING_REPEAT_SURCHARGE := 0.35  # WORKING: aynı alandaki her tekrarda oransal zam


static func training_fee(current_area_value: int, trainings_done_in_area: int,
		skill_key: String = "") -> int:
	## Kademeli ücret + azalan getiri, tek yerde. Çağıran yalnız bu sayıyı görür.
	## `skill_key` YALNIZ Liderlik için fark yaratır; boş bırakılırsa alan fiyatı döner, yani
	## bu imzadan önceki her çağrı aynı rakamı alır.
	var base: float = float(TRAINING_FEE) + float(maxi(current_area_value, 0)) * float(TRAINING_FEE_PER_POINT)
	var repeat: float = 1.0 + float(maxi(trainings_done_in_area, 0)) * TRAINING_REPEAT_SURCHARGE
	var lead: float = TRAINING_LEADERSHIP_MULT if skill_key == SKILL_LEADERSHIP else 1.0
	return int(round(base * repeat * lead))


static func trainable_keys() -> Array:
	## Eğitime gönderilebilecek yetenekler: altı alan + LİDERLİK. Tasarımın eğitim tablosu
	## (11c) kişinin ana alanını, ikincil alanını ve Liderlik'i gösteriyor. Karizma YOK —
	## tasarımın listesinde de yok ve zaten yalnız kurucuda var.
	var out: Array = AREAS.duplicate()
	out.append(SKILL_LEADERSHIP)
	return out


static func is_trainable_key(skill_key: String) -> bool:
	return AREAS.has(skill_key) or skill_key == SKILL_LEADERSHIP


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
const SEVERANCE_ON_RESIGN := 0          # istifada tazminat YOKTUR (design doc §6)


## EMNİYET VALFİ PARAMETRESİ EMEKLİ. Valf bir MESAİ BLOĞUNUN olayıydı ("bu kişi tükeniyor,
## bloğu durdurayım mı?") ve §8.2 blokları kaldırdı — durdurulacak blok yoksa "Devam et" diye
## bir karar da yok. İmza `valve_continued` parametresini KORUYOR ve şimdilik hep false
## geliyor: §11.3 ayrılmaları olay motoruna bırakıyor, ve oradan gelecek "riski bilerek aldım"
## kararının bağlanacağı yer tam olarak burasıdır. Sabiti silmek yerine parametreyi bırakmak,
## o kancanın adını görünür tutuyor.
static func resign_chance(trait_ids: Array, valve_continued: bool) -> float:
	var chance: float = RESIGN_CHANCE_PER_DAY * trait_mult(trait_ids, "resign_chance_mult")
	if valve_continued:
		chance = minf(1.0, chance * 2.0)
	return clampf(chance, 0.0, 1.0)


static func resign_voice_line(index: int) -> String:
	return TranslationServer.translate("HR_RESIGN_VOICE_%d" % (posmod(index, RESIGN_VOICE_COUNT) + 1))
# VALVE_VOICE left this file for strings.csv: the lines are copy, and an array of copy in
# code cannot carry a second language. VALVE_VOICE_COUNT is the pool size; valve_voice_line(i)
# resolves the row. Index stays the selector, so the deterministic
# id-hash pick that chose a line still chooses the same one.
const VALVE_VOICE_COUNT := 3


## Deterministically indexed by character id, so the same person always says the same
## line — the index is the selector, the sentence lives in strings.csv.
static func resign_voice(character_id: String) -> String:
	return resign_voice_line(absi(character_id.hash()))


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

# --------------------- §11.4 yaz izni (hafta tabanlı) ------------------------
# İzin ÇALIŞANIN KENDİSİNE aittir; "tatile gönder" bir oyuncu fiili DEĞİLDİR.
# Süre iki hafta (10 iş günü), tek blok, Haziran–Ağustos penceresinde. Yukarıdaki AY tabanlı
# model (LEAVE_DAYS 7, LEAVE_MONTH_*, leave_month_for) tüketicileri Faz 2c'de çevrilene
# kadar duruyor ve Faz 7'de silinir.
const LEAVE_DAYS_R11 := 14              # §11.4 "iki hafta (10 iş günü)"
const LEAVE_WINDOW_START_MONTH := 6     # Haziran
const LEAVE_WINDOW_END_MONTH := 8       # Ağustos
## Yaz penceresi ~13 hafta. Adım 5, 13 ile ARALARINDA ASAL — on üç ardışık işe alım on üç
## FARKLI haftaya düşer. (Aynı gerekçe eski ay adımınınkiydi; taban aydan haftaya taşındı.)
const LEAVE_WEEK_COUNT := 13
const LEAVE_WEEK_STRIDE := 5
## §11.4 erteleme: −5 moral, talep 30 gün sonra döner, en fazla iki kez.
const LEAVE_MAX_DEFERRALS := 2
const LEAVE_DEFER_DAYS := 30


## hire_ordinal = bu kişiden önce kaç çalışan alındı. Yaz penceresi içinde 0..12 hafta indeksi.
static func leave_week_for(hire_ordinal: int) -> int:
	return (LEAVE_WEEK_STRIDE * maxi(hire_ordinal, 0)) % LEAVE_WEEK_COUNT


## §9.3 terfi zammının moral kazancı — %10 → MIN, %25 → MAX, arası doğrusal.
static func promotion_morale_gain(pct: int) -> int:
	var pp: int = clampi(pct, PROMOTION_MIN_PCT, PROMOTION_MAX_PCT)
	var span: int = maxi(1, PROMOTION_MAX_PCT - PROMOTION_MIN_PCT)
	var t: float = float(pp - PROMOTION_MIN_PCT) / float(span)
	return int(round(lerpf(float(MORALE_PROMOTION_AT_MIN_PCT), float(MORALE_PROMOTION_AT_MAX_PCT), t)))


## §11.1 KIDEM TAZMİNATI — basamaklı ve TAVANLI. Tamamlanmış yıl esas alınır, ara aylar
## yukarı yuvarlanmaz: bir buçuk yıllık çalışan BİR maaş alır, on yıllık da ÜÇ maaş alır.
## Eski kural (her tam yıl için bir ay, minimum bir, tavansız) iki uçta da yanlıştı.
## severance_months yukarıda duruyor — okuyanları Faz 5b'de çevrilir.
const SEVERANCE_UNDER_ONE_YEAR := 1.0 / 3.0
const SEVERANCE_MAX_MONTHS := 3.0


static func severance_multiple(days_served: int) -> float:
	var years: int = int(floor(float(maxi(days_served, 0)) / float(DAYS_PER_YEAR)))
	if years < 1:
		return SEVERANCE_UNDER_ONE_YEAR
	return minf(float(years), SEVERANCE_MAX_MONTHS)


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
## §9.2 aralık %3–10. 15'ti ve ağaçta bulunmayan bir belgeye "ONAYLI" damgası veriyordu.
const RAISE_MAX_PCT := 10
const RAISE_COOLDOWN_DAYS := 180   # §9.2 "aynı çalışana altı ay geçmeden yeni zam verilemez"
## §9.3 terfi: tek seviye atlama, oyuncu %10–25 arası zammı slider'dan seçer, minimum %10.
const PROMOTION_MIN_PCT := 10
const PROMOTION_MAX_PCT := 25
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
	# §11.1 BASAMAKLI VE TAVANLI: 1 yıldan az ⅓ maaş · 1 yıl 1 · 2 yıl 2 · 3 yıl ve üzeri 3.
	# Tamamlanmış yıl esas alınır ve ara aylar YUKARI YUVARLANMAZ — bir buçuk yıllık çalışan
	# BİR maaş alır. severance_months yukarıda duruyor (Faz 7) ama artık okunmuyor: eski
	# kural iki uçta da yanlıştı, bir yıldan az çalışana tam maaş, on yıllığa on maaş.
	return int(round(float(monthly_salary) * severance_multiple(days_served)))





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
