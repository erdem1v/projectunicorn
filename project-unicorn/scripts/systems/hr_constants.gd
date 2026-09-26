class_name HRConstants
extends RefCounted

# Ekip modülünün (EKİP MODÜLÜ rev 11) TEK ayar bloğu: roller, alanlar, işler, huylar, Atlas
# araması, moral, izin, çalışma saatleri, oyuncu eylemleri. HR formülünün her sayısı buradan
# okunur. Saf statik; durum ve sahne bağımlılığı yok.


# ============================ Skill ALANLARI (0-10) ===========================
# §4: yetenek ROL değil ALANDIR; herkes altı alanda ve Liderlik'te bir sayı taşır, böylece
# tek kişilik ekipte boşluk kalmaz (bedeli §5: alan dışında çalışmak daha yorucudur).
const AREA_PRODUCT := "product"                     # Ürün — tasarım turları, özellik kararları
const AREA_DESIGN := "design"                       # Tasarım — tasarım tavanı, Deneyim ekseni
const AREA_ENGINEERING := "engineering"             # Yazılım — geliştirme hızı, bug oranı
const AREA_QA := "qa"                               # Test — beta keşif hızı, canlı bug aşınması
const AREA_SALES := "sales"                         # Satış — kapanış olasılığı, anlaşma boyutu
const AREA_CUSTOMER_SUCCESS := "customer_success"   # Müşteri Başarısı — bilet, memnuniyet, churn
const AREAS := ["product", "design", "engineering", "qa", "sales", "customer_success"]

# Liderlik herkeste (§4.2); Karizma yalnız kurucuda ve FounderConstants'ta.
const SKILL_LEADERSHIP := "leadership"
# Bir çalışanın role_stats'ının tam anahtar kümesi: altı alan + Liderlik.
const EMPLOYEE_SKILL_KEYS := ["product", "design", "engineering", "qa", "sales",
	"customer_success", "leadership"]

const AREA_MIN := 0
## Beş yıldızlı cetvel yarım yıldız çiziyor: 2 puan = 1 yıldız, tavan 10 = beş yıldız.
const AREA_MAX := 10

## Yıldız cetveli; defter, matris, kurucu kartı ve eğitim modali aynı eşlemeyi okur.
const STAR_MAX := 5
const POINTS_PER_STAR := 2

# Eski eksen anahtarları. Kayıt bilinmeyen anahtarı sessizce düşürdüğü için bunlar
# yakalanıp bağırılır (FounderConstants.OLD_SKILLS ile aynı düzen).
const RETIRED_SKILL_KEYS := ["expertise", "pace", "rapport"]

# "sales" üç ayrı şeydir: alan id'si, JOB_SALES ve kadro grubu GROUP_*. Aynı sözlükte
# buluşmazlar ama bir "sales" araması üçüne de çarpar.
# Etiketler id'den türetilir (HR_AREA_ + ID vb.), tablo tutulmaz.


static func area_label(area_key: String) -> String:
	return _derived("HR_AREA_", area_key)


static func default_employee_skills() -> Dictionary:
	# Orta değerler, Liderlik düşük: liderlik istisnadır ve §4.2 ona gerçek etkiler bağlar.
	return {"product": 5, "design": 5, "engineering": 5, "qa": 5, "sales": 5,
		"customer_success": 5, "leadership": 2}


static func validate_employee_skills(role_stats: Dictionary) -> bool:
	# TAM OLARAK altı alan + Liderlik, her biri cetvelin içinde; kurucu sözlüğü yüksek sesle düşer.
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
	for k in RETIRED_SKILL_KEYS:
		if role_stats.has(k):
			return true
	return false


# ===================== Rol → alan, ve işler ==================================
# ROLE_AREAS (§4.4): rol bir UNVANDIR; bu iki alan kapalı satırın gösterdiği ve aday
# üreticisinin tepe noktasını koyduğu yerdir.
const ROLE_AREAS := {
	"product_manager": {"key": "product", "secondary": "design"},
	"designer": {"key": "design", "secondary": "product"},
	"developer": {"key": "engineering", "secondary": "qa"},
	"tester": {"key": "qa", "secondary": "engineering"},
	# §4.4: cross-cover yalnız ürün tarafının içindedir. Satış ve müşteri temsilcisinin boş
	# ikincili bir eksiklik değil, hükümdür.
	"sales_rep": {"key": "sales", "secondary": ""},
	"customer_rep": {"key": "customer_success", "secondary": ""},
}

# ============================== İŞLER — §12.0 ================================
# İş atama birimidir. `AREAS` kişinin neyde İYİ olduğu, `JOBS` ne YAPTIĞI; `JOB_AREAS` köprü.
const JOB_BUILD := "build"          # Build ekibi (aktif yapım)
const JOB_TEST := "test"            # Test
const JOB_SUPPORT := "support"      # Destek (canlı ürün)
const JOB_ACCOUNTS := "accounts"    # Hesap sahipliği
# Satış rev 6 §7.2: temsilcinin masası tek müşteriyi günlerce işleyen sürekli bir iştir.
# Kurucunun pitch'i ise bir toplantıdır, hiçbir atamaya dokunmaz (SalesMeetingSystem).
const JOB_SALES := "sales"          # Satış masası (lead işleme, kapanış)
const JOB_RESEARCH := "research"    # Ar-Ge §5.0 — DIŞLAYICI iş; JOB_EXCLUSIVE'e bakın
const JOBS := ["build", "test", "support", "accounts", "sales", "research"]

## SÜREKLİ işler SLOT tutar: kişi başına en fazla iki, ikisi odağı böler (§12.1) ve ikisi de
## koşar, ikisi de yavaşlar. Araştırma slot tutmaz, kişinin tamamını alır (JOB_EXCLUSIVE).
const JOB_CONTINUOUS := ["build", "test", "support", "accounts", "sales"]


## Tavan yalnız slot tutan işleri sayar; araştırmayı reddetmesi bu yüzden imkânsızdır.
static func is_continuous_job(job_id: String) -> bool:
	return JOB_CONTINUOUS.has(job_id)

## Hangi ALANLAR her işi taşır (§12.0). Kişi işin alanlarından birini taşıyorsa o işi tutabilir;
## ne kadar iyi yaptığı §4.5'in formülüdür. Bir developer destekte Yazılım üzerinden çalışır ve
## Müşteri İlişkileri kazanmaz (§4.4).
const JOB_AREAS := {
	"build": ["product", "design", "engineering"],
	"test": ["qa"],
	"support": ["engineering", "customer_success"],
	"accounts": ["customer_success", "sales"],
	# §4.4: Satış Temsilcisinin ikincil alanı yok, satış işini yalnız Satış alanı taşır.
	"sales": ["sales"],
	# Ar-Ge §5.2: yalnız `can_hold_job` kapısı; düğümün okuduğu alan düğümün kendi `areas`'ında.
	# sales_rep ve customer_rep katsayı 0 alır, araştırmaya konamaz (§5.3).
	"research": ["product", "design", "engineering", "qa"],
}

