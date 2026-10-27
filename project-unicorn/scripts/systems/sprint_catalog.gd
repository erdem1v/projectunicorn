class_name SprintCatalog
extends RefCounted

# Ürün sprint ekranının kataloğu: alanlar ve yetenekleri, alan seviyesi ve durumu, aday kartlar,
# kartın etki satırı, sprint sonu öngörüsü, hatanın etkilediği hesaplar, liderin önerisi ve rakip tablosu. Yalnız okur; ürün
# durumunu SprintSystem ve köprüsü SprintBridges yazar. Adaylar saklanmaz, her çağrıda durumdan
# kurulur.
# Çalışma değerleri sprint.json'da, rakip tablosu rivals.json'da. Metin TranslationServer'dan
# okunur, çünkü statik fonksiyonda tr() çalışmaz.

const DATA_PATH := "res://data/product/sprint.json"
const RIVALS_PATH := "res://data/product/rivals.json"
## Gelir alanının tek yeteneği: katalogda hattı yok, ücretli katmanın açık olmasından okunur.
const PAID_PLAN := "cap_paid_plan"
const PAID_PLAN_NAME_KEY := "PRODUCT_CAP_PAID_PLAN"
## Çeyrek hedefinin alan olmayan seçeneği ("Hatalar"): hedefin kartları düzeltme kartlarıdır.
const GOAL_BUGS := "bugs"
## Liderin önerecek kartı yok: bu sprinte de sonraki sütuna da.
const NO_LEAD := {"this": [], "next": []}
const SEP := " · "
const STAR := "★"

static var _data: Dictionary = {}
static var _rivals: Dictionary = {}


static func load_data() -> void:
	_data = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	_rivals = JSON.parse_string(FileAccess.get_file_as_string(RIVALS_PATH))


## sprint.json'a nokta yolu: cfg("effort.k1"), cfg("request.deadline_weeks").
static func cfg(path: String) -> Variant:
	if _data.is_empty():
		load_data()
	var v: Variant = _data
	for key in path.split("."):
		v = v[key]
	return v


# --- Alanlar ve yetenekler ------------------------------------------------------

## Pazarın alanları sırasıyla. Tür seçilmeden alan yoktur.
static func areas_for(subtype: String, market: String) -> Array:
	if subtype == "":
		return []
	var out: Array = (cfg("areas") as Array).filter(func(a: Dictionary) -> bool: return market in a.markets)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.order < b.order)
	return out.map(func(a: Dictionary) -> Dictionary: return a.duplicate(true))


static func area_ids() -> Array:
	return _areas().map(func(a: Dictionary) -> String: return a.id)


static func area_of_line(line_id: String) -> String:
	for area in _areas():
		if line_id in capabilities(area.id):
			return area.id
	return ""


## Alanın yetenekleri: hat kimlikleri (paylaşılan hat alt-türüyle, `@note_tool`) ve Gelir'de
## ücretli plan. Gizli hat ancak Ar-Ge onu açınca listeye girer. `subtype` canlı üründen başka bir ürün içindir
## (kayıt göçü kendi kaydının ürününü okur).
static func capabilities(area_id: String, subtype: String = ProductState.subtype()) -> Array[String]:
	var key: String = "capabilities/" + area_id + "/" + subtype
	if not ProductLines.memo.has(key):
		ProductLines.memo[key] = _capabilities_of(area_id, subtype)
	return ProductLines.memo[key].duplicate()


static func _capabilities_of(area_id: String, subtype: String) -> Array[String]:
	var area: Dictionary = area_def(area_id)
	var out: Array[String] = []
	for line_id in ProductLines.line_ids(subtype):
		var identity: bool = area.get("identity", false) and not ProductLines.line(line_id).shared
		if identity or line_id.get_slice("@", 0) in area.lines:
			out.append(line_id)
	if PAID_PLAN in area.lines:
		out.append(PAID_PLAN)
	return out


static func cap_name(line_id: String) -> String:
	if line_id == PAID_PLAN:
		return _t(PAID_PLAN_NAME_KEY)
	return _t(ProductLines.line(line_id).name_key)


static func tier(line_id: String) -> int:
	if line_id == PAID_PLAN:
		return int(GameState.get_flag("b2c_paid_tier_open", false))
	return ProductState.line_tier(line_id)


static func polish(line_id: String) -> float:
	return float(_p().get("polish", {}).get(line_id, 0.0))


static func area_name(area_id: String) -> String:
	return _t(area_def(area_id).name_key)


## Etki satırında ve hedefte kullanılan kısa ad.
static func area_short(area_id: String) -> String:
	return _t(area_short_key(area_id))


static func area_short_key(area_id: String) -> String:
	return area_def(area_id).name_key + "_SHORT"


## sprint.json'daki alan kaydı (ad anahtarı, renk yuvası, hatlar).
static func area_def(area_id: String) -> Dictionary:
	return (cfg("areas") as Array).filter(func(a: Dictionary) -> bool: return a.id == area_id)[0]


## Çalışanın kapasite satırı ("design", "dev", "test"): rolünün ana alanının aşaması (`role_areas`). Ürün rolünün (PM)
## satırı yoktur, "".
static func row_of(c: Character) -> String:
	var area: String = HRConstants.role_key_area(c.role)
	var roles: Dictionary = cfg("role_areas")
	for stage in ["design", "dev", "test"]:
		if roles[stage] == area:
			return stage
	return ""


# --- Seviye, durum ------------------------------------------------------------------

## Ekranın gösterdiği seviye: yarıma yuvarlanmış (0..3). Kelime ve ekonomi yuvarlanmamışı okur (ProductQuality).
static func display_level(raw: float) -> float:
	return snappedf(raw, 0.5)


## Yarıma yuvarlanmış alan seviyesi.
static func area_level(area_id: String) -> float:
	return display_level(ProductQuality.level(area_id))


## "!": yeteneklerinden birinde öncelik eşiği kadar açık hata, ya da (Güven & Ölçek) sunucu aşımı;
## `cleared` hatlarının hataları kapanmış sayılır.
static func area_alert(area_id: String, cleared: Array = []) -> bool:
	if _over_capacity(area_id):
		return true
	return capabilities(area_id).any(func(line_id: String) -> bool:
		return line_id not in cleared and is_priority_count(ProductState.line_bugs(line_id)))


