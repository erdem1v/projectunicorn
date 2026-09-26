class_name InfraSystem
extends RefCounted

# GDD — ÜRÜN MODÜLÜ rev 6.1 §10 · ALTYAPI. Pure-logic system, no scene, no instance,
# no autoload (ProductLines / FinanceSystem ile aynı gramer).
#
# İKİ AYRI KARAR (MÜHÜRLÜ, §10): "Altyapı iki ayrı karardır: kimden alıyorsun
# (SAĞLAYICI: birim fiyat + kalite) ve ne kadar alıyorsun (KAPASİTE: talebe göre artıp
# azalan miktar). Tek sütuna sıkıştırılmaz." Bu dosya ikisini de ayrı tutar: sağlayıcı
# bir kimlik + fiyat tablosu satırıdır, kapasite ±1 birim adımlı bir sayıdır ve ikisi
# birbirinin yerine geçemez.
#
# KENDİ KENDİNE TİKLEMEZ. `daily_tick()` dışarı açıktır; TimeManager'ın sıralı
# dispatch'ine bağlanması AYRI bir iştir. Bağlanacağı yer:
# ProductSystem (slot 1) SONRASI, FinanceSystem (slot 5) ÖNCESİ — sunucu faturası
# Finans'ın o günkü burn toplamına yetişsin diye.
#
# NE YAPMAZ (§18 tek kaynak kuralları · CLAUDE.md WRITE-THROUGH LAW):
#   · Memnuniyeti YAZMAZ. §10'un −0,8/gün'ünü sayı olarak açar; §8.3'ün −2,0/gün
#     tavanını uygulayan DESTEK'tir, burası değil.
#   · GELEN akışını ve B2C edinimini YAZMAZ. Çarpanları açar; uygulayan sahipleridir.
#   · OLAY KUYRUĞUNA DOKUNMAZ. Sarı banttaki "Sunucular yoruluyor." kartı için yalnız
#     `due_capacity_warning()` bayrağını ve tüketim seam'ini verir.
#   · Rastgele kesinti YOK (§10: "uyarısız kayıp yasağı"). Ucuz sağlayıcının bedeli
#     deterministiktir; bu dosyada RNG kullanılmaz.
#
# HASAR KALICI DEĞİLDİR (§10). Bu yüzden burada BİRİKTİREN bir alan yoktur: aşımın her
# etkisi o anki durumdan TÜRETİLİR, kapasite eklendiği an sıfırlanır. Saklanan tek şey
# sürüm başına bir kez düşen uyarı kartının mandalıdır.


# ============================================================================
#  §10 · Sağlayıcılar [K] — mühürlü tablo
# ============================================================================

const PROVIDER_LOCAL := "local"             # Yerel Sağlayıcı
const PROVIDER_CLOUD := "cloud"             # Bulut Sağlayıcı
const PROVIDER_ENTERPRISE := "enterprise"   # Kurumsal Bulut

## Merdiven sırası: ucuzdan pahalıya. Seçim ekranı bu sırayı okur.
const PROVIDER_IDS := ["local", "cloud", "enterprise"]

## §10 [K] — B2C birim fiyatı; BİR BİRİM = 1.000 KULLANICI/AY.
const UNIT_PRICE_B2C := {"local": 35, "cloud": 55, "enterprise": 85}

## §10 [K] — B2B birim fiyatı; BİR BİRİM = 50 KOLTUK/AY.
const UNIT_PRICE_B2B := {"local": 30, "cloud": 45, "enterprise": 70}

## §10 — birim büyüklükleri. Fiyat tablosunun iki sütunu bu iki sayı yüzünden ayrıdır.
const USERS_PER_UNIT_B2C := 1000
const SEATS_PER_UNIT_B2B := 50

## §10 kalite farkı — Yerel: "GELEN bildirim akışı ×1,25 (yavaşlık şikayeti)". Sağlayıcı
## kaynaklı, aşımdan BAĞIMSIZ bir çarpandır; ikisi aynı anda geçerliyse ÇARPILIRLAR.
const LOCAL_INFLOW_MULT := 1.25

