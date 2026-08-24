class_name HRMoraleSystem
extends RefCounted

# The morale machine (§7), yıllık izin (§11.4) and the departure paths (§11.3).
# Ticked DAILY from HRSystem.daily_tick (slot 3), in the order that file fixes and for the
# reasons it gives:
#   1. tick_leave_returns    — status flips back FIRST, so everything below reads the
#                              restored `active` (capacity, ek mesai, badges).
#   2. tick_leave_departures — next, so today's capacity already excludes whoever left.
#   5. tick_thresholds       — son adım, so a person pushed under KAÇMA RİSKİ
#                              by tonight's mesai starts their count today, not tomorrow.
#   6. tick_trait_effects    — periodic (not daily), reads the settled morale picture.
#
# Owns: every movement of Character.morale (the only writer in the game besides the event
# modifiers), Character.status / leave_until_day / leave_taken_year / flight_risk_days, the
# flight-risk counter and its resignation roll, the pending-departure latch, the
# same-department trait nudges, the positive-event trigger surface, and
#
# THERE IS NO DRIFT. The old ±1/day-toward-50 tick is DELETED, not tuned to zero: on a day
# with no event, no ek mesai, no aşırı yük and no player action, morale does not move by a
# single point. Morale moves only from played causes (§7). That is also why a
# negative delta which scales below half a point is DROPPED instead of rounded to -1
# (see scaled_delta) — a rounding rule is exactly how a deleted drift grows back.
#
# WRITE-THROUGH LAW: morale ONLY through CharacterRegistry.set_morale (never `emp.morale =`),
# which clamps and emits morale_changed; departures ONLY through CharacterRegistry.remove
# (which increments run_departures and emits character_removed); one-time money ONLY through
# FinanceSystem.apply_one_time_cost (this file charges nothing — a resignation has no
# severance); player-facing beats ONLY through EventManager.enqueue (the modal queue) and
# EventBus.headline_added (the non-interrupting ticker). The employment fields above have no
# registry seam and this system is their owner, so they are written here and nowhere else.
# Every HR tunable comes from HRConstants: there is no HR number in this file.


# --- Local, non-tunable constants (keys and sentinels, not knobs) ---

# SUPERSEDED by RngStreams.STREAM_HR_MORALE, which salts `run_seed ^ <name>.hash()` with
# exactly the same technique for exactly the reason recorded here. Kept as a named constant
# because HRConstants.resign_voice and the file's own header both cite it, and because it
# documents WHY the salt is a string hash rather than a magic number: String.hash() is
# stable for a given string. Nothing seeds from it any more — see _roll().
const RNG_SALT := "hr_morale_system"

# Per-record marker for "this leave was the MANUAL vacation, not the automatic annual one",
# because the two owe different return bonuses and the return lands up to LEAVE_DAYS later.
# Character has no field for it and the model is a shared file, so the marker lives in
# GameState.flags — the same per-record flag pattern B2BSalesSystem uses for
# "b2b_broke_<customer_id>", and it travels with GameState instead of dying with a static var.
const FLAG_MANUAL_LEAVE_PREFIX := "hr_manual_leave_"

# "Hiç olmadı" for the days_since_* reads. It has to be distinguishable from 0, because 0
# means TODAY and the ship/signing triggers compare against 0 exactly.
const NEVER := -1


# --- Static state ---
# THE GENERATOR MOVED, THE REASONING DID NOT. This file used to hold a private
# RandomNumberGenerator because SkillCheck ended in a bare randf() drawing from the one
# global seed that event triggers and EventManager's shuffle also consumed — so an HR roll
# could displace that stream and flip a long-horizon case with nothing to do with HR. That
# insight is now the whole design: RngStreams gives events, skill and hr_morale one named
# stream each, and this file draws from RngStreams.STREAM_HR_MORALE. The private _rng and
# its _seeded_for cursor are gone (RngStreams keeps that cursor for all three streams), and
# in exchange the HR sequence is now RESUMABLE from a save rather than only from birth.
# Pending-departure latch. A resignation event sits in the queue until the player acknowledges
# it; without this the roll would be re-attempted every day in between, and even though
# EventManager.enqueue dedupes the event, the wasted draws would push the effective odds
# silently above HRConstants.RESIGN_CHANCE_PER_DAY. Held HERE, not on the event: a synthetic
# event bypasses _is_eligible entirely, so `one_shot` does nothing (HREventFactory's header).
static var _pending: Array[String] = []


