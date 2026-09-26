class_name HRSystem
extends RefCounted

# Pure-logic system. Driven by TimeManager.daily_tick slot 3 (ordered dispatch).
#
# This file is the DAILY ORCHESTRATOR of HR plus its read surface; every rule lives in the
# system that owns it:
#   HRSearchSystem     — Atlas arayışı, aday dosyaları, işe alım
#   HRMoraleSystem     — moral (hedef + taban sürüklenme + ease), izin, eşikler, istifa
#   HRActions          — zam / terfi / işten çıkarma (oyuncu tetikler, tick'te değil)
#   HRConstants        — her HR sayısının TEK evi
#
# Salary→Finance link: HR does NOT push payroll. FinanceSystem pulls
# CharacterRegistry.get_total_monthly_salaries() and WorkHoursSystem.overtime_pay_accrued_today()
# at the top of its own daily_tick (slot 5), so daily_burn never publishes fresh overtime
# against stale salaries.
#
# Frank (category "mentor") is excluded from every path here because they all iterate
# get_employees()/get_active_employees(), which filter on category == "employee".


static func daily_tick() -> void:
	# Order matters; each step reads state the previous one settled:
	#  1. Leave RETURNS first, so anything below sees the restored `active` status.
	#  2. Leave DEPARTURES next, so today's capacity/speed/overtime already excludes them.
	#  3. Search arrival can add an employee, so it lands before anything that iterates the
	#     roster for morale.
	#  4. §7 taban sürüklenme eşiklerden ÖNCE: bugünün saat ayarı ve aşırı yükü hedefe yazılır,
	#     ease onu morale taşır, sonra eşikler O MORALİ okur. Ters sıra Ayrılabilir'i bir gün
	#     geriden getirirdi.
	#  5. DENEYİM: bugün gerçekten çalışmış olanlar biriktirir.
	#  6. EĞİTİM en sonda: önce koşarsa bitiş günü sıfırlanan deneyime tick_experience aynı
	#     gün bir puan geri verir ve "biterken sıfırlanır" sözleşmesi bozulur.
	HRMoraleSystem.tick_leave_returns()
	HRMoraleSystem.tick_leave_departures()
	HRSearchSystem.daily_tick()
	HRMoraleSystem.tick_drift()
	HRMoraleSystem.tick_ease()
	HRMoraleSystem.tick_thresholds()
	tick_experience()
	tick_training()
	# LAST, and it has to be: EventBus.day_advanced fires BEFORE the daily ticks are dispatched,
	# so a screen repainting on it would read HR state from before the steps above. The HR tab
	# listens here.
	EventBus.hr_day_processed.emit()


# --- DENEYİM / EĞİTİM ---

## Günlük deneyim birikimi — §5.1 "Çalışan projelerde aktif rol aldıkça deneyim kazanır."
## TEK BAR, alan başına değil. YALNIZ gerçekten çalışanlar: izindeki ya da eğitimdeki biri
## get_active_employees dışında kalır.
##
## BOŞTAKİ KİŞİ ÖĞRENMEZ: §12.2'nin "Boşta çalışan maaş yemeye devam eder" cümlesinin ikinci
## yarısı — boşta durmak yalnız bugünü değil yarını da kaybettirir.
##
## AŞIRI YÜK ÖĞRENMEYİ YAVAŞLATMAZ: odak katsayısı ÇIKTI hakkındadır (§12.1) ve iki işteki
## kişi aynı saatleri çalışır. Aynı sürede aynı deneyim.
static func tick_experience() -> void:
	var base: int = HRConstants.EXPERIENCE_PER_WORKED_DAY
	if _build_phase_running():
		base += HRConstants.EXPERIENCE_BUILD_BONUS
	# §4.2: lider ataması yapım başınadır; lidersiz alanların öğrenme iklimi kurucudan gelir,
	# o yüzden burada kurucunun Liderlik'i okunur. GERÇEK LİDER'in lead_experience_mult'u
	# burada OKUNMUYOR (bkz. HRConstants.TRAITS).
	var lead_mult: float = HRConstants.experience_gain_mult(
		GameState.get_founder_skill(HRConstants.SKILL_LEADERSHIP))
	# KURUCU DA ÖĞRENİR: Kişisel kartı bir DENEYİM çubuğu çiziyor (§2.5).
	var learners: Array[Character] = CharacterRegistry.get_active_employees()
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null and founder.status == HRConstants.STATUS_ACTIVE:
		learners.append(founder)
	for emp in learners:
		if emp.assigned_job_ids.is_empty():
			continue
		# ÇABUK KAPAR: kişinin KENDİ öğrenme hızı (§6).
		var own_mult: float = HRConstants.trait_mult(emp.traits, "experience_mult")
		var gain: int = int(round(float(base) * own_mult * lead_mult))
		CharacterRegistry.add_experience(emp.id, maxi(gain, 1))


