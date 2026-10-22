class_name SupportSystem
extends RefCounted

# GDD — ÜRÜN MODÜLÜ rev 6.1 §8 (CANLI / DESTEK) + §9 (CANLI HATA AKIŞI MODELİ).
#
# Canlı ürünün kalıcı hâli: sprintler biter, DESTEK bitmez.
#
# GELEN BİLDİRİM (§8.1, MÜHÜRLÜ terim) doğrulanmamış kullanıcı bildirimidir ve kendiliğinden GELİR (§9).
# Doğrulanan her bildirim ürünün açık hata deposuna (ProductState) bir hata olarak düşer; açık hata
# kendiliğinden ÇÖZÜLMEZ. Asla. Modülün bütün gerilimi bu asimetride: akış otomatiktir, çözüm sprintin
# düzeltme kartıdır.
#
# MODÜL KENDİ KENDİNE TİKLEMEZ: `daily_tick()` ve `hourly_tick(hour)` TimeManager'dan
# çağrılır. Bayrak ADLARININ tek evi ProductState'tir; bu modül GELEN sayacının tek yazarıdır ama
# adı daima ProductState'in sabitinden alır.
#
# SAAT/GÜN AYRIMI (bir tik yedi takvim günüdür):
#   hourly_tick — AKIŞLAR. §9 bildirim akışı, §8.2 doğrulama.
#                 İkisi de GÜNLÜK oranlardır; saatlik tikte tikin yedi gününün 1/24'ü
#                 işlenir. Kesirli birikim *_PROGRESS bayraklarında durur, tam sayıya
#                 taşınca sayaç oynar. Sıra kasıtlı: bildirim gelir → doğrulanır.
#   daily_tick  — GÜNLÜK KESİNTİLER. §8.3 memnuniyet zararı ve §9 ilgi sönümü. İkisi
#                 de belgede açıkça "/gün" yazılıdır; zarar tavanı GÜNLÜK bir tavandır ve
#                 günlük değere uygulanır, tik yedi günü sonra alır. Haftalık hata ihmali kuralı
#                 (itibar) ve haftalık destek raporu da burada işler.

# ------------------------------------------------------ §9 canlı hata akışı
# gelen bildirim/gün = (0,1 + 0,03 × yeni_kod_eforu × e^(−sürüm_yaşı/3)) × kullanım_çarpanı
# Sürüm yaşı haftadır ve saat kesrini taşır. Açık hata akışı beslemez: hata yalnız kullanımdan ve
# yeni koddan doğar.
#
## §9 taban — "hiçbir ürün %100 hatasız değildir; akış asla sıfırlanmaz."
const INFLOW_BASE := 0.1
## Ar-Ge §4.3 `self_service` — aynı tabanın araştırılmış hâli. Akışı KISAR, kapatmaz.
const INFLOW_BASE_RESEARCHED := 0.07
## §9 yeni kod terimi — yeni sürümün efor büyüklüğüyle orantılı yeni havuz.
const INFLOW_NEWCODE_COEF := 0.03
## §9 "~3 haftada söner" — YALNIZ yeni kod terimi söner. Yeni sürüm sıfırdan havuz
## yaratmaz: olgun ürün altta durur, tazelenen tek şey bu terimdir. Birim hafta.
const INFLOW_TAU := 3.0
## §9 kullanım çarpanı: 1 + aktif kullanıcı/10000 (B2C) · 1 + hesap sayısı/80 (B2B). B2B'de aynı hatayı
## çok hesap bildirir, akış hesapla yavaş büyür.
const USAGE_DIV_B2C := 10000.0
const USAGE_DIV_B2B := 80.0

# ------------------------------------------------ §8.2 doğrulama (Müşteri İlişkileri)
## §8.2 — doğrulama/gün = 0,8 × Σ hr.effective_skill(atanan, Mİ) × saat/8.
const VALIDATION_COEF := 0.8
## Ar-Ge §4.3 `bug_tracker` — aynı katsayının araştırılmış hâli.
const VALIDATION_COEF_RESEARCHED := 1.0
## Herkes mail okur: her okurun (Destek'e atanan, pasif ilgideki kurucu, bu hafta sprint kartı olmayan
## çalışan) doğrulamaya katıldığı en düşük Müşteri İlişkileri puanı. Masaya atanmak kimseyi boştakinden
## yavaş yapmaz.
const SUPPORT_BASE_POINTS := 2.0
## Modelin dışında, taşma koruması: işlenecek kaynak kalmadığında birikim en fazla bir
## birim bankalanır. Sınırsız bankalansaydı boş bir masada biriken kesir, ilk gelen
## bildirimi geldiği saniye doğrulardı — §8.2'nin "masa kapalı" hükmünü delerdi.
const VALIDATION_BANK_MAX := 1.0