# ============================================================================
#  Daily steps, called in this order by HRSystem.daily_tick
# ============================================================================

static func tick_leave_returns() -> void:
	# Runs FIRST so the restored `active` status is what the rest of the day reads.
	for emp in CharacterRegistry.get_employees():
		if emp.category != "employee":
			continue   # Frank is filtered by get_employees; verified again, not assumed
		if emp.status != HRConstants.STATUS_ON_LEAVE:
			continue
		if GameState.day < emp.leave_until_day:
			continue
		var was_manual: bool = bool(GameState.get_flag(FLAG_MANUAL_LEAVE_PREFIX + emp.id, false))
		CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ACTIVE)
		emp.leave_until_day = 0
		GameState.set_flag(FLAG_MANUAL_LEAVE_PREFIX + emp.id, false)
		# İzin dönüşü moral getirir; manuel tatil dönüşü daha büyük (§11.4; manuel eylem emekli,
		# çeşme sabiti gelecek olay kanalı için duruyor).
		# The TÜKENİYOR badge clears by itself as soon as morale crosses back over
		# §7'nin bandları — nothing here touches badges, they are derived.
		if was_manual:
			apply_delta(emp, HRConstants.MORALE_VACATION_RETURN, HRConstants.REASON_VACATION_RETURN)
		else:
			apply_delta(emp, HRConstants.MORALE_LEAVE_RETURN, HRConstants.REASON_LEAVE_RETURN)
		var whence: String = TranslationServer.translate("HR_WHENCE_HOLIDAY") if was_manual else TranslationServer.translate("HR_WHENCE_LEAVE")
		EventBus.headline_added.emit(HRConstants.notice_source_hr(), TranslationServer.translate("HR_NEWS_BACK_FROM").format({"name": emp.character_name, "whence": whence}))


static func tick_leave_departures() -> void:
	# İzin HAFTASI geldiğinde çalışan OTOMATİK izne çıkar, oyuncu onayı istenmez (§11.4).
	# §11.4 YAZ PENCERESİ. İzinler Haziran–Ağustos arasına yerleşir ve her çalışana işe
	# alındığında pencere içinden bir HAFTA atanır; dağıtıcı adım art arda alınan iki kişinin
	# iznini yan yana haftalara düşürmez. Amaç bütün ekibin aynı hafta izinde olmasını
	# engellemek — eski ay tabanlı model bunu on iki aya yayıyordu ve yaz kısıtı yoktu.
	var date: Dictionary = GameState.get_date_dict()
	var month: int = int(date.month)
	var year: int = int(date.year)
	if month < HRConstants.LEAVE_WINDOW_START_MONTH or month > HRConstants.LEAVE_WINDOW_END_MONTH:
		return
	# Pencerenin başından bu yana geçen hafta — 0..12.
	var window_start_day: int = _summer_window_start_day(year)
	var week_index: int = int(floor(float(GameState.day - window_start_day) / 7.0))
	for emp in CharacterRegistry.get_employees():
		if emp.category != "employee":
			continue
		if emp.status != HRConstants.STATUS_ACTIVE:
			continue
		if emp.leave_week < 0 or emp.leave_week != week_index:
			continue
		if emp.leave_taken_year == year:
			# Already had this year's leave. This guard is ALSO what makes the
			# returns-before-departures order safe on its own: whoever returned earlier in
			# this same tick is already stamped for the current year, so they cannot be
			# re-sent today no matter which step runs first.
			continue
		# §15.3: TALEP bu modülden doğar, KART olay motorunun (§17.3). Motor gelene kadar
		# izin otomatik başlar (R2) ama sinyal bugünden yayınlanır ki motor ona bağlansın.
		EventBus.leave_requested.emit(emp.id)
		send_on_leave(emp, HRConstants.LEAVE_DAYS, false)



## Yaz penceresinin (1 Haziran) o yıldaki RUN GÜNÜ. GameState.day → takvim dönüşümü tek
## evdedir (get_date_dict), o yüzden geriye doğru arama yerine ileri doğru bir tarama:
## pencere on üç haftalık ve yılda bir kez çalıştığı için maliyet önemsiz.
static func _summer_window_start_day(year: int) -> int:
	var probe: int = GameState.day
	while probe > 1:
		var d: Dictionary = GameState.get_date_dict(probe - 1)
		if int(d.year) != year or int(d.month) < HRConstants.LEAVE_WINDOW_START_MONTH:
			break
		probe -= 1
	return probe