## Ar-Ge §5.0 — kişiyi MEŞGUL EDEN işler: atanınca diğer işleri duraklar (silinmez) ve kişi
## başka hiçbir alana çıktı vermez. Sonucu `areas_for_jobs`'daki `continue`'dur.
const JOB_EXCLUSIVE := ["research"]


static func is_exclusive_job(job_id: String) -> bool:
	return JOB_EXCLUSIVE.has(job_id)

## §12 "Bir kişiye en fazla iki iş verilebilir." Matris kilidi ve yazma tarafı aynı sayıyı okur.
const MAX_JOBS_PER_PERSON := 2

## §12.1 odak katsayısı (ZAMAN; §4.3 YETKİNLİK ile çarpılır). Tek iş 1,00 · iki iş her birine 0,50.
const FOCUS_MULT_SINGLE := 1.0
const FOCUS_MULT_SPLIT := 0.5


static func job_areas(job_id: String) -> Array:
	return (JOB_AREAS.get(job_id, []) as Array).duplicate()


static func is_job(job_id: String) -> bool:
	return JOBS.has(job_id)


## Bilinmeyen id kendini döndürür ve logda bağırır.
static func job_label(job_id: String) -> String:
	if not JOBS.has(job_id):
		push_error("[HRConstants] job_label with an unknown job: '%s'" % job_id)
		return job_id
	return _derived("HR_JOB_", job_id)


## §4.4 atanabilirlik: 1.0 ana alan · SECONDARY_AREA_MULT ikincil · 0.0 alanı yok.
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


static func focus_mult(job_count: int) -> float:
	return FOCUS_MULT_SINGLE if job_count <= 1 else FOCUS_MULT_SPLIT


## ALAN → birincil işi. Çoğu alan iki işe girebilir; bu tablo belirsizliği çözer.
## Müşteri İlişkileri'nin birincil işi Destek: hesap sahipliği Customer.assigned_to ile taşınır.
const AREA_PRIMARY_JOB := {
	"product": "build",
	"design": "build",
	"engineering": "build",
	"qa": "test",
	"customer_success": "support",
	"sales": "sales",
}


static func primary_job_for_area(area_id: String) -> String:
	return String(AREA_PRIMARY_JOB.get(area_id, ""))


## Yeni işe alınan kendi ana alanının birincil işine oturur; kimse boşta doğmaz.
static func default_job_for_role(role_id: String) -> String:
	return primary_job_for_area(role_key_area(role_id))


## İşlerden TÜRETİLEN alan listesi (`Character.assigned_jobs` aynası), kişinin taşıdığı
## alanlara daraltılmış (§4.4).
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
		# Ar-Ge §5.0: araştıran kişi başka hiçbir şeye çıktı vermez. Ayna ProductSystem ve
		# HRSystem.assigned_to tarafından okunuyor; araştırmayı aynaya sokmak kişiyi sessizce
		# build ekibine geri koyardı.
		if is_exclusive_job(String(job_id)):
			continue
		for area_id in job_areas(String(job_id)):
			if owned.has(String(area_id)) and not out.has(String(area_id)):
				out.append(String(area_id))
	return out

## §4.3 ikincil alan ×0,8: zayıflık zaten yıldızlarda yazılı, katsayı onu ikinci kez
## kesmez, rol kimliğini korur.
const SECONDARY_AREA_MULT := 0.8


static func role_key_area(role_id: String) -> String:
	var row: Dictionary = ROLE_AREAS.get(role_id, {})
	return String(row.get("key", ""))


static func role_secondary_area(role_id: String) -> String:
	var row: Dictionary = ROLE_AREAS.get(role_id, {})
	return String(row.get("secondary", ""))


static func is_assignable(area_id: String) -> bool:
	return AREAS.has(area_id)


static func can_hold_area(role_id: String, area_id: String, category: String) -> bool:
	## Matrisin "ALANI YOK · ATANAMAZ" hücresi: çalışan yalnız ana ya da ikincil alanında
	## çalışır. Kurucunun rolü yok; onu sayı sınırlar, alan değil.
	if not is_assignable(area_id):
		return false
	if category == "founder":
		return true
	return area_id == role_key_area(role_id) or area_id == role_secondary_area(role_id)


static func stars_for(points: int) -> float:
	## Tek eşleme; tek sayı yarım yıldız olarak çizilir.
	return clampf(float(points) / float(POINTS_PER_STAR), 0.0, float(STAR_MAX))


static func experience_gain_mult(lead_leadership: int) -> float:
	## §4.2: ekip liderinin Liderlik'i deneyim kazanım hızını da taşır. 0'da nötr.
	var t: float = clampf(float(lead_leadership) / float(AREA_MAX), 0.0, 1.0)
	return 1.0 + (EXPERIENCE_LEAD_BONUS_MAX - 1.0) * t


static func seed_skills(role_id: String, key_value: int, rest_value: int,
		leadership_value: int = 2) -> Dictionary:
	## Rolün şekliyle tam bir yetenek sözlüğü: ana alan `key_value`, ikincil bir altı, geri
	## kalan `rest_value`. Elle kurulan kadroların (debug, çekim, smoke) tek evi.
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
	## §4.3: ikincil alanda çalışmak daha yorucudur. Kurucunun ana/ikincil ayrımı yok.
	if role_id == "" or role_id == ROLE_FOUNDER:
		return 1.0
	if area_id == role_key_area(role_id):
		return 1.0
	return SECONDARY_AREA_MULT


# ============================== Roller ========================================
# Tipli id'ler; `category` kurucu/mentor/çalışan ayrımını taşımaya devam eder.
const ROLE_PRODUCT_MANAGER := "product_manager"
const ROLE_DESIGNER := "designer"
const ROLE_DEVELOPER := "developer"
const ROLE_TESTER := "tester"
const ROLE_SALES_REP := "sales_rep"
const ROLE_CUSTOMER_REP := "customer_rep"
# Personel olmayan id'ler: yalnız ham kod basılmasın diye etiket taşırlar.
const ROLE_FOUNDER := "founder"
const ROLE_MENTOR := "mentor"

# Düz altı id'lik dizi: HRCandidateGenerator tohum indeksini find() ile buradan türetir ve
# smoke boyutunu doğrular; filtrelemek ya da araya id sokmak her aday havuzunu değiştirir.
const EMPLOYEE_ROLES := ["product_manager", "designer", "developer", "tester", "sales_rep", "customer_rep"]

# Türetilmiş etiket anahtarları tr("LITERAL") aramasında görünmez; `loc_hr_derived_keys`
# gerçek id listelerini yürüyüp her anahtarın iki dilde çözüldüğünü doğrular.

