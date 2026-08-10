class_name HRConstants
extends RefCounted

# THE single tunables block for the HR module (HR_TASARIM_DOKUMANI.md): roles and
# departments, the three-axis employee ruler, traits, the Atlas search, morale,
# annual leave, player actions, department overtime and the HR economy labels.
# EVERY number here is a WORKING PLACEHOLDER — calibration is a separate last pass
# (PROJECT_SPEC §10: numbers last). Pure statics; no state, no scene dependency.
#
# NO HR NUMBER LIVES ANYWHERE ELSE. If an HR formula needs a knob it comes from here;
# the badge threshold that used to be a literal in left_tabs.gd is MORALE_BURNOUT below.
#
# Scope note (HR Core task 1 of 3): this file also owns the two SHIM tables that let
# today's un-rewritten formulas keep reading the old scales. The HR Coupling task
# (task 2) deletes them and rescales the coefficients instead.


# ========================= Employee skill ruler (0-9) ========================
# TEK CETVEL: 0-9 for everyone (design doc §4). An employee carries EXACTLY these
# three axes; the founder carries EXACTLY FounderConstants.SKILLS. The two key sets
# never mix — CharacterRegistry.add key-locks both and push_errors on a mismatch.
# What an axis MEANS is decided by the role (design doc §4 table); the keys do not
# change per role, so there is one dictionary shape for all six roles.
const AXIS_EXPERTISE := "expertise"   # UZMANLIK — işinin kalitesi
const AXIS_PACE := "pace"             # HIZ — işinin temposu
const AXIS_RAPPORT := "rapport"       # UYUM — moral dayanıklılığı + ekibe etkisi
const AXES := ["expertise", "pace", "rapport"]
const AXIS_MIN := 0
const AXIS_MAX := 9

# Title case in data; every uppercase surface renders through UiTokens.tr_upper.
const AXIS_LABELS := {
	"expertise": "Uzmanlık",
	"pace": "Hız",
	"rapport": "Uyum",
}


static func axis_label(axis_key: String) -> String:
	return String(AXIS_LABELS.get(axis_key, axis_key))


static func default_axes() -> Dictionary:
	# The exact-key shape every employee must hold. Mid-band middle values.
	return {"expertise": 5, "pace": 5, "rapport": 5}


static func validate_employee_axes(role_stats: Dictionary) -> bool:
	# EXACTLY the three axes, each inside the ruler. Mirrors FounderConstants.validate_alloc's
	# grammar so a founder dict handed to an employee (or vice versa) fails loudly.
	if role_stats.size() != AXES.size():
		return false
	for axis_key in AXES:
		if not role_stats.has(axis_key):
			return false
		var v: int = int(role_stats[axis_key])
		if v < AXIS_MIN or v > AXIS_MAX:
			return false
	return true


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
const ROLE_LABELS := {
	"product_manager": "Ürün Yöneticisi",
	"designer": "Tasarımcı",
	"developer": "Yazılımcı",
	"tester": "Test Uzmanı",
	"sales_rep": "Satış Uzmanı",
	"customer_rep": "Müşteri Temsilcisi",
	"founder": "Kurucu",
	# BYTE-EXACT, DO NOT TRANSLATE: already on screen today via mentor_intro_modal and the
	# three live JSON events whose character_id is char_mentor_frank. Changing it is a
	# visible regression in the paid-tier and first-revenue moments.
	"mentor": "Operating Partner",
}

# What each role's UZMANLIK / HIZ axis drives (design doc §4 table). Player-facing help
# copy for the candidate file and the HR card; the mechanics live in the Coupling task.
const ROLE_AXIS_MEANING := {
	"product_manager": {"expertise": "Deneyim ekip bonusu", "pace": "Tasarım fazına ikincil hız"},
	"designer": {"expertise": "Tasarım kalitesi katkısı", "pace": "Tasarım fazı hızı"},
	"developer": {"expertise": "Kod kalitesi (hata çarpanı)", "pace": "Geliştirme hızı"},
	"tester": {"expertise": "Hata bulma isabeti", "pace": "Bulma ve çözme temposu"},
	"sales_rep": {"expertise": "Anlaşma kapama gücü", "pace": "Aday üretim hızı"},
	"customer_rep": {"expertise": "Müşteri tutma", "pace": "Talep işleme temposu"},
}