## Pazar kimlikleri — fiyat sütununu ve birim boyunu seçen tek ayrım (§10).
const MARKET_B2C := "b2c"
const MARKET_B2B := "b2b"


# ============================================================================
#  §10 · Yük ve etkin kapasite
# ============================================================================

## §10 [K] — "yük = 1 + Σağırlık / 20". Ağırlığın kendisi ProductLines'ın kademe
## alanıdır (0–3) ve toplamı ProductState.usage_weight_total() türetir.
## TEK BAŞINA ADLI SABİT olmak zorunda: Ar-Ge'nin `scalable_backend` düğümü bu böleni
## 20 → 28 yapar ve ResearchSeam.NODE_EFFECTS bu sabiti ADIYLA gösterir.
const LOAD_DIVISOR := 20.0

## Ar-Ge §4.2 `scalable_backend` — AYNI bölenin araştırılmış hâli (20 → 28). Taban
## sabiti adıyla ve değeriyle YERİNDE DURUR: düğüm tamamlanmadan yük hesabı hâlâ 20
## ile bölünür ve `LOAD_DIVISOR`'ı adıyla okuyan ölçümler dürüst kalır. Kalibrasyonun
## eline tek sihirli literal değil, ADI OLAN İKİ SAYI geçsin diye böyle: hangisinin
## yürürlükte olduğunu `load_divisor()` söyler.
const LOAD_DIVISOR_RESEARCHED := 28.0

## §10 — yükün tabanı. Ağırlık toplamı 0 iken yük 1,0'dır: hiçbir kademe yayınlamamış
## ürün satın aldığı kapasitenin tamamını kullanır.
const LOAD_BASE := 1.0

## §10 — kapasite ±1 birim adımlarla her an artırılıp azaltılır, CEZASIZ. Taban 0:
## sağlayıcısını seçmemiş ya da kapasitesini sıfırlamış ürün meşru bir durumdur.
const CAPACITY_STEP := 1
const CAPACITY_MIN := 0

## §10 — v1 yayın akışının Altyapı adımındaki öneri satırı ("Tahmini ilk ay:
## ~1.000 kullanıcı"). ÖNERİDİR, kural değil: oyuncu istediği birimle başlayabilir.
const SUGGESTED_START_UNITS := 1


# ============================================================================
#  §10 · Doluluk ve aşım [K]
# ============================================================================

## §10 — "< %80 normal · %80–100 sararır · > %100 aşım".
const OCCUPANCY_AMBER := 0.80
const OCCUPANCY_OVER := 1.00

## §10 aşım etkileri [K]. ÜÇÜ DE BU DOSYADA UYGULANMAZ; sahiplerine sayı olarak açılır.
## OVERAGE_SATISFACTION Ar-Ge'nin `incident_playbook` düğümünün hedefidir (−0,8 → −0,5),
## o yüzden adı ResearchSeam.NODE_EFFECTS'te yazdığı gibidir.
const OVERAGE_SATISFACTION := -0.8      # memnuniyet/gün — DESTEK uygular, §8.3'ün −2,0 tavanı içinde
const OVERAGE_INFLOW_MULT := 1.5        # GELEN akışı çarpanı — DESTEK uygular
const OVERAGE_ACQUISITION_MULT := 0.6   # B2C edinim çarpanı — SATIŞ uygular

## Ar-Ge §4.3 `incident_playbook` — aşımın memnuniyet zararının araştırılmış hâli
## (−0,8 → −0,5). Taban sabiti ADIYLA VE DEĞERİYLE kalır, çünkü ikisi de doğrudur:
## düğüm kapalıyken uygulanan sayı odur ve smoke tam olarak onu (`OVERAGE_SATISFACTION`
## == −0,8) ölçüyor. Araştırılmış değeri o adın üstüne yazmak ölçümü yalancı yapardı.
## Uygulayan yine DESTEK'tir; §8.3'ün −2,0/gün tavanı orada, burada değil.
const OVERAGE_SATISFACTION_RESEARCHED := -0.5

