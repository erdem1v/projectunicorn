class_name HRSystem
extends RefCounted

# Pure-logic system per TECH_SPEC §8.3 — no scene dependency, no instance.
# Driven by TimeManager.daily_tick slot 3 (TECH_SPEC §8.2 ordered dispatch).
#
# HR Core: this file is the DAILY ORCHESTRATOR only. It owns the order the HR
# sub-systems run in and nothing else; every rule lives in the system that owns it.
#   HRSearchSystem     — Atlas arayışı, aday dosyaları, işe alım
#   HRMoraleSystem     — moral, izin, eşikler, istifa, pozitif event'ler
#   HRActions          — zam / tatil / işten çıkarma (oyuncu tetikler, tick'te değil)
#   HRConstants        — her HR sayısının TEK evi
#
# THE AUTONOMOUS MORALE DRIFT IS GONE — deleted, not tuned to zero. It used to pull every
# employee ±1/day toward 50 from here. The design says morale moves only from played
# causes: ek mesai, aşırı yük, event'ler, oyuncu aksiyonları, izin dönüşü (§7).
# Dead machinery invites a future reader to switch it back on, so there is nothing left to
# switch on. That is also why this task ships the RECOVERY channel (HRMoraleSystem's
# placeholder positive events) and not only the costs — morale never self-heals, so a
# one-directional loop would be a broken demo, not a hard one.
#
# Salary→Finance link: HRSystem does NOT push payroll to Finance. FinanceSystem pulls
# CharacterRegistry.get_total_monthly_salaries() AND WorkHoursSystem.overtime_pay_accrued_today()
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
	#  AŞIRI YÜKLENME sayacı moralden ÖNCE: tick_thresholds ve trait etkileri o günün
	#  yükünü okur, sayaç sonra artarsa bir gün geriden gelir (deneyim/eğitim sırasında
	#  ölçülen aynı tuzak).
	HRSearchSystem.daily_tick()
	#  §7 TABAN SÜRÜKLENME eşiklerden ÖNCE: bugünün saat ayarı ve aşırı yükü bu tikte
	#  hedefe yazılır, sonra ease onu morale taşır, sonra eşikler O MORALİ okur. Ters sıra
	#  Ayrılabilir'i bir gün geriden getirirdi.
	HRMoraleSystem.tick_drift()
	HRMoraleSystem.tick_ease()
	HRMoraleSystem.tick_thresholds()
	#  7. DENEYİM: bugün gerçekten ÇALIŞMIŞ olanlar biriktirir. Eğitimdekiler
	#     STATUS_TRAINING taşıdığı için get_active_employees zaten dışarıda bırakır.
	#  8. EĞİTİM en sonda. SIRA ÖNEMLİ ve tersi ÖLÇÜLDÜ: eğitim önce koşarsa
	#     bitiş günü deneyimi sıfırlar, sonra tick_experience aynı gün içinde bir
	#     puan geri verir ve "biterken sıfırlanır" sözleşmesi sessizce yalan olur
	#     (hr_training_completion tam olarak bunu yakaladı).
	tick_experience()
	tick_training()

	if OS.is_debug_build():
		print("[HRSystem] Daily tick — %d employees (%d izinde)" % [
			CharacterRegistry.count_employees(), CharacterRegistry.count_on_leave(),
		])

	# LAST LINE, and it has to be: EventBus.day_advanced fires inside GameState.advance_day(),
	# which TimeManager calls BEFORE dispatching the daily ticks — so a screen that repaints on
	# day_advanced reads HR state from BEFORE the seven steps above ran (search strip a day
	# behind, arriving files invisible until tomorrow). This is the same trap
	# build_progress_changed was added to fix for the build tracker. The HR tab listens here.
	EventBus.hr_day_processed.emit()


# --- DENEYİM / EĞİTİM (Terminal UI görevi, 2026-08-08) ---
# Onaylı defterin [PROPOSAL] DENEYİM sütunu. Tüm sayılar HRConstants'ta ve WORKING.

