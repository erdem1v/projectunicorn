class_name SprintSystem
extends RefCounted

# Ürünün sprint motoru: tür seçimi, planlama eylemleri, haftalık atama ve ilerleme, sprint
# kapanışı ve sürüm. GameState.product'ı burası ve köprüsü SprintBridges yazar (köprü yalnız
# tickets, ticket_seq, requests ve rival_hits'i); okuma katalogdadır (SprintCatalog). Sinyaller
# EventBus'ın Sprint bölümündedir.
#
# Bir gün bir haftadır. Başlatılan sprintin ilk haftası başlatma günüdür; her günlük tik biten
# haftanın işini kartlara döker, ikinci haftanın sonunda sprint kapanır ve sürüm yazılır.
# Atama hafta başında yapılır ve hafta boyunca kartta görünür.

## Kartın progress ve shares dizilerinin sırası: Tasarım (araştırmada Ürün), Geliştirme, Test.
const TEST_PHASE := 2
const PHASE_DONE := 3
const EPS := 0.001
## Karar kartı masada mı diye bakarken taranan kâğıt sayısı; masa hiç bu kadar dolmaz.
const DESK_SCAN := 64


static func daily_tick() -> void:
	if not is_typed():
		return
	SprintBridges.sync_tickets()
	_refresh_fix_cards()
	SprintBridges.tick_requests()
	_settle_decision()
	var p: Dictionary = _p()
	_fill_actual()
	match mode():
		"active":
			_end_week()
		"plan":
			if GameState.day > int(p.sprint.start_day):
				_auto_start()
		"release":
			if GameState.day > int(p.release.day):
				_auto_start()
	_changed()


# --- Tür -------------------------------------------------------------------------

## Ürün sekmesinin tür seçimi: alt-tür, pazar, haber havuzu ve ad yazılır, Sprint 1 planlamada açılır.
static func choose_type(subtype: String, name: String) -> void:
	if is_typed():
		return
	GameState.set_flag("mvp_sub_product_type_id", subtype)
	GameState.set_flag("mvp_market_type", ProductCatalog.get_market_type(subtype))
	var pool: String = ProductCatalog.get_pool_of(subtype)
	if pool != "":
		GameState.set_subgenre(pool)
	GameState.set_flag("mvp_product_name", name)
	GameState.product.merge(new_state(GameState.day), true)
	EventBus.sprint_planned.emit(1)
	_changed()


## Tür seçilmiş ürünün ilk durumu: Sprint 1 `day` gününde planlamada açılır. Saf; kayıt göçü de
## bunu kurar.
static func new_state(day: int) -> Dictionary:
	return {
		"sprint": {"number": 1, "start_day": day, "status": "planning", "cards": [], "capacity": 0,
			"beta": false, "lead_applied": false},
		"next": {"number": 2, "cards": []},
		"mode": "plan", "cards": {}, "release": {}, "releases": [], "polish": {},
		"tickets": [], "ticket_seq": 0, "requests": [], "rival_hits": [],
		"voices_seen": {}, "research_done": {}, "decision": {}, "auto_started": -1,
		"quarter": {"goal_area": "", "start_sprint": 1, "plans": []},
		"worked": {"day": -1, "ids": []},
	}


# --- Eylemler (arayüz ve bot) -------------------------------------------------------

## "+" ve "↑": kapasite var, yük tavanı aşmamış ve kart yerinden oynayabiliyorsa bu sprinte girer.
static func add(card_id: String) -> void:
	var card: Dictionary = SprintCatalog.card_by_id(card_id)
	if _movable(card) and can_add():
		_place(card, true)
		_changed()


## "→": kart sonraki sprinte.
static func send_next(card_id: String) -> void:
	var card: Dictionary = SprintCatalog.card_by_id(card_id)
	if _movable(card):
		_place(card, false)
		_changed()


## Kart adaylara döner; ilerlemesi ya da ödenmiş lisansı varsa saklanır ve yeniden alındığında
## kaldığı yerden, bedeli yeniden kesilmeden sürer.
static func remove(card_id: String) -> void:
	var p: Dictionary = _p()
	var card: Dictionary = p.cards.get(card_id, {})
	if card.is_empty() or card.state in ["done", "beta"]:
		return
	p.sprint.cards.erase(card_id)
	p.next.cards.erase(card_id)
	if _worked(card) > EPS or card.get("paid", false):
		card.state = "candidate"
		card.assignees = []
	else:
		p.cards.erase(card_id)
	_changed()