## Kapalı satırın cümlesi: alanın kime yettiği, açık hata, sunucu aşımı, rakip çıkışı ve araştırmadan sonraki
## `research_sentence_weeks` haftada kullanıcıların söylediği.
static func area_sentence(area_id: String) -> String:
	var parts: PackedStringArray = []
	var standing: String = _standing(area_id)
	if standing != "":
		parts.append(standing)
	var n: int = 0
	for line_id in capabilities(area_id):
		n += ProductState.line_bugs(line_id)
	if n > 0:
		parts.append(_t(Fmt.count_key("PRODUCT_BUG_COUNT", n)).format({"n": Fmt.group(n)}))
	if _over_capacity(area_id):
		parts.append(_t("PRODUCT_AREA_OVER_CAPACITY"))
	var hit: Dictionary = _recent_hit(area_id)
	if not hit.is_empty():
		parts.append(_t("PRODUCT_AREA_RIVAL").format({"rival": rival_name(int(hit.rival))}))
	var researched: Variant = _p().get("research_done", {}).get(area_id)
	if researched != null and SprintSystem.sprint_number() - int(researched) \
			<= SprintSystem.sprints_in(int(cfg("research_sentence_weeks"))):
		parts.append(_t("PRODUCT_RESEARCH_VOICE_" + area_id.to_upper()))
	return SEP.join(parts)


# --- Kartlar ---------------------------------------------------------------------

## Düzeltme kartının eforu: hattın açık hatası başına `fix_effort.per_bug` puan, alt sınır yok.
static func fix_effort(bugs: int) -> int:
	return bugs * int(cfg("fix_effort.per_bug"))


## k: mutlak hata eşiklerinin (itibar ihmal eşiği, botun düzeltme eşiği) ekiple oranlanan çarpanı. En büyüğü:
## 1, canlı hat ÷ `limit_k.lines`, √(son `limit_k.weeks` haftanın haftalık teslimi ÷ `limit_k.delivery`); haftalık teslim
## son sprintlerin sürüm kayıtlarında bitirilen puanın koştukları haftaya bölümüdür (erken kapanan sprint bir haftadır).
static func limit_k() -> float:
	var k: Dictionary = cfg("limit_k")
	var recent: Array = _p().get("releases", []).slice(-SprintSystem.sprints_in(int(k.weeks)))
	var done: float = 0.0
	var weeks: int = 0
	for r in recent:
		done += float(r.velocity.done)
		weeks += int(r.velocity.get("weeks", SprintSystem.sprint_weeks()))
	var weekly: float = done / maxi(1, weeks)
	return maxf(1.0, maxf(ProductState.live_lines().size() / float(k.lines), sqrt(weekly / float(k.delivery))))


## K1 15 · K2 25 · K3 40; Ar-Ge "design_system" tasarım profilli hatların kademe eforunu %20 indirir.
static func step_effort(step_id: String) -> int:
	if step_id == PAID_PLAN:
		return int(cfg("paid_plan.effort"))
	var step: Dictionary = ProductLines.step(step_id)
	var effort: int = int(cfg("effort.k%d" % int(step.tier)))
	if ProductLines.work_profile(step.line_id) == "design" and ResearchSeam.completed("design_system"):
		return maxi(1, roundi(effort * ProductLines.RND_DESIGN_EFFORT_MULT))
	return effort


## Kartın aşama ihtiyacı [Tasarım, Geliştirme, Test] puan (araştırmada ilk aşama Ürün'ündür): `effort` puan, kartın türünün
## ya da hattın iş profilinin kademe satırının (sprint.json `need`) oranlarıyla paylaşılır. Ücretli planın kendi satırı
## vardır; kademesi ya da profili olmayan özellik kartı (ör. kademesiz kartın takip kartı) `unprofiled` oranını alır.
static func card_need(kind: String, line: String, tier: int, effort: float) -> Array:
	var row: Array = _need_row(kind, line, tier)
	var sum: float = float(row[0]) + float(row[1]) + float(row[2])
	return row.map(func(part: float) -> float: return part * effort / sum)


## Alanın aday kartları (PRD §3.2): yetenek başına sonraki kademe (kapısı kapalıysa da görünür),
## açık talep o kademeyi talep kartına çevirir, açık hatası olan yetenek başına düzeltme, alan başına
## araştırma (yapıldığı sprintin ardından bir kapanış gizli). Sprintte ya da sonrakinde duran kart
## saklanan hâliyle döner. Sıra: öncelikli önde, kilitsiz önde, sonra etki/efor azalan.
static func candidates(area_id: String) -> Array:
	var stored: Dictionary = _p().get("cards", {})
	var requests: Dictionary = {}
	for r in open_requests():
		requests[String(r.step)] = r
	var out: Array = []
	var caps: Array[String] = capabilities(area_id)
	for line_id in caps:
		if line_id == PAID_PLAN:
			if tier(PAID_PLAN) < max_tier(PAID_PLAN):
				out.append(new_card("plan:" + PAID_PLAN, "feature", area_id, step_effort(PAID_PLAN), line_id, PAID_PLAN, 1))
			continue
		var next: int = ProductLines.next_tier(tier(line_id))
		if next == 0:
			continue
		var step: String = ProductLines.step_at(line_id, next).id
		var request: Variant = requests.get(step)
		if request != null and not stored.has("feat:" + step):
			var card: Dictionary = new_card("req:" + str(request.id), "request", area_id, step_effort(step), line_id,
				step, next)
			card.customer_id = request.customer_id
			card.request_id = str(request.id)
			out.append(card)
		else:
			out.append(new_card("feat:" + step, "feature", area_id, step_effort(step), line_id, step, next))
	var bugs: Dictionary = ProductState.open_bugs_by_line()
	for line_id in caps:
		if bugs.has(line_id):
			var card: Dictionary = new_card("fix:" + line_id, "fix", area_id, fix_effort(int(bugs[line_id])), line_id)
			card.bugs = int(bugs[line_id])
			out.append(card)
	var researched: Variant = _p().get("research_done", {}).get(area_id)
	if researched == null or SprintSystem.last_closed() > int(researched):
		out.append(new_card("res:" + area_id, "research", area_id, int(cfg("effort.research"))))
	var keyed: Array = out.map(func(c: Dictionary) -> Array:
		var card: Dictionary = (stored.get(c.id, c) as Dictionary).duplicate(true)
		return [[float(is_priority(card)), float(gate_reason(card.step) == ""), _ratio(card)], card])
	keyed.sort_custom(func(a: Array, b: Array) -> bool:
		for i in a[0].size():
			if a[0][i] != b[0][i]:
				return a[0][i] > b[0][i]
		return a[1].id < b[1].id)
	return keyed.map(func(k: Array) -> Dictionary: return k[1])