static func tick_thresholds() -> void:
	# KAÇMA RİSKİ counter, then the resignation roll. Runs last so tonight's
	# mesai is already in the morale number this reads.
	for emp in CharacterRegistry.get_employees():
		if emp.category != "employee":
			continue
		if emp.status == HRConstants.STATUS_ON_LEAVE:
			# WORKING: the counter FREEZES while someone is away (it is not reset, so neglect
			# is not laundered by a holiday) and no roll is taken. Otherwise the player's own
			# recovery action could be answered with a resignation on day 3 of the holiday it
			# paid for, which would break the loop the recovery channel exists to close.
			continue
		if not HRConstants.is_flight_risk(emp.morale):
			if emp.flight_risk_days != 0:
				emp.flight_risk_days = 0
			continue
		# Under the threshold: another consecutive day on the counter. Asked through
		# HRConstants.is_flight_risk so the counter, the badge and the overtime valve share ONE
		# comparison and cannot disagree about the boundary. Note this moves
		# NO morale — a quiet bad day costs the player time, not points.
		emp.flight_risk_days += 1
		_maybe_resign(emp)


## `tick_trait_effects` EMEKLİ (2026-08-21). Tek ekseni `dept_morale_weekly` idi
## (KOL KANAT GERER +2 / HAVAYI BOZAR −2, haftada bir) ve sekiz trait'lik yeni sette o
## eksen yok. Yerine geçen TAT KAÇIRAN bir HAFTALIK DOKUNUŞ değil bir ERİME ÇARPANI:
## ekibin her moral DÜŞÜŞÜNÜ büyütüyor, `_team_decay_mult` üzerinden `apply_delta`'da.
## Fark önemli: eski trait moralİ kendiliğinden aşındırıyordu (§10'un "oynanmamış
## ekonomik sonuç yok" kuralına sınırda bir şey), yenisi yalnız BAŞKA bir sebeple düşen
## morali daha sert düşürüyor — sebep hep oynanmış bir şey kalıyor.


## Bu kişinin ekibindeki TAT KAÇIRAN'ların moral erime çarpanı. Taşıyıcı KENDİ çarpanına
## girmez (bir şikayetçi kendi kendini bozmaz), ve izindeki taşıyıcı odada değildir —
## `get_active_employees` zaten onları dışarıda bırakıyor.
static func _team_decay_mult(emp: Character) -> float:
	if emp == null or emp.category != "employee":
		return 1.0
	# §6 TAT KAÇIRAN takım arkadaşlarının moral düşüşünü hızlandırır. "Takım arkadaşı" artık
	# KADRO GRUBUDUR (§13.1) — departman taksonomisi §8.2 ile birlikte kalktı. Kapsam DARALDI
	# ve bu doğru yönde bir daralma: dört kişilik bir ürün departmanı yerine, oyuncunun
	# defterde yan yana gördüğü bant.
	var group_id: String = String(HRConstants.ROLE_GROUP.get(emp.role, ""))
	if group_id == "":
		return 1.0
	var m: float = 1.0
	for other in CharacterRegistry.get_active_employees():
		if other == null or other.id == emp.id or other.category != "employee":
			continue
		if String(HRConstants.ROLE_GROUP.get(other.role, "")) != group_id:
			continue
		m *= HRConstants.trait_mult(other.traits, "dept_morale_decay_mult")
	return m


# ============================================================================
#  THE morale seam# ============================================================================
#  THE morale seam
# ============================================================================

