class_name SprintPrep
extends RefCounted

# PM'in önden hazırlığı. PM sprint puanı üretmez: haftasını sonraki sütunda henüz başlamamış kartları hazırlamaya verir
# (SprintSystem._ahead_cards; özellik ve istek kartı, düzeltme ve araştırma kartı hazırlanmaz). Hazırlık işi kartın puanının
# `prep.share` payıdır, PM'in hızı P(s) = rate[0] + rate[1] × √((s − 2) ÷ 8) puan/hafta (s Ürün puanı, 1★'ın altında sıfıra
# doğrusal iner) ve çalışma saati, verim, huy ve sprint payıyla çarpılır (SprintSystem.team'in `prep`'i). Kart hazırlığı
# bittiği oranda kartı hazırlayan PM'in yıldızından fayda alır: kartın her aşamasında hız (`prep_gain`, SprintSystem._work) ve
# hata yükünde azalma (`prep_cut`, SprintBugs.expected); ikisi `prep.speed` ve `prep.bugs`'ta 1★ ile 5★ arasında doğrusaldır,
# yarım hazırlık orantılı fayda alır. Hazırlanacak kartlar karmaşıklığa (puan × Yazılım kapısı) göre büyükten küçüğe
# dizilir, PM'ler yıldızdan aza; her PM'e sprintin sonuna dek kalan hazırlık kapasitesiyle orantılı ardışık bir kart dilimi düşer
# (en karmaşık dilim en iyi PM'e), kartın Ürün kapısını geçemeyen PM'in payı en yakın uygun PM'e kayar. Bir kartı tek PM
# hazırlar ve hazırlayan, ekipte durdukça, değişmez. Kartın alanları, yoksa varsayılanla okunur: prep_by (PM'in kimliği),
# prep_done (0..1), prep_gain (hız kazancı g), prep_cut (hata yükünde azalma).


## Ürün puanı `points` olan PM'in kişisiz haftalık hazırlık hızı (puan).
static func rate_for(points: int) -> float:
	var curve: Array = SprintCatalog.cfg("prep.rate")
	var one_star: float = HRConstants.POINTS_PER_STAR
	if points < one_star:
		return float(curve[0]) * points / one_star
	return float(curve[0]) + float(curve[1]) * sqrt((points - one_star) / (HRConstants.AREA_MAX - one_star))


## PM'in haftalık hazırlık puanı (SprintSystem.team'in `prep`'i); PM değilse 0.
static func rate(c: Character, hours: int) -> float:
	if c.role != HRConstants.ROLE_PRODUCT_MANAGER:
		return 0.0
	return SprintSystem.paced(c, rate_for(HRSystem.skill(c, HRConstants.AREA_PRODUCT)) * HRConstants.hours_output_mult(hours))


## Kartın hazırlık işi (puan).
static func need(c: Dictionary) -> float:
	return float(SprintCatalog.cfg("prep.share")) * SprintSystem.total(c)


## Bir hafta: `people` (SprintSystem.team biçimi) içindeki PM'ler `ahead` kartlarını hazırlar; `weeks_after` sprintin bu
## haftadan sonra kalan haftasıdır (sahiplik dilimleri onunla kurulur). Haftada hazırlık yapan PM'lerin kimlikleri döner.
static func week(ahead: Array, people: Array, weeks_after: int) -> Array:
	var cards: Array = ahead.filter(_open)
	var pms: Array = people.filter(func(t: Dictionary) -> bool: return t.prep > 0.0)
	if cards.is_empty() or pms.is_empty():
		return []
	var points: Dictionary = {}
	for t in pms:
		points[t.id] = HRSystem.skill(CharacterRegistry.get_character(t.id), HRConstants.AREA_PRODUCT)
	pms.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return points[a.id] > points[b.id] if points[a.id] != points[b.id] else a.id < b.id)
	var rows: Array = []
	for i in cards.size():
		rows.append([SprintSystem.total(cards[i]) * SprintBugs.requirement(cards[i]), i])
	rows.sort_custom(func(a: Array, b: Array) -> bool: return a[0] > b[0] if a[0] != b[0] else a[1] < b[1])
	var queue: Array = rows.map(func(row: Array) -> Dictionary: return cards[row[1]])
	_own(queue, pms, points, weeks_after)
	return _prepare(queue, pms, points)


