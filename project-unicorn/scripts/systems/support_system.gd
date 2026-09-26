class_name SupportSystem
extends RefCounted

# GDD — ÜRÜN MODÜLÜ rev 6.1 §8 (CANLI / DESTEK) + §9 (CANLI HATA AKIŞI MODELİ).
#
# Yaşam döngüsünün BEŞİNCİ fazı ve tek kalıcı olanı: Konsept → TASARIM → GELİŞTİRME →
# BETA → CANLI/DESTEK. Yapım biter, DESTEK bitmez.
#
# İKİ SAYAÇ (§8.1), MÜHÜRLÜ terimler:
#   GELEN BİLDİRİM  — doğrulanmamış kullanıcı bildirimi. Kendiliğinden GELİR (§9).
#   DOĞRULANMIŞ HATA — onaylanmış açık hata. Kendiliğinden ÇÖZÜLMEZ. Asla.
# Modülün bütün gerilimi bu asimetride: akış otomatiktir, çözüm ATAMA gerektirir.
#
# MODÜL KENDİ KENDİNE TİKLEMEZ: `daily_tick()` ve `hourly_tick(hour)` TimeManager'dan
# çağrılır. Bayrak ADLARININ tek evi ProductState'tir; bu modül §8 sayaçlarının tek
# yazarıdır ama adı daima ProductState'in sabitinden alır.
#
# SAAT/GÜN AYRIMI:
#   hourly_tick — AKIŞLAR. §9 bildirim akışı, §8.2 doğrulama, §8.4 düzeltme koşusu.
#                 Üçü de GÜNLÜK oranlardır ve saatte 1/24'ü işlenir; kesirli birikim
#                 *_PROGRESS bayraklarında durur, tam sayıya taşınca sayaç oynar.
#                 Sıra kasıtlı: bildirim gelir → doğrulanır → koşu çözer. Aynı saat
#                 içinde bir bildirimin doğrulanıp çözülebilmesi "masa dolu" hâlinin
#                 ta kendisidir.
#   daily_tick  — GÜNLÜK KESİNTİLER. §8.3 memnuniyet zararı ve §9 ilgi sönümü. İkisi
#                 de belgede açıkça "/gün" yazılıdır; saate bölünmeleri anlamı
#                 değiştirirdi (zarar tavanı GÜNLÜK bir tavandır).

# ------------------------------------------------------ §9 canlı hata akışı
# gelen bildirim/gün = (0,2 + 0,05 × taşınan_hata
#                       + 0,03 × yeni_kod_eforu × e^(−sürüm_yaşı/21)) × kullanım_çarpanı
#
## §9 taban — "hiçbir ürün %100 hatasız değildir; akış asla sıfırlanmaz."
const INFLOW_BASE := 0.2
## Ar-Ge §4.3 `self_service` — aynı tabanın araştırılmış hâli. Akışı KISAR, kapatmaz.
const INFLOW_BASE_RESEARCHED := 0.14
## §9 taşınan hata terimi — BETA'dan canlıya taşınan her açık hata zamanla yüzeye çıkar.
const INFLOW_CARRIED_COEF := 0.05
## §9 yeni kod terimi — yeni sürümün efor büyüklüğüyle orantılı yeni havuz.
const INFLOW_NEWCODE_COEF := 0.03
## §9 "~3 haftada söner" — YALNIZ yeni kod terimi söner. Yeni sürüm sıfırdan havuz
## yaratmaz: olgun ürün altta durur, tazelenen tek şey bu terimdir.
const INFLOW_TAU := 21.0
## §9 kullanım çarpanı: 1 + aktif kullanıcı/2000 (B2C) · 1 + hesap sayısı/10 (B2B).
const USAGE_DIV_B2C := 2000.0
const USAGE_DIV_B2B := 10.0