# One-line, founder-voice effect per role — what hiring this person actually buys you,
# in the player's own language (iç-not sicili emekli: "TASARIM fazına ikincil hız" tarzı
# satırlar kurucu cümlesine çevrildi). Still keyed to ProductSystem.PHASE_CREW AND the
# iteration ceiling law (designer/developer/PM raise their axis ceilings —
# ProductSystem.ITER_CEIL_AXIS_ROLE), so the copy cannot drift from the mechanics
# without this comment being wrong too. The Coupling task's UI obligation stands:
# "oyuncu 'yazılımcı aldım, tasarım hızlanmadı' şaşkınlığını yaşamasın, bunu bilerek alsın."
# WORKING TR (voice pass later).
const ROLE_PHASE_HINT := {
	"product_manager": "Ekibe yön verir: ürünün deneyim tavanını yükseltir, tasarıma hız katar.",
	"designer": "Tasarım aşamasını hızlandırır, tasarım kalitesinin tavanını yükseltir.",
	"developer": "Geliştirmeyi hızlandırır, kod kalitesinin tavanını yükseltir.",
	"tester": "Hataları yayına çıkmadan yakalar, beta süresini kısaltır.",
	"sales_rep": "Kendi müşteri adaylarını bulur, anlaşmaları senin yerine kapatır.",
	"customer_rep": "Müşteri taleplerine yetişir, müşteri kaybını yavaşlatır.",
}

const DEPT_PRODUCT_DEV := "product_dev"
const DEPT_SALES := "sales"
const DEPT_CUSTOMER := "customer"
# Overtime is started per MAIN department, never per sub-section (design doc §7b).
const DEPARTMENTS := ["product_dev", "sales", "customer"]
const DEPT_LABELS := {
	"product_dev": "Ürün Geliştirme",
	"sales": "Satış",
	"customer": "Müşteri",
}

const SECTION_DESIGN := "design"
const SECTION_DEVELOPMENT := "development"
const SECTION_TEST := "test"
const SECTION_LABELS := {
	"design": "Tasarım",
	"development": "Geliştirme",
	"test": "Test",
}

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


static func role_label(role_id: String) -> String:
	# Never let a raw internal code reach the screen: an unknown id falls back to itself
	# only after screaming, so a typo surfaces in the log rather than in the UI silently.
	if not ROLE_LABELS.has(role_id):
		push_error("[HRConstants] role_label on unknown role id: '%s'" % role_id)
		return role_id
	return String(ROLE_LABELS[role_id])


static func is_employee_role(role_id: String) -> bool:
	return EMPLOYEE_ROLES.has(role_id)


static func department_of(role_id: String) -> String:
	return String(ROLE_DEPARTMENT.get(role_id, ""))


static func section_of(role_id: String) -> String:
	return String(ROLE_SECTION.get(role_id, ""))


static func department_label(dept_id: String) -> String:
	return String(DEPT_LABELS.get(dept_id, dept_id))


static func section_label(section_id: String) -> String:
	return String(SECTION_LABELS.get(section_id, section_id))


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