## Çarpan yokluğunun tek adı. "1.0 döndür" üç yerde tekrar edeceğine burada durur.
const NEUTRAL_MULT := 1.0

## Kapasite çubuğunun durumu — İÇ kimlikler (İngilizce), ekrana ham yazılmaz.
const STATE_NORMAL := "normal"
const STATE_AMBER := "amber"
const STATE_OVER := "over"
const STATE_UNPROVISIONED := "unprovisioned"   # canlı ürün yok ya da hiç kapasite alınmamış


# ============================================================================
#  Finans · lokalizasyon anahtarları
# ============================================================================

## §10 — "Fatura günlük olarak burn'e işler (aylık/30)." Yinelenen gider olduğu için
## FinanceSystem'in burn KATEGORİSİ kanalından gider, tek seferlik gider kanalından
## değil. Kategori kimliği İngilizce ve içseldir; ekrandaki ad FinanceSystem'in kendi
## türetmesinden (FIN_BURN_<ID>) gelir.
const BURN_CATEGORY := "servers"

## Oyuncu-yüzü metin bu dosyada YOK (Bilingual Birth Law). Anahtarlar burada durur;
## satırlarını strings.csv'ye eklemek ayrı bir iştir.
const KEY_PROVIDER_NAME_PREFIX := "PROD_INFRA_PROVIDER_"    # + LOCAL | CLOUD | ENTERPRISE
const KEY_PROVIDER_QUALITY_PREFIX := "PROD_INFRA_QUALITY_"  # + LOCAL | CLOUD | ENTERPRISE
const KEY_WARN_TITLE := "PROD_INFRA_WARN_TITLE"             # "Sunucular yoruluyor."
const KEY_WARN_BODY := "PROD_INFRA_WARN_BODY"
const KEY_WARN_RAISE := "PROD_INFRA_WARN_RAISE"             # kapasite artır
const KEY_WARN_WAIT := "PROD_INFRA_WARN_WAIT"               # şimdilik bekle
const KEY_START_HINT := "PROD_INFRA_START_HINT"             # {users} yer tutuculu öneri satırı


# ============================================================================
#  Durum · koşu sınırı
# ============================================================================

## §10 — "sürüm başına bir kez olay kartı düşer". Mandal: kartı TÜKETİLMİŞ sürüm
## numarası. Sürüm ilerlediği an yeniden düşebilir hale gelir.
## NOT: sağlayıcı ve kapasitenin kendisi burada DEĞİL, ürün durumunda yaşar
## (ProductState.INFRA_PROVIDER / INFRA_UNITS) — kayıt yolu zaten oradan geçiyor.
static var _warning_consumed_version: int = 0

## Eksik Finans kategorisi için tek seferlik gürültü mandalı (aşağıdaki SEAM MISSING).
static var _burn_seam_warned: bool = false


## Run boundary. FinanceSystem.reset() ile aynı gramer; SaveManager'ın yeni-koşu
## yolundan çağrılması gerekir (HENÜZ BAĞLI DEĞİL).
static func reset() -> void:
	_warning_consumed_version = 0
	_burn_seam_warned = false


static func to_dict() -> Dictionary:
	# Yalnız mandal. Sağlayıcı/kapasite GameState'in bayrak torbasında taşındığı için
	# (v9 şeması §22.5) burada TEKRAR yazılmaz — iki kopya ilk yüklemede ayrışırdı.
	return {"warning_consumed_version": _warning_consumed_version}


static func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	_warning_consumed_version = int(d.get("warning_consumed_version", 0))
	_burn_seam_warned = false


# ============================================================================
#  Okumalar — sağlayıcı ve kapasite
# ============================================================================

static func is_provider(provider_id: String) -> bool:
	return PROVIDER_IDS.has(provider_id)


