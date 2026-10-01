class_name SprintCatalog
extends RefCounted

# Ürün sprint ekranının kataloğu: alanlar ve yetenekleri, alan seviyesi ve durumu, aday kartlar,
# kartın etki satırı, sprint sonu öngörüsü, liderin önerisi ve rakip tablosu. Yalnız okur; ürün
# durumunu SprintSystem ve köprüsü SprintBridges yazar. Adaylar saklanmaz, her çağrıda durumdan
# kurulur.
# Çalışma değerleri sprint.json'da, rakip tablosu rivals.json'da. Metin TranslationServer'dan
# okunur, çünkü statik fonksiyonda tr() çalışmaz.

const DATA_PATH := "res://data/product/sprint.json"
const RIVALS_PATH := "res://data/product/rivals.json"
## Gelir alanının tek yeteneği: katalogda hattı yok, ücretli katmanın açık olmasından okunur.
const PAID_PLAN := "cap_paid_plan"
const SEP := " · "
const STAR := "★"
const MARK_UNMET := "✗"

static var _data: Dictionary = {}
static var _rivals: Dictionary = {}


static func load_data() -> void:
	_data = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	_rivals = JSON.parse_string(FileAccess.get_file_as_string(RIVALS_PATH))


## sprint.json'a nokta yolu: cfg("effort.k1"), cfg("request.deadline_sprints").
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
## ücretli plan. Gizli hat ancak Ar-Ge onu açınca listeye girer.
static func capabilities(area_id: String) -> Array[String]:
	var area: Dictionary = area_def(area_id)
	var out: Array[String] = []
	for line_id in ProductLines.line_ids(ProductState.subtype()):
		var identity: bool = area.get("identity", false) and not ProductLines.line(line_id).shared
		if identity or line_id.get_slice("@", 0) in area.lines:
			out.append(line_id)
	if PAID_PLAN in area.lines:
		out.append(PAID_PLAN)
	return out


static func cap_name(line_id: String) -> String:
	if line_id == PAID_PLAN:
		return _t("PRODUCT_CAP_PAID_PLAN")
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
	return _t(area_def(area_id).name_key + "_SHORT")


## sprint.json'daki alan kaydı (ad anahtarı, renk yuvası, hatlar).
static func area_def(area_id: String) -> Dictionary:
	return (cfg("areas") as Array).filter(func(a: Dictionary) -> bool: return a.id == area_id)[0]


# --- Seviye, beklenti, durum ------------------------------------------------------

## Yarıma yuvarlanmış alan seviyesi (0..3); `tiers` öngörünün varsaydığı kademeleri ezer.
static func area_level(area_id: String, tiers: Dictionary = {}) -> float:
	return snappedf(_raw_level(area_id, tiers), 0.5)


## Bootstrap 1 · Traction 2 · Series A 2, rakip çıkışı başına +0.5 (en çok +1). Beklenti alanın
## ulaşabileceği seviyeyi aşmaz: tek kademeli Ücretli plan Gelir'i 1'de tamamlar.
static func expectation(area_id: String) -> float:
	var caps: Array[String] = capabilities(area_id)
	var hits: int = (_p().get("rival_hits", []) as Array).filter(
		func(h: Dictionary) -> bool: return String(h.line) in caps).size()
	var bump: float = minf(float(cfg("rival_bump")) * hits, float(cfg("rival_bump_max")))
	var top: int = 0
	for line_id in caps:
		top = maxi(top, _max_tier(line_id))
	return minf(float(cfg("expectation")[str(GameState.phase)]) + bump, top)


static func area_word(area_id: String) -> String:
	return word_for(area_level(area_id), expectation(area_id))


## 0 → Yok · beklentinin altı → Zayıf · beklenti ile +0.5 arası → Yeterli · +1 ve üstü → Güçlü.
static func word_for(level: float, expect: float) -> String:
	if level <= 0.0:
		return "none"
	if level < expect:
		return "weak"
	return "enough" if level < expect + 1.0 else "strong"


## "!": yeteneklerinden birinde acil eşiği kadar ticket, ya da (Güven & Ölçek) sunucu aşımı;
## `closed` ticket'ları kapanmış sayılır.
static func area_alert(area_id: String, closed: Array = []) -> bool:
	if _over_capacity(area_id):
		return true
	var by_line: Dictionary = tickets_by_line(closed)
	for line_id in capabilities(area_id):
		if (by_line.get(line_id, []) as Array).size() >= int(cfg("urgent_tickets")):
			return true
	return false