## Günlük deneyim birikimi — §5.1 "learn-by-doing: ATANDIĞI ALANIN deneyimi yavaş
## yükselir". YALNIZ gerçekten çalışanlar: izindeki ya da eğitimdeki biri edilgendir ve
## get_active_employees zaten ikisini de dışarıda bırakır. Kurucu bu listede hiç yok.
##
## BOŞTAKİ KİŞİ ÖĞRENMEZ. Bu, "atanmamış kişi boşta durur ve maaş yer" cümlesinin
## (§4) ikinci yarısıdır: boşta durmak yalnız bugünü değil, yarını da kaybettirir.
##
## Birden fazla işi olan kişi deneyimi BÖLÜŞTÜRMEZ, her işin alanına ayrı ayrı yazar —
## ama aşırı yük çarpanıyla. §5'in "verimi düşer" cümlesi öğrenmeye de uygulanır, yoksa
## iki işe koşmak öğrenme sömürüsü olurdu.
static func tick_experience() -> void:
	# §5.1: "Çalışan projelerde aktif rol aldıkça deneyim kazanır." TEK BAR — alan başına
	# değil. Boştaki kişi öğrenmez: §12.2'nin "Boşta çalışan maaş yemeye devam eder"
	# cümlesinin ikinci yarısı, boşta durmanın yalnız bugünü değil yarını da kaybettirmesi.
	#
	# AŞIRI YÜK ÖĞRENMEYİ YAVAŞLATMAZ. Eski kod §5'in "verimi düşer"ini öğrenmeye de
	# uyguluyordu; rev 11'de odak katsayısı ÇIKTI hakkındadır (§12.1) ve iki işteki kişi
	# aynı saatleri çalışır. Aynı sürede aynı deneyim.
	var base: int = HRConstants.EXPERIENCE_PER_WORKED_DAY
	if _build_phase_running():
		base += HRConstants.EXPERIENCE_BUILD_BONUS
	# KURUCU DA ÖĞRENİR: Kişisel kartı bir DENEYİM çubuğu çiziyor ve §2.5 onu sabitliyor.
	var learners: Array[Character] = CharacterRegistry.get_active_employees()
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null and founder.status == HRConstants.STATUS_ACTIVE:
		learners.append(founder)
	for emp in learners:
		if emp.assigned_job_ids.is_empty():
			continue
		# ÇABUK KAPAR: kişinin KENDİ öğrenme hızı (§6).
		var own_mult: float = HRConstants.trait_mult(emp.traits, "experience_mult")
		# GERÇEK LİDER: ekip lideri taşıyorsa altındakiler daha hızlı öğrenir (§6). Lider
		# ataması §4.2'ye göre YAPIM BAŞINA yapılır ve Ürün modülünün konusudur; burada
		# kurucu iklim lideri olarak okunuyor, çünkü lidersiz alanların moral ve öğrenme
		# iklimi kurucudan gelir (§4.2).
		var lead_mult: float = HRConstants.experience_gain_mult(
			GameState.get_founder_skill(HRConstants.SKILL_LEADERSHIP))
		var gain: int = int(round(float(base) * own_mult * lead_mult))
		CharacterRegistry.add_experience(emp.id, maxi(gain, 1))

# ============================================================================
#  §15.3 · OKUMA YÜZEYİ — olay motoruna açılan katalog
# ============================================================================
# Diğer modüller ve olay motoru Ekip verisine DOĞRUDAN UZANARAK değil, bu adlandırılmış
# katalog üzerinden erişir. Katalog Ekip'in sorumluluğudur ve bu inşayla birlikte açılır —
# olay motorunu BEKLEMEZ (§17.3).
#
# Bugün çoğunun tüketicisi yok ve bu kasıtlı: motor geldiğinde işi bunları OKUMAK olacak,
# KEŞFETMEK değil. Seçiciler ("en düşük moralli çalışan", "en yeni işe alınan", "şu alanın
# lideri") bu sorguların ÜZERİNE motorun kendi tarafında kurulur — burada değil.
#
# Adlar KARARLIDIR. İç yapı değişse bile korunurlar; §15.3 bunu bir sözleşme olarak yazıyor.

static func morale(c: Character) -> int:
	return 0 if c == null else c.morale


static func morale_band(c: Character) -> String:
	## Bant KİMLİĞİ döner, sayı değil — §4.2 ve §8.5'in "oyuncu sebebi görür, katsayıyı
	## görmez" kuralının okuma tarafındaki karşılığı.
	if c == null:
		return "mid"
	return HRConstants.morale_band_id(c.morale)


static func headcount() -> int:
	return CharacterRegistry.count_employees()


static func skill(c: Character, area_key: String) -> int:
	## HAM 0–10. Ekranda beş yıldıza çevrilir (§4.1); ham puan doğrulama içindir,
	## karar yüzeyi değildir.
	return 0 if c == null else int(c.role_stats.get(area_key, 0))


static func status(c: Character) -> String:
	return "" if c == null else c.status