## Seçili sağlayıcı, ya da henüz seçilmemişse "". Ham bayrağa kimse uzanmaz: adın evi
## ProductState'tir (§18).
static func provider() -> String:
	return ProductState.infra_provider()


## Satın alınan BİRİM sayısı (kullanıcı/koltuk değil). Negatife düşemez.
static func units() -> int:
	return maxi(ProductState.infra_units(), CAPACITY_MIN)


## Pazarın birim büyüklüğü: B2C'de 1.000 kullanıcı, B2B'de 50 koltuk (§10).
## Pazarı henüz belli olmayan ürün B2C okur — v1 akışının varsayılan yolu.
static func unit_size(market: String = "") -> int:
	var m: String = market if market != "" else ProductState.market_type()
	return SEATS_PER_UNIT_B2B if m == MARKET_B2B else USERS_PER_UNIT_B2C


## §10 tablosu — bir birimin aylık fiyatı. Bilinmeyen sağlayıcı 0 döner ve BAĞIRIR;
## boş sağlayıcı (henüz seçilmemiş) sessizce 0'dır, çünkü meşru bir durumdur.
static func unit_price(provider_id: String, market: String = "") -> int:
	if provider_id == "":
		return 0
	if not is_provider(provider_id):
		push_error("[InfraSystem] unit_price on unknown provider '%s'" % provider_id)
		return 0
	var m: String = market if market != "" else ProductState.market_type()
	var table: Dictionary = UNIT_PRICE_B2B if m == MARKET_B2B else UNIT_PRICE_B2C
	return int(table.get(provider_id, 0))


static func current_unit_price() -> int:
	return unit_price(provider(), ProductState.market_type())


## Sağlayıcı adının ve kalite farkı satırının lokalizasyon anahtarları — kimlikten
## TÜRETİLİR, ayrıca saklanmaz (ProductLines'ın anahtar grameri).
static func provider_name_key(provider_id: String) -> String:
	return KEY_PROVIDER_NAME_PREFIX + provider_id.to_upper()


static func provider_quality_key(provider_id: String) -> String:
	return KEY_PROVIDER_QUALITY_PREFIX + provider_id.to_upper()


# ============================================================================
#  Okumalar — yük, etkin kapasite, doluluk
# ============================================================================

## Ar-Ge §4.2 `scalable_backend` — YÜRÜRLÜKTEKİ bölen. Düğüm kapalıyken taban (20),
## tamamlandığında araştırılmış değer (28). Böleni okuyan HERKES buradan geçer; ham
## sabite uzanan bir çağrı yeri kalırsa düğüm o yolda sessizce ölür.
static func load_divisor() -> float:
	return LOAD_DIVISOR_RESEARCHED if ResearchSeam.completed("scalable_backend") else LOAD_DIVISOR


## §10 — yük = 1 + Σağırlık / 20 (Ar-Ge sonrası / 28). Canlı ürün yokken taban 1,0'dır
## (bölme yok).
static func load_factor() -> float:
	if not ProductState.is_live():
		return LOAD_BASE
	return LOAD_BASE + float(ProductState.usage_weight_total()) / load_divisor()


## Satın alınan kapasitenin KULLANICI/KOLTUK cinsinden karşılığı — birim × birim boyu.
static func purchased_capacity() -> int:
	return units() * unit_size()


## §10 — etkin kapasite = satın alınan kapasite / yük. Ağır kademe yayınlamak kalıcı
## bir işletme maliyetidir: aynı birim sayısı daha az kullanıcı taşır.
static func effective_capacity() -> float:
	var lf: float = load_factor()
	if lf <= 0.0:
		return 0.0   # ulaşılamaz (yük ≥ LOAD_BASE); yine de bölme korumasız kalmaz
	return float(purchased_capacity()) / lf