## Sprinti başlatır: kartlar kilitlenir, lisans bedeli bir kez alınır, ilk haftanın ataması yapılır.
static func start() -> bool:
	if not can_start():
		return false
	_settle_decision()
	var p: Dictionary = _p()
	var sprint: Dictionary = p.sprint
	sprint.status = "running"
	sprint.start_day = GameState.day
	sprint.capacity = capacity()
	var steps: Array = []
	for card in _sprint_cards():
		card.state = "running"
		card.base = _worked(card)
		if not card.get("paid", false):
			card.paid = true
			steps.append(card.step)
	var cost: int = ProductLines.sum_license_cost(steps)
	if cost > 0:
		FinanceSystem.apply_one_time_cost(cost, "build_commit")
	p.mode = "active"
	SprintBridges.tick_rivals(int(sprint.number))
	_assign(_sprint_cards(), team())
	EventBus.sprint_started.emit(int(sprint.number))
	_changed()
	return true


## Sürüm notundan sonraki sprintin planlamasına: sonraki sütun (devredenler önde) bu sprint olur,
## yeni sonraki sütuna onaylı PM planı geçer. Altı sprintte bir çeyrek döner, hedef PM'in
## önerisine (en zayıf alan) geri düşer. Kademesine başka bir kartla varılmış saklı kart düşer
## (geç kalan talebin kartı ile aynı kademenin özellik kartı ikisi de saklanabilir).
static func plan_next() -> void:
	if mode() != "release":
		return
	var p: Dictionary = _p()
	for c in p.cards.values():
		if c.kind in ["feature", "request"] and int(c.target_tier) <= SprintCatalog.tier(c.line):
			p.cards.erase(c.id)
			p.next.cards.erase(c.id)
	var number: int = int(p.next.number)
	p.sprint = {"number": number, "start_day": GameState.day, "status": "planning", "cards": p.next.cards,
		"capacity": 0, "beta": bool(p.sprint.beta), "lead_applied": false}
	p.next = {"number": number + 1, "cards": []}
	p.release = {}
	p.mode = "plan"
	var quarter: Dictionary = p.quarter
	if number >= int(quarter.start_sprint) + int(SprintCatalog.cfg("quarter_sprints")):
		quarter.start_sprint = number
		quarter.goal_area = ""
	quarter.plans = quarter.plans.filter(func(plan: Dictionary) -> bool: return int(plan.number) > number)
	for plan in quarter.plans:
		if int(plan.number) == number + 1:
			_to_next(SprintCatalog.still_open(plan.cards))
	EventBus.sprint_planned.emit(number)
	_changed()


static func set_beta(open: bool) -> void:
	if mode() != "plan":
		return
	_p().sprint.beta = open
	_changed()


## Liderin önerisi bu sprintin boş yerlerini doldurur.
static func apply_lead() -> void:
	if mode() != "plan":
		return
	for id in SprintCatalog.lead_suggestion():
		_place(SprintCatalog.card_by_id(id), true)
	_p().sprint.lead_applied = true
	_changed()


## "Karar ver": kartın bekleyen olay kâğıdını açar.
static func decide(card_id: String) -> void:
	var decision: Dictionary = _p().decision
	if decision.get("card_id", "") == card_id:
		_watch_decision()
		EventGate.request(String(decision.event_id))


# --- Karar kartının etkileri (olay motorunun sprint fiilleri) --------------------------

## Bekleyen kararın kartının eforu ± puan; kartın kimliği, karar yoksa "".
static func decision_effort(amount: int) -> String:
	var c: Dictionary = decision_card()
	if not c.is_empty():
		c.effort_mod = int(c.effort_mod) + effort_change(amount)
		_changed()
	return c.get("id", "")


## Eforun gerçekten değişeceği puan: kart en az 1 puan kalır. Olay çipi de bunu gösterir, yazılan
## ile görünen aynıdır; bekleyen karar yoksa istenen puan.
static func effort_change(amount: int) -> int:
	var c: Dictionary = decision_card()
	return amount if c.is_empty() else maxi(amount, 1 - roundi(total(c)))


