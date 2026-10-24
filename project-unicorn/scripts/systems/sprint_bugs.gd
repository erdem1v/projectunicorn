class_name SprintBugs
extends RefCounted

# Kartın hata modeli. Kartta doğan hata sayısı n, kartın karmaşıklığından ve Geliştirmeyi yapanların yıldızından gelir:
# H = T × tür × (1 − PM hazırlığı) × Σ pay × m(Δ) × TİTİZ; T = c × kartın puanı × R, m(Δ) = rate × 0,5^(Δ ÷ half_stars),
# Δ = kişinin Yazılım yıldızı − R, R kartın Geliştirme aşamasındaki Yazılım kapısı. Test bittiği an n kartın tohumundan
# Poisson(H) ile belirlenir; testin bulduğu F hata kartın Geliştirme satırına düzeltme işi ekler, kaçan n − F kart yayına
# çıkınca kendi hattında açık hata olur. Zar kartın kendi tohumundan (koşunun tohumu, sürüm numarası, kartın kimliği)
# kurulan yerel bir üreteçtir: RNG akışlarına dokunmaz, plan ile kapanış aynı kartta aynı sayıyı görür. Sayılar
# data/product/sprint.json `bugs` bloğunda [WORKING].


## Kartın kademesinin `area` alanında tek kişiden istediği yıldız; kapısı yoksa 0.
static func gate(c: Dictionary, area: String) -> int:
	var req: int = 0
	var gates: Dictionary = ProductLines.step(c.step).get("requires", {}) as Dictionary
	for d in (gates.get("person", []) as Array):
		if String(d.get("area", "")) == area:
			req = maxi(req, int(d.get("stars", 0)))
	return req


## Kartın Geliştirme aşamasındaki Yazılım kapısı (yıldız); kilitsiz kart 1★.
static func requirement(c: Dictionary) -> int:
	return maxi(1, gate(c, HRConstants.AREA_ENGINEERING))


## Kişilerin kartın bir aşamasında yaptığı iş (kişi: puan): hatanın iş payı ve testin yakalama payı bundan çıkar. İş kaydı
## olmayan kartta boştur.
static func worked(c: Dictionary, at: int) -> Dictionary:
	return (c.get("by", [{}, {}, {}]) as Array)[at]


## `_work`ın yaptığı her iş parçasını kişiye yazar (`worked`).
static func record(c: Dictionary, at: int, id: String, work: float) -> void:
	if not c.has("by"):
		c.by = [{}, {}, {}]
	var by: Dictionary = c.by[at]
	by[id] = float(by.get(id, 0.0)) + work


## Testten önce kartın beklenen hata yükü: h, h0 PM hazırlığı olmadan. Geliştirmeyi yapanların iş payıyla ağırlıklıdır.
static func expected(c: Dictionary) -> Dictionary:
	var cfg: Dictionary = SprintCatalog.cfg("bugs")
	var req: int = requirement(c)
	var h0: float = float(cfg.c) * SprintSystem.total(c) * req * float(cfg.kind[c.kind]) * _quality(c, req, cfg)
	return {"h": h0 * (1.0 - float(c.get("prep_cut", 0.0))), "h0": h0}


## Hata göstergesinin tavanı: 40 eforluk (`effort.k3`), gereksinimi 5★, Δ = 0, PM'siz ve TİTİZ'siz özellik kartının beklenen
## hatası, yani standart bir kartın ulaşabileceği en yüksek yük.
static func ceiling() -> float:
	var cfg: Dictionary = SprintCatalog.cfg("bugs")
	return float(cfg.c) * float(SprintCatalog.cfg("effort.k3")) * HRConstants.STAR_MAX * float(cfg.kind.feature) \
		* _miss(0.0, cfg)


## Testin kartta yakaladığı pay C: testi yapanların iş payıyla ağırlıklı 0,57 × √Y(Test); kendi geliştirdiği kartı test
## edenin oranı ×0,6'dır. Payda gereken testtir (kısaltılmış test o kadarını yakalar); bir kâğıt yapılmış testi geri aldıysa
## yeniden yapılan iş de paydaya girer. Böylece paylar 1'i aşmaz ve C en iyi testçinin oranını geçmez.
static func catch_rate(c: Dictionary) -> float:
	var cfg: Dictionary = SprintCatalog.cfg("bugs")
	var tested_by: Dictionary = worked(c, SprintSystem.TEST_PHASE)
	var built_by: Dictionary = worked(c, SprintSystem.DEV_PHASE)
	var covered: float = 0.0
	var done: float = 0.0
	for id: String in tested_by:
		done += float(tested_by[id])
		var who: Character = CharacterRegistry.get_character(id)
		if who != null:
			var rate: float = float(cfg.catch_coef) * sqrt(SprintSystem.skill_y(HRSystem.skill(who, HRConstants.AREA_QA)))
			covered += float(tested_by[id]) * rate * (float(cfg.self_test) if built_by.has(id) else 1.0)
	return covered / maxf(float(c.need[SprintSystem.TEST_PHASE]) + float(c.get("cut", 0.0)), done)