## Öncelikli düzeltme: hattın açık hatası öncelik eşiğinde ya da üstünde.
static func is_priority(card: Dictionary) -> bool:
	return card.kind == "fix" and is_priority_count(card.bugs)


## Bir hattın `bugs` açık hatası öncelik eşiğinde ya da üstünde mi.
static func is_priority_count(bugs: int) -> bool:
	return bugs >= int(cfg("fix_effort.priority"))


## Yeni kart: `effort` puanlık ihtiyaç aşamalara paylaşılır, rolleri ihtiyacı olan aşamaların rolleridir (en çok üç).
## `cut` kısaltılmış testin karttan düşen işidir (SprintBugs).
static func new_card(id: String, kind: String, area_id: String, effort: int, line := "", step := "",
		target_tier := 0) -> Dictionary:
	var need: Array = card_need(kind, line, target_tier, effort)
	var roles: Array = cfg("roles." + kind)
	return {"id": id, "kind": kind, "line": line, "step": step, "target_tier": target_tier, "area": area_id,
		"need": need, "roles": range(need.size()).filter(func(i: int) -> bool: return need[i] > 0.0).map(
			func(i: int) -> String: return roles[i]),
		"progress": [0.0, 0.0, 0.0], "state": "candidate", "assignees": [], "bugs": 0, "customer_id": "",
		"request_id": "", "decision": false, "cut": 0.0}


## Saklanan kart ya da adayı; yoksa {}.
static func card_by_id(card_id: String) -> Dictionary:
	var stored: Dictionary = _p().get("cards", {})
	if stored.has(card_id):
		return stored[card_id]
	for area in _areas():
		for card in candidates(area.id):
			if card.id == card_id:
				return card
	return {}


## Kartın adı: kademe adı, "{yetenek} düzeltmesi", "{n} kullanıcıyla görüş" ya da "{kademe} ({müşteri})".
static func card_name(card: Dictionary) -> String:
	match card.kind:
		"fix":
			return _t("PRODUCT_FIX_CARD").format({"capability": cap_name(card.line)})
		"research":
			return _t("PRODUCT_RESEARCH_CARD").format({"n": int(cfg("research_users"))})
		"request":
			# Hesabı kapanan müşterinin talebi ertesi tike kadar kartta kalır; adı boş parantez yazmasın.
			var customer: String = customer_name(card)
			if customer != "":
				return _t("PRODUCT_REQUEST_CARD").format({"step": step_name(card.step), "customer": customer})
	return step_name(card.step)


## Kartın son tarihi (sprint numarası): kademesine verilmiş en yakın açık söz, yoksa karşıladığı açık talebin son tarihi;
## ikisi de yoksa -1. Sprint hesabı olmayan (gün sayan) söz son tarih vermez.
static func due_sprint(card: Dictionary) -> int:
	for p in _promises_on(card.step):
		if p.due_sprint >= 0:
			return p.due_sprint
	var request: Dictionary = _request_of(card)
	return -1 if request.is_empty() else int(request.due_sprint)


## Kilitli kademenin gerekçesi ("2★ Tasarım gerekli"), yalnız karşılanmayan parçalarla; kilitsizse "". Ücretli
## plan yayındaki ürünün katmanıdır, MVP'den önce açılmaz.
static func gate_reason(step_id: String) -> String:
	if step_id == PAID_PLAN:
		return "" if ProductState.is_live() else _t("PRODUCT_LOCK_LIVE")
	if ProductLines.step(step_id).is_empty():
		return ""
	var parts: PackedStringArray = []
	for part in LineGates.unmet_parts(step_id):
		if part.kind == LineGates.KIND_RESEARCH:
			parts.append(_t("PROD_LOCK_RESEARCH").format({"node": ResearchSeam.node_name(part.node)}))
		elif part.kind == LineGates.KIND_TOTAL:
			var have: float = part.have
			parts.append(_t("PROD_LOCK_TOTAL").format({"area": HRConstants.area_label(part.area),
				"stars": str(part.stars) + STAR,
				"have": (str(roundi(have)) if is_equal_approx(have, roundf(have)) else Fmt.number(have, 1)) + STAR}))
		else:
			parts.append(_t("PROD_LOCK_PERSON").format({"area": HRConstants.area_label(part.area),
				"stars": str(part.stars) + STAR}))
	return SEP.join(parts)


## Kartın etki satırı (ProductModel `part`): alan dilim geçişi, değişmiyorsa "Alan X kalır" ve
## yeteneğin geçişi; rakip açığı, talep ve verilmiş söz; düzeltmede hata sayısı, etkilenenler ve "!" kalkışı.
static func card_effect(card: Dictionary) -> Array:
	var area: String = card.area
	match card.kind:
		"fix":
			var parts: Array = [bugs_part(card.line, card.bugs)]
			if _clears_alert(card):
				parts.append({"k": "alert_clear", "area": area_short(area)})
			return parts
		"research":
			return [{"k": "research", "area": area_short(area)}]
	var level: Dictionary = _level_part(area, {card.line: card.target_tier})
	var out: Array = []
	if level.to != level.from:
		out.append(level)
	else:
		var cap_max: float = max_tier(card.line)
		var expect: float = ProductQuality.expectation(area)
		var cap_from: float = minf(tier(card.line) + polish(card.line), cap_max)
		var cap_to: float = minf(card.target_tier + polish(card.line), cap_max)
		out.append({"k": "holds", "area": area_short(area), "word": level.to_word})
		out.append({"k": "cap", "name": cap_name(card.line), "from": cap_from, "to": cap_to,
			"from_word": ProductQuality.word_for(cap_from, expect), "to_word": ProductQuality.word_for(cap_to, expect)})
	var request: Dictionary = _request_of(card)
	if not request.is_empty():
		out.append({"k": "request", "customer": customer_name(request), "value": int(request.value)})
	out.append_array(_promise_parts(card.step))
	return out


# --- Etkilenenler -----------------------------------------------------------------------