# ------------------------------------------------ §8.2 doğrulama (Müşteri İlişkileri)
## §8.2 — doğrulama/gün = 0,8 × Σ hr.effective_skill(atanan, Mİ) × saat/8.
const VALIDATION_COEF := 0.8
## Ar-Ge §4.3 `bug_tracker` — aynı katsayının araştırılmış hâli.
const VALIDATION_COEF_RESEARCHED := 1.0
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
## §8.3 TAVAN: iki kademenin günlük TOPLAM zararı −2,0/gün ile sınırlı. İhmal ölüm
## sarmalı değil, ağır ama toparlanabilir bir kanamadır.
const DAMAGE_DAILY_CAP := -2.0

# ------------------------------------------------------------- §8.4 düzeltme koşusu
## §8.4 — düzeltme/gün = 1,2 × Σ etkin Yazılım × saat/8.
const FIX_COEF := 1.2

# --------------------------------------------------------------- §8.5 ısınma
## §8.5 eşikler: GELEN < 20 sakin · 20-40 ılık · > 40 sıcak. Renk UI'nin sözlüğüdür.
const WARMTH_WARM_AT := 20
const WARMTH_HOT_AT := 40
const BAND_CALM := "calm"
const BAND_WARM := "warm"
const BAND_HOT := "hot"

# ------------------------------------------------------------------ §9 ilgi
## §9 — "her yayın ilgiyi 100'e tazeler; ilgi sürüm yaşıyla söner, yarı ömür 30 gün."
## Tazeleme ProductState.refresh_on_publish()'in işi; sönüm burada.
const INTEREST_HALF_LIFE := 30.0

const MARKET_B2B := "b2b"

## §8.4 DÜZELTME BAŞLAT'ın ret kimlikleri: makine kimliği döner, metin dönmez.
## "" = koşu başlatılabilir.
const REFUSAL_NOT_LIVE := "not_live"
const REFUSAL_ALREADY_RUNNING := "already_running"
const REFUSAL_NO_BUGS := "no_confirmed_bugs"
const REFUSAL_DESK_SHUT := "desk_shut"

## Memnuniyet 0-100 TAM SAYIDIR ve tek yazma seam'i CustomerRegistry.set_satisfaction(id, int).
## §8.3'ün zararı kesirlidir: beş hesaba bölünmüş −2,0 hesap başına −0,4 eder ve yuvarlama
## onu ya sıfırlar ya ikiye katlar. Kalıntı kişi başına burada birikir; tam birime taşınca
## seam çağrılır. KAYDA GİRMEZ: yükleme bir günden küçük kalıntıyı unutur (< 1 puan).
static var _damage_residue: Dictionary = {}


# =========================================================================
#  TICK'LER
# =========================================================================

static func hourly_tick(_hour: int) -> void:
	if not ProductState.is_live():
		return
	var f: float = 1.0 / float(TimeManager.HOURS_PER_DAY)
	# §9 — bildirimler kendiliğinden gelir. Masa kapalı olsa da gelir; §8.2'nin
	# kapattığı şey doğrulamadır, akış değil.
	var reports: float = float(GameState.get_flag(ProductState.REPORTS_PROGRESS, 0.0)) + reports_per_day() * f
	var arrived: int = int(reports)
	GameState.set_flag(ProductState.REPORTS_PROGRESS, reports - arrived)
	GameState.set_flag(ProductState.REPORTS_INCOMING, ProductState.reports_incoming() + arrived)
	# §8.2 — GELEN'i DOĞRULANMIŞ'a çevirir. Boş masa küçük bir sızıntı değil, tam sıfırdır.
	_drain(ProductState.VALIDATION_PROGRESS, validation_per_day() * f,
		ProductState.REPORTS_INCOMING, ProductState.BUGS_CONFIRMED)
	# §8.4 — koşu DOĞRULANMIŞ'ı eritir ve çözülenleri sayar. Havuz boşalırsa koşu
	# KENDİLİĞİNDEN BİTMEZ: yeni doğrulamaları da yer. Koşuyu bitiren yalnız oyuncudur.
	_drain(ProductState.FIX_RUN_PROGRESS, fix_per_day() * f,
		ProductState.BUGS_CONFIRMED, ProductState.FIX_RUN_FIXED)