# KADRO GRUPLARI — §13.1'in dört bandı ve modülün tek insan taksonomisi (§8.1 çalışma saati
# kapsamı ve TAT KAÇIRAN'ın "takım arkadaşı" tanımı bunu okur).
const GROUP_PRODUCT_DESIGN := "product_design"
const GROUP_DEVELOPMENT := "development"
const ROSTER_GROUPS := ["product_design", "development", "sales", "customer_success"]
const ROLE_GROUP := {
	"product_manager": "product_design",
	"designer": "product_design",
	"developer": "development",
	"tester": "development",
	"sales_rep": "sales",
	"customer_rep": "customer_success",
}
## Ham kod ekrana çıkmaz: bilinmeyen id logda bağırır ve kendini döndürür.
static func role_label(role_id: String) -> String:
	if not ROLE_GROUP.has(role_id) and role_id not in [ROLE_FOUNDER, ROLE_MENTOR]:
		push_error("[HRConstants] role_label on unknown role id: '%s'" % role_id)
		return role_id
	return _derived("HR_ROLE_", role_id)


## id -> yerel etiket. Bu dosya statik olduğu için tr() değil TranslationServer; çözülmeyen
## anahtar id'nin kendisini döndürür.
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


## Bu rolü işe almanın kurucu sesiyle tek satırlık getirisi; kurucu/mentor için boş.
static func role_phase_hint(role_id: String) -> String:
	if not is_employee_role(role_id):
		return ""
	return _derived("HR_ROLE_HINT_", role_id)


static func role_lock_reason_key(role_id: String) -> String:
	# "" = şu an işe alınabilir; değilse NEDENİNİ söyleyen CSV anahtarı (kilitli, görünür,
	# açıklanmış; asla sessizce yok).
	match role_id:
		ROLE_SALES_REP:
			# Kurumsal satış masası yalnız B2B pazarında vardır.
			return "" if ProductSystem.has_b2b_product() else "HR_ROLE_LOCK_SALES"
	return ""


static func is_role_hireable(role_id: String) -> bool:
	return role_lock_reason_key(role_id) == ""


## §10.6 Atlas'ın kilitli-görünür iki kartı: çizilir, sönüktür, tıklanamaz, gerekçesini
## gösterir. EMPLOYEE_ROLES'a girmezler (aday havuzu tohumları); rol değil vitrin.
const FUTURE_ROLES := ["marketing", "hr_inhouse"]
const FUTURE_ROLE_LOCK_KEY := "HR_ROLE_LOCK_FULL_VERSION"


static func future_role_label(role_id: String) -> String:
	return _derived("HR_ROLE_", role_id)


static func future_role_hint(role_id: String) -> String:
	return _derived("HR_ROLE_HINT_", role_id)


# ================================== Huylar ===================================
# Huy skill tekrarı değil davranış tanımıdır; gizli huy yoktur. Huylar iyi ya da kötü
# değildir: `carries_cost` yalnız aday üreticisinin "bir dosya bedel taşır" ayrımıdır ve hiçbir
# çizim onu okumaz. Metin HR_TRAIT_<ID>_LABEL / _EFFECT anahtarlarından türetilir.
#
# Etki anahtarları ve okuyucuları:
#   resign_chance_mult      HRMoraleSystem — istifa roll'unun çarpanı
#   overtime_morale_mult    OKUYUCUSU YOK — İŞKOLİK şu an etkisiz (açık hata)
#   experience_mult         HRSystem.tick_experience — kendi deneyim kazancı
#   lead_experience_mult    OKUYUCUSU YOK — GERÇEK LİDER'in yalnız ayrılış bedeli işler (açık hata)
#   departure_morale_extra  HRMoraleSystem — ayrılışın ekibe EK moral bedeli
#   bug_rate_mult           ProductSystem._accrue_bugs_hourly
#   speed_mult              ProductSystem._phase_area_sum — kişinin katkı çarpanı
#   output_mult             ProductSystem._phase_area_sum — aynı yer, ters yön
#   promise_chance_mult     B2BEventFactory, SalesRepSystem — söz olaylarının bu kişide ateşlenme oranı
#   satisfaction_bonus      B2BSalesSystem._tick_satisfaction — hesaplarında memnuniyet
#   dept_morale_decay_mult  HRMoraleSystem — ekibinin moral erime hızı
#
# Sayıların hiçbiri ölçülmüş değil; kalibrasyon yüzeyidir.
const TRAITS := {
	# --- bedelsiz üç ------------------------------------------------------
	"loyal": {                                # SADIK
		"carries_cost": false,
		"resign_chance_mult": 0.6,
	},
	"picks_it_up_fast": {                     # ÇABUK KAPAR
		"carries_cost": false,
		"experience_mult": 1.5,               # "belirgin şekilde hızlı"
	},
	"last_one_out": {                         # İŞKOLİK
		"carries_cost": false,
		"overtime_morale_mult": 0.5,          # yalnız mesaide
	},
	# --- bedelli beş -------------------------------------------------------
	"takes_them_under": {                     # GERÇEK LİDER
		"carries_cost": true,
		"lead_experience_mult": 1.5,
		"departure_morale_extra": -5,         # başkaları −5 alırken bunlar −10
	},
	"double_checker": {                       # TİTİZ
		"carries_cost": true,
		"bug_rate_mult": 0.5,                 # "çok daha az hata"
		"speed_mult": 0.85,                   # hız bedeli
	},
	"cant_say_no": {                          # HAYIR DİYEMEZ
		"carries_cost": true,
		"promise_chance_mult": 1.6,
		"satisfaction_bonus": 5,              # hesaplarında memnuniyet
	},
	"bag_packed": {                           # GÖZÜ YÜKSEKTE
		"carries_cost": true,
		"resign_chance_mult": 1.6,
		"output_mult": 1.15,                  # "yüksek verim"
	},
	"mood_buster": {                          # TAT KAÇIRAN
		"carries_cost": true,
		"dept_morale_decay_mult": 1.25,       # "hafifçe" yükseltir
		# Şikayetin kendisi (olay kartı) henüz yazılmadı.
	},
}

## Çalışan TAM BİR huy taşır ve o huy bedelli de olabilir; bir aday saf bir yük olabilir.
## Kurucunun formülü ayrıdır (FounderConstants.validate_traits, iki huy).
const TRAIT_COUNT := 1


static func trait_label(trait_id: String) -> String:
	return _derived("HR_TRAIT_", trait_id + "_LABEL")


static func trait_effect_text(trait_id: String) -> String:
	if not TRAITS.has(trait_id):
		return ""
	return _derived("HR_TRAIT_", trait_id + "_EFFECT")


## Bedelli mi — yalnız aday üreticisi okur; bir çizim bunu okumamalı.
static func trait_carries_cost(trait_id: String) -> bool:
	return bool((TRAITS.get(trait_id, {}) as Dictionary).get("carries_cost", false))


## Satış rev 6 §11.8 tuzak-huy yasağı: "faydası o rolün işlerinde ateşlenemeyen huy, o rolün
## aday havuzuna girmez." GERÇEK LİDER yalnız bir BUILD liderinde ateşlenir, TİTİZ'in faydası
## yalnız geliştirmede (bug oranı); satış ve müşteri temsilcisinde ikisi de saf bedeldir.
## Havuz filtresidir, huyun ne yaptığını değiştirmez. Kalan üç bedelli huy üç dosyalık bir
## aramanın en kötü durumuna tam yeter.
const ROLE_TRAIT_BAN := {
	"sales_rep": ["takes_them_under", "double_checker"],
	"customer_rep": ["takes_them_under", "double_checker"],
}


