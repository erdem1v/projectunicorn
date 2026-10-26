class_name HRMoraleSystem
extends RefCounted

# Moral makinesi (§7), yıllık izin (§11.4) ve ayrılış yolları (§11.3). HRSystem.daily_tick
# günlük adımları o dosyadaki sırayla çağırır.
#
# Moral iki katmanlıdır: `morale_target` sürüklenen hedef, `morale` görünen değer. Taban
# sürüklenme (tick_drift) yalnız hedefi yazar ve saat/aşırı yük çarpanı yalnız ona uygulanır;
# adı olan deltalar (apply_delta) hedefe VE morale anında iner; tick_ease görünen morali
# hedefe doğru yürütür.
#
# WRITE-THROUGH: moral yalnız CharacterRegistry.set_morale, ayrılış yalnız
# CharacterRegistry.remove üzerinden. İzin alanları (status hariç), kaçma riski ve tükenmişlik
# sayaçlarının registry seam'i yok; sahibi bu dosyadır.


# Oyuncunun gönderdiği izin dönüşte haftasına göre, yaz izni sabit moral getirir; iznin haftası
# Character'da alan olmadığı için GameState.flags'te kişi başına tutulur (0 = yaz izni).
const FLAG_MANUAL_LEAVE_PREFIX := "hr_manual_leave_"

# Bekleyen istifa. Oyuncu kartı kapatana kadar kişi burada kalır: hem aynı kişi için roll'u
# durdurur (yoksa kart açıkken ertesi hafta ikinci bir istifa istenirdi) hem de HRActions'ın
# kart eylemlerini reddettiği gerçektir.
static var _pending: Array[String] = []


# ============================================================================
#  Günlük adımlar
# ============================================================================

static func tick_leave_returns() -> void:
	# İlk koşar ki günün geri kalanı geri gelen `active` durumunu okusun.
	for emp in CharacterRegistry.get_employees():
		if emp.status != HRConstants.STATUS_ON_LEAVE or GameState.day < _return_day(emp):
			continue
		CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ACTIVE)
		if emp.leave_kind == HRConstants.LEAVE_KIND_SICK:
			# Hastalıktan dönüş tatilden dönüş değildir: ne moral verir ne de oyuncunun izin beklemesini başlatır.
			CharacterRegistry.set_away(emp.id, "", 0)
			EventBus.headline_added.emit(HRConstants.NEWS_SOURCE,
				{"key": "HR_NEWS_BACK_TO_WORK", "args": {"name": emp.character_name}})
			continue
		var manual_weeks: int = int(GameState.get_flag(FLAG_MANUAL_LEAVE_PREFIX + emp.id, 0))
		GameState.set_flag(FLAG_MANUAL_LEAVE_PREFIX + emp.id, 0)
		# leave_until_day dönüş günü olarak kalır: oyuncunun yeni izni ondan LEAVE_COOLDOWN_WEEKS sonra açılır.
		apply_delta(emp, HRConstants.MORALE_VACATION_RETURN.get(manual_weeks, HRConstants.MORALE_LEAVE_RETURN))
		EventBus.headline_added.emit(HRConstants.NEWS_SOURCE,
			{"key": "HR_NEWS_BACK_FROM", "args": {"name": emp.character_name}})


static func tick_leave_departures() -> void:
	# §11.4 yaz penceresi: her çalışanın Haziran–Ağustos içinde atanmış bir izin HAFTASI var;
	# o hafta gelince oyuncu onayı istenmeden izne çıkar. Tikler yedi gün arayla düşer, bu yüzden
	# pencerenin tikleri 0..12 indekslerine birer kez düşer.
	var date: Dictionary = GameState.get_date_dict()
	var month: int = int(date.month)
	var year: int = int(date.year)
	if month < HRConstants.LEAVE_WINDOW_START_MONTH or month > HRConstants.LEAVE_WINDOW_END_MONTH:
		return
	var since_june: int = Time.get_unix_time_from_datetime_dict(date) - Time.get_unix_time_from_datetime_dict(
		{"year": year, "month": HRConstants.LEAVE_WINDOW_START_MONTH, "day": 1})
	var week_index: int = int(float(since_june) / (7.0 * 86400.0))
	for emp in CharacterRegistry.get_employees():
		if emp.status != HRConstants.STATUS_ACTIVE or summer_week(emp, year) != week_index:
			continue
		# Bu yılın iznini almış olan (bugün dönen dahil) yeniden gönderilmez.
		if emp.leave_taken_year == year:
			continue
		# §15.3: talep bu modülden doğar, kartı olay motorunundur; kart bağlanana kadar izin
		# otomatik başlar ama sinyal yayınlanır.
		EventBus.leave_requested.emit(emp.id)
		send_on_leave(emp, HRConstants.LEAVE_WEEKS, false)