## Kapalı satırın cümlesi: alan × durum şablonu, açık ticket ve rakip çıkışı eklenir.
static func area_sentence(area_id: String) -> String:
	var parts: PackedStringArray = [_t("PRODUCT_AREA_%s_%s" % [area_id.to_upper(), area_word(area_id).to_upper()])]
	var by_line: Dictionary = tickets_by_line()
	var n: int = 0
	for line_id in capabilities(area_id):
		n += (by_line.get(line_id, []) as Array).size()
	if n > 0:
		parts.append(_t(Fmt.count_key("PRODUCT_AREA_TICKETS", n)).format({"n": n}))
	if _over_capacity(area_id):
		parts.append(_t("PRODUCT_AREA_OVER_CAPACITY"))
	var hit: Dictionary = _recent_hit(area_id)
	if not hit.is_empty():
		parts.append(_t("PRODUCT_AREA_RIVAL").format({"rival": rival_name(int(hit.rival))}))
	return SEP.join(parts)


## SESLER: açık ticket başlıkları, araştırma cümlesi ve rakip çıkışı; yeniler önde. Yeni = son
## sprintte gelmiş ve katlama o günden beri açılmamış.
static func voices(area_id: String) -> Array:
	var seen: int = int(_p().get("voices_seen", {}).get(area_id, -1))
	var since_sprint: bool = seen < int(_p().get("sprint", {}).get("start_day", 0))
	var fresh: Array = []
	var old: Array = []
	var caps: Array[String] = capabilities(area_id)
	for t in _p().get("tickets", []):
		if String(t.line) in caps:
			var is_new: bool = int(t.day) > seen and GameState.day - int(t.day) < int(cfg("sprint_weeks"))
			(fresh if is_new else old).append({"text": ticket_title(t), "new": is_new})
	var research: Dictionary = _p().get("research_done", {})
	if research.has(area_id):
		var is_new: bool = since_sprint and SprintSystem.sprint_number() - int(research[area_id]) <= 1
		(fresh if is_new else old).append({"text": _t("PRODUCT_RESEARCH_VOICE_" + area_id.to_upper()), "new": is_new})
	var launch: Dictionary = _launch_of(_recent_hit(area_id))
	if not launch.is_empty():
		var is_new: bool = since_sprint and SprintSystem.sprint_number() - int(launch.sprint) <= 1
		(fresh if is_new else old).append({"text": _t("PRODUCT_RIVAL_VOICE").format(
			{"rival": launch.name, "capability": launch.capability}), "new": is_new})
	return fresh + old


static func ticket_title(ticket: Dictionary) -> String:
	var variant: int = absi(hash(str(int(ticket.id)))) % int(cfg("content.ticket_titles"))
	return _t("PRODUCT_TICKET_%d" % variant).format({"capability": cap_name(ticket.line)})


# --- Kartlar ---------------------------------------------------------------------

## K1 3 · K2 5 · K3 8; Ar-Ge "design_system" Deneyim kademelerinin eforunu %20 indirir.
static func step_effort(step_id: String) -> int:
	if step_id == PAID_PLAN:
		return int(cfg("paid_plan.effort"))
	var step: Dictionary = ProductLines.step(step_id)
	var effort: int = int(cfg("effort.k%d" % int(step.tier)))
	if step.axis == "experience" and ResearchSeam.completed("design_system"):
		return maxi(1, roundi(effort * ProductLines.RND_EXPERIENCE_EFFORT_MULT))
	return effort


## Faz payları [Tasarım, Geliştirme, Test]; araştırmada ilk faz Ürün'ündür.
static func card_shares(kind: String) -> Array:
	return (cfg("shares." + kind) as Array).duplicate()


## Payı olan fazların rolleri, en çok üç.
static func card_roles(kind: String) -> Array:
	var roles: Array = cfg("roles." + kind)
	var shares: Array = card_shares(kind)
	return range(shares.size()).filter(func(i: int) -> bool: return shares[i] > 0.0).map(
		func(i: int) -> String: return roles[i])