## B2B'de hattı kullanan hesaplar: aktif ya da deneme hesabı, sektörü hattın alanını kullanıyorsa
## (`ProductQuality.uses_area`: Çekirdek ve sektörün iki vurgusu). Hesap başına bedeli yazan olay da bu listeyi okur.
static func line_accounts(line_id: String) -> Array:
	var area: String = area_of_line(line_id)
	return CustomerRegistry.get_all().filter(func(c: Customer) -> bool:
		return c.market_type == "b2b" and c.status in ["active", "trial"] and ProductQuality.uses_area(c.industry, area))


## Hattın B2C kitle payı: her canlı hat bir pay artı kademesinin kullanım ağırlığı kadar alır; canlı olmayan hat 0.
static func line_share(line_id: String) -> float:
	var pulls: Dictionary = {}
	for live in ProductState.live_lines():
		pulls[live] = 1 + ProductLines.usage_weight_of(String(ProductLines.step_at(live, ProductState.line_tier(live)).id))
	var total: int = 0
	for pull in pulls.values():
		total += pull
	return float(pulls.get(line_id, 0)) / maxi(1, total)


## Hattın açık hatasından etkilenenler. B2B: {accounts, seats, top_id, top_seats}; en büyük hesap koltuk
## sayısıyla seçilir, eşitlikte MRR, sonra kimlik (hesap yoksa top_id ""). B2C: {users}, kitle × hattın payı.
static func line_impact(line_id: String) -> Dictionary:
	if ProductState.market_type() != "b2b":
		return {"users": roundi(SalesSystem.b2c_audience() * line_share(line_id))}
	var accounts: Array = line_accounts(line_id)
	accounts.sort_custom(larger_account)
	var seats: int = 0
	for c in accounts:
		seats += c.seats
	return {"accounts": accounts.size(), "seats": seats, "top_id": accounts[0].id if not accounts.is_empty() else "",
		"top_seats": accounts[0].seats if not accounts.is_empty() else 0}


## Büyük hesap önce: koltuk sayısı, eşitlikte MRR, sonra kimlik.
static func larger_account(a: Customer, b: Customer) -> bool:
	if a.seats != b.seats:
		return a.seats > b.seats
	return a.mrr > b.mrr if a.mrr != b.mrr else a.id < b.id


## Hattın açık hatasından etkilenen kullanıcılar: B2B'de hattı kullanan hesapların koltukları, B2C'de kitle payı.
static func line_users(line_id: String) -> int:
	return _users_of(line_impact(line_id))


## Paylaşılan bir hat ya da kademe temel kimliğiyle (`line_shared_mobile`, `line_shared_mobile_k1`) yazılırsa ürünün kendi
## kimliği (`id@alt-tür`); öbür kimlikler olduğu gibi. Kart verisi alt-türden bağımsız yazılır.
static func in_product(id: String) -> String:
	var shared: String = "%s@%s" % [id, ProductState.subtype()]
	return shared if not ProductLines.line(shared).is_empty() or not ProductLines.step(shared).is_empty() else id


## Karar kartının hattını kullanan hesaplardan kâğıdın konusu olan (`select` kipi): "line_top" en büyük, "line_warehouse" depo
## işi sektörlerindeki (sprint.json `paper.warehouse_sectors`) en büyük, "line_newest" en yeni imzalanan, "line_slow"
## `paper.slow_seats` koltuğa varan en büyük, "request" kartı isteyen hesap. `used`taki hesaplar sayılmaz. Karar ya da
## böyle bir hesap yoksa "".
static func paper_account(mode: String, used: Dictionary) -> String:
	var card: Dictionary = SprintSystem.decision_card()
	if card.is_empty():
		return ""
	if mode == "request":
		return String(card.customer_id)
	var accounts: Array = line_accounts(card.line).filter(func(c: Customer) -> bool:
		if used.has(c.id):
			return false
		match mode:
			"line_warehouse":
				return c.industry in cfg("paper.warehouse_sectors")
			"line_slow":
				return c.seats >= int(cfg("paper.slow_seats"))
		return true)
	accounts.sort_custom(func(a: Customer, b: Customer) -> bool:
		if mode == "line_newest" and a.acquired_on_day != b.acquired_on_day:
			return a.acquired_on_day > b.acquired_on_day
		return a.id < b.id if mode == "line_newest" else larger_account(a, b))
	return "" if accounts.is_empty() else accounts[0].id


## Karar kartı bir isteğin kartıysa o kademeyi isteyen öbür hesap (en büyüğü), yoksa null.
static func second_account(card: Dictionary) -> Customer:
	var asking: Array = open_requests().filter(func(r: Dictionary) -> bool:
		return r.step == card.get("step", "") and r.customer_id != card.get("customer_id", ""))
	var accounts: Array = asking.map(func(r: Dictionary) -> Customer: return CustomerRegistry.get_customer(r.customer_id))
	accounts.sort_custom(larger_account)
	return null if accounts.is_empty() else accounts[0]


## Düzeltme kartının ve hat satırının hata sayısı parçası (ProductModel `part`): `n` hata, hesap (B2C'de -1) ve kullanıcı
## sayısı, B2B'de en büyük hesabın adı ve koltuğu (hesap yoksa adı "").
static func bugs_part(line_id: String, n: int) -> Dictionary:
	var impact: Dictionary = line_impact(line_id)
	var part := {"k": "bugs", "n": n, "accounts": -1, "users": _users_of(impact), "top": "", "top_users": 0}
	if impact.has("top_id"):
		var top: Customer = CustomerRegistry.get_customer(impact.top_id)
		part.merge({"accounts": impact.accounts, "top": top.display_name() if top != null else "",
			"top_users": impact.top_seats}, true)
	return part


# --- Lider ---------------------------------------------------------------------------

