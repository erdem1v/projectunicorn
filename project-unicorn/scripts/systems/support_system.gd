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
# MODÜL KENDİ KENDİNE TİKLEMEZ. `daily_tick()` ve `hourly_tick(hour)` dışarıdan
# çağrılır (TimeManager slot'u), tıpkı ProductSystem ve SalesSystem gibi. Bu dosya
# hiçbir autoload'a kaydolmaz.
#
# DURUM NEREDE YAŞIYOR: bayrak ADLARININ tek evi ProductState'tir ve okuma DAİMA
# oradan yapılır (`ProductState.reports_incoming()` vb.). Yazma seam'leri burada,
# çünkü §8'in sayaçlarını oynatan tek sahip bu modüldür — ama yazarken bile ad
# ProductState'in sabitinden alınır, string kopyalanmaz.
#
# SAAT/GÜN AYRIMI (ProductSystem grameri):
#   hourly_tick — AKIŞLAR. §9 bildirim akışı, §8.2 doğrulama, §8.4 düzeltme koşusu.
#                 Üçü de GÜNLÜK oranlardır ve saatte 1/24'ü işlenir; kesirli birikim
#                 *_PROGRESS bayraklarında durur, tam sayıya taşınca sayaç oynar.
#                 Sıra kasıtlı: bildirim gelir → doğrulanır → koşu çözer. Aynı saat
#                 içinde bir bildirimin doğrulanıp çözülebilmesi modelin bir kusuru
#                 değil, "masa dolu" hâlinin ta kendisidir.
#   daily_tick  — GÜNLÜK KESİNTİLER. §8.3 memnuniyet zararı ve §9 ilgi sönümü. İkisi
#                 de belgede açıkça "/gün" yazılıdır; saate bölünmeleri sayıyı değil
#                 anlamı değiştirirdi (zarar tavanı GÜNLÜK bir tavandır).
#
# BAĞLANMAMIŞ SEAM'LER — BU LİSTE BAYATTI, 2026-08-25'te ölçülerek düzeltildi.
# Dördü aynı turun ilerleyen adımlarında BAĞLANDI; liste yazıldığı gün doğruydu ve
# güncellenmeden kaldı. Silinmiyor, DÜZELTİLİYOR: hangi iddianın nasıl kapandığı
# sonraki okur için listenin kendisinden daha değerli.
#   · ProductSystem.launch() → `ProductState.refresh_on_publish(total_efor)` ÇAĞIRIYOR
#     (product_system.gd:1626). Sürüm yaşı, ilgi ve yeni-kod terimi yayında tazeleniyor.
#   · Yeni sürümün eforu AYNI çağrıda damgalanıyor — `refresh_on_publish` NEW_CODE_EFFORT'u
#     kendi yazıyor, ayrı bir `stamp_new_code_effort` çağrısı GEREKMİYOR.
#   · ProductSystem.pause_kind() → `fix_run_pauses_build()` OKUYOR (product_system.gd:429).
#   · SalesSystem.b2c_audience() VAR (sales_system.gd:310).
# HÂLÂ AÇIK:
#   · Memnuniyet tam sayıdır; kesirli zararın kalıntısı kayda giremiyor.

# ---------------------------------------------------------------- zaman
## ProductSystem.HOURS_PER_BUILD_DAY ile aynı sayı, kasıtlı olarak AYRI: bu modül
## build motoruna değil takvime bağlı. Günlük oranlar saatte bunun tersiyle işlenir.
const HOURS_PER_DAY := 24