## Eğitim günlerini işler; biten her eğitim bir haber satırı bırakır. Kurucu dahil:
## get_employees() onu içermez ve dışarıda kalırsa STATUS_TRAINING'de askıda kalırdı.
static func tick_training() -> void:
	var in_training: Array[Character] = CharacterRegistry.get_employees()
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null:
		in_training.append(founder)
	for emp in in_training:
		if emp.training_days_left <= 0:
			continue
		if CharacterRegistry.tick_training(emp.id):
			EventBus.headline_added.emit(HRConstants.notice_source_hr(),
				TranslationServer.translate("HR_NEWS_TRAINING_DONE").format({
					"name": emp.character_name,
				}))


## Oyuncunun kararı: birini eğitime gönder, HANGİ ALANDA olduğunu söyleyerek (§5.2).
## §5.3: ücret yalnız hedef alanın mevcut seviyesine göre kademelenir
## (CharacterRegistry.training_fee_for). `false` yalnız kişi/alan uygun değilse.
static func send_to_training(id: String, area_key: String) -> bool:
	if not CharacterRegistry.can_train(id, area_key):
		return false
	# §5.4: "PARANIN YETMEMESİ BİR KİLİT DEĞİLDİR; bir bedeldir ve modalde okunur." Kasa
	# eksiye düşebilir — işe alım komisyonuyla aynı kanal, aynı olağan iflas yolu.
	FinanceSystem.apply_one_time_cost(CharacterRegistry.training_fee_for(id, area_key), "training")
	CharacterRegistry.begin_training(id, area_key)
	return true


## Bir geliştirme fazı KOŞUYOR mu? ProductSystem'in faz listesiyle aynı üçlü.
static func _build_phase_running() -> bool:
	var b: FeatureBuild = ProductSystem.get_active_build()
	return b != null and b.current_phase in ["iteration", "development", "bugfix"]


# ============================================================================
#  §15.3 · OKUMA YÜZEYİ — olay motoruna açılan katalog
# ============================================================================
# Diğer modüller ve olay motoru Ekip verisine doğrudan uzanarak değil, bu adlandırılmış
# katalog üzerinden erişir. Bazılarının bugün tüketicisi yok ve bu kasıtlı (§17.3). Adlar
# KARARLIDIR; §15.3 bunu bir sözleşme olarak yazıyor.

static func morale(c: Character) -> int:
	return 0 if c == null else c.morale


## Bant KİMLİĞİ döner, sayı değil — "oyuncu sebebi görür, katsayıyı görmez" (§4.2, §8.5).
static func morale_band(c: Character) -> String:
	return "mid" if c == null else HRConstants.morale_band_id(c.morale)


static func headcount() -> int:
	return CharacterRegistry.count_employees()


## HAM 0–10. Ekranda beş yıldıza çevrilir (§4.1).
static func skill(c: Character, area_key: String) -> int:
	return 0 if c == null else int(c.role_stats.get(area_key, 0))


