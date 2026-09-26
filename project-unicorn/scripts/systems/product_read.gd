class_name ProductRead
extends RefCounted

# GDD — ÜRÜN MODÜLÜ rev 6.1 §19 · OKUMA YÜZEYİ — olay motoruna açılan katalog.
#
# "Sorgular (adlar kararlı)" — belgedeki `urun.X` adlarının kod karşılığı
# `ProductRead.X`'tir. Önek Türkçe olduğu için sınıf adı İngilizce kaldı (kod
# tabanı yalnız İngilizcedir, Ekip §16); eşleme birebir ve başka hiçbir yerde
# yeniden adlandırılmaz.
#
# NEDEN ŞİMDİ, TÜKETİCİSİ YOKKEN: §19'un kendi gerekçesi. "Attribution yazım yasası
# (mühürlü): olaylar motorun okumadığı hiçbir şeyi iddia edemez." Bu katalog o
# yasanın SÖZLÜĞÜDÜR — eksik bir ad, içeriğin o duruma asla atıfta bulunamaması
# demektir. Olay motoru geldiğinde işi bunları OKUMAK olacak, keşfetmek değil.
#
# `product_id` parametreleri belgedeki imzayı korumak için var ve bugün YOK SAYILIR:
# çoklu ürün Erken Erişim'in konusu (§1), demo'da tek ürün vardır. İmzayı şimdi
# doğru yazmak, o gün çağrı yerlerini değil yalnız gövdeleri değiştirmek demek.

## §2 — beş fazdan hangisi. Yapım yoksa canlı ürün DESTEK'tedir; ürün de yoksa "".
const PHASE_NONE := ""
const PHASE_CONCEPT := "concept"
const PHASE_DESIGN := "design"
const PHASE_DEVELOPMENT := "development"
const PHASE_BETA := "beta"
const PHASE_SUPPORT := "support"

## Motorun iç faz dizgelerinden §19'un kararlı adlarına. İç adlar tarihsel
## ("iteration"/"bugfix"); dışarıya sızmazlar.
const _PHASE_MAP := {
	"planning": PHASE_CONCEPT,
	"iteration": PHASE_DESIGN,
	"development": PHASE_DEVELOPMENT,
	"bugfix": PHASE_BETA,
}


static func phase(_product_id: String = "") -> String:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b != null:
		return String(_PHASE_MAP.get(b.current_phase, PHASE_NONE))
	# §2 — DESTEK KALICIDIR; ürün yaşadıkça sürer.
	return PHASE_SUPPORT if ProductState.is_live() else PHASE_NONE


static func build_active() -> bool:
	return ProductSystem.get_active_build() != null


## §11.3 — 0-120 okuması. Üçgenin çizdiği ve tabanların (§14) karşılaştırdığı sayı.
static func axis_reading(_product_id: String, axis: String) -> int:
	return ProductState.axis_reading(axis)


## §19 — önde / hizada / geride. SORGU VARDIR, EKRANDA HİÇBİR YERDE RENDER EDİLMEZ:
## olay metni düzyazıda kullanabilir, monitör kullanamaz (§17'nin üçgen kuralı).
const WORD_AHEAD := "onde"
const WORD_LEVEL := "hizada"
const WORD_BEHIND := "geride"
## Çıtanın etrafındaki "hizada" bandı: okuma 100 çıtanın tam kendisidir.
const MARKET_WORD_BAND := 10


static func market_word(_product_id: String, axis: String) -> String:
	var r: int = ProductState.axis_reading(axis)
	if r >= 100 + MARKET_WORD_BAND:
		return WORD_AHEAD
	if r <= 100 - MARKET_WORD_BAND:
		return WORD_BEHIND
	return WORD_LEVEL


## §8.1 — DOĞRULANMIŞ HATA (açık, onaylanmış).
static func confirmed_open(_product_id: String = "") -> int:
	return ProductState.bugs_confirmed()


## §8.1 — GELEN BİLDİRİM (henüz doğrulanmamış).
static func unconfirmed(_product_id: String = "") -> int:
	return ProductState.reports_incoming()


## §17 — SÜRÜM yaşı, ürün yaşı DEĞİL.
static func version_age(_product_id: String = "") -> int:
	return ProductState.version_age_days()


## §9 — kullanım: akış modelinin çarpanını besleyen sayı (B2C kitle, B2B hesap).
static func usage(_product_id: String = "") -> float:
	return SupportSystem.usage_multiplier()


## §12.1 — hattın durumu: 0 (boş) · 1 · 2 · 3.
static func line_tier(_product_id: String, line_id: String) -> int:
	return ProductState.line_tier(line_id)


## §12.3 — hattın sıradaki kademesinin kimliği; hat tamamlandıysa "".
static func line_next_step(_product_id: String, line_id: String) -> String:
	var nxt: int = ProductLines.next_tier(ProductState.line_tier(line_id))
	if nxt == 0:
		return ""
	return String(ProductLines.step_at(line_id, nxt).get("id", ""))


static func lines_open(_product_id: String = "") -> int:
	return ProductState.lines_open()


## §12.10 — koşu profilinin ölçüldüğü sayı (3-5 sürüm, 9-14 kademe).
static func steps_shipped(_product_id: String = "") -> int:
	return ProductState.steps_shipped()


## §9 — her yayında 100'e tazelenir, yarı ömür 30 gün.
static func interest(_product_id: String = "") -> float:
	return SupportSystem.interest_now()


