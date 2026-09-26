extends Node

# Karakter kaydı: çalışanlar, kurucu, mentor ve NPC'ler için tek doğruluk kaynağı.
# WRITE-THROUGH LAW: Character alanlarını bu dosyanın dışında kimse yazmaz; değişiklikler
# buradaki seam'lerden geçer ve UI'nin dinlediği yerde EventBus'a yayılır.
#
# Tik etkileşimi çekme desenidir: HRSystem çalışanları okuyup set_morale ile yazar,
# FinanceSystem get_total_monthly_salaries'i çeker.
#
# Adlandırma: get_character (get değil) — `Object.get(prop)` ayrılmış ve gölgelemek sinsi hata üretir.

var _characters: Dictionary = {}  # id (String) -> Character


# --- Okuma ---

func get_character(id: String) -> Character:
	return _characters.get(id, null)


func get_all() -> Array[Character]:
	var out: Array[Character] = []
	for c in _characters.values():
		out.append(c)
	return out


## İzinde olsun olmasın HER çalışan: bordro, moral, ekip sayısı ve bütün gösterim yüzeyleri
## (izindeki kişi hâlâ ekiptedir). İŞİ ölçen her şey get_active_employees() okur.
func get_employees() -> Array[Character]:
	var out: Array[Character] = []
	for c in _characters.values():
		if c.category == "employee":
			out.append(c)
	return out


## Şu an İŞBAŞINDA olan çalışanlar (status active). Kapasite, ekip hızı, SORUMLU seçimi ve
## CS churn sönümü bunu okur. Bordro (ücretli izin), moral, ekip sayısı, özsermaye ve VC ekip
## kontrolleri get_employees() okur: izindeki bir geliştirici şirketi tek kurucuya çevirmez.
func get_active_employees() -> Array[Character]:
	var out: Array[Character] = []
	for c in _characters.values():
		if c.category == "employee" and c.status == HRConstants.STATUS_ACTIVE:
			out.append(c)
	return out


# --- DENEYİM / EĞİTİM ---
# `trainings_done`, `training_days_left`, `training_area` ve `assigned_jobs` yalnız burada
# yazılır: defter satırı bu değerleri çiziyor ve HR sekmesi yapı anahtarıyla yeniden kuruluyor.

## Eğitime uygun mu? Edilgen olmayan çalışan ya da kurucu, deneyim barı dolu (§5.2) ve seçilen
## alan tavanın altında (§5.3). Tavandaki alana eğitim gönderilemez: ücreti alıp hiçbir şey
## vermemek olurdu. area_key "" = herhangi bir alanda eğitilebilir mi.
func can_train(id: String, area_key: String = "") -> bool:
	return training_block_reason_key(id, area_key) == ""


## §5.4: kilitli eylem gerekçesini gösterir ve iki gerekçe karıştırılmaz:
## bar dolmadı → HR_TRAINING_NOT_EARNED · alan 5,0 yıldızda → HR_TRAINING_AT_CAP.
## "" = kilit yok. Para bir kilit değil, bedeldir; bu listede yoktur.
func training_block_reason_key(id: String, area_key: String = "") -> String:
	var c: Character = _characters.get(id, null)
	if c == null or c.category not in ["employee", "founder"] \
			or c.status != HRConstants.STATUS_ACTIVE or not experience_bar_full(c):
		return "HR_TRAINING_NOT_EARNED"
	var keys: Array = HRConstants.trainable_keys() if area_key == "" else [area_key]
	for k in keys:
		var key: String = String(k)
		if HRConstants.is_trainable_key(key) and int(c.role_stats.get(key, 0)) < HRConstants.AREA_MAX:
			return ""
	return "HR_TRAINING_AT_CAP"


func training_block_reason(id: String, area_key: String = "") -> String:
	var key: String = training_block_reason_key(id, area_key)
	return "" if key == "" else tr(key)


# --- §5.1 DENEYİM: tek bar, büyüyen eşik ---

## Kişinin toplam gelişmişliği (altı alan + Liderlik ham puanı); eşiğin girdisi.
func total_skill_points(c: Character) -> int:
	var total: int = int(c.role_stats.get(HRConstants.SKILL_LEADERSHIP, 0))
	for area_key in HRConstants.AREAS:
		total += int(c.role_stats.get(String(area_key), 0))
	return total


