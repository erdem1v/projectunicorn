class_name ProductQuality
extends RefCounted

# Ürünün tek kalitesi: alanların seviyesi, müşterinin yıldızına ve sektörüne göre beklenti, sektörün alan ağırlıkları ve
# ürün uyumu U. Yalnız okur. Beklenti evreye değil müşterinin büyüklüğüne bağlıdır: B2B'de adayın ya da hesabın yıldızı,
# B2C'de kitle. Çekirdek giriş biletidir: Çekirdek'i geride kalan ürünün uyumu, öteki alanlar ne kadar iyi olursa olsun,
# Çekirdek oranının CORE_LEAD üstüne çıkamaz. Ekonomi yuvarlanmamış seviyeyi okur; ekran yarıma yuvarlanmışı gösterir.

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
const STAR_MAX := 3
## Ürün sayfasının referansı bu yıldızı okur: Traction adaylarının yarısı 2★'dır ve sözcük ürün büyüdükçe kendi kendine
## düşmemelidir. B2C'de kitle bu yıldıza varana kadar da bunu okur: küçük kitlede ilk sürümü yapılmış tek alana Güçlü denmez.
const PAGE_STAR := 2
## Hesap, sektör ağırlığı bu değerde ya da üstünde olan alanın hatlarını kullanır: Çekirdek ve sektörün iki vurgusu. Kalan
## alanın hatası o hesaba yazılmaz.
const USE_AREA_MIN := 0.15
## Satışçı kapanışının eğrisi [WORKING] onay bekliyor, E1'de kalibre: adayın U'su → ihtimal, noktalar arası doğrusal, uçlarda
## düz. Baktığı hiçbir alanı eksik olmayan aday bu eğriye girmez, kesin kapanır.
const CLOSE_CURVE := [[40.0, 0.30], [55.0, 0.60], [70.0, 0.85], [80.0, 0.95]]

# Yıldız beklenti tablosu: seviye 1 alanın her hattının ilk sürümüdür. 1★ satırı yayın şartıdır ve hat sayısından hesaplanır:
# adlı şartı olan türde alanın adlı modüllerinin payı, öbür türde Çekirdek'te `mvp_lines` ÷ Çekirdek hat sayısı. Tabloda
# olmayan hücre 0'dır: o yıldız o alana bakmaz. 1★ satırı ve 3★ satırı [WORKING] onay bekliyor.
const CORE_2 := 1.25
const EMPHASIS_2 := 1.0
const CORE_3 := 2.0
const EMPHASIS_3 := 1.5
const REST_3 := 1.0
## B2C: kitlenin 1★, 2★ ve 3★ satırına denk geldiği kullanıcı sayısı; arası kitlenin logaritmasıyla doğrusal
## [WORKING] onay bekliyor, E1'de kalibre.
const AUDIENCE_STARS := [1000.0, 10000.0, 50000.0]

## Sektörün alanları: vurgu 1, vurgu 2, kalan; satır ERP'nin alıcı sektörlerinindir (`erp.json` `buyer_sectors`).
const TABLE := {
	"logistics": ["integrations", "trust", "onboarding"],
	"construction": ["onboarding", "trust", "integrations"],
	"ecommerce": ["trust", "integrations", "onboarding"],
	"retail": ["trust", "integrations", "onboarding"],
	"manufacturing": ["integrations", "trust", "onboarding"],
	"textile": ["integrations", "onboarding", "trust"],   # [WORKING] onay bekliyor
	"wholesale": ["integrations", "trust", "onboarding"],  # [WORKING] onay bekliyor
	"auto_parts": ["integrations", "onboarding", "trust"], # [WORKING] onay bekliyor
	"food": ["trust", "integrations", "onboarding"],       # [WORKING] onay bekliyor
}

## Tabloda olmayan sektörün (fikstür sektörü, eski kayıttan gelen başka bir sektör) okuduğu satır.
const FALLBACK_SECTOR := "logistics"


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


## Sektördeki bir hesabın hatlarını kullandığı alanlar: ağırlığı `USE_AREA_MIN` ve üstü olanlar, yani Çekirdek ve sektörün
## iki vurgusu.
static func used_areas(sector: String) -> Array:
	var w: Dictionary = weights("b2b", sector)
	return w.keys().filter(func(area: String) -> bool: return w[area] >= USE_AREA_MIN)


