class_name SprintBridges
extends RefCounted

# Sprint motorunun öbür alanlarla dikişleri: B2B talepleri, rakip çıkışları ve basın satırı,
# ekonomi (eksen puanı, altyapı, ücretli plan) ve gerçekleşen sonuç. Öbür alanlara yalnız onların
# seam'lerinden yazar. GameState.product'ın yazarı SprintSystem'dir; köprü orada yalnız iki
# anahtarı yazar: requests, rival_hits. Hepsi tür seçilmiş üründe çalışır.
# Sürüm notunun cümleleri {key, args} saklanır; args'taki metin değeri ya çeviri anahtarıdır ya
# özel ad, resolve() ikisini de ekranın dilinde okur.


# --- Talepler (B2B) ---------------------------------------------------------------------

## Günlük. Her aktif B2B hesabı en çok bir açık talep taşır; talep imzadan `first_after_weeks` sonra
## ve her yenilemeden `before_renewal_weeks` önce açılan pencerede bir kez doğar, kaçırılan eski
## pencere atlanır. Yetenek hesabın sektörünün arketipine bağlı alandan, kilidi açık ve başka açık
## talepte olmayan sonraki kademelerden hash'le seçilir. Son tarih planlanabilir sprintten
## `deadline_weeks` sonraki sprinttir (seçilen süreyle sayılır); o sprint kapanmış ya da hesabı
## kapanan açık talep sessizce düşer (zamanında olan kapanışta on_release'te karşılanmıştır).
static func tick_requests() -> void:
	var last_closed: int = SprintSystem.last_closed()
	var plannable: int = SprintSystem.plannable_sprint()
	var accounts: Array[Customer] = CustomerRegistry.get_by_market("b2b")
	var account_ids: Array = accounts.map(func(c: Customer) -> String: return c.id)
	var requests: Array = _p().requests
	for r in requests:
		if r.status == "open" and (int(r.due_sprint) <= last_closed or not account_ids.has(r.customer_id)):
			r.status = "late"
	var term: int = TimeModel.ticks(int(SprintCatalog.cfg("request.contract_weeks")))
	var lead: int = TimeModel.ticks(int(SprintCatalog.cfg("request.before_renewal_weeks")))
	var first: int = TimeModel.ticks(int(SprintCatalog.cfg("request.first_after_weeks")))
	var area_of: Dictionary = SprintCatalog.cfg("archetypes")
	for c in accounts:
		var renewals: int = int(float(GameState.day - c.acquired_on_day + lead) / term)
		var window: int = c.acquired_on_day + (renewals * term - lead if renewals > 0 else first)
		if GameState.day < window or requests.any(func(r: Dictionary) -> bool:
				return r.customer_id == c.id and (r.status == "open" or int(r.day) >= window)):
			continue
		var area: String = area_of.get(SalesArchetypes.of_sector(c.industry), area_of["default"])
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
			"due_sprint": plannable + SprintSystem.sprints_in(int(SprintCatalog.cfg("request.deadline_weeks"))),
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
		EventBus.ticker_live_line.emit(NewsFeedSystem.outlet_key(absi(hash(launch.name))),
			{"key": "PRODUCT_NEWS_RIVAL_LAUNCH_%d" % variant,
			"args": {"rival": launch.name, "capability": {"key": launch.capability_key}}})


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
	EventBus.headline_added.emit(out.outlet, line_of(out))
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
	# Frank'in "fiyatı belirle" satırı fiyat konunca düşer.
	if GameState.mentor_line_key == "FRANK_ADVISORY_PAID_TIER":
		EventBus.mentor_advisory_changed.emit("", {})


# --- Sonuç -------------------------------------------------------------------------------

## Sürümden bir gün sonraki SONUÇ satırı: B2C'de v1.0'ınki ilk haftanın kullanıcılarıdır; öbürlerinde
## sürümde değişen alanın kelimesi bugün değiştiyse o, yoksa kapanan hata sayısı, o da yoksa "görünür bir
## değişiklik olmadı".
static func actual_sentence(release: Dictionary) -> Dictionary:
	if int(release.number) == 1 and not SalesSystem.is_b2b_market():
		var users: int = int(SalesSystem.b2c_audience())
		return {"key": Fmt.count_key("PRODUCT_RELEASE_USERS", users), "args": {"n": users}}
	for change in release.changed_areas:
		var from: String = SprintCatalog.word_for(float(change.from), SprintCatalog.expectation(change.area))
		var to: String = SprintCatalog.area_word(change.area)
		if from != to:
			return {"key": "PRODUCT_RESULT_LEVEL_ACTUAL", "args": {"area": change.area, "from": from, "to": to}}
	var n: int = 0
	for c in release.shipped:
		if c.kind == "fix":
			n += int(c.bugs)
	if n > 0:
		return {"key": Fmt.count_key("PRODUCT_RESULT_BUGS_ACTUAL", n), "args": {"n": n}}
	return {"key": "PRODUCT_RESULT_NONE_ACTUAL", "args": {}}


## Sürüm notunun saklanan cümlesi ({key, args}) ekranın dilinde. Args kimlik taşır: area alan
## kimliği, from/to durum kelimesi, capability kademe kimliğidir; öbürleri (sayı, özel ad) olduğu
## gibi yazılır.
static func resolve(sentence: Dictionary) -> String:
	return NewsFeedSystem.line_text(line_of(sentence))


## Aynı cümle haber satırı olarak: kimlik taşıyan her arg, adının anahtarı olan iç içe satıra döner.
static func line_of(sentence: Dictionary) -> Dictionary:
	var args: Dictionary = sentence.args.duplicate()
	if args.has("area"):
		args.area = {"key": SprintCatalog.area_short_key(args.area)}
	for k in ["from", "to"]:
		if args.has(k):
			args[k] = {"key": "PRODUCT_LEVEL_" + String(args[k]).to_upper()}
	if args.has("capability"):
		args.capability = {"key": SprintCatalog.step_name_key(args.capability)}
	return {"key": sentence.key, "args": args}


# --- İç -------------------------------------------------------------------------------

static func _p() -> Dictionary:
	return GameState.product