static func apply_delta(emp: Character, delta: int, reason: String) -> void:
	# The single morale entry point for the whole HR module: çalışma saatleri (§7.1), the
	# three player actions (HRActions), izin dönüşü and the trait nudges all land here, so the
	# carrier's trait multiplier and the founder's Liderlik climate are folded in exactly once
	# and in one place. Callers pass the NOMINAL design number and never pre-scale it.
	if emp == null or delta == 0:
		return
	if emp.category != "employee":
		# The founder ("founder") and Frank ("mentor") are not morale-managed: founder burnout
		# is out of demo scope and the mentor is not staff. Silent rather than loud on purpose
		# — HROvertimeSystem counts the founder as a mesai participant, so this seam being
		# tolerant is what keeps that system from having to special-case him.
		return
	var effective: int = scaled_delta(emp, delta)
	if effective == 0:
		return
	# ADLANDIRILMIŞ DELTA ANINDA İNER; SÜRÜKLENEN TABAN DRIFT'TİR.
	#
	# §7 "hedefe doğru sürüklenir, anında sıçramaz" ile §11.4 "izin dönüşü +15 ... TEK
	# SEFERDE gelir" birlikte okunur: sürüklenen şey AMBIENT erimedir, çünkü §7'nin
	# gerekçesi "oyuncuya tepki verecek pencere bırakmak" ve tepki verilecek şey odur.
	# Zam, izin dönüşü, ayrılık darbesi gibi ADI OLAN etkiler §14'ün modal gramerinde
	# taahhütten önce "Moral 75 → 79" diye okunur; onları geciktirmek modali yalancı yapar
	# ve oyuncunun eylemini tepkisiz gösterirdi.
	#
	# Olay deltaları ayrıca TABAN ÇARPANINDAN GEÇMEZ (§7.1): "ham gelir, ham uygulanır.
	# Yani yedi saatlik gün ambient erimeyi durdurur, DÜNYAYI DURDURMAZ."
	_seed_target(emp)
	var before: int = emp.morale
	# Hedef de birlikte taşınır, yoksa tick_ease morali eski hedefe geri çekerdi.
	emp.morale_target = clampf(emp.morale_target + float(effective),
		float(HRConstants.MORALE_MIN), float(HRConstants.MORALE_MAX))
	CharacterRegistry.set_morale(emp.id, before + effective)   # clamps + emits morale_changed
	if OS.is_debug_build():
		print("[HRMoraleSystem] %s moral %d → %d (%s)" % [emp.id, before, emp.morale, reason])


static func scaled_delta(emp: Character, delta: int) -> int:
	# What apply_delta WOULD write, expressed as a delta, without touching any state: trait
	# multiplier, Liderlik climate, the trait floor and the registry's clamp. HRActions'
	# previews print `emp.morale + scaled_delta(...)`, so the number on the confirm card is
	# exactly the number the action produces — one formula, one home, no drift between the
	# promise and the effect.
	if emp == null or delta == 0 or emp.category != "employee":
		return 0
	# LİDERLİK'İN OYUNDAKİ İLK MEKANİK OKUMASI — noted honestly: until this line the skill
	# existed in onboarding, on the founder card and in the audit only. It stays out of the
	# sales, bug and negotiation formulas (§4.2/§4.5); here it is İKLİM, and KOORDİNASYON
	# is wired later by the HR Coupling task.
	var leadership: int = GameState.get_founder_skill("leadership")
	var scaled: int
	if delta < 0:
		# §4.2 LİDERLİK: yarım yıldız başına moral düşüş hızı −%2, beş yıldızda −%20.
		# Eski climate_drop_mult −%50'ye kadar iniyordu ve tavanı yanlıştı; sabitler
		# Faz 7'ye kadar duruyor ama artık okunmuyorlar.
		#
		# `_team_decay_mult` KİŞİNİN ALEYHİNEDİR (TAT KAÇIRAN aynı ekiptekilerin erimesini
		# hızlandırır), o yüzden düşüşte ÇARPAR — §7.1'in yön kuralı. Yükselişteki tersi
		# _against_mult'ta.
		scaled = int(round(float(delta)
			* _team_decay_mult(emp)
			* _leadership_drop_mult(leadership)))
	else:
		# §4.2 yükseliş tarafına bir bonus VERMİYOR — yalnız "moral düşüş hızını" fiyatlıyor.
		# Aleyhe olan modifikatör burada yükselişi YAVAŞLATIR (§7.1 yön kuralı).
		scaled = int(round(float(delta) / maxf(_team_decay_mult(emp), 0.01)))
	if scaled == 0:
		return 0   # NO DRIFT: a drop worth less than half a point is nothing, not -1.
	var target: int = emp.morale + scaled
	return clampi(target, HRConstants.MORALE_MIN, HRConstants.MORALE_MAX) - emp.morale