## Sektördeki bir hesap alanın hatlarını kullanır mı. Hatsız alan ("") kullanılmaz.
static func uses_area(sector: String, area: String) -> bool:
	return area in used_areas(sector)


## Alanın yuvarlanmamış seviyesi: hatlarının kademe + cila ortalaması; `tiers` öngörünün varsaydığı kademeleri ezer.
static func level(area: String, tiers: Dictionary = {}) -> float:
	var caps: Array[String] = SprintCatalog.capabilities(area)
	if caps.is_empty():
		return 0.0
	var sum: float = 0.0
	for line_id in caps:
		sum += minf(float(tiers.get(line_id, SprintCatalog.tier(line_id))) + SprintCatalog.polish(line_id),
			SprintCatalog.max_tier(line_id))
	return sum / caps.size()


## Seviyenin beklentiye oranı, RATIO_CAP'te kesik. Beklentisi 0 olan alan için çağrılmaz.
static func ratio(area: String, expect: float) -> float:
	return _ratio(level(area), expect)


## Alanın beklentisi (0-3; 0 = bu müşteri bakmaz). `ctx`: `market` (boşsa ürünün pazarı), `star` (B2B'de adayın ya da
## hesabın yıldızı; B2C'de verilirse o yıldızın satırı), `audience` (B2C'de `star` yokken true ise kitlenin kendi konumu,
## sayfanın 2★ tabanı olmadan; taban merdiveni okur), `sector` (boşsa alanın sektörlerdeki en yüksek beklentisi), `rivals`
## (alanın hatlarına rakip penceresinde düşen çıkış başına artış; yalnız aday ve ekonomi bağlamı), `subtype` (boşsa canlı
## ürün: hat sayısı canlıdır). ctx boşsa ürün sayfasının referansıdır: B2B'de 2★ şirketin, B2C'de kitlenin yıldızı ile
## 2★'ın büyüğü; rakipsizdir.
static func expectation(area: String, ctx: Dictionary = {}) -> float:
	var market: String = ctx.get("market", ProductState.market_type())
	var subtype: String = ctx.get("subtype", ProductState.subtype())
	var caps: Array[String] = SprintCatalog.capabilities(area, subtype)
	var role: String = _role(area, market, ctx.get("sector", ""))
	var value: float = _value(role, caps, SprintCatalog.mvp_named(subtype), ctx, market) if role != "" else 0.0
	if ctx.get("rivals", false) and value > 0.0:
		value += minf(float(SprintCatalog.cfg("rival_bump")) * SprintCatalog.recent_hits(caps).size(),
			float(SprintCatalog.cfg("rival_bump_max")))
	var top: int = 0
	for line_id in caps:
		top = maxi(top, SprintCatalog.max_tier(line_id))
	return minf(value, top)


## 0 → Yok · beklentinin altı → Zayıf · beklenti ile beklenti + 1 arası → Yeterli · beklenti + 1 ve üstü → Güçlü.
static func word_for(lvl: float, expect: float) -> String:
	if lvl <= 0.0:
		return "none"
	if lvl < expect:
		return "weak"
	return "enough" if lvl < expect + 1.0 else "strong"


## Alanın ürün sayfasındaki sözcüğü (`none` | `weak` | `enough` | `strong`), ham seviyeyle.
static func word(area: String, ctx: Dictionary = {}) -> String:
	return word_for(level(area), expectation(area, ctx))


## Alanın sözcüğü Yeterli ya da üstü mü.
static func is_enough(area: String, ctx: Dictionary) -> bool:
	return word(area, ctx) in ["enough", "strong"]


## Ürünün henüz karşılamadığı en küçük yıldız (herhangi bir alanın ham seviyesi o yıldızın referansının altındaysa);
## hepsi karşılanmışsa 3. Lider, PM önerisi ve çeyrek şeridi bunu okur.
static func next_star() -> int:
	var areas: Array = SprintCatalog.area_ids()
	for star in range(1, STAR_MAX):
		if areas.any(func(area: String) -> bool: return level(area) < expectation(area, {"star": star})):
			return star
	return STAR_MAX


## Alanın sıradaki yıldızın beklentisine oranı, kesiksiz; o yıldızın bakmadığı alan bir üst yıldızın değeriyle tartılır.
static func next_ratio(area: String, star: int = next_star()) -> float:
	var expect: float = expectation(area, {"star": star})
	return level(area) / (expect if expect > 0.0 else expectation(area, {"star": mini(star + 1, STAR_MAX)}))