# ------------------------------------------------------ §9 canlı hata akışı
# gelen bildirim/gün = (0,2 + 0,05 × taşınan_hata
#                       + 0,03 × yeni_kod_eforu × e^(−sürüm_yaşı/21)) × kullanım_çarpanı
#
## §9 taban — "hiçbir ürün %100 hatasız değildir; akış asla sıfırlanmaz." Ar-Ge bir
## düğümle bunu 0,20 → 0,14'e çeker, o yüzden TEK BAŞINA adlı bir sabit: düğüm geldiğinde
## değiştirilecek tek yer burasıdır ve formülün içine gömülü bir literal olamaz.
const INFLOW_BASE := 0.2
## Ar-Ge §4.3 `self_service` — aynı tabanın araştırılmış hâli (0,20 → 0,14). Taban
## sabiti adıyla ve değeriyle YERİNDE DURUR: düğüm kapalıyken akış hâlâ 0,20'den
## başlar, ve §9'un "akış asla sıfırlanmaz" hükmü iki değerde de geçerli — kendi
## kendine servis akışı KISAR, kapatmaz. Yürürlükteki sayıyı `inflow_base()` söyler.
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
## Ar-Ge bir düğümle bunu 1,0'a çıkarır; INFLOW_BASE gibi tek başına adlı.
const VALIDATION_COEF := 0.8
## Ar-Ge §4.3 `bug_tracker` — aynı katsayının araştırılmış hâli (0,8 → 1,0). Taban
## sabiti adıyla ve değeriyle YERİNDE DURUR: düğüm kapalıyken doğrulama hâlâ 0,8 ile
## çarpılır. Yürürlükteki sayıyı `validation_coef()` söyler.
const VALIDATION_COEF_RESEARCHED := 1.0
## Modelin dışında, taşma koruması: doğrulanacak bildirim kalmadığında birikim en fazla
## bir birim bankalanır. Sınırsız bankalansaydı boş bir masada biriken kesir, ilk gelen
## bildirimi geldiği saniye doğrulardı — §8.2'nin "masa kapalı" hükmünü delerdi.
const VALIDATION_BANK_MAX := 1.0

# ---------------------------------------------------------- §8.3 iki kademeli zarar
## §8.3 — doğrulanmamış birikim: memnuniyet −0,6/gün her 10 GELEN başına (en ağır zarar).
const DAMAGE_INCOMING_PER_TEN := -0.6
## §8.3 — doğrulanmış-açık: −0,3/gün her 10 başına (yarısı). Düzeltilmiş: sıfır.
const DAMAGE_CONFIRMED_PER_TEN := -0.3
## Her iki kademenin de böleni. "Her 10 ... başına" ifadesinin tek evi.
const DAMAGE_PER_UNITS := 10.0
## §8.3 TAVAN (kurtarılabilir baskı): iki kademenin günlük TOPLAM zararı −2,0/gün ile
## sınırlı. İhmal ölüm sarmalı değil, ağır ama toparlanabilir bir kanamadır.
const DAMAGE_DAILY_CAP := -2.0

# ------------------------------------------------------------- §8.4 düzeltme koşusu
## §8.4 — düzeltme/gün = 1,2 × Σ etkin Yazılım × saat/8.
const FIX_COEF := 1.2

# --------------------------------------------------------------- §8.5 ısınma
## §8.5 eşikler: GELEN < 20 sakin · 20-40 ılık · > 40 sıcak. RENK BURADA YOK — belge
## yeşil/amber/kırmızı diyor, ama renk UI'nin sözlüğüdür (UI/STYLE LAW madde 1).
const WARMTH_WARM_AT := 20
const WARMTH_HOT_AT := 40
const BAND_CALM := "calm"
const BAND_WARM := "warm"
const BAND_HOT := "hot"

# ------------------------------------------------------------------ §9 ilgi
## §9 — "her yayın ilgiyi 100'e tazeler; ilgi sürüm yaşıyla söner, yarı ömür 30 gün."
## Tazeleme ProductState.refresh_on_publish()'in işi; sönüm burada.
const INTEREST_HALF_LIFE := 30.0

# ----------------------------------------------------------------- kimlikler
const MARKET_B2B := "b2b"
const MARKET_B2C := "b2c"

## §8.4 DÜZELTME BAŞLAT'ın ret kimlikleri — LineGates.ladder_refusal grameri: makine
## kimliği döner, metin dönmez. "" = koşu başlatılabilir.
const REFUSAL_NOT_LIVE := "not_live"
const REFUSAL_ALREADY_RUNNING := "already_running"
const REFUSAL_NO_BUGS := "no_confirmed_bugs"
const REFUSAL_DESK_SHUT := "desk_shut"

## SEAM MISSING — Satış tarafının kitle OKUMA seam'i yok; bugün bu bayrağı okuyan
## herkes (event_manager dahil) ham okuyor. SalesSystem'de bir `b2c_audience()`
## seam'i açılınca burası ona çevrilir; ad kopyası o gün ölür.
const B2C_AUDIENCE_FLAG := "b2c_audience"

