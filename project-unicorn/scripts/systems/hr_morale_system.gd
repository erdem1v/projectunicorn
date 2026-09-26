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
# CharacterRegistry.remove üzerinden. İzin alanları (status hariç) ve kaçma riski sayacının
# registry seam'i yok; sahibi bu dosyadır.


# Manuel tatil ile otomatik yıllık izin dönüşte farklı moral getirir; işaret Character'da
# alan olmadığı için GameState.flags'te kişi başına tutulur.
const FLAG_MANUAL_LEAVE_PREFIX := "hr_manual_leave_"

# Bekleyen istifa. Oyuncu kartı kapatana kadar kişi burada kalır: hem aynı kişi için günlük
# roll'u durdurur (yoksa etkin olasılık RESIGN_CHANCE_PER_DAY'in üstüne çıkardı) hem de
# HRActions'ın kart eylemlerini reddettiği gerçektir.
static var _pending: Array[String] = []


# ============================================================================
#  Günlük adımlar
# ============================================================================

static func tick_leave_returns() -> void:
	# İlk koşar ki günün geri kalanı geri gelen `active` durumunu okusun.
	for emp in CharacterRegistry.get_employees():
		if emp.status != HRConstants.STATUS_ON_LEAVE or GameState.day < emp.leave_until_day:
			continue
		var was_manual: bool = bool(GameState.get_flag(FLAG_MANUAL_LEAVE_PREFIX + emp.id, false))
		CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ACTIVE)
		emp.leave_until_day = 0
		GameState.set_flag(FLAG_MANUAL_LEAVE_PREFIX + emp.id, false)
		# İzin dönüşü moral getirir, manuel tatil dönüşü daha büyük (§11.4).
		if was_manual:
			apply_delta(emp, HRConstants.MORALE_VACATION_RETURN, HRConstants.REASON_VACATION_RETURN)
		else:
			apply_delta(emp, HRConstants.MORALE_LEAVE_RETURN, HRConstants.REASON_LEAVE_RETURN)
		var whence: String = TranslationServer.translate("HR_WHENCE_HOLIDAY" if was_manual else "HR_WHENCE_LEAVE")
		EventBus.headline_added.emit(HRConstants.notice_source_hr(), TranslationServer.translate("HR_NEWS_BACK_FROM").format({"name": emp.character_name, "whence": whence}))


static func tick_leave_departures() -> void:
	# §11.4 yaz penceresi: her çalışanın Haziran–Ağustos içinde atanmış bir izin HAFTASI var;
	# o hafta gelince oyuncu onayı istenmeden izne çıkar.
	var date: Dictionary = GameState.get_date_dict()
	var month: int = int(date.month)
	var year: int = int(date.year)
	if month < HRConstants.LEAVE_WINDOW_START_MONTH or month > HRConstants.LEAVE_WINDOW_END_MONTH:
		return
	var week_index: int = int(float(GameState.day - _summer_window_start_day(year)) / 7.0)
	for emp in CharacterRegistry.get_employees():
		if emp.status != HRConstants.STATUS_ACTIVE or emp.leave_week != week_index:
			continue
		# Bu yılın iznini almış olan (bugün dönen dahil) yeniden gönderilmez.
		if emp.leave_taken_year == year:
			continue
		# §15.3: talep bu modülden doğar, kartı olay motorunundur; kart bağlanana kadar izin
		# otomatik başlar ama sinyal yayınlanır.
		EventBus.leave_requested.emit(emp.id)
		send_on_leave(emp, HRConstants.LEAVE_DAYS, false)


## Yaz penceresinin (1 Haziran) o yıldaki run günü. Takvim dönüşümü yalnız get_date_dict'te
## yaşadığı için bugünden geriye taranır; pencere en fazla ~92 gün.
static func _summer_window_start_day(year: int) -> int:
	var probe: int = GameState.day
	while probe > 1:
		var d: Dictionary = GameState.get_date_dict(probe - 1)
		if int(d.year) != year or int(d.month) < HRConstants.LEAVE_WINDOW_START_MONTH:
			break
		probe -= 1
	return probe


static func tick_thresholds() -> void:
	# Kaçma riski sayacı ve istifa roll'u. Drift ve ease'ten sonra koşar ki bugünün moralini okusun.
	for emp in CharacterRegistry.get_employees():
		# İzindekinin sayacı DONAR (sıfırlanmaz, ihmal tatille aklanmaz) ve roll atılmaz:
		# oyuncunun ödediği toparlanma tatilin üçüncü günü istifayla cevaplanmamalı.
		if emp.status == HRConstants.STATUS_ON_LEAVE:
			continue
		if not HRConstants.is_flight_risk(emp.morale):
			emp.flight_risk_days = 0
			continue
		emp.flight_risk_days += 1
		_maybe_resign(emp)


