class_name WorkHoursSystem
extends RefCounted

# ÇALIŞMA SAATLERİ — GDD Ekip §8. Pure-logic system, no scene, no instance.
#
# ÜÇ KAPSAM, TEK ÇÖZÜMLEYİCİ. §8.1: çalışma süresi tek bir şirket ayarı değildir.
#
#   kişinin çalışma saati = çalışan istisnası ?? grubunun istisnası ?? şirket değeri
#
# Bu zincir YALNIZ `_resolve()` içinde yürür. §15.2: "Hiçbir sistem 'çalışan istisnası ??
# grup ?? şirket' sırasını kendisi yürütmez; hr.work_hours(kişi) çağırır." Bir yerde daha
# yürütülürse iki cevap doğar ve önizleme ile tahakkuk ayrışır.
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
# bir buton, blok ya da hız bonusu yoktur.


# ============================================================================
#  Çözümleme — §8.1
# ============================================================================

## ZİNCİRİN TEK GÖVDESİ. İki giriş var (canlı motor durumu · taahhüt edilmemiş modal
## taslağı) ama sıra yalnız burada yürür.
static func _resolve(company: int, group_hours: Variant, person_hours: int) -> int:
	if person_hours > 0:
		return _clamp_hours(person_hours)
	if group_hours != null:
		return _clamp_hours(int(group_hours))
	return _clamp_hours(company)


## Kişinin BUGÜN devraldığı günlük saat — CANLI giriş.
static func hours_for(c: Character) -> int:
	if c == null:
		return GameState.company_work_hours
	# §2: kurucu şirket çalışma saatini devralır ve İSTİSNA ALAMAZ. Morali olmadığı için
	# kişisel bir istisna hiçbir şey ifade etmez. Çalışma saatleri modalinde de görünmez (§8.5).
	if c.category == "founder":
		return _clamp_hours(GameState.company_work_hours)
	var group_id: String = group_of(c)
	return _resolve(GameState.company_work_hours,
		GameState.group_work_hours_override.get(group_id) if group_id != "" else null,
		c.work_hours_override)


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


## Bitiş = başlangıç + kişinin devraldığı süre (§8.1). Bugünkü tavanlarla 24'ü geçemez;
## modulo bir sonraki kalibrasyona karşı sigortadır.
static func end_hour_for(c: Character) -> int:
	return (start_hour() + hours_for(c)) % 24


## ŞİRKET PENCERESİ — tek ev (§15.2): kadro başlığındaki çip ve modalin Şirket satırı
## buradan okur. `hours`/`start` verilirse TAAHHÜT EDİLMEMİŞ bir taslak çizilir.
static func company_window(hours: int = -1, start: int = -1) -> Dictionary:
	var s: int = clampi(start, HRConstants.START_HOUR_MIN, HRConstants.START_HOUR_MAX) \
		if start >= 0 else start_hour()
	var e: int = (s + _clamp_hours(hours if hours >= 0 else GameState.company_work_hours)) % 24
	return {"start": s, "end": e, "start_text": "%02d:00" % s, "end_text": "%02d:00" % e}


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
	return override_count_in(draft_state())


## §8.5 bedel listesinin OLGU satırı: kaç çalışan mesaide, kaç çalışan kısa günde.
## Kurucu sayılmaz — bordroda değil ve modalde görünmüyor (§2).
static func counts() -> Dictionary:
	return counts_in(draft_state())


# ============================================================================
#  TAAHHÜT EDİLMEMİŞ TASLAK — §8.5 "maliyet TAAHHÜTTEN ÖNCE okunur"
# ============================================================================
# Modal taahhütlüdür: düzenlemeler yerel bir taslağa yazılır, `Uygula` onları motora
# geçirir, `Vazgeç` atar. Aşağıdakiler `_resolve`'u çağırır, yalnız girdiyi taslaktan alır.
#
# Taslak biçimi: {"company": int, "start": int, "groups": {gid: h}, "people": {id: h}}.
# `people` ve `groups` YALNIZ istisnaları taşır; bir anahtarın YOKLUĞU "devralıyor" demektir.


## Motorun bugünkü durumunun taslak biçimi. KOPYA döner — modal onu serbestçe düzenler.
static func draft_state() -> Dictionary:
	var people: Dictionary = {}
	for c in CharacterRegistry.get_employees():
		if person_has_override(c):
			people[c.id] = c.work_hours_override
	return {
		"company": _clamp_hours(GameState.company_work_hours),
		"start": start_hour(),
		"groups": GameState.group_work_hours_override.duplicate(true),
		"people": people,
	}


