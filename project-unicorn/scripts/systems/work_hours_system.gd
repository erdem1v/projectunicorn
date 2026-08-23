class_name WorkHoursSystem
extends RefCounted

# ÇALIŞMA SAATLERİ — GDD Ekip §8. Pure-logic system, no scene, no instance.
#
# ÜÇ KAPSAM, TEK ÇÖZÜMLEYİCİ. §8.1: çalışma süresi tek bir şirket ayarı değildir.
#
#   kişinin çalışma saati = çalışan istisnası ?? grubunun istisnası ?? şirket değeri
#
# Bu zincir YALNIZ `hours_for()` içinde yürür. §15.2 bunu bir tek-kaynak kuralı olarak
# yazıyor: "Hiçbir sistem 'çalışan istisnası ?? grup ?? şirket' sırasını kendisi yürütmez;
# hr.work_hours(kişi) çağırır." Bir yerde daha yürütülürse iki cevap doğar ve önizleme ile
# tahakkuk ayrışır — bu modülün geçmişinde tam olarak bu şekilde bir yalan üretilmişti.
#
# NEDEN ÜÇ KAPSAM: ek mesai ücreti de moral çarpanı da KİŞİ BAŞINA işler. Tek bir şirket
# ayarı oyuncuyu bütün ekibi aynı anda yakmaya ya da aynı anda dinlendirmeye zorlardı.
# Üç kapsam gerçek bir triyaj yaratır — beta sırasında test ekibini crunch'a sokup
# geliştiricileri normalde tutmak, sürüm sonrası destek masasını kısa güne çekip morali
# toparlamak. Karar bir kadran değil, bir KADRO kararıdır.
#
# BAŞLANGIÇ SAATİ YALNIZ ŞİRKET KAPSAMINDADIR (§8.1). Grup ve çalışan yalnız SÜREYİ
# değiştirir: ofis tek saatte açılır, değişen kimin ne zaman çıktığıdır.
#
# EK MESAİ AYRI BİR MEKANİK DEĞİLDİR (§8.2). Aşan saatler bu modelin bir SONUCUDUR; ayrı
# bir buton, blok ya da hız bonusu yoktur. Eski departman-bazlı blok sistemi hâlâ ağaçta
# ve tüketicileri Faz 3'te buraya çevrilecek (planın 2a-bis silme tablosu).


# ============================================================================
#  Çözümleme — §8.1
# ============================================================================

## Kişinin BUGÜN devraldığı günlük saat. Zincirin tek evi.
static func hours_for(c: Character) -> int:
	if c == null:
		return GameState.company_work_hours
	# §2: kurucu şirket çalışma saatini devralır ve İSTİSNA ALAMAZ. Morali olmadığı için
	# kişisel bir istisna hiçbir şey ifade etmez; çıktısı zaten şirket saatiyle orantılı
	# değişir. Çalışma saatleri modalinde de görünmez (§8.5).
	if c.category == "founder":
		return _clamp_hours(GameState.company_work_hours)
	if c.work_hours_override > 0:
		return _clamp_hours(c.work_hours_override)
	var group_id: String = group_of(c)
	if group_id != "" and GameState.group_work_hours_override.has(group_id):
		return _clamp_hours(int(GameState.group_work_hours_override[group_id]))
	return _clamp_hours(GameState.company_work_hours)


## Bir satırın değeri DEVRALINMIŞ mı yoksa KARAR mı — §8.5'in devir dili buradan okunur:
## "Üstünden devralan satır değerini soluk gösterir; istisna taşıyan satır dolu gösterir."
static func person_has_override(c: Character) -> bool:
	return c != null and c.category != "founder" and c.work_hours_override > 0


static func group_has_override(group_id: String) -> bool:
	return GameState.group_work_hours_override.has(group_id)


## Devralınan değerin KAYNAĞI — §8.5'in KAYNAK sütunu. "" = kendi kararı.
static func inherited_from(c: Character) -> String:
	if c == null or person_has_override(c):
		return ""
	var group_id: String = group_of(c)
	if c.category != "founder" and group_id != "" and group_has_override(group_id):
		return "group"
	return "company"


static func group_of(c: Character) -> String:
	if c == null:
		return ""
	return String(HRConstants.ROLE_GROUP.get(c.role, ""))


static func start_hour() -> int:
	return clampi(GameState.company_start_hour, HRConstants.START_HOUR_MIN, HRConstants.START_HOUR_MAX)


## Bitiş = başlangıç + kişinin devraldığı süre (§8.1). Gün taşması modulo ile sarılır —
## 11:00 başlayan 11 saatlik bir gün 22:00'de biter, taşma yok, ama tavan ikisi de 11 olduğu
## için 24'ü geçmesi mümkün değil; yine de sarma bir sonraki kalibrasyona karşı ucuz sigorta.
static func end_hour_for(c: Character) -> int:
	return (start_hour() + hours_for(c)) % 24


static func _clamp_hours(hours: int) -> int:
	return clampi(hours, HRConstants.WORK_HOURS_MIN, HRConstants.WORK_HOURS_MAX)