static func daily_tick() -> void:
	if not ProductState.is_live():
		return
	apply_daily_satisfaction_damage()
	# İlgi türetilir ama duruma geri yazılır: tüketicisi Satış/Pazarlama tek bir sayı okur.
	GameState.set_flag(ProductState.INTEREST, interest_now())


## Yeni koşu / yeni kayıt. Kalıntı tablosu türetilmiş bir tampon, taşınmaz.
static func reset() -> void:
	_damage_residue.clear()


# =========================================================================
#  §9 · CANLI HATA AKIŞI
# =========================================================================

## §9'un tam formülü, GÜNLÜK bildirim sayısı olarak. Canlı ürün yoksa akış yoktur.
static func reports_per_day() -> float:
	if not ProductState.is_live():
		return 0.0
	var floor_rate: float = INFLOW_BASE_RESEARCHED if ResearchSeam.completed("self_service") else INFLOW_BASE
	var new_code: float = ProductState.new_code_effort() \
		* exp(-float(ProductState.version_age_days()) / INFLOW_TAU)
	# Taşınan hata bugün eski aşınma sayacından (`live_bug_count`) okunur. Rev 6.1'de
	# DOĞRULANMIŞ (`ProductState.bugs_confirmed`) ile yayındaki devir ayrışır; devrin
	# yayında tohumlanması ProductSystem'in işidir ve yapılmadı.
	var base: float = floor_rate + INFLOW_CARRIED_COEF * float(ProductSystem.live_bug_count()) \
		+ INFLOW_NEWCODE_COEF * new_code
	# §10 — altyapı akışı çarpar (ucuz sağlayıcı ×1,25, doluluk %100 üstü ×1,5);
	# InfraSystem'den okunur, burada yeniden türetilmez.
	return base * usage_multiplier() * InfraSystem.report_inflow_multiplier()


## §9 kullanım çarpanı — "farklı kullanıcı farklı hataya çarpar". B2C'de kaynak ödeyen
## değil, ürünü KULLANAN kitledir (`get_total_users` yalnız ödeyeni sayar).
static func usage_multiplier() -> float:
	if ProductState.market_type() == MARKET_B2B:
		return 1.0 + float(CustomerRegistry.get_by_market(MARKET_B2B).size()) / USAGE_DIV_B2B
	return 1.0 + SalesSystem.b2c_audience() / USAGE_DIV_B2C


# =========================================================================
#  §8.2 · DOĞRULAMA — Müşteri İlişkileri'nin işi, ATAMAYA duyarlı
# =========================================================================

## §8.2/§12.0 — DESTEK işine atanmış, bugün çalışabilir herkes; ARTI pasif ilgideki kurucu.
## İzindeki/eğitimdeki kişi HRSystem tarafında zaten eleniyor. `_desk_sum` roster üzerinde
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


## §8.2 — "Destek'e kimse atanmamışsa masa KAPALIDIR: GELEN birikir, hiçbir şey
## doğrulanmaz, hiçbir şey düzeltilemez."
static func desk_staffed() -> bool:
	return not desk_roster().is_empty()


## §8.2 — doğrulama/gün = katsayı × Σ `HRSystem.daily_contribution` (effective_skill × saat/8).
## Liderlik çarpanı BU FORMÜLDE YOK: §4.2 onu alanın toplamına uyguluyor ve §8.2 yazmıyor.
static func validation_per_day() -> float:
	if not ProductState.is_live():
		return 0.0
	var coef: float = VALIDATION_COEF_RESEARCHED if ResearchSeam.completed("bug_tracker") else VALIDATION_COEF
	return coef * _desk_sum(HRConstants.AREA_CUSTOMER_SUCCESS)


## §8.4 — düzeltme/gün = 1,2 × Σ etkin Yazılım × saat/8, yine YALNIZ Destek masası.
## Koşu yokken 0: hiçbir hata kendiliğinden çözülmez (§8.1).
static func fix_per_day() -> float:
	if not ProductState.is_live() or not ProductState.fix_run_active():
		return 0.0
	return FIX_COEF * _desk_sum(HRConstants.AREA_ENGINEERING)