static func tick_thresholds() -> void:
	# Kaçma riski sayacı ve istifa roll'u. Drift ve ease'ten sonra koşar ki bu haftanın moralini okusun.
	for emp in CharacterRegistry.get_employees():
		# İzindekinin sayacı DONAR (sıfırlanmaz, ihmal tatille aklanmaz) ve roll atılmaz:
		# oyuncunun ödediği toparlanma tatili istifayla cevaplanmamalı.
		if emp.status == HRConstants.STATUS_ON_LEAVE:
			continue
		if not HRConstants.is_flight_risk(emp.morale):
			emp.flight_risk_weeks = 0
			continue
		emp.flight_risk_weeks += 1
		_maybe_resign(emp)


## Tükenmişlik: sekizi aşan her iş haftası sayılır, başka her hafta sayımı sıfırlar. Sayaç BURNOUT_WEEKS'e
## varınca kart istenir; kabul edilen kartla sayım baştan başlar, reddedilen istek gelecek hafta yinelenir.
## Kurucu sayılmaz: onun uzun gününün bedeli gün içi verim düşüşüdür.
static func tick_burnout() -> void:
	for emp in CharacterRegistry.get_employees():
		if emp.status != HRConstants.STATUS_ACTIVE or not WorkHoursSystem.overtime_active(emp):
			emp.overtime_weeks = 0
			continue
		emp.overtime_weeks += 1
		if emp.overtime_weeks >= HRConstants.BURNOUT_WEEKS \
				and EventGate.request("team.burnout", {"employee": emp.id}):
			emp.overtime_weeks = 0


## §6 TAT KAÇIRAN aynı kadro grubundaki (§13.1) takım arkadaşlarının moral düşüşünü
## hızlandırır. Taşıyıcı kendi çarpanına girmez; izindeki taşıyıcı odada değildir, eğitimdeki
## odadadır (§8.6: eğitim bir tatil değildir).
static func _team_decay_mult(emp: Character) -> float:
	var group_id: String = String(HRConstants.ROLE_GROUP.get(emp.role, ""))
	if group_id == "":
		return 1.0
	var m: float = 1.0
	for other in CharacterRegistry.get_employees():
		if other.id == emp.id or other.status == HRConstants.STATUS_ON_LEAVE \
				or String(HRConstants.ROLE_GROUP.get(other.role, "")) != group_id:
			continue
		m *= HRConstants.trait_mult(other.traits, "dept_morale_decay_mult")
	return m


## Huy ve liderlik ölçeklemesinin TEK yeri (§7.1): sistemler ham delta verir. Aleyhe
## modifikatör (TAT KAÇIRAN) düşüşü hızlandırır, yükselişi yavaşlatır. Liderlik (§4.2)
## yalnız düşüş hızını küçültür; yükselişe bonus vermez.
static func _scale(emp: Character, raw: float) -> float:
	var decay: float = _team_decay_mult(emp)
	if raw < 0.0:
		return raw * decay * _leadership_drop_mult(GameState.get_founder_skill("leadership"))
	return raw / maxf(decay, 0.01)


## §4.2: yarım yıldız (1 ham puan) başına −%2 düşüş hızı.
static func _leadership_drop_mult(leadership: int) -> float:
	return maxf(1.0 - HRConstants.LEAD_MORALE_PER_POINT * float(clampi(leadership, 0, HRConstants.AREA_MAX)), 0.0)