static func role_bans_trait(role_id: String, trait_id: String) -> bool:
	return (ROLE_TRAIT_BAN.get(role_id, []) as Array).has(trait_id)


static func free_trait_ids(role_id: String = "") -> Array:
	return _trait_ids(role_id, false)


static func cost_trait_ids(role_id: String = "") -> Array:
	return _trait_ids(role_id, true)


static func _trait_ids(role_id: String, carries_cost: bool) -> Array:
	var out: Array = []
	for trait_id in TRAITS.keys():
		if trait_carries_cost(String(trait_id)) != carries_cost:
			continue
		if role_bans_trait(role_id, String(trait_id)):
			continue
		out.append(trait_id)
	out.sort()   # deterministik sıra: üretici bu diziye indeksler
	return out


static func validate_employee_traits(trait_ids: Array) -> bool:
	## TRAIT_COUNT kadar geçerli, tekrarsız huy; kutup serbest.
	if trait_ids.size() != TRAIT_COUNT:
		return false
	var seen: Array = []
	for trait_id in trait_ids:
		var tid: String = String(trait_id)
		if not TRAITS.has(tid) or seen.has(tid):
			return false
		seen.append(tid)
	return true


static func trait_mult(trait_ids: Array, effect_key: String) -> float:
	# Çarpımsal: ters yöne çeken iki huy birbirini götürür.
	var m: float = 1.0
	for trait_id in trait_ids:
		var entry: Dictionary = TRAITS.get(String(trait_id), {})
		if entry.has(effect_key):
			m *= float(entry[effect_key])
	return m


static func trait_sum(trait_ids: Array, effect_key: String) -> float:
	var total: float = 0.0
	for trait_id in trait_ids:
		var entry: Dictionary = TRAITS.get(String(trait_id), {})
		if entry.has(effect_key):
			total += float(entry[effect_key])
	return total


# ==================== SEVİYELER — §3, §9.1, §10.2 ============================
# Seviye kişide saklanan bir alandır; terfinin değiştirdiği budur (§15).
const LEVEL_JUNIOR := 0
const LEVEL_MID := 1
const LEVEL_SENIOR := 2
const LEVELS := [0, 1, 2]

## §3 unvan türetilir: ön ek + rol adı; ORTA seviyede ön ek yoktur. §3.1: Junior iki dilde
## de "Junior", Kıdemli'nin İngilizcesi "Senior".
const LEVEL_PREFIX_KEYS := {0: "HR_LEVEL_PREFIX_JUNIOR", 1: "", 2: "HR_LEVEL_PREFIX_SENIOR"}

## Seviyenin ADI ön ekinden ayrıdır: Orta'nın ön eki yok ama adı var ve Atlas şeridi onu gösterir.
const LEVEL_NAME_KEYS := {0: "HR_LEVEL_JUNIOR", 1: "HR_LEVEL_MID", 2: "HR_LEVEL_SENIOR"}


static func level_label(level: int) -> String:
	return TranslationServer.translate(
		String(LEVEL_NAME_KEYS.get(clampi(level, LEVEL_JUNIOR, LEVEL_SENIOR), "")))


static func is_level(level: int) -> bool:
	return LEVELS.has(level)


static func level_prefix(level: int) -> String:
	var key: String = String(LEVEL_PREFIX_KEYS.get(clampi(level, LEVEL_JUNIOR, LEVEL_SENIOR), ""))
	return "" if key == "" else TranslationServer.translate(key)


## Unvanın tek evi; hiçbir yüzey ön ekle rol adını kendi birleştirmez.
static func job_title(role_id: String, level: int) -> String:
	var prefix: String = level_prefix(level)
	var name: String = role_label(role_id)
	return name if prefix == "" else "%s %s" % [prefix, name]


## §9.1 maaş bantları, tek kaynak: işe alım, terfi ve zam önizlemesi buradan okur. Bantlar
## sınırlarda KASTEN örtüşür (güçlü junior ile zayıf orta aynı parayı isteyebilir). Aylık USD.
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


## Maaşın düştüğü seviye; bantlar örtüştüğü için en yüksek uyan kazanır.
static func level_for_salary(role_id: String, monthly_salary: int) -> int:
	for lvl in [LEVEL_SENIOR, LEVEL_MID]:
		if monthly_salary >= int(salary_band_for_level(role_id, int(lvl))[0]):
			return int(lvl)
	return LEVEL_JUNIOR


# ------------------------- §10.2 aday arketipleri ----------------------------
# Her aramada sabit bir üçlü çekilir: amaç her aramada gerçek ve savunulabilir bir karar.
const ARCHETYPE_UZMAN := "uzman"        # ana alanda üçlünün en yükseği, diğerleri zayıf
const ARCHETYPE_DENGELI := "dengeli"    # tepe noktası yok, ana ve ikincilde makul
const ARCHETYPE_PAZARLIK := "pazarlik"  # bir alanda gerçekten iyi, en az birinde kırık
const ARCHETYPES := ["uzman", "dengeli", "pazarlik"]

## [ANA, İKİNCİL, DİĞER] seviye başına. Uzman ve Pazarlık ana alanda Dengeli'den tam 1 yıldız
## (2 puan) yukarıda: §10.2'nin tavanı; biri iki yıldız iyiyse seçim ortadan kalkar.
## ANA >= İKİNCİL >= DİĞER her arketipte (§4.3 ikincili rolün kendi alanı sayar).
const ARCHETYPE_SHAPE := {
	0: {"uzman": [5, 1, 0], "dengeli": [3, 2, 2], "pazarlik": [5, 0, 0]},
	1: {"uzman": [7, 2, 2], "dengeli": [5, 4, 3], "pazarlik": [7, 1, 1]},
	2: {"uzman": [9, 4, 3], "dengeli": [7, 6, 5], "pazarlik": [9, 3, 2]},
}


## Satış rev 6 §11.7 — satış eğrisi yarım basamak aşağıda: satışta yıldız doğrudan paradır
## (koltuk bandı) ve rolün puan harcayacağı ikincili yok. Her satır rol-nötr kardeşinin ana
## alanda −2, geri kalanda −1'idir (tabanı 0), arketip şekilleri korunur.
const ROLE_ARCHETYPE_SHAPE := {
	"sales_rep": {
		0: {"uzman": [3, 0, 0], "dengeli": [2, 1, 1], "pazarlik": [3, 0, 0]},
		1: {"uzman": [5, 1, 1], "dengeli": [4, 3, 2], "pazarlik": [5, 0, 0]},
		2: {"uzman": [6, 3, 2], "dengeli": [5, 4, 4], "pazarlik": [6, 2, 1]},
	},
}


static func archetype_shape(level: int, archetype: String, role_id: String = "") -> Array:
	var table: Dictionary = ROLE_ARCHETYPE_SHAPE.get(role_id, ARCHETYPE_SHAPE) as Dictionary
	var per_level: Dictionary = table[clampi(level, LEVEL_JUNIOR, LEVEL_SENIOR)] as Dictionary
	return (per_level.get(archetype, per_level["dengeli"]) as Array).duplicate()