## Eşik saklanır ve her yıldız değişiminde yeniden hesaplanır, her çizimde değil.
func refresh_experience_threshold(c: Character) -> void:
	c.experience_threshold = HRConstants.experience_threshold(total_skill_points(c))


func experience_bar_full(c: Character) -> bool:
	if c.experience_threshold <= 0:
		refresh_experience_threshold(c)
	return c.experience_raw >= c.experience_threshold


## Barın 0–1 doluluğu (Kadro'nun DENEYİM sütunu, Kişisel'in çubuğu).
func experience_ratio(c: Character) -> float:
	if c == null or c.experience_threshold <= 0:
		return 0.0
	return clampf(float(c.experience_raw) / float(c.experience_threshold), 0.0, 1.0)


## §5.1: bar dolar ve orada durur; deneyim kendiliğinden yıldıza dönüşmez, tek çıkışı eğitim.
## Dolduğu an bir kez yayar (§15.3 KENAR), her gün değil.
func add_experience(id: String, amount: int) -> void:
	var c: Character = _characters.get(id, null)
	if c == null or amount <= 0:
		return
	var was_full: bool = experience_bar_full(c)
	c.experience_raw = mini(c.experience_raw + amount, c.experience_threshold)
	if not was_full and c.experience_raw >= c.experience_threshold:
		EventBus.employee_experience_changed.emit(id, c.experience_raw)
		EventBus.experience_bar_full.emit(id)


## §5.3: bedel yalnız hedef alanın mevcut seviyesine göre kademelenir.
func training_fee_for(id: String, area_key: String) -> int:
	var c: Character = _characters.get(id, null)
	if c == null:
		return HRConstants.TRAINING_FEE_BASE
	return HRConstants.training_fee_tiered(int(c.role_stats.get(area_key, 0)))


## Eğitimi başlatır. Ücreti tahsil etmez: çağıran (HRSystem.send_to_training) Finance'ten geçirir.
func begin_training(id: String, area_key: String) -> void:
	var c: Character = _characters.get(id, null)
	if c == null:
		push_warning("[CharacterRegistry] begin_training on unknown id: %s" % id)
		return
	if not HRConstants.is_trainable_key(area_key):
		push_error("[CharacterRegistry] begin_training with an untrainable target: '%s'" % area_key)
		return
	c.training_days_left = HRConstants.TRAINING_DAYS
	c.training_area = area_key
	c.status = HRConstants.STATUS_TRAINING
	EventBus.employee_training_changed.emit(id, c.training_days_left)
	EventBus.training_started.emit(id, area_key)


## Bir eğitim gününü işler. `true` yalnız eğitim BİTTİYSE döner; haber satırını çağıran atar.
func tick_training(id: String) -> bool:
	var c: Character = _characters.get(id, null)
	if c == null or c.training_days_left <= 0:
		return false
	c.training_days_left -= 1
	if c.training_days_left > 0:
		EventBus.employee_training_changed.emit(id, c.training_days_left)
		return false
	var area_key: String = c.training_area
	if HRConstants.is_trainable_key(area_key):
		# §5.2: seçilen alanda +½ yıldız (= +1 ham puan), deneyim barı sıfırlanır ve eşik
		# yeniden hesaplanır — kişi geliştiği için sonraki bar daha uzun sürer.
		var cur: int = int(c.role_stats.get(area_key, 0))
		c.role_stats[area_key] = mini(cur + 1, HRConstants.AREA_MAX)
		c.trainings_done[area_key] = int(c.trainings_done.get(area_key, 0)) + 1
		c.experience_raw = 0
		refresh_experience_threshold(c)
		c.employment_history.append({
			"day": GameState.day, "kind": "training", "old": cur, "new": int(c.role_stats[area_key]),
		})
	c.training_area = ""
	c.status = HRConstants.STATUS_ACTIVE
	EventBus.employee_training_changed.emit(id, 0)
	EventBus.employee_experience_changed.emit(id, 0)
	EventBus.training_completed.emit(id, area_key)
	return true


# --- §12.0 İŞ ATAMASI: tek yazıcı ---

