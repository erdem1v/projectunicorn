class_name SupportSystem
extends RefCounted

# GDD — ÜRÜN MODÜLÜ rev 6.1 §8 (CANLI / DESTEK) + §9 (CANLI HATA AKIŞI MODELİ).
#
# Canlı ürünün kalıcı hâli: sprintler biter, DESTEK bitmez.
#
# İKİ SAYAÇ (§8.1), MÜHÜRLÜ terimler:
#   GELEN BİLDİRİM  — doğrulanmamış kullanıcı bildirimi. Kendiliğinden GELİR (§9).
#   DOĞRULANMIŞ HATA — onaylanmış açık hata. Kendiliğinden ÇÖZÜLMEZ. Asla.
# Modülün bütün gerilimi bu asimetride: akış otomatiktir, çözüm sprintin düzeltme kartıdır.
#
# MODÜL KENDİ KENDİNE TİKLEMEZ: `daily_tick()` ve `hourly_tick(hour)` TimeManager'dan
# çağrılır. Bayrak ADLARININ tek evi ProductState'tir; bu modül §8 sayaçlarının tek
# yazarıdır ama adı daima ProductState'in sabitinden alır.
#
# SAAT/GÜN AYRIMI (bir tik yedi takvim günüdür):
#   hourly_tick — AKIŞLAR. §9 bildirim akışı, §8.2 doğrulama.
#                 İkisi de GÜNLÜK oranlardır; saatlik tikte tikin yedi gününün 1/24'ü
#                 işlenir. Kesirli birikim *_PROGRESS bayraklarında durur, tam sayıya
#                 taşınca sayaç oynar. Sıra kasıtlı: bildirim gelir → doğrulanır.
#   daily_tick  — GÜNLÜK KESİNTİLER. §8.3 memnuniyet zararı ve §9 ilgi sönümü. İkisi
#                 de belgede açıkça "/gün" yazılıdır; zarar tavanı GÜNLÜK bir tavandır ve
#                 günlük değere uygulanır, tik yedi günü sonra alır.

# ------------------------------------------------------ §9 canlı hata akışı
# gelen bildirim/gün = (0,2 + 0,05 × taşınan_hata
#                       + 0,03 × yeni_kod_eforu × e^(−sürüm_yaşı/3)) × kullanım_çarpanı
# Sürüm yaşı haftadır ve saat kesrini taşır.
#
## §9 taban — "hiçbir ürün %100 hatasız değildir; akış asla sıfırlanmaz."
const INFLOW_BASE := 0.2
## Ar-Ge §4.3 `self_service` — aynı tabanın araştırılmış hâli. Akışı KISAR, kapatmaz.
const INFLOW_BASE_RESEARCHED := 0.14
## §9 taşınan hata terimi — canlıdaki her açık hata zamanla yüzeye çıkar.
const INFLOW_CARRIED_COEF := 0.05
## §9 yeni kod terimi — yeni sürümün efor büyüklüğüyle orantılı yeni havuz.
const INFLOW_NEWCODE_COEF := 0.03
## §9 "~3 haftada söner" — YALNIZ yeni kod terimi söner. Yeni sürüm sıfırdan havuz
## yaratmaz: olgun ürün altta durur, tazelenen tek şey bu terimdir. Birim hafta.
const INFLOW_TAU := 3.0
## §9 kullanım çarpanı: 1 + aktif kullanıcı/2000 (B2C) · 1 + hesap sayısı/10 (B2B).
const USAGE_DIV_B2C := 2000.0
const USAGE_DIV_B2B := 10.0

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
	# §8.2 — GELEN'i DOĞRULANMIŞ'a çevirir; masa boşken de okurların tabanıyla.
	_drain(ProductState.VALIDATION_PROGRESS, TimeModel.per_tick(validation_per_day(founder_share)) * f,
		ProductState.REPORTS_INCOMING, ProductState.BUGS_CONFIRMED)


static func daily_tick() -> void:
	if not ProductState.is_live():
		return
	apply_daily_satisfaction_damage()
	# İlgi türetilir ama duruma geri yazılır: tüketicisi Satış/Pazarlama tek bir sayı okur.
	GameState.set_flag(ProductState.INTEREST, interest_now())


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
	# Taşınan hata `live_bug_count`'tur ve canlı aşınmayla (ProductSystem._post_ship_wear_hourly)
	# büyür; §9 aşınma terimi yazmaz.
	var base: float = floor_rate + INFLOW_CARRIED_COEF * float(ProductSystem.live_bug_count()) \
		+ INFLOW_NEWCODE_COEF * new_code
	# §10 — altyapı akışı çarpar (ucuz sağlayıcı ×1,25, doluluk %100 üstü ×1,5);
	# InfraSystem'den okunur, burada yeniden türetilmez.
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
## §10 aşım zararı da tavanın İÇİNDE toplanır ("§8.3'ün −2,0 tavanı içinde"); ayrı kanal
## olsaydı ihmal + aşım −2,8'e çıkardı.
static func daily_satisfaction_damage() -> float:
	var support: float = 0.0
	if ProductState.is_live():
		support = DAMAGE_INCOMING_PER_TEN * float(ProductState.reports_incoming()) / DAMAGE_PER_UNITS \
			+ DAMAGE_CONFIRMED_PER_TEN * float(ProductState.bugs_confirmed()) / DAMAGE_PER_UNITS
	return maxf(support + InfraSystem.satisfaction_delta_per_day(), DAMAGE_DAILY_CAP)


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

## Günlük oranın bu saatlik payını birikime ekler ve tam birimleri `from_key` sayacından
## `to_key` sayacına taşır. Kaynak tükenince birikim VALIDATION_BANK_MAX ile sınırlanır.
static func _drain(progress_key: String, rate: float, from_key: String, to_key: String) -> void:
	if rate <= 0.0:
		return
	var prog: float = float(GameState.get_flag(progress_key, 0.0)) + rate
	var source: int = int(GameState.get_flag(from_key, 0))
	var moved: int = mini(int(prog), source)
	prog -= moved
	source -= moved
	if source <= 0:
		prog = minf(prog, VALIDATION_BANK_MAX)
	GameState.set_flag(progress_key, prog)
	GameState.set_flag(from_key, source)
	GameState.set_flag(to_key, int(GameState.get_flag(to_key, 0)) + moved)