## Bekleyen kararın kartına ± puan ilerleme: artı sıradaki fazlardan dolar, eksi son fazdan geri alır.
static func decision_progress(amount: int) -> String:
	var c: Dictionary = decision_card()
	if c.is_empty():
		return ""
	if amount >= 0:
		_work(c, {"points": float(amount), "fits": SprintCatalog.cfg("roles." + String(c.kind))})
	else:
		var left: float = -amount
		for i in range(TEST_PHASE, -1, -1):
			var take: float = minf(left, float(c.progress[i]))
			c.progress[i] = float(c.progress[i]) - take
			left -= take
	_changed()
	return c.id


## Bekleyen kararın kartı ilerlemesiyle sonraki sprinte devreder; sprint kapandıysa zaten oradadır.
static func decision_carry() -> String:
	var c: Dictionary = decision_card()
	if c.is_empty():
		return ""
	var p: Dictionary = _p()
	if c.id in p.sprint.cards:
		p.sprint.cards.erase(c.id)
		p.next.cards.push_front(c.id)
		c.state = "carried"
		c.assignees = []
		EventBus.card_carried_over.emit(c.id)
		_changed()
	return c.id


## Koşan sprintin çalışma saati çarpanı (fazla mesai kararı) sprint sonuna kadar; sprint yoksa 0.
static func set_hours_mult(mult: float) -> int:
	if mode() != "active":
		return 0
	_p().sprint.hours_mult = mult
	_changed()
	return sprint_number()


## Onaylanan PM planı saklanır; kartları o sprint sonraki sütun olunca oraya geçer (sonraki
## sprintinse hemen).
static func approve(sprint: int) -> void:
	for plan in SprintCatalog.pm_plans():
		if int(plan.number) == sprint and not plan.approved:
			_keep_plan(plan)
	_changed()


static func approve_all() -> void:
	for plan in SprintCatalog.pm_plans():
		if not plan.approved:
			_keep_plan(plan)
	_changed()


## Düzenle: sonraki sprintin önerisi onaysız olarak sonraki sütuna gelir, oyuncu orada düzenler.
## SPRINT görünümünün sonraki sütunu yalnız sonraki sprinti taşır; ilerideki plan düzenlenmez.
static func edit(sprint: int) -> void:
	for plan in SprintCatalog.pm_plans():
		if int(plan.number) == sprint and sprint == int(_p().next.number):
			_to_next(plan.cards)
	_changed()


static func pick_goal(area_id: String) -> void:
	_p().quarter.goal_area = area_id
	_changed()


## Sesler katlaması açıldı: o güne kadar gelenler "yeni" sayılmaz.
static func voices_seen(area_id: String) -> void:
	_p().voices_seen[area_id] = GameState.day
	_changed()


# --- Okumalar --------------------------------------------------------------------------

static func is_typed() -> bool:
	return GameState.product.has("sprint")


static func mode() -> String:
	return String(GameState.product.get("mode", "plan"))


static func sprint_number() -> int:
	return int(GameState.product.get("sprint", {}).get("number", 0))


## Koşan sprintin haftası (1..2); başka kipte 0.
static func week() -> int:
	return GameState.day - int(_p().sprint.start_day) + 1 if mode() == "active" else 0


## Ekibin iki haftalık puanı.
static func capacity() -> int:
	var points: float = 0.0
	for person in team():
		points += person.points
	return roundi(points * int(SprintCatalog.cfg("sprint_weeks")))


## Sprintteki kartların yükü; kapasite çubuğunun dilimleri kart yükleridir.
static func used() -> int:
	var load: int = 0
	for card in _sprint_cards():
		load += card_load(card)
	return load


## Kartın sprintteki yükü: planlamada kalan puanı, sprint içinde başlarken kalan puanı.
static func card_load(c: Dictionary) -> int:
	return roundi(total(c) - float(c.base)) if mode() == "active" else remaining(c)


## Kartın kalan puanı.
static func remaining(c: Dictionary) -> int:
	return roundi(total(c) - _worked(c))


## Saklanan kartların kalan puanı.
static func points_left(ids: Array) -> int:
	var load: int = 0
	for id in ids:
		load += remaining(_p().cards[id])
	return load