## SEAM MISSING — §9'un `yeni_kod_eforu` girdisinin YAŞADIĞI YER YOK. FeatureBuild
## `total_efor` taşıyor ama ProductSystem.launch() onu canlı duruma damgalamıyor ve
## `mvp_*` bayrak adlarının evi olan ProductState'te de karşılığı yok. İki satırlık
## eksik, ikisi de başka dosyada:
##   1) ProductState: `const NEW_CODE_EFFORT := "mvp_new_code_effort"` + okuyucusu,
##   2) GameState.FLAG_TYPES: `"mvp_new_code_effort": TYPE_FLOAT` (kayıt şeması).
## O ikisi inene kadar ad burada duruyor ve damgasız ürün yeni-kod terimini SIFIR
## okuyor — model taban + taşınan + kullanım ile bozulmadan koşar.
const NEW_CODE_EFFORT_FLAG := "mvp_new_code_effort"

## SEAM MISSING — memnuniyet 0-100 TAM SAYIDIR (Customer.satisfaction) ve tek yazma
## seam'i CustomerRegistry.set_satisfaction(id, int). §8.3'ün zararı kesirlidir: beş
## hesaba bölünmüş bir −2,0 hesap başına −0,4 eder ve yuvarlama onu ya sıfırlar ya
## ikiye katlar. Kalıntı burada, kişi kimliği başına biriktirilir; tam birime taşınca
## seam çağrılır. KAYDA GİRMİYOR: kesirli memnuniyet için bir alan yok, yani kayıt/
## yükleme bir günden küçük kalıntıyı unutur. Kabul edilebilir kayıp (< 1 puan), ama
## kalıcı çözüm Customer'da kesirli bir memnuniyet katmanıdır.
static var _damage_residue: Dictionary = {}


# =========================================================================
#  TICK'LER — dışarıdan çağrılır, kendi kendine koşmaz
# =========================================================================

## §9 akışı + §8.2 doğrulama + §8.4 koşu. Üçü de günlük oranın 1/24'ü kadar işler.
static func hourly_tick(_hour: int) -> void:
	if not ProductState.is_live():
		return
	var f: float = 1.0 / float(HOURS_PER_DAY)
	_accrue_reports(f)
	_accrue_validation(f)
	_accrue_fix_run(f)


## §8.3 memnuniyet zararı + §9 ilgi sönümü. İkisi de belgede "/gün" yazılı.
static func daily_tick() -> void:
	if not ProductState.is_live():
		return
	apply_daily_satisfaction_damage()
	sync_interest()


## Yeni koşu / yeni kayıt. Kalıntı tablosu türetilmiş bir tampon, taşınmaz.
static func reset() -> void:
	_damage_residue.clear()


# =========================================================================
#  §9 · CANLI HATA AKIŞI
# =========================================================================

## Ar-Ge §4.3 `self_service` — YÜRÜRLÜKTEKİ akış tabanı: düğüm kapalıyken 0,20,
## tamamlandığında 0,14. Tabanı okuyan herkes buradan geçer; formülün içine ham
## sabit gömülürse düğüm o satırda sessizce ölür.
static func inflow_base() -> float:
	return INFLOW_BASE_RESEARCHED if ResearchSeam.completed("self_service") else INFLOW_BASE


## §9'un tam formülü, GÜNLÜK bildirim sayısı olarak:
##   (0,2 + 0,05 × taşınan_hata + 0,03 × yeni_kod_eforu × e^(−sürüm_yaşı/21))
##   × kullanım_çarpanı
## Canlı ürün yoksa akış yoktur — desteklenecek bir şey yok demektir.
static func reports_per_day() -> float:
	if not ProductState.is_live():
		return 0.0
	var age: float = float(ProductState.version_age_days())
	var new_code: float = new_code_effort() * exp(-age / INFLOW_TAU)
	var base: float = inflow_base() \
		+ INFLOW_CARRIED_COEF * float(carried_bugs()) \
		+ INFLOW_NEWCODE_COEF * new_code
	# §10 — altyapı akışı ÇARPAR, iki ayrı sebeple ve çarpımsal olarak: ucuz
	# sağlayıcı ×1,25 (yavaşlık şikayeti) ve doluluk %100'ün üstünde ×1,5. İkisi de
	# InfraSystem'in tek evinden okunur; burada yeniden türetilmez.
	return base * usage_multiplier() * InfraSystem.report_inflow_multiplier()