## Liderin önerisi {this, next}: `this` bu sprintin, `next` sonraki sütunun kartları. `this` sprintin uygulanan yerleşimine altı
## basamak sırasıyla kart ekler: (1) verilmiş sözlerin kartları, son tarihi yakın önde, ardından ücretli plan; (2) son tarihi bu
## ya da sonraki sprint olan en yakın talep (sprintte en çok bir talep); (3) bırakılan ve devreden kartlar; (4) öncelikli
## düzeltmeler; (5) çeyrek hedefinin en iyi kartı ("Hatalar" hedefinde düzeltme kartları), hedef yoksa liderin alanının;
## (6) kalanlar etki ÷ iş sırasıyla. Düzeltme pay tavanını (`SprintSystem.fix_share_takes`) aşan düzeltme kartı alınmaz. Her aday
## sprintin alım kuralından (`SprintSystem.intake`, "+" ile aynı) geçer; uymayan atlanır, öneri art arda en çok `lead.skip`
## aday atlar ve bir sonraki uymayanda durur. Kalan yeri dolduran 6. basamak yalnız bitecek kartları alır, en çok bir devreden
## kartla durur. `next` aynı sırayı baştan dolaşır: `this`'e giren kartlar atlanır, bu sprintte sığmadığı ya da tavana takıldığı
## için atlanan kart yeniden denenir. Sütunun yerleşimi içinde duran kartlardır (oyuncunun "→"u ve onaylı PM planı önde); alım
## sınaması, düzeltme payı, atlama sayacı ve 6. basamağın kalkanı sütun için ayrıca sayılır. Sütunun yükü, kartlarının kalanı
## artı `this` oynatmasında sütuna devredecek iş, ekibin kapasitesini (%100, %125 tavanı sütunda yoktur) aşmaz. Onaylı PM
## planlarının kartları o sprintlere ayrılmıştır, lider onlara dokunmaz; onaysız plan hiçbir sütuna konmaz.
static func lead_suggestion() -> Dictionary:
	var pool: Array = open_cards(_approved_ahead())
	var people: Array = SprintSystem.team()
	var capacity: float = SprintSystem.capacity_of(people)
	if pool.is_empty() or capacity <= 0.0:
		return NO_LEAD
	var score: Dictionary = {}
	for c in pool:
		score[c.id] = _ratio(c)
	pool.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return score[a.id] > score[b.id] if score[a.id] != score[b.id] else a.id < b.id)
	var steps: Array = _lead_steps(pool, quarter_goal(), capacity)
	var order: Array = steps + pool.filter(func(c: Dictionary) -> bool: return score[c.id] > 0.0)
	var this: Array = _lead_picks(order, steps.size(), SprintSystem.starting(), [], people, INF)
	var column: Array = (_p().next.cards as Array).map(func(id: String) -> Dictionary: return _p().cards[id])
	var room: float = capacity - SprintSystem.points_left(_p().next.cards) \
		- SprintSystem.carried_points(SprintSystem.starting() + this, people)
	var ids := func(cards: Array) -> Array: return cards.map(func(c: Dictionary) -> String: return c.id)
	return {"this": ids.call(this), "next": ids.call(_lead_picks(order, steps.size(), column, this, people, room))}


## `order` sırasıyla `placed` yerleşimine eklenecek kartlar (öneri iki sütunu da bununla kurar): `skip` o sütuna girmeyecek
## kartlar, `room` eklenenlerin kalan puan toplamının üst sınırı. `steps` sıranın ilk kaç kartı 1 ile 5. basamaktır.
static func _lead_picks(order: Array, steps: int, placed: Array, skip: Array, people: Array, room: float) -> Array:
	var tried: Dictionary = {}
	for c in skip:
		tried[c.id] = true
	var picks: Array = []
	var skipped: int = 0
	for i in order.size():
		var c: Dictionary = order[i]
		if tried.has(c.id):
			continue
		tried[c.id] = true
		if not SprintSystem.fix_share_takes(placed, c, people):
			continue
		var take: Dictionary = SprintSystem.intake(placed, c, people) if SprintSystem.remaining(c) <= room else {"takes": false}
		var fits: bool = take.takes
		var carries: bool = false
		if fits and i >= steps:
			fits = picks.all(func(pick: Dictionary) -> bool: return take.cards[pick.id].finishes)
			carries = not take.cards[c.id].finishes
		if not fits:
			skipped += 1
			if skipped > int(cfg("lead.skip")):
				break
			continue
		picks.append(c)
		skipped = 0
		placed = placed + [c]
		room -= SprintSystem.remaining(c)
		if carries:
			break
	return picks


## Önerinin 1 ile 5. basamakları sırasıyla (bir kart birden çok basamakta olabilir); `ranked` etki ÷ iş sırasındaki açık
## adaylardır. Hedef yokken 5. basamak liderin alanına bakar.
static func _lead_steps(ranked: Array, goal: String, capacity: float) -> Array:
	var due: int = SprintSystem.sprint_number() + 1
	var out: Array = _promised(ranked)
	out.append_array(ranked.filter(func(c: Dictionary) -> bool: return c.line == PAID_PLAN))
	out.append_array(_requested(ranked).filter(func(c: Dictionary) -> bool:
		return int(_request_of(c).due_sprint) <= due).slice(0, 1))
	out.append_array(ranked.filter(func(c: Dictionary) -> bool:
		return SprintSystem.total(c) - SprintSystem.remaining(c) > SprintSystem.EPS))
	out.append_array(ranked.filter(is_priority))
	if goal == GOAL_BUGS:
		out.append_array(ranked.filter(func(c: Dictionary) -> bool: return c.kind == "fix"))
	else:
		var area: String = goal if goal != "" else _lead_area(ranked, capacity)
		out.append_array(ranked.filter(func(c: Dictionary) -> bool: return c.area == area).slice(0, 1))
	return out


## Sürüm notundaki lider cümlesi: devreden kartı anar, yoksa liderin sıradaki alanını; seçilecek kart
## kalmadıysa boştur.
static func release_lead_sentence(release: Dictionary) -> String:
	var carried: Array = release.get("carried", [])
	if not carried.is_empty():
		return _t("PRODUCT_LEAD_CARRIED").format({"card": card_name(card_by_id(carried[0].id))})
	var pool: Array = open_cards([])
	return "" if pool.is_empty() else _t("PRODUCT_LEAD_WEAKEST").format(
		{"area": area_short(_lead_area(pool, SprintSystem.capacity()))})


## Çekirdek'te K1'e varması gereken kimlik yeteneği sayısı; canlı üründe 0.
static func mvp_cards_left() -> int:
	if ProductState.is_live():
		return 0
	var shipped: int = _identity_lines().filter(func(l: String) -> bool: return tier(l) >= 1).size()
	return maxi(0, int(cfg("mvp_lines")) - shipped)


## Çekirdek'in açık K1 adayları efor, eşitse id sırasıyla; MVP tahmini ve sprint probe'u sprinti bu sırayla
## doldurur.
static func mvp_candidates() -> Array:
	var open: Array = candidates(_identity_area()).filter(func(c: Dictionary) -> bool:
		return c.state == "candidate" and int(c.target_tier) == 1)
	open.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var size_a: int = roundi(SprintSystem.total(a))
		var size_b: int = roundi(SprintSystem.total(b))
		return size_a < size_b if size_a != size_b else a.id < b.id)
	return open