# ============================================================================
#  §7 · hedef, taban sürüklenme ve yön kuralı
# ============================================================================

## §4.2: yarım yıldız başına −%2, beş yıldızda (10 ham puan) −%20. Liderlik kişinin
## LEHİNEDİR, o yüzden düşüşü KÜÇÜLTÜR.
static func _leadership_drop_mult(leadership: int) -> float:
	return maxf(1.0 - HRConstants.LEAD_MORALE_PER_POINT * float(clampi(leadership, 0, HRConstants.AREA_MAX)), 0.0)


## morale_target -1 doğar (tohumlanmadı). İlk dokunuşta bugünkü moralden doldurulur, yoksa
## ilk tik morali sıfıra doğru sıçratırdı.
static func _seed_target(emp: Character) -> void:
	if emp.morale_target < 0.0:
		emp.morale_target = float(emp.morale)


## §7.1 TABAN SÜRÜKLENME. Saat çarpanı ve aşırı yük YALNIZ buraya uygulanır.
##
## Çarpan sıfırın altına indiğinde İŞARET DÖNER ve moral yükselir — yedide durur, altıda
## yükselir, beşte taban hızında yükselir (§7.1). Kısa günün bütün mekaniği bu tek
## tablodan geliyor; ayrı bir "toparlanma" sistemi yok.
static func tick_drift() -> void:
	for emp in CharacterRegistry.get_active_employees():
		_seed_target(emp)
		# §8.6: İZİNDEKİ çalışanın morali HİÇ sürüklenmez — ne düşer ne yükselir. Kazanç
		# dönüşte tek seferde gelir (§11.4), yoksa iki hafta erir, sonra +15 alır ve izin
		# NET BİR KAYBA dönerdi. (get_active_employees izindekini zaten dışarıda bırakıyor;
		# bu satır sözleşmeyi okunur kılmak için burada.)
		if emp.status == HRConstants.STATUS_ON_LEAVE:
			continue
		# §8.6: EĞİTİMDEKİ çalışan taban sürüklenmeye TABİDİR — eğitim bir tatil değildir.
		# Yalnız saat çarpanı ve mesai ücreti uygulanmaz.
		var hour_mult: float = 1.0
		if emp.status != HRConstants.STATUS_TRAINING:
			hour_mult = HRConstants.hour_morale_mult(WorkHoursSystem.hours_for(emp))
		var raw: float = -HRConstants.MORALE_BASE_DRIFT_PER_DAY * hour_mult

		if HRSystem.is_overloaded(emp):
			if raw < 0.0:
				# Aleyhe modifikatör, düşüşte: hızlandırır (§7.1, ×1,5).
				raw *= HRConstants.OVERLOAD_MORALE_MULT
			else:
				# §7.1 AŞIRI YÜK BİR TABAN KOYAR: "Aşırı yüklü bir çalışan kısa günden en
				# fazla erimesinin durması kadar fayda görür; morali YÜKSELMEZ. İki iş
				# taşırken toparlanma yoktur." Bu, genel yön kuralından DAHA SERT bir
				# hükümdür ve bilerek öyle.
				raw = 0.0

		if is_zero_approx(raw):
			continue
		# Huy ve liderlik ölçeklemesi TEK YERDE (§7.1): her sistem kendi deltasını ayrı
		# ölçeklemez, ham verir, ölçekleme merkezde uygulanır.
		if raw < 0.0:
			raw *= _team_decay_mult(emp) * _leadership_drop_mult(GameState.get_founder_skill("leadership"))
		else:
			raw /= maxf(_team_decay_mult(emp), 0.01)
		emp.morale_target = clampf(emp.morale_target + raw,
			float(HRConstants.MORALE_MIN), float(HRConstants.MORALE_MAX))