# ---------------------------------------------------------- §8.3 iki kademeli zarar
## §8.3 — doğrulanmamış birikim: memnuniyet −0,6/gün her 10 GELEN başına (en ağır zarar).
const DAMAGE_INCOMING_PER_TEN := -0.6
## §8.3 — doğrulanmış-açık: −0,3/gün her 10 başına (yarısı). Düzeltilmiş: sıfır.
## Hızlı yanıt alan kullanıcı, düzeltme gecikse bile hemen ayrılmaz.
const DAMAGE_CONFIRMED_PER_TEN := -0.3
const DAMAGE_PER_UNITS := 10.0
## §8.3 TAVAN: iki kademenin günlük TOPLAM zararı −2,0/gün ile sınırlı; tik başına −14. İhmal
## ölüm sarmalı değil, ağır ama toparlanabilir bir kanamadır.
const DAMAGE_DAILY_CAP := -2.0

# --------------------------------------------------------------- §8.5 ısınma
## §8.5 eşikler: GELEN < 20 sakin · 20-40 ılık · > 40 sıcak. Renk UI'nin sözlüğüdür.
const WARMTH_WARM_AT := 20
const WARMTH_HOT_AT := 40
const BAND_CALM := "calm"
const BAND_WARM := "warm"
const BAND_HOT := "hot"

# ------------------------------------------------------------------ §9 ilgi
## §9 — "her yayın ilgiyi 100'e tazeler; ilgi sürüm yaşıyla söner, yarı ömür 30 gün."
## Tazeleme ProductState.refresh_on_publish()'in işi; sönüm burada. Birim hafta; tam bölünür.
const INTEREST_HALF_LIFE := 30.0 / TimeModel.DAYS_PER_TICK

# ------------------------------------------------------- hata ihmali ve itibar
## Açık hata bu sayıya ya da üstüne varınca o haftalık tik ihmal sayılır.
const NEGLECT_BUGS := 30                # [ÇALIŞMA] onay bekliyor
## Üst üste bu kadar haftalık tikte ihmal sürerse itibar her hafta bir düşer (alt sınır GameState'in −10'u).
const NEGLECT_WEEKS := 4                # [ÇALIŞMA] onay bekliyor
## İtibar düşüşünün sebebi; ipucu bu CSV anahtarını son düşüşün tarihiyle okur.
const NEGLECT_REASON := "REP_DROP_BUGS"

const MARKET_B2B := "b2b"

## Memnuniyet 0-100 TAM SAYIDIR ve tek yazma seam'i CustomerRegistry.set_satisfaction(id, int).
## §8.3'ün zararı kesirlidir: beş hesaba bölünmüş −2,0 hesap başına −0,4 eder ve yuvarlama
## onu ya sıfırlar ya ikiye katlar. Kalıntı kişi başına burada birikir; tam birime taşınca
## seam çağrılır. Kayda girer (ProductSystem'in bloğunda): girmeseydi her yükleme hesap başına
## bir puandan küçük zararı silerdi.
static var _damage_residue: Dictionary = {}


# =========================================================================
#  TICK'LER
# =========================================================================