## İşe atar; "" = kabul, aksi hâlde ret gerekçesi. §12.1 tavanı burada uygulanır (arayüz
## kilidi aynı sabiti okur, ama kapı buradadır).
##
## Ar-Ge §5.0 "bir kişi, bir etkinlik": yeni iş çakıştığı işleri reddetmez, DURAKLATIR.
## Duraklamış iş `paused_job_ids`'te bekler ve dışlayıcı etkinlik bitince geri döner.
func assign_job(id: String, job_id: String) -> String:
	var c: Character = _characters.get(id, null)
	if c == null:
		return "unknown"
	if not HRConstants.is_job(job_id):
		push_error("[CharacterRegistry] assign_job with an unknown job: '%s'" % job_id)
		return "unknown_job"
	if c.assigned_job_ids.has(job_id):
		return ""
	if c.status != HRConstants.STATUS_ACTIVE:
		return "inactive"
	if not HRConstants.can_hold_job(c.role, job_id, c.category):
		return "not_your_job"

	# Tavan yalnız SÜREKLİ işleri sayar (aktif + duraklamış) ve yerinden etmeden ÖNCE sayılır;
	# yoksa arkasından gelen duraklatma §12.1'in tavanını eritirdi. Araştırma slot tutmaz ve
	# hiç reddedilmez: kişinin tamamını alır, sürekli işleri duraklatır.
	if HRConstants.is_continuous_job(job_id) and not c.paused_job_ids.has(job_id):
		var slots: int = 0
		for held in c.assigned_job_ids + c.paused_job_ids:
			if HRConstants.is_continuous_job(String(held)):
				slots += 1
		if slots >= HRConstants.MAX_JOBS_PER_PERSON:
			return "job_cap"

	# Yer değiştiren tek şey araştırmadır, iki yönde de: dışlayıcı iş gelirse bütün işler
	# duraklar; sürekli iş gelirse tutulan araştırma biter (düğüm donar, ilerleme korunur).
	# İki sürekli iş birlikte koşar (odak bölünür); kurucu istisnası yoktur.
	var displaced: Array[String] = []
	if HRConstants.is_exclusive_job(job_id):
		displaced = c.assigned_job_ids.duplicate()
	else:
		for held in c.assigned_job_ids:
			if HRConstants.is_exclusive_job(String(held)):
				displaced.append(String(held))
	var ended_exclusive := false
	for d in displaced:
		if HRConstants.is_exclusive_job(d):
			ended_exclusive = true
		_displace_job(c, d)

	# Araştırma hangi yoldan biterse bitsin duraklamış işler geri döner (Ar-Ge §5.0); yoksa
	# araştırmadan doğrudan yapıma dönen birinin desteği defterde sessizce park kalırdı.
	if ended_exclusive:
		resume_paused_jobs(id)
		if c.assigned_job_ids.has(job_id):
			return ""   # istenen iş zaten geri geldi; resume senkronunu ve sinyalini attı

	c.paused_job_ids.erase(job_id)   # duraklamış bir işe dönmek yeni bir iş değildir
	c.assigned_job_ids.append(job_id)
	_sync_area_mirror(c)
	EventBus.assignment_changed.emit(id)
	return ""


## Yerinden edilen iş: araştırma deftere park edilmez — kişi düğümden iner, düğüm ilerlemesi
## korunarak donar (Ar-Ge §5.7) ve notu "Ekip yapımda." olur. Sürekli iş deftere park edilir.
func _displace_job(c: Character, job_id: String) -> void:
	c.assigned_job_ids.erase(job_id)
	if HRConstants.is_exclusive_job(job_id):
		RnDSystem.drop_assignee(c.id, "RND_PAUSED_BUILD")
		return
	if not c.paused_job_ids.has(job_id):
		c.paused_job_ids.append(job_id)


## Ar-Ge §5.0: dışlayıcı iş bitince duraklamış işler geri döner. Sürekli slot tavanı burada
## da geçerlidir; sığmayan defterde bekler. Idempotent, tek sinyal.
func resume_paused_jobs(id: String) -> void:
	var c: Character = _characters.get(id, null)
	if c == null or c.paused_job_ids.is_empty():
		return
	var slots: int = 0
	for held in c.assigned_job_ids:
		if HRConstants.is_continuous_job(String(held)):
			slots += 1
	var still_parked: Array[String] = []
	var resumed := false
	for job_id in c.paused_job_ids:
		if c.assigned_job_ids.has(job_id):
			continue
		if HRConstants.is_continuous_job(job_id):
			if slots >= HRConstants.MAX_JOBS_PER_PERSON:
				still_parked.append(job_id)
				continue
			slots += 1
		c.assigned_job_ids.append(job_id)
		resumed = true
	c.paused_job_ids = still_parked
	if not resumed:
		return
	_sync_area_mirror(c)
	EventBus.assignment_changed.emit(id)