static func is_busy(c: Character) -> bool:
	## §2.2'nin cevabı. MEŞGULİYET TEK MODEL: izindeyken · eğitimdeyken · (kurucu)
	## yatırım hazırlığındayken. Ara kademe, yarı hız çarpanı, kısmi kapasite YOKTUR.
	if c == null:
		return false
	if c.status == HRConstants.STATUS_ON_LEAVE or c.status == HRConstants.STATUS_TRAINING:
		return true
	if c.category == "founder" and bool(GameState.get_flag("pitch_prep_active", false)):
		return true
	# Satış rev 6 §5.0 — kurucu bir SATIŞ TOPLANTISINDA. Sekizinci bir görev durumu DEĞİL
	# (§2.3 kapalı bir tablodur ve bu bayrak orada görünmez): toplantı atomiktir, içinde
	# dünya dönmez, ve kapanışta atlanan iki saat "kurucu katkısı sıfır" sayılarak simüle
	# edilir. Bu satır o sıfırın kendisidir — `pitch_prep_active`in birebir kardeşi.
	# ÜÇ KAPI DEĞİL İKİ: yapım yolu ProductSystem._is_free okuyor, araştırma burayı. İkisine
	# de eklenmezse kurucu inşa etmeye devam ederken araştırmadan donar.
	if c.category == "founder" and bool(GameState.get_flag("sales_meeting_active", false)):
		return true
	return false


static func tenure_days(c: Character) -> int:
	if c == null or c.hire_day <= 0:
		return 0
	return maxi(GameState.day - c.hire_day, 0)


static func accounts_of(c: Character) -> Array:
	## KİŞİ → HESAPLAR ters indeksi. Satış tarafında yalnız Customer.assigned_to vardı, yani
	## "bu kişi neye bakıyor" sorusunun cevabı müşteri kaydını yürümekten geçiyordu — ve
	## §11.3'ün ayrılma sorusu ("müşterilerine kim bakacak?") tam olarak bunu soruyor.
	if c == null:
		return []
	var out: Array = []
	for cu in CustomerRegistry.get_all():
		if cu != null and String(cu.assigned_to) == c.id:
			out.append(cu)
	return out


static func work_hours(c: Character) -> int:
	## §8.1 devralma zinciri. Hiçbir sistem zinciri kendisi yürütmez (§15.2).
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
## Yedi durumun hepsi bugün var olan state'ten okunur; hiçbir modülden yazma beklenmez.
const FOUNDER_STATE_BUILD := "build"
const FOUNDER_STATE_SALES := "sales"
const FOUNDER_STATE_SUPPORT := "support"
const FOUNDER_STATE_RESEARCH := "research"
const FOUNDER_STATE_PITCH_PREP := "pitch_prep"
const FOUNDER_STATE_TRAINING := "training"
const FOUNDER_STATE_IDLE := "idle"


## §2.3'ün cümlesi. Durum id'si MOTORUN, cümle EKRANIN — ve §16 gereği ikisi de tek evde
## durur, yoksa Kişisel sayfası kendi eşlemesini yazar ve id'ler değiştiğinde sessizce
## eskir. ARAŞTIRMADA ARTIK ERİŞİLİRDİR: bu satır uzun süre "Ar-Ge modülü gelene kadar
## yazılmayacak" diyordu ve modül geldi. Araştırma hâlâ Görevler matrisinden atanmıyor
## (Ar-Ge §5.3: atama Ar-Ge panelindedir) — ama artık gerçek bir iş, gerçek bir işaret
## bırakıyor ve kurucu onu tutabiliyor.
## Kişisel sayfasının tek satırı (Ekip §2.5). Normalde §2.3'ün YEDİ durumundan biri.
##
## İKİ SÜREKLİ İŞ İÇİN SEKİZİNCİ BİR DURUM İCAT EDİLMEZ. §2.3 kapalı bir tablodur ve
## "durumların tamamı aşağıdadır / hiçbir kurucu durumu id'siz kalmaz" der. Ama §12.2 aynı
## durumu ÇALIŞAN tarafı için zaten hükme bağlamış: "İki iş | İki cümle yerine iki kısa
## etiket, orta nokta ayracıyla — Pulse v1 · Destek", gerekçesi de satırın taşması. Kurucunun
## satırı o grameri ödünç alır: iki AYRI id'nin kısa etiketi, `·` ile. Böylece iki durum da
## id'li kalır ve yeni bir vokabüler doğmaz.
##
## MEŞGUL DURUMLAR YİNE ÖNCE GELİR: eğitim ve yatırım hazırlığı §2.3'te MEŞGUL'dür ve bir
## atamanın üstünü örterler, yani onlar varken kompozisyon yapılmaz.
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
	# ARAŞTIRMA YAPIMDAN ÖNCE OKUNUR (Ar-Ge §5.0). Dışlayıcı bir iş: araştıran kurucu
	# BAŞKA HİÇBİR ŞEY yapmıyor, yani duraklamış yapımının adını taşımak yalan olurdu.
	# Sıra kuralı bu fonksiyonun kendi kuralıdır — meşgul durumlar önce.
	if f.assigned_job_ids.has(HRConstants.JOB_RESEARCH):
		return FOUNDER_STATE_RESEARCH
	if f.assigned_job_ids.has(HRConstants.JOB_BUILD):
		return FOUNDER_STATE_BUILD
	# Satış bir İŞ değil (2026-08-25); ticari sürekli iş yalnız hesap sahipliğidir. Kurucunun
	# pitch'i bir toplantıdır ve yukarıdaki pitch_prep dalından okunur.
	if f.assigned_job_ids.has(HRConstants.JOB_ACCOUNTS):
		return FOUNDER_STATE_SALES
	if f.assigned_job_ids.has(HRConstants.JOB_SUPPORT) or f.assigned_job_ids.has(HRConstants.JOB_TEST):
		return FOUNDER_STATE_SUPPORT
	return FOUNDER_STATE_IDLE