# --- Çeyrek ve PM ----------------------------------------------------------------------

## Çeyreği planlayan PM: ilk aktif Ürün Yöneticisi, yoksa null (ÇEYREK kapalı).
static func quarter_pm() -> Character:
	for c in CharacterRegistry.get_active_employees():
		if c.role == HRConstants.ROLE_PRODUCT_MANAGER:
			return c
	return null


## Çeyreğin hedefi: oyuncunun seçtiği alan ya da `GOAL_BUGS`; seçmediyse boş. PM'siz de seçilir.
static func quarter_goal() -> String:
	return _p().quarter.goal_area


## PM'in planının baktığı hedef: çeyrek hedefi, yoksa en zayıf alan.
static func pm_goal() -> String:
	var goal: String = quarter_goal()
	return goal if goal != "" else _weakest(area_ids(), open_cards([]))


## PM'in planı: sonraki sprintten başlayıp ufuk kadar sprint, bugünkü ekibin kapasitesiyle.
## Onaylanan plan saklanır ve hâlâ yapılabilecek kartlarıyla döner. Onaysız plan saklanmaz, her
## okumada PM'in kuralıyla (`_suggest`) hedef alana ağırlık verilerek bugünkü durumdan kurulur: yapılan ya
## da sprinte alınan kart plandan kendiliğinden düşer. Sonraki sprintin planı o sütunda duran
## kartların üstüne kurulur.
## [{number, cards: [card_id], approved}]; PM yoksa ya da tür seçilmediyse [].
static func pm_plans() -> Array:
	if quarter_pm() == null or SprintSystem.sprint_number() == 0:
		return []
	var stored: Dictionary = {}
	for plan in _p().quarter.plans:
		stored[int(plan.number)] = plan
	var taken: Array = _approved_ahead()
	var capacity: float = SprintSystem.capacity()
	var goal: String = pm_goal()
	var first: int = int(_p().next.number)
	var out: Array = []
	for n in range(first, first + int(cfg("pm.horizon"))):
		if stored.has(n):
			out.append(stored[n].merged({"number": n, "cards": still_open(stored[n].cards)}, true))
			continue
		var ids: Array = _suggest(capacity, SprintSystem.points_left(_p().next.cards) if n == first else 0.0, taken, goal)
		taken.append_array(ids)
		out.append({"number": n, "cards": ids, "approved": false})
	return out


## Planın hâlâ yapılabilecek kartları: o arada yapılan, sprinte alınan ya da kilitlenen kart düşer.
static func still_open(ids: Array) -> Array:
	return ids.filter(func(id: String) -> bool:
		var c: Dictionary = card_by_id(id)
		return c.get("state", "") == "candidate" and gate_reason(c.step) == "")


static func _approved_ahead() -> Array:
	var ids: Array = []
	for plan in _p().get("quarter", {}).get("plans", []):
		ids.append_array(plan.cards)
	return ids


# --- Rakipler ------------------------------------------------------------------------

## Alt-türün en çok çıkış yapmış rakibi, eşitlikte tablo sırası; tür seçilmeden "".
static func rival_leader() -> String:
	var rivals: Array = rival_table().rivals
	if rivals.is_empty():
		return ""
	var launches: Array = rivals.map(func(_r: Variant) -> int: return 0)
	for hit in _p().get("rival_hits", []):
		launches[int(hit.rival)] += 1
	return rival_name(launches.find(launches.max()))


## Alt-türün rakip tablosu (rivals.json): rakipler, başlangıç kademeleri, çıkışlar.
static func rival_table() -> Dictionary:
	if _rivals.is_empty():
		load_data()
	return _rivals.get(ProductState.subtype(), {"rivals": [], "tiers": {}, "launches": []})


## `rival` rakibin tablodaki sırasıdır (0..2), RivalCatalog.NAMES indeksi değil.
static func rival_name(rival: int) -> String:
	return RivalCatalog.NAMES[ProductState.subtype()][int(rival_table().rivals[rival])]


## Sprintin rakip çıkışları; tablodaki kayda ad, konu ve çıkan kademenin adı eklenir.
static func rival_launch_in(sprint: int) -> Array:
	var table: Dictionary = rival_table()
	var out: Array = []
	for launch in table.launches.filter(func(l: Dictionary) -> bool: return int(l.sprint) == sprint):
		# Her çıkış rakibin o hattaki kademesini bir artırır; ad, varılan kademenin adıdır.
		var reached: int = int(table.tiers.get(launch.line, [0, 0, 0])[int(launch.rival)]) + table.launches.filter(
			func(l: Dictionary) -> bool: return l.rival == launch.rival and l.line == launch.line \
				and l.sprint <= launch.sprint).size()
		var step: String = PAID_PLAN if launch.line == PAID_PLAN else ProductLines.step_at(launch.line, reached).id
		out.append(launch.merged({"name": rival_name(int(launch.rival)), "topic": _t(launch.topic_key),
			"capability_key": step_name_key(step)}))
	return out


# --- İç -------------------------------------------------------------------------------

static func _t(key: String) -> String:
	return TranslationServer.translate(key)


static func _p() -> Dictionary:
	return GameState.product


static func _areas() -> Array:
	return areas_for(ProductState.subtype(), ProductState.market_type())


static func _identity_area() -> String:
	return (cfg("areas") as Array).filter(func(a: Dictionary) -> bool: return a.get("identity", false))[0].id


static func _identity_lines() -> Array[String]:
	return capabilities(_identity_area())


## `card_need`in oran satırı: düzeltme ve araştırmanın türünden, ücretli planın kendinden, öbürlerinin hattın iş profilinin
## kademe satırından. Kayıt göçü hattı henüz açılmamış bir gizli hat için profili Ar-Ge tanımından okur.
static func _need_row(kind: String, line: String, tier: int) -> Array:
	if kind in ["fix", "research"]:
		return cfg("need." + kind)
	if line == PAID_PLAN:
		return cfg("need.paid_plan")
	var profile: String = ProductLines.work_profile(line)
	if profile == "":
		profile = ResearchTree.hidden_line_profile(line.get_slice("@", 0))
	var by_tier: Variant = (cfg("need") as Dictionary).get(profile)
	return cfg("need.unprofiled") if by_tier == null or tier < 1 else by_tier[tier - 1]