## §9 kullanım çarpanı — "farklı kullanıcı farklı hataya çarpar".
## B2C: 1 + aktif kullanıcı/2000 · B2B: 1 + hesap sayısı/10.
static func usage_multiplier() -> float:
	if ProductState.market_type() == MARKET_B2B:
		return 1.0 + float(CustomerRegistry.get_by_market(MARKET_B2B).size()) / USAGE_DIV_B2B
	return 1.0 + b2c_active_users() / USAGE_DIV_B2C


## §9 "aktif kullanıcı" — ödeyen değil, ürünü KULLANAN herkes; B2C akışının kaynağı
## kitlenin kendisidir. `CustomerRegistry.get_total_users()` yalnız ödeyeni sayar ve
## bu formülün istediği o değil.
static func b2c_active_users() -> float:
	# SEAM MISSING (B2C_AUDIENCE_FLAG'e bakınız): Satış'ta okuma seam'i yok.
	return SalesSystem.b2c_audience()


## §9 "taşınan hata" — BETA'dan canlıya taşınan açık hatalar. ProductSystem'in kendi
## okuma seam'i üzerinden alınır, ham bayraktan değil.
##
## ŞERH, bilerek işaretli: `ProductSystem.live_bug_count()` ESKİ modelin sayacıdır ve
## başlığı hâlâ "DOĞRULANMIŞ sayacının ta kendisi" diyor. Rev 6.1'de bu ikisi AYRIŞIR:
## DOĞRULANMIŞ artık `ProductState.bugs_confirmed()`, taşınan hata ise yayın anındaki
## devir. Yayında devrin DOĞRULANMIŞ'a tohumlanması (ve eski aşınma kanalının emekli
## edilmesi) ProductSystem'in işidir ve bu turda YAPILMADI. Yeniden yönlendirilecek
## tek yer burasıdır — o yüzden ayrı bir fonksiyon.
static func carried_bugs() -> int:
	return maxi(0, ProductSystem.live_bug_count())


## §9 "yeni kod eforu" — en yeni sürümün efor büyüklüğü. Damgasız ürün 0 okur ve terim
## sessizce düşer (NEW_CODE_EFFORT_FLAG'in SEAM MISSING notuna bakınız).
static func new_code_effort() -> float:
	return ProductState.new_code_effort()


## YAZMA SEAM'İ — yayın anında çağrılmalı: ProductSystem.launch(), eksenleri damgaladığı
## yerde `SupportSystem.stamp_new_code_effort(active_build.total_efor)` demeli. Sürüm
## yaşının sıfırlanması ProductState.refresh_on_publish()'in işi ve o da bugün çağrılmıyor.
static func stamp_new_code_effort(effort: float) -> void:
	GameState.set_flag(NEW_CODE_EFFORT_FLAG, maxf(0.0, effort))


# =========================================================================
#  §8.2 · DOĞRULAMA — Müşteri İlişkileri'nin işi, ATAMAYA duyarlı
# =========================================================================

## §8.2/§12.0 — DESTEK işine atanmış, bugün çalışabilir herkes. Kurucu da atanabilir ve
## sayılır (Ekip §2). İzindeki/eğitimdeki kişi HRSystem tarafında zaten eleniyor.
static func desk_roster() -> Array[Character]:
	return HRSystem.assigned_to_job(HRConstants.JOB_SUPPORT)


## §8.2 — "Destek'e kimse atanmamışsa masa KAPALIDIR: GELEN birikir, hiçbir şey
## doğrulanmaz, hiçbir şey düzeltilemez." Modülün merkez baskısı budur; boş masa
## küçük bir sızıntı değil TAM SIFIR üretir.
static func desk_staffed() -> bool:
	return not desk_roster().is_empty()