# ======================= Görev ataması: okuma seam'leri ======================
# §12. CharacterRegistry TEK YAZARDIR; burası okuma tarafı ve dışarıya açılan yüz.
# Ürün, Satış ve Operasyon "kim meşgul" sorusunu buradan sorar.

static func assigned_to(area_id: String) -> Array[Character]:
	## O ALANA atanmış, BUGÜN ÇALIŞABİLİR herkes. İzindeki ve eğitimdeki dışarıda: ataması
	## durur (dönünce işine döner) ama bugünkü hiçbir formüle girmez.
	var out: Array[Character] = []
	for c in CharacterRegistry.get_all():
		if c == null or c.status != HRConstants.STATUS_ACTIVE:
			continue
		if c.category != "employee" and c.category != "founder":
			continue
		if c.assigned_jobs.has(area_id):
			out.append(c)
	return out


static func is_idle(c: Character) -> bool:
	## §12.2 "Boşta" — hiçbir İŞE atanmamış. Çalışan durur ve maaş yemeye devam eder;
	## kurucu maaş almadığı için boştalığı bir gider değil kaybedilmiş zamandır.
	## Boşta ayrı bir rozet değildir, GÖREV sütununun kendi metnidir (§12.2).
	return c != null and c.category == "employee" and c.assigned_job_ids.is_empty()


## §15.3 hr.job_count(kişi) → 0, 1 ya da 2.
static func job_count(c: Character) -> int:
	return 0 if c == null else c.assigned_job_ids.size()


static func is_overloaded(c: Character) -> bool:
	## §12.1 AŞIRI YÜK = atanmış İŞ sayısı 2. Alandan sayılamaz: Build + Destek taşıyan bir
	## developer İKİ iş tutar ama tek alana (Yazılım) yansır, çünkü iki işi de o alan taşıyor.
	## Alanı saymak onu aşırı yüklü SAYMAZDI ve §12.1'in bedeli hiç uygulanmazdı.
	return c != null and c.assigned_job_ids.size() > 1


static func idle_count() -> int:
	## İŞ SAYAR, ALAN DEĞİL — is_idle() ile aynı alanı okur (§12.2 "hiçbir İŞE atanmamış").
	## KUSUR GERÇEKTİ: burası türetilmiş ALAN aynasını (`assigned_jobs`) okuyordu ve o ayna
	## araştırmayı bilerek dışarıda bırakıyor (HRConstants.areas_for_jobs'un `continue`'u,
	## Ar-Ge §5.0). Yani araştıran bir çalışan — modülün en meşgul insanı — bu sayaçta
	## BOŞTA görünürdü. İki fonksiyonun aynı soruya iki cevap vermesi §15.2'nin yasağı.
	var n: int = 0
	for c in CharacterRegistry.get_active_employees():
		if c.assigned_job_ids.is_empty():
			n += 1
	return n


# ---------------------- §12.0 İŞ TARAFI OKUMA SEAM'LERİ ----------------------
# Yukarıdaki assigned_to(alan) DURUYOR ve türetilmiş alan aynası üzerinden çalışıyor;
# tüketiciler tek tek buraya çevrilir ve son çevrilen Faz 7'de o seam'i öldürür.