## morale_target -1 doğar; ilk dokunuşta bugünkü moralden doldurulur, yoksa ilk tik morali
## sıfıra doğru çekerdi.
static func _seed_target(emp: Character) -> void:
	if emp.morale_target < 0.0:
		emp.morale_target = float(emp.morale)


## §7.1 taban sürüklenme. Saat çarpanı ve aşırı yük YALNIZ buraya uygulanır; çarpan sıfırın
## altına inince işaret döner ve moral yükselir (sekizde durur, yedide yükselir; aşırı yük ve TAT
## KAÇIRAN sekizde de aşındırır).
static func tick_drift() -> void:
	var drift: float = TimeModel.per_tick(HRConstants.MORALE_BASE_DRIFT_PER_DAY)
	for emp in CharacterRegistry.get_employees():
		_seed_target(emp)
		# §8.6: izindekinin morali hiç sürüklenmez, kazanç dönüşte tek seferde gelir. Eğitimdeki
		# ise taban sürüklenmeye tabidir; yalnız saat çarpanı uygulanmaz.
		if emp.status == HRConstants.STATUS_ON_LEAVE:
			continue
		var hour_mult: float = 1.0
		if emp.status != HRConstants.STATUS_TRAINING:
			hour_mult = HRConstants.hour_morale_mult(WorkHoursSystem.hours_for(emp))
		var overloaded: bool = HRSystem.is_overloaded(emp)
		if is_zero_approx(hour_mult) and (overloaded or _team_decay_mult(emp) > 1.0):
			hour_mult = HRConstants.LOADED_DAY_MORALE_MULT
		var raw: float = -drift * hour_mult
		if overloaded:
			# §12.1: aşırı yük düşüşü hızlandırır; kısa günde de moral YÜKSELMEZ, en fazla durur.
			raw = raw * HRConstants.OVERLOAD_MORALE_MULT if raw < 0.0 else 0.0
		if is_zero_approx(raw):
			continue
		emp.morale_target = clampf(emp.morale_target + _scale(emp, raw),
			float(HRConstants.MORALE_MIN), float(HRConstants.MORALE_MAX))


## §7 "anında sıçramaz": görünen moral hedefe doğru günde en fazla MORALE_EASE_PER_DAY yürür.
static func tick_ease() -> void:
	var max_step: float = TimeModel.per_tick(HRConstants.MORALE_EASE_PER_DAY)
	for emp in CharacterRegistry.get_employees():
		_seed_target(emp)
		var gap: float = emp.morale_target - float(emp.morale)
		if is_zero_approx(gap):
			continue
		var step: float = clampf(gap, -max_step, max_step)
		# Adım ±1'e zorlanmaz: drift kesir olarak hedefte birikir ve moral ancak fark yarım
		# puanı geçince kımıldar. Zorlamak kesirli drift'i tam puana şişirirdi.
		var next_value: int = int(round(float(emp.morale) + step))
		if next_value != emp.morale:
			CharacterRegistry.set_morale(emp.id, next_value)


# ============================================================================
#  Moral seam'i
# ============================================================================

## HR modülünün tek moral giriş noktası. Çağıran NOMİNAL tasarım sayısını verir; ölçekleme
## burada bir kez yapılır. Adı olan delta anında iner (§14 önizlemesi "Moral 75 → 79" yalan
## söylemesin) ve saat çarpanından geçmez (§7.1). Kurucu ve Frank moral yönetilmez; sessizce
## yok sayılır ki mesai kurucuyu özel durum olarak ele almak zorunda kalmasın.
static func apply_delta(emp: Character, delta: int) -> void:
	var effective: int = scaled_delta(emp, delta)
	if effective == 0:
		return
	_seed_target(emp)
	# Hedef de taşınır, yoksa tick_ease morali eski hedefe geri çekerdi.
	emp.morale_target = clampf(emp.morale_target + float(effective),
		float(HRConstants.MORALE_MIN), float(HRConstants.MORALE_MAX))
	CharacterRegistry.set_morale(emp.id, emp.morale + effective)


