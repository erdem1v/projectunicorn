class_name SprintBridges
extends RefCounted

# Sprint motorunun öbür alanlarla dikişleri: DESTEK ticket defteri, B2B talepleri, rakip
# çıkışları ve basın satırı, ekonomi (eksen puanı, altyapı, ücretli plan) ve gerçekleşen sonuç.
# Öbür alanlara yalnız onların seam'lerinden yazar. GameState.product'ın yazarı SprintSystem'dir;
# köprü orada yalnız dört anahtarı yazar: tickets, ticket_seq, requests, rival_hits. Hepsi tür
# seçilmiş üründe çalışır.
# Sürüm notunun cümleleri {key, args} saklanır; args'taki metin değeri ya çeviri anahtarıdır ya
# özel ad, resolve() ikisini de ekranın dilinde okur.


# --- Ticket ---------------------------------------------------------------------------

## Defteri DESTEK'in doğrulanmış sayacına eşitler. Sayaç kimlik taşımaz, yalnız fark okunur:
## düzeltme koşusunun erittikleri defterin en eskisinden düşer; yeni doğrulananlar canlı
## yeteneklere ticket kimliğinin hash'iyle dağılır, her yetenek bir pay artı kademesinin
## kullanım ağırlığı kadar pay alır.
static func sync_tickets() -> void:
	var tickets: Array = _p().tickets
	var confirmed: int = ProductState.bugs_confirmed()
	if tickets.size() == confirmed:
		return
	tickets = tickets.slice(maxi(0, tickets.size() - confirmed))
	var weights: Dictionary = {}
	var total: int = 0
	for line_id in ProductLines.line_ids(ProductState.subtype()):
		var tier: int = ProductState.line_tier(line_id)
		if tier > 0:
			weights[line_id] = 1 + ProductLines.usage_weight_of(ProductLines.step_at(line_id, tier).id)
			total += weights[line_id]
	while tickets.size() < confirmed and total > 0:
		var id: int = _next_ticket_id()
		var r: int = absi(hash("%d|ticket" % id)) % total
		var line: String = ""
		for line_id in weights:
			line = line_id
			r -= weights[line_id]
			if r < 0:
				break
		tickets.append({"id": id, "line": line, "day": GameState.day})
	_p().tickets = tickets


## Düzeltme kartı çıktı: kartın ticket'ları defterden ve doğrulanmış sayaçtan düşer. Koşu o
## arada bir kısmını eritmişse onlar zaten düşmüştür; gerçekten kapananların kimlikleri döner.
static func close_tickets(ids: Array) -> Array:
	sync_tickets()
	var closing: Array = ids.map(func(i: Variant) -> int: return int(i))
	var closed: Array = _p().tickets.filter(func(t: Dictionary) -> bool: return closing.has(int(t.id))).map(
		func(t: Dictionary) -> int: return int(t.id))
	_p().tickets = _p().tickets.filter(func(t: Dictionary) -> bool: return not closing.has(int(t.id)))
	ProductState.adjust_confirmed(-closed.size())
	return closed


## Hatalı çıkış: kartın yeteneğine bir doğrulanmış hata.
static func add_faulty_ticket(line: String) -> void:
	sync_tickets()
	_p().tickets.append({"id": _next_ticket_id(), "line": line, "day": GameState.day})
	ProductState.adjust_confirmed(1)


# --- Talepler (B2B) ---------------------------------------------------------------------