static func status(c: Character) -> String:
	return "" if c == null else c.status


## §2.2 MEŞGULİYET TEK MODEL: izindeyken · eğitimdeyken · (kurucu) yatırım hazırlığında ya da
## satış toplantısındayken. Ara kademe, yarı hız çarpanı, kısmi kapasite YOKTUR.
## Satış toplantısı (Satış §5.0) sekizinci bir görev durumu değildir: toplantı atomiktir ve
## atlanan iki saat "kurucu katkısı sıfır" sayılır. Yapım yolu ProductSystem._is_free'yi,
## araştırma burayı okur — ikisine de eklenmezse kurucu inşa ederken araştırmadan donar.
static func is_busy(c: Character) -> bool:
	if c == null:
		return false
	if c.status == HRConstants.STATUS_ON_LEAVE or c.status == HRConstants.STATUS_TRAINING:
		return true
	return c.category == "founder" and (bool(GameState.get_flag("pitch_prep_active", false))
		or bool(GameState.get_flag("sales_meeting_active", false)))


static func tenure_days(c: Character) -> int:
	if c == null or c.hire_day <= 0:
		return 0
	return maxi(GameState.day - c.hire_day, 0)


## KİŞİ → HESAPLAR ters indeksi — §11.3'ün ayrılma sorusu ("müşterilerine kim bakacak?").
static func accounts_of(c: Character) -> Array:
	if c == null:
		return []
	var out: Array = []
	for cu in CustomerRegistry.get_all():
		if cu != null and String(cu.assigned_to) == c.id:
			out.append(cu)
	return out


## §8.1 devralma zinciri. Hiçbir sistem zinciri kendisi yürütmez (§15.2).
static func work_hours(c: Character) -> int:
	return WorkHoursSystem.hours_for(c)


static func work_hours_company() -> Dictionary:
	return {
		"hours": GameState.company_work_hours,
		"start_hour": WorkHoursSystem.start_hour(),
	}


static func work_hours_overrides() -> int:
	return WorkHoursSystem.override_count()


static func overtime_active(c: Character) -> bool:
	return WorkHoursSystem.overtime_active(c)


static func short_day_active(c: Character) -> bool:
	return WorkHoursSystem.short_day_active(c)


## §2.3 · KURUCUNUN GÖREV DURUMU — TÜRETİLİR, SAKLANMAZ (§15.1'in rozet kuralı).
const FOUNDER_STATE_BUILD := "build"
const FOUNDER_STATE_SALES := "sales"
const FOUNDER_STATE_SUPPORT := "support"
const FOUNDER_STATE_RESEARCH := "research"
const FOUNDER_STATE_PITCH_PREP := "pitch_prep"
const FOUNDER_STATE_TRAINING := "training"
## PASİF MÜŞTERİ İLGİSİ. Bir atama değil bir okuma: kurucu başka hiçbir şey yapmıyorken
## destek masası onu kendiliğinden sayar. BOŞTA'nın önünde okunur — ikisi de "bir işi yok"
## der, ama biri kaybedilmiş zamandır ve öteki değil.
const FOUNDER_STATE_CARE := "care"
const FOUNDER_STATE_IDLE := "idle"


## Kişisel sayfasının tek satırı (Ekip §2.5). Durum id'si MOTORUN, cümle EKRANIN; ikisi de
## burada durur (§16).
##
## İKİ SÜREKLİ İŞ İÇİN SEKİZİNCİ BİR DURUM İCAT EDİLMEZ: §2.3 kapalı bir tablodur. Satır
## §12.2'nin çalışan grameri ödünç alır — iki ayrı işin kısa etiketi, `·` ile. Meşgul
## durumlar (eğitim, yatırım hazırlığı) atamanın üstünü örter, o yüzden önce gelir.
static func founder_task_label() -> String:
	var f: Character = CharacterRegistry.get_founder()
	if f != null and f.assigned_job_ids.size() > 1 \
			and f.status != HRConstants.STATUS_TRAINING \
			and not bool(GameState.get_flag("pitch_prep_active", false)):
		var parts := PackedStringArray()
		for job in f.assigned_job_ids:
			parts.append(HRConstants.job_label(String(job)))
		return " · ".join(parts)
	return TranslationServer.translate("HR_FOUNDER_STATE_%s" % founder_task_state().to_upper())