## Hazırlanabilir kart: bir sprintte hiç koşmamış (devreden kartın hızı sprintte sabitlenmiştir), karar beklemeyen ve
## hazırlığı bitmemiş.
static func _open(c: Dictionary) -> bool:
	return c.state == "planned" and not c.decision and float(c.get("prep_done", 0.0)) < 1.0 - SprintSystem.EPS


static func _left(c: Dictionary) -> float:
	return need(c) * (1.0 - float(c.get("prep_done", 0.0)))


## Sahibi olmayan (ya da sahibi ekipte durmayan) kartlar PM'lere dilimlenir. Her PM'in payı sprintin sonuna dek hazırlık
## kapasitesidir, eski kartlarının kalan işi düşülmüş; kartlar karmaşıklık sırasıyla ardışık dilimlere ayrılır ve dilimin
## sahibi, kartın Ürün kapısını geçen en yakın (eşitte daha yıldızlı) ve payı kalan PM'dir. Payı kalmayan kart bu hafta sahipsiz kalır.
static func _own(queue: Array, pms: Array, points: Dictionary, weeks_after: int) -> void:
	var budget: Dictionary = {}
	for t in pms:
		budget[t.id] = float(t.prep) * (1.0 + weeks_after)
	for c in queue:
		if budget.has(c.get("prep_by", "")):
			budget[c.prep_by] -= _left(c)
	var fresh: Array = queue.filter(func(c: Dictionary) -> bool: return not budget.has(c.get("prep_by", "")))
	var order: Array = pms.filter(func(t: Dictionary) -> bool: return budget[t.id] > SprintSystem.EPS)
	if fresh.is_empty() or order.is_empty():
		return
	var cap: float = 0.0
	for t in order:
		cap += budget[t.id]
	var upto: Array = []
	var run: float = 0.0
	for t in order:
		run += budget[t.id]
		upto.append(run / cap)
	var all_left: float = 0.0
	for c in fresh:
		all_left += _left(c)
	var best: float = HRConstants.stars_for(points[pms[0].id])
	var before: float = 0.0
	for c in fresh:
		var left: float = _left(c)
		var at: int = mini(upto.bsearch((before + left / 2.0) / all_left - 1e-12), order.size() - 1)
		before += left
		var gate: float = minf(float(SprintBugs.gate(c, HRConstants.AREA_PRODUCT)), best)
		var fit: Array = range(order.size()).filter(func(i: int) -> bool:
			return HRConstants.stars_for(points[order[i].id]) >= gate - 1e-9 and budget[order[i].id] > SprintSystem.EPS)
		if not fit.is_empty():
			var pick: int = fit.reduce(func(a: int, b: int) -> int: return b if absi(b - at) < absi(a - at) else a)
			c.prep_by = order[pick].id
			budget[order[pick].id] -= left


## Her PM haftasını kendi kartlarına karmaşıklık sırasıyla harcar; kartın faydası hazırlayan PM'in yıldızındandır.
static func _prepare(queue: Array, pms: Array, points: Dictionary) -> Array:
	var worked: Array = []
	for t in pms:
		var time: float = 1.0
		for c in queue:
			if time <= SprintSystem.EPS:
				break
			if c.get("prep_by", "") != t.id or float(c.get("prep_done", 0.0)) >= 1.0 - SprintSystem.EPS:
				continue
			var work: float = minf(_left(c), time * t.prep)
			var part: float = work / need(c)
			c.prep_done = minf(1.0, float(c.get("prep_done", 0.0)) + part)
			c.prep_gain = float(c.get("prep_gain", 0.0)) + part * _at("prep.speed", points[t.id])
			c.prep_cut = float(c.get("prep_cut", 0.0)) + part * (1.0 - _at("prep.bugs", points[t.id]))
			time -= work / t.prep
			if not worked.has(t.id):
				worked.append(t.id)
	return worked


## `path` ("prep.speed" ya da "prep.bugs") 1★'ta ilk, 5★'ta ikinci değerdir, arası doğrusal; 1★'ın altı 1★'ın değeri.
static func _at(path: String, points: int) -> float:
	var ends: Array = SprintCatalog.cfg(path)
	var t: float = clampf((HRConstants.stars_for(points) - 1.0) / (HRConstants.STAR_MAX - 1), 0.0, 1.0)
	return lerpf(float(ends[0]), float(ends[1]), t)
