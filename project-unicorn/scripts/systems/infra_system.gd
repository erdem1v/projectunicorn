class_name InfraSystem
extends RefCounted

# GDD — ÜRÜN MODÜLÜ rev 6.1 §10 · ALTYAPI. Saf mantık; durum ProductState'te yaşar
# (INFRA_PROVIDER / INFRA_UNITS / INFRA_AUTO ...), burada yalnız kurallar ve türetilmiş okumalar var.
#
# İKİ AYRI KARAR (§10): SAĞLAYICI (birim fiyat + kesinti çarpanı) ve KAPASİTE (birim sayısı). Tek sütuna
# sıkıştırılmaz; biri diğerinin yerine geçmez. Kapasiteyi yalnız oyuncunun düğmeleri ve açtığı otomatik ayar
# değiştirir; satın alınan kapasite kullanılabilen kapasitedir. Dolu sunucunun tek bedeli kesinti ihtimalidir
# (IncidentSystem.load_mult): ne memnuniyete, ne bildirim akışına, ne edinime gizli bir çarpan girer. RNG yok.


# ---------------------------------------------------------------- §10 sağlayıcılar [K]

const PROVIDER_LOCAL := "local"
const PROVIDER_CLOUD := "cloud"
const PROVIDER_ENTERPRISE := "enterprise"

## Merdiven sırası, ucuzdan pahalıya; seçim ekranı bu sırayı okur.
const PROVIDER_IDS := [PROVIDER_LOCAL, PROVIDER_CLOUD, PROVIDER_ENTERPRISE]

## B2C birim fiyatı; bir birim = 1.000 kullanıcı/ay.
const UNIT_PRICE_B2C := {"local": 125, "cloud": 250, "enterprise": 500}
## B2B birim fiyatı; bir birim = 50 koltuk/ay.
const UNIT_PRICE_B2B := {"local": 60, "cloud": 120, "enterprise": 240}

const USERS_PER_UNIT_B2C := 1000
const SEATS_PER_UNIT_B2B := 50

## Ekonomik: "GELEN bildirim akışı ×1,25 (yavaşlık şikayeti)".
const LOCAL_INFLOW_MULT := 1.25

const MARKET_B2B := "b2b"


# ---------------------------------------------------------------- §10 kapasite ve yük [K]

## Bir düğme basışı mevcut birimin onda biridir, en az bir birim; hemen işler, cezasızdır. Taban 0: sağlayıcısız ya
## da sıfırlanmış ürün meşrudur.
const CAPACITY_STEP_SHARE := 0.10
const CAPACITY_MIN := 0

## MVP'de açılan bulut kapasitesi (SprintBridges.on_mvp); kural değil.
const SUGGESTED_START_UNITS := 1

## Yük çubuğunun çizgileri, yüzde: %90 üstünde sarı (kesinti ihtimali artar), %100 üstünde kırmızı (kapasite yetmiyor).
const LOAD_AMBER := 90
const LOAD_OVER := 100
## Kapasitesi olmayan ama kullanıcısı olan ürünün yükü: hiçbir çizgiyi tutmaz.
const LOAD_UNBOUNDED := 999

## Otomatik ayar: yük %80'e varınca kapasite, yükü yaklaşık %65'e indirecek en küçük tam birime büyür; hiç küçülmez.
const AUTO_EDGE := 80
const AUTO_TARGET := 65

## Büyüme satırı: son haftaların hızıyla yük önümüzdeki haftalarda %90'ı geçecekse söylenir.
const GROWTH_LOOKBACK_WEEKS := 4
const GROWTH_HORIZON_WEEKS := 4

## Kapasite çubuğunun durumu (iç kimlikler, ekrana ham yazılmaz).
const STATE_NORMAL := "normal"
const STATE_AMBER := "amber"
const STATE_OVER := "over"
const STATE_UNPROVISIONED := "unprovisioned"   # canlı ürün yok ya da hiç kapasite alınmamış

## "Fatura günlük olarak burn'e işler (aylık/30)": yinelenen gider, FinanceSystem'in burn
## kategorisi kanalından gider.
const BURN_CATEGORY := "servers"


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
static func unit_size() -> int:
	return SEATS_PER_UNIT_B2B if ProductState.market_type() == MARKET_B2B else USERS_PER_UNIT_B2C


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


## Satın alınan kapasite, kullanıcı/koltuk cinsinden.
static func purchased_capacity() -> int:
	return units() * unit_size()


## Doluluğun payı: B2B'de koltuk, B2C'de canlı KULLANICI TABANI (ödeyen değil; deneyen de
## sunucuda durur).
static func served_count() -> int:
	if not ProductState.is_live():
		return 0
	if ProductState.market_type() == MARKET_B2B:
		return CustomerRegistry.get_total_seats()
	return int(floor(SalesSystem.b2c_audience()))


## Hizmet edilen ÷ `at_units` birimin kapasitesi, tam yüzde ve yukarı yuvarlanır: 90 gösteren yük 90'ın üstünde değildir.
## Çizgilerin, ipuçlarının ve kesinti çarpanının tek okuması budur.
static func load_percent(at_units: int = -1) -> int:
	var capacity: int = (units() if at_units < 0 else at_units) * unit_size()
	var served: int = served_count()
	if capacity <= 0:
		return LOAD_UNBOUNDED if served > 0 else 0
	return ceili(float(served * 100) / float(capacity))


## Hizmet edilenin `percent` yük altında kalacağı en az birim sayısı.
static func units_for_load(percent: int) -> int:
	return ceili(float(served_count() * 100) / float(unit_size() * percent))


