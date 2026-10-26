class_name SprintBridges
extends RefCounted

# Sprint motorunun öbür alanlarla dikişleri: B2B talepleri, rakip çıkışları ve basın satırı,
# ekonomi (altyapı, ücretli plan) ve gerçekleşen sonuç. Öbür alanlara yalnız onların
# seam'lerinden yazar. GameState.product'ın yazarı SprintSystem'dir; köprü orada yalnız requests ve
# rival_hits'i, bir de kendisine verilen sürüm kaydının thanks alanını yazar (reviews'u SprintSystem
# yazar, seçimi köprüden alır). Hepsi tür seçilmiş üründe çalışır.
# Sürüm notunun cümleleri {key, args} saklanır; args'taki metin değeri ya çeviri anahtarıdır ya
# özel ad, resolve() ikisini de ekranın dilinde okur.


# --- Talepler (B2B) ---------------------------------------------------------------------

## Günlük. Her aktif B2B hesabı en çok bir açık talep taşır; talep imzadan `first_after_weeks` sonra
## ve her yenilemeden `before_renewal_weeks` önce açılan pencerede bir kez doğar, kaçırılan eski
## pencere atlanır. Yetenek hesabın sektörünün vurgu 1 alanından, kilidi açık ve başka açık
## talepte olmayan sonraki kademelerden hash'le seçilir. Son tarih planlanabilir sprintten
## `deadline_weeks` sonraki sprinttir; o sprint kapanmış ya da hesabı
## kapanan açık talep sessizce düşer (zamanında olan kapanışta on_release'te karşılanmıştır). Yenileme penceresinin
## açıldığı gün hesap pazar referansını yeniden kopyalar (`Customer.market_ref`).
static func tick_requests() -> void:
	var last_closed: int = SprintSystem.last_closed()
	var plannable: int = SprintSystem.plannable_sprint()
	var accounts: Array[Customer] = CustomerRegistry.get_by_market("b2b")
	var account_ids: Array = accounts.map(func(c: Customer) -> String: return c.id)
	var requests: Array = _p().requests
	for r in requests:
		if r.status == "open" and (int(r.due_sprint) <= last_closed or not account_ids.has(r.customer_id)):
			r.status = "late"
	var lead: int = TimeModel.ticks(int(SprintCatalog.cfg("request.before_renewal_weeks")))
	var first: int = TimeModel.ticks(int(SprintCatalog.cfg("request.first_after_weeks")))
	for c in accounts:
		var renewal: int = next_renewal_day(c)
		if GameState.day == renewal - lead:
			CustomerRegistry.set_market_ref(c.id, ProductQuality.market_ref_for(c.scale, c.industry))
		var window: int = renewal - lead if GameState.day >= renewal - lead else c.acquired_on_day + first
		if GameState.day < window or requests.any(func(r: Dictionary) -> bool:
				return r.customer_id == c.id and (r.status == "open" or int(r.day) >= window)):
			continue
		var area: String = ProductQuality.emphasis(c.industry)[0]
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


## Hesabın yenileme penceresinin gösterdiği yenileme günü: sözleşme imza gününden `request.contract_weeks` haftada bir
## yenilenir ve pencere yenilemeden `request.before_renewal_weeks` hafta önce açılır. İlk pencere açılana dek ilk yenileme
## döner; pencere açılınca o yenileme, geçse de bir sonraki pencereye kadar.
static func next_renewal_day(c: Customer) -> int:
	var term: int = TimeModel.ticks(int(SprintCatalog.cfg("request.contract_weeks")))
	var lead: int = TimeModel.ticks(int(SprintCatalog.cfg("request.before_renewal_weeks")))
	return c.acquired_on_day + maxi(1, int(float(GameState.day - c.acquired_on_day + lead) / term)) * term


## Herkese açık sürüm, kademeler yazıldıktan sonra: kademesi canlıya geçen açık talep zamanında
## karşılanmıştır (geç kalan talep tick_requests'te çoktan düşmüştür). Sunucuya dokunulmaz: kapasiteyi
## yalnız oyuncu ve açtığı otomatik ayar değiştirir.
static func on_release() -> void:
	for r in _p().requests:
		if r.status == "open" and ProductState.is_feature_live(r.step):
			r.status = "met"


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
			var expect: float = ProductQuality.expectation(change.area)
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
		var from: String = ProductQuality.word_for(float(change.from), ProductQuality.expectation(change.area))
		var to: String = ProductQuality.word(change.area)
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


# --- Sürüm anı: teşekkür ve yorum -------------------------------------------------------

## Teşekkür notunun kartı; gövdesinin hangi varyant olduğunu `musteri.thanks_variant` söyler.
const THANKS_CARD := "customer.release_thanks"