static func founder_task_state() -> String:
	var f: Character = CharacterRegistry.get_founder()
	if f == null:
		return FOUNDER_STATE_IDLE
	# SIRA ÖNEMLİ: meşgul durumlar önce okunur (§2.3'ün "Meşgul mü" sütunu). Eğitim ve
	# yatırım hazırlığı yapımı DURDURUR, o yüzden bir yapım atamasının üstünü örterler.
	if f.status == HRConstants.STATUS_TRAINING:
		return FOUNDER_STATE_TRAINING
	if bool(GameState.get_flag("pitch_prep_active", false)):
		return FOUNDER_STATE_PITCH_PREP
	# ARAŞTIRMA YAPIMDAN ÖNCE (Ar-Ge §5.0): araştıran kurucu başka hiçbir şey yapmıyor, yani
	# duraklamış yapımının adını taşımak yalan olurdu.
	if f.assigned_job_ids.has(HRConstants.JOB_RESEARCH):
		return FOUNDER_STATE_RESEARCH
	if f.assigned_job_ids.has(HRConstants.JOB_BUILD):
		return FOUNDER_STATE_BUILD
	# Satış işindeki kurucu CARE'e düşmemeli: o zaman satış yaparken destek de üretirdi.
	if f.assigned_job_ids.has(HRConstants.JOB_SALES) \
			or f.assigned_job_ids.has(HRConstants.JOB_ACCOUNTS):
		return FOUNDER_STATE_SALES
	if f.assigned_job_ids.has(HRConstants.JOB_SUPPORT) or f.assigned_job_ids.has(HRConstants.JOB_TEST):
		return FOUNDER_STATE_SUPPORT
	# Atama YOKLUĞUNU okur: canlı bir ürün varken işsiz kurucu müşterilerle ilgileniyordur ve
	# destek masası onu sayar (SupportSystem.desk_roster); ürün yokken gerçekten boştadır.
	if SupportSystem.founder_passive_care():
		return FOUNDER_STATE_CARE
	return FOUNDER_STATE_IDLE


# ======================= Görev ataması: okuma seam'leri ======================
# §12. CharacterRegistry TEK YAZARDIR; burası okuma tarafı. Ürün, Satış ve Operasyon
# "kim meşgul" sorusunu buradan sorar.

## O ALANA atanmış, BUGÜN ÇALIŞABİLİR herkes. İzindeki ve eğitimdeki dışarıda: ataması durur
## (§12.3 — dönünce işine döner) ama bugünkü hiçbir formüle girmez (§8.6).
static func assigned_to(area_id: String) -> Array[Character]:
	return _on_duty(area_id, false)


## O İŞE atanmış, BUGÜN ÇALIŞABİLİR herkes — assigned_to ile aynı süzgeç.
static func assigned_to_job(job_id: String) -> Array[Character]:
	return _on_duty(job_id, true)


static func _on_duty(key: String, by_job: bool) -> Array[Character]:
	var out: Array[Character] = []
	for c in CharacterRegistry.get_all():
		if c == null or c.status != HRConstants.STATUS_ACTIVE:
			continue
		if c.category != "employee" and c.category != "founder":
			continue
		if (c.assigned_job_ids if by_job else c.assigned_jobs).has(key):
			out.append(c)
	return out