## Alanın aday kartları (PRD §3.2): yetenek başına sonraki kademe (kapısı kapalıysa da görünür),
## açık talep o kademeyi talep kartına çevirir, ticket'lı yetenek başına düzeltme, alan başına
## araştırma. Sprintte ya da sonrakinde duran kart saklanan hâliyle döner. Sıra: acil önde,
## kilitsiz önde, sonra etki/efor azalan.
static func candidates(area_id: String) -> Array:
	var stored: Dictionary = _p().get("cards", {})
	var requests: Dictionary = {}
	for r in _p().get("requests", []):
		if r.status == "open":
			requests[String(r.step)] = r
	var out: Array = []
	var caps: Array[String] = capabilities(area_id)
	for line_id in caps:
		if line_id == PAID_PLAN:
			if tier(PAID_PLAN) < _max_tier(PAID_PLAN):
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
	var by_line: Dictionary = tickets_by_line()
	for line_id in caps:
		if by_line.has(line_id):
			var ids: Array = by_line[line_id]
			var urgent: bool = ids.size() >= int(cfg("urgent_tickets"))
			var effort: int = int(cfg("effort.fix_urgent" if urgent else "effort.fix"))
			var card: Dictionary = new_card("fix:" + line_id, "fix", area_id, effort, line_id)
			card.tickets = ids
			out.append(card)
	var researched: Variant = _p().get("research_done", {}).get(area_id)
	if researched == null or SprintSystem.sprint_number() - int(researched) > 1:
		out.append(new_card("res:" + area_id, "research", area_id, int(cfg("effort.research"))))
	var keyed: Array = out.map(func(c: Dictionary) -> Array:
		var card: Dictionary = (stored.get(c.id, c) as Dictionary).duplicate(true)
		return [[float(is_urgent(card)), float(gate_reason(card.step) == ""), _ratio(card)], card])
	keyed.sort_custom(func(a: Array, b: Array) -> bool:
		for i in a[0].size():
			if a[0][i] != b[0][i]:
				return a[0][i] > b[0][i]
		return a[1].id < b[1].id)
	return keyed.map(func(k: Array) -> Dictionary: return k[1])


static func is_urgent(card: Dictionary) -> bool:
	return card.kind == "fix" and card.tickets.size() >= int(cfg("urgent_tickets"))


static func new_card(id: String, kind: String, area_id: String, effort: int, line := "", step := "",
		target_tier := 0) -> Dictionary:
	return {"id": id, "kind": kind, "line": line, "step": step, "target_tier": target_tier, "area": area_id,
		"effort": effort, "roles": card_roles(kind), "shares": card_shares(kind), "progress": [0.0, 0.0, 0.0],
		"state": "candidate", "assignees": [], "tickets": [], "customer_id": "", "request_id": "",
		"decision": false, "effort_mod": 0, "faulty": false}


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
			return _t("PRODUCT_REQUEST_CARD").format({"step": step_name(card.step), "customer": customer_name(card)})
	return step_name(card.step)


## Kilitli kademenin gerekçesi, yalnız karşılanmayan parçalarla; kilitsizse "". Ücretli plan
## yayındaki ürünün katmanıdır, MVP'den önce açılmaz.
static func gate_reason(step_id: String) -> String:
	if step_id == PAID_PLAN:
		return "" if ProductState.is_live() else _t("PROD_LOCK_PREFIX") + " " + _t("PRODUCT_LOCK_LIVE").format(
			{"mark": MARK_UNMET})
	if ProductLines.step(step_id).is_empty():
		return ""
	var parts: PackedStringArray = []
	for part in LineGates.unmet_parts(step_id):
		if part.kind == LineGates.KIND_RESEARCH:
			parts.append(_t("PROD_LOCK_RESEARCH").format({"node": ResearchSeam.node_name(part.node), "mark": MARK_UNMET}))
		elif part.kind == LineGates.KIND_TOTAL:
			var have: float = part.have
			parts.append(_t("PROD_LOCK_TOTAL").format({"area": HRConstants.area_label(part.area),
				"stars": STAR + str(part.stars),
				"have": STAR + (str(roundi(have)) if is_equal_approx(have, roundf(have)) else Fmt.number(have, 1)),
				"mark": MARK_UNMET}))
		else:
			parts.append(_t("PROD_LOCK_PERSON").format({"area": HRConstants.area_label(part.area),
				"stars": STAR.repeat(part.stars), "mark": MARK_UNMET}))
	return "" if parts.is_empty() else _t("PROD_LOCK_PREFIX") + " " + SEP.join(parts)