## İki işteki kişi 0,5 odakla bölünür — `effective_skill` bunu zaten uyguluyor, yani
## koşu sırasında doğrulamanın sürmesi (§8.4) bedavaya gelmiyor.
static func _desk_sum(area_key: String) -> float:
	var total: float = 0.0
	for c in desk_roster():
		total += HRSystem.daily_contribution(c, area_key)
	return total


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


## §8.3 dağıtımı — B2B'de zarar AKTİF HESAPLARA EŞİT bölünür, B2C'de Satış'ın tek toplu
## kitle kaydına işler (ücretli kademe açılmadan o kayıt yoktur). Yazma yolu
## CustomerRegistry.set_satisfaction (WRITE-THROUGH LAW).
static func apply_daily_satisfaction_damage() -> void:
	var damage: float = daily_satisfaction_damage()
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
#  §8.4 · DÜZELTME KOŞUSU
# =========================================================================

## §8.4 — "DOĞRULANMIŞ birikince DÜZELTME BAŞLAT açılır (DOĞRULANMIŞ 0 iken kapalıdır)."
## Masa kapalıysa da açılmaz: kimse yokken başlatılan koşu yalnız yapımı duraklatan boş
## bir kabuk olurdu.
static func fix_run_refusal() -> String:
	if not ProductState.is_live():
		return REFUSAL_NOT_LIVE
	if ProductState.fix_run_active():
		return REFUSAL_ALREADY_RUNNING
	if ProductState.bugs_confirmed() <= 0:
		return REFUSAL_NO_BUGS
	if not desk_staffed():
		return REFUSAL_DESK_SHUT
	return ""


static func can_start_fix_run() -> bool:
	return fix_run_refusal() == ""


## §8.4 — koşuyu başlatır. Sayaçlar sıfırlanır; ilerleme saatlik tick'te akar.
static func start_fix_run() -> bool:
	var refusal: String = fix_run_refusal()
	if refusal != "":
		push_warning("[SupportSystem] start_fix_run refused: %s" % refusal)
		return false
	EventBus.fix_run_started.emit(ProductState.bugs_confirmed())   # §19
	GameState.set_flag(ProductState.FIX_RUN_ACTIVE, true)
	GameState.set_flag(ProductState.FIX_RUN_FIXED, 0)
	GameState.set_flag(ProductState.FIX_RUN_PROGRESS, 0.0)
	return true


## §8.4 — "Oyuncu koşuyu istediği an bitirir ve çözülenleri canlıya iter: 35 doğrulanmış,
## 27 çözüldü, 27'si gider, 8'i havuzda kalır." Çözülenler koşu boyunca zaten havuzdan
## düşmüştür; bu fonksiyon koşuyu kapatır ve kaç hatanın canlıya gittiğini döner.
static func end_fix_run() -> int:
	if not ProductState.fix_run_active():
		return 0
	var shipped: int = ProductState.fix_run_fixed()
	GameState.set_flag(ProductState.FIX_RUN_ACTIVE, false)
	GameState.set_flag(ProductState.FIX_RUN_FIXED, 0)
	GameState.set_flag(ProductState.FIX_RUN_PROGRESS, 0.0)
	EventBus.fix_run_finished.emit(shipped, ProductState.bugs_confirmed())   # §19
	return shipped


## §8.4 — "Koşu başlatmak aktif yapımı duraklatır." ProductSystem bunu kendi duraklama
## okumasında sorar; bu modül ona uzanmaz.
static func fix_run_pauses_build() -> bool:
	return ProductState.is_live() and ProductState.fix_run_active()


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
## saklanan değeri okumaz.
static func interest_now() -> float:
	if not ProductState.is_live():
		return 0.0
	var age: float = float(ProductState.version_age_days())
	return ProductState.INTEREST_MAX * pow(0.5, age / INTEREST_HALF_LIFE)


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