## §12.2 "Boşta" — hiçbir İŞE atanmamış. Çalışan durur ve maaş yemeye devam eder; kurucu
## maaş almadığı için boştalığı bir gider değil kaybedilmiş zamandır.
static func is_idle(c: Character) -> bool:
	return c != null and c.category == "employee" and c.assigned_job_ids.is_empty()


## §15.3 hr.job_count(kişi) → 0, 1 ya da 2.
static func job_count(c: Character) -> int:
	return 0 if c == null else c.assigned_job_ids.size()


## §12.1 AŞIRI YÜK = atanmış İŞ sayısı 2. Alandan sayılamaz: Build + Destek taşıyan bir
## developer İKİ iş tutar ama tek alana (Yazılım) yansır.
static func is_overloaded(c: Character) -> bool:
	return c != null and c.assigned_job_ids.size() > 1


## İŞ SAYAR, ALAN DEĞİL — is_idle() ile aynı alanı okur. Alan aynası (`assigned_jobs`)
## araştırmayı dışarıda bırakır, yani araştıran biri orada boşta görünürdü.
static func idle_count() -> int:
	var n: int = 0
	for c in CharacterRegistry.get_active_employees():
		if c.assigned_job_ids.is_empty():
			n += 1
	return n


## §15.3 hr.unstaffed_jobs() — kimsenin atanmadığı işler. §12.2: bir uyarı satırı olarak
## çizilmez — matris boş sütunu zaten gösteriyor ve oyunun başında uyarılar gürültü üretir.
static func unstaffed_jobs() -> Array[String]:
	var out: Array[String] = []
	for job_id in HRConstants.JOBS:
		if assigned_to_job(String(job_id)).is_empty():
			out.append(String(job_id))
	return out


## Çıktı çarpanı, ÇALIŞILAN ALAN bilindiğinde. Yorgunluk gerçekten çalışılan alandan
## ölçülür, işin genel alanından değil — §5'in "ikincil alanında çalışmak daha yorucudur"
## cümlesi ancak böyle ısırır. §12.1 odak katsayısı: iki işteki kişi her iki işe 0,50 verir.
static func output_mult_for_area(c: Character, area_key: String) -> float:
	if c == null:
		return 0.0
	return HRConstants.area_fatigue_mult(c.role, area_key) * HRConstants.focus_mult(job_count(c))


# ==================== §4.5 · ETKİN ÇIKTI — KANONİK FORMÜL ====================
# "Bir kişinin bir işteki etkin çıktısı TEK BİR YERDE tanımlıdır. Başka hiçbir modül kendi
# hız formülünü kurmaz; hepsi buna referans verir." Ürün, Satış, Destek ve Ar-Ge bu seam'i
# çağırır ve karakter kaydına doğrudan uzanmaz.

## Bir kişinin bir ALANDAKİ saatlik etkin çıktısı. Liderlik BURADA YOK: §4.2 onu ALANIN
## TOPLAMINA uyguluyor — kişi başına katlansaydı kadro sayısıyla çarpılırdı.
static func effective_skill(c: Character, area_key: String) -> float:
	# İzindeki ya da eğitimdeki çalışanın günlük katkısı SIFIRDIR (§4.5, §8.6).
	if c == null or c.status != HRConstants.STATUS_ACTIVE:
		return 0.0
	var points: float = float(int(c.role_stats.get(area_key, 0)))
	if points <= 0.0:
		return 0.0
	if c.category != "founder" and not HRConstants.can_hold_area(c.role, area_key, c.category):
		return 0.0
	# §4.3 alan katsayısı: ana 1,0 · ikincil 0,8.
	var area_coef: float = HRConstants.area_fatigue_mult(c.role, area_key)
	# §12.1 odak katsayısı: tek iş 1,00 · iki iş 0,50, her iki işe AYRI AYRI.
	var focus: float = HRConstants.focus_mult(job_count(c))
	# §7 moral bandı. §2: KURUCUYA UYGULANMAZ — morali yoktur.
	var morale_band: float = HRConstants.morale_band_mult(c.morale) if c.category == "employee" else 1.0
	# §6 huy çarpanları. TİTİZ hız cezası öder, GÖZÜ YÜKSEKTE verimi yüksektir.
	var traits: float = HRConstants.trait_mult(c.traits, "speed_mult") \
		* HRConstants.trait_mult(c.traits, "output_mult")
	return points * area_coef * focus * morale_band * traits