## Kartın etki satırı (ProductModel `part`): alan dilim geçişi, değişmiyorsa "Alan X kalır" ve
## yeteneğin geçişi; rakip açığı ve talep; düzeltmede ticket ve "!" kalkışı.
static func card_effect(card: Dictionary) -> Array:
	var area: String = card.area
	match card.kind:
		"fix":
			var parts: Array = [{"k": "tickets", "n": card.tickets.size()}]
			if _clears_alert(card):
				parts.append({"k": "alert_clear", "area": area_short(area)})
			return parts
		"research":
			return [{"k": "research", "area": area_short(area)}]
	var from: float = area_level(area)
	var to: float = area_level(area, {card.line: card.target_tier})
	var expect: float = expectation(area)
	var out: Array = []
	if to != from:
		out.append(_shift({"k": "level", "area": area_short(area), "from": from, "to": to}, expect))
	else:
		var cap_max: float = _max_tier(card.line)
		out.append({"k": "holds", "area": area_short(area), "word": word_for(to, expect)})
		out.append(_shift({"k": "cap", "name": cap_name(card.line),
			"from": minf(tier(card.line) + polish(card.line), cap_max),
			"to": minf(card.target_tier + polish(card.line), cap_max)}, expect))
	if _closes_rival_gap(card):
		out.append({"k": "rival_gap"})
	var request: Dictionary = _request_of(card)
	if not request.is_empty():
		out.append({"k": "request", "customer": customer_name(request), "value": int(request.value)})
	return out


## SPRINT SONUNDA: kartların hepsi bitmiş varsayılır; yalnız değişen alanlar, zamanında talepler,
## kalkan "!" ve kapanan ticket sayısı.
static func forecast(card_ids: Array) -> Array:
	var cards: Array = card_ids.map(card_by_id)
	var tiers: Dictionary = {}
	var closed: Array = []
	for c in cards:
		if c.kind == "fix":
			closed.append_array(c.tickets.map(func(i: Variant) -> int: return int(i)))
		elif c.kind != "research":
			tiers[c.line] = maxi(int(tiers.get(c.line, tier(c.line))), int(c.target_tier))
	var out: Array = []
	for area_id in area_ids():
		var from: float = area_level(area_id)
		var to: float = area_level(area_id, tiers)
		if to != from:
			out.append(_shift({"k": "level", "area": area_short(area_id), "from": from, "to": to}, expectation(area_id)))
	for c in cards:
		var request: Dictionary = _request_of(c)
		if not request.is_empty() and SprintSystem.sprint_number() <= int(request.due_sprint):
			out.append({"k": "request_on_time", "customer": customer_name(request)})
	for area_id in area_ids():
		if area_alert(area_id) and not area_alert(area_id, closed):
			out.append({"k": "alert_clear", "area": area_short(area_id)})
	if not closed.is_empty():
		out.append({"k": "tickets", "n": closed.size()})
	return out


# --- Lider ---------------------------------------------------------------------------

## Onaylı PM planlarının kartları o sprintlere ayrılmıştır; lider onlara dokunmaz.
static func lead_suggestion() -> Array:
	return _suggest(SprintSystem.capacity(), SprintSystem.used(), _approved_ahead())


## "{kart1} ve {kart2} bu sprintte bitmeli."; öneride talep varsa son tarihi en yakın talebi anar.
static func lead_sentence(ids: Array) -> String:
	var cards: Array = ids.map(card_by_id)
	var requests: Array = cards.map(_request_of).filter(func(r: Dictionary) -> bool: return not r.is_empty())
	if not requests.is_empty():
		requests.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.due_sprint) < int(b.due_sprint))
		return _t("PRODUCT_LEAD_REQUEST").format({"request": step_name(requests[0].step),
			"customer": customer_name(requests[0])})
	match cards.size():
		0:
			return ""
		1:
			return _t("PRODUCT_LEAD_ONE").format({"card": card_name(cards[0])})
	return _t("PRODUCT_LEAD_TWO").format({"first": card_name(cards[0]), "second": card_name(cards[1])})