## Beklenen alanlardan sözcüğü Zayıf ya da Yok olan (seviye < beklenti) ve oranı en düşük olan; yoksa "". `ctx` boşsa
## ürün sayfasının referansıdır. `areas` verilmezse U'nun alanlarına bakar: Gelir fiyatın konusudur, kaliteye girmez.
static func weakest_area(ctx: Dictionary = {}) -> String:
	var ratios: Dictionary = {}
	var areas: Array = ctx.get("areas", weights(ctx.get("market", ProductState.market_type()), ctx.get("sector", "")).keys())
	for area in areas:
		var lvl: float = level(area)
		var expect: float = expectation(area, ctx)
		if lvl < expect:
			ratios[area] = _ratio(lvl, expect)
	return lowest(ratios.keys(), ratios)


## s★ şirketin beklentisinin (alanın sektörlerdeki en yüksek beklentisi, rakip penceresi dahil) altında kalan alanların
## kartları, en zayıf alan önde: alanın hatlarından kademesi beklentiye varmayanların sıradaki adımı (step kimliği). Hepsi
## yayına çıkınca bant açılır; bant sektörlerin ortalamasını okuduğu için daha önce de açılabilir. Satış başlığının ipucu okur.
static func needs_for(star: int) -> Array:
	var ctx := {"star": star, "rivals": true}
	var expect: Dictionary = {}
	var ratios: Dictionary = {}
	for area in SprintCatalog.area_ids():
		expect[area] = expectation(area, ctx)
		if level(area) < expect[area]:
			ratios[area] = ratio(area, expect[area])
	var short: Array = ratios.keys()
	short.sort_custom(func(a: String, b: String) -> bool: return ratios[a] < ratios[b])
	var out: Array = []
	for area in short:
		var want: int = ceili(expect[area])
		for line_id in SprintCatalog.capabilities(area):
			var tier: int = SprintCatalog.tier(line_id)
			if tier < want and tier < SprintCatalog.max_tier(line_id):
				out.append(String(ProductLines.step_at(line_id, tier + 1).id))
	return out


## {alan: beklenti} (beklentisi 0 olan alan yok): yıldızın ve sektörün satırı, rakipsiz. Hesap bunu imzada ve her yenileme
## penceresinin açılışında kopyalar (`Customer.market_ref`).
static func market_ref_for(star: int, sector: String, subtype: String = ProductState.subtype()) -> Dictionary:
	return _ref({"market": "b2b", "sector": sector, "star": star, "subtype": subtype})


## Adayın bağlamı: yıldızı ve sektörüyle bugünkü beklenti, rakip penceresi dahil.
static func prospect_ctx(p: Prospect) -> Dictionary:
	return _candidate_ctx(p.industry, p.star)


## Adayın uyumu.
static func prospect_fit(p: Prospect) -> Dictionary:
	return fit(prospect_ctx(p))


## Ürünün bir yıldızdaki müşterilere uyumu (0-100): B2B'de tablodaki alıcı sektörlerinin o yıldızdaki aday U'sunun ortalaması, B2C'de kitle
## bağlamındaki U (yıldız okunmaz). Akışın yıldız bandı okur (`SalesFaucetSystem.top_band`).
static func market_fit(star: int) -> int:
	if ProductState.market_type() == "b2c":
		return fit(SalesSystem.B2C_FIT_CTX).value
	var sum: int = 0
	for sector in TABLE:
		sum += sector_fit(sector, star)
	return roundi(float(sum) / TABLE.size())


## Bir sektörün bir yıldızdaki adayına ürünün uyumu (0-100, rakip penceresi dahil); akışın sektör çekimi okur.
static func sector_fit(sector: String, star: int) -> int:
	return fit(_candidate_ctx(sector, star)).value