## §11.7 demo aday tavanı: satış ★3,5'te durur, diğer roller cetvelin sonuna varabilir (§5.3).
const ROLE_STAR_CAP_RAW := {"sales_rep": 7}


static func role_star_cap(role_id: String) -> int:
	return int(ROLE_STAR_CAP_RAW.get(role_id, AREA_MAX))


## §11.7 junior satış tepe dosyası ★2'dir, demo tavanı değil: aynı üçlüde ★1 ile ★3,5
## §10.2'nin "ana alanda fark en fazla 1 yıldız" kuralını çiğnerdi.
const SALES_TOP_JUNIOR_RAW := 4   # 0-10 cetvelde ★2
const SALES_TOP_JUNIOR_CHANCE := 0.25   # [K] §11.7 "aramaların ~%25'inde"


static func role_top_value(role_id: String, level: int) -> int:
	if role_id == ROLE_SALES_REP and level == LEVEL_JUNIOR:
		return SALES_TOP_JUNIOR_RAW
	return role_star_cap(role_id)


## §11.7 aramanın tepe dosyası taşıma olasılığı: herkes nadir beş yıldızlı kıdemliyi alır,
## satış ayrıca ★2 junior'ı ("~%25'inde ve üçlüde TEK ADAYDA").
static func role_top_chance(role_id: String, level: int) -> float:
	if level == LEVEL_SENIOR:
		return FIVE_STAR_CHANCE
	if role_id == ROLE_SALES_REP and level == LEVEL_JUNIOR:
		return SALES_TOP_JUNIOR_CHANCE
	return 0.0


## §10.2 fiyat farkı %20–45: alt sınır kararı anlamlı yapar, üst sınır "pahalı olan zaten
## daha iyi" refleksini engeller.
const SALARY_SPREAD_MIN_R11 := 0.20
const SALARY_SPREAD_MAX_R11 := 0.45

## §10.2 fiyat sırası: Dengeli en pahalı, Pazarlık en ucuz, Uzman "orta–yüksek" (0,6 onu tepeye
## yakın tutar). İki boşluk da yuvarlama adımından (50) büyük, üç dosya aynı rakama düşmez:
## en dar hâlde 1500 × 0,20 × 0,6 = 180 ve 1500 × 0,20 × 0,4 = 120.
const ARCHETYPE_PRICE_UZMAN_SHARE := 0.6

## §10.2 Liderlik seviyeden okunur, arketipin "diğer" değerinden değil; yoksa junior'da Uzman
## ile Pazarlık berabere kalır ve eksen ölür. Dengeli en iyi lider, Uzman en zayıf.
const LEVEL_LEAD_BASE := [1, 2, 3]
const ARCHETYPE_LEAD_OFFSET := {"uzman": -1, "dengeli": 1, "pazarlik": 0}


static func archetype_leadership(level: int, archetype: String) -> int:
	var base: int = int(LEVEL_LEAD_BASE[clampi(level, LEVEL_JUNIOR, LEVEL_SENIOR)])
	return clampi(base + int(ARCHETYPE_LEAD_OFFSET.get(archetype, 0)), AREA_MIN, AREA_MAX)


## §10.2 huy rolleri: Pazarlık HER ZAMAN bedelli huy taşır (TRIO_COST_TRAIT_MIN'in garantisi),
## Uzman "nötr ya da hafif riskli" bir yazı-tura, Dengeli hep bedelsiz.
const UZMAN_COST_TRAIT_CHANCE := 0.35

## §10.2 beş yıldızlı aday: nadir, yalnız Kıdemli bantta, maaş talebi bandın tavanında.
const FIVE_STAR_CHANCE := 0.08
## §10.2: üçlüden en az biri bedelli huy taşır — garanti, üretimden sonra kontrol edilir.
const TRIO_COST_TRAIT_MIN := 1


# ========================= Arama (Atlas Seçme & Yerleştirme) =================
# Ajans özel addır, iki dilde de aynı kalır (glossary §6).
static func search_agency_name() -> String:
	return TranslationServer.translate("HR_AGENCY_NAME")
## §10 tek ücret: arama bedava, işe alımda bir aylık maaşın %50'si komisyon
## ("$3.000'lik bir çalışanın maliyeti $4.500").
const SEARCH_COMMISSION_PCT := 0.50
## §10: aday listesi bir hafta sonra gelir; oyuncu bir ayrılışı o gün kapatamaz.
const SEARCH_ARRIVAL_DAYS := 7
const CANDIDATE_COUNT := 3              # her arayış üç dosya getirir

# ========================= ÇALIŞMA SAATLERİ — §8 =============================
# Ayrı bir ek mesai mekaniği yoktur (§8.2): süre sekizi aşarsa mesai, altına inerse kısa gün.
# Getiri saatin kendisidir (§8.4).
const WORK_HOURS_MIN := 5           # §8.1 en kısa gün
const WORK_HOURS_MAX := 11          # §8.1 en uzun gün — İş Kanunu md.63'ün günlük sınırı
const WORK_HOURS_DEFAULT := 8       # §8.1 şirket kapsamı varsayılanı; herkes bunu devralır

## §8.1: başlangıç saati yalnız şirket kapsamındadır; grup ve çalışan yalnız süreyi değiştirir.
const START_HOUR_DEFAULT := 9
const START_HOUR_MIN := 6
const START_HOUR_MAX := 11

## §7.1 saat → moral çarpanı. Taban sürüklenmeye uygulanır; sıfırın altında işaret döner ve
## moral yükselir. Yukarı doğru hızlanır; aşağıda yedide durur, altıda yükselir, beşte belirgin.
const HOUR_MORALE_MULT := {
	5: -1.0,
	6: -0.5,
	7: 0.0,
	8: 1.0,
	9: 1.1,
	10: 1.3,
	11: 1.5,
}

## §12.1 aşırı yük çarpanı. Çarpanlar çarpılır: 11 saat + aşırı yük = ×2,25.
const OVERLOAD_MORALE_MULT := 1.5

## §8.2 ek mesai ücreti: yalnız sekizi aşan saatler, %50 fazlasıyla (İş Kanunu md.41).
const OVERTIME_WAGE_MULT := 1.5

## Aylık maaş → saatlik ücretin tek sabiti (§8.2): 22 iş günü × 8 saat. Saklanan tek rakam
## aylık maaştır.
const HOURS_PER_MONTH := 176


## §8.4 saatin çıktıya ORANI: sekiz saat 1,0, yani diğer modüllerin kalibre sabitleri ölçek
## değiştirmez. 11 saat → 1,375, 5 saat → 0,625 (§8.1/§8.3).
static func hours_output_mult(hours: int) -> float:
	return float(clampi(hours, WORK_HOURS_MIN, WORK_HOURS_MAX)) / float(WORK_HOURS_DEFAULT)