## §10 — doluluğun payı: B2C'de mevcut kullanıcı, B2B'de koltuk.
## B2C tarafında bu ÖDEYEN sayısı değil, canlı KULLANICI TABANIDIR (deneyen de sunucuda
## durur); SalesSystem'in saatlik akışı bu sayıyı büyütüp küçültür.
static func served_count() -> int:
	if not ProductState.is_live():
		return 0
	if ProductState.market_type() == MARKET_B2B:
		return CustomerRegistry.get_total_seats()
	# SEAM MISSING (read): SalesSystem'in `b2c_audience` bayrağı için adlı bir okuma
	# seam'i yok; sistemler bayrağı doğrudan okuyor (sales_system.gd:191-192, 251). Ürün
	# bayrağı olmadığı için ProductState'e ait de değil. Bir SalesSystem.b2c_audience()
	# okuması doğduğunda burası oraya çevrilmeli.
	return int(floor(SalesSystem.b2c_audience()))


## §10 — doluluk = mevcut kullanıcı (B2C) ya da koltuk (B2B) / etkin kapasite.
## KAPASİTE 0 İKEN 0,0 DÖNER ve bu bir ölçüm değil, "çizilecek bir şey yok" demektir:
## kullanıcı varken kapasite yoksa doluluk sonsuzdur ve o durumun kararı
## `is_over_capacity()` / `capacity_state()` ile verilir — ikisi de bölme yapmaz.
static func occupancy() -> float:
	var cap: float = effective_capacity()
	if cap <= 0.0:
		return 0.0
	return float(served_count()) / cap


## Çubuğun yüzdesi — "doluluk çubuğu (mevcut / etkin kapasite · %)" satırı için.
static func occupancy_pct() -> int:
	return int(round(occupancy() * 100.0))


## §10 aşım kapısı. BÖLME YOK: kapasitesi olmayan ama kullanıcısı olan ürün de aşımdır,
## ve o durumda bir oran hesaplamak sıfıra bölmek olurdu.
static func is_over_capacity() -> bool:
	if not ProductState.is_live():
		return false
	var served: int = served_count()
	if served <= 0:
		return false
	var cap: float = effective_capacity()
	if cap <= 0.0:
		return true
	return float(served) / cap > OCCUPANCY_OVER


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


# ============================================================================
#  Oyuncu kararları — §10, ikisi de her an, cezasız
# ============================================================================

## §10 — "Sağlayıcı canlıda her an değiştirilebilir; göç bedeli yoktur, yeni fiyat bir
## sonraki günden itibaren işler." Göç bedeli olmadığı için burada hiçbir tahsilat yok;
## "bir sonraki günden itibaren" ise faturanın YALNIZ `daily_tick()` içinde
## yayımlanmasından gelir — bugünün burn'ü bu sabah zaten yazıldı, değişiklik ilk kez
## yarınki tik'te fiyatlanır. Bekleyen-sağlayıcı diye ikinci bir durum TUTULMAZ.
static func set_provider(provider_id: String) -> bool:
	if not is_provider(provider_id):
		push_error("[InfraSystem] set_provider on unknown provider '%s'" % provider_id)
		return false
	# SEAM MISSING (write): ProductState bu iki alan için write-through seam taşımıyor
	# (yalnız infra_provider() / infra_units() okumaları var). Bayrağın ADI yine tek
	# evinden alınıyor, literal "mvp_..." yazılmıyor. ProductState.set_infra_provider /
	# set_infra_units doğduğunda buradaki iki yazma oraya çevrilmeli.
	ProductState.set_infra_provider(provider_id)
	return true


## §10 — kapasite ±1 birim adımlarla, her an, cezasız. Tavan yoktur; taban 0'dır.
## Yerleşen birim sayısını döndürür.
static func set_capacity(new_units: int) -> int:
	var clamped: int = maxi(new_units, CAPACITY_MIN)
	ProductState.set_infra_units(clamped)
	return clamped


## Adım adım artır/azalt. `steps` işaretlidir (+1 / −1); CAPACITY_STEP adımın boyudur.
static func adjust_capacity(steps: int) -> int:
	return set_capacity(units() + steps * CAPACITY_STEP)