## Sürüm kapanışında, söz ve istek çözüldükten sonra bir kez: sürüme teşekkür eden hesapların notunu ister ve sürüm
## kaydına `thanks` olarak yazar ({customer, trigger, feature, variant}). Üç tetikleyici öncelik sırasıyla söz tutuldu,
## istek karşılandı, acil durum hızla kapandı; bir hesap sürümde en çok bir not, sürüm en çok `thanks.max` [WORKING] not alır.
static func thank(release: Dictionary) -> void:
	var thanks: Array = []
	release["thanks"] = thanks
	for c in _thanks_candidates(release):
		if thanks.size() == int(SprintCatalog.cfg("thanks.max")):
			break
		if thanks.any(func(t: Dictionary) -> bool: return t.customer == c.customer):
			continue
		thanks.append({"customer": c.customer, "trigger": c.trigger, "feature": c.feature,
			"variant": _thanks_variant(c, int(release.number))})
		if not EventGate.request(THANKS_CARD, {"customer": c.customer}):
			thanks.pop_back()


## Hesabın en son teşekküründeki kayıt, yoksa {}; kartın seam'leri (`musteri.thanks_variant`, `musteri.met_feature`) okur.
static func thanks_of(customer_id: String) -> Dictionary:
	var releases: Array = _p().get("releases", [])
	for i in range(releases.size() - 1, -1, -1):
		for t in releases[i].get("thanks", []):
			if t.customer == customer_id:
				return t
	return {}


## Teşekkür edebilecek hesaplar, en çok hak edenden başlayarak: tutulan söz, karşılanan istek, hızla kapanan acil durum;
## her tetikleyicide büyük hesap önde. Acil durum, önceki sürümden bu yana olduysa sayılır: sürüm çıkarmadan kapanan
## sprint aralığı açmaz.
static func _thanks_candidates(release: Dictionary) -> Array:
	var steps: Array = release.shipped.map(func(c: Dictionary) -> String: return c.step)
	var words: Array = PromiseRegistry.get_all().filter(func(p: Promise) -> bool:
		return p.status == "kept" and p.feature_id in steps).map(func(p: Promise) -> Dictionary:
			return {"customer": p.customer_id, "trigger": "promise", "feature": p.feature_id, "moved": p.extended})
	var asked: Array = _p().requests.filter(func(r: Dictionary) -> bool: return r.status == "met" and r.step in steps).map(
		func(r: Dictionary) -> Dictionary: return {"customer": r.customer_id, "trigger": "request", "feature": r.step})
	var larger := func(a: Dictionary, b: Dictionary) -> bool:
		return SprintCatalog.larger_account(CustomerRegistry.get_customer(a.customer), CustomerRegistry.get_customer(b.customer))
	words.sort_custom(larger)
	asked.sort_custom(larger)
	var fast: Dictionary = IncidentSystem.quick_fix()
	var before: Array = _p().releases.slice(0, -1).filter(func(r: Dictionary) -> bool: return int(r.number) > 0)
	var since: int = int(before.back().day) * MailClock.DAY_MINUTES if not before.is_empty() else 0
	if not fast.is_empty() and int(GameState.incident.open.start) >= since:
		return words + asked + [{"customer": fast.customer, "trigger": "incident", "feature": "", "night": fast.night}]
	return words + asked


## Notun gövdesi: tetikleyicinin kartta yazılı gövdelerinden hesap ve sürümle seçilir; aynı tetikleyicide en son
## kullanılan dönmez.
static func _thanks_variant(c: Dictionary, number: int) -> int:
	var pool: Array = _thanks_pool(c)
	var sent: Array = []
	for r in _p().releases:
		sent.append_array(r.get("thanks", []).filter(func(t: Dictionary) -> bool: return t.trigger == c.trigger))
	if not sent.is_empty():
		pool.erase(int(sent.back().variant))
	return pool[floori(EvDice.unit("thanks", number, c.customer, "") * pool.size())]


## Kartın gövdelerinden tetikleyicinin doğru söyleyebilecekleri: gece düzeltmesine ancak gece kapanan olay, ertelenmiş
## söze ancak yeni tarihi anan gövdeler uyar.
static func _thanks_pool(c: Dictionary) -> Array:
	match String(c.trigger):
		"incident":
			return [0, 1, 2, 3, 4] if c.night else [0, 1, 2]
		"promise":
			return [5, 7, 9] if c.moved else [5, 6, 7, 8]
	return [10, 11, 12, 13]