## Bu sprintte bitirilen puan (yarım kalan işler dahil).
static func done_points() -> int:
	if mode() != "active":
		return 0
	var done: float = 0.0
	for card in _sprint_cards():
		done += _worked(card) - float(card.base)
	return roundi(done)


## Bu sprintte çalışabilecekler: aktif kurucu ve ürün tarafındaki aktif çalışanlar, Ar-Ge'dekiler
## hariç. {id, name, points (haftalık), fits (uyduğu roller), founder}.
static func team() -> Array:
	var people: Array[Character] = CharacterRegistry.get_active_employees()
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null and founder.status == HRConstants.STATUS_ACTIVE:
		people.push_front(founder)
	var hours: float = float(_p().sprint.get("hours_mult", 1.0)) if mode() == "active" else 1.0
	var out: Array = []
	for c in people:
		var fits: Array = _fits(c)
		if fits.is_empty() or c.assigned_job_ids.has(HRConstants.JOB_RESEARCH):
			continue
		out.append({"id": c.id, "name": c.character_name, "points": _points(c) * hours, "fits": fits,
			"founder": c.category == "founder"})
	return out


## "+" yalnız planlamada, kapasite varken ve yük %125'i aşmamışken açıktır.
static func can_add() -> bool:
	var cap: int = capacity()
	return mode() == "plan" and cap > 0 and used() <= cap * float(SprintCatalog.cfg("cap_ceiling"))


static func can_start() -> bool:
	return mode() == "plan" and not _sprint_cards().is_empty() and capacity() > 0


## Otomatik atamanın ön izlemesi: sprintin kalan haftaları bugünkü ekiple oynanır;
## kartta çalışacak her kişi ve haftası, [{id, name, weeks}].
static func effort_split(card_id: String) -> Array:
	var cards: Array = _sprint_cards().map(func(c: Dictionary) -> Dictionary: return c.duplicate(true))
	var people: Array = team()
	var by_id: Dictionary = {}
	for person in people:
		by_id[person.id] = person
	var weeks: Dictionary = {}
	for _w in int(SprintCatalog.cfg("sprint_weeks")) - maxi(week(), 1) + 1:
		_assign(cards, people)
		for c in cards:
			for id in c.assignees:
				_work(c, by_id[id])
				if c.id == card_id:
					weeks[id] = int(weeks.get(id, 0)) + 1
	return weeks.keys().map(func(id: String) -> Dictionary:
		return {"id": id, "name": by_id[id].name, "weeks": weeks[id]})


## "v1.4": v1.0 MVP'dir, her sürüm +0.1; 0 sürümsüzdür ("").
static func version_label(n: int) -> String:
	return TranslationServer.translate("PROD_VERSION_SHORT").format({"version": version_text(n)}) if n > 0 else ""


## Sürüm etiketinin sayı kısmı, "1.4".
static func version_text(n: int) -> String:
	return "%d.%d" % [1 + int((n - 1) / 10.0), (n - 1) % 10]


## Kişi, bugünkü tikte biten haftada bir sprint kartında çalıştı mı; tür seçilmeden kimse çalışmaz.
static func worked(character_id: String) -> bool:
	return is_typed() and int(_p().worked.day) == GameState.day and character_id in _p().worked.ids


# --- Hafta ve kapanış ----------------------------------------------------------------

## Biten haftanın işi kartlara dökülür; ikinci haftanın sonunda sprint kapanır, değilse
## yeni haftanın kararı ve ataması yapılır.
static func _end_week() -> void:
	var people: Dictionary = {}
	for person in team():
		people[person.id] = person
	var worked_ids: Array = []
	for c in _sprint_cards():
		if c.decision or c.state == "done":
			continue
		var before: int = phase(c)
		for id in c.assignees:
			if people.has(id):
				_work(c, people[id])
				worked_ids.append(id)
		var after: int = phase(c)
		if after != before:
			EventBus.card_phase_changed.emit(c.id, after)
		# Karar fiili eforu düşürüp kartı haftasız da bitirmiş olabilir.
		if after == PHASE_DONE:
			c.state = "done"
			EventBus.card_done.emit(c.id)
	_p().worked = {"day": GameState.day, "ids": worked_ids}
	if week() > int(SprintCatalog.cfg("sprint_weeks")):
		_close()
	else:
		_request_decision()
		_assign(_sprint_cards(), team())