## v1 yayın akışının Altyapı adımındaki öneri: birim sayısı ve o birimin karşıladığı
## kullanıcı/koltuk. Metin KEY_START_HINT'ten gelir, buradan değil.
static func suggested_start_units() -> int:
	return SUGGESTED_START_UNITS


static func suggested_start_headroom() -> int:
	return SUGGESTED_START_UNITS * unit_size()


# ============================================================================
#  §10 · Fatura ve brüt marj
# ============================================================================

## §10 — "aylık fatura = birim sayısı × birim fiyatı". Canlı ürün yoksa 0.
static func monthly_bill() -> int:
	if not ProductState.is_live():
		return 0
	return units() * current_unit_price()


## §10 — "Fatura günlük olarak burn'e işler (aylık/30)." Bölen GameState'in tek evinden
## (DAYS_PER_MONTH) gelir; FinanceSystem MRR→günlük gelir çevrimini de oradan yapıyor.
static func daily_bill() -> int:
	return int(round(float(monthly_bill()) / float(GameState.DAYS_PER_MONTH)))


## §10 — "Brüt marj = MRR − sunucu faturası; monitörde gösterilir, Finans tüketir."
## İkisi de AYLIK büyüklüktür.
static func gross_margin_monthly() -> int:
	return GameState.mrr - monthly_bill()


# ============================================================================
#  Sahiplerine açılan sayılar — hiçbiri burada UYGULANMAZ
# ============================================================================

## Ar-Ge §4.3 `incident_playbook` — YÜRÜRLÜKTEKİ aşım zararı: düğüm kapalıyken
## −0,8/gün, tamamlandığında −0,5/gün. Zararı okuyan herkes buradan geçer.
static func overage_satisfaction() -> float:
	return OVERAGE_SATISFACTION_RESEARCHED if ResearchSeam.completed("incident_playbook") else OVERAGE_SATISFACTION


## §10 aşımının memnuniyet zararı, gün başına. DESTEK bunu kendi iki kademeli zararına
## ekler ve §8.3'ün −2,0/gün tavanını UYGULAYAN odur; burada tavan yoktur.
static func satisfaction_delta_per_day() -> float:
	if not ProductState.is_live():
		return 0.0
	return overage_satisfaction() if is_over_capacity() else 0.0


## GELEN bildirim akışının çarpanı. İki kaynak ÇARPILIR: ucuz sağlayıcının yavaşlık
## şikayeti (×1,25) sağlayıcı seçiminden, aşım (×1,5) doluluktan gelir — biri diğerinin
## yerine geçmez, ikisi birden yaşanabilir (§10'un iki ayrı kararı).
static func report_inflow_multiplier() -> float:
	if not ProductState.is_live():
		return NEUTRAL_MULT
	var mult: float = NEUTRAL_MULT
	if provider() == PROVIDER_LOCAL:
		mult *= LOCAL_INFLOW_MULT
	if is_over_capacity():
		mult *= OVERAGE_INFLOW_MULT
	return mult


## §10 — "B2C edinim ×0,6". YALNIZ B2C: belge B2B tarafında bir edinim çarpanı
## yazmıyor, o yüzden B2B pazarda nötr döner (uydurulmuş bir B2B karşılığı YOK).
static func acquisition_multiplier() -> float:
	if not ProductState.is_live() or ProductState.market_type() != MARKET_B2C:
		return NEUTRAL_MULT
	return OVERAGE_ACQUISITION_MULT if is_over_capacity() else NEUTRAL_MULT