func unassign_job(id: String, job_id: String) -> void:
	var c: Character = _characters.get(id, null)
	if c == null or not c.assigned_job_ids.has(job_id):
		return
	c.assigned_job_ids.erase(job_id)
	_sync_area_mirror(c)
	EventBus.assignment_changed.emit(id)
	# Dışlayıcı iş masadan kalktığı an duraklamış işler döner. Sıra bilinçli: resume kendi
	# sinyalini atar, dinleyiciler son hâli okur.
	if HRConstants.is_exclusive_job(job_id):
		resume_paused_jobs(id)


## §11.3: kişinin işleri boşalır, otomatik devir yok. Duraklamış defter de silinir (dönecek
## kimse kalmadıysa geri dönüş sözü de kalmaz) ve kişi araştırmadan düşürülür.
func clear_jobs(id: String) -> void:
	var c: Character = _characters.get(id, null)
	if c == null or (c.assigned_job_ids.is_empty() and c.paused_job_ids.is_empty()):
		return
	c.assigned_job_ids.clear()
	c.paused_job_ids.clear()
	RnDSystem.drop_assignee(id)
	_sync_area_mirror(c)
	EventBus.assignment_changed.emit(id)


## `assigned_jobs` alan aynasının tek yazıcısı: işlerden türetilir.
func _sync_area_mirror(c: Character) -> void:
	c.assigned_jobs.clear()
	for area_id in HRConstants.areas_for_jobs(c.role, c.category, c.assigned_job_ids):
		c.assigned_jobs.append(String(area_id))


## ALAN adaptörü: alanı birincil işine çevirip assign_job'a delege eder, kapıların hepsi
## orada. "" = kabul.
func assign_area(id: String, area_id: String) -> String:
	if _characters.get(id, null) == null:
		return "unknown"
	if not HRConstants.is_assignable(area_id):
		push_error("[CharacterRegistry] assign_area with an unknown area: '%s'" % area_id)
		return "unknown_area"
	var job_id: String = HRConstants.primary_job_for_area(area_id)
	if job_id == "":
		return "unknown_area"
	var refusal: String = assign_job(id, job_id)
	return "not_your_area" if refusal == "not_your_job" else refusal


func unassign_area(id: String, area_id: String) -> void:
	var job_id: String = HRConstants.primary_job_for_area(area_id)
	if job_id != "":
		unassign_job(id, job_id)


func clear_areas(id: String) -> void:
	clear_jobs(id)


# --- Sayımlar ---

## Müşteri Temsilcisi: category "employee", rolüyle ayrılır. İzin DAHİL (bordro merceği).
func get_customer_reps() -> Array[Character]:
	var out: Array[Character] = []
	for c in get_employees():
		if c.role == HRConstants.ROLE_CUSTOMER_REP:
			out.append(c)
	return out


func count_customer_reps() -> int:
	return get_customer_reps().size()


## İŞ merceği: bir roldeki işbaşındaki herkes, masalar sıralasın diye id'ye göre sıralı.
func get_active_by_role(role_id: String) -> Array[Character]:
	var out: Array[Character] = []
	for c in get_active_employees():
		if c.role == role_id:
			out.append(c)
	out.sort_custom(func(a: Character, b: Character) -> bool: return a.id < b.id)
	return out


func count_active_by_role(role_id: String) -> int:
	var n: int = 0
	for c in get_active_employees():
		if c.role == role_id:
			n += 1
	return n


## İzin DAHİL bütün geliştiriciler (VC ekip alanı: "şirketin mühendisi var mı").
func count_developers() -> int:
	var n: int = 0
	for c in get_employees():
		if c.role == HRConstants.ROLE_DEVELOPER:
			n += 1
	return n


func count_active_developers() -> int:
	return count_active_by_role(HRConstants.ROLE_DEVELOPER)


func count_employees() -> int:
	return get_employees().size()


func count_on_leave() -> int:
	var n: int = 0
	for c in get_employees():
		if c.status == HRConstants.STATUS_ON_LEAVE:
			n += 1
	return n


func get_mentor() -> Character:
	for c in _characters.values():
		if c.category == "mentor":
			return c
	return null


