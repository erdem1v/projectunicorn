class_name ProductQuality
extends RefCounted

# Ürünün tek kalitesi: alanların seviyesi, sektörün alan ağırlıkları ve müşterinin beklentisine göre ürün uyumu U.
# Yalnız okur. Çekirdek giriş biletidir: Çekirdek'i geride kalan ürünün uyumu, öteki alanlar ne kadar iyi olursa
# olsun, Çekirdek oranının CORE_LEAD üstüne çıkamaz. Ekonomi yuvarlanmamış seviyeyi okur; ekran yarıma yuvarlanmışı gösterir.

## "Ürün uyumu" metninin anahtarı.
const LABEL_KEY := "SALES_MOD_PRODUCT_FIT"
## Her beklenen alanı tam beklentide olan ürünün U'su.
const FIT_SCALE := 70.0
const RATIO_CAP := 1.5       # [WORKING] onay bekliyor: bir alana aşırı yatırım sınırsız getirmesin
## Uyum, Çekirdek oranının en çok bu kadar üstüne çıkar.
const CORE_LEAD := 0.25
const W_CORE := 0.50
## B2B: sektörün vurgu 1, vurgu 2 ve kalan alanının ağırlığı.
const W_B2B := [0.25, 0.15, 0.10]
## B2C: Çekirdek'ten kalan ağırlığı eşit bölen alanlar. Gelir kaliteye girmez, fiyatın konusudur.
const B2C_AREAS := ["onboarding", "growth", "trust"]

## Sektörün alanları: vurgu 1, vurgu 2, kalan. Tanınmayan sektör (fikstür sektörleri) alıcı tipi varsayılanının
## ilk sektörünün satırını okur.
const TABLE := {
	"health": ["trust", "integrations", "onboarding"],
	"finance": ["trust", "integrations", "onboarding"],
	"insurance": ["integrations", "trust", "onboarding"],
	"legal": ["integrations", "trust", "onboarding"],
	"logistics": ["integrations", "trust", "onboarding"],
	"construction": ["onboarding", "trust", "integrations"],
	"ecommerce": ["trust", "integrations", "onboarding"],
	"retail": ["trust", "integrations", "onboarding"],
	"technology": ["integrations", "trust", "onboarding"],
	"manufacturing": ["integrations", "trust", "onboarding"],
	"real_estate": ["onboarding", "integrations", "trust"],
	"textile": ["integrations", "onboarding", "trust"],   # [WORKING] onay bekliyor
	"media": ["trust", "onboarding", "integrations"],     # [WORKING] onay bekliyor
}


## Alanın ağırlıkları, toplamı 1. Toplama sırası Çekirdek, vurgu 1, vurgu 2, kalandır. B2C'de `sector` boştur.
static func weights(market: String, sector: String) -> Dictionary:
	var out: Dictionary = {"core": W_CORE}
	if market == "b2c":
		for area in B2C_AREAS:
			out[area] = (1.0 - W_CORE) / B2C_AREAS.size()
		return out
	var row: Array = _row(sector)
	for i in row.size():
		out[row[i]] = W_B2B[i]
	return out


## [vurgu 1, vurgu 2]; B2C'de (sektör boş) boş.
static func emphasis(sector: String) -> Array:
	return [] if sector == "" else _row(sector).slice(0, 2)


## Alanın yuvarlanmamış seviyesi: hatlarının kademe + cila ortalaması.
static func level(area: String) -> float:
	return SprintCatalog._raw_level(area)


## Seviyenin beklentiye oranı, RATIO_CAP'te kesik. Beklentisi 0 olan alan için çağrılmaz.
static func ratio(area: String, expect: float) -> float:
	return _ratio(level(area), expect)


## Ürün uyumu. `ctx`: `market` ("b2b" | "b2c"), `sector` (B2C'de ""), `ref` ({alan: beklenti}; beklentisi 0 olan
## alan sayılmaz). U: 0-100. `match`: tavandan sonraki uyum. `capped`: tavan devrede. `loss_area`: müşterinin eksik
## bulacağı alan (tavan devredeyse Çekirdek, değilse beklentisinin altındaki alanların en zayıfı, yoksa "").
## `weakest_emphasis`: oranı en düşük vurgu alanı. `note`: Çekirdek ve o alanın kelimesi.
static func fit(ctx: Dictionary) -> Dictionary:
	var levels: Dictionary = {}
	for area in ctx.ref:
		levels[area] = level(area)
	return fit_from_levels(levels, ctx)


## `fit`, alan seviyeleri verilmiş hâliyle.
static func fit_from_levels(levels: Dictionary, ctx: Dictionary) -> Dictionary:
	var w: Dictionary = weights(ctx.market, ctx.sector)
	var ratios: Dictionary = {}
	var weighted: float = 0.0
	var total: float = 0.0
	for area in w:
		var expect: float = float(ctx.ref.get(area, 0.0))
		if expect > 0.0:
			ratios[area] = _ratio(float(levels[area]), expect)
			weighted += w[area] * ratios[area]
			total += w[area]
	var mean: float = weighted / total
	var ceiling: float = ratios.core + CORE_LEAD
	var capped: bool = mean > ceiling
	var uyum: float = minf(mean, ceiling)
	var weakest: String = _lowest(emphasis(ctx.sector), ratios)
	var lowest: String = _lowest(ratios.keys(), ratios)
	var note: Array = []
	for area in ["core", weakest]:
		if ratios.has(area):
			note.append({"area": area, "word": SprintCatalog.word_for(float(levels[area]), float(ctx.ref[area]))})
	return {"value": mini(100, roundi(FIT_SCALE * uyum)), "match": uyum, "capped": capped,
		"weakest_emphasis": weakest,
		"loss_area": "core" if capped else (lowest if ratios[lowest] < 1.0 else ""),
		"note": note, "label_key": LABEL_KEY}


static func _ratio(lvl: float, expect: float) -> float:
	return minf(lvl / expect, RATIO_CAP)


static func _row(sector: String) -> Array:
	return TABLE.get(sector, TABLE[SalesArchetypes.sectors(SalesArchetypes.DEFAULT_ID)[0]]) as Array


## `areas` içinde oranı en düşük alan; eşitlikte öndeki. Oranı olan alan yoksa "".
static func _lowest(areas: Array, ratios: Dictionary) -> String:
	var out: String = ""
	for area in areas:
		if ratios.has(area) and (out == "" or ratios[area] < ratios[out]):
			out = area
	return out