## §7 "anında sıçramaz": görünen moral hedefe doğru günde en fazla MORALE_EASE_PER_DAY
## yürür. Tek yazıcı CharacterRegistry.set_morale — clamp'i ve morale_changed sinyalini o
## taşıyor, ve bu fonksiyon onu atlamıyor.
static func tick_ease() -> void:
	for emp in CharacterRegistry.get_employees():
		_seed_target(emp)
		var gap: float = emp.morale_target - float(emp.morale)
		if is_zero_approx(gap):
			continue
		var step: float = clampf(gap, -HRConstants.MORALE_EASE_PER_DAY, HRConstants.MORALE_EASE_PER_DAY)
		# MORAL BİR TAM SAYI, TABAN DRIFT İSE GÜNDE 0,25. Adımı zorla ±1'e yuvarlamak
		# drift'i dört katına çıkarırdı — sekiz saatlik gün günde bir puan eritirdi ve
		# §7.1'in "hafif baskı" ayarı ölürdü. Onun yerine KESİR HEDEFTE BİRİKİR ve moral
		# ancak fark yarım puanı geçtiğinde kımıldar: 0,25/gün ≈ üç dört günde bir puan.
		# Olay deltaları zaten ≥1 olduğu için ilk tikte hareket ederler.
		var next_value: int = int(round(float(emp.morale) + step))
		if next_value == emp.morale:
			continue
		CharacterRegistry.set_morale(emp.id, next_value)


# ============================================================================
#  Derived read surface (HR tab task 3 + the left-rail badge)
# ============================================================================

static func badges_for(emp: Character) -> Array[String]:
	# TÜRETİLİR, SAKLANMAZ (§15.1): bir kişi aynı anda iki rozet taşıyabilir ve tek bir String
	# alan ikisini tutamaz — Character'daki `attention_flag` tam olarak o yüzden silindi.
	# En kötüsü önce, ki tek rozetlik yeri olan bir arayüz doğru olanı göstersin.
	var out: Array[String] = []
	if emp == null or emp.category != "employee":
		return out
	if HRConstants.is_flight_risk(emp.morale):
		out.append(HRConstants.BADGE_FLIGHT_RISK)
	# §15.1: rozetler SAKLANMAZ, TÜRETİLİR — ve rev 11'de üç tanedir:
	#   Ayrılabilir  ← moral < 35
	#   AŞIRI YÜK    ← atanmış iş sayısı 2
	#   YENİ         ← işe alım tarihi son N gün içinde (bu liste DIŞINDA, çünkü YENİ bir
	#                  dikkat rozeti değil; attention_count'a girmemeli)
	# Birden fazlası aynı anda görünebilir ve birbirini BASTIRMAZ.
	#
	# TÜKENİYOR kalktı: §7'nin dört bandı üç rozete karşılık geliyor ve 40 eşiği rev 2'nindi.
	# ŞİRKET ÇAPINDAKİ "mühendise ihtiyaç var" rozeti de kalktı (§17.6, adıyla): bir şirket
	# sinyalini kişi başına rozet olarak çiziyordu, yalnız developer alınarak temizleniyordu,
	# ve İngilizcede aşırı yük rozetiyle AYNI kelimeyi kullanıyordu — §16 bunu yasaklıyor.
	if HRSystem.is_overloaded(emp):
		out.append(HRConstants.BADGE_OVERLOAD_JOBS)
	return out


static func average_morale() -> float:
	# Employees only: the founder and Frank are NOT part of the team's morale picture (the
	# founder has no morale mechanic and the mentor is not staff). get_employees() already
	# filters by category; the guard below verifies it instead of trusting it.
	var total: int = 0
	var n: int = 0
	for emp in CharacterRegistry.get_employees():
		if emp.category != "employee":
			continue
		total += emp.morale
		n += 1
	if n == 0:
		return 0.0
	return float(total) / float(n)


static func days_since_last_signing() -> int:
	# Reads Customer.acquired_on_day across the registry. NEVER when no account exists, for
	# the same reason as above.
	var newest: int = NEVER
	for c in CustomerRegistry.get_all():
		newest = maxi(newest, c.acquired_on_day)
	if newest <= 0:
		return NEVER
	return GameState.day - newest


static func days_until_return(emp: Character) -> int:
	# Remaining leave days for an on-leave employee, for the "İZİNDE · N gün kaldı" line.
	# Character.leave_until_day is the raw absolute day; the subtraction lives here because
	# leave is this file's domain and a card must not do arithmetic on engine state.
	# 0 for anyone at work, and never negative (tick_leave_returns brings them back at 0).
	if emp == null or emp.status != HRConstants.STATUS_ON_LEAVE:
		return 0
	return maxi(emp.leave_until_day - GameState.day, 0)


static func has_pending_departure(character_id: String) -> bool:
	# A resignation event for this person is queued and unresolved. HRActions refuses every
	# card action while it is: the person is already leaving, and acting behind an open modal
	# about them would contradict what the player is reading.
	return _pending.has(character_id)