## Haftanın ataması: kartlar sprint sırasıyla, kişi haftada tek kart. Kartın sıradaki fazına
## uyan kişi önce, sonra puanı yüksek olan; kart bu hafta bitecek kadar kişi alır.
static func _assign(cards: Array, people: Array) -> void:
	var free: Array = people.duplicate()
	for c in cards:
		c.assignees = []
		if c.decision:
			continue
		var probe: Dictionary = c.duplicate(true)
		while phase(probe) < PHASE_DONE and not free.is_empty():
			var role: String = _role(probe, phase(probe))
			free.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
				if (role in a.fits) != (role in b.fits):
					return role in a.fits
				if a.points != b.points:
					return a.points > b.points
				return a.id < b.id)
			var person: Dictionary = free.pop_front()
			_work(probe, person)
			c.assignees.append(person.id)


## Kişinin haftalık puanı kartın sıradaki fazlarına dökülür; uymadığı rolün fazında yarı hızla.
## Test fazı Test rolü olmadan yapılırsa kart sürümde hatalı çıkabilir.
static func _work(c: Dictionary, person: Dictionary) -> void:
	var budget: float = person.points
	var effort: float = total(c)
	var at: int = phase(c)
	while at < PHASE_DONE and budget > EPS:
		var speed: float = 1.0 if _role(c, at) in person.fits else float(SprintCatalog.cfg("no_role_speed"))
		var work: float = minf(float(c.shares[at]) * effort - float(c.progress[at]), budget * speed)
		c.progress[at] = float(c.progress[at]) + work
		budget -= work / speed
		if at == TEST_PHASE and speed < 1.0:
			c.faulty = true
		at = phase(c)


## Haftada bir: sürmekte olan bir kart için deterministik bir karar kartı istenir; olay motoru
## kabul ederse kart karar verilene kadar ilerlemez. Aynı anda tek karar bekler.
static func _request_decision() -> void:
	var p: Dictionary = _p()
	if not p.decision.is_empty():
		return
	var events: Array = SprintCatalog.cfg("decision.cards")
	for c in _sprint_cards():
		if phase(c) == PHASE_DONE:
			continue
		var roll: int = absi(hash(str([c.id, sprint_number(), week()])))
		if roll % 1000 >= roundi(float(SprintCatalog.cfg("decision.rate")) * 1000):
			continue
		var event_id: String = events[roll % events.size()]
		if EventGate.request(event_id):
			c.decision = true
			p.decision = {"card_id": c.id, "event_id": event_id}
			_watch_decision()
			EventBus.card_decision_requested.emit(c.id)
			return


## Kâğıt ne kuyrukta ne masadaysa oyuncu karar vermiştir; kart yeniden ilerler.
static func _settle_decision() -> void:
	var decision: Dictionary = _p().decision
	if decision.is_empty():
		return
	var event_id: String = decision.event_id
	if EventGate.instances_of(event_id) > 0 \
			or EventGate.desk_papers(DESK_SCAN).any(func(e: Dictionary) -> bool: return e.id == event_id):
		return
	_clear_decision()


## Seçilen karar kartı hemen serbest bırakır; süresi dolan kâğıdı ertesi tik ya da başlatma okur.
static func _watch_decision() -> void:
	if not EventBus.event_resolved.is_connected(_on_event_resolved):
		EventBus.event_resolved.connect(_on_event_resolved)


static func _on_event_resolved(event_id: String, _choice: int) -> void:
	if GameState.product.get("decision", {}).get("event_id", "") == event_id:
		_clear_decision()
		_changed()


## Sprint sürerken kalkan kararın kartı haftanın kalanında o hafta boşta kalanlarla yürür: seçim
## kartın kaderini değiştirebilsin.
static func _clear_decision() -> void:
	var c: Dictionary = decision_card()
	_p().decision = {}
	if c.is_empty():
		return
	c.decision = false
	if mode() == "active" and c.id in _p().sprint.cards:
		var busy: Array = []
		for card in _sprint_cards():
			busy.append_array(card.assignees)
		_assign([c], team().filter(func(person: Dictionary) -> bool: return person.id not in busy))