## Hattın en üst kademesi: Ücretli plan tek kademelidir.
static func max_tier(line_id: String) -> int:
	return int(cfg("paid_plan.tiers")) if line_id == PAID_PLAN else ProductLines.TIER_MAX


static func step_name(step_id: String) -> String:
	return _t(step_name_key(step_id))


static func step_name_key(step_id: String) -> String:
	return PAID_PLAN_NAME_KEY if step_id == PAID_PLAN else ProductLines.step(step_id).name_key


## Alanın seviye geçişi parçası (etki satırı ve öngörü): sayılar yarıma yuvarlanmış, iki ucun kelimesi ham seviyeden
## ürün sayfasının referansına göre; çizim kelimeyi buradan okur, seviyeden türetmez.
static func _level_part(area_id: String, tiers: Dictionary) -> Dictionary:
	var from: float = ProductQuality.level(area_id)
	var to: float = ProductQuality.level(area_id, tiers)
	var expect: float = ProductQuality.expectation(area_id)
	return {"k": "level", "area": area_short(area_id), "from": display_level(from), "to": display_level(to),
		"from_word": ProductQuality.word_for(from, expect), "to_word": ProductQuality.word_for(to, expect)}


## Alanın kime yettiği. B2B'de hangi yıldızdaki şirketlere yettiği (Çekirdek dışı alana 1★ şirket bakmaz); B2C'de sayfanın
## referansına (kitlenin yıldızı, en az 2★) yetip yetmediği, yayından önce kitle olmadığı için hiçbir şey; Gelir kaliteye
## girmez, cümlesi sözcüğüne bağlı kendi dört satırıdır.
static func _standing(area_id: String) -> String:
	if area_id == "revenue":
		return _t("PRODUCT_AREA_REVENUE_" + ProductQuality.word(area_id).to_upper())
	if ProductState.market_type() == "b2c":
		if not ProductState.is_live():
			return ""
		var enough: bool = ProductQuality.level(area_id) >= ProductQuality.expectation(area_id)
		return _t("PRODUCT_AUDIENCE_ENOUGH" if enough else "PRODUCT_AUDIENCE_OUTGROWN")
	var star: int = ProductQuality.serves(area_id)
	if star == 0:
		return _t("PRODUCT_STAR_NONE")
	if star == 1 and area_id != "core":
		return _t("PRODUCT_STAR_SKIPPED")
	if star == ProductQuality.STAR_MAX:
		return _t("PRODUCT_STAR_TOP")
	return _t("PRODUCT_STAR_SERVES").format({"star": star, "next": star + 1})


## Güven & Ölçek sunucu aşımını da uyarı sayar.
static func _over_capacity(area_id: String) -> bool:
	return area_def(area_id).get("infra_alert", false) and InfraSystem.is_over_capacity()


static func _users_of(impact: Dictionary) -> int:
	return int(impact.get("users", impact.get("seats", 0)))


static func _clears_alert(card: Dictionary) -> bool:
	return area_alert(card.area) and not area_alert(card.area, [card.line])


static func _rival_tier(rival: int, line_id: String) -> int:
	var t: int = int(rival_table().tiers.get(line_id, [0, 0, 0])[rival])
	for h in _p().get("rival_hits", []):
		if int(h.rival) == rival and h.line == line_id:
			t += 1
	return mini(t, max_tier(line_id))


## Rakiplerden biri bu kademeye ya da üstüne varmış ve kart oyuncuyu ona yetiştiriyor.
static func _closes_rival_gap(card: Dictionary) -> bool:
	var best: int = 0
	for i in rival_table().rivals.size():
		best = maxi(best, _rival_tier(i, card.line))
	return best > tier(card.line) and int(card.target_tier) >= best


## Verilen hatlara son `rival_window_weeks` haftanın sprintlerinde düşen rakip çıkışları, çıkış kaydı başına. Aday
## beklentisinin artışı ve alanın cümlesi aynı pencereyi okur.
static func recent_hits(lines: Array) -> Array:
	var window: int = SprintSystem.sprints_in(int(cfg("rival_window_weeks")))
	return (_p().get("rival_hits", []) as Array).filter(func(h: Dictionary) -> bool:
		return String(h.line) in lines and SprintSystem.sprint_number() - int(h.sprint) < window)


## Alanın son rakip çıkışı, yoksa {}.
static func _recent_hit(area_id: String) -> Dictionary:
	var latest: Dictionary = {}
	for h in recent_hits(capabilities(area_id)):
		if int(h.sprint) >= int(latest.get("sprint", -1)):
			latest = h
	return latest


## Kartın karşıladığı açık talep: talep kartının kendisi ya da aynı kademeyi yapan özellik kartı.
static func _request_of(card: Dictionary) -> Dictionary:
	for r in open_requests():
		if str(r.id) == card.request_id or (card.kind == "feature" and r.step == card.step):
			return r
	return {}


## Açık talepler. Hesabı kapanan müşterinin talebi ertesi tikte düşer; o arada sayılmaz.
static func open_requests() -> Array:
	return (_p().get("requests", []) as Array).filter(func(r: Dictionary) -> bool:
		return r.status == "open" and CustomerRegistry.get_customer(String(r.customer_id)) != null)


## Kademeye verilmiş açık sözler, son tarihi yakın olan önde.
static func _promises_on(step: String) -> Array:
	var out: Array = PromiseRegistry.get_all().filter(func(p: Promise) -> bool:
		return p.status == "open" and p.feature_id == step)
	out.sort_custom(func(a: Promise, b: Promise) -> bool: return a.due_sprint < b.due_sprint)
	return out


## Etki satırının ve öngörünün söz parçaları. Hesap kapanınca açık sözü de düşer, ad hep okunur.
static func _promise_parts(step: String) -> Array:
	return _promises_on(step).map(func(p: Promise) -> Dictionary:
		return {"k": "promise", "customer": CustomerRegistry.get_customer(p.customer_id).display_name()})


## Talebin ya da talep kartının müşterisi; hesap kapanmışsa "".
static func customer_name(owner: Dictionary) -> String:
	var customer: Customer = CustomerRegistry.get_customer(String(owner.customer_id))
	return customer.display_name() if customer != null else ""