## Günlük. Her aktif B2B hesabı en çok bir açık talep taşır; talep imzadan bir sprint sonra ve
## her yenilemeden altı sprint önce açılan pencerede bir kez doğar, kaçırılan eski pencere
## atlanır. Yetenek hesabın sektörünün arketipine bağlı alandan, kilidi açık ve başka açık
## talepte olmayan sonraki kademelerden hash'le seçilir. Son tarih sprinti kapanmış ya da hesabı
## kapanan açık talep sessizce düşer (zamanında olan kapanışta on_release'te karşılanmıştır).
static func tick_requests() -> void:
	# Sürüm notundayken kapanan sprint henüz numarayı taşır. Talebin ilk sprinti oyuncunun
	# planlayabileceği ilk sprinttir: planlamadaki sprint, yoksa sıradaki (koşanın kartları kilitli).
	var last_closed: int = SprintSystem.sprint_number() - (0 if SprintSystem.mode() == "release" else 1)
	var plannable: int = SprintSystem.sprint_number() + (0 if SprintSystem.mode() == "plan" else 1)
	var accounts: Array[Customer] = CustomerRegistry.get_by_market("b2b")
	var account_ids: Array = accounts.map(func(c: Customer) -> String: return c.id)
	var requests: Array = _p().requests
	for r in requests:
		if r.status == "open" and (int(r.due_sprint) <= last_closed or not account_ids.has(r.customer_id)):
			r.status = "late"
	var weeks: int = int(SprintCatalog.cfg("sprint_weeks"))
	var term: int = TimeModel.ticks(int(SprintCatalog.cfg("request.contract_weeks")))
	var lead: int = TimeModel.ticks(weeks * int(SprintCatalog.cfg("request.before_renewal_sprints")))
	var first: int = TimeModel.ticks(weeks * int(SprintCatalog.cfg("request.first_after_sprints")))
	var area_of: Dictionary = SprintCatalog.cfg("archetypes")
	for c in accounts:
		var renewals: int = int(float(GameState.day - c.acquired_on_day + lead) / term)
		var window: int = c.acquired_on_day + (renewals * term - lead if renewals > 0 else first)
		if GameState.day < window or requests.any(func(r: Dictionary) -> bool:
				return r.customer_id == c.id and (r.status == "open" or int(r.day) >= window)):
			continue
		var area: String = area_of["default"]
		for archetype in SalesArchetypes.ids():
			if c.industry in SalesArchetypes.sectors(archetype):
				area = area_of.get(archetype, area)
		var taken: Array = requests.filter(func(r: Dictionary) -> bool: return r.status == "open").map(
			func(r: Dictionary) -> String: return r.step)
		var steps: Array = []
		for line_id in SprintCatalog.capabilities(area):
			var step: Dictionary = ProductLines.step_at(line_id, ProductState.line_tier(line_id) + 1)
			if not step.is_empty() and not taken.has(step.id) and SprintCatalog.gate_reason(step.id) == "":
				steps.append(step)
		if steps.is_empty():
			continue
		var pick: Dictionary = steps[absi(hash("%s|%d" % [c.id, window])) % steps.size()]
		var id: String = "%s.%d" % [c.id, window]
		requests.append({"id": id, "customer_id": c.id, "line": pick.line_id, "step": pick.id,
			"created_sprint": plannable,
			"due_sprint": plannable + int(SprintCatalog.cfg("request.deadline_sprints")),
			"value": c.mrr * 12, "status": "open", "card_id": "req:" + id, "day": GameState.day})


## Herkese açık sürüm, kademeler yazıldıktan sonra: kademesi canlıya geçen açık talep zamanında
## karşılanmıştır (geç kalan talep tick_requests'te çoktan düşmüştür). Sunucu, yeni sürümün
## yüküyle doluluk normal banda (sararma eşiğinin altına) inene kadar büyür; hiç küçülmez.
static func on_release() -> void:
	for r in _p().requests:
		if r.status == "open" and ProductState.is_feature_live(r.step):
			r.status = "met"
	InfraSystem.set_capacity(maxi(InfraSystem.units(), InfraSystem.units_for_occupancy(InfraSystem.OCCUPANCY_AMBER)))


# --- Rakipler ---------------------------------------------------------------------------

## Rakip tablosunun bu sprintteki çıkışları kayda geçer; beklenti artışı, alan çipi ve sonraki
## sütunun bayrağı kayıttan okunur. Haber bandına canlı satır düşer, Biz arşivine girmez:
## haber bizim değil, dünyanın.
static func tick_rivals(sprint: int) -> void:
	for launch in SprintCatalog.rival_launch_in(sprint):
		if _p().rival_hits.any(func(h: Dictionary) -> bool:
				return int(h.sprint) == sprint and int(h.rival) == int(launch.rival) and h.line == launch.line):
			continue
		_p().rival_hits.append({"rival": int(launch.rival), "line": launch.line, "sprint": sprint})
		var variant: int = absi(hash("%d|%s" % [sprint, launch.line])) % int(SprintCatalog.cfg("content.rival_news"))
		EventBus.ticker_live_line.emit(NewsFeedSystem.outlet_name(absi(hash(launch.name))),
			TranslationServer.translate("PRODUCT_NEWS_RIVAL_LAUNCH_%d" % variant).format(
				{"rival": launch.name, "capability": launch.capability}))