## Bekleyen kararın kartı; karar yoksa ya da kart artık saklanmıyorsa {}.
static func decision_card() -> Dictionary:
	return _p().get("cards", {}).get(String(_p().get("decision", {}).get("card_id", "")), {})


## Planlamada ya da sürüm notunda bir gün geçti: liderin önerisiyle sprint kendiliğinden başlar.
static func _auto_start() -> void:
	if mode() == "release":
		plan_next()
	apply_lead()
	if start():
		_p().auto_started = sprint_number()
		EventBus.sprint_auto_started.emit(sprint_number())


## Sprint kapanışı: önceki sprintten betada bekleyenler ve bu sprintte bitenler (beta kapalıysa)
## çıkar, etkileri uygulanır; bitmeyenler ilerlemesiyle sonraki sprinte devreder. Kimlik
## yeteneklerinden üçü K1'e varınca ürün CANLI v1.0 olur; canlıda çıkan kart her sürümde +0.1.
## Hâlâ bekleyen karar açık kalır: kâğıdı aynı dağıtımın olay yuvasında süresi dolup on_expire
## ile çözülür ve ertesi okumada kart serbest kalır; beklerken ilerlemediği için devretmiştir.
static func _close() -> void:
	var p: Dictionary = _p()
	var sprint: Dictionary = p.sprint
	var number: int = int(sprint.number)
	var velocity: Dictionary = {"done": done_points(), "total": int(sprint.capacity)}
	var ship: Array = p.cards.values().filter(func(c: Dictionary) -> bool: return c.state == "beta")
	var to_beta: Array = []
	var carried: Array = []
	for c in _sprint_cards():
		if c.state != "done":
			carried.append(c)
		elif sprint.beta:
			to_beta.append(c)
		else:
			ship.append(c)
	var areas: Array = SprintCatalog.area_ids()
	var levels: Dictionary = {}
	var alerts: Dictionary = {}
	for a in areas:
		levels[a] = SprintCatalog.area_level(a)
		alerts[a] = SprintCatalog.area_alert(a)
	var closed: int = 0
	var new_code: float = 0.0
	var faulty: Array = []
	for c in ship:
		match c.kind:
			"fix":
				# Sürüm notu gerçekten kapananları yazar: koşunun erittikleri karttan düşer.
				c.tickets = SprintBridges.close_tickets(c.tickets)
				closed += c.tickets.size()
			"research":
				p.research_done[c.area] = number
			_:
				if c.line == SprintCatalog.PAID_PLAN:
					SprintBridges.open_paid_plan()
				elif int(c.target_tier) > ProductState.line_tier(c.line):
					# Kademe düşmez: aynı kademeye başka bir kartla varılmışsa bu kart bir şey yazmaz.
					var tier: int = int(c.target_tier)
					ProductState.set_line_tier(c.line, tier)
					EventBus.line_upgraded.emit(c.line, tier)
					if tier >= ProductLines.TIER_MAX:
						EventBus.line_completed.emit(c.line)
						EventBus.delighter_shipped.emit(c.step)
					new_code += ProductLines.effort_of(c.step)
		var chance: float = SprintCatalog.cfg("faulty_chance_beta" if c.state == "beta" else "faulty_chance")
		if c.faulty and float(absi(hash(str([c.id, number]))) % 1000) / 1000.0 < chance:
			faulty.append(c.line)
		c.state = "done"
		p.cards.erase(c.id)
	var mvp: bool = not ProductState.is_live() and SprintCatalog.mvp_cards_left() == 0
	var public: bool = mvp or (ProductState.is_live() and ship.any(
		func(c: Dictionary) -> bool: return c.kind != "research"))
	var n: int = ProductState.version() + 1 if public else 0
	if public:
		if mvp:
			GameState.set_flag("mvp_shipped", true)
			GameState.set_flag("mvp_launch_day", GameState.day)
			new_code = _shipped_code()
		GameState.set_flag("mvp_version", n)
		var history: Array = GameState.get_flag("mvp_version_history", [])
		history.append({"version": n, "day": GameState.day})
		GameState.set_flag("mvp_version_history", history)
		# Canlı hata havuzu her sürümle yeniden başlar; sprintte gizli hata devri yoktur, devir 0'dır.
		GameState.set_flag("mvp_live_bug_count", 0)
		GameState.set_flag("mvp_live_bug_progress", 0.0)
		GameState.submit_month_highlight(TranslationServer.translate("PROD_SHIP_FIRST_TITLE") if n == 1
			else TranslationServer.translate("PROD_SHIP_VERSION_TITLE").format({"version": version_text(n)}), 50)
		ProductState.refresh_on_publish(new_code)
		SprintBridges.push_axes()
		if mvp:
			SprintBridges.on_mvp()
		SprintBridges.on_release()
		# Hatayı bulan kullanıcıdır: yayına girmeyen kart ticket doğurmaz.
		for line in faulty:
			SprintBridges.add_faulty_ticket(line)
		_refresh_fix_cards()
	var changed: Array = []
	var cleared: Array = []
	for a in areas:
		var to: float = SprintCatalog.area_level(a)
		if to != levels[a]:
			changed.append({"area": a, "from": levels[a], "to": to})
		if alerts[a] and not SprintCatalog.area_alert(a):
			cleared.append(a)
	var snapshot := func(c: Dictionary) -> Dictionary: return c.duplicate(true)
	var release: Dictionary = {"number": n, "sprint": number, "shipped": ship.map(snapshot),
		"carried": carried.map(func(c: Dictionary) -> Dictionary:
			return {"id": c.id, "done": floori(_worked(c) + EPS), "total": roundi(total(c)), "to_sprint": number + 1}),
		"velocity": velocity, "expected": _expected(changed, closed), "actual": {}, "press": {},
		"beta": not to_beta.is_empty(), "day": GameState.day, "changed_areas": changed, "alerts_cleared": cleared}
	release.press = SprintBridges.press_line(release)
	for c in to_beta:
		c.state = "beta"
	for c in carried:
		c.state = "carried"
		c.assignees = []
	var carried_ids: Array = carried.map(func(c: Dictionary) -> String: return c.id)
	p.next.cards = carried_ids + p.next.cards.filter(func(id: String) -> bool: return id not in carried_ids)
	sprint.status = "closed"
	sprint.cards = []
	p.release = release
	p.releases.append(release.duplicate(true))
	p.mode = "release"
	for id in carried_ids:
		EventBus.card_carried_over.emit(id)
	if public:
		EventBus.build_phase_changed.emit("shipped")
		EventBus.version_shipped.emit(n)
	EventBus.sprint_closed.emit(number)