# ============================================================================
#  Durum okumaları — §8.2 / §8.3 / §15.3
# ============================================================================

static func overtime_active(c: Character) -> bool:
	return HRConstants.is_overtime_hours(hours_for(c))


static func short_day_active(c: Character) -> bool:
	return HRConstants.is_short_day_hours(hours_for(c))


## §8.5 başlık çipi: şirketten ayrılan KAPSAM sayısı (grup istisnaları + kişi istisnaları).
static func override_count() -> int:
	var n: int = GameState.group_work_hours_override.size()
	for c in CharacterRegistry.get_employees():
		if person_has_override(c):
			n += 1
	return n


## §8.5 bedel listesinin OLGU satırı: kaç çalışan mesaide, kaç çalışan kısa günde.
## Kurucu sayılmaz — bordroda değil ve modalde görünmüyor (§2).
static func counts() -> Dictionary:
	var over: int = 0
	var short_day: int = 0
	for c in CharacterRegistry.get_active_employees():
		var h: int = hours_for(c)
		if HRConstants.is_overtime_hours(h):
			over += 1
		elif HRConstants.is_short_day_hours(h):
			short_day += 1
	return {"overtime": over, "short_day": short_day}


# ============================================================================
#  Yazma — §8.1 devralma kuralları
# ============================================================================

static func set_company_hours(hours: int) -> void:
	GameState.company_work_hours = _clamp_hours(hours)
	EventBus.assignment_changed.emit("")


static func set_company_start_hour(hour: int) -> void:
	GameState.company_start_hour = clampi(hour, HRConstants.START_HOUR_MIN, HRConstants.START_HOUR_MAX)
	EventBus.assignment_changed.emit("")


## Bir grup istisnası, o gruba SONRADAN KATILAN herkesi de kapsar (§8.1) — bu, istisnanın
## kişide değil grupta saklanmasının doğrudan sonucu ve bedava gelir.
static func set_group_hours(group_id: String, hours: int) -> void:
	if not HRConstants.ROSTER_GROUPS.has(group_id):
		push_error("[WorkHoursSystem] unknown roster group: '%s'" % group_id)
		return
	GameState.group_work_hours_override[group_id] = _clamp_hours(hours)
	EventBus.assignment_changed.emit("")


## §8.1 "İstisna geri alınabilir; geri alınınca satır üstünü devralmaya döner."
static func clear_group_hours(group_id: String) -> void:
	GameState.group_work_hours_override.erase(group_id)
	EventBus.assignment_changed.emit("")


## Kişisel istisna. §8.1: "Rolü değişen ve grup değiştiren çalışanın kişisel istisnası
## KENDİSİYLE TAŞINIR" — istisna kişide saklandığı için bu da bedava gelir.
static func set_person_hours(id: String, hours: int) -> void:
	var c: Character = CharacterRegistry.get_character(id)
	if c == null or c.category == "founder":
		return
	c.work_hours_override = _clamp_hours(hours)
	EventBus.assignment_changed.emit(id)


static func clear_person_hours(id: String) -> void:
	var c: Character = CharacterRegistry.get_character(id)
	if c == null:
		return
	c.work_hours_override = 0
	EventBus.assignment_changed.emit(id)


## §8.1 / §8.5 "Tümünü şirkete eşitle bütün istisnaları temizler."
static func equalise_all() -> void:
	GameState.group_work_hours_override.clear()
	for c in CharacterRegistry.get_employees():
		c.work_hours_override = 0
	EventBus.assignment_changed.emit("")


# ============================================================================
#  Para — §8.2
# ============================================================================

## Bir çalışanın BUGÜNKÜ ek mesai tahakkuku. §8.6: izindeki ya da eğitimdeki çalışan
## üretmez ve ÜCRETLENDİRİLMEZ — "Şirket 11 saatteyken izne çıkan bir çalışan mesai ücreti
## almaz." Kurucuya da ödenmez: bordroda yer almaz (§9.1).
static func overtime_pay_today(c: Character) -> int:
	if c == null or c.category != "employee":
		return 0
	if c.status != HRConstants.STATUS_ACTIVE:
		return 0
	return HRConstants.overtime_pay_for_day(c.monthly_salary, hours_for(c))


## Finans'ın slot 5'te ÇEKTİĞİ toplam. HR itmez, Finans çeker — tek yönlü, tek kaynak.
static func overtime_pay_accrued_today() -> int:
	var total: int = 0
	for c in CharacterRegistry.get_active_employees():
		total += overtime_pay_today(c)
	return total


## §8.5 bedel listesinin DELTA satırı: bugünkü günlük burn ile verilen saat ayarındaki
## günlük burn. Maaş AYLIKTIR ve kısa gün onu düşürmez (§8.3) — değişen yalnız mesai
## tahakkuku, ve modal bunu açıkça yazar, yoksa oyuncu tasarruf bekler.
static func daily_overtime_at(hours_by_id: Dictionary) -> int:
	var total: int = 0
	for c in CharacterRegistry.get_active_employees():
		var h: int = int(hours_by_id.get(c.id, hours_for(c)))
		total += HRConstants.overtime_pay_for_day(c.monthly_salary, h)
	return total