## §4.2 liderlik bonusu — ALANIN TOPLAMINA, yarım yıldız başına +%1 (beş yıldızda +%10).
static func leadership_output_mult(lead_leadership: int) -> float:
	return 1.0 + HRConstants.LEAD_OUTPUT_PER_POINT * float(clampi(lead_leadership, 0, HRConstants.AREA_MAX))


## §4.5'in ikinci yarısı: "günlük katkı = etkin çıktı × kişinin o günkü çalışma saati".
## Saat formülün DIŞINDADIR: yetenek, alan, odak ve moral kişinin bir SAATTE ne çıkardığını,
## çalışma süresi KAÇ SAAT çıkardığını belirler.
##
## Çarpan standart güne göre normalize (HRConstants.hours_output_mult): sekiz saat 1,0.
## Ham saatle çarpmak Ürün, Satış ve CS'nin bütün kalibre sabitlerini sekizle çarpardı.
static func daily_contribution(c: Character, area_key: String) -> float:
	return effective_skill(c, area_key) * HRConstants.hours_output_mult(WorkHoursSystem.hours_for(c))


## O ALANA atanmış herkesin, o alandaki puanlarının ÇARPANLI toplamı — rol değil ATAMA sayar.
static func area_sum_for(area_id: String) -> float:
	var total: float = 0.0
	for c in assigned_to(area_id):
		total += float(int(c.role_stats.get(area_id, 0))) * output_mult_for_area(c, area_id)
	return total


# --- Run reset (called from GameState.initialize_run, after the flags clear) ---

static func reset() -> void:
	# HRSearchSystem holds no statics: its whole state lives on GameState.hr_search, which
	# initialize_run clears and the save carries.
	HRMoraleSystem.reset_rng()


# --- Save routing (SaveManager): the one door the codec knocks on; each sub-system owns
#     its own payload. ---

static func to_dict() -> Dictionary:
	return {"morale": HRMoraleSystem.to_dict()}


static func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	HRMoraleSystem.from_dict(d.get("morale", {}) as Dictionary)


# --- Read surface for the HR tab and the left-rail badge ---

## Rozetler TÜRETİLİR, saklanmaz (§15.1): bir çalışan aynı anda iki rozet taşıyabilir.
static func badges_for(emp: Character) -> Array[String]:
	return HRMoraleSystem.badges_for(emp)


static func attention_count() -> int:
	# The left-rail HR badge: people who need looking at, plus a waiting candidate file.
	var n: int = 0
	for emp in CharacterRegistry.get_employees():
		if not HRMoraleSystem.badges_for(emp).is_empty():
			n += 1
	if HRSearchSystem.has_files_ready():
		n += 1
	# Frank's hire nudge: the seed is in the bank and the founder is still alone. A signpost,
	# not a demand — it clears itself the moment anyone is hired.
	if int(GameState.get_flag(AngelRoundSystem.FLAG_ACCEPTED_DAY, 0)) > 0 \
			and CharacterRegistry.get_employees().is_empty():
		n += 1
	return n


## "İzinde · 4 gün kaldı" for the ledger's on-leave chip. Empty for anyone at work, so the
## caller can render it unconditionally.
static func leave_line(emp: Character) -> String:
	if emp == null or emp.status != HRConstants.STATUS_ON_LEAVE:
		return ""
	return TranslationServer.translate("HR_STATE_ON_LEAVE_DAYS").format({"n": HRMoraleSystem.days_until_return(emp)})
