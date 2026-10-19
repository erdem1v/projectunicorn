class_name ProductRead
extends RefCounted

# GDD — ÜRÜN MODÜLÜ rev 6.1 §19 · OKUMA YÜZEYİ — olay motoruna açılan katalog.
#
# Belgedeki `urun.X` adlarının kod karşılığı `ProductRead.X`'tir; eşleme birebir ve
# başka hiçbir yerde yeniden adlandırılmaz. §19: "olaylar motorun okumadığı hiçbir
# şeyi iddia edemez" — eksik bir ad, içeriğin o duruma asla atıfta bulunamaması demektir.
#
# `product_id` parametreleri belgedeki imzayı korur ve YOK SAYILIR: çoklu ürün Erken
# Erişim'in konusu (§1), demo'da tek ürün vardır.

## §8.1 — açık hata (doğrulanmış, düzeltilmemiş), bütün hatlarda.
static func open_bugs(_product_id: String = "") -> int:
	return ProductState.open_bugs()


## En çok açık hatası olan hattın açık hatası; hata yoksa 0.
static func worst_line_bugs(_product_id: String = "") -> int:
	return ProductState.line_bugs(ProductState.worst_bug_line())


## §8.1 — GELEN BİLDİRİM (henüz doğrulanmamış).
static func unconfirmed(_product_id: String = "") -> int:
	return ProductState.reports_incoming()


## §17 — SÜRÜM yaşı hafta olarak, ürün yaşı DEĞİL.
static func version_age(_product_id: String = "") -> int:
	return ProductState.version_age_weeks()


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
## kuralını sormaz; o sprint kataloğunun işi.
static func step_unlockable(step_id: String) -> bool:
	return LineGates.is_unlocked(step_id)


# =========================================================================
#  §19 · SİNYALLER — dinleyicisi olmasa da yayınlanır
# =========================================================================
# Adlar EventBus'ta yaşıyor; bu bölüm onları YAYINLAYAN tek yerdir. İki emitter
# olursa olay motoru aynı olayı iki kez görür.

## §14 — taban merdiveninin ilk iki basamağı, yalnız B2C'de. "Uyarısız kayıp yoktur": önce yumuşak sinyal, sonra tabanın
## kendisi. Alanın seviyesi ürün sayfasının referansına (kitle) bölünür; oran ilkinin altına inince "warning", ikincisinin
## altına inince "crossed". Üçüncü basamak (kriz) olay motorunun işi. [WORKING] onay bekliyor.
const FLOOR_WARNING_RATIO := 0.6
const FLOOR_CROSSED_RATIO := 0.4

## Merdivenin alanları: {alan: seviye ÷ beklenti}. Gelir kaliteye girmediği için yok, beklentisi 0 olan alan da yok. B2B'de
## ve canlı ürün yokken boş: B2B'de geride kalmanın dili satış kaybıdır.
static func floor_ratios() -> Dictionary:
	var out: Dictionary = {}
	if not ProductState.is_live() or ProductState.market_type() != "b2c":
		return out
	for area in ProductQuality.weights("b2c", ""):
		var expect: float = ProductQuality.expectation(area)
		if expect > 0.0:
			out[area] = ProductQuality.level(area) / expect
	return out


## Oranın basamağı: "" · "warning" · "crossed".
static func floor_state(ratio: float) -> String:
	if ratio < FLOOR_CROSSED_RATIO:
		return "crossed"
	return "warning" if ratio < FLOOR_WARNING_RATIO else ""


## En düşük oranlı alan ve basamağı ({area, state}); oranlar eşitse öndeki. Hiçbir alan uyarıya inmediyse ikisi de boş.
static func worst_floor() -> Dictionary:
	var ratios: Dictionary = floor_ratios()
	var worst: String = ""
	for area in ratios:
		if worst == "" or ratios[area] < ratios[worst]:
			worst = area
	var state: String = floor_state(ratios[worst]) if worst != "" else ""
	return {"area": worst if state != "" else "", "state": state}


# ---------------------------------------------------------------- edges
# Sinyaller bir KENARDIR: durum değiştiği anda bir kez atarlar, her gün değil.
# Önceki değerin hafızası TEK YERDE, burada durur; iki yerde tutulsaydı sinyal ya
# çifter atar ya hiç atmazdı. Kayda YAZILMAZ: yüklemeden sonraki ilk gün yalnız
# tohumlar, çünkü kaydı açan oyuncuya dünkü kenarı bildirmek yanlış olurdu.

static var _prev_open := 0
static var _prev_band := ""
static var _prev_floor := {}
static var _seeded := false


## Sonraki emit_edges yalnız tohumlar; öteki alanlar orada üzerine yazılır.
static func reset() -> void:
	_seeded = false


## Günün sonunda çağrılır (TimeManager, sistemler yerleştikten SONRA).
static func emit_edges() -> void:
	var open: int = ProductState.open_bugs()
	var band: String = SupportSystem.warmth_band()
	var ratios: Dictionary = floor_ratios()
	var floors: Dictionary = {}
	for area in ratios:
		floors[area] = floor_state(ratios[area])

	if _seeded:
		# §8.1 — bir bildirim DOĞRULANDIĞINDA. Düşüş (düzeltme) bu sinyali atmaz.
		if open > _prev_open:
			EventBus.bug_confirmed.emit(open)
		# §8.5 — ısınma bandı değişti.
		if band != _prev_band:
			EventBus.unconfirmed_threshold_crossed.emit(band)
		# §14 — taban merdiveninin ilk iki basamağı, her alan için ayrı.
		for area in floors:
			var now: String = floors[area]
			if now == _prev_floor.get(area, ""):
				continue
			if now == "warning":
				EventBus.axis_floor_warning.emit(area)
			elif now == "crossed":
				EventBus.axis_floor_crossed.emit(area)

	_seeded = true
	_prev_open = open
	_prev_band = band
	_prev_floor = floors