## §6 TAT KAÇIRAN aynı kadro grubundaki (§13.1) takım arkadaşlarının moral düşüşünü
## hızlandırır. Taşıyıcı kendi çarpanına girmez; izindeki taşıyıcı odada değildir.
static func _team_decay_mult(emp: Character) -> float:
	var group_id: String = String(HRConstants.ROLE_GROUP.get(emp.role, ""))
	if group_id == "":
		return 1.0
	var m: float = 1.0
	for other in CharacterRegistry.get_active_employees():
		if other.id == emp.id or String(HRConstants.ROLE_GROUP.get(other.role, "")) != group_id:
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
## altına inince işaret döner ve moral yükselir (yedide durur, altıda yükselir).
static func tick_drift() -> void:
	for emp in CharacterRegistry.get_employees():
		_seed_target(emp)
		# §8.6: izindekinin morali hiç sürüklenmez, kazanç dönüşte tek seferde gelir. Eğitimdeki
		# ise taban sürüklenmeye tabidir; yalnız saat çarpanı uygulanmaz.
		if emp.status == HRConstants.STATUS_ON_LEAVE:
			continue
		var hour_mult: float = 1.0
		if emp.status != HRConstants.STATUS_TRAINING:
			hour_mult = HRConstants.hour_morale_mult(WorkHoursSystem.hours_for(emp))
		var raw: float = -HRConstants.MORALE_BASE_DRIFT_PER_DAY * hour_mult
		if HRSystem.is_overloaded(emp):
			# §12.1: aşırı yük düşüşü hızlandırır; kısa günde de moral YÜKSELMEZ, en fazla durur.
			raw = raw * HRConstants.OVERLOAD_MORALE_MULT if raw < 0.0 else 0.0
		if is_zero_approx(raw):
			continue
		emp.morale_target = clampf(emp.morale_target + _scale(emp, raw),
			float(HRConstants.MORALE_MIN), float(HRConstants.MORALE_MAX))


## §7 "anında sıçramaz": görünen moral hedefe doğru günde en fazla MORALE_EASE_PER_DAY yürür.
static func tick_ease() -> void:
	for emp in CharacterRegistry.get_employees():
		_seed_target(emp)
		var gap: float = emp.morale_target - float(emp.morale)
		if is_zero_approx(gap):
			continue
		var step: float = clampf(gap, -HRConstants.MORALE_EASE_PER_DAY, HRConstants.MORALE_EASE_PER_DAY)
		# Adım ±1'e zorlanmaz: günde 0,25'lik drift kesir olarak hedefte birikir ve moral
		# ancak fark yarım puanı geçince kımıldar. Zorlamak drift'i dört katına çıkarırdı.
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
static func apply_delta(emp: Character, delta: int, _reason: String) -> void:
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


## "İZİNDE · N gün kaldı" satırı için; işteyken 0.
static func days_until_return(emp: Character) -> int:
	if emp == null or emp.status != HRConstants.STATUS_ON_LEAVE:
		return 0
	return maxi(emp.leave_until_day - GameState.day, 0)


## Bu kişi için bekleyen bir istifa kartı var; HRActions bu sürede kart eylemlerini reddeder.
static func has_pending_departure(character_id: String) -> bool:
	return _pending.has(character_id)


# ============================================================================
#  İzin ve ayrılış seam'leri
# ============================================================================

## on_leave'e tek kapı. Ücretli izin: maaş akar (maaş toplamı durumla süzülmez), katkı durur.
static func send_on_leave(emp: Character, days: int, is_manual: bool) -> void:
	if emp == null or emp.category != "employee" or days <= 0:
		return
	if emp.status == HRConstants.STATUS_ON_LEAVE:
		return   # süren izin yeniden başlatılmaz
	CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ON_LEAVE)
	emp.leave_until_day = GameState.day + days
	# Manuel tatil de o yılın iznini tüketir (§11.4); yoksa dönüş bonusu her hafta tekrarlanabilirdi.
	emp.leave_taken_year = int(GameState.get_date_dict().year)
	GameState.set_flag(FLAG_MANUAL_LEAVE_PREFIX + emp.id, is_manual)
	# Kimse izni ONAYLAMAZ (§11.4): modal değil ticker satırı.
	if is_manual:
		EventBus.headline_added.emit(HRConstants.notice_source_hr(), TranslationServer.translate("HR_NEWS_ON_HOLIDAY").format({"name": emp.character_name, "n": days}))
	else:
		EventBus.headline_added.emit(HRConstants.notice_source_hr(), TranslationServer.translate("HR_NEWS_ON_LEAVE_MONTH").format({"name": emp.character_name}))


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
		apply_delta(other, -(HRConstants.MORALE_FIRE_TEAM + int(round(absf(extra)))), HRConstants.REASON_TEAMMATE_FIRED)


## Ayrılanın HR tarafı latch'lerini temizler. confirm_departure ve HRActions.fire,
## CharacterRegistry.remove'dan ÖNCE çağırır.
static func forget_employee(character_id: String) -> void:
	if character_id == "":
		return
	_pending.erase(character_id)
	GameState.set_flag(FLAG_MANUAL_LEAVE_PREFIX + character_id, false)


## GameState.initialize_run run_seed atandıktan SONRA çağırır. Yüklemede
## SaveCodec.restore_systems RngStreams.from_dict'i bundan sonra koşar ve kayıtlı konumu geri yükler.
static func reset_rng() -> void:
	RngStreams.reseed(GameState.run_seed)
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

## Kaçma riski ihmal edilirse istifa (§11.3). Ucuz tamsayı testleri RNG'den önce: sağlıklı
## bir ekip hiç çekiliş tüketmez.
static func _maybe_resign(emp: Character) -> void:
	if emp.flight_risk_days < HRConstants.RESIGN_WINDOW_MIN_DAYS or _pending.has(emp.id):
		return
	var chance: float = HRConstants.resign_chance(emp.traits)
	# Pencerenin üst ucu kesinliktir: sonsuz roll kalıcı bir kırmızı rozetle arafta kalan
	# biri bırakırdı. "İki hafta ihmal" oyuncunun öğrenebileceği bir kural olur.
	if emp.flight_risk_days >= HRConstants.RESIGN_WINDOW_MAX_DAYS:
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