## apply_delta'nın YAZACAĞI delta, durum değiştirmeden. HRActions önizlemeleri
## `emp.morale + scaled_delta(...)` basar, böylece onay kartındaki sayı eylemin sonucudur.
static func scaled_delta(emp: Character, delta: int) -> int:
	if emp == null or delta == 0 or emp.category != "employee":
		return 0
	# Yarım puanın altındaki düşüş sıfırdır, −1'e yuvarlanmaz.
	var scaled: int = int(round(_scale(emp, float(delta))))
	return clampi(emp.morale + scaled, HRConstants.MORALE_MIN, HRConstants.MORALE_MAX) - emp.morale


# ============================================================================
#  Türetilmiş okuma yüzeyi
# ============================================================================

## §15.1 rozetler saklanmaz, türetilir; bir kişi aynı anda birden fazlasını taşıyabilir. En
## kötüsü önce, ki tek rozetlik yer doğru olanı göstersin. YENİ bir dikkat rozeti değildir ve
## bu listeye girmez (attention_count bunu sayar).
static func badges_for(emp: Character) -> Array[String]:
	var out: Array[String] = []
	if emp == null or emp.category != "employee":
		return out
	if HRConstants.is_flight_risk(emp.morale):
		out.append(HRConstants.BADGE_FLIGHT_RISK)
	if HRSystem.is_overloaded(emp):
		out.append(HRConstants.BADGE_OVERLOAD_JOBS)
	return out


static func average_morale() -> float:
	var employees: Array[Character] = CharacterRegistry.get_employees()
	if employees.is_empty():
		return 0.0
	var total: int = 0
	for emp in employees:
		total += emp.morale
	return float(total) / float(employees.size())


## "İZİNDE · N hafta kaldı" satırı için; işteyken 0.
static func weeks_until_return(emp: Character) -> int:
	if emp == null or emp.status != HRConstants.STATUS_ON_LEAVE:
		return 0
	return maxi(_return_day(emp) - GameState.day, 0)


## Bu yıl için yaz izni haftası: bir olay kartı kaydırdıysa o, değilse işe girişte atanan.
static func summer_week(emp: Character, year: int) -> int:
	return emp.leave_week_override if emp.leave_override_year == year else emp.leave_week


## Bu yılın yaz izninin başlamasına kalan hafta; izin alınmışsa, pencere geçtiyse ya da hafta atanmadıysa -1.
static func leave_weeks_left(emp: Character) -> int:
	var date: Dictionary = GameState.get_date_dict()
	var week: int = summer_week(emp, int(date.year))
	if emp.leave_taken_year == int(date.year) or week < 0:
		return -1
	return _weeks_until(week, date)


## Yaz izni bloğu bununkiyle örtüşen, aynı roldeki iş arkadaşı: çalışıyor, bu yılın iznini almamış ve başlangıcı en çok bir
## hafta uzakta. En yakın hafta kazanır, eşitlikte önce işe giren. Yoksa "".
static func leave_partner(emp: Character) -> String:
	var year: int = int(GameState.get_date_dict().year)
	var week: int = summer_week(emp, year)
	var best: String = ""
	var gap: int = HRConstants.LEAVE_WEEKS
	for other in CharacterRegistry.employees_by_hire():
		var apart: int = absi(summer_week(other, year) - week)
		if other.id != emp.id and other.role == emp.role and other.status == HRConstants.STATUS_ACTIVE \
				and other.leave_taken_year != year and apart < gap:
			best = other.id
			gap = apart
	return best


## `summer_leave` fiilinin bir çifte bu yıl yaptığı: `apart` geç başlayanı (eşitlikte `b`) erken başlayanın iki hafta arkasına
## alır; blokları zaten ayrı olana ve arkası pencereye sığmayana dokunmaz. Öne alınan izin geçmiş bir haftaya düşebilirdi, bu yüzden
## kayan hep geç başlayandır. `together` ikisini de erken başlayanın haftasına alır: iki izin aynı iki haftadır.
## {a_id, b_id, apart, moved_id: kayan ("" yoksa), a_week, b_week: sonraki haftalar, shift: kaç hafta kaydığı, weeks_away:
## ikisinden önce gidenin başlamasına kalan hafta}.
static func plan_summer_leave(a: Character, b: Character, apart: bool) -> Dictionary:
	var date: Dictionary = GameState.get_date_dict()
	var year: int = int(date.year)
	var a_week: int = summer_week(a, year)
	var b_week: int = summer_week(b, year)
	var moved_id: String = ""
	var shift: int = 0
	var early_week: int = mini(a_week, b_week)
	var late_week: int = maxi(a_week, b_week)
	if not apart:
		a_week = early_week
		b_week = early_week
	elif late_week - early_week < HRConstants.LEAVE_WEEKS and early_week + HRConstants.LEAVE_WEEKS < HRConstants.LEAVE_WEEK_COUNT:
		shift = early_week + HRConstants.LEAVE_WEEKS - late_week
		if a_week <= b_week:
			moved_id = b.id
			b_week += shift
		else:
			moved_id = a.id
			a_week += shift
	return {"a_id": a.id, "b_id": b.id, "apart": apart, "moved_id": moved_id, "shift": shift, "a_week": a_week, "b_week": b_week,
		"weeks_away": _weeks_until(mini(a_week, b_week), date)}