## Sürümde beklenen: değişen ilk alanın yeni durumu, yoksa kapanan ticket'lar, yoksa değişiklik yok.
static func _expected(changed: Array, closed: int) -> Dictionary:
	if not changed.is_empty():
		var area: String = changed[0].area
		return {"key": "PRODUCT_RESULT_LEVEL_EXPECTED", "args": {"area": area, "to": SprintCatalog.area_word(area)}}
	if closed > 0:
		return {"key": Fmt.count_key("PRODUCT_RESULT_TICKETS_EXPECTED", closed), "args": {"n": closed}}
	return {"key": "PRODUCT_RESULT_NONE_EXPECTED", "args": {}}


## Sürümden bir gün sonra gerçekleşen sonuç, hem geçmişteki kayda hem açık sürüm notuna.
static func _fill_actual() -> void:
	var p: Dictionary = _p()
	for r in p.releases:
		if GameState.day != int(r.day) + 1 or r.shipped.is_empty():
			continue
		r.actual = SprintBridges.actual_sentence(r)
		if not p.release.is_empty() and int(p.release.sprint) == int(r.sprint):
			p.release.actual = r.actual


## MVP'nin yeni kod terimi: o güne kadar yapılmış bütün kademelerin katalog eforu.
static func _shipped_code() -> float:
	var code: float = 0.0
	var tiers: Dictionary = ProductState.line_tiers()
	for line_id in tiers:
		for t in range(1, int(tiers[line_id]) + 1):
			code += ProductLines.effort_of(String(ProductLines.step_at(line_id, t).id))
	return code


# --- İç -------------------------------------------------------------------------------

static func _p() -> Dictionary:
	return GameState.product


