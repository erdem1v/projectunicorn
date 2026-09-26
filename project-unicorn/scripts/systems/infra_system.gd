class_name InfraSystem
extends RefCounted

# GDD — ÜRÜN MODÜLÜ rev 6.1 §10 · ALTYAPI. Saf mantık; durum ProductState'te yaşar
# (INFRA_PROVIDER / INFRA_UNITS), burada yalnız kurallar ve türetilmiş okumalar var.
#
# İKİ AYRI KARAR (§10): SAĞLAYICI (birim fiyat + kalite) ve KAPASİTE (±1 birim adımlı
# miktar). Tek sütuna sıkıştırılmaz; biri diğerinin yerine geçmez.
#
# Aşımın etkileri (memnuniyet, GELEN akışı, B2C edinimi) burada UYGULANMAZ; sayı olarak
# sahiplerine (DESTEK, SATIŞ) açılır. Rastgele kesinti yok (§10 "uyarısız kayıp yasağı"),
# o yüzden RNG da yok. Hasar kalıcı değildir: her etki o anki durumdan türetilir ve
# kapasite eklendiği an durur.


# ---------------------------------------------------------------- §10 sağlayıcılar [K]

const PROVIDER_LOCAL := "local"
const PROVIDER_CLOUD := "cloud"
const PROVIDER_ENTERPRISE := "enterprise"

## Merdiven sırası, ucuzdan pahalıya; seçim ekranı bu sırayı okur.
const PROVIDER_IDS := [PROVIDER_LOCAL, PROVIDER_CLOUD, PROVIDER_ENTERPRISE]

## B2C birim fiyatı; bir birim = 1.000 kullanıcı/ay.
const UNIT_PRICE_B2C := {"local": 35, "cloud": 55, "enterprise": 85}
## B2B birim fiyatı; bir birim = 50 koltuk/ay.
const UNIT_PRICE_B2B := {"local": 30, "cloud": 45, "enterprise": 70}

const USERS_PER_UNIT_B2C := 1000
const SEATS_PER_UNIT_B2B := 50

## Yerel: "GELEN bildirim akışı ×1,25 (yavaşlık şikayeti)". Aşımdan bağımsızdır; ikisi
## aynı anda geçerliyse çarpılırlar.
const LOCAL_INFLOW_MULT := 1.25

const MARKET_B2C := "b2c"
const MARKET_B2B := "b2b"


# ---------------------------------------------------------------- §10 yük ve kapasite

## "yük = 1 + Σağırlık / 20". Ar-Ge `scalable_backend` böleni 28'e çıkarır; yürürlükteki
## değeri load_divisor() söyler.
const LOAD_DIVISOR := 20.0
const LOAD_DIVISOR_RESEARCHED := 28.0
const LOAD_BASE := 1.0

## Kapasite ±1 birim, her an, cezasız. Taban 0: sağlayıcısız ya da sıfırlanmış ürün meşrudur.
const CAPACITY_STEP := 1
const CAPACITY_MIN := 0

## v1 yayın akışının öneri satırı ("Tahmini ilk ay: ~1.000 kullanıcı"); kural değil.
const SUGGESTED_START_UNITS := 1


# ---------------------------------------------------------------- §10 doluluk ve aşım [K]

## "< %80 normal · %80–100 sararır · > %100 aşım".
const OCCUPANCY_AMBER := 0.80
const OCCUPANCY_OVER := 1.00

## Aşım etkileri. OVERAGE_SATISFACTION'ı DESTEK uygular (§8.3'ün −2,0/gün tavanı orada);
## Ar-Ge `incident_playbook` onu −0,5'e indirir, yürürlükteki değeri overage_satisfaction()
## söyler. Taban sabit adıyla kalır: düğüm kapalıyken uygulanan sayı odur ve smoke onu ölçer.
const OVERAGE_SATISFACTION := -0.8
const OVERAGE_SATISFACTION_RESEARCHED := -0.5
const OVERAGE_INFLOW_MULT := 1.5        # GELEN akışı çarpanı — DESTEK uygular
const OVERAGE_ACQUISITION_MULT := 0.6   # B2C edinim çarpanı — SATIŞ uygular

## Kapasite çubuğunun durumu (iç kimlikler, ekrana ham yazılmaz).
const STATE_NORMAL := "normal"
const STATE_AMBER := "amber"
const STATE_OVER := "over"
const STATE_UNPROVISIONED := "unprovisioned"   # canlı ürün yok ya da hiç kapasite alınmamış

## "Fatura günlük olarak burn'e işler (aylık/30)": yinelenen gider, FinanceSystem'in burn
## kategorisi kanalından gider.
const BURN_CATEGORY := "servers"

const KEY_START_HINT := "PROD_INFRA_START_HINT"   # {users} yer tutuculu öneri satırı


# ---------------------------------------------------------------- durum