static func assigned_to_job(job_id: String) -> Array[Character]:
	## O İŞE atanmış, BUGÜN ÇALIŞABİLİR herkes. İzindeki ve eğitimdeki dışarıda: ataması
	## durur (§12.3 — hiçbir sistem silemez) ama bugünkü hiçbir formüle girmez (§8.6).
	var out: Array[Character] = []
	for c in CharacterRegistry.get_all():
		if c == null or c.status != HRConstants.STATUS_ACTIVE:
			continue
		if c.category != "employee" and c.category != "founder":
			continue
		if c.assigned_job_ids.has(job_id):
			out.append(c)
	return out


## §15.3 hr.unstaffed_jobs() — kimsenin atanmadığı işler.
## §12.2: bunun bir UYARI SATIRI olarak çizilmediğine dikkat — matris zaten boş sütunu
## gösteriyor, ve oyunun başında oyuncu her rolü alamayacağı için o uyarılar aynı anda
## birden fazla iş için çıkar ve gürültü üretir. Seam okunur, ekrana basılmaz.
static func unstaffed_jobs() -> Array[String]:
	var out: Array[String] = []
	for job_id in HRConstants.JOBS:
		if assigned_to_job(String(job_id)).is_empty():
			out.append(String(job_id))
	return out


## §4.2: LİDER YAPIM BAŞINADIR (Ürün modülünün seçtiği SORUMLU), ve lidersiz bir alan
## KURUCUNUN Liderlik'ini okur. ALAN BAŞINA OTURAN KOLTUK KALKTI: GameState.area_leads'in
## bir tane okuyucusu (burası) ve SIFIR üretim yazıcısı vardı — geri kalan her dokunuş bir
## silmeydi ya da kayıt göçünün yanlış yuvaya yazan bloğuydu. Kalan şey türetilmiş liderdir:
## o alandaki en yüksek Liderlik, kimse yoksa kurucu.
static func area_lead(area_id: String) -> Character:
	var best: Character = null
	var best_v: int = -1
	for c in assigned_to(area_id):
		var v: int = int(c.role_stats.get(HRConstants.SKILL_LEADERSHIP, 0))
		if v > best_v:
			best_v = v
			best = c
	if best != null:
		return best
	return CharacterRegistry.get_founder()


static func area_lead_leadership_for(c: Character) -> int:
	## Bu kişinin ÜSTÜNDEKİ liderin Liderlik'i — birden fazla alanı varsa en yüksek olanı,
	## çünkü §5 aşırı yükü zaten cezalandırıyor; ikinci bir ceza olarak en kötü lideri
	## seçmek aynı kararı iki kez faturalandırırdı.
	if c == null:
		return 0
	var best: int = 0
	for area_id in c.assigned_jobs:
		var lead: Character = area_lead(String(area_id))
		if lead == null or lead.id == c.id:
			continue
		best = maxi(best, int(lead.role_stats.get(HRConstants.SKILL_LEADERSHIP, 0)))
	return best


static func output_mult_for_area(c: Character, area_key: String) -> float:
	## Çıktı çarpanı, ÇALIŞILAN ALAN bilindiğinde. Bir iş birden fazla alanla beslenebilir
	## (Build'i Ürün · Tasarım · Yazılım besliyor) ve kişi o işin FAZINA göre farklı bir
	## alandan katkı verebilir — bir yazılımcı TASARIM fazına Tasarım'ından katılır. Yorgunluk
	## o zaman GERÇEKTEN çalışılan alandan ölçülmeli, işin genel alanından değil, yoksa
	## §5'in "ikincil alanında çalışmak daha yorucudur" cümlesi tam da ısırması gereken yerde
	## ısırmaz. (Ölçüldü: `speed_tracks_team_change` bunu yakaladı.)
	if c == null:
		return 0.0
	## §12.1 ODAK KATSAYISI, TOLERANS SAYACININ YERİNE. Buraya eskiden rev 2'nin
	## `overload_bites` dalı giriyordu: beş günlük bir lütuf penceresinden SONRA ×0,75.
	## §12.1 hem sayacı hem çarpanı kaldırdı ve yerine tek bir kural koydu — iki işteki
	## kişi HER İKİ İŞE de 0,50 verir, ilk günden. Bu bir zayıflatma değil bir DÜZELTMEDİR:
	## `effective_skill` odak katsayısını zaten uyguluyordu, yani bu yol iki işi ×0,75 ile
	## bir KEZ DAHA faturalandırıyor ve §12.1'in "en iyi durumda tam olarak bir kişilik iş
	## çıkar" cümlesini bozuyordu.
	return HRConstants.area_fatigue_mult(c.role, area_key) * HRConstants.focus_mult(job_count(c))