static func _changed() -> void:
	EventBus.product_state_changed.emit()


## Tür seçilmeden de okunur (lider önerisi used()'i sorar); o zaman boştur.
static func _sprint_cards() -> Array:
	var cards: Dictionary = _p().get("cards", {})
	return (_p().get("sprint", {}).get("cards", []) as Array).map(func(id: String) -> Dictionary: return cards[id])


## Koşan, bitmiş ya da betada bekleyen kart yerinden oynamaz; kilitli kademe alınmaz.
static func _movable(c: Dictionary) -> bool:
	return not c.is_empty() and c.state not in ["running", "done", "beta"] and SprintCatalog.gate_reason(c.step) == ""


## Başlamamış düzeltme kartının ticket'ları defterden okunur: koşunun erittikleri düşer, hattın
## yenileri eklenir. Defter yalnız günlük eşitlemede ve kapanışta değişir; ikisinden sonra çağrılır.
static func _refresh_fix_cards() -> void:
	var by_line: Dictionary = SprintCatalog.tickets_by_line()
	for c in _p().cards.values():
		if c.kind == "fix" and c.state in ["candidate", "planned", "carried"]:
			c.tickets = by_line.get(c.line, [])


## Kartı bu sprinte ya da sonrakine koyar; adaysa saklanan kart olur, devreden damgası kalır.
static func _place(c: Dictionary, this_sprint: bool) -> void:
	var p: Dictionary = _p()
	p.sprint.cards.erase(c.id)
	p.next.cards.erase(c.id)
	(p.sprint.cards if this_sprint else p.next.cards).append(c.id)
	if c.state == "candidate":
		c.state = "planned"
	c.merge({"paid": false, "base": 0.0})
	p.cards[c.id] = c


static func _keep_plan(plan: Dictionary) -> void:
	plan.approved = true
	_p().quarter.plans.append(plan)
	if int(plan.number) == int(_p().next.number):
		_to_next(plan.cards)


static func _to_next(ids: Array) -> void:
	for id in ids:
		_place(SprintCatalog.card_by_id(id), false)


## Kartın eforu, karar fiilinin değişikliğiyle.
static func total(c: Dictionary) -> float:
	return float(int(c.effort) + int(c.effort_mod))


static func _worked(c: Dictionary) -> float:
	return float(c.progress[0]) + float(c.progress[1]) + float(c.progress[2])


## Kartın sıradaki fazı; üçü dolmuşsa PHASE_DONE. Payı olmayan faz öncekiler bitince biter.
static func phase(c: Dictionary) -> int:
	var effort: float = total(c)
	for i in PHASE_DONE:
		if float(c.shares[i]) * effort - float(c.progress[i]) > EPS:
			return i
	return PHASE_DONE


static func _role(c: Dictionary, at: int) -> String:
	return (SprintCatalog.cfg("roles." + String(c.kind)) as Array)[at]


## Kişinin uyduğu sprint rolleri: kurucu Ürün ve Yazılım'da, çalışan ana ya da ikincil alanında.
static func _fits(c: Character) -> Array:
	if c.category == "founder":
		return (SprintCatalog.cfg("founder_roles") as Array).duplicate()
	var areas: Dictionary = SprintCatalog.cfg("role_areas")
	return areas.keys().filter(func(r: String) -> bool: return HRConstants.can_hold_area(c.role, areas[r], c.category))


## Haftalık puan: 2 × beceri bandı (ana alanın 0-10 puanı; kurucu sabit) × moral bandı × çalışma saati.
static func _points(c: Character) -> float:
	var mult: float = SprintCatalog.cfg("founder_mult")
	var morale: float = 1.0
	if c.category != "founder":
		var stat: int = HRSystem.skill(c, HRConstants.role_key_area(c.role))
		var bands: Array = SprintCatalog.cfg("skill.mult")
		mult = bands[0] if stat <= int(SprintCatalog.cfg("skill.low_max")) \
			else bands[1] if stat <= int(SprintCatalog.cfg("skill.mid_max")) else bands[2]
		morale = HRConstants.morale_band_mult(c.morale)
	return float(SprintCatalog.cfg("person_points_week")) * mult * morale \
		* HRConstants.hours_output_mult(WorkHoursSystem.hours_for(c))