## §10 — satın alınan kapasite birimi. "Kademe" belgenin sözcüğü; birim sayısıdır.
static func capacity_tier(_product_id: String = "") -> int:
	return ProductState.infra_units()


## §8.2 — masada kimse var mı. Boş masa = hiçbir şey doğrulanmaz, hiçbir şey
## düzeltilemez; modülün merkez baskısı bu tek boolean'dan okunur.
static func support_staffed(_product_id: String = "") -> bool:
	return SupportSystem.desk_staffed()


## §12.5/§12.7 — kademe ŞU AN alınabilir mi (kapılar karşılandı mı). Merdiven
## kuralını sormaz; o Konsept'in işi (validate_line_plan).
static func step_unlockable(step_id: String) -> bool:
	return LineGates.is_unlocked(step_id)


# =========================================================================
#  §19 · SİNYALLER — dinleyicisi olmasa da yayınlanır
# =========================================================================
# Adlar EventBus'ta yaşıyor (tek sinyal merkezi). Bu bölüm onları
# YAYINLAYAN tek yerdir: bir sinyalin iki emitter'ı olursa olay motoru aynı olayı
# iki kez görür ve sebebini bulmak imkânsızlaşır.

## §14 — taban merdiveninin ilk iki basamağı. "Uyarısız kayıp yoktur": önce yumuşak
## sinyal, sonra tabanın kendisi. Üçüncü basamak (kriz) olay motorunun işi.
const FLOOR_WARNING_MARGIN := 1.20

static func market_floors(market: String) -> Dictionary:
	# §14 [K] — B2B İ25 · K40 · D30 · B2C İ35 · K20 · D35.
	if market == "b2b":
		return {"innovation": 25, "stability": 40, "experience": 30}
	return {"innovation": 35, "stability": 20, "experience": 35}


## Her eksen için tabanın durumunu döndürür: "" · "warning" · "crossed".
static func axis_floor_state(axis: String) -> String:
	if not ProductState.is_live():
		return ""
	var floor_v: float = float(market_floors(ProductState.market_type()).get(axis, 0))
	if floor_v <= 0.0:
		return ""
	var r: float = float(ProductState.axis_reading(axis))
	if r < floor_v:
		return "crossed"
	if r < floor_v * FLOOR_WARNING_MARGIN:
		return "warning"
	return ""


# ---------------------------------------------------------------- edges
# Yedi sinyal bir KENARDIR: durum değiştiği anda bir kez atarlar, her gün değil.
# Kenar tespiti önceki değeri bilmeyi gerektiriyor ve o hafıza BURADA duruyor —
# tek yerde, çünkü iki yerde tutulsaydı iki farklı "önceki" doğar ve sinyal ya
# çifter atar ya hiç atmaz. Kayda YAZILMAZ: bir yükleme sonrası ilk gün sessiz
# geçer, ki bu doğrudur (kaydı açan oyuncuya dünkü kenarı bildirmek yanlış olurdu).

static var _prev_paused := false
static var _prev_confirmed := 0
static var _prev_band := ""
static var _prev_floor := {}
static var _prev_phase := 0
static var _seeded := false


static func reset() -> void:
	_prev_paused = false
	_prev_confirmed = 0
	_prev_band = ""
	_prev_floor = {}
	_prev_phase = 0
	_seeded = false


## Günün sonunda çağrılır (TimeManager, sistemler yerleştikten SONRA). İlk çağrı
## yalnız hafızayı tohumlar ve hiçbir şey yayınlamaz.
static func emit_edges() -> void:
	var paused: bool = ProductSystem.build_paused()
	var confirmed: int = ProductState.bugs_confirmed()
	var band: String = SupportSystem.warmth_band()
	var phase_now: int = GameState.phase
	var floors: Dictionary = {}
	for axis in QualityModel.AXES:
		floors[axis] = axis_floor_state(String(axis))

	if not _seeded:
		_seeded = true
		_prev_paused = paused
		_prev_confirmed = confirmed
		_prev_band = band
		_prev_floor = floors
		_prev_phase = phase_now
		return

	if paused != _prev_paused:
		if paused:
			EventBus.build_paused.emit(ProductSystem.pause_note_key())
		else:
			EventBus.build_resumed.emit()
	# §8.1 — bir bildirim DOĞRULANDIĞINDA. Düşüş (düzeltme) bu sinyali atmaz.
	if confirmed > _prev_confirmed:
		EventBus.bug_confirmed.emit(confirmed)
	# §8.5 — ısınma bandı değişti (eşikler 20 · 40).
	if band != _prev_band:
		EventBus.unconfirmed_threshold_crossed.emit(band)
	# §14 — taban merdiveninin ilk iki basamağı, her eksen için ayrı.
	for axis_f in floors:
		var was: String = String(_prev_floor.get(axis_f, ""))
		var now: String = String(floors[axis_f])
		if now == was:
			continue
		if now == "warning":
			EventBus.axis_floor_warning.emit(String(axis_f))
		elif now == "crossed":
			EventBus.axis_floor_crossed.emit(String(axis_f))
	# §11.3 — çıta her faz geçişinde +%10 yükselir. "Yerinde durmak görece gerilemektir."
	if phase_now > _prev_phase:
		EventBus.phase_bar_raised.emit(phase_now)

	_prev_paused = paused
	_prev_confirmed = confirmed
	_prev_band = band
	_prev_floor = floors
	_prev_phase = phase_now