static func hour_morale_mult(hours: int) -> float:
	return float(HOUR_MORALE_MULT.get(clampi(hours, WORK_HOURS_MIN, WORK_HOURS_MAX), 1.0))


static func is_overtime_hours(hours: int) -> bool:
	return hours > WORK_HOURS_DEFAULT


static func is_short_day_hours(hours: int) -> bool:
	return hours < WORK_HOURS_DEFAULT


static func hourly_wage(monthly_salary: int) -> float:
	return float(maxi(monthly_salary, 0)) / float(HOURS_PER_MONTH)


## Bir günün ek mesai tahakkuku. İzindeki/eğitimdeki için çağrılmaz (§8.6).
static func overtime_pay_for_day(monthly_salary: int, hours: int) -> int:
	var extra: int = maxi(hours - WORK_HOURS_DEFAULT, 0)
	if extra <= 0:
		return 0
	return int(round(hourly_wage(monthly_salary) * float(extra) * OVERTIME_WAGE_MULT))

# FinanceSystem.apply_one_time_cost defter etiketleri. Const değil fonksiyon: const yüklemede
# bir kez değerlendirilir ve o anki dili dondururdu.
static func cost_label_hire() -> String:
	return TranslationServer.translate("HR_COST_HIRING")


static func cost_label_severance() -> String:
	return TranslationServer.translate("HR_COST_SEVERANCE")

# Ticker kaynağı (EventBus.headline_added); emit anında yerelleştirilir.
static func notice_source_hr() -> String:
	return TranslationServer.translate("HR_LABEL_HR")

# apply_delta sebep sözlüğü — oyuncuya görünmez; her çağıran kendi yazımını icat etmesin.
const REASON_LEAVE_RETURN := "leave_return"
const REASON_VACATION_RETURN := "vacation_return"
const REASON_RAISE := "raise"
const REASON_TEAMMATE_FIRED := "teammate_fired"

# Arama durum makinesi (GameState.hr_search.state).
const SEARCH_IDLE := "idle"
const SEARCH_SEARCHING := "searching"
const SEARCH_FILES_READY := "files_ready"


static func commission_for(monthly_salary: int) -> int:
	return int(round(float(monthly_salary) * SEARCH_COMMISSION_PCT))


# ================================ Moral ======================================
# §7: moral hedefe doğru sürüklenir (taban drift × saat çarpanı) ve adı olan olaylarla
# (mesai, oyuncu eylemleri, izin dönüşü, ayrılış, olaylar) hareket eder.
# Sınırlar CharacterRegistry.set_morale'in clamp'iyle aynı; önizleme yazılacak sayıyı vaat eder.
const MORALE_MIN := 0
const MORALE_MAX := 100

## §7 bantları. Moral yalnız HIZI etkiler; kalite yıldızlarda ve TİTİZ huyunda.
const MORALE_BAND_HIGH := 80        # ve üstü → +%10 hız
const MORALE_BAND_LOW := 50         # altı → −%15 hız
const MORALE_BAND_HIGH_MULT := 1.10
const MORALE_BAND_MID_MULT := 1.0
const MORALE_BAND_LOW_MULT := 0.85

## §4.2 Liderlik katsayıları: liderlik bir İNSAN istatistiğidir. Çıktı tarafı ölçülü (moral bandı
## birincil hız kaldıracı kalsın), moral tarafı cömert. Yarım yıldız başına çıktı +%1 · moral
## düşüş hızı −%2. Yüzdeler ekranda görünmez (§4.2).
const LEAD_OUTPUT_PER_POINT := 0.01
const LEAD_MORALE_PER_POINT := 0.02

## Taban günlük düşüş; §7.1 saat çarpanı YALNIZ buna uygulanır, olay deltaları ham iner.
## 0,25 = ayda 7,5 puan: sekiz saat geri sayım değil hafif baskıdır, yedi saat gerçek rahatlama.
const MORALE_BASE_DRIFT_PER_DAY := 0.25

## §7 "anında sıçramaz": görünen moral hedefe günde en fazla bu kadar yürür; −15'lik bir
## olay beş günde iner ve oyuncunun tepki penceresi budur.
const MORALE_EASE_PER_DAY := 3.0

const MORALE_LEAVE_DEFER := 5            # §11.4 erteleme bedeli
const MORALE_PROMOTION_AT_MIN_PCT := 8   # %10 terfi zammında
const MORALE_PROMOTION_AT_MAX_PCT := 20  # %25 terfi zammında


static func morale_band_mult(morale: int) -> float:
	match morale_band_id(morale):
		"high":
			return MORALE_BAND_HIGH_MULT
		"low":
			return MORALE_BAND_LOW_MULT
	return MORALE_BAND_MID_MULT


## §15.3 hr.morale_band(kişi) — bant kimliği, sayı değil.
static func morale_band_id(morale: int) -> String:
	if morale >= MORALE_BAND_HIGH:
		return "high"
	if morale < MORALE_BAND_LOW:
		return "low"
	return "mid"
const MORALE_FLIGHT_RISK := 35      # §7: altı → Ayrılabilir
const MORALE_HIRE_START := 75       # WORKING: yeni işe alınanın başlangıç morali
const MORALE_LEAVE_RETURN := 15     # §11.4 izin dönüşü, tek seferde
## Manuel tatil dönüşü. Oyuncu eylemi yok; `send_on_leave`'in `is_manual` dalı gelecek olay
## kanalı için bekliyor (§15.3 bildirilmiş ama henüz ateşlenmemiş).
const MORALE_VACATION_RETURN := 20
const MORALE_FIRE_TEAM := 5         # ayrılışta kalan ekipteki DÜŞÜŞ büyüklüğü
const MORALE_RAISE_AT_MIN_PCT := 4  # %3 zamda moral kazancı  (WORKING)
const MORALE_RAISE_AT_MAX_PCT := 10 # %10 zamda moral kazancı

# Rozet id'leri (§15.1): saklanmaz, HRMoraleSystem.badges_for türetir. YENİ bir dikkat rozeti
# değildir ve bu kümeye girmez.
const BADGE_FLIGHT_RISK := "FLIGHT_RISK"
## §13.3 AŞIRI YÜK — atanmış iş sayısı 2.
const BADGE_OVERLOAD_JOBS := "OVERLOAD_JOBS"

# badges_for'un en-kötü-önce sırası; liste "dikkat" satırlarını yeniden karar vermeden sıralar.
const BADGE_SEVERITY := {
	BADGE_FLIGHT_RISK: 3,
	BADGE_OVERLOAD_JOBS: 1,
}

## §17.4: YENİ rozetinin süresi; Atlas'ın bir haftalık bekleyişini ve bir yerleşme süresini taşır.
const NEW_HIRE_BADGE_DAYS := 14

# Character.status — saklanan DURUM; rozet her çizimde türetilir.
const STATUS_ACTIVE := "active"
const STATUS_ON_LEAVE := "on_leave"
# Eğitimde: kapasite dışı, mesai dışı, SORUMLU seçilemez. `on_leave`'den ayrı olmalı, yoksa
# yıllık izin latch'i ve izin dönüşü ödülü tetiklenirdi.
const STATUS_TRAINING := "training"