## Oyuncu avatarı; GameState.initialize_run yazar, ondan önce null.
func get_founder() -> Character:
	for c in _characters.values():
		if c.category == "founder":
			return c
	return null


## GameState.initialize_run çağırır; idempotent. Doğrudan eklenir (add() değil), sistemin
## kurduğu mentor için character_added yayılmaz; UI fixture'ları get_mentor()'ı _ready'de okur.
func ensure_mentor() -> void:
	if get_mentor() != null:
		return
	var m := Character.new()
	m.id = "char_mentor_frank"
	m.character_name = TranslationServer.translate("MENTOR_NAME")
	m.role = HRConstants.ROLE_MENTOR
	m.category = "mentor"
	m.monthly_salary = 0
	m.morale = 50
	# Portre politikası (GDD 14 §7): çalışanlar baş harfle, Frank portresiyle çizilir.
	m.portrait_path = "res://assets/art/investors/portrait_frank.webp"
	_characters[m.id] = m


## Bordro yalnız çalışanlardan. Durum süzülmez: yıllık izin ÜCRETLİDİR (§11.4); iznin bedeli
## kaybolan kapasitedir, kazanılan maaş değil.
func get_total_monthly_salaries() -> int:
	var total: int = 0
	for c in get_employees():
		total += c.monthly_salary
	return total


# --- Yazma ---

func add(character: Character) -> void:
	if character == null or character.id == "":
		push_warning("[CharacterRegistry] add() called with null or missing id")
		return
	if _characters.has(character.id):
		push_warning("[CharacterRegistry] add() id collision: %s" % character.id)
		return
	_validate_shape(character)
	if character.category == "employee":
		# İstihdam damgaları hire akışında değil BURADA: olayla gelen işe alım da alır.
		# HRSearchSystem.hire() hire_day'i hemen ardından GameState.day + 1'e yeniden damgalar
		# (işe alınan ertesi gün başlar); bu bilinçli.
		character.hire_day = GameState.day
		# §12.2: atanmamış kişi boşta durur ve maaş yer; yeni işe alınan kendi ana işine düşer.
		if character.assigned_job_ids.is_empty():
			var default_job: String = HRConstants.default_job_for_role(character.role)
			if default_job != "":
				character.assigned_job_ids.append(default_job)
		_sync_area_mirror(character)
		refresh_experience_threshold(character)
		if character.salary_floor <= 0:
			character.salary_floor = character.monthly_salary
		# §11.4 yaz izni haftası; işe alım sırası izinleri haftalara yayar.
		if character.leave_week < 0:
			character.leave_week = HRConstants.leave_week_for(GameState.run_hires)
		GameState.run_hires += 1
	_characters[character.id] = character
	EventBus.character_added.emit(character.id)
	if character.category == "employee":
		EventBus.employee_hired.emit(character.id)


## Engellemeyen şekil kontrolü: karakter yine eklenir, kusur log'a düşer. get_founder_skill
## bilinmeyen anahtar için sessizce 0 döndüğü ve save_codec bilinmeyen anahtarı düşürdüğü için
## yarım göçmüş bir kayıt aksi hâlde sessiz kalırdı.
func _validate_shape(character: Character) -> void:
	if HRConstants.has_retired_skill_key(character.role_stats):
		push_error("[CharacterRegistry] '%s' still carries a RETIRED skill key %s: %s"
			% [character.id, str(HRConstants.RETIRED_SKILL_KEYS), str(character.role_stats)])
	if character.category == "employee":
		if not HRConstants.is_employee_role(character.role):
			push_error("[CharacterRegistry] employee '%s' has non-employee role '%s' — see HRConstants.EMPLOYEE_ROLES"
				% [character.id, character.role])
		if not HRConstants.validate_employee_skills(character.role_stats):
			push_error("[CharacterRegistry] employee '%s' role_stats must hold EXACTLY %s on 0-%d: %s"
				% [character.id, str(HRConstants.EMPLOYEE_SKILL_KEYS), HRConstants.AREA_MAX, str(character.role_stats)])
		if not HRConstants.validate_employee_traits(character.traits):
			push_error("[CharacterRegistry] employee '%s' traits failed the employee trait formula: %s"
				% [character.id, str(character.traits)])
	elif character.category == "founder":
		var keys: Array = character.role_stats.keys()
		if keys.size() != FounderConstants.SKILLS.size():
			push_error("[CharacterRegistry] founder role_stats must hold EXACTLY the %d canonical skills: %s"
				% [FounderConstants.SKILLS.size(), str(keys)])
		for skill_key in FounderConstants.SKILLS:
			if not character.role_stats.has(skill_key):
				push_error("[CharacterRegistry] founder role_stats missing skill '%s'" % skill_key)
	# AREAS dışındaki bir alan id'si her okuma seam'inin kişiyi sessizce atlamasına yol açardı.
	for area_id in character.assigned_jobs:
		if not HRConstants.is_assignable(area_id):
			push_error("[CharacterRegistry] '%s' assigned to unknown area '%s' — see HRConstants.AREAS"
				% [character.id, area_id])
		elif not HRConstants.can_hold_area(character.role, area_id, character.category):
			push_error("[CharacterRegistry] '%s' (%s) assigned to '%s', which is neither their key nor their secondary area"
				% [character.id, character.role, area_id])
	# §2.1 "Her şeyi yapabilir, aynı anda yapamaz": kurucunun kilidi İŞ sayısındadır. Alan aynası
	# meşru biçimde daha geniştir (Build'deki kurucu üç alanda görünür).
	if character.category == "founder" and character.assigned_job_ids.size() > 1:
		push_error("[CharacterRegistry] founder holds %d jobs — §2.1 allows exactly one"
			% character.assigned_job_ids.size())