## §10 + §15 — Kurumsal Bulut "büyük hesabın imza öncesi güven koşulunu karşılar".
## Ar-Ge §4.2 `security_cert` bu kapının İKİNCİ YOLUDUR: belge düğümü "balina imza
## koşulu (Kurumsal Bulut'a ikinci yol)" diye tanımlıyor, yani sertifika kurumsal
## sağlayıcının YERİNE geçer — onu ucuzlatmaz, koşulu kendi başına karşılar. Kapı,
## sayının sahibi olan sistemde durduğu için §9'un tek kaynak kuralı bozulmuyor.
## DİKKAT: `blocks_enterprise_signature()` bundan AYRI bir engeldir (Yerel Sağlayıcı
## seçiliyken imza yok) ve sertifika onu KALDIRMAZ; §10 o engeli sağlayıcıya bağlıyor.
static func meets_enterprise_trust() -> bool:
	return provider() == PROVIDER_ENTERPRISE or ResearchSeam.completed("security_cert")


## §10 — Yerel Sağlayıcı seçiliyken "kurumsal hesap imzalamaz". Satışın imza kapısı
## bunu okur; engel SAĞLAYICI kaynaklıdır, dolulukla ilgisi yoktur.
static func blocks_enterprise_signature() -> bool:
	return provider() == PROVIDER_LOCAL


# ============================================================================
#  §10 · Sürüm başına bir kez düşen uyarı kartı
# ============================================================================

## Kart DÜŞMEYE HAZIR mı. Olayı BU DOSYA KUYRUĞA KOYMAZ; koyan taraf kartı gösterdikten
## sonra `mark_capacity_warning_shown()` çağırır.
##
## HÜKÜM (tek yargı çağrısı): §10 kartı %80–100 BANDINA
## bağlar. Burada eşik "≥ %80" olarak okunuyor, yani aşım da kartı hak eder. Sebep:
## doluluk bir günde %70'ten %120'ye sıçrayabilir ve dar band okunsaydı o sürümde kart
## HİÇ düşmezdi — "uyarısız kayıp yasağı"nın (§10) tam tersi. Bandı birebir istersek
## tek satır: `st == STATE_AMBER`.
static func due_capacity_warning() -> bool:
	if not ProductState.is_live():
		return false
	if _warning_consumed_version == ProductState.version():
		return false
	var st: String = capacity_state()
	return st == STATE_AMBER or st == STATE_OVER


## Kart bu sürüm için tüketildi. Sürüm ilerlediğinde mandal kendiliğinden açılır.
static func mark_capacity_warning_shown() -> void:
	_warning_consumed_version = ProductState.version()


## Kartın metin anahtarları tek yerden — olayı kuran taraf bunları okur, kendi
## anahtarını uydurmaz.
static func capacity_warning_keys() -> Dictionary:
	return {
		"title": KEY_WARN_TITLE,
		"body": KEY_WARN_BODY,
		"raise": KEY_WARN_RAISE,
		"wait": KEY_WARN_WAIT,
	}


# ============================================================================
#  Günlük tik — dışarıdan bağlanır
# ============================================================================

## Günün TEK işi faturayı yayımlamaktır. Aşımın üç etkisi burada BİRİKTİRİLMEZ: §10
## "hasar kalıcı değildir" diyor, o yüzden hepsi okuma anında türetilir ve kapasite
## eklendiği an — bir sonraki tik beklenmeden — durur.
static func daily_tick() -> void:
	_publish_daily_bill()


static func _publish_daily_bill() -> void:
	var bill: int = daily_bill()
	# SEAM MISSING (write): FinanceSystem'de "servers" burn kategorisi YOK. Doğru seam
	# `FinanceSystem.set_burn_category` ama BURN_IDS / STARTING_BURN_BREAKDOWN kimliği
	# tanımadığı için bugün push_warning ile geri çevirir. Kategori eklendiği gün bu
	# satır kendiliğinden akmaya başlar; burada hiçbir değişiklik gerekmez.
	if not FinanceSystem.get_burn_breakdown().has(BURN_CATEGORY):
		if bill > 0 and not _burn_seam_warned:
			_burn_seam_warned = true
			push_warning(("[InfraSystem] FinanceSystem has no '%s' burn category; " +
				"the $%d/day server bill is computed but never reaches burn")
				% [BURN_CATEGORY, bill])
		return
	FinanceSystem.set_burn_category(BURN_CATEGORY, bill)