## Ar-Ge §4.3 `bug_tracker` — YÜRÜRLÜKTEKİ doğrulama katsayısı: düğüm kapalıyken
## 0,8, tamamlandığında 1,0. Katsayıyı okuyan herkes buradan geçer.
static func validation_coef() -> float:
	return VALIDATION_COEF_RESEARCHED if ResearchSeam.completed("bug_tracker") else VALIDATION_COEF


## §8.2 — doğrulama/gün = 0,8 × Σ hr.effective_skill(atanan, Mİ) × saat/8 (Ar-Ge
## sonrası 1,0 ×). `HRSystem.daily_contribution` zaten `effective_skill × saat/8`'dir
## (Ekip §4.5) — yeniden türetilmez, çağrılır. Liderlik çarpanı BU FORMÜLDE YOK: §4.2
## onu alanın toplamına uyguluyor ve §8.2 sealed formülü onu yazmıyor.
static func validation_per_day() -> float:
	if not ProductState.is_live():
		return 0.0
	return validation_coef() * _desk_sum(HRConstants.AREA_CUSTOMER_SUCCESS)


## §8.4 — düzeltme/gün = 1,2 × Σ etkin Yazılım × saat/8, yine YALNIZ Destek'e atananlar.
## Koşu yokken 0: hiçbir hata kendiliğinden çözülmez (§8.1).
static func fix_per_day() -> float:
	if not ProductState.is_live() or not ProductState.fix_run_active():
		return 0.0
	return FIX_COEF * _desk_sum(HRConstants.AREA_ENGINEERING)


## Destek masasının bir ALANDAKİ günlük toplam katkısı. İki formülün ortak yarısı.
## İki işteki kişi 0,5 odakla bölünür — `effective_skill` bunu zaten uyguluyor, yani
## koşu sırasında doğrulamanın sürmesi (§8.4) burada bedavaya gelmiyor.
static func _desk_sum(area_key: String) -> float:
	var total: float = 0.0
	for c in desk_roster():
		total += HRSystem.daily_contribution(c, area_key)
	return total


# =========================================================================
#  §8.3 · İKİ KADEMELİ ZARAR
# =========================================================================

## §8.3 üst kademe — cevapsız kullanıcı: −0,6/gün her 10 GELEN başına.
static func unvalidated_damage_per_day() -> float:
	if not ProductState.is_live():
		return 0.0
	return DAMAGE_INCOMING_PER_TEN * float(ProductState.reports_incoming()) / DAMAGE_PER_UNITS


## §8.3 alt kademe — muhatap bulmuş kullanıcı: −0,3/gün her 10 DOĞRULANMIŞ başına.
## Gerekçe belgede: hızlı yanıt alan kullanıcı, düzeltme gecikse bile hemen ayrılmaz.
static func confirmed_damage_per_day() -> float:
	if not ProductState.is_live():
		return 0.0
	return DAMAGE_CONFIRMED_PER_TEN * float(ProductState.bugs_confirmed()) / DAMAGE_PER_UNITS


## §8.3 — iki kademenin toplamı, GÜNLÜK TAVANLA sınırlı. Negatif ya da sıfır döner.
## Düzeltilmiş hata sıfır zarar verir; havuzdan çıkan hata bu toplamdan da çıkar.
static func daily_satisfaction_damage() -> float:
	# §10 aşım zararı (−0,8/gün) §8.3'ün TAVANININ İÇİNDE toplanır — belge bunu
	# açıkça söylüyor ("§8.3'ün −2,0 tavanı içinde"). Ayrı bir kanal olsaydı ihmal +
	# aşım üst üste binip −2,8'e çıkar ve "ağır ama toparlanabilir" sözü bozulurdu.
	var total: float = unvalidated_damage_per_day() + confirmed_damage_per_day() \
		+ InfraSystem.satisfaction_delta_per_day()
	return maxf(total, DAMAGE_DAILY_CAP)