# ==================== §4.5 · ETKİN ÇIKTI — KANONİK FORMÜL ====================
# "Bir kişinin bir işteki etkin çıktısı TEK BİR YERDE tanımlıdır. Başka hiçbir modül kendi
# hız formülünü kurmaz; hepsi buna referans verir."
#
# Ürün, Satış, Destek ve Ar-Ge bu seam'i çağırır ve karakter kaydına DOĞRUDAN UZANMAZ.
# Bugüne kadar üç ayrı hesap vardı (ProductSystem._phase_area_sum ·
# SalesRepSystem._diminished_sum · CustomerRepSystem.throughput_of) ve ÜÇÜ DE moral bandını
# atlıyordu — §7'nin bantları yalnız istifa roll'una bakıyordu.

## Bir kişinin bir ALANDAKİ saatlik etkin çıktısı. Liderlik BURADA YOK: §4.2 onu ALANIN
## TOPLAMINA uyguluyor, kişi başına değil — kişi başına katlansaydı kadro sayısıyla çarpılırdı.
static func effective_skill(c: Character, area_key: String) -> float:
	if c == null:
		return 0.0
	# İzindeki ya da eğitimdeki çalışanın günlük katkısı SIFIRDIR (§4.5, §8.6).
	if c.status != HRConstants.STATUS_ACTIVE:
		return 0.0
	var points: float = float(int(c.role_stats.get(area_key, 0)))
	if points <= 0.0:
		return 0.0
	# §4.3 alan katsayısı: ana 1,0 · ikincil 0,8 · alanı yok 0.
	var area_coef: float = HRConstants.area_fatigue_mult(c.role, area_key)
	if c.category != "founder" and not HRConstants.can_hold_area(c.role, area_key, c.category):
		return 0.0
	# §12.1 odak katsayısı: tek iş 1,00 · iki iş 0,50, her iki işe AYRI AYRI.
	var focus: float = HRConstants.focus_mult(job_count(c))
	# §7 moral bandı. §2: KURUCUYA UYGULANMAZ — morali yoktur; diğer bütün çarpanlar
	# onda da aynen geçerlidir.
	var morale_band: float = 1.0
	if c.category == "employee":
		morale_band = HRConstants.morale_band_mult(c.morale)
	# §6 huy çarpanları. TİTİZ hız cezası öder, GÖZÜ YÜKSEKTE verimi yüksektir.
	var traits: float = HRConstants.trait_mult(c.traits, "speed_mult") \
		* HRConstants.trait_mult(c.traits, "output_mult")
	return points * area_coef * focus * morale_band * traits


## §4.2 liderlik bonusu — ALANIN TOPLAMINA, yarım yıldız başına +%1 (beş yıldızda +%10).
## Lider yoksa kurucunun Liderliği okunur: "Lideri olmayan alanların moral iklimi kurucunun
## Liderliğinden okunur" (§4.2) ve çıktı tarafı da aynı kaynağı izler.
static func leadership_output_mult(lead_leadership: int) -> float:
	return 1.0 + HRConstants.LEAD_OUTPUT_PER_POINT * float(clampi(lead_leadership, 0, HRConstants.AREA_MAX))


## Bir ALANIN toplam etkin çıktısı — §4.5 × §4.2. Bu, "kaç kişilik iş çıkıyor" sorusunun
## tek cevabı; her masa kendi toplamını burada alır.
static func area_output(area_key: String, people: Array = []) -> float:
	var roster: Array = people
	if roster.is_empty():
		roster = CharacterRegistry.get_all()
	var total: float = 0.0
	for c in roster:
		if c == null or (c.category != "employee" and c.category != "founder"):
			continue
		total += effective_skill(c, area_key)
	if total <= 0.0:
		return 0.0
	return total * leadership_output_mult(GameState.get_founder_skill(HRConstants.SKILL_LEADERSHIP))