## YALNIZ KAYIT GERİ YÜKLEME. add() yanlış kapıdır: hire_day'i bugüne damgalar, run_hires'ı
## artırır ve henüz ağaçta olmayan bir kabuğa character_added yayar. Şekil kontrolü yine koşar.
func insert_raw(character: Character) -> void:
	if character == null or character.id == "":
		push_warning("[CharacterRegistry] insert_raw() called with null or missing id")
		return
	_validate_shape(character)
	_characters[character.id] = character


## §11.3 ayrılış. Kişiyi araştırmadan RnDSystem kendi günlük budamasıyla düşürür.
func remove(id: String) -> void:
	var c: Character = _characters.get(id, null)
	if c == null:
		return
	if c.category == "employee":
		GameState.run_departures += 1
	_characters.erase(id)
	EventBus.character_removed.emit(id)
	EventBus.employee_departed.emit(id)


## Onboarding yeniden tetiklenince kadroyu boşaltır. Sinyalsiz: kabuk da birlikte yıkılıyor.
func reset() -> void:
	_characters.clear()


## Maaş seam'i (HRActions.apply_raise). Sinyal yok: Finance bordroyu her gün çeker.
func set_salary(id: String, value: int) -> void:
	var c: Character = _characters.get(id, null)
	if c == null:
		push_warning("[CharacterRegistry] set_salary on unknown id: %s" % id)
		return
	c.monthly_salary = maxi(value, 0)


## İstihdam durumu seam'i: kapasite, ekip hızı, SORUMLU listesi, CS sönümü ve mesai `status`
## okur; tek yerden yazılmalı.
func set_status(id: String, value: String) -> void:
	var c: Character = _characters.get(id, null)
	if c == null:
		push_warning("[CharacterRegistry] set_status on unknown id: %s" % id)
		return
	if value not in [HRConstants.STATUS_ACTIVE, HRConstants.STATUS_ON_LEAVE, HRConstants.STATUS_TRAINING]:
		push_error("[CharacterRegistry] unknown employee status '%s' for %s" % [value, id])
		return
	c.status = value


## Sınırlar HRConstants'ta adlıdır ve önizleme de onları okur (§15.2). Band KENARI ayrıca
## yayılır (§15.3): motorun sorusu "moral kaç" değil "hangi banda düştü".
func set_morale(id: String, value: int) -> void:
	var c: Character = _characters.get(id, null)
	if c == null:
		push_warning("[CharacterRegistry] set_morale on unknown id: %s" % id)
		return
	var clamped: int = clampi(value, HRConstants.MORALE_MIN, HRConstants.MORALE_MAX)
	if c.morale == clamped:
		return
	var band_before: String = HRConstants.morale_band_id(c.morale)
	c.morale = clamped
	EventBus.morale_changed.emit(id, clamped)
	var band_after: String = HRConstants.morale_band_id(clamped)
	if band_after != band_before:
		EventBus.morale_band_changed.emit(id, band_after)