## `summer_leave`: planın iki haftasını da bu yıla sabitler; kayan yoksa yazılan yerinde durandır.
static func apply_summer_leave(plan: Dictionary) -> void:
	var year: int = int(GameState.get_date_dict().year)
	CharacterRegistry.set_leave_override(plan.a_id, plan.a_week, year)
	CharacterRegistry.set_leave_override(plan.b_id, plan.b_week, year)


## Bu kişi için bekleyen bir istifa kartı var; HRActions bu sürede kart eylemlerini reddeder.
static func has_pending_departure(character_id: String) -> bool:
	return _pending.has(character_id)


# ============================================================================
#  İzin ve ayrılış seam'leri
# ============================================================================

## on_leave'e tek kapı. Ücretli izin: maaş akar (maaş toplamı durumla süzülmez), katkı durur.
static func send_on_leave(emp: Character, weeks: int, is_manual: bool) -> void:
	if emp == null or emp.category != "employee" or weeks <= 0:
		return
	if emp.status == HRConstants.STATUS_ON_LEAVE:
		return   # süren izin yeniden başlatılmaz
	CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ON_LEAVE)
	emp.leave_until_day = GameState.day + TimeModel.ticks(weeks)
	# Oyuncunun gönderdiği izin o yılın yaz izni yerine sayılır (§11.4).
	emp.leave_taken_year = int(GameState.get_date_dict().year)
	GameState.set_flag(FLAG_MANUAL_LEAVE_PREFIX + emp.id, weeks if is_manual else 0)
	# Kimse izni ONAYLAMAZ (§11.4): modal değil ticker satırı.
	var key: String = "HR_NEWS_ON_HOLIDAY" if is_manual else "HR_NEWS_ON_LEAVE"
	EventBus.headline_added.emit(HRConstants.NEWS_SOURCE,
		{"key": Fmt.count_key(key, weeks), "args": {"name": emp.character_name, "n": weeks}})


## Hastalık: on_leave'e girer, ama o yılın yaz izni sayılmaz ve oyuncunun izin beklemesi başlamaz (leave_taken_year ve
## leave_until_day yazılmaz). Gidişte haber, dönüşte moral yoktur. Çalışmayan kişi hasta olmaz: o zaman false.
static func send_on_sick_leave(emp: Character, weeks: int) -> bool:
	if emp == null or emp.category != "employee" or weeks <= 0 or emp.status != HRConstants.STATUS_ACTIVE:
		return false
	CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ON_LEAVE)
	CharacterRegistry.set_away(emp.id, HRConstants.LEAVE_KIND_SICK, GameState.day + TimeModel.ticks(weeks))
	return true


## hr_departure modifier'ı oyuncu istifayı kabul edince çağırır. İstifanın kadrodan çıktığı
## TEK yer.
static func confirm_departure(character_id: String) -> void:
	if character_id == "":
		return
	var emp: Character = CharacterRegistry.get_character(character_id)
	forget_employee(character_id)   # kayıt zaten gitmiş olsa da latch temizlenir
	if emp == null:
		return
	if emp.category != "employee":
		push_error("[HRMoraleSystem] confirm_departure on a non-employee ('%s', category '%s')" % [character_id, emp.category])
		return
	# İstifada tazminat yoktur (§11.1/§11.3); bedeli ekip öder, işten çıkarmadaki gibi.
	_charge_departure(character_id)
	CharacterRegistry.remove(character_id)