## Sürüm notundaki lider cümlesi: devreden kartı anar, yoksa en zayıf alanı.
static func release_lead_sentence(release: Dictionary) -> String:
	var carried: Array = release.get("carried", [])
	if not carried.is_empty():
		return _t("PRODUCT_LEAD_CARRIED").format({"card": card_name(card_by_id(carried[0].id))})
	return _t("PRODUCT_LEAD_WEAKEST").format({"area": area_short(_weakest(area_ids()))})


## Çekirdek'te K1'e varması gereken kimlik yeteneği sayısı; canlı üründe 0.
static func mvp_cards_left() -> int:
	if ProductState.is_live():
		return 0
	var shipped: int = _identity_lines().filter(func(l: String) -> bool: return tier(l) >= 1).size()
	return maxi(0, int(cfg("mvp_lines")) - shipped)


# --- Çeyrek ve PM ----------------------------------------------------------------------

## Çeyreği planlayan PM: ilk aktif Ürün Yöneticisi, yoksa null (ÇEYREK kapalı).
static func quarter_pm() -> Character:
	for c in CharacterRegistry.get_active_employees():
		if c.role == HRConstants.ROLE_PRODUCT_MANAGER:
			return c
	return null


## Çeyreğin hedef alanı: oyuncunun seçtiği, seçmediyse PM'in önerisi olan en zayıf alan.
static func quarter_goal() -> String:
	var goal: String = _p().quarter.goal_area
	return goal if goal != "" else _weakest(area_ids())


## PM'in planı: sonraki sprintten başlayıp ufuk kadar sprint, bugünkü ekibin kapasitesiyle.
## Onaylanan plan saklanır ve hâlâ yapılabilecek kartlarıyla döner. Onaysız plan saklanmaz, her
## okumada liderin kuralıyla hedef alana ağırlık verilerek bugünkü durumdan kurulur: yapılan ya
## da sprinte alınan kart plandan kendiliğinden düşer. Sonraki sprintin planı o sütunda duran
## kartların üstüne kurulur. Ürün alanı zayıf PM'in planı daha az kart taşır.
## [{number, cards: [card_id], approved}]; PM yoksa ya da tür seçilmediyse [].
static func pm_plans() -> Array:
	var pm: Character = quarter_pm()
	if pm == null or SprintSystem.sprint_number() == 0:
		return []
	var stored: Dictionary = {}
	for plan in _p().quarter.plans:
		stored[int(plan.number)] = plan
	var taken: Array = _approved_ahead()
	var keep: float = float(cfg("pm.low_skill_cards")) \
		if HRSystem.skill(pm, HRConstants.role_key_area(pm.role)) <= int(cfg("skill.low_max")) else 1.0
	var capacity: int = SprintSystem.capacity()
	var goal: String = quarter_goal()
	var first: int = int(_p().next.number)
	var out: Array = []
	for n in range(first, first + int(cfg("pm.horizon"))):
		if stored.has(n):
			out.append(stored[n].merged({"number": n, "cards": still_open(stored[n].cards)}, true))
			continue
		var ids: Array = _suggest(capacity, SprintSystem.points_left(_p().next.cards) if n == first else 0, taken, goal)
		ids = ids.slice(0, roundi(ids.size() * keep))
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

## Kademesi en az 1 olan rakipler (tablodaki başlangıç + kayda geçen çıkışlar).
static func rival_names(line_id: String) -> Array:
	var out: Array = []
	for i in rival_table().rivals.size():
		if _rival_tier(i, line_id) >= 1:
			out.append(rival_name(i))
	return out


## Alt-türün rakip tablosu (rivals.json): rakipler, başlangıç kademeleri, çıkışlar.
static func rival_table() -> Dictionary:
	if _rivals.is_empty():
		load_data()
	return _rivals.get(ProductState.subtype(), {"rivals": [], "tiers": {}, "launches": []})


## `rival` rakibin tablodaki sırasıdır (0..2), RivalCatalog.NAMES indeksi değil.
static func rival_name(rival: int) -> String:
	return RivalCatalog.NAMES[ProductState.subtype()][int(rival_table().rivals[rival])]