static func hourly_tick(_hour: int) -> void:
	if not ProductState.is_live():
		return
	var f: float = 1.0 / float(TimeModel.HOURS_PER_DAY)
	# Toplantı atlamasının saatinde kurucu masada payıyla sayılır (TimeManager.founder_output_factor).
	var founder_share: float = TimeManager.founder_output_factor()
	# §9 — bildirimler kendiliğinden gelir, masa kapalı olsa da.
	var reports: float = float(GameState.get_flag(ProductState.REPORTS_PROGRESS, 0.0)) \
		+ TimeModel.per_tick(reports_per_day()) * f
	var arrived: int = int(reports)
	GameState.set_flag(ProductState.REPORTS_PROGRESS, reports - arrived)
	GameState.set_flag(ProductState.REPORTS_INCOMING, ProductState.reports_incoming() + arrived)
	_count_week("in", arrived)
	# §8.2 — GELEN'i açık hataya çevirir; masa boşken de okurların tabanıyla. Her hata kendi başına bir canlı
	# hatta düşer, hatlar eşit olasılıklı; hatsız ürünün bildirimi hat çıkana dek doğrulanmaz.
	var lines: Array = ProductState.live_lines().filter(
		func(line: String) -> bool: return not ProductState.line_blocked(line))
	if lines.is_empty():
		return
	var draw: RandomNumberGenerator = RngStreams.get_stream(RngStreams.STREAM_BUG_LINE)
	var validated: int = _validate(TimeModel.per_tick(validation_per_day(founder_share)) * f)
	for _i in validated:
		ProductState.add_bugs(lines[draw.randi_range(0, lines.size() - 1)], 1)
	_count_week("done", validated)


static func daily_tick() -> void:
	if not ProductState.is_live():
		return
	apply_daily_satisfaction_damage()
	_tick_neglect()
	# İlgi türetilir ama duruma geri yazılır: tüketicisi Satış/Pazarlama tek bir sayı okur.
	GameState.set_flag(ProductState.INTEREST, interest_now())
	weekly_report()


static func reset() -> void:
	_damage_residue.clear()


static func to_dict() -> Dictionary:
	return {"damage_residue": _damage_residue.duplicate()}


static func from_dict(d: Dictionary) -> void:
	_damage_residue = (d.get("damage_residue", {}) as Dictionary).duplicate()


# =========================================================================
#  §9 · CANLI HATA AKIŞI
# =========================================================================

## §9'un tam formülü, GÜNLÜK bildirim sayısı olarak. Canlı ürün yoksa akış yoktur. Saatlik tik
## okur: yaş saatin başından ölçülür.
static func reports_per_day() -> float:
	if not ProductState.is_live():
		return 0.0
	var floor_rate: float = INFLOW_BASE_RESEARCHED if ResearchSeam.completed("self_service") else INFLOW_BASE
	var new_code: float = ProductState.new_code_effort() \
		* exp(-ProductState.version_age(ProductSystem.hour_start_fraction()) / INFLOW_TAU)
	var base: float = floor_rate + INFLOW_NEWCODE_COEF * new_code
	# §10 — altyapı akışı çarpar (ucuz sağlayıcı ×1,25); InfraSystem'den okunur, burada yeniden türetilmez.
	return base * usage_multiplier() * InfraSystem.report_inflow_multiplier()


## §9 kullanım çarpanı — "farklı kullanıcı farklı hataya çarpar". B2C'de kaynak ödeyen
## değil, ürünü KULLANAN kitledir.
static func usage_multiplier() -> float:
	if ProductState.market_type() == MARKET_B2B:
		return 1.0 + float(CustomerRegistry.get_by_market(MARKET_B2B).size()) / USAGE_DIV_B2B
	return 1.0 + SalesSystem.b2c_audience() / USAGE_DIV_B2C


# =========================================================================
#  §8.2 · DOĞRULAMA — Müşteri İlişkileri'nin işi, ATAMAYA duyarlı
# =========================================================================

## §8.2/§12.0 — DESTEK işine atanmış, bugün çalışabilir herkes; ARTI pasif ilgideki kurucu.
## İzindeki/eğitimdeki kişi HRSystem tarafında zaten eleniyor. `validation_per_day` roster üzerinde
## topladığı için masadaki temsilci ile pasif kurucu kendiliğinden toplanır.
static func desk_roster() -> Array[Character]:
	var roster: Array[Character] = HRSystem.assigned_to_job(HRConstants.JOB_SUPPORT)
	if founder_passive_care():
		var f: Character = CharacterRegistry.get_founder()
		if not roster.has(f):
			roster.append(f)
	return roster