## §8.3 dağıtımı — B2B'de zarar AKTİF HESAPLARA EŞİT bölünür, B2C'de küresel
## memnuniyete işler. Uygulanan (tam sayıya taşımış) toplamı döner; hesaplanan zararın
## kendisi için `daily_satisfaction_damage()` okunur.
##
## YAZMA YOLU: CustomerRegistry.set_satisfaction — başka alanın kaydına ham yazılmaz
## (WRITE-THROUGH LAW). B2C'de hedef, Satış'ın tek toplu kitle kaydıdır.
static func apply_daily_satisfaction_damage() -> float:
	var damage: float = daily_satisfaction_damage()
	if damage >= 0.0:
		return 0.0
	var targets: Array[Customer] = []
	if ProductState.market_type() == MARKET_B2B:
		targets = CustomerRegistry.get_by_market(MARKET_B2B)
	else:
		var base: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
		if base != null:
			targets.append(base)
	if targets.is_empty():
		# Ücretli kademe açılmadan toplu B2C kaydı yok; hesabı olmayan B2B'de de
		# zarar verecek kimse yok. Sayı yine okunabilir, uygulanan sıfırdır.
		return 0.0
	var share: float = damage / float(targets.size())
	var applied: float = 0.0
	for c in targets:
		applied += _bleed(c, share)
	return applied


## Kesirli zararı bir müşteriye taşır; yalnız TAM birim seam'e gider, kalanı bekler.
## (Kalıntının kayda girmediğine dair not yukarıda, _damage_residue'de.)
static func _bleed(c: Customer, share: float) -> float:
	var carried: float = float(_damage_residue.get(c.id, 0.0)) + share
	# Zarar daima negatif; tavana doğru YUVARLAMA sıfıra doğrudur (−1,2 → −1 uygula,
	# −0,2 beklet). floor kullanılsaydı yarım puanlık zarar tam puana şişerdi.
	var whole: int = int(ceil(carried))
	_damage_residue[c.id] = carried - float(whole)
	if whole == 0:
		return 0.0
	CustomerRegistry.set_satisfaction(c.id, c.satisfaction + whole)
	return float(whole)


# =========================================================================
#  §8.4 · DÜZELTME KOŞUSU
# =========================================================================

## §8.4 — "DOĞRULANMIŞ birikince DÜZELTME BAŞLAT açılır (DOĞRULANMIŞ 0 iken kapalıdır)."
## Masa kapalıysa da açılmaz: §8.2 "hiçbir şey düzeltilemez" diyor, ve kimse yokken
## başlatılan bir koşu yalnız yapımı duraklatan boş bir kabuk olurdu.
## Makine kimliği döner (LineGates.ladder_refusal grameri); "" = başlatılabilir.
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
## 27 çözüldü, 27'si gider, 8'i havuzda kalır. Sıfır beklenmez." Çözülenler koşu boyunca
## zaten havuzdan düşmüştür (DOĞRULANMIŞ iki yönlü hareket eder); bu fonksiyon koşuyu
## kapatır ve o sürümde kaç hatanın canlıya gittiğini döner.
static func end_fix_run() -> int:
	if not ProductState.fix_run_active():
		return 0
	var shipped: int = ProductState.fix_run_fixed()
	GameState.set_flag(ProductState.FIX_RUN_ACTIVE, false)
	GameState.set_flag(ProductState.FIX_RUN_FIXED, 0)
	GameState.set_flag(ProductState.FIX_RUN_PROGRESS, 0.0)
	EventBus.fix_run_finished.emit(shipped, ProductState.bugs_confirmed())   # §19
	return shipped


## §8.4 — "Koşu başlatmak aktif yapımı duraklatır." ProductSystem'e UZANMIYORUZ; o
## kendi `build_paused()`'ında bunu OKUR. Bağlanmadı: bugün ProductSystem.build_paused()
## yalnız kadro doluluğuna bakıyor, bu seam'e sormuyor (rapora yazıldı).
static func fix_run_pauses_build() -> bool:
	return ProductState.is_live() and ProductState.fix_run_active()


# =========================================================================
#  §8.5 · İHMAL ISINMASI
# =========================================================================

## §8.5 — GELEN birikimine göre kararlı bir bant kimliği: "calm" · "warm" · "hot".
## Eşikler 20 ve 40. RENK DÖNMEZ: yeşil/amber/kırmızı eşlemesi UI'nin işidir.
static func warmth_band() -> String:
	var incoming: int = ProductState.reports_incoming() if ProductState.is_live() else 0
	if incoming < WARMTH_WARM_AT:
		return BAND_CALM
	if incoming <= WARMTH_HOT_AT:
		return BAND_WARM
	return BAND_HOT