# --- Deneyim / eğitim ---
const EXPERIENCE_LEAD_BONUS_MAX := 1.5  # WORKING: Liderlik tavanındaki lider altında öğrenme hızı

## §5.1 deneyim tek bar, ekranda hep 0–100; kendiliğinden yıldıza dönüşmez, tek çıkışı eğitim.
const EXPERIENCE_PER_WORKED_DAY := 2   # en az bir işe atanmış ve edilgen olmayan her gün
const EXPERIENCE_BUILD_BONUS := 1      # bir geliştirme fazı koşarken üstüne (toplam 3)

## Eşik = BASE + PER_POINT × (altı alan + Liderlik ham toplamı). Junior (T≈12) ≈37 günde,
## dört yıldızlı kıdemli (T≈25) ≈63 günde dolar (§5.1 "belirgin şekilde uzun"). Girdi
## istatistiktir: dışarıdan alınan beş yıldızlı biri de yavaş olmalı.
const EXPERIENCE_THRESHOLD_BASE := 40
const EXPERIENCE_THRESHOLD_PER_POINT := 6


static func experience_threshold(total_skill_points: int) -> int:
	return EXPERIENCE_THRESHOLD_BASE + EXPERIENCE_THRESHOLD_PER_POINT * maxi(total_skill_points, 0)


## §5.3 kademeli bedel: ücret = BASE × GROWTH^(mevcut ham puan). Kademe YARIM yıldızdır ki
## §5.5'in istediği gibi yarım yıldızlık fark satırda okunsun. Merdiven: 400 · 528 · 697 · 920 ·
## 1.214 · … · 4.867; son kademe ilkin ~12 katı. Tekrar zammı ve Liderlik çarpanı yok: §5.3
## bedeli yalnız hedef alanın mevcut seviyesine göre kademelendirir.
const TRAINING_FEE_BASE := 400
const TRAINING_FEE_GROWTH := 1.32


static func training_fee_tiered(current_area_value: int) -> int:
	var rung: int = clampi(current_area_value, AREA_MIN, AREA_MAX)
	return int(round(float(TRAINING_FEE_BASE) * pow(TRAINING_FEE_GROWTH, float(rung))))
const TRAINING_DAYS := 14            # §5.2: "Çalışan İKİ HAFTA eğitimde kalır"

## §5.5: süre metni gün sayısından türetilir ki süre değişince metin yalan söylemesin. Tam
## haftaya bölünüyorsa hafta, değilse gün.
static func training_duration_text() -> String:
	if TRAINING_DAYS % 7 == 0:
		return TranslationServer.translate("HR_DURATION_WEEKS").format({"n": TRAINING_DAYS / 7})
	return TranslationServer.translate("HR_DURATION_DAYS").format({"n": TRAINING_DAYS})


static func trainable_keys() -> Array:
	## Eğitilebilir yetenekler: altı alan + Liderlik. Karizma yalnız kurucuda.
	var out: Array = AREAS.duplicate()
	out.append(SKILL_LEADERSHIP)
	return out


static func is_trainable_key(skill_key: String) -> bool:
	return AREAS.has(skill_key) or skill_key == SKILL_LEADERSHIP


static func badge_label(badge_id: String) -> String:
	return _derived("HR_BADGE_", badge_id)


static func badge_severity(badge_id: String) -> int:
	# Dikkat rozeti olmayan her şey 0; bilgi etiketi bir uyarıyı sıralamada geçemez.
	return int(BADGE_SEVERITY.get(badge_id, 0))


static func is_new_hire(hire_day: int, today: int) -> bool:
	# hire_day işe alımın ERTESİ gününe damgalanır, ödeme günü today < hire_day'dir.
	return today <= hire_day + NEW_HIRE_BADGE_DAYS


static func is_flight_risk(morale: int) -> bool:
	return morale < MORALE_FLIGHT_RISK


# ===================== Liderlik: iklim + koordinasyon =========================
# Liderlik satış, bug ve pazarlık formüllerine girmez (§4.2).
const CLIMATE_DROP_PER_POINT := 0.05   # her Liderlik puanı moral düşüşlerini bu oranda kısar
const CLIMATE_DROP_FLOOR := 0.50       # en iyi liderlikte bile düşüşün yarısı kalır
const CLIMATE_GAIN_PER_POINT := 0.05   # her puan toparlanmaları bu oranda büyütür
const CLIMATE_GAIN_CAP := 1.50

const COORD_MIN := 0.85                # zayıf ÇALIŞAN sorumlu — ekip birbirini bekler
const COORD_MAX := 1.20                # güçlü sorumlu (her iki kaynak için de tavan)
const COORD_MAX_WITH_TRAIT := 1.25     # "Doğal lider" tavanı da yükseltir
const COORD_NATURAL_LEADER_BONUS := 0.05
# Kurucu-lider Liderlik 0'da NÖTR ve yalnız yükselir: "CEO olarak ekibin başında olmak hız
# cezası DEĞİL" (§4.2). Aynı zamanda "kurucu tech-3 solo = 3.0 efor/gün" çıpasını korur.
const COORD_FOUNDER_NEUTRAL := 1.0


static func climate_drop_mult(leadership: int) -> float:
	return clampf(1.0 - float(maxi(leadership, 0)) * CLIMATE_DROP_PER_POINT, CLIMATE_DROP_FLOOR, 1.0)


static func climate_gain_mult(leadership: int) -> float:
	return clampf(1.0 + float(maxi(leadership, 0)) * CLIMATE_GAIN_PER_POINT, 1.0, CLIMATE_GAIN_CAP)


# Çarpan KAYNAĞA göre asimetriktir: kurucu her zaman odadadır, Liderlik'i yalnız EKLER;
# SEÇİLMİŞ bir çalışan lider gerçek bir bahistir ve zayıfı gerçekten kötü koordine eder.
# ProductSystem._speed_for_lead lidere göre doğru olanı seçer.

static func coordination_for_founder(leadership: int, has_natural_leader: bool = false) -> float:
	var span: float = COORD_MAX - COORD_FOUNDER_NEUTRAL
	var t: float = clampf(float(leadership) / float(AREA_MAX), 0.0, 1.0)
	var m: float = COORD_FOUNDER_NEUTRAL + span * t
	if has_natural_leader:
		m += COORD_NATURAL_LEADER_BONUS
	return clampf(m, COORD_FOUNDER_NEUTRAL, COORD_MAX_WITH_TRAIT)


static func coordination_for_lead(leadership: int, has_natural_leader: bool = false) -> float:
	# Tüm cetvel boyunca iki yönlü: Liderlik 0 → COORD_MIN, tavan → COORD_MAX.
	var t: float = clampf(float(leadership) / float(AREA_MAX), 0.0, 1.0)
	var m: float = lerpf(COORD_MIN, COORD_MAX, t)
	if has_natural_leader:
		m += COORD_NATURAL_LEADER_BONUS
	return clampf(m, COORD_MIN, COORD_MAX_WITH_TRAIT)