## Kurucu masaya ATANMAZ, OKUNUR: başka hiçbir şey yapmıyorsa müşterilerle ilgileniyordur.
## Saklanan bir durum yok, kendiliğinden başlar ve biter.
##
## "Başka hiçbir şey yapmıyor" = hiçbir İŞE atanmamış, MEŞGUL değil (`HRSystem.is_busy`:
## izin · eğitim · yatırım hazırlığı · satış toplantısı) ve AKTİF.
## `founder_task_state()` ÇAĞRILMAZ: o bu yanıtı okuyup CARE dönüyor, çağırmak sonsuz
## özyineleme olurdu.
## CANLI ÜRÜN ŞART: ürünü olmayan kurucu "müşterilerle ilgileniyor" olamaz; bu §2.3'ün
## BOŞTA durumunu da korur.
static func founder_passive_care() -> bool:
	if not ProductState.is_live():
		return false
	var f: Character = CharacterRegistry.get_founder()
	if f == null or f.status != HRConstants.STATUS_ACTIVE:
		return false
	return not HRSystem.is_busy(f) and f.assigned_job_ids.is_empty()


## §8.2 — Destek'e kimse atanmamışsa masa KAPALIDIR; doğrulama yalnız okurların tabanıyla sürer.
static func desk_staffed() -> bool:
	return not desk_roster().is_empty()


## §8.2 — doğrulama/gün = katsayı × Σ `HRSystem.daily_contribution` (effective_skill × saat/8).
## Liderlik çarpanı BU FORMÜLDE YOK: §4.2 onu alanın toplamına uyguluyor ve §8.2 yazmıyor.
## Herkes mail okur: masanın yanında bu hafta sprint kartı olmayan aktif çalışanlar da doğrular.
## İki işteki kişi 0,5 odakla bölünür (`effective_skill` bunu zaten uyguluyor). `founder_share`
## kurucunun katkısını çarpar; yalnız saatlik tik toplantı payını verir. Herkes en az
## SUPPORT_BASE_POINTS'le sayılır.
static func validation_per_day(founder_share: float = 1.0) -> float:
	if not ProductState.is_live():
		return 0.0
	var coef: float = VALIDATION_COEF_RESEARCHED if ResearchSeam.completed("bug_tracker") else VALIDATION_COEF
	var readers: Array[Character] = desk_roster()
	for c in CharacterRegistry.get_active_employees():
		if not readers.has(c) and SprintSystem.role_of(c.id) == "":
			readers.append(c)
	var total: float = 0.0
	for c in readers:
		var points: float = maxf(HRSystem.daily_contribution(c, HRConstants.AREA_CUSTOMER_SUCCESS), SUPPORT_BASE_POINTS)
		total += points * (founder_share if c.category == "founder" else 1.0)
	return coef * total


# =========================================================================
#  §8.3 · İKİ KADEMELİ ZARAR
# =========================================================================

## §8.3 — iki kademenin toplamı, GÜNLÜK TAVANLA sınırlı. Negatif ya da sıfır döner.
static func daily_satisfaction_damage() -> float:
	var support: float = 0.0
	if ProductState.is_live():
		support = DAMAGE_INCOMING_PER_TEN * float(ProductState.reports_incoming()) / DAMAGE_PER_UNITS \
			+ DAMAGE_CONFIRMED_PER_TEN * float(ProductState.costed(ProductState.open_bugs())) / DAMAGE_PER_UNITS
	return maxf(support, DAMAGE_DAILY_CAP)


## §8.3 dağıtımı — tikin zararı, tavanlı günlük zararın yedi günüdür. B2B'de zarar AKTİF
## HESAPLARA EŞİT bölünür, B2C'de Satış'ın tek toplu kitle kaydına işler (ücretli kademe
## açılmadan o kayıt yoktur). Yazma yolu CustomerRegistry.set_satisfaction (WRITE-THROUGH LAW).
static func apply_daily_satisfaction_damage() -> void:
	var damage: float = TimeModel.per_tick(daily_satisfaction_damage())
	if damage >= 0.0:
		return
	var targets: Array[Customer] = []
	if ProductState.market_type() == MARKET_B2B:
		targets = CustomerRegistry.get_by_market(MARKET_B2B)
	else:
		var base: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
		if base != null:
			targets.append(base)
	for c in targets:
		var carried: float = float(_damage_residue.get(c.id, 0.0)) + damage / float(targets.size())
		# Zarar negatif; ceil sıfıra doğru yuvarlar (−1,2 → −1 uygula, −0,2 beklet).
		# floor yarım puanlık zararı tam puana şişirirdi.
		var whole: int = int(ceil(carried))
		_damage_residue[c.id] = carried - float(whole)
		if whole != 0:
			CustomerRegistry.set_satisfaction(c.id, c.satisfaction + whole)