## §4.5'in ikinci yarısı: "günlük katkı = etkin çıktı × kişinin o günkü çalışma saati".
## Çalışma saati formülün İÇİNDE değil DIŞINDADIR ve bu ayrım kasıtlı: yetenek, alan, odak,
## moral ve liderlik kişinin bir SAATTE ne kadar iş çıkardığını belirler; çalışma süresi
## KAÇ SAAT çıkardığını. İki soru karıştırılmaz.
##
## ÇARPAN STANDART GÜNE GÖRE NORMALİZE (HRConstants.hours_output_mult): sekiz saat 1,0'dır.
## Ham saatle çarpmak Ürün, Satış ve CS'nin bütün kalibre sabitlerini sekizle çarpardı ve
## bunun bir tasarım gerekçesi yok. §8.1 ile §8.3 oranı zaten kendileri veriyor — 11 saat
## +%37,5, 5 saat %62,5 — ve normalize hâl tam o iki sayıdır.
##
## ÜÇ MASANIN DA OKUDUĞU ŞEY BUDUR (Faz 7). Öncesinde bu fonksiyonun HİÇBİR tüketicisi
## yoktu: hepsi effective_skill okuyordu, yani saat kadranı para ve moral harcıyor ama
## çıktıya dokunmuyordu. §8.4'ün "getiri saatin kendisidir" cümlesi motorda karşılıksızdı.
static func daily_contribution(c: Character, area_key: String) -> float:
	if c == null or c.status != HRConstants.STATUS_ACTIVE:
		return 0.0
	return effective_skill(c, area_key) \
		* HRConstants.hours_output_mult(WorkHoursSystem.hours_for(c))

static func area_sum_for(area_id: String) -> float:
	## O ALANA atanmış herkesin, o alandaki puanlarının ÇARPANLI toplamı. Ürün ve Satış
	## formüllerinin ortak girdisi — rol değil ATAMA sayar.
	##
	## `output_mult_for(c, job)` emekli oldu: atama artık alanın kendisi olduğu için "bu işi
	## hangi alandan yapıyor" diye bir arama kalmadı, output_mult_for_area doğrudan doğru
	## cevabı veriyor.
	var total: float = 0.0
	for c in assigned_to(area_id):
		total += float(int(c.role_stats.get(area_id, 0))) * output_mult_for_area(c, area_id)
	return total


## Eğitim günlerini işler; biten her eğitim bir haber satırı bırakır.
static func tick_training() -> void:
	# KURUCU DAHİL (2026-08-22). get_employees() kurucuyu içermiyor; kurucu eğitime
	# gidebildiği andan itibaren bu döngünün dışında kalmak, onu STATUS_TRAINING'de
	# SONSUZA DEK askıda bırakıyordu — geri dönmeyen, hiçbir alanda çalışmayan bir kurucu.
	# (founder_trains_and_learns bunu yakaladı.)
	var in_training: Array[Character] = CharacterRegistry.get_employees()
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null:
		in_training.append(founder)
	for emp in in_training:
		if emp.training_days_left <= 0:
			continue
		if CharacterRegistry.tick_training(emp.id):
			# Mevcut haber grameri: "biz" kaynağı EventBus.headline_added'a yazar,
			# NewsFeedSystem kotayı kendi yürütür (HRMoraleSystem'in izin satırlarıyla
			# aynı yol).
			# TranslationServer, tr() DEĞİL: statik fonksiyonun çeviri yapacağı bir
			# Object'i yok (UiTokens.net_runway_parts ile aynı sebep).
			EventBus.headline_added.emit(HRConstants.notice_source_hr(),
				TranslationServer.translate("HR_NEWS_TRAINING_DONE").format({
					"name": emp.character_name,
				}))


## Oyuncunun kararı: birini eğitime gönder, HANGİ ALANDA olduğunu söyleyerek (§5.2:
## "Oyuncu hangi alanın yükseleceğini seçer"). Ücreti HR gider hattından TAHSİL EDER ve
## ancak ödeme geçtiyse eğitimi başlatır — §10: bedeli olan, oynanmış bir karar.
## Ücret kademelidir ve aynı alandaki tekrarda artar (HRConstants.training_fee), yani
## "azalan getiri" fiyat tarafından ödenir: kazanç hep +1, pahalılaşan aynı +1'dir.
## `false` döner uygun değilse ya da kasa yetmiyorsa (çağıran düğmeyi kapatır).
static func send_to_training(id: String, area_key: String) -> bool:
	if not CharacterRegistry.can_train(id, area_key):
		return false
	var fee: int = CharacterRegistry.training_fee_for(id, area_key)
	# §5.4: "PARANIN YETMEMESİ BİR KİLİT DEĞİLDİR; bir bedeldir ve modalde okunur." Kasa
	# eksiye düşebilir — işe alım komisyonu ve kıdem tazminatıyla aynı kanal, aynı olağan
	# iflas yolu. Eski kapı sessizce reddediyordu: buton basılıyor, para yetmiyor, hiçbir
	# şey olmuyor ve oyuncuya sebep söylenmiyordu.
	# Tek seferlik gider, HR gider hattına — işe alım retainer'ıyla aynı sızdırmazlık.
	FinanceSystem.apply_one_time_cost(fee, "training")
	CharacterRegistry.begin_training(id, area_key)
	return true