static func hours_in(st: Dictionary, c: Character) -> int:
	var company: int = int(st.get("company", GameState.company_work_hours))
	if c == null or c.category == "founder":
		return _clamp_hours(company)
	var group_id: String = group_of(c)
	var groups: Dictionary = st.get("groups", {}) as Dictionary
	var people: Dictionary = st.get("people", {}) as Dictionary
	return _resolve(company,
		groups.get(group_id) if group_id != "" else null,
		int(people.get(c.id, 0)))


static func person_has_override_in(st: Dictionary, c: Character) -> bool:
	return c != null and c.category != "founder" \
		and int((st.get("people", {}) as Dictionary).get(c.id, 0)) > 0


static func group_has_override_in(st: Dictionary, group_id: String) -> bool:
	return (st.get("groups", {}) as Dictionary).has(group_id)


## KAYNAK sütunu, taslaktan. "" = kendi kararı.
static func inherited_from_in(st: Dictionary, c: Character) -> String:
	if c == null or person_has_override_in(st, c):
		return ""
	var group_id: String = group_of(c)
	if group_id != "" and group_has_override_in(st, group_id):
		return "group"
	return "company"


static func override_count_in(st: Dictionary) -> int:
	return (st.get("groups", {}) as Dictionary).size() \
		+ (st.get("people", {}) as Dictionary).size()


static func counts_in(st: Dictionary) -> Dictionary:
	var over: int = 0
	var short_day: int = 0
	for c in CharacterRegistry.get_active_employees():
		var h: int = hours_in(st, c)
		if HRConstants.is_overtime_hours(h):
			over += 1
		elif HRConstants.is_short_day_hours(h):
			short_day += 1
	return {"overtime": over, "short_day": short_day}


## §8.5 bedel listesinin DELTA satırı: taslağın günlük mesai tahakkuku. Maaş AYLIKTIR ve
## kısa gün onu düşürmez (§8.3) — değişen yalnız mesai tahakkuku, ve modal bunu açıkça
## yazar, yoksa oyuncu tasarruf bekler.
static func daily_overtime_in(st: Dictionary) -> int:
	var total: int = 0
	for c in CharacterRegistry.get_active_employees():
		total += HRConstants.overtime_pay_for_day(c.monthly_salary, hours_in(st, c))
	return total


## `Uygula`. Taslağı motora TEK hamlede geçirir; yazıcıların hepsi kendi seam'leri
## (WRITE-THROUGH YASASI), yani sinyaller olması gerektiği gibi çıkar.
static func apply_state(st: Dictionary) -> void:
	set_company_start_hour(int(st.get("start", start_hour())))
	set_company_hours(int(st.get("company", GameState.company_work_hours)))
	var groups: Dictionary = st.get("groups", {}) as Dictionary
	for gid in HRConstants.ROSTER_GROUPS:
		var key: String = String(gid)
		if groups.has(key):
			set_group_hours(key, int(groups[key]))
		else:
			clear_group_hours(key)
	var people: Dictionary = st.get("people", {}) as Dictionary
	for c in CharacterRegistry.get_employees():
		if people.has(c.id):
			set_person_hours(c.id, int(people[c.id]))
		elif c.work_hours_override > 0:
			clear_person_hours(c.id)


# ============================================================================
#  Yazma — §8.1 devralma kuralları
# ============================================================================

static func set_company_hours(hours: int) -> void:
	GameState.company_work_hours = _clamp_hours(hours)
	EventBus.assignment_changed.emit("")


static func set_company_start_hour(hour: int) -> void:
	GameState.company_start_hour = clampi(hour, HRConstants.START_HOUR_MIN, HRConstants.START_HOUR_MAX)
	EventBus.assignment_changed.emit("")


## Bir grup istisnası, o gruba SONRADAN KATILAN herkesi de kapsar (§8.1) — istisna kişide
## değil grupta saklandığı için.
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
## KENDİSİYLE TAŞINIR" — istisna kişide saklandığı için.
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
## üretmez ve ÜCRETLENDİRİLMEZ. Kurucuya da ödenmez: bordroda yer almaz (§9.1).
static func overtime_pay_today(c: Character) -> int:
	if c == null or c.category != "employee" or c.status != HRConstants.STATUS_ACTIVE:
		return 0
	return HRConstants.overtime_pay_for_day(c.monthly_salary, hours_for(c))


## Finans'ın slot 5'te ÇEKTİĞİ toplam. HR itmez, Finans çeker — tek yönlü, tek kaynak.
static func overtime_pay_accrued_today() -> int:
	var total: int = 0
	for c in CharacterRegistry.get_active_employees():
		total += overtime_pay_today(c)
	return total