static func is_over_capacity() -> bool:
	return load_percent() > LOAD_OVER


## Çubuğun durumu tek yerde karar verilir; UI kendi eşiğini kurmaz (§18).
static func capacity_state() -> String:
	if not ProductState.is_live():
		return STATE_UNPROVISIONED
	if is_over_capacity():
		return STATE_OVER
	if purchased_capacity() <= 0:
		return STATE_UNPROVISIONED
	return STATE_AMBER if load_percent() > LOAD_AMBER else STATE_NORMAL


## Son haftaların hızıyla yük `GROWTH_HORIZON_WEEKS` hafta içinde %90'ı geçecekse kaç hafta sonra geçeceği, yoksa 0.
static func weeks_to_amber() -> int:
	var seen: Array = ProductState.infra_served_weeks()
	var capacity: int = purchased_capacity()
	if seen.size() < 2 or capacity <= 0 or load_percent() > LOAD_AMBER:
		return 0
	var pace: float = float(int(seen.back()) - int(seen.front())) / float(seen.size() - 1)
	if pace <= 0.0:
		return 0
	var weeks: int = floori((capacity * LOAD_AMBER / 100.0 - served_count()) / pace) + 1
	return weeks if weeks <= GROWTH_HORIZON_WEEKS else 0


# ---------------------------------------------------------------- oyuncu kararları

## Ekonomik ile Standart arasında geçiş her an ve bedelsizdir; yeni fiyat bir sonraki günden işler (fatura yalnız
## daily_tick()'te yayımlandığı için bugünün burn'ü zaten yazılmıştır). Kurumsal'a geçiş geri dönüşsüzdür ve hesapların
## sunucu maddelerini karşılar: kural burada, çünkü seçici, posta düğmesi, bot ve debug aynı kapıdan geçer.
static func set_provider(provider_id: String) -> bool:
	if not is_provider(provider_id):
		push_error("[InfraSystem] set_provider on unknown provider '%s'" % provider_id)
		return false
	if provider() == PROVIDER_ENTERPRISE and provider_id != PROVIDER_ENTERPRISE:
		return false
	var moves_up: bool = provider_id == PROVIDER_ENTERPRISE and provider() != PROVIDER_ENTERPRISE
	ProductState.set_infra_provider(provider_id)
	if moves_up:
		B2BSalesSystem.meet_clauses()
	return true


## Tavan yok, taban CAPACITY_MIN. Yerleşen birim sayısını döndürür.
static func set_capacity(new_units: int) -> int:
	var clamped: int = maxi(new_units, CAPACITY_MIN)
	ProductState.set_infra_units(clamped)
	return clamped


## Bir düğme basışının birimi: mevcut birimin onda biri, en az bir.
static func capacity_step() -> int:
	return maxi(1, roundi(units() * CAPACITY_STEP_SHARE))


## `direction` işaretlidir (+1 Artır / −1 Azalt).
static func adjust_capacity(direction: int) -> int:
	return set_capacity(units() + direction * capacity_step())


static func suggested_start_units() -> int:
	return SUGGESTED_START_UNITS


## Otomatik ayar, saatlik çağrılır: anahtar açıkken yük eşiğe varınca kapasite yükü hedefe indirecek en küçük tam birime
## büyür, hiç küçülmez; bekleme yok, bir değerlendirmede en çok bir büyüme. Son büyüme blokta yazar.
static func auto_adjust() -> void:
	if not ProductState.infra_auto() or load_percent() < AUTO_EDGE:
		return
	var grown: int = units_for_load(AUTO_TARGET)
	ProductState.set_infra_auto_last({"day": GameState.day, "old": purchased_capacity(), "new": grown * unit_size()})
	set_capacity(grown)


# ---------------------------------------------------------------- §10 fatura

## "aylık fatura = birim sayısı × birim fiyatı", mevcut sağlayıcıda ya da `on_provider`'da. Canlı ürün yoksa 0.
static func monthly_bill(on_provider: String = "") -> int:
	if not ProductState.is_live():
		return 0
	return units() * unit_price(on_provider if on_provider != "" else provider())


static func daily_bill() -> int:
	return FinanceSystem.daily_rate(monthly_bill())


# ---------------------------------------------------------------- sahiplerine açılan sayılar

## GELEN akışı çarpanı: ucuz sağlayıcının yavaşlığı (×1,25).
static func report_inflow_multiplier() -> float:
	return LOCAL_INFLOW_MULT if ProductState.is_live() and provider() == PROVIDER_LOCAL else 1.0


## Kartların okuduğu güven koşulu (`urun.enterprise_trust`): Kurumsal sunucu ya da Ar-Ge `security_cert`. Sözleşmenin
## sunucu maddesini yalnız Kurumsal sunucu karşılar, sertifika karşılamaz (B2BSalesSystem).
static func meets_enterprise_trust() -> bool:
	return provider() == PROVIDER_ENTERPRISE or ResearchSeam.completed("security_cert")


# ---------------------------------------------------------------- günlük tik

## TimeManager ürün slotunda, DESTEK'ten sonra koşar. Günün işi sunucu faturasını yayımlamak ve haftanın hizmet edilen
## sayısını büyüme satırının geçmişine yazmaktır.
static func daily_tick() -> void:
	FinanceSystem.set_burn_category(BURN_CATEGORY, daily_bill())
	if ProductState.is_live():
		var seen: Array = ProductState.infra_served_weeks()
		seen.append(served_count())
		ProductState.set_infra_served_weeks(seen.slice(-(GROWTH_LOOKBACK_WEEKS + 1)))