## Sürüm kapanışında bir kez: çekirdekte ikinci ya da üçüncü kademe canlıya geçtiyse onu, yoksa
## beklentiyi yakalayan alanı anan basın satırı; ikisi de yoksa {}. Satır haber bandına da düşer.
static func press_line(release: Dictionary) -> Dictionary:
	if int(release.number) == 0:
		return {}
	var h: int = absi(hash("%d|press" % int(release.number)))
	var product: String = ProductState.product_name()
	var out: Dictionary = {}
	for c in release.shipped:
		if c.area == "core" and int(c.target_tier) >= 2 and ProductState.line_tier(c.line) >= int(c.target_tier):
			out = {"key": "PRODUCT_PRESS_CORE_%d" % (h % int(SprintCatalog.cfg("content.press_core"))),
				"args": {"product": product, "capability": c.step}}
			break
	if out.is_empty():
		for change in release.changed_areas:
			var expect: float = SprintCatalog.expectation(change.area)
			if float(change.from) < expect and float(change.to) >= expect:
				out = {"key": "PRODUCT_PRESS_AREA_%d" % (h % int(SprintCatalog.cfg("content.press_area"))),
					"args": {"product": product, "area": change.area}}
				break
	if out.is_empty():
		return {}
	out["outlet"] = NewsFeedSystem.OUTLET_KEYS[h % NewsFeedSystem.OUTLET_KEYS.size()]
	EventBus.headline_added.emit(TranslationServer.translate(out.outlet), resolve(out))
	return out


# --- Ekonomi -----------------------------------------------------------------------------

## Eksen köprüsü: hat kademelerinden türeyen ham eksen değerleri Satış'ın, VC'nin ve Finans'ın
## okuduğu mvp_* bayraklarına yazılır.
static func push_axes() -> void:
	var dims: Dictionary = ProductState.realized_dims()
	for axis in QualityModel.AXES:
		GameState.set_flag("mvp_%s" % axis, float(dims[axis]))


## MVP anı: sunucu önerilen kapasiteyle bulutta açılır.
static func on_mvp() -> void:
	InfraSystem.set_provider(InfraSystem.PROVIDER_CLOUD)
	InfraSystem.set_capacity(InfraSystem.suggested_start_units())


## Gelir'in "Ücretli plan" kartı: ücretli katman ürünün bugünkü değerinin önerdiği fiyatla açılır.
static func open_paid_plan() -> void:
	SalesSystem.apply_b2c_price(int(SalesSystem.product_value().optimal))


# --- Sonuç -------------------------------------------------------------------------------

## Sürümden bir gün sonraki SONUÇ satırı: sürümde değişen alanın kelimesi bugün değiştiyse o,
## yoksa kapanan ticket sayısı, o da yoksa "görünür bir değişiklik olmadı".
static func actual_sentence(release: Dictionary) -> Dictionary:
	for change in release.changed_areas:
		var from: String = SprintCatalog.word_for(float(change.from), SprintCatalog.expectation(change.area))
		var to: String = SprintCatalog.area_word(change.area)
		if from != to:
			return {"key": "PRODUCT_RESULT_LEVEL_ACTUAL", "args": {"area": change.area, "from": from, "to": to}}
	var n: int = 0
	for c in release.shipped:
		if c.kind == "fix":
			n += c.tickets.size()
	if n > 0:
		return {"key": Fmt.count_key("PRODUCT_RESULT_TICKETS_ACTUAL", n), "args": {"n": n}}
	return {"key": "PRODUCT_RESULT_NONE_ACTUAL", "args": {}}


## Sürüm notunun saklanan cümlesi ({key, args}) ekranın dilinde. Args kimlik taşır: area alan
## kimliği, from/to durum kelimesi, capability kademe kimliğidir; öbürleri (sayı, özel ad) olduğu
## gibi yazılır.
static func resolve(sentence: Dictionary) -> String:
	var args: Dictionary = sentence.args.duplicate()
	if args.has("area"):
		args.area = SprintCatalog.area_short(args.area)
	for k in ["from", "to"]:
		if args.has(k):
			args[k] = TranslationServer.translate("PRODUCT_LEVEL_" + String(args[k]).to_upper())
	if args.has("capability"):
		args.capability = TranslationServer.translate(ProductLines.step(args.capability).name_key)
	return TranslationServer.translate(sentence.key).format(args)


# --- İç -------------------------------------------------------------------------------

static func _p() -> Dictionary:
	return GameState.product


static func _next_ticket_id() -> int:
	_p().ticket_seq = int(_p().ticket_seq) + 1
	return _p().ticket_seq