## Test bitti: kartın hatası belirlenir, bulunanların düzeltme işi Geliştirme satırına eklenir. `rolled` yanlışsa zar
## atılmaz (beklenen kip): n = H, F = H × C, iş = F × bir hatanın ortalama düzeltme işi. Tohum anahtarı sürüm numarasını
## taşır çünkü yinelenen kimlik yalnız düzeltme kartında vardır ve iki sürüm arasında bir kez çıkar; çekilişler ardışık
## üreteç çıktısıdır, çünkü sonu değişen anahtarlar `EvDice.unit`te doğrusal bir dizi verir.
static func settle(c: Dictionary, rolled := true) -> void:
	c.tested = true
	var h: float = expected(c).h
	if h <= 0.0:
		return
	var rate: float = catch_rate(c)
	var work: Dictionary = SprintCatalog.cfg("bugs.fix_work")
	var costs: Array = []
	if rolled:
		var dice := RandomNumberGenerator.new()
		dice.seed = EvDice.fnv1a("%d|bugs|%d|%s" % [GameState.run_seed, ProductState.version(), c.id])
		var n: int = _poisson(dice, h)
		for _i in n:
			var found: bool = dice.randf() < rate
			var heavy: bool = dice.randf() < float(work.heavy_p)
			if found:
				costs.append(float(work.heavy) if heavy else float(work.light))
		c.born = n
		c.found = costs.size()
	else:
		costs.append(h * rate * (float(work.heavy_p) * float(work.heavy) + (1.0 - float(work.heavy_p)) * float(work.light)))
		c.born = h
		c.found = h * rate
	c.fix = costs
	c.need[SprintSystem.DEV_PHASE] = float(c.need[SprintSystem.DEV_PHASE]) + _sum(costs)


## Testin bulduğu, düzeltmesi bitmemiş hata: düzeltmeler bulunma sırasıyla yapılır, Geliştirme satırında kalan iş en
## sondakilerdir.
static func known(c: Dictionary) -> int:
	var costs: Array = c.get("fix", [])
	var done: float = _sum(costs) - (float(c.need[SprintSystem.DEV_PHASE]) - float(c.progress[SprintSystem.DEV_PHASE]))
	var fixed: int = 0
	var acc: float = 0.0
	for cost in costs:
		acc += float(cost)
		if acc <= done + SprintSystem.EPS:
			fixed += 1
	return costs.size() - fixed


## Söz olayında testi kısaltmak ya da fazla mesai istemek kartı gönderir: testi bitmişse düzeltmesi bitmese de sprint
## kapanışında sürüme girer.
static func sent(c: Dictionary) -> bool:
	return bool(c.get("send", false)) and bool(c.get("tested", false))


## Kartın sürüme bıraktığı hata: testten kaçan ve gönderilen kartta düzeltilmemiş bulunan.
static func leaving(c: Dictionary) -> int:
	return int(c.get("born", 0)) - int(c.get("found", 0)) + known(c)


## Test bitmiş kartın [n, F, K, düzeltme işi]; testi bitmemişse [].
static func tally(c: Dictionary) -> Array:
	if not bool(c.get("tested", false)):
		return []
	return [int(c.get("born", 0)), int(c.get("found", 0)), int(c.get("born", 0)) - int(c.get("found", 0)),
		_sum(c.get("fix", []))]


## Geliştirmeyi yapanların hata oranı: iş payıyla ağırlıklı m(Δ) × TİTİZ; kimsenin yapmadığı iş Δ = 0 sayılır.
static func _quality(c: Dictionary, req: int, cfg: Dictionary) -> float:
	var built_by: Dictionary = worked(c, SprintSystem.DEV_PHASE)
	var share: float = 0.0
	var weighted: float = 0.0
	for id: String in built_by:
		var who: Character = CharacterRegistry.get_character(id)
		if who != null:
			var stars: float = HRConstants.stars_for(HRSystem.skill(who, HRConstants.AREA_ENGINEERING))
			weighted += float(built_by[id]) * _miss(stars - req, cfg) * HRConstants.trait_mult(who.traits, "bug_rate_mult")
			share += float(built_by[id])
	return weighted / share if share > 0.0 else _miss(0.0, cfg)


## Gereksinimin `delta` yıldız üstündeki kişinin kartın tavanından hata olarak soktuğu pay.
static func _miss(delta: float, cfg: Dictionary) -> float:
	return float(cfg.rate) * pow(0.5, delta / float(cfg.half_stars))


## Poisson(h)'nin ters dağılımı: [0, 1) çekilişini aşan en küçük n. Çekiliş 1'e eşit olamaz, yoksa toplam ona varmayabilirdi.
static func _poisson(dice: RandomNumberGenerator, h: float) -> int:
	var u: float = float(dice.randi()) / 4294967296.0
	var n: int = 0
	var p: float = exp(-h)
	var s: float = p
	while u > s:
		n += 1
		p *= h / n
		s += p
	return n


static func _sum(values: Array) -> float:
	var total: float = 0.0
	for v in values:
		total += float(v)
	return total