## "Rakip: …" çipi: alana son pencerede çıkış yapan rakibin konusu, yoksa "".
static func rival_topic(area_id: String) -> String:
	return String(_launch_of(_recent_hit(area_id)).get("topic", ""))


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
			"capability": step_name(step)}))
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


static func _max_tier(line_id: String) -> int:
	return int(cfg("paid_plan.tiers")) if line_id == PAID_PLAN else ProductLines.TIER_MAX


static func step_name(step_id: String) -> String:
	return cap_name(PAID_PLAN) if step_id == PAID_PLAN else _t(ProductLines.step(step_id).name_key)


## Etki satırının seviye geçişi parçası (level, cap) iki ucun kelimesini taşır; çizim kelimeyi
## buradan okur, seviyeden türetmez.
static func _shift(part: Dictionary, expect: float) -> Dictionary:
	return part.merged({"from_word": word_for(part.from, expect), "to_word": word_for(part.to, expect)})


## Yuvarlanmamış alan seviyesi: yeteneklerin kademe + cila ortalaması; `tiers` öngörünün
## varsaydığı kademeleri ezer.
static func _raw_level(area_id: String, tiers: Dictionary = {}) -> float:
	var caps: Array[String] = capabilities(area_id)
	if caps.is_empty():
		return 0.0
	var sum: float = 0.0
	for line_id in caps:
		sum += minf(float(tiers.get(line_id, tier(line_id))) + polish(line_id), _max_tier(line_id))
	return sum / caps.size()


## Güven & Ölçek sunucu aşımını da uyarı sayar.
static func _over_capacity(area_id: String) -> bool:
	return area_def(area_id).get("infra_alert", false) and InfraSystem.is_over_capacity()


## Açık ticket kimlikleri hatta göre; `closed` kapanmış sayılır.
static func tickets_by_line(closed: Array = []) -> Dictionary:
	var out: Dictionary = {}
	for t in _p().get("tickets", []):
		if not closed.has(int(t.id)):
			(out.get_or_add(String(t.line), []) as Array).append(int(t.id))
	return out


static func _clears_alert(card: Dictionary) -> bool:
	return area_alert(card.area) and not area_alert(card.area, card.tickets.map(func(i: Variant) -> int: return int(i)))


static func _rival_tier(rival: int, line_id: String) -> int:
	var t: int = int(rival_table().tiers.get(line_id, [0, 0, 0])[rival])
	for h in _p().get("rival_hits", []):
		if int(h.rival) == rival and h.line == line_id:
			t += 1
	return mini(t, _max_tier(line_id))


## Rakiplerden biri bu kademeye ya da üstüne varmış ve kart oyuncuyu ona yetiştiriyor.
static func _closes_rival_gap(card: Dictionary) -> bool:
	var best: int = 0
	for i in rival_table().rivals.size():
		best = maxi(best, _rival_tier(i, card.line))
	return best > tier(card.line) and int(card.target_tier) >= best


## Alanın son rakip çıkışı (son `rival_window_sprints` sprintte), yoksa {}.
static func _recent_hit(area_id: String) -> Dictionary:
	var caps: Array[String] = capabilities(area_id)
	var latest: Dictionary = {}
	for h in _p().get("rival_hits", []):
		if String(h.line) in caps and SprintSystem.sprint_number() - int(h.sprint) < int(cfg("rival_window_sprints")) \
				and int(h.sprint) >= int(latest.get("sprint", -1)):
			latest = h
	return latest


static func _launch_of(hit: Dictionary) -> Dictionary:
	if hit.is_empty():
		return {}
	for launch in rival_launch_in(int(hit.sprint)):
		if int(launch.rival) == int(hit.rival) and launch.line == hit.line:
			return launch
	return {}


## Kartın karşıladığı açık talep: talep kartının kendisi ya da aynı kademeyi yapan özellik kartı.
static func _request_of(card: Dictionary) -> Dictionary:
	for r in _p().get("requests", []):
		if r.status == "open" and (str(r.id) == card.request_id or (card.kind == "feature" and r.step == card.step)):
			return r
	return {}


## Talebin ya da talep kartının müşterisi; hesap kapanmışsa "".
static func customer_name(owner: Dictionary) -> String:
	var customer: Customer = CustomerRegistry.get_customer(String(owner.customer_id))
	return customer.display_name() if customer != null else ""