# =========================================================================
#  HATA İHMALİ · itibar
# =========================================================================

## Haftalık tikte açık hata ihmal eşiğindeyse sayaç artar, değilse sıfırlanır; sayaç eşiğe varınca (ve koşul
## sürdükçe her hafta) itibar bir düşer. Düzenli düzelten oyuncu eşiğe varmaz.
static func _tick_neglect() -> void:
	var streak: int = int(GameState.get_flag(ProductState.BUG_STREAK, 0))
	streak = streak + 1 if ProductState.costed(ProductState.open_bugs()) >= NEGLECT_BUGS else 0
	GameState.set_flag(ProductState.BUG_STREAK, streak)
	if streak >= NEGLECT_WEEKS:
		var before: int = GameState.reputation
		GameState.set_reputation(before - 1)
		if GameState.reputation < before:
			GameState.set_flag(ProductState.BUG_DROP_DAY, GameState.day)


## İhmalin son itibar düşüşü: {day, reason}, reason bir CSV anahtarı; hiç düşürmediyse boş.
static func neglect_drop() -> Dictionary:
	var day: int = int(GameState.get_flag(ProductState.BUG_DROP_DAY, 0))
	return {} if day == 0 else {"day": day, "reason": NEGLECT_REASON}


## Son düşüşün sebebini söyleyen cümle (TopBar'ın ve Destek kartının ipucu); hiç düşürmediyse "".
static func neglect_note() -> String:
	var drop: Dictionary = neglect_drop()
	return "" if drop.is_empty() else TranslationServer.translate(drop.reason).format(
		{"date": Fmt.date_line(GameState.get_date_dict(int(drop.day)))})


# =========================================================================
#  HAFTALIK DESTEK RAPORU
# =========================================================================

## Cevapsız kalan bildirim haftanın gelenlerinin bu sayıda birine ya da fazlasına varınca temsilci yetişemedim der.
const REPORT_BEHIND_ONE_IN := 5         # [ÇALIŞMA] onay bekliyor
## Yeni en kötü hat, öncekinin açık hatasını bu kadar ya da fazla geçince unvanın değişmesi haber olur.
const REPORT_WORST_LEAD := 2            # [ÇALIŞMA] onay bekliyor
const REPORT_KIND := "support_week"


## Haftalık tikte, sprint kapanışından sonra: Müşteri İlişkileri'nin en yüksek puanlı temsilcisi haftada en çok bir rapor
## yazar. Temsilci yoksa ya da hafta sessizse (`report_news` boş) gelmez; okunmamış eski rapor yenisi gelince düşer. Hata
## defteri ve bildirim sayacı rapor yazılsın yazılmasın hafta sonunda yazılır: "yeni", son haftanın farkıdır.
static func weekly_report() -> void:
	var before: Dictionary = GameState.get_flag(ProductState.REPORT_BUGS, {})
	var now: Dictionary = ProductState.open_bugs_by_line()
	var week: Dictionary = GameState.get_flag(ProductState.REPORT_WEEK, {})
	GameState.set_flag(ProductState.REPORT_BUGS, now)
	GameState.set_flag(ProductState.REPORT_WEEK, {})
	var reps: Array = CustomerRepSystem.ranked_reps()
	if reps.is_empty():
		return
	var news: Array = report_news(before, now, week)
	if news.is_empty():
		return
	var lines: Array = ProductState.lines_by_bugs(now).map(func(line: String) -> Dictionary:
		return {"line": line, "part": SprintCatalog.bugs_part(line, int(now[line])),
			"delta": int(now[line]) - int(before.get(line, 0))})
	MessageSystem.drop_unread(REPORT_KIND)
	MessageSystem.post(REPORT_KIND, "SUPPORT_RPT_SUBJECT", {"rep": reps[0].character_name,
		"week": int(GameState.get_date_dict().week), "lines": lines, "news": news,
		"fix": ProductState.worst_bug_line(now)})