## Satışçının adayı kapanış anında imzalama ihtimali (0-1): adayın bugünkü U'sundan `CLOSE_CURVE` ile. Baktığı hiçbir alan
## beklentinin altında değilse (`loss_area` boş) 1'dir: ortada adı konmuş bir eksik yoksa zar atılmaz.
static func close_chance(p: Prospect) -> float:
	var fit_now: Dictionary = prospect_fit(p)
	if fit_now.loss_area == "":
		return 1.0
	var u: float = clampf(fit_now.value, CLOSE_CURVE[0][0], CLOSE_CURVE[-1][0])
	for i in range(1, CLOSE_CURVE.size()):
		if u <= CLOSE_CURVE[i][0]:
			return lerpf(CLOSE_CURVE[i - 1][1], CLOSE_CURVE[i][1], inverse_lerp(CLOSE_CURVE[i - 1][0], CLOSE_CURVE[i][0], u))
	return CLOSE_CURVE[-1][1]


## Hesabın uyumu: beklenti hesabın kopyasıdır (`market_ref`), kopyası olmayan hesapta (imza yolunu atlayan fikstür) bugünkü
## satır. `market_value`: aynı hesabın bugünkü satırla U'su.
static func account_fit(c: Customer) -> Dictionary:
	var today: Dictionary = market_ref_for(c.scale, c.industry)
	var ctx := {"market": "b2b", "sector": c.industry, "ref": c.market_ref if not c.market_ref.is_empty() else today}
	var levels: Dictionary = _levels(ctx)
	var out: Dictionary = fit_from_levels(levels, ctx)
	out["market_value"] = fit_from_levels(levels, ctx.merged({"ref": today}, true)).value
	return out


## Ürün uyumu. `ctx`: `market` ("b2b" | "b2c"), `sector` (B2C'de ""), `star`, `ref` ({alan: beklenti}; verilmezse ctx'in
## beklentisinden kurulur, beklentisi 0 olan alan sayılmaz), `rivals`, `areas` (U yalnız bu alanlardan hesaplanır, ağırlıklar
## kendi içinde yeniden ölçeklenir; verilmezse hepsi, Çekirdek içinde olmalı: tavan onu okur). U: 0-100. `match`: tavandan
## sonraki uyum. `capped`: tavan devrede. `loss_area`: müşterinin eksik bulacağı alan (tavan devredeyse Çekirdek, değilse
## beklentisinin altındaki alanların en zayıfı, yoksa ""). `weakest_emphasis`: oranı en düşük vurgu alanı. `note`: Çekirdek
## ve o alanın kelimesi.
static func fit(ctx: Dictionary) -> Dictionary:
	return fit_from_levels(_levels(ctx), ctx)


## `fit`, alan seviyeleri verilmiş hâliyle. B2C'de `star` ve `ref` verilmezse bağlam kitledir: kitle iki yıldız satırının
## arasındayken uyum iki satırın uyumunun kitle payıyla karışımıdır. Alan satıra girerken beklentisi 0'dan yükselse
## ağırlığı tam girerdi, kitle eşiğinde U sıçrardı.
static func fit_from_levels(levels: Dictionary, ctx: Dictionary) -> Dictionary:
	if ctx.market == "b2c" and not ctx.has("ref") and not ctx.has("star"):
		return _audience_fit(levels, ctx)
	var ref: Dictionary = ctx.get("ref", {})
	if ref.is_empty():
		ref = _ref(ctx)
	var w: Dictionary = weights(ctx.market, ctx.sector)
	var ratios: Dictionary = {}
	var weighted: float = 0.0
	var total: float = 0.0
	for area in ctx.get("areas", w.keys()):
		var expect: float = float(ref.get(area, 0.0))
		if expect > 0.0:
			ratios[area] = _ratio(float(levels[area]), expect)
			weighted += w[area] * ratios[area]
			total += w[area]
	var mean: float = weighted / total
	var ceiling: float = ratios.core + CORE_LEAD
	var capped: bool = mean > ceiling
	var uyum: float = minf(mean, ceiling)
	var weakest: String = lowest(emphasis(ctx.sector), ratios)
	var lowest_area: String = lowest(ratios.keys(), ratios)
	var note: Array = []
	for area in ["core", weakest]:
		if ratios.has(area):
			note.append({"area": area, "word": word_for(float(levels[area]), float(ref[area]))})
	return {"value": mini(100, roundi(FIT_SCALE * uyum)), "match": uyum, "capped": capped,
		"weakest_emphasis": weakest,
		"loss_area": "core" if capped else (lowest_area if ratios[lowest_area] < 1.0 else ""),
		"note": note, "label_key": LABEL_KEY}