# =========================================================================
#  §9 · İLGİ
# =========================================================================

## §9 — "her yayın ilgiyi 100'e tazeler; ilgi sürüm yaşıyla söner, yarı ömür 30 gün."
## Tazeleme ProductState.refresh_on_publish()'te; sönüm burada ve SÜRÜM yaşından
## türetilir (ürün yaşından değil, §17). Saf fonksiyon: saklanan değeri okumaz.
static func interest_now() -> float:
	if not ProductState.is_live():
		return 0.0
	var age: float = float(ProductState.version_age_days())
	return ProductState.INTEREST_MAX * pow(0.5, age / INTEREST_HALF_LIFE)


## Günlük adım: türetilen ilgiyi duruma geri yazar, çünkü tüketicisi Satış/Pazarlama'dır
## ve onlar tek bir sayı okur (§18 tek kaynak: sahibi Ürün, tüketicisi Satış).
static func sync_interest() -> void:
	if not ProductState.is_live():
		return
	GameState.set_flag(ProductState.INTEREST, interest_now())


# =========================================================================
#  BİRİKİM — kesirli oranlar, tam sayı sayaçlar
# =========================================================================

## §9 — bildirimler kendiliğinden gelir. Masa kapalı olsa da gelir; §8.2'nin kapattığı
## şey doğrulamadır, akış değil.
static func _accrue_reports(day_fraction: float) -> void:
	var rate: float = reports_per_day() * day_fraction
	if rate <= 0.0:
		return
	var prog: float = float(GameState.get_flag(ProductState.REPORTS_PROGRESS, 0.0)) + rate
	var count: int = ProductState.reports_incoming()
	while prog >= 1.0:
		count += 1
		prog -= 1.0
	GameState.set_flag(ProductState.REPORTS_PROGRESS, prog)
	GameState.set_flag(ProductState.REPORTS_INCOMING, count)


## §8.2 — GELEN'i DOĞRULANMIŞ'a çevirir. Masa boşsa oran sıfırdır ve bu fonksiyon hiçbir
## şey yapmaz: boş masa küçük bir sızıntı değil, tam sıfırdır.
static func _accrue_validation(day_fraction: float) -> void:
	var rate: float = validation_per_day() * day_fraction
	if rate <= 0.0:
		return
	var prog: float = float(GameState.get_flag(ProductState.VALIDATION_PROGRESS, 0.0)) + rate
	var incoming: int = ProductState.reports_incoming()
	var confirmed: int = ProductState.bugs_confirmed()
	while prog >= 1.0 and incoming > 0:
		incoming -= 1
		confirmed += 1
		prog -= 1.0
	if incoming <= 0:
		prog = minf(prog, VALIDATION_BANK_MAX)
	GameState.set_flag(ProductState.VALIDATION_PROGRESS, prog)
	GameState.set_flag(ProductState.REPORTS_INCOMING, incoming)
	GameState.set_flag(ProductState.BUGS_CONFIRMED, confirmed)


## §8.4 — koşu DOĞRULANMIŞ'ı eritir ve çözülenleri sayar. Havuz boşalırsa koşu
## KENDİLİĞİNDEN BİTMEZ: yeni doğrulamalar gelmeye devam eder ve koşu onları da yer
## ("DOĞRULANMIŞ iki yönlü hareket eder"). Koşuyu bitiren yalnız oyuncudur.
static func _accrue_fix_run(day_fraction: float) -> void:
	var rate: float = fix_per_day() * day_fraction
	if rate <= 0.0:
		return
	var prog: float = float(GameState.get_flag(ProductState.FIX_RUN_PROGRESS, 0.0)) + rate
	var confirmed: int = ProductState.bugs_confirmed()
	var fixed: int = ProductState.fix_run_fixed()
	while prog >= 1.0 and confirmed > 0:
		confirmed -= 1
		fixed += 1
		prog -= 1.0
	if confirmed <= 0:
		prog = minf(prog, VALIDATION_BANK_MAX)
	GameState.set_flag(ProductState.FIX_RUN_PROGRESS, prog)
	GameState.set_flag(ProductState.BUGS_CONFIRMED, confirmed)
	GameState.set_flag(ProductState.FIX_RUN_FIXED, fixed)