## Haftanın yenileri, {key, args} satırları olarak: bir hat Öncelikli eşiğine ulaştı, sıfırlandı ya da bir düzeltmeyle
## azaldı (açık hata yalnız düzeltmeyle azalır), en çok sorunlu hat değişti, temsilci yetişemedi. Unvanın değişmesi
## önceki en kötü hattın açık hatası o hafta azaldıysa haber değildir (düzeltme satırı onu zaten söyler) ve yeni en kötü
## hat öncekini `REPORT_WORST_LEAD` farkla geçmediyse de değildir.
## `before` ve `now` {hat: açık hata} defterleri, `week` {in, done} bildirim sayacı. Boşsa hafta sessizdir.
static func report_news(before: Dictionary, now: Dictionary, week: Dictionary) -> Array:
	var news: Array = []
	var lines: Array = before.keys()
	for line in now:
		if not before.has(line):
			lines.append(line)
	lines.sort()
	for line in lines:
		var was: int = int(before.get(line, 0))
		var open: int = int(now.get(line, 0))
		if SprintCatalog.is_priority_count(open) and not SprintCatalog.is_priority_count(was):
			news.append({"key": "SUPPORT_RPT_NEW_PRIORITY", "args": {"line": line, "n": open}})
		elif open == 0 and was > 0:
			news.append({"key": "SUPPORT_RPT_NEW_CLEARED", "args": {"line": line}})
		elif open < was:
			news.append({"key": "SUPPORT_RPT_SHIPPED", "args": {"line": line, "from": was, "to": open}})
	var worst: String = ProductState.worst_bug_line(now)
	var was_worst: String = ProductState.worst_bug_line(before)
	var was_open: int = int(now.get(was_worst, 0))
	if worst != "" and worst != was_worst and was_open >= int(before.get(was_worst, 0)) \
			and int(now[worst]) - was_open >= REPORT_WORST_LEAD:
		news.append({"key": "SUPPORT_RPT_NEW_WORST", "args": {"line": worst}})
	var incoming: int = int(week.get("in", 0))
	var handled: int = int(week.get("done", 0))
	if incoming > 0 and (incoming - handled) * REPORT_BEHIND_ONE_IN >= incoming:
		news.append({"key": "SUPPORT_RPT_BEHIND", "args": {"incoming": incoming, "handled": handled}})
	return news


## Bu haftanın bildirim sayacına `n` ekler (`key`: "in" gelen, "done" doğrulanan).
static func _count_week(key: String, n: int) -> void:
	if n > 0:
		var week: Dictionary = (GameState.get_flag(ProductState.REPORT_WEEK, {}) as Dictionary).duplicate()
		week[key] = int(week.get(key, 0)) + n
		GameState.set_flag(ProductState.REPORT_WEEK, week)


# =========================================================================
#  §8.5 · İHMAL ISINMASI · §9 · İLGİ
# =========================================================================

## §8.5 — GELEN birikimine göre bant kimliği: "calm" · "warm" · "hot".
static func warmth_band() -> String:
	var incoming: int = ProductState.reports_incoming() if ProductState.is_live() else 0
	if incoming < WARMTH_WARM_AT:
		return BAND_CALM
	if incoming <= WARMTH_HOT_AT:
		return BAND_WARM
	return BAND_HOT


## §9 — ilgi SÜRÜM yaşından türetilir (ürün yaşından değil, §17). Saf fonksiyon:
## saklanan değeri okumaz. Yaş tik başında ölçülür: ilgi tik başında yazılır ve satış o sayıyı okur,
## canlı okuma da aynı sayıyı verir.
static func interest_now() -> float:
	if not ProductState.is_live():
		return 0.0
	return ProductState.INTEREST_MAX * pow(0.5, ProductState.version_age() / INTEREST_HALF_LIFE)


# =========================================================================
#  BİRİKİM — kesirli oranlar, tam sayı sayaçlar
# =========================================================================

## Günlük oranın bu saatlik payını doğrulama birikimine ekler ve tam birimleri GELEN sayacından düşer;
## doğrulanan bildirimlerin sayısı döner. GELEN tükenince birikim VALIDATION_BANK_MAX ile sınırlanır.
static func _validate(rate: float) -> int:
	if rate <= 0.0:
		return 0
	var progress: float = float(GameState.get_flag(ProductState.VALIDATION_PROGRESS, 0.0)) + rate
	var incoming: int = ProductState.reports_incoming()
	var validated: int = mini(int(progress), incoming)
	progress -= validated
	incoming -= validated
	if incoming <= 0:
		progress = minf(progress, VALIDATION_BANK_MAX)
	GameState.set_flag(ProductState.VALIDATION_PROGRESS, progress)
	GameState.set_flag(ProductState.REPORTS_INCOMING, incoming)
	return validated