## §10 — "sürüm başına bir kez olay kartı düşer". Kartı tüketilmiş sürüm numarası; sürüm
## ilerleyince kart yeniden düşebilir. Kart henüz bağlı değil: mandal kayda ve
## SaveManager.reset_all_owners'a girmiyor.
static var _warning_consumed_version: int = 0


static func reset() -> void:
	_warning_consumed_version = 0


static func to_dict() -> Dictionary:
	return {"warning_consumed_version": _warning_consumed_version}


static func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	_warning_consumed_version = int(d.get("warning_consumed_version", 0))


# ---------------------------------------------------------------- sağlayıcı ve kapasite

static func is_provider(provider_id: String) -> bool:
	return PROVIDER_IDS.has(provider_id)


## Seçili sağlayıcı; henüz seçilmemişse "".
static func provider() -> String:
	return ProductState.infra_provider()


## Satın alınan BİRİM sayısı (kullanıcı/koltuk değil).
static func units() -> int:
	return maxi(ProductState.infra_units(), CAPACITY_MIN)


## B2C'de 1.000 kullanıcı, B2B'de 50 koltuk. Pazarı henüz belli olmayan ürün B2C okur.
static func unit_size(market: String = "") -> int:
	return SEATS_PER_UNIT_B2B if _is_b2b(market) else USERS_PER_UNIT_B2C


## Bir birimin aylık fiyatı. Boş sağlayıcı (henüz seçilmemiş) meşrudur ve 0'dır;
## bilinmeyen sağlayıcı 0 döner ve bağırır.
static func unit_price(provider_id: String, market: String = "") -> int:
	if provider_id == "":
		return 0
	if not is_provider(provider_id):
		push_error("[InfraSystem] unit_price on unknown provider '%s'" % provider_id)
		return 0
	return int((UNIT_PRICE_B2B if _is_b2b(market) else UNIT_PRICE_B2C)[provider_id])


static func _is_b2b(market: String) -> bool:
	return (market if market != "" else ProductState.market_type()) == MARKET_B2B


static func provider_name_key(provider_id: String) -> String:
	return "PROD_INFRA_PROVIDER_" + provider_id.to_upper()


static func provider_quality_key(provider_id: String) -> String:
	return "PROD_INFRA_QUALITY_" + provider_id.to_upper()


# ---------------------------------------------------------------- yük, etkin kapasite, doluluk

## Yükü okuyan herkes buradan geçer; ham sabite uzanan çağrı Ar-Ge düğümünü o yolda öldürür.
static func load_divisor() -> float:
	return LOAD_DIVISOR_RESEARCHED if ResearchSeam.completed("scalable_backend") else LOAD_DIVISOR


static func load_factor() -> float:
	if not ProductState.is_live():
		return LOAD_BASE
	return LOAD_BASE + float(ProductState.usage_weight_total()) / load_divisor()


## Satın alınan kapasite, kullanıcı/koltuk cinsinden.
static func purchased_capacity() -> int:
	return units() * unit_size()


## §10 — etkin kapasite = satın alınan / yük: ağır kademe yayınlamak kalıcı bir işletme
## maliyetidir, aynı birim daha az kullanıcı taşır.
static func effective_capacity() -> float:
	return float(purchased_capacity()) / load_factor()


## Doluluğun payı: B2B'de koltuk, B2C'de canlı KULLANICI TABANI (ödeyen değil; deneyen de
## sunucuda durur).
static func served_count() -> int:
	if not ProductState.is_live():
		return 0
	if ProductState.market_type() == MARKET_B2B:
		return CustomerRegistry.get_total_seats()
	return int(floor(SalesSystem.b2c_audience()))


## Kapasite 0 iken 0,0 döner: bu bir ölçüm değil "çizilecek bir şey yok" demektir. Kullanıcı
## varken kapasite yoksa aşım kararını is_over_capacity() verir.
static func occupancy() -> float:
	var cap: float = effective_capacity()
	if cap <= 0.0:
		return 0.0
	return float(served_count()) / cap


static func occupancy_pct() -> int:
	return int(round(occupancy() * 100.0))


## Kapasitesi olmayan ama kullanıcısı olan ürün de aşımdadır; o yüzden oran bölmeden okunur.
static func is_over_capacity() -> bool:
	var served: int = served_count()
	if served <= 0:
		return false
	var cap: float = effective_capacity()
	return cap <= 0.0 or float(served) / cap > OCCUPANCY_OVER


## Çubuğun durumu tek yerde karar verilir; UI kendi eşiğini kurmaz (§18).
static func capacity_state() -> String:
	if not ProductState.is_live():
		return STATE_UNPROVISIONED
	if is_over_capacity():
		return STATE_OVER
	if purchased_capacity() <= 0:
		return STATE_UNPROVISIONED
	if occupancy() >= OCCUPANCY_AMBER:
		return STATE_AMBER
	return STATE_NORMAL