## Sürümden bir tik sonra, B2C güncellemesinin notuna yorum satırı: 2 ya da 3 kısa yorum (`ids`), adlı yorumların andığı
## özellik (`feature`, kademe kimliği) ve yorumların ekrana geleceği an (`at`); B2B'de ve v1.0'da {}. Sırayla: sürümde
## canlıya geçen kademe (kimlik hattınınsa adlı ya da adsız, ortak hattınsa adsız), kapanan bir düzeltme, hatalı çıkan ya da
## açık hatası eşiği geçen hattın olumsuz yorumu (sonda); 2'nin altında kalırsa adsız yorumla tamamlanır. Olumsuz yorumun
## yanına yalnız sakin adsız yorum konur. Aynı metin `reviews.repeat_weeks` hafta dönmez. Sayılar `reviews` bloğunda [WORKING].
static func pick_reviews(release: Dictionary) -> Dictionary:
	if int(release.number) < 2 or SalesSystem.is_b2b_market():
		return {}
	var cfg: Dictionary = SprintCatalog.cfg("reviews")
	var number: int = int(release.number)
	var shown: Array = []
	for r in _p().releases:
		if GameState.day - int(r.day) < TimeModel.ticks(int(cfg.repeat_weeks)):
			shown.append_array(r.get("reviews", {}).get("ids", []))
	var tiers: Array = release.shipped.filter(func(c: Dictionary) -> bool:
		return c.kind in ["feature", "request"] and c.line != SprintCatalog.PAID_PLAN)
	var identity: Array = tiers.filter(func(c: Dictionary) -> bool: return not ProductLines.line(c.line).shared)
	identity.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return [a.target_tier, SprintSystem.total(a)] > [b.target_tier, SprintSystem.total(b)])
	var feature: String = String(identity[0].step) if not identity.is_empty() else ""
	var fixed: bool = release.shipped.any(func(c: Dictionary) -> bool: return c.kind == "fix" and int(c.bugs) > 0)
	var unhappy: Dictionary = _unhappy(release, int(cfg.neg_line_bugs))
	var plain: Array = cfg.plain.filter(func(e: Dictionary) -> bool: return unhappy.is_empty() or e.get("calm", false))
	var picks: Array = []
	if not tiers.is_empty():
		var named: bool = feature != "" and ((not fixed and unhappy.is_empty())
				or EvDice.unit("review", number, "named", "") < float(cfg.named_share))
		_add_review(picks, cfg.named if named else plain, "new", number, shown)
	if fixed:
		_add_review(picks, cfg.fix, "fix", number, shown)
	for pad in maxi(0, int(cfg.min) - (0 if unhappy.is_empty() else 1) - picks.size()):
		_add_review(picks, plain, "pad%d" % pad, number, shown)
	if not unhappy.is_empty():
		var group: Array = cfg.neg.get(String(unhappy.line).get_slice("@", 0), cfg.neg.other)
		_add_review(picks, group.filter(func(e: Dictionary) -> bool:
			return (unhappy.blames or not e.get("blames", false)) and ProductState.line_tier(unhappy.line) >= int(e.get("tier", 0))),
			"neg", number, shown)
	if picks.is_empty():
		return {}
	return {"ids": picks.map(func(e: Dictionary) -> String: return e.id), "feature": feature,
		"at": MailClock.arrival("reviews:%d" % number)}


## Olumsuz yorumu yazacak hat ve yorumun güncellemeyi suçlayıp suçlamadığı: sürümden hata kaçtıysa o hat, değilse açık
## hatası eşikte ya da üstünde olan en kötü hat; yoksa {}.
static func _unhappy(release: Dictionary, line_bugs: int) -> Dictionary:
	var escaped: Array = release.get("escaped", [])
	var blames: bool = not escaped.is_empty()
	var lines: Array = escaped if blames else ProductState.open_bugs_by_line().keys().filter(
		func(l: String) -> bool: return ProductState.costed(ProductState.line_bugs(l)) >= line_bugs)
	var bugs: Dictionary = {}
	for line in lines:
		bugs[line] = ProductState.line_bugs(line)
	var worst: String = ProductState.worst_bug_line(bugs)
	return {} if worst == "" else {"line": worst, "blames": blames}


## Havuzdan henüz seçilmemiş bir yorum ekler, yakında gösterilmemiş olanı yeğler; havuz tükendiyse eklemez.
static func _add_review(picks: Array, pool: Array, salt: String, number: int, shown: Array) -> void:
	var open: Array = pool.filter(func(e: Dictionary) -> bool: return e not in picks)
	var fresh: Array = open.filter(func(e: Dictionary) -> bool: return e.id not in shown)
	var from: Array = fresh if not fresh.is_empty() else open
	if not from.is_empty():
		picks.append(from[floori(EvDice.unit("review", number, salt, "") * from.size())])


## Sürüm notunun yorum satırları ekranın dilinde ({source, text}); yorumlar kendi anına gelene dek ve B2B'de yok.
static func review_lines(release: Dictionary) -> Array:
	var reviews: Dictionary = release.get("reviews", {})
	if reviews.is_empty() or not MailClock.delivered(int(reviews.at)):
		return []
	var cfg: Dictionary = SprintCatalog.cfg("reviews")
	var entries: Array = cfg.named + cfg.plain + cfg.fix
	for group in cfg.neg.values():
		entries += group
	var feature: String = SprintCatalog.step_name(reviews.feature) if reviews.feature != "" else ""
	return reviews.ids.map(func(id: String) -> Dictionary:
		var entry: Dictionary = entries.filter(func(e: Dictionary) -> bool: return e.id == id)[0]
		return {"source": TranslationServer.translate(entry.src), "text": TranslationServer.translate(
			"PRODUCT_REVIEW_QUOTED").format({"review": TranslationServer.translate(id).format({"feature": feature})})})


# --- İç -------------------------------------------------------------------------------

static func _p() -> Dictionary:
	return GameState.product