static func role_phase_hint(role_id: String) -> String:
	# One line naming what this role accelerates. Empty for non-employee roles (kurucu/mentor
	# have no build-phase contribution to advertise) — the caller renders nothing.
	return String(ROLE_PHASE_HINT.get(role_id, ""))


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
const TRAITS := {
	"warms_up_fast": {
		"label": "Çabuk ısınır",
		"polarity": "positive",
		"effect_text": "Morali bir tabanın altına inmez",
		"morale_floor": 35,
	},
	"pressure_proof": {
		"label": "Baskıya dayanıklı",
		"polarity": "positive",
		"effect_text": "Moral düşüşleri ve ek mesai bedeli yarı yarıya",
		"morale_drop_mult": 0.5,
	},
	"mentors_peers": {
		"label": "Kol kanat gerer",
		"polarity": "positive",
		"effect_text": "Aynı bölümdeki arkadaşlarına moral desteği verir",
		"dept_morale_weekly": 2,
	},
	"wont_jump_ship": {
		"label": "Gemiyi terk etmez",
		"polarity": "positive",
		"effect_text": "Zor koşulda bile ayrılmaya daha az meyilli",
		"resign_chance_mult": 0.6,
	},
	"natural_leader": {
		"label": "Doğal lider",
		"polarity": "positive",
		"effect_text": "Sorumlu olduğunda ekibi daha iyi koordine eder",
		"coordination_bonus": 0.05,
	},
	"works_alone": {
		"label": "Yalnız çalışır",
		"polarity": "negative",
		"effect_text": "Ekibe katkı vermez, yalnız kendi işini yapar",
		"no_team_bonus": true,
	},
	"glass_heart": {
		"label": "Cam kalp",
		"polarity": "negative",
		"effect_text": "Moral düşüşleri ve ek mesai bedeli iki katı",
		"morale_drop_mult": 2.0,
	},
	"sours_the_room": {
		"label": "Havayı bozar",
		"polarity": "negative",
		"effect_text": "Aynı bölümdeki arkadaşlarının moralini aşağı çeker",
		"dept_morale_weekly": -2,
	},
	"one_foot_out": {
		"label": "Bir ayağı kapıda",
		"polarity": "negative",
		"effect_text": "Kötü giderse ayrılmaya daha meyilli",
		"resign_chance_mult": 1.6,
	},
	"needs_direction": {
		"label": "Söylenmezse yapmaz",
		"polarity": "negative",
		"effect_text": "Sorumlu değilken belirgin biçimde az katkı verir",
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
	return String((TRAITS.get(trait_id, {}) as Dictionary).get("label", trait_id))


static func trait_effect_text(trait_id: String) -> String:
	return String((TRAITS.get(trait_id, {}) as Dictionary).get("effect_text", ""))


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
const BAND_LABELS := {
	"junior": "ekonomik",
	"mid": "dengeli",
	"senior": "üst segment",
}

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

# Axis PROFILES per band tier — CANDIDATE_COUNT profiles per band, cheapest first.
# Candidate k = profile k rotated k (HRCandidateGenerator._axes_for), so the peak
# lands on a DISTINCT axis per file AND the files differ in TOTAL: fiyat artık bir
# kaldıraç, üç dosya üç ayrı rakam ister. Per-profile INVARIANT: peak > mid >= low
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
	return String(BAND_LABELS.get(band_id, band_id))


static func band_shape(band_id: String, profile_index: int = 0) -> Array:
	var profiles: Array = BAND_SHAPE.get(band_id, BAND_SHAPE["mid"])
	if profiles.is_empty():
		return []
	return profiles[clampi(profile_index, 0, profiles.size() - 1)]


# ========================= Search (Atlas Seçme & Yerleştirme) ================
# Çift ücret (design doc §2, KANON): peşin retainer + işe alımda komisyon.
const SEARCH_AGENCY_NAME := "Atlas Seçme & Yerleştirme"
const SEARCH_RETAINER := 600            # peşin, iptalde İADE EDİLMEZ
const SEARCH_COMMISSION_PCT := 0.15     # işe alımda ilk ay maaşının oranı
const SEARCH_ARRIVAL_MIN_DAYS := 2      # dosyalar en erken bu kadar gün sonra gelir
const SEARCH_ARRIVAL_MAX_DAYS := 4      # ve en geç bu kadar
const CANDIDATE_COUNT := 3              # her arayış üç dosya getirir
const SALARY_SPREAD_MAX := 0.15         # en pahalı/en ucuz − 1 üst sınırı
const SALARY_PEAK_PREMIUM := 0.10       # WORKING: keskin uzman, düz profilden bu oranda pahalı

# Finance one-time charge labels (FinanceSystem.apply_one_time_cost's ledger hook).
const COST_LABEL_HIRE := "İşe alım"
const COST_LABEL_SEVERANCE := "Kıdem tazminatı"
const COST_LABEL_TRAINING := "Eğitim ücreti"   # DENEYİM/EĞİTİM tek seferlik gideri

# Ticker attribution (EventBus.headline_added source). Shared so the HR systems do not each
# hold their own copy of the same literal.
const NOTICE_SOURCE_HR := "İK"

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
const BADGE_LABELS := {
	"FLIGHT_RISK": "Kaçma riski",
	"BURNING_OUT": "Tükeniyor",
	"OVERLOADED": "Aşırı yüklü",
	"NEW": "Yeni",
}
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
const TRAINING_DAYS := 5             # WORKING: eğitim süresi
const TRAINING_FEE := 500            # WORKING: tek seferlik ücret, HR gider hattına
const EXPERTISE_CAP := 8             # WORKING: eğitimin UZMANLIK tavanı (AXIS_MAX 9'un altında bilerek)


static func badge_label(badge_id: String) -> String:
	return String(BADGE_LABELS.get(badge_id, badge_id))


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
	var t: float = clampf(float(leadership) / float(AXIS_MAX), 0.0, 1.0)
	var m: float = COORD_FOUNDER_NEUTRAL + span * t
	if has_natural_leader:
		m += COORD_NATURAL_LEADER_BONUS
	return clampf(m, COORD_FOUNDER_NEUTRAL, COORD_MAX_WITH_TRAIT)


static func coordination_for_employee(rapport: int, has_natural_leader: bool = false) -> float:
	# Two-sided across the whole ruler: UYUM 0 → COORD_MIN (the team waits on each other),
	# UYUM 9 → COORD_MAX. This is UYUM's SECOND job, the one the design doc gives it beyond
	# morale resilience.
	var t: float = clampf(float(rapport) / float(AXIS_MAX), 0.0, 1.0)
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
	# every consumer would otherwise print a number where a month belongs. Delegates to the
	# calendar's own Title-Case table rather than keeping a fourth copy of the month names.
	if month < 1 or month > 12:
		return ""
	return String(GameState.MONTH_NAMES_TR_TITLE[month - 1])


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
const OVERTIME_BLOCK_LABELS := {
	3: "3 gün",
	7: "1 hafta",
	14: "2 hafta",
}
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
const RESIGN_VOICE := [
	"\"Bir süre düşündüm. Burada tükeniyorum, daha fazla taşımak istemiyorum.\"",
	"\"Kimseyle sorunum yok. Sadece her sabah biraz daha zor kalkıyorum. O kadar.\"",
	"\"Bana kötü davranıldı demeyeceğim. Ama fark edilmedim.\"",
	"\"Başka bir yerden teklif geldi. Doğrusunu istersen, aramayı ben yaptım.\"",
]
const VALVE_VOICE := [
	"\"Bu tempoyla devam edemem. Şimdi söylüyorum ki sonra sürpriz olmasın.\"",
	"\"Haftalardır eve gece yarısı gidiyorum. Bir yere kadar.\"",
	"\"Kimse sormadı diye iyi olduğum sanılmasın.\"",
]


static func resign_voice(character_id: String) -> String:
	return String(RESIGN_VOICE[absi(character_id.hash()) % RESIGN_VOICE.size()])


static func valve_voice(character_id: String) -> String:
	return String(VALVE_VOICE[absi(character_id.hash()) % VALVE_VOICE.size()])


static func money_tr(amount: int) -> String:
	# "$1.500" — Turkish thousands separator. One home for the HR module so the event copy
	# and the action previews cannot disagree about how money reads. (The wider codebase has
	# several private copies of this; unifying them all is a separate editorial pass.)
	var digits: String = str(absi(amount))
	var out: String = ""
	var count: int = 0
	for i in range(digits.length() - 1, -1, -1):
		out = digits[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "." + out
	return "$%s" % out


# ============================ Aday dosyası içeriği ===========================
# WORKING content — deterministically indexed by the generator's pure hash, never RNG.
const FIRST_NAMES := [
	"Kerem", "Selin", "Arda", "Deniz", "Ece", "Mert", "Zeynep", "Baran",
	"Elif", "Onur", "Sena", "Kaan", "Bilge", "Tolga", "Nehir", "Emre",
]
const LAST_NAMES := [
	"Aksoy", "Koç", "Güneş", "Demir", "Kaya", "Arslan", "Yıldız", "Çetin",
	"Doğan", "Şahin", "Erdem", "Polat", "Tekin", "Uysal",
]
# Tek satırlık dosya notu — mizaç verir, skill tekrarı yapmaz.
const FILE_NOTES := [
	"Sorulardan çok cevapları seviyor.",
	"CV'si kısa, referansları uzun.",
	"İki startup batırmış, üçüncüye hazır.",
	"Görüşmeye kendi yaptığı bir şeyle gelmiş.",
	"Son işinde kimse gitmesini istemedi.",
	"Konuşmaktan çok not aldı.",
	"Maaşı sordu, sonra ürünü sordu, sırayı fark etti.",
	"Büyük şirketten geliyor, küçüğü merak ediyor.",
	"Uzun bir aradan sonra dönüyor.",
	"Herkesi tanıyor, kimseyle çalışmamış.",
	"Teknik soruda durdu, düşündü, doğru cevapladı.",
	"Eski ekibinden iki kişi onu tavsiye etti.",
]