# ---------------------------------------------------------------- oyuncu kararları

## §10 — "Sağlayıcı canlıda her an değiştirilebilir; göç bedeli yoktur, yeni fiyat bir
## sonraki günden itibaren işler." Fatura yalnız daily_tick()'te yayımlandığı için bugünün
## burn'ü zaten yazılmıştır; bekleyen-sağlayıcı durumu gerekmez.
static func set_provider(provider_id: String) -> bool:
	if not is_provider(provider_id):
		push_error("[InfraSystem] set_provider on unknown provider '%s'" % provider_id)
		return false
	ProductState.set_infra_provider(provider_id)
	return true


## Tavan yok, taban CAPACITY_MIN. Yerleşen birim sayısını döndürür.
static func set_capacity(new_units: int) -> int:
	var clamped: int = maxi(new_units, CAPACITY_MIN)
	ProductState.set_infra_units(clamped)
	return clamped


## `steps` işaretlidir (+1 / −1).
static func adjust_capacity(steps: int) -> int:
	return set_capacity(units() + steps * CAPACITY_STEP)


static func suggested_start_units() -> int:
	return SUGGESTED_START_UNITS


static func suggested_start_headroom() -> int:
	return SUGGESTED_START_UNITS * unit_size()


# ---------------------------------------------------------------- §10 fatura ve brüt marj

## "aylık fatura = birim sayısı × birim fiyatı". Canlı ürün yoksa 0.
static func monthly_bill() -> int:
	if not ProductState.is_live():
		return 0
	return units() * unit_price(provider())


static func daily_bill() -> int:
	return int(round(float(monthly_bill()) / float(GameState.DAYS_PER_MONTH)))


## "Brüt marj = MRR − sunucu faturası"; ikisi de aylık.
static func gross_margin_monthly() -> int:
	return GameState.mrr - monthly_bill()


# ---------------------------------------------------------------- sahiplerine açılan sayılar

static func overage_satisfaction() -> float:
	return OVERAGE_SATISFACTION_RESEARCHED if ResearchSeam.completed("incident_playbook") else OVERAGE_SATISFACTION


## Gün başına memnuniyet zararı; §8.3'ün −2,0 tavanını DESTEK uygular.
static func satisfaction_delta_per_day() -> float:
	return overage_satisfaction() if is_over_capacity() else 0.0


## GELEN akışı çarpanı: ucuz sağlayıcının yavaşlığı (×1,25) ve aşım (×1,5) ayrı kararlardan
## gelir ve çarpılır.
static func report_inflow_multiplier() -> float:
	if not ProductState.is_live():
		return 1.0
	var mult: float = 1.0
	if provider() == PROVIDER_LOCAL:
		mult *= LOCAL_INFLOW_MULT
	if is_over_capacity():
		mult *= OVERAGE_INFLOW_MULT
	return mult


## "B2C edinim ×0,6". Belge B2B için edinim çarpanı yazmıyor; B2B nötr döner.
static func acquisition_multiplier() -> float:
	if ProductState.market_type() == MARKET_B2C and is_over_capacity():
		return OVERAGE_ACQUISITION_MULT
	return 1.0


## §10 + §15 — Kurumsal Bulut büyük hesabın imza öncesi güven koşulunu karşılar; Ar-Ge
## `security_cert` aynı koşulun ikinci yoludur. blocks_enterprise_signature() bundan ayrı
## bir engeldir ve sertifika onu kaldırmaz.
static func meets_enterprise_trust() -> bool:
	return provider() == PROVIDER_ENTERPRISE or ResearchSeam.completed("security_cert")


## §10 — Yerel Sağlayıcı seçiliyken "kurumsal hesap imzalamaz". Engel sağlayıcı kaynaklıdır.
static func blocks_enterprise_signature() -> bool:
	return provider() == PROVIDER_LOCAL


# ---------------------------------------------------------------- §10 uyarı kartı

## Kart düşmeye hazır mı. Kartı kuyruğa koyan taraf gösterdikten sonra
## mark_capacity_warning_shown() çağırır.
## §10 kartı %80–100 bandına bağlar; burada aşım da kartı hak eder, çünkü doluluk bir günde
## %70'ten %120'ye sıçrayabilir ve dar band o sürümde kartı hiç düşürmezdi.
static func due_capacity_warning() -> bool:
	if _warning_consumed_version == ProductState.version():
		return false
	return capacity_state() in [STATE_AMBER, STATE_OVER]


static func mark_capacity_warning_shown() -> void:
	_warning_consumed_version = ProductState.version()


# ---------------------------------------------------------------- günlük tik

## TimeManager ürün slotunda, DESTEK'ten sonra koşar. Günün tek işi faturayı yayımlamaktır.
static func daily_tick() -> void:
	FinanceSystem.set_burn_category(BURN_CATEGORY, daily_bill())