## Bir geliştirme fazı KOŞUYOR mu? ProductSystem'in kendi faz listesiyle aynı üçlü
## (iteration/development/bugfix) — kopya bir liste tutmamak için tek yerden okunur.
static func _build_phase_running() -> bool:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null:
		return false
	return b.current_phase in ["iteration", "development", "bugfix"]


# --- Run reset (called from GameState.initialize_run, after the flags clear) ---

static func reset() -> void:
	# Static state in the HR sub-systems must not survive into a fresh run (the smoke
	# harness runs one case per process, but the debug onboarding re-trigger does not — and
	# neither does a load).
	# Verified complete against the two sub-systems' statics:
	#   HRMoraleSystem  — the RNG cursor (now RngStreams' concern) + _pending. Both cleared.
	#   (Ek mesai blok sistemi §8.2 ile kalktı; sıfırlanacak statiği kalmadı.)
	# HRSearchSystem holds NO statics: its whole state machine lives on GameState.hr_search,
	# which initialize_run clears and the save carries.
	HRMoraleSystem.reset_rng()


# --- Save routing (SaveManager). This file is the HR orchestrator, so it is also the one
#     door the codec knocks on; each sub-system still owns its own payload. ---

static func to_dict() -> Dictionary:
	# HROvertimeSystem's three statics are deliberately NOT here. _pay_today /
	# _pay_stamped_day are a SINGLE DAY's stamp, self-verifying against GameState.day
	# (pay_accrued_today returns 0 when the stamp is not today's), so a restored run simply
	# reads 0 until the next daily tick re-stamps — which is the same answer the stamp would
	# have given. _pay_carry only holds value between a same-day stop and the next tick, a
	# window no save can land in. The overtime BLOCKS themselves live on GameState.hr_overtime.
	return {"morale": HRMoraleSystem.to_dict()}


static func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	HRMoraleSystem.from_dict(d.get("morale", {}) as Dictionary)


# --- Read surface for the HR tab (task 3) and the left-rail badge ---

static func badges_for(emp: Character) -> Array[String]:
	# Rozetler TÜRETİLİR, saklanmaz (§15.1): bir çalışan aynı anda iki rozet taşıyabilir ve
	# tek bir String alan ikisini tutamaz. Vokabüler HRConstants.BADGE_*'da tek evde durur.
	return HRMoraleSystem.badges_for(emp)


static func attention_count() -> int:
	# What the left-rail HR badge counts: people who need looking at, plus a waiting
	# candidate file. Kept here so the UI reads one number from one place.
	var n: int = attention_people_count()
	if HRSearchSystem.has_files_ready():
		n += 1
	# Frank's hire nudge (Playable Run Sprint): the seed is in the bank and the founder is
	# still alone. A SIGNPOST, not a demand — it clears itself the moment anyone is hired,
	# and nothing anywhere reads it as a requirement. Counted here rather than in the rail
	# so the badge keeps reading one number from one place.
	if int(GameState.get_flag(AngelRoundSystem.FLAG_ACCEPTED_DAY, 0)) > 0 \
			and CharacterRegistry.get_employees().is_empty():
		n += 1
	return n


static func attention_people_count() -> int:
	# PEOPLE only — the Ekip header's "N dikkat gerektiriyor". Deliberately not the same number
	# as attention_count() above: the rail badge also counts a waiting candidate file, but on
	# the Ekip page those files have their own strip, so counting them again in a sentence about
	# the team would be a lie. Splitting it here rather than subtracting in the UI keeps the
	# rail's verified behaviour untouched.
	var n: int = 0
	for emp in CharacterRegistry.get_employees():
		if not HRMoraleSystem.badges_for(emp).is_empty():
			n += 1
	return n


static func leave_line(emp: Character) -> String:
	# "İzinde · 4 gün kaldı" for the ledger's on-leave chip. Empty for anyone at work, so the
	# caller can render it unconditionally and get nothing when there is nothing to say.
	# (It was written for the Kare 7 card and went unowned when that card was retired; the
	# training chip beside it counts down, so the leave chip counting down too is the point.)
	# WORKING TR.
	if emp == null or emp.status != HRConstants.STATUS_ON_LEAVE:
		return ""
	return TranslationServer.translate("HR_STATE_ON_LEAVE_DAYS").format({"n": HRMoraleSystem.days_until_return(emp)})