# ============================================================================
#  Leave + departure seams
# ============================================================================

static func send_on_leave(emp: Character, days: int, is_manual: bool) -> void:
	# The one door to on_leave, used by the automatic annual leave and by TATİLE GÖNDER.
	# Ücretli izin: maaş akmaya devam eder (CharacterRegistry.get_total_monthly_salaries is
	# deliberately NOT status-filtered), kapasite/hız/CS/mesai katkısı durur.
	if emp == null or emp.category != "employee":
		return
	if days <= 0:
		return
	if emp.status == HRConstants.STATUS_ON_LEAVE:
		return   # idempotent: never restart a running leave
	CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ON_LEAVE)
	emp.leave_until_day = GameState.day + days
	# Once-per-year latch. The MANUAL vacation stamps it too, because TATİLE GÖNDER consumes
	# that year's automatic leave (§11.4) — which is also what keeps a +20 recovery
	# from becoming a fountain the player re-runs every week.
	emp.leave_taken_year = int(GameState.get_date_dict().year)
	GameState.set_flag(FLAG_MANUAL_LEAVE_PREFIX + emp.id, is_manual)
	# Non-interrupting notice: nobody is asked to APPROVE leave (§11.4), so this is a
	# ticker line and never a modal.
	if is_manual:
		EventBus.headline_added.emit(HRConstants.notice_source_hr(), TranslationServer.translate("HR_NEWS_ON_HOLIDAY").format({"name": emp.character_name, "n": days}))
	else:
		EventBus.headline_added.emit(HRConstants.notice_source_hr(), TranslationServer.translate("HR_NEWS_ON_LEAVE_MONTH").format({"name": emp.character_name}))


static func confirm_departure(character_id: String) -> void:
	# Called by the hr_departure event modifier when the player acknowledges a resignation
	# (EventManager._apply_modifiers). The roll already happened in tick_thresholds; this is
	# the removal, and the ONLY place a resignation leaves the roster.
	if character_id == "":
		return
	var emp: Character = CharacterRegistry.get_character(character_id)
	forget_employee(character_id)   # clears the latch even if the record is already gone
	if emp == null:
		return
	if emp.category != "employee":
		push_error("[HRMoraleSystem] confirm_departure on a non-employee ('%s', category '%s') — the founder and the mentor never leave through this path" % [character_id, emp.category])
		return
	# İSTİFADA TAZMİNAT YOKTUR (HRConstants.SEVERANCE_ON_RESIGN == 0, §11.1/§11.3). Nothing
	# is charged here on purpose: the price of neglect was the person, not a payment.
	#
	# AMA EKİP BEDEL ÖDER (2026-08-21). İşten çıkarma bunu zaten yapıyordu
	# (HRActions.fire → MORALE_FIRE_TEAM), İSTİFA yapmıyordu — yani oyuncunun ihmali
	# yüzünden giden biri odada hiç iz bırakmıyordu. GERÇEK LİDER'in bedeli tam olarak
	# burada okunuyor: "ayrılışı −10 alan, diğerleri −5".
	_charge_departure(character_id)
	CharacterRegistry.remove(character_id)   # run_departures++ and character_removed


## Bir ayrılışın kalan ekibe moral bedeli. Taban HRConstants.MORALE_FIRE_TEAM (5) —
## işten çıkarmanın zaten kullandığı sabit, yeni bir sayı icat edilmedi.
## GERÇEK LİDER taşıyanlar `departure_morale_extra` kadar FAZLA öder.
static func _charge_departure(leaver_id: String) -> void:
	for other in CharacterRegistry.get_employees():
		if other == null or other.id == leaver_id:
			continue
		var extra: float = HRConstants.trait_sum(other.traits, "departure_morale_extra")
		var cost: int = HRConstants.MORALE_FIRE_TEAM + int(round(absf(extra)))
		apply_delta(other, -cost, HRConstants.REASON_TEAMMATE_FIRED)


static func forget_employee(character_id: String) -> void:
	# Drop every HR-side latch a leaver held so nothing outlives the record: the
	# pending-departure entry and the manual-vacation marker. Called by confirm_departure and
	# by HRActions.fire BEFORE CharacterRegistry.remove, while the id is still meaningful.
	if character_id == "":
		return
	_pending.erase(character_id)
	GameState.set_flag(FLAG_MANUAL_LEAVE_PREFIX + character_id, false)