## Etki puanı (sprint.json `impact`): kademe, alan seviyesindeki ham artış, rakip açığı, talep,
## MVP öncesi boş kimlik yeteneği; düzeltmede ticket ve kalkan "!", araştırmada sabit.
static func _impact(card: Dictionary) -> float:
	var w: Dictionary = cfg("impact")
	match card.kind:
		"fix":
			return w.ticket * card.tickets.size() + (w.alert if _clears_alert(card) else 0.0)
		"research":
			return w.research
	var v: float = w.step + w.level * (_raw_level(card.area, {card.line: card.target_tier}) - _raw_level(card.area))
	if _closes_rival_gap(card):
		v += w.rival_gap
	if not _request_of(card).is_empty():
		v += w.request
	if mvp_cards_left() > 0 and tier(card.line) == 0 and card.line in _identity_lines():
		v += w.mvp
	return v


static func _ratio(card: Dictionary) -> float:
	return _impact(card) / maxi(1, int(card.effort))


## Seviyesi beklentisinin en çok altında kalan alan; eşitlikte sırada önce gelen.
static func _weakest(area_ids: Array) -> String:
	var weakest: String = ""
	var gap: float = INF
	for area_id in area_ids:
		var g: float = area_level(area_id) - expectation(area_id)
		if g < gap:
			gap = g
			weakest = area_id
	return weakest


## Liderin kuralı: son tarihi en yakın talep, en zayıf alanın (MVP öncesi Çekirdek'in) en iyi kartı
## ve açık acil düzeltmeler tavana (%125) kadar; boş sprint, "+" gibi, tavanı aşan kartı da alır.
## Kalan yer etkisi olan, etki/efor oranı en yüksek kartlarla kapasiteye kadar dolar. Araştırmanın
## etkisi yoktur: yalnız en zayıf alanın tek kartıysa önerilir, yoksa küçük ekibin haftalarını
## alanı ilerletmeyen işe bağlar. Bu ya da sonraki sprintte duran ve kilitli kartlar önerilmez.
## `taken` başka sprintlere ayrılmış kartlardır (onaylı planlar, PM'in önceki sütunları). PM aynı
## kuralla planlar; `goal` alanının kartları sırada hedef ağırlığıyla öne çıkar.
static func _suggest(capacity: int, used: int, taken: Array = [], goal := "") -> Array:
	var pool: Array = []
	var areas: Array = []
	for area in _areas():
		var cards: Array = candidates(area.id).filter(func(c: Dictionary) -> bool:
			return c.state == "candidate" and gate_reason(c.step) == "" and c.id not in taken)
		if not cards.is_empty():
			areas.append(area.id)
			pool.append_array(cards)
	if pool.is_empty():
		return []
	var score: Dictionary = {}
	for c in pool:
		score[c.id] = _ratio(c) * (float(cfg("pm.goal_weight")) if c.area == goal else 1.0)
	pool.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return score[a.id] > score[b.id] if score[a.id] != score[b.id] else a.id < b.id)
	var weakest: String = _weakest(areas)
	# Yayında olmayan ürünün tek hedefi MVP'dir: zorunlu kart, açık kartı kaldıkça Çekirdek'ten.
	if mvp_cards_left() > 0 and _identity_area() in areas:
		weakest = _identity_area()
	var must: Array = pool.filter(func(c: Dictionary) -> bool: return c.kind == "request")
	must.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(_request_of(a).due_sprint) < int(_request_of(b).due_sprint))
	must = must.slice(0, 1)
	must.append(pool.filter(func(c: Dictionary) -> bool: return c.area == weakest)[0])
	must.append_array(pool.filter(is_urgent))
	var picks: Array = []
	var ceiling: float = capacity * float(cfg("cap_ceiling"))
	for c in must:
		if not picks.has(c.id) and ((used == 0 and capacity > 0) or used + int(c.effort) <= ceiling):
			picks.append(c.id)
			used += int(c.effort)
	for c in pool:
		if not picks.has(c.id) and score[c.id] > 0.0 and used + int(c.effort) <= capacity:
			picks.append(c.id)
			used += int(c.effort)
	return picks