## Etki puanı (sprint.json `impact`): kademe, alan seviyesindeki ham artış, rakip açığı, talep,
## MVP öncesi boş kimlik yeteneği; düzeltmede kapanan hata ve kalkan "!", araştırmada sabit.
static func _impact(card: Dictionary) -> float:
	var w: Dictionary = cfg("impact")
	match card.kind:
		"fix":
			return w.bug * card.bugs + (w.alert if _clears_alert(card) else 0.0)
		"research":
			return w.research
	var v: float = w.step + w.level * (
		ProductQuality.level(card.area, {card.line: card.target_tier}) - ProductQuality.level(card.area))
	if _closes_rival_gap(card):
		v += w.rival_gap
	if not _request_of(card).is_empty():
		v += w.request
	if mvp_cards_left() > 0 and tier(card.line) == 0 and card.line in _identity_lines():
		v += w.mvp
	return v


static func _ratio(card: Dictionary) -> float:
	return _impact(card) / maxi(1, roundi(SprintSystem.total(card)))


## Seviyesi sıradaki yıldızın beklentisine en az ulaşmış alan (ProductQuality.next_ratio). Yuvarlanmamış seviye okunur,
## yarım dilimin gizlediği fark da sayılır; eşitlikte `pool`'daki en iyi kartının etki/efor oranı yüksek olan.
static func _weakest(area_ids: Array, pool: Array) -> String:
	var best: Dictionary = {}
	for c in pool:
		best[c.area] = maxf(float(best.get(c.area, 0.0)), _ratio(c))
	var star: int = ProductQuality.next_star()
	var weakest: String = ""
	var reached: float = INF
	var ratio: float = 0.0
	for area_id in area_ids:
		var g: float = ProductQuality.next_ratio(area_id, star)
		var r: float = best.get(area_id, 0.0)
		if g < reached or (g == reached and r > ratio):
			reached = g
			ratio = r
			weakest = area_id
	return weakest


## Liderin ve PM'in seçebileceği kartlar: aday, kilitsiz ve başka sprinte ayrılmamış.
static func open_cards(taken: Array) -> Array:
	var out: Array = []
	for area_id in area_ids():
		out.append_array(candidates(area_id).filter(func(c: Dictionary) -> bool:
			return c.state == "candidate" and gate_reason(c.step) == "" and c.id not in taken))
	return out


## Liderin alanı: kartı olan alanların en zayıfı. Araştırmanın etkisi yoktur: küçük ekipte (sprint en
## çok `lead.small_team_cards` K1 alır) tek kartı araştırma olan alan en zayıf sayılmaz, yoksa ekibin
## haftaları alanı ilerletmeyen işe bağlanırdı. Yayında olmayan ürünün tek hedefi MVP'dir: açık kartı
## kaldıkça Çekirdek.
static func _lead_area(pool: Array, capacity: float) -> String:
	var areas: Array = area_ids().filter(func(a: String) -> bool:
		return pool.any(func(c: Dictionary) -> bool: return c.area == a))
	if floori(capacity / float(cfg("effort.k1"))) <= int(cfg("lead.small_team_cards")):
		var built: Array = areas.filter(func(a: String) -> bool:
			return pool.any(func(c: Dictionary) -> bool: return c.area == a and c.kind != "research"))
		if not built.is_empty():
			areas = built
	if mvp_cards_left() > 0 and _identity_area() in areas:
		return _identity_area()
	return _weakest(areas, pool)


## PM'in planının kuralı. Zorunlu kartlar sırasıyla tavana (%125) kadar, oynatmadan yüklenir: verilmiş sözlerin kartları
## (son tarihi yakın önde), son tarihi en yakın talep, ücretli plan (B2C'de yayından sonra gelirin kapısıdır), alanın en iyi
## kartı ve açık öncelikli düzeltmeler; boş sprint, "+" gibi, tavanı aşan kartı da alır. Kalan yer etkisi olan, etki/efor
## oranı en yüksek kartlarla kapasiteye kadar dolar. Bu ya da sonraki sprintte duran ve kilitli kartlar önerilmez. `taken`
## başka sprintlere ayrılmış kartlardır (onaylı planlar, PM'in önceki sütunları); `goal` (çeyrek hedefi ya da PM'in en zayıf
## alanı) kartları sırada hedef ağırlığıyla öne çıkar.
static func _suggest(capacity: float, used: float, taken: Array = [], goal := "") -> Array:
	var pool: Array = open_cards(taken)
	if pool.is_empty() or capacity <= 0.0:
		return []
	var score: Dictionary = {}
	for c in pool:
		var aimed: bool = c.kind == "fix" if goal == GOAL_BUGS else c.area == goal
		score[c.id] = _ratio(c) * (float(cfg("pm.goal_weight")) if aimed else 1.0)
	pool.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return score[a.id] > score[b.id] if score[a.id] != score[b.id] else a.id < b.id)
	var weakest: String = _lead_area(pool, capacity)
	var must: Array = _promised(pool)
	must.append_array(_requested(pool).slice(0, 1))
	must.append_array(pool.filter(func(c: Dictionary) -> bool: return c.line == PAID_PLAN))
	must.append(pool.filter(func(c: Dictionary) -> bool: return c.area == weakest)[0])
	must.append_array(pool.filter(is_priority))
	var picks: Array = []
	var ceiling: float = capacity * float(cfg("cap_ceiling"))
	for c in must:
		var load: float = SprintSystem.remaining(c)
		if not picks.has(c.id) and (is_zero_approx(used) or used + load <= ceiling):
			picks.append(c.id)
			used += load
	for c in pool:
		var load: float = SprintSystem.remaining(c)
		if picks.has(c.id) or score[c.id] <= 0.0 or used + load > capacity:
			continue
		picks.append(c.id)
		used += load
	return picks


## Verilmiş sözü olan kartlar, söz tarihi yakın önde.
static func _promised(cards: Array) -> Array:
	var out: Array = cards.filter(func(c: Dictionary) -> bool: return not _promises_on(c.step).is_empty())
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return _promises_on(a.step)[0].due_sprint < _promises_on(b.step)[0].due_sprint)
	return out


## Talep kartları, son tarihi yakın önde.
static func _requested(cards: Array) -> Array:
	var out: Array = cards.filter(func(c: Dictionary) -> bool: return c.kind == "request")
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(_request_of(a).due_sprint) < int(_request_of(b).due_sprint))
	return out