# ============================ İstifa — §11.3 =================================
# Kaçma riski ihmal edilirse istifa. Karar yukarıdadır: rozet bütün pencere boyunca görünür
# ve kart eylemleri açıktır — ihmal kararın kendisidir.
const RESIGN_WINDOW_MIN_DAYS := 10      # kaçma riski bu kadar gün sürerse roll başlar
const RESIGN_WINDOW_MAX_DAYS := 14      # pencerenin üst sınırı; bu gün istifa kesin
const RESIGN_CHANCE_PER_DAY := 0.25     # WORKING: pencere boyunca ~%76 birikimli


static func resign_chance(trait_ids: Array) -> float:
	return clampf(RESIGN_CHANCE_PER_DAY * trait_mult(trait_ids, "resign_chance_mult"), 0.0, 1.0)


## Ayrılış tek replikli olaydır (§11.3). Karakter id'sinin hash'iyle seçilir (String.hash
## kararlıdır), aynı kişi hep aynı satırı söyler.
const RESIGN_VOICE_COUNT := 4


static func resign_voice(character_id: String) -> String:
	return TranslationServer.translate("HR_RESIGN_VOICE_%d" % (posmod(absi(character_id.hash()), RESIGN_VOICE_COUNT) + 1))


# --------------------- §11.4 yaz izni (hafta tabanlı) ------------------------
# İzin çalışanın kendisine aittir. İki hafta, tek blok, Haziran–Ağustos penceresinde.
# Ücretli: maaş akar, kapasite/hız/CS/mesai katkısı durur.
const LEAVE_DAYS := 14                  # §11.4 "iki hafta (10 iş günü)"
const LEAVE_WINDOW_START_MONTH := 6     # Haziran
const LEAVE_WINDOW_END_MONTH := 8       # Ağustos
## Yaz penceresi ~13 hafta. Adım 5 ile 13 aralarında asal: on üç ardışık işe alım on üç
## farklı haftaya düşer ve bütün ekip aynı hafta izinde olmaz.
const LEAVE_WEEK_COUNT := 13
const LEAVE_WEEK_STRIDE := 5
## §11.4 erteleme: −5 moral, talep 30 gün sonra döner, en fazla iki kez.
const LEAVE_MAX_DEFERRALS := 2
const LEAVE_DEFER_DAYS := 30


## hire_ordinal = bu kişiden önce kaç çalışan alındı. Sonuç 0..12 hafta indeksi.
static func leave_week_for(hire_ordinal: int) -> int:
	return (LEAVE_WEEK_STRIDE * maxi(hire_ordinal, 0)) % LEAVE_WEEK_COUNT


## §9.3 terfi zammının moral kazancı — %10 → MIN, %25 → MAX, arası doğrusal.
static func promotion_morale_gain(pct: int) -> int:
	return _lerp_gain(pct, PROMOTION_MIN_PCT, PROMOTION_MAX_PCT,
		MORALE_PROMOTION_AT_MIN_PCT, MORALE_PROMOTION_AT_MAX_PCT)


## §9.2 zammın moral kazancı — RAISE_MIN_PCT → MIN, RAISE_MAX_PCT → MAX, arası doğrusal.
static func raise_morale_gain(pct: int) -> int:
	return _lerp_gain(pct, RAISE_MIN_PCT, RAISE_MAX_PCT,
		MORALE_RAISE_AT_MIN_PCT, MORALE_RAISE_AT_MAX_PCT)


static func _lerp_gain(pct: int, pct_min: int, pct_max: int, gain_min: int, gain_max: int) -> int:
	var t: float = float(clampi(pct, pct_min, pct_max) - pct_min) / float(maxi(1, pct_max - pct_min))
	return int(round(lerpf(float(gain_min), float(gain_max), t)))


## §11.1 kıdem tazminatı, basamaklı ve tavanlı: 1 yıldan az ⅓ maaş · 1 yıl 1 · 2 yıl 2 ·
## 3 yıl ve üzeri 3. Tamamlanmış yıl esas alınır, ara aylar yukarı yuvarlanmaz.
const SEVERANCE_UNDER_ONE_YEAR := 1.0 / 3.0
const SEVERANCE_MAX_MONTHS := 3.0


static func severance_multiple(days_served: int) -> float:
	var years: int = int(floor(float(maxi(days_served, 0)) / float(DAYS_PER_YEAR)))
	if years < 1:
		return SEVERANCE_UNDER_ONE_YEAR
	return minf(float(years), SEVERANCE_MAX_MONTHS)


static func severance_amount(monthly_salary: int, days_served: int) -> int:
	return int(round(float(monthly_salary) * severance_multiple(days_served)))


# ======================= Oyuncu eylemleri (çalışan kartı) ====================
const RAISE_MIN_PCT := 3           # zam slider alt sınırı (§9.2)
const RAISE_MAX_PCT := 10          # §9.2 aralık %3–10
const RAISE_COOLDOWN_DAYS := 180   # §9.2 "aynı çalışana altı ay geçmeden yeni zam verilemez"
## §9.3 terfi: tek seviye atlama, oyuncu %10–25 arası zammı slider'dan seçer.
const PROMOTION_MIN_PCT := 10
const PROMOTION_MAX_PCT := 25
const DAYS_PER_YEAR := 365         # kıdem hesabı (hire_day → tam yıl)


## HR para biçimi; Fmt'ye devreder ki iki dilde doğru gruplansın.
static func money_tr(amount: int) -> String:
	return Fmt.money_exact(amount)


# ============================ Aday dosyası içeriği ===========================
# Üreticinin saf hash'iyle deterministik indekslenir, RNG değil.
const FIRST_NAMES := [
	"Kerem", "Selin", "Arda", "Deniz", "Ece", "Mert", "Zeynep", "Baran",   # LOC-DATA name pool
	"Elif", "Onur", "Sena", "Kaan", "Bilge", "Tolga", "Nehir", "Emre",   # LOC-DATA name pool
]
const LAST_NAMES := [
	"Aksoy", "Koç", "Güneş", "Demir", "Kaya", "Arslan", "Yıldız", "Çetin",   # LOC-DATA name pool
	"Doğan", "Şahin", "Erdem", "Polat", "Tekin", "Uysal",   # LOC-DATA name pool
]
# Tek satırlık dosya notu — mizaç verir, skill tekrarı yapmaz. Satırlar HR_FILE_NOTE_<n>.
const FILE_NOTES_COUNT := 12


static func file_notes_line(index: int) -> String:
	return TranslationServer.translate("HR_FILE_NOTE_%d" % (posmod(index, FILE_NOTES_COUNT) + 1))


## Rolün ana/ikincil ALANININ oyuncuya getirisi (HR_AREA_MEANING_<ROLE>_<AREA>). Yalnız rolün
## kendi iki alanının satırı var; §4.4 altısını düz listede göstermeyi yasaklar.
static func role_area_meaning(role_id: String, area_key: String) -> String:
	if not is_employee_role(role_id):
		return ""
	return _derived("HR_AREA_MEANING_", role_id + "_" + area_key)