## Ayrılışın kalan ekibe moral bedeli: MORALE_FIRE_TEAM, GERÇEK LİDER taşıyanlara
## `departure_morale_extra` kadar fazlası.
static func _charge_departure(leaver_id: String) -> void:
	for other in CharacterRegistry.get_employees():
		if other.id == leaver_id:
			continue
		var extra: float = HRConstants.trait_sum(other.traits, "departure_morale_extra")
		apply_delta(other, -(HRConstants.MORALE_FIRE_TEAM + int(round(absf(extra)))))


## Ayrılanın HR tarafı latch'lerini temizler. confirm_departure ve HRActions.fire,
## CharacterRegistry.remove'dan ÖNCE çağırır.
static func forget_employee(character_id: String) -> void:
	if character_id == "":
		return
	_pending.erase(character_id)
	GameState.set_flag(FLAG_MANUAL_LEAVE_PREFIX + character_id, 0)


## Run sınırı: önceki koşunun bekleyen istifası yeni koşuya taşınmaz. İstifa roll'unun akışını
## RngStreams kendisi run_seed'e bağlar.
static func reset() -> void:
	_pending.clear()


static func to_dict() -> Dictionary:
	# Bugün her kayıt noktasında boştur (SaveManager.can_save açık kart varken reddeder) ama
	# yine de saklanır: şema başka bir modülün kapısının bu kadar sıkı kalmasına dayanmasın.
	return {"pending_departures": _pending.duplicate()}


static func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	_pending.clear()
	for id in (d.get("pending_departures", []) as Array):
		_pending.append(String(id))


# ============================================================================
#  İç
# ============================================================================

## Kişinin yokluğunun bittiği gün: hastalık away_until_day'de, izin leave_until_day'de biter.
static func _return_day(emp: Character) -> int:
	return emp.away_until_day if emp.leave_kind == HRConstants.LEAVE_KIND_SICK else emp.leave_until_day


## Yaz penceresinin `week` indeksli haftasının başlayacağı tike kalan hafta (`date` bugünün tarihi); geçtiyse -1.
static func _weeks_until(week: int, date: Dictionary) -> int:
	var window_start: int = Time.get_unix_time_from_datetime_dict(
		{"year": int(date.year), "month": HRConstants.LEAVE_WINDOW_START_MONTH, "day": 1})
	var week_start: int = window_start + week * 7 * 86400
	var left: int = ceili(float(week_start - Time.get_unix_time_from_datetime_dict(date)) / (7.0 * 86400.0))
	return left if left >= 0 else -1


## Kaçma riski ihmal edilirse istifa (§11.3). Ucuz tamsayı testleri RNG'den önce: sağlıklı
## bir ekip hiç çekiliş tüketmez.
static func _maybe_resign(emp: Character) -> void:
	if emp.flight_risk_weeks < TimeModel.ticks(HRConstants.RESIGN_WINDOW_MIN_WEEKS) or _pending.has(emp.id):
		return
	var chance: float = HRConstants.resign_chance(emp.traits)
	# Pencerenin üst ucu kesinliktir: sonsuz roll kalıcı bir kırmızı rozetle arafta kalan
	# biri bırakırdı. "Üç hafta ihmal" oyuncunun öğrenebileceği bir kural olur.
	if emp.flight_risk_weeks >= TimeModel.ticks(HRConstants.RESIGN_WINDOW_MAX_WEEKS):
		chance = 1.0
	if not _roll(chance):
		return
	_pending.append(emp.id)
	EventGate.request("team.resignation", {"employee": emp.id})


## flags["debug_hr_force"] = "pass" | "fail" (yalnız debug build) smoke'un bir istifayı
## akışı sabitlemeden zorlamasını sağlar.
static func _roll(chance: float) -> bool:
	if OS.is_debug_build():
		match String(GameState.get_flag("debug_hr_force", "")):
			"pass":
				return true
			"fail":
				return false
	return RngStreams.get_stream(RngStreams.STREAM_HR_MORALE).randf() < chance