static func _audience_fit(levels: Dictionary, ctx: Dictionary) -> Dictionary:
	var at: float = _audience_star()
	var low: int = mini(int(at), STAR_MAX - 1)
	var lower: Dictionary = fit_from_levels(levels, ctx.merged({"star": low}))
	var upper: Dictionary = fit_from_levels(levels, ctx.merged({"star": low + 1}))
	var blend: float = lerpf(lower.match, upper.match, at - low)
	var near: Dictionary = upper if at - low > 0.5 else lower
	return near.merged({"match": blend, "value": mini(100, roundi(FIT_SCALE * blend))}, true)


## B2C kitlesinin yıldız konumu (1-3): 1.000 ve altı 1, 10.000'de 2, 50.000 ve üstü 3, aralarında kitlenin logaritmasıyla
## doğrusal.
static func _audience_star() -> float:
	var audience: float = SalesSystem.b2c_audience()
	var seg: int = 0 if audience < AUDIENCE_STARS[1] else 1
	return 1.0 + seg + clampf(
		inverse_lerp(log(AUDIENCE_STARS[seg]), log(AUDIENCE_STARS[seg + 1]), log(audience)), 0.0, 1.0)


## Alanın bağlamdaki rolü: "core" | "emphasis" | "rest"; pazarın alanı olmayan alan "" (beklentisi 0). B2C'de Çekirdek dışı
## her alan (Gelir dahil, o yalnız gösterim için) vurgu sütununu okur; sektörsüz B2B bağlamında (ürün sayfası) alanın
## sektörlerdeki en yüksek sütunu olan vurguyu.
static func _role(area: String, market: String, sector: String) -> String:
	if market not in SprintCatalog.area_def(area).markets:
		return ""
	if area == "core":
		return "core"
	if market == "b2c" or sector == "":
		return "emphasis"
	return "emphasis" if _row(sector).find(area) < 2 else "rest"


static func _value(role: String, caps: Array[String], named: Array, ctx: Dictionary, market: String) -> float:
	if market == "b2c" and not ctx.has("star"):
		var star: float = _audience_star()
		var at: float = (star if ctx.get("audience", false) else maxf(star, PAGE_STAR)) - 1.0
		var low: int = mini(int(at), STAR_MAX - 2)
		return lerpf(_star_value(low + 1, role, caps, named), _star_value(low + 2, role, caps, named), at - low)
	return _star_value(ctx.get("star", PAGE_STAR), role, caps, named)


static func _star_value(star: int, role: String, caps: Array[String], named: Array) -> float:
	if star == 1:
		if not named.is_empty():
			return float(caps.filter(func(l: String) -> bool: return l in named).size()) / caps.size()
		return float(SprintCatalog.cfg("mvp_lines")) / caps.size() if role == "core" else 0.0
	match [star, role]:
		[2, "core"]:
			return CORE_2
		[3, "core"]:
			return CORE_3
		[2, "emphasis"]:
			return EMPHASIS_2
		[3, "emphasis"]:
			return EMPHASIS_3
		[3, "rest"]:
			return REST_3
	return 0.0


## Bir sektörün bir yıldızdaki adayının bağlamı.
static func _candidate_ctx(sector: String, star: int) -> Dictionary:
	return {"market": "b2b", "sector": sector, "star": star, "rivals": true}


## ctx'in beklenti haritası: beklentisi 0'dan büyük alanlar.
static func _ref(ctx: Dictionary) -> Dictionary:
	var ref: Dictionary = {}
	for area in weights(ctx.market, ctx.sector):
		var expect: float = expectation(area, ctx)
		if expect > 0.0:
			ref[area] = expect
	return ref


static func _levels(ctx: Dictionary) -> Dictionary:
	var levels: Dictionary = {}
	for area in weights(ctx.market, ctx.sector):
		levels[area] = level(area)
	return levels


static func _ratio(lvl: float, expect: float) -> float:
	return minf(lvl / expect, RATIO_CAP)


static func _row(sector: String) -> Array:
	return TABLE.get(sector, TABLE[FALLBACK_SECTOR]) as Array


## `areas` içinde oranı en düşük alan; eşitlikte öndeki. Oranı olan alan yoksa "".
static func lowest(areas: Array, ratios: Dictionary) -> String:
	var out: String = ""
	for area in areas:
		if ratios.has(area) and (out == "" or ratios[area] < ratios[out]):
			out = area
	return out