static func reset_rng() -> void:
	# Called by HRSystem.reset() from GameState.initialize_run, which runs it AFTER run_seed
	# is assigned (it used to run before, which would have keyed the generator to the
	# PREVIOUS run's seed). RngStreams.get_stream() keeps the belt-and-braces re-key at the
	# first roll, so a future reordering cannot silently break determinism again.
	#
	# NOTE ON THE LOAD PATH: this re-keys the hr_morale stream from run_seed, i.e. back to
	# the START of the sequence. That is correct for a fresh run and would be wrong for a
	# load — which is why SaveCodec.restore_systems runs RngStreams.from_dict() AFTER
	# initialize_run has finished, restoring the saved position over this re-key.
	RngStreams.reseed(GameState.run_seed)
	_pending.clear()


static func to_dict() -> Dictionary:
	# _pending is the resignation latch: an employee whose roll already succeeded sits here
	# until the player acknowledges the event, and without it the roll is re-attempted every
	# day in between, pushing the effective odds silently above RESIGN_CHANCE_PER_DAY.
	#
	# It is PROVABLY empty at every save point today (the latch is set in the same breath as
	# the enqueue, and SaveManager.can_save() refuses while EventManager.has_pending()), so
	# this could have been justified as an exclusion. It is saved anyway: that invariant
	# lives in a different file, and a schema that silently depends on another module's gate
	# staying exactly this strict is a trap for whoever loosens it.
	return {"pending_departures": _pending.duplicate()}


static func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	_pending.clear()
	for id in (d.get("pending_departures", []) as Array):
		_pending.append(String(id))


# ============================================================================
#  Internals
# ============================================================================

static func _maybe_resign(emp: Character) -> void:
	# KAÇMA RİSKİ ihmal edilirse istifa (§11.3). The played decision is upstream: the
	# badge is visible for the whole window and all three card actions are available the
	# entire time, so neglect IS the decision.
	#
	# THE GUARD ORDER MATTERS: every cheap integer test runs before the RNG is touched, so a
	# healthy team consumes literally zero draws and cannot displace anything.
	if emp.flight_risk_days <= 0:
		return
	if emp.flight_risk_days < HRConstants.RESIGN_WINDOW_MIN_DAYS:
		return
	if _pending.has(emp.id):
		return
	# EMNİYET VALFİ GİTTİ. Valf bir MESAİ BLOĞUNUN olayıydı ("bu kişi tükeniyor, bloğu
	# durdurayım mı?") ve §8.2 blokları kaldırdı: durdurulacak bir blok yok, o yüzden
	# "Devam et" diye bir karar da yok. §11.3 ayrılmaları olay motoruna bırakıyor; kişi
	# başına ceza oraya, kendi kararıyla birlikte döner.
	var chance: float = HRConstants.resign_chance(emp.traits, false)
	if emp.flight_risk_days >= HRConstants.RESIGN_WINDOW_MAX_DAYS:
		# WORKING: the far edge of the canon 10-14 gün window is a CERTAINTY, not a coin flip
		# that keeps failing. Rolling forever would leave a permanently neglected employee in
		# limbo with a red badge the player can never resolve; stopping the roll at day 14
		# would do the same and also make ~24% of neglected people immortal. Rolled on days
		# 10-13, certain on day 14 — so "ignored for two weeks" is a rule the player can learn.
		chance = 1.0
	if not _roll(chance):
		return
	# Latch BEFORE enqueueing, so a re-entrant enqueue path can never double-fire.
	_pending.append(emp.id)
	EventManager.enqueue(HREventFactory.build_resignation(emp))


static func _roll(chance: float) -> bool:
	# Same force-flag shape as SkillCheck.roll_against / SkillCheck.resolve, so the smoke
	# suite can pin a resignation without pinning the whole global stream:
	# flags["debug_hr_force"] = "pass" | "fail", debug builds only.
	var forced: String = String(GameState.get_flag("debug_hr_force", ""))
	if OS.is_debug_build() and forced == "pass":
		return true
	if OS.is_debug_build() and forced == "fail":
		return false
	return RngStreams.get_stream(RngStreams.STREAM_HR_MORALE).randf() < chance
