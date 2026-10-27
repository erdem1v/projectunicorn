class_name SprintSystem
extends RefCounted

# Ürünün sprint motoru: tür seçimi, planlama eylemleri, haftalık atama ve ilerleme, sprint
# kapanışı ve sürüm. GameState.product'ı burası ve köprüsü SprintBridges yazar (köprü yalnız
# requests ve rival_hits'i, bir de verilen sürüm kaydının thanks'ini); okuma katalogdadır
# (SprintCatalog). Sinyaller EventBus'ın Sprint bölümündedir.
#
# Bir gün bir haftadır. Başlatılan sprintin ilk haftası başlatma günüdür; her günlük tik biten
# haftanın işini kartlara döker. Sprint iki haftadır; kartlarının hepsi daha önce biterse o haftanın
# sonunda kapanır ve sürüm yazılır. Atama hafta başında yapılır ve hafta boyunca kartta görünür.

## Kartın progress ve need dizilerinin sırası: Tasarım (araştırmada Ürün), Geliştirme, Test.
const DEV_PHASE := 1
const TEST_PHASE := 2
const PHASE_DONE := 3
## Aşama adları, ihtiyaç dizisinin sırasıyla; sürüm kaydının `overflow`'u bunlarla anahtarlanır.
const STAGES := ["design", "dev", "test"]
const EPS := 0.001
## MVP tahmininin ufku (hafta); ötesinde tahmin yoktur.
const MVP_HORIZON := 24
## product.sprint_late ve product.promise_due kartlarının fazla mesai seçeneğinin çarpanı (sprint_hours fiili); kartların değeriyle aynı kalır.
const CRUNCH_MULT := 1.25
## Sprint oyuncunun planını beklerken saati tutan neden (TimeManager.HOLD_LABELS).
const HOLD_PLAN := "sprint_plan"
## Sprint ekibine giren işler.
const SPRINT_JOBS := [HRConstants.JOB_BUILD, HRConstants.JOB_TEST]


static func daily_tick() -> void:
	if mode() != "active":
		GameState.freeze_founder_sprint_pay()
	if not is_typed():
		return
	_settle_decision()
	_refresh_fix_cards()
	SprintBridges.tick_requests()
	var p: Dictionary = _p()
	_fill_actual()
	match mode():
		"active":
			_end_week()
		"plan":
			if GameState.day > int(p.sprint.start_day) and not awaits_plan():
				_auto_start()
		"release":
			if GameState.day > int(p.release.day) and not awaits_plan():
				_auto_start()
	_changed()


# --- Tür -------------------------------------------------------------------------

## Ürün sekmesinin tür seçimi: alt-tür, pazar, haber havuzu ve ad yazılır, Sprint 1 planlamada açılır;
## seçicinin taslağı silinir.
static func choose_type(subtype: String, name: String) -> void:
	if is_typed():
		return
	GameState.set_flag("mvp_sub_product_type_id", subtype)
	GameState.set_flag("mvp_market_type", ProductCatalog.get_market_type(subtype))
	var pool: String = ProductCatalog.get_pool_of(subtype)
	if pool != "":
		GameState.set_subgenre(pool)
	GameState.set_flag("mvp_product_name", name)
	GameState.product.erase("type_draft")
	GameState.product.merge(new_state(GameState.day), true)
	EventBus.sprint_planned.emit(1)
	_changed()


## Tür seçicinin yarım seçimi {market, subtype, name}: sayfa yeniden kurulunca (dil, palet, gelen kutusu)
## seçici onu okur. Sinyalsiz: ad yazılırken sekme yeniden kurulmaz.
static func set_type_draft(d: Dictionary) -> void:
	GameState.product["type_draft"] = d


## Tür seçilmiş ürünün ilk durumu: Sprint 1 `day` gününde planlamada açılır. Saf; kayıt göçü de
## bunu kurar.
static func new_state(day: int) -> Dictionary:
	return {
		"sprint": {"number": 1, "start_day": day, "status": "planning", "cards": [], "capacity": 0,
			"lead_applied": false},
		"next": {"number": 2, "cards": []},
		"mode": "plan", "cards": {}, "release": {}, "releases": [], "polish": {},
		"requests": [], "rival_hits": [],
		"research_done": {}, "decision": {}, "decision_sprint": -1, "auto_started": -1,
		"quarter": {"goal_area": "", "start_sprint": 1, "start_day": day, "plans": []},
		"worked": {"day": -1, "ids": []}, "pending_faulty": [], "delegate": false, "empty_sprint": -1,
	}


# --- Eylemler (arayüz ve bot) -------------------------------------------------------

## "+" ve "↑": kart yerinden oynayabiliyor ve "+" onun için açıksa (can_add) bu sprinte girer.
static func add(card_id: String) -> void:
	var card: Dictionary = SprintCatalog.card_by_id(card_id)
	if _movable(card) and can_add(card_id):
		_place(card, true)
		_changed()


## "→": kart sonraki sprinte.
static func send_next(card_id: String) -> void:
	var card: Dictionary = SprintCatalog.card_by_id(card_id)
	if _movable(card):
		_place(card, false)
		_changed()


## Kart adaylara döner; ilerlemesi, ödenmiş lisansı ya da bekleyen kararı varsa saklanır ve yeniden
## alındığında kaldığı yerden, bedeli yeniden kesilmeden sürer. Koşan sprintte kartın kişileri
## haftanın kalanında kimsesiz kartlara geçer. Kâğıdın takip kartı (`follow`) çıkmaz: kâğıdın bedeli onda durur ve aday
## listesinde yeri yoktur.
static func remove(card_id: String) -> void:
	var p: Dictionary = _p()
	var card: Dictionary = p.cards.get(card_id, {})
	if card.is_empty() or card.state == "done" or card.get("follow", false):
		return
	p.sprint.cards.erase(card_id)
	p.next.cards.erase(card_id)
	p.sprint.lead_applied = false
	if _worked(card) > EPS or card.get("paid", false) or card.decision:
		card.state = "candidate"
		card.assignees = []
	else:
		p.cards.erase(card_id)
	if mode() == "active":
		_restaff()
	_changed()


## Sprinti başlatır; planın tutuşu kalkar, saati oyuncu sürdürür. Düzeltme kartları kilitlemeden önce
## hata deposundan okunur.
static func start() -> bool:
	_settle_decision()
	_refresh_fix_cards()
	if not can_start():
		return false
	_begin()
	return true


## Başlatmanın kendisi: kapısı sonradan kapanmış kart sonraki sütuna geçer, kalanlar kilitlenir (`base` ve
## `progress_at_start`: sprintin başındaki iş), lisans bedeli bir kez alınır, ilk haftanın ataması yapılır. Kartsız
## başlayan sprint (boş geçirme, planlanacak kart yokken otomatik başlangıç) boş sprinttir; damgası ilk çizimden
## önce yazılır.
static func _begin() -> void:
	var p: Dictionary = _p()
	for card in _sprint_cards():
		if not _starts(card):
			_place(card, false)
	if _sprint_cards().is_empty():
		p.empty_sprint = int(p.sprint.number)
	var sprint: Dictionary = p.sprint
	sprint.status = "running"
	sprint.start_day = GameState.day
	sprint.capacity = capacity()
	var steps: Array = []
	for card in _sprint_cards():
		card.state = "running"
		card.base = _worked(card)
		card.progress_at_start = card.progress.duplicate()
		if not card.get("paid", false):
			card.paid = true
			steps.append(card.step)
	var cost: int = ProductLines.sum_license_cost(steps)
	if cost > 0:
		FinanceSystem.apply_one_time_cost(cost, "build_commit")
	p.mode = "active"
	SprintBridges.tick_rivals(int(sprint.number))
	_staff_week(false)
	_ask_promise()
	EventBus.sprint_started.emit(int(sprint.number))
	_changed()


## Sürüm notundan sonraki sprintin planlamasına: sonraki sütun (devredenler önde) bu sprint olur,
## yeni sonraki sütuna onaylı PM planı geçer. Çeyreğin haftaları sprintlerle dolunca çeyrek döner, hedef
## boşalır (PM'in planı en zayıf alana bakar). Kademesine başka bir kartla varılmış saklı kart düşer
## (geç kalan talebin kartı ile aynı kademenin özellik kartı ikisi de saklanabilir); kâğıdın takip kartı (`follow`) kalır.
static func plan_next() -> void:
	if mode() != "release":
		return
	var p: Dictionary = _p()
	for c in p.cards.values():
		if c.kind in ["feature", "request"] and not c.get("follow", false) and int(c.target_tier) <= SprintCatalog.tier(c.line):
			p.cards.erase(c.id)
			p.next.cards.erase(c.id)
	var number: int = int(p.next.number)
	p.sprint = {"number": number, "start_day": GameState.day, "status": "planning", "cards": p.next.cards,
		"capacity": 0, "lead_applied": false}
	p.next = {"number": number + 1, "cards": []}
	p.release = {}
	p.mode = "plan"
	var quarter: Dictionary = p.quarter
	if number >= int(quarter.start_sprint) + sprints_in(int(SprintCatalog.cfg("quarter_weeks"))):
		quarter.start_sprint = number
		quarter.start_day = GameState.day
		quarter.goal_area = ""
	quarter.plans = quarter.plans.filter(func(plan: Dictionary) -> bool: return int(plan.number) > number)
	for plan in quarter.plans:
		if int(plan.number) == number + 1:
			_to_next(SprintCatalog.still_open(plan.cards))
	EventBus.sprint_planned.emit(number)
	_changed()
	if delegated():
		_auto_start()


## Hattın düzeltme kartı sprintin başına girer (olay motoru çağırır). Hattında hata yoksa ya da kart bu sprintte
## bitmişse (kapanışta hattı zaten temizler) bir şey yapmaz. Kart, `start()`'taki gibi, kilitlenmeden önce hata
## deposundan okunur: olay hatayı düşürüp aynı tikte çağırır. `bugs`: kendi hattı olmayan bir olayın (ücretli plan)
## hattına düşürdüğü hata.
static func fix_first(line: String, bugs := 0) -> void:
	if bugs > 0:
		ProductState.add_bugs(line, bugs)
	_refresh_fix_cards()
	var card: Dictionary = SprintCatalog.card_by_id("fix:" + line)
	if not card.is_empty() and card.state != "done":
		put_first(card)


## Kart sprintin başına girer: sprintteyse başa taşınır, sonraki sütundaysa ya da aday ise sprinte alınır, ikinci kart
## açılmaz. Sürüm notundayken ve koşan sprintin son gecesi mesai bittikten sonra (ekip yeni sprintle başlar) sonraki
## sprintin başına girer. Son gecede kapanış devredenleri sonraki sütunun başına dizer; kartın onların önünde kalması
## için kimliği `next.first`e yazılır (son çağrılan önde, `_next_column`) ve koşan sprintte duran kart sonraki sütuna
## geçmez, yalnız bu sırayı alır. Koşan sprintte sprinte giren kart hemen koşmaya başlar ve haftanın ataması iki durumda
## da baştan yapılır: sprintten çıkan kartın kişileri öbür kartlara geçer, kapanış planın gösterdiğini yapar.
static func put_first(card: Dictionary) -> void:
	var next: bool = _fix_goes_next()
	if next and mode() == "active":
		var asked: Array = _p().next.get_or_add("first", [])
		asked.erase(card.id)
		asked.push_front(card.id)
		if card.state == "running":
			_changed()
			return
	_place(card, not next)
	var column: Array = _p().next.cards if next else _p().sprint.cards
	column.erase(card.id)
	column.push_front(card.id)
	if mode() == "active":
		if not next and card.state != "running":
			card.merge({"state": "running", "base": _worked(card), "progress_at_start": card.progress.duplicate(),
				"paid": true}, true)
		_assign(_sprint_cards(), team(), _ahead_cards())
	_changed()


## Düzeltme kartı sütunun başına girse hangi kart sprintten kayardı: bugünkü sırada biten, kart başa geçince bitmeyen
## ilk kart ({kind, line, step, customer_id}: adı SprintCatalog.card_name verir), yoksa {}. Çip bunu `fix_first`
## çalışmadan söyler; `bugs` fix_first'teki gibi hattın henüz düşmemiş hatasıdır.
static func fix_first_bumps(line: String, bugs := 0) -> Dictionary:
	var fix: Dictionary = SprintCatalog.card_by_id("fix:" + line)
	if fix.is_empty() and bugs > 0:
		fix = SprintCatalog.new_card("fix:" + line, "fix", SprintCatalog.area_of_line(line),
			SprintCatalog.fix_effort(bugs), line)
	return {} if fix.is_empty() or fix.state == "done" else first_bumps(fix)


## `card` sütunun başına girse hangi kart sprintten kayardı: bugünkü sırada biten, kart başa geçince bitmeyen ilk kart
## (`card_ref`), yoksa {}. Kartlar karar beklemiyormuş gibi oynanır: kâğıdın kartı da başa geçince çalışır. Son gecede
## sonraki sprint kapanışın devrettikleriyle, son haftanın işi dökülmüş hâlleriyle başlar (`_closing_carry`); bu hafta
## bitecek kart sonraki sprinte geçmez, kimseyi kaydırmaz.
static func first_bumps(card: Dictionary) -> Dictionary:
	var next: bool = _fix_goes_next()
	var carried: Array = _closing_carry() if next else []
	var carried_ids: Array = carried.map(func(c: Dictionary) -> String: return c.id)
	if next and card.id in _p().sprint.cards and card.id not in carried_ids:
		return {}
	var column: Array = _next_column(carried_ids) if next else _p().sprint.cards
	var undecided := func(c: Dictionary) -> Dictionary:
		var at: int = carried_ids.find(c.id)
		return (carried[at] if at >= 0 else c).merged({"decision": false}, true)
	var rest: Array = column.filter(func(id: String) -> bool: return id != card.id).map(
		func(id: String) -> Dictionary: return undecided.call(_p().cards[id]))
	var today: Array = column.map(func(id: String) -> Dictionary: return undecided.call(_p().cards[id])) \
		if card.id in column else rest
	var weeks: int = sprint_weeks() if next else weeks_left()
	var before: Dictionary = _outcome(today, weeks, not next, team()).cards
	var after: Dictionary = _outcome([undecided.call(card)] + rest, weeks, not next, team()).cards
	for c in rest:
		if bool(before[c.id].finishes) and not bool(after[c.id].finishes):
			return card_ref(c)
	return {}


## Kartı adlandıran alanlar (`SprintCatalog.card_name`'in okuduğu): çip ve geçmiş satırı kartın adını bununla yazar, kart
## sürümle silinse de.
static func card_ref(c: Dictionary) -> Dictionary:
	return {} if c.is_empty() else {"kind": c.kind, "line": c.line, "step": c.step, "customer_id": c.customer_id}


## Düzeltme kartı sonraki sprintin başına girer: sürüm notundayken ya da koşan sprint bu gece kapanacak ve günün
## mesaisi bitmişken (son hafta, ekip bu hafta için bir şey yapamaz; mesaiden önceki saatlerde hafta daha önündedir).
static func _fix_goes_next() -> bool:
	return mode() == "release" or (mode() == "active" and week() >= sprint_weeks() and not MailClock.in_window()
		and MailClock.now() % MailClock.DAY_MINUTES >= int(WorkHoursSystem.company_window()["end"]) * 60)


## Koşan sprint bu gece kapanırsa sonraki sprinte devredecek kartlar: sprintteki sırayla, haftanın işi dökülmüş
## kopyalar (`_close`un `carried`ı); koşan sprint yoksa [].
static func _closing_carry() -> Array:
	if mode() != "active":
		return []
	var cards: Array = _played_copies()
	_finish_sprint(cards, team())
	return cards.filter(func(c: Dictionary) -> bool: return phase(c) < PHASE_DONE and not SprintBugs.sent(c))


## Sonraki sütunun kapanıştaki sırası, `carried` kapanışın devrettiği kimlikler olsun: son gecede başa alınanlar
## (son çağrılan önde; devreden ya da sütunda olanlar), sonra devredenler, sonra planlı kartlar.
static func _next_column(carried: Array) -> Array:
	var next_cards: Array = _p().next.cards
	var asked: Array = (_p().next.get("first", []) as Array).filter(func(id: String) -> bool:
		return id in carried or id in next_cards)
	var lead: Array = asked + carried.filter(func(id: String) -> bool: return id not in asked)
	return lead + next_cards.filter(func(id: String) -> bool: return id not in lead)


## "Bu sprinti boş geçir", oyuncunun onayıyla: planın kartları sonraki sprinte geçer, sprint kartsız başlar.
static func skip() -> void:
	if mode() != "plan":
		return
	_to_next(_p().sprint.cards.duplicate())
	_begin()


## Planlamayı PM'e devretme anahtarı: devirde sprint oyuncuyu beklemeden liderin önerisiyle başlar. Çeyreği planlayan
## PM yokken açılmaz.
static func set_delegate(on: bool) -> void:
	_p().delegate = on and SprintCatalog.quarter_pm() != null
	_changed()


## Kurucu sprint kartı alır mı: planlamanın kararıdır, planlamada ve sürüm notunda değişir, koşan sprintte değişmez. Ekip
## değiştiği için liderin önerisi yeniden okunur.
static func set_founder_in_sprint(on: bool) -> void:
	if mode() != "active":
		GameState.set_founder_in_sprint(on)
		_p().sprint.lead_applied = false
		_changed()


## Kapıda "Yayınla": ürün CANLI v1.0 olur, kapanışın notu v1.0'ın sürüm notu olur; v1.0'ı bekleyen
## hatalı kartların hataları kartlarının hattına düşer. "Bir sprint daha" plan_next'tir. Not yayın
## gününe tarihlenir: kapıda geçen günün yazdığı sonuç kapalı ürünündü, v1.0'ınki ertesi gün yazılır.
static func publish() -> void:
	var p: Dictionary = _p()
	if not p.release.get("gate", false):
		return
	_go_public(1)
	_land_faulty()
	var release: Dictionary = p.release
	release.number = 1
	release.day = GameState.day
	release.actual = {}
	release.press = SprintBridges.press_line(release)
	release.expected = {"key": "PRODUCT_RESULT_MVP_EXPECTED", "args": {}}
	release.gate = false
	p.releases[-1] = release.duplicate(true)
	EventBus.build_phase_changed.emit("shipped")
	EventBus.version_shipped.emit(1)
	_changed()


## Beta kanalı günlerinden kalma kayıt: betada bekleyen kart biten sayılır ve sıradaki kapanışta yayına girer
## (sürüm notu açıksa sıradaki sprintin kartı olarak).
static func finish_beta_cards() -> void:
	var p: Dictionary = GameState.product
	for c in p.get("cards", {}).values().filter(func(c: Dictionary) -> bool: return c.state == "beta"):
		c.state = "done"
		(p.next if p.mode == "release" else p.sprint).cards.append(c.id)


## Liderin önerisi bu sprintin boş yerlerini doldurur ve sonraki sütundaki kartların sonuna kart ekler. Öneri büyük ekipte
## idempotent değildir (devreden kalkanı çağrı başına sayılır): uygulandıktan sonra ikinci uygulama bir şey yapmaz; bayrağı
## planın değişmesi (`_place`, `remove`), Kurucu sprintte anahtarı ve çeyreğin hedefi indirir, devir indirmez.
static func apply_lead() -> void:
	if mode() != "plan" or _p().sprint.get("lead_applied", false):
		return
	var lead: Dictionary = SprintCatalog.lead_suggestion()
	for id in lead.this:
		_place(SprintCatalog.card_by_id(id), true)
	for id in lead.next:
		_place(SprintCatalog.card_by_id(id), false)
	_p().sprint.lead_applied = true
	_changed()


# --- Karar kartının etkileri (olay motorunun sprint fiilleri) --------------------------

## Bekleyen kararın kartının eforu ± puan, aşamalarına ihtiyaçlarıyla orantılı dağılır; kartın kimliği, karar yoksa "".
static func decision_effort(amount: int) -> String:
	var c: Dictionary = decision_card()
	if not c.is_empty():
		_scale_need(c, effort_change(amount))
		_changed()
	return c.get("id", "")


## Eforun gerçekten değişeceği puan: kart sprint.json `paper.min_points` puanın altına ve yapılmış işin altına inmez.
## Olay çipi de bunu gösterir, yazılan ile görünen aynıdır; bekleyen karar yoksa istenen puan.
static func effort_change(amount: int) -> int:
	var c: Dictionary = decision_card()
	return amount if c.is_empty() else maxi(amount,
		maxi(int(SprintCatalog.cfg("paper.min_points")), ceili(_worked(c) - EPS)) - roundi(total(c)))


## Bekleyen kararın kartına ± puan ilerleme: artı sıradaki fazlardan dolar, eksi son fazdan geri alır.
static func decision_progress(amount: int) -> String:
	var c: Dictionary = decision_card()
	if c.is_empty():
		return ""
	if amount >= 0:
		_work(c, {"id": "", "fits": SprintCatalog.cfg("roles." + String(c.kind)), "ahead": false}, float(amount))
	else:
		var left: float = -amount
		for i in range(TEST_PHASE, -1, -1):
			var take: float = minf(left, float(c.progress[i]))
			c.progress[i] = float(c.progress[i]) - take
			left -= take
	_changed()
	return c.id


## Bekleyen kararın kartında yapılmış iş, puan olarak (yola dönmek bunu siler); karar yoksa 0.
static func decision_done() -> int:
	var c: Dictionary = decision_card()
	return 0 if c.is_empty() else roundi(_worked(c))


## Hattın bir kartı ilk sürümle çıktı mı: v1.0'a kadarki sprintler (sürüm numarası 0) ve v1.0'ın kendisi.
static func line_in_first_version(line: String) -> bool:
	return _p().get("releases", []).any(func(r: Dictionary) -> bool:
		return int(r.number) <= 1 and r.shipped.any(func(c: Dictionary) -> bool: return c.line == line))


## Bekleyen kararın kartı ilerlemesiyle sonraki sprinte devreder; sprint kapandıysa zaten oradadır.
## Koşan sprintte boştakiler haftanın kalanında kimsesiz kartlara geçer.
static func decision_carry() -> String:
	var c: Dictionary = decision_card()
	if c.is_empty():
		return ""
	var p: Dictionary = _p()
	if c.id in p.sprint.cards:
		p.sprint.cards.erase(c.id)
		p.next.cards.push_front(c.id)
		# Sürüm notu onu devredenlerde, bu sprintteki işini hızda sayar.
		p.sprint.carried_out = p.sprint.get("carried_out", []) + [c.id]
		c.state = "carried"
		c.assignees = []
		EventBus.card_carried_over.emit(c.id)
		if mode() == "active":
			_restaff()
		_changed()
	return c.id


## Bekleyen kararın kartından `share` payı (kartın eforunun, yukarı yuvarlanır) çıksa kaç puan çıkar: yapılmış işin ve
## `paper.min_points` puanın altına inilmez (effort_change).
static func trim_points(share: float) -> int:
	var c: Dictionary = decision_card()
	return 0 if c.is_empty() else -effort_change(-ceili(share * total(c) - EPS))


## Kâğıdın karttan iş almasının bedeli (`sprint_card_trim`): {of (card_ref), share, cut (karttan çıkan puan), work (sonraki
## sprinte kalan puan: çıkan, kartın hiç almadığı `extra` ve yeniden açma payı; `follow` yoksa 0), bugs, line}. `share`
## doğruysa `cut` kartın sprint.json `paper.trim_share` payıdır. Çip, geçmiş satırı ve uygulama bunu okur.
static func trim_plan(share: bool, extra: int, follow: bool, bugs: int, line: String) -> Dictionary:
	var cut: int = trim_points(float(SprintCatalog.cfg("paper.trim_share"))) if share else 0
	return {"of": card_ref(decision_card()), "share": share, "cut": cut, "bugs": bugs, "line": line,
		"work": cut + extra + int(SprintCatalog.cfg("paper.reopen_points")) if follow else 0}


## `trim_plan`ın uygulanması: kart `cut` puan hafifler, `work` puanlık iş sonraki sprintin kartı olarak girer, `bugs` hata kart
## çıkınca `line` hattında açık hata olur (`leaks`, kapanışta `pending_faulty`'ye); kartın kimliği, karar yoksa "".
static func decision_trim(plan: Dictionary) -> String:
	var c: Dictionary = decision_card()
	if c.is_empty():
		return ""
	_scale_need(c, -float(plan.cut))
	if int(plan.work) > 0:
		_place(_follow_card(c, int(plan.work)), false)
	if int(plan.bugs) > 0:
		var leaks: Dictionary = c.get("leaks", {})
		leaks[plan.line] = int(leaks.get(plan.line, 0)) + int(plan.bugs)
		c.leaks = leaks
	_changed()
	return c.id


## Kartın kademesini yapan takip kartı: özellik kartıdır, istek bağı ve lisans bedeli yoktur (kademenin lisansı ilk kartta
## ödenir); `plan_next` kademesi tutulmuş kartı siler, bunu silmez.
static func _follow_card(c: Dictionary, work: int) -> Dictionary:
	var follow: Dictionary = SprintCatalog.new_card("follow:%s:%d" % [c.id, sprint_number()], "feature", c.area, work,
		c.line, c.step, c.target_tier)
	follow.merge({"follow": true, "paid": true, "base": 0.0})
	return follow


## Bekleyen kararın kartı sprintin başına girse hangi kart sprintten kayardı (`first_bumps`), yoksa {}.
static func decision_first_bumps() -> Dictionary:
	var c: Dictionary = decision_card()
	return {} if c.is_empty() else first_bumps(c)


## "Kartı başa al": bekleyen kararın kartı sprintin başına girer (`put_first`) ve kâğıt cevaplanınca hemen çalışır.
static func decision_first() -> String:
	var c: Dictionary = decision_card()
	if c.is_empty():
		return ""
	c.decision = false
	put_first(c)
	return c.id


## Bekleyen kararın kartı sprintin başına girse bu sprintte biter mi (kalan haftalar bugünkü ekiple oynanır); sprintte
## olmayan kart için yanlış.
static func decision_first_finishes() -> bool:
	var id: String = decision_card().get("id", "")
	if not _in_sprint(id):
		return false
	var cards: Array = _played_copies()
	var lead: Dictionary = cards.filter(func(c: Dictionary) -> bool: return c.id == id)[0]
	var rest: Array = cards.filter(func(c: Dictionary) -> bool: return c.id != id)
	return bool(_outcome([lead] + rest, weeks_left(), true, team()).cards[id].finishes)


## "Kartı başa al" kartı yenilemeden önce çıkarır: kart ekibin hızıyla bu sprintte yetişmiyor, isteyen hesabın yenilemesi
## bu sprintin kapanışından sonra ve sonraki kapanıştan önce (`SprintBridges.next_renewal_day`) ve kart başa girince bu
## sprintte biter.
static func decision_renewal_saved() -> bool:
	var c: Dictionary = decision_card()
	var account: Customer = CustomerRegistry.get_customer(String(c.get("customer_id", "")))
	if account == null or not card_late(c.id):
		return false
	var renewal: int = SprintBridges.next_renewal_day(account)
	var close: int = GameState.day + weeks_left()
	return renewal >= close and renewal < close + sprint_weeks() and decision_first_finishes()


## Bekleyen kararın kartı hâlâ tasarımda ve bu haftanın işiyle de tasarımı bitmiyor, ekipte onu bekleyen bir yazılımcı var.
static func design_late(id: String) -> bool:
	if not _in_sprint(id) or phase(_p().cards[id]) != 0:
		return false
	var cards: Array = _played_copies()
	_play_out(cards, 1, team())
	return cards.any(func(c: Dictionary) -> bool: return c.id == id and phase(c) == 0) and team().any(
		func(t: Dictionary) -> bool: return not t.founder and CharacterRegistry.get_character(t.id).role == HRConstants.ROLE_DEVELOPER)


## Bekleyen kararın kartının kalan test işinin yarısı (yukarı yuvarlanır): testi kısaltmanın karttan aldığı, bir yazılımcı
## teste yardım ederse onun yaptığı iş; test aşamasında olmayan kart için 0.
static func decision_test_half() -> int:
	var c: Dictionary = decision_card()
	if c.is_empty() or phase(c) != TEST_PHASE:
		return 0
	return ceili((float(c.need[TEST_PHASE]) - float(c.progress[TEST_PHASE])) / 2.0)


## Koşan sprintin çalışma saati çarpanı (fazla mesai kararı) sprint sonuna kadar. Döndürdüğü
## sprint; sprint yoksa 0.
static func set_hours_mult(mult: float) -> int:
	if mode() != "active":
		return 0
	_p().sprint.hours_mult = hours_after(mult)
	_changed()
	return sprint_number()


## Kararla sprintin varacağı çalışma saati çarpanı: ikinci karar birincinin üstüne çarpılır,
## sprint.json'daki aralıkta kalır. Olay çipi de bunu gösterir, yazılan ile görünen aynıdır;
## sprint koşmuyorsa istenen çarpan.
static func hours_after(mult: float) -> float:
	if mode() != "active":
		return mult
	return clampf(float(_p().sprint.get("hours_mult", 1.0)) * mult, float(SprintCatalog.cfg("hours_mult.min")),
		float(SprintCatalog.cfg("hours_mult.max")))


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


## Çeyreğin hedefi: bir alan, `SprintCatalog.GOAL_BUGS` ya da "" (hedef yok). PM'siz de seçilir. Liderin önerisi hedefe bakar:
## yeniden okunur.
static func pick_goal(area_id: String) -> void:
	_p().quarter.goal_area = area_id
	_p().sprint.lead_applied = false
	_changed()


## Bu sprint bir olayla kesildi (`kind`: "incident", "promise" ya da kâğıt için "paper"): kayıt sprinti ve türü tutar,
## son kesinti kalır; eski kayıtta alan yoktur. Sprintin kesinti sırası: söz ya da acil durum gelen sprintte kâğıt gelmez,
## kâğıt gelen sprintte yalnız servis kesintisi gelebilir.
static func record_interrupt(kind: String) -> void:
	_p()["interrupt"] = {"sprint": sprint_number(), "kind": kind}


# --- Okumalar --------------------------------------------------------------------------

static func is_typed() -> bool:
	return GameState.product.has("sprint")


static func mode() -> String:
	return String(GameState.product.get("mode", "plan"))


## Sprint oyuncunun planını bekler: MVP kapısında her zaman; planlamada ve sürüm notunda ekip ve
## planlanacak kart (sprintte ya da sonraki sütunda kapısı açık kart, ya da açık aday) varken, devir
## yoksa. Bekleyen sprint saati tutar.
static func awaits_plan() -> bool:
	if not is_typed() or mode() == "active":
		return false
	var p: Dictionary = _p()
	if p.release.get("gate", false):
		return true
	return capacity() > 0 and not delegated() and ((p.sprint.cards + p.next.cards).any(func(id: String) -> bool:
		return SprintCatalog.gate_reason(p.cards[id].step) == "") or not SprintCatalog.open_cards([]).is_empty())


## Planlama PM'e devredilmiş ve çeyreği planlayan PM işbaşında. İzindeki ya da eğitimdeki PM'de devir işlemez,
## bayrak kalır ve PM dönünce devir geri gelir; son PM ayrılınca bayrak silinir (`_on_team_changed`) ve plan oyuncuyu bekler.
static func delegated() -> bool:
	return bool(_p().get("delegate", false)) and SprintCatalog.quarter_pm() != null


static func sprint_number() -> int:
	return int(GameState.product.get("sprint", {}).get("number", 0))


## Son kapanan sprint: sürüm notundayken kapanan sprint henüz numarayı taşır.
static func last_closed() -> int:
	return sprint_number() - (0 if mode() == "release" else 1)


## Oyuncunun kart koyabileceği ilk sprint: planlamadaki sprint, yoksa sıradaki (koşanın kartları
## kilitli). Talebin ve sözün son tarihi bundan sayılır.
static func plannable_sprint() -> int:
	return sprint_number() + (0 if mode() == "plan" else 1)


## Sprintin süresi (hafta): hep sprint.json `sprint_weeks`.
static func sprint_weeks() -> int:
	return int(SprintCatalog.cfg("sprint_weeks"))


## Haftayla sayılan süre kaç sprint eder: talep ve söz son tarihi, çeyrek, rakip penceresi ve araştırma cümlesi
## hafta sayar ve sprint sırasıyla okunur.
static func sprints_in(weeks: int) -> int:
	return int(float(weeks) / sprint_weeks())


## Koşan sprintin haftası (1..süre); başka kipte 0.
static func week() -> int:
	return GameState.day - int(_p().sprint.start_day) + 1 if mode() == "active" else 0


## Koşan sprintin bu hafta dahil kalan haftaları; başka kipte bütün sprint.
static func weeks_left() -> int:
	return sprint_weeks() - maxi(week(), 1) + 1


## Ekibin sprint boyunca puanı.
static func capacity() -> float:
	return capacity_of(team())


## `people` satırlarının (`team`) sprint boyunca puanı.
static func capacity_of(people: Array) -> float:
	return people.reduce(func(sum: float, t: Dictionary) -> float: return sum + t.points, 0.0) * sprint_weeks()


## Sprintteki kartların yükü; kapasite çubuğunun dilimleri kart yükleridir. Puanlar tamdır,
## yalnız gösterim yuvarlar.
static func used() -> float:
	var load: float = 0.0
	for card in _sprint_cards():
		load += card_load(card)
	return load


## Kartın sprintteki yükü kalan puanıdır; sprint içinde bu sprintte yapılan iş de yüke sayılır.
## Böylece başlatma çubuğu değiştirmez, kararın efor değişikliği yüke girer.
static func card_load(c: Dictionary) -> float:
	return remaining(c) + (_worked(c) - float(c.base) if mode() == "active" else 0.0)


## Kartın kalan puanı: fazların ihtiyacından eksik kalan iş. Karar eforu düşürdüyse bir fazın fazlası
## öbürüne sayılmaz; devreden kartın biten puanı eforundan bunu çıkarır.
static func remaining(c: Dictionary) -> float:
	var left: float = 0.0
	for i in PHASE_DONE:
		left += maxf(0.0, float(c.need[i]) - float(c.progress[i]))
	return left


## Saklanan kartların kalan puanı.
static func points_left(ids: Array) -> float:
	var load: float = 0.0
	for id in ids:
		load += remaining(_p().cards[id])
	return load


## Kartın geliştirmeye hazır payı (0..1): ilk fazının (tasarım) biten oranı. Önden hazırlanmayan kartta -1:
## araştırmanın geliştirmesi, düzeltmenin tasarımı yoktur.
static func ready_share(c: Dictionary) -> float:
	if float(c.need[0]) <= 0.0 or float(c.need[1]) <= 0.0:
		return -1.0
	return 1.0 if phase(c) > 0 else float(c.progress[0]) / float(c.need[0])


## Bu sprintte bitirilen puan (yarım kalan ve kararla erken devreden işler dahil).
static func done_points() -> float:
	if mode() != "active":
		return 0.0
	var done: float = 0.0
	for card in _sprint_cards() + _carried_out():
		done += _worked(card) - float(card.base)
	return done


## Ekibin haftalık sprint puanı; mesai modali taslağın saatleriyle sorar (WorkHoursSystem.draft_state
## biçimi), boş taslak bugünkü saatlerdir. Koşan sprintin mesai kararı çarpanı sayılmaz: saat ayarı
## sprintten uzun yaşar.
static func week_points(draft: Dictionary = {}) -> float:
	var points: float = 0.0
	for person in team():
		var c: Character = CharacterRegistry.get_character(person.id)
		points += _points(c, WorkHoursSystem.hours_for(c) if draft.is_empty() else WorkHoursSystem.hours_in(draft, c))
	return points


## Bu sprintte çalışabilecekler: Görevler matrisinde Yapım ya da Test işini tutan aktif kişiler, kurucu
## dahil (`founder_in_sprint` açıkken ve haftanın donmuş payı 0'dan büyükken). {id, name, points (haftalık, sprint
## payıyla; PM'inki 0), prep (PM'in haftalık hazırlık puanı, öbürlerinin 0), share (sprint payı), fits (uyduğu roller),
## founder, ahead (ürün ve tasarım rolü: geliştirme ve teste uymaz, yalnız ilk fazda çalışır ve önden gider)}.
static func team() -> Array:
	var people: Array[Character] = CharacterRegistry.get_active_employees()
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null and founder.status == HRConstants.STATUS_ACTIVE and GameState.founder_in_sprint \
			and GameState.founder_sprint_pay > 0.0:
		people.push_front(founder)
	var hours: float = float(_p().sprint.get("hours_mult", 1.0)) if mode() == "active" else 1.0
	var out: Array = []
	for c in people:
		var share: float = _share(c)
		if share == 0.0:
			continue
		var fits: Array = _fits(c)
		out.append({"id": c.id, "name": c.character_name, "points": _points(c, WorkHoursSystem.hours_for(c)) * hours,
			"prep": SprintPrep.rate(c, WorkHoursSystem.hours_for(c)) * hours,
			"share": share, "fits": fits, "founder": c.category == "founder",
			"ahead": not (fits.has("dev") or fits.has("test"))})
	return out


## `team()`in dışında kalan ve nedeni olan kişiler [{id, reason}]: çalışanlar "training" ve "leave" (durum, Ar-Ge'den önce
## okunur) ya da "research" (Ar-Ge işini tutan); kurucu yalnız anahtarı açıkken ve payını toplantılar bitirmişse "meetings".
## Yalnız Destek'te çalışan ya da işsiz kişi sprint dışıdır ama nedeni yoktur, listede değildir.
static func away() -> Array:
	var out: Array = []
	for c in CharacterRegistry.get_employees():
		var reason := ""
		match c.status:
			HRConstants.STATUS_TRAINING:
				reason = "training"
			HRConstants.STATUS_ON_LEAVE:
				reason = "leave"
			_:
				if c.assigned_job_ids.has(HRConstants.JOB_RESEARCH):
					reason = "research"
		if reason != "":
			out.append({"id": c.id, "reason": reason})
	if GameState.founder_in_sprint and GameState.founder_sprint_pay == 0.0:
		out.append({"id": CharacterRegistry.get_founder().id, "reason": "meetings"})
	return out


## Bir olayın düzeltmesinin moral bedelini ödeyenler (kimlik, sprint payı çoktan aza, eşitse ad). Kurucu ödemez:
## onun yolu "Kendin düzelt". Önce koşan sprintte `line` hattının kartlarına atanmış geliştirici ve testçiler ile o
## kartları hazırlayan PM'ler; hiçbiri yoksa ya da hat yoksa Görevler matrisinde Yapım ya da Test işini tutan herkes.
## İkisi de boşsa [] döner ve bedeli ödeyecek seçenek kilitli kalır.
static func payers(line: String) -> Array:
	var crew: Array = team().filter(func(t: Dictionary) -> bool: return not t.founder)
	var carded: Array = []
	if line != "":
		var on_line: Array = []
		var prepared: Array = []
		for c in _sprint_cards():
			if c.line == line:
				on_line.append_array(c.assignees)
				prepared.append(c.get("prep_by", ""))
		carded = crew.filter(func(t: Dictionary) -> bool: return (t.id in on_line and not t.ahead) or t.id in prepared)
	var paying: Array = carded if not carded.is_empty() else crew
	paying.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a.share > b.share if a.share != b.share else a.name < b.name)
	return paying.map(func(t: Dictionary) -> String: return t.id)


## "+" yalnız planlamada ve kapasite varken açıktır, sonra sprint kartı alıyor mu (`intake`). Kart verilmezse
## sorulan, boş puanın kalıp kalmadığıdır.
static func can_add(card_id := "") -> bool:
	return mode() == "plan" and capacity() > 0 and intake(starting(),
		SprintCatalog.card_by_id(card_id) if card_id != "" else {}, team()).takes


## Alım sınaması, bütün alıcıların tek kuralı ("+", liderin önerisi, MVP tahmini): `card` sprintin uygulanan yerleşiminin
## (`cards`, sırasıyla) sonuna eklenir ve sprintin haftaları `people` ile kopyalarda oynanır. Boş sprint her kartı alır
## (yoksa tek kurucu büyük kartı hiç alamazdı); dolu sprintte eklendikten sonra yük ekibin kapasitesinin %125'ini
## (`cap_ceiling`) aşmamalı ve kart bu sprintte puan almalı; bitmeyecek kart devreder. `card` boşsa sorulan oynatmada
## boş puanın kalıp kalmadığıdır. {takes, cards: oynatmanın kart başına sonucu (`_outcome`)}; yük tavanı aşıldıysa
## oynatılmaz ve `cards` boştur.
static func intake(cards: Array, card: Dictionary, people: Array) -> Dictionary:
	var load: float = cards.reduce(func(sum: float, c: Dictionary) -> float: return sum + remaining(c), 0.0)
	var cap: float = capacity_of(people)
	if load > EPS and load + (0.0 if card.is_empty() else remaining(card)) > cap * float(SprintCatalog.cfg("cap_ceiling")):
		return {"takes": false, "cards": {}}
	var played: Dictionary = _outcome(cards if card.is_empty() else cards + [card], sprint_weeks(), false, people)
	var got: float = played.spare if card.is_empty() else played.cards[card.id].done
	return {"takes": load <= EPS or got > EPS, "cards": played.cards}


## `cards` bu sprintin haftalarında `people` ekibiyle oynanınca sonraki sprinte kalan iş: `intake` ile aynı oynatma, kapanışın
## devredeceği iş, zaman ekseninin `out`u (hazırlık kazancına bölünmüş).
static func carried_points(cards: Array, people: Array) -> float:
	return _replay(cards, sprint_weeks(), false, people).cards.reduce(
		func(sum: float, c: Dictionary) -> float: return sum + remaining(c) / (1.0 + float(c.get("prep_gain", 0.0))), 0.0)


## Düzeltme pay tavanı: sistemin kendiliğinden aldığı düzeltme işi, uygulanan yerleşimin (`cards`) düzeltme işiyle birlikte,
## ekibin kapasitesinin `lead.fix_share`'ini aşmaz; yerleşimde düzeltme işi yoksa ilk düzeltme kartı girer. "+" bu tavana
## tabi değildir, oyuncu kendisi seçer. Düzeltme olmayan kart her zaman geçer.
static func fix_share_takes(cards: Array, card: Dictionary, people: Array) -> bool:
	if card.kind != "fix":
		return true
	var work: float = cards.reduce(func(sum: float, c: Dictionary) -> float:
		return sum + (remaining(c) if c.kind == "fix" else 0.0), 0.0)
	return work <= EPS or work + remaining(card) <= capacity_of(people) * float(SprintCatalog.cfg("lead.fix_share"))


## Başlatmak ekip ve başlayacak en az bir kart ister.
static func can_start() -> bool:
	return mode() == "plan" and capacity() > 0 and not starting().is_empty()


## Sprintin başlatmada kalacak kartları: başlatma (`_begin`), plan oynatması ve alım sınaması aynı yerleşimi okur.
static func starting() -> Array:
	return _sprint_cards().filter(_starts)


## Planın oynatması: sprintin başlayacak kartları (`starting`) sırasıyla bugünkü ekiple, sprintin kalan haftalarında
## kopyalarda oynanır; sonraki sütunun kartları önden hazırlanır. Kapısı kapanmış kart başlamaz: puan almaz, devretmez
## sayılır. Plan ekranı ve prob aynı oynatmayı okur. {cards: {kart: {split: [{id, name, weeks}], done, finishes, bugs}},
## spare, ready}: done kartın bu sprintte alacağı puan (testin eklediği düzeltme işi dahil), bugs testi bu sprintte biten
## kartın [n, F, K, düzeltme işi] (SprintBugs.tally, kartın tohumlu zarı; yoksa []), spare sprintin hiçbir kartına gitmeyen
## puan, ready sonraki sütunun kartlarının sprint sonundaki hazır payı (ready_share).
static func plan_outcome() -> Dictionary:
	return _planned(_replay(starting(), weeks_left(), true, team()))


## Ekranın zaman ekseni (`SprintTimeline`): planlamada planın (sonuna eklenen `extra` aday kartlarla birlikte) oynatması, koşan
## sprintte bu haftanın ataması korunarak haftanın başından oynanan kalan sprint; oynatma tek ve günlüğe yazılır.
## Planlamada `outcome`, aynı oynatmanın `plan_outcome` biçimindeki sonucudur (başka kipte null): ekran ikisini birden okur,
## plan iki kez oynanmaz. Sürüm notunda eksendeki kart yoktur.
static func timeline(extra: Array = []) -> Dictionary:
	var people: Array = team()
	var log: Array = []
	var running: bool = mode() == "active"
	var run: Dictionary
	if running:
		run = {"from": _sprint_cards(), "ahead_from": _ahead_cards()}
		run.cards = _copies(run.from)
		run.ahead = _copies(run.ahead_from)
		_finish_sprint(run.cards, people, run.ahead, log)
	else:
		run = _replay(starting() + extra, weeks_left(), true, people, log)
	var out: Dictionary = SprintTimeline.build(run, log, people, maxi(week() - 1, 0), running)
	out["outcome"] = _planned(run) if mode() == "plan" else null
	return out


## Sonraki sütunun önden hazırlanan kartlarının, sprintin `weeks` haftası daha geçince varacağı hazırlık kazancı {kart: g}: PM'ler
## kopyalarda o haftaları hazırlar. Hazırlık kartın yapılan işinden bağımsızdır, bu yüzden kartlar oynanmaz; zaman ekseninin
## kapanışına dek sayılan haftalarda eksenin oynatmasının kazancıdır (sprint kapanınca hazırlık durur).
static func prep_gains(weeks: int) -> Dictionary:
	var ahead: Array = _copies(_ahead_cards())
	var people: Array = team()
	for w in weeks:
		SprintPrep.week(ahead, people, weeks_left() - w - 1)
	var out: Dictionary = {}
	for c in ahead:
		out[c.id] = float(c.get("prep_gain", 0.0))
	return out


## `run`ın (`_replay`) plan ekranı biçimi: sprintin başlamayan kartı puan almaz, bitmez sayılır.
static func _planned(run: Dictionary) -> Dictionary:
	var out: Dictionary = _read(run)
	for c in _sprint_cards():
		if not out.cards.has(c.id):
			out.cards[c.id] = {"split": [], "done": 0.0, "finishes": false, "bugs": []}
	return out


## Verilen kartların oynatmasının kart başına sonucu (`_read`).
static func _outcome(cards: Array, weeks: int, with_ahead: bool, people: Array) -> Dictionary:
	return _read(_replay(cards, weeks, with_ahead, people))


## Kartlar kopyalarda `weeks` hafta, `people` ekibiyle oynanır; `with_ahead` sonraki sütunun önden hazırlanan kartlarını da
## oynatır. `log` verilirse oynatma oraya yazılır (`_work`). {from (verilen kartlar), cards ve ahead (oynanmış kopyalar),
## ahead_from (sonraki sütunun gerçek kartları), before (kartların oynatmadan önce biten işi), split, spare}.
static func _replay(cards: Array, weeks: int, with_ahead: bool, people: Array, log = null) -> Dictionary:
	var played_cards: Array = _copies(cards)
	var ahead_from: Array = _ahead_cards() if with_ahead else []
	var ahead: Array = _copies(ahead_from)
	var before: Array = played_cards.map(_made)
	var played: Dictionary = _play_out(played_cards, weeks, people, ahead, log)
	return {"from": cards, "cards": played_cards, "ahead": ahead, "ahead_from": ahead_from, "before": before,
		"split": played.split, "spare": played.spare}


## `_replay` oynatmasının kart başına sonucu (`plan_outcome`un gövdesi).
static func _read(run: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for i in run.cards.size():
		var c: Dictionary = run.cards[i]
		out[c.id] = {"split": (run.split.get(c.id, {}) as Dictionary).values(), "done": _made(c) - run.before[i],
			"finishes": phase(c) == PHASE_DONE, "bugs": SprintBugs.tally(c)}
	var ready: Dictionary = {}
	for c in run.ahead:
		ready[c.id] = ready_share(c)
	return {"cards": out, "spare": run.spare, "ready": ready}


## Kartın biten işi: kalanın azalması değil biten işin artışı, çünkü testin bulduğu hata kalana düzeltme işi ekler.
static func _made(c: Dictionary) -> float:
	return total(c) - remaining(c)


static func _copies(cards: Array) -> Array:
	return cards.map(func(c: Dictionary) -> Dictionary: return c.duplicate(true))


## MVP tahmini: Çekirdek'in kalan K1'leri hangi sprintin kapanışında yayına girer. Oyuncu sprinti dolu
## tutar ve açıldığı gün başlatır: kopyalarda bu sprintin kartları, sonraki sütun, sonra Çekirdek'in açık
## K1 adayları efor sırasıyla; koşan sprintin kartları kilitlidir, öbür sprintlere sıradaki kartlar alım sınamasını
## (`intake`) geçtikçe girer, bitmeyen devreder; kartlarının hepsi biten sprint o hafta kapanır. Hafta hafta
## bugünkü ekiple oynanır, koşan sprintin mesai çarpanı sonraki sprintlere geçmez; karar bekleyen kart
## beklemiyormuş gibi. {sprint, week (kapanış tikinden bir önceki hafta)}; canlıda, ekip yokken ya da
## MVP_HORIZON haftada bitmiyorsa {}.
static func mvp_eta() -> Dictionary:
	if ProductState.is_live() or capacity() <= 0:
		return {}
	var p: Dictionary = _p()
	var weeks: int = sprint_weeks()
	var k1 := func(c: Dictionary) -> bool: return c.area == "core" and int(c.target_tier) == 1
	var queue: Array = (_sprint_cards() + p.next.cards.map(func(id: String) -> Dictionary: return p.cards[id])
		+ SprintCatalog.mvp_candidates()).map(
		func(c: Dictionary) -> Dictionary: return c.duplicate(true).merged({"decision": false}, true))
	var all: Array = queue.duplicate()
	var locked: bool = mode() == "active"
	var cards: Array = queue.slice(0, p.sprint.cards.size()) if locked else []
	queue = queue.slice(cards.size())
	var people: Array = team()
	var hours: float = float(p.sprint.get("hours_mult", 1.0)) if locked else 1.0
	var plain: Array = people.map(func(t: Dictionary) -> Dictionary: return t.merged({"points": t.points / hours}, true))
	var number: int = sprint_number() + int(mode() == "release")
	var left: int = weeks_left()
	var close: int = GameState.day + left
	var need: int = SprintCatalog.mvp_cards_left()
	if need <= 0:
		return {"sprint": number, "week": close - 1}
	for _w in MVP_HORIZON:
		if not locked:
			while not queue.is_empty() and intake(cards, queue[0], plain).takes:
				cards.append(queue.pop_front())
			locked = true
		_play_out(cards, 1, people, [], null, GameState.day + _w)
		left -= 1
		var shut: bool = left == 0 or _finished(cards)
		if all.filter(func(c: Dictionary) -> bool: return k1.call(c) and phase(c) == PHASE_DONE).size() >= need:
			return {"sprint": number, "week": close - (left if shut else 0) - 1}
		if shut:
			cards = cards.filter(func(c: Dictionary) -> bool: return phase(c) < PHASE_DONE)
			number += 1
			close += weeks - left
			left = weeks
			locked = false
			people = plain
	return {}


## Kart bu sprintte yetişmez mi: kalan haftalar bugünkü ekiple oynanır, kartlar karar beklemiyormuş gibi.
## Sprintte olmayan kart için yanlış.
static func card_late(id: String) -> bool:
	return _in_sprint(id) and id in _unfinished()


## Kart, eforu `extra` puan değişse (eksi: azalsa) bu sprintte yetişmez mi (kalan haftalar bugünkü ekiple oynanır, kartlar
## karar beklemiyormuş gibi); sprintte olmayan kart için yanlış.
static func late_with(id: String, extra: int) -> bool:
	return _in_sprint(id) and id in _unfinished(id, extra)


## Kart, eforu `extra` puan değişse bu sprintte biter mi; sprintte olmayan kart için yanlış.
static func finishes_with(id: String, extra: int) -> bool:
	return _in_sprint(id) and id not in _unfinished(id, extra)


## Fazla mesai kartı bu sprintte bitirir mi (sprint_hours'un varacağı çarpanla); sprintte olmayan kart için yanlış.
## Karar bekleyen kart haftanın işine girmemiştir; cevap gelince haftanın ataması baştan yapılır (_clear_decision), bu yüzden
## kalan haftalar baştan atanarak oynanır (_play_out). Atanmış kartı kendi çalışanları yetiştirir (_finish_sprint).
## `sends`: söz olayının seçeneği kartı gönderir (`send`), testi biten kart da sayılır.
static func crunch_finishes(id: String, sends := false) -> bool:
	if not _in_sprint(id):
		return false
	var scale: float = hours_after(CRUNCH_MULT) / float(_p().sprint.get("hours_mult", 1.0))
	var people: Array = team().map(func(t: Dictionary) -> Dictionary: return t.merged({"points": t.points * scale}, true))
	var cards: Array = _played_copies()
	if decision_card().get("id", "") == id:
		_play_out(cards, weeks_left(), people)
	else:
		_finish_sprint(cards, people)
	return _ends(cards, id, sends)


## Testi kısaltmak test aşamasındaki kartı bu sprintte bitirir mi (`sends`: crunch_finishes'taki gibi).
static func cut_test_finishes(id: String, sends := false) -> bool:
	if not _in_sprint(id) or phase(_p().cards[id]) != TEST_PHASE:
		return false
	var cards: Array = _played_copies()
	for c in cards:
		if c.id == id:
			_halve_test(c)
	_finish_sprint(cards, team())
	return _ends(cards, id, sends)


## Oynatılmış kopyalarda `id` kartı sprinti bitirmiş mi; `sends` ise testi bitmiş kart da bitmiş sayılır.
static func _ends(cards: Array, id: String, sends: bool) -> bool:
	return cards.any(func(c: Dictionary) -> bool:
		return c.id == id and (phase(c) == PHASE_DONE or (sends and bool(c.get("tested", false)))))


## Sprintin kartlarının kopyaları, karar beklemiyormuş gibi.
static func _played_copies() -> Array:
	return _sprint_cards().map(func(c: Dictionary) -> Dictionary: return c.duplicate(true).merged({"decision": false}, true))


## Sprintin kartlarından kalan haftalarda bugünkü ekiple bitmeyenlerin kimlikleri; `id` kartının eforu `extra` puan
## değişmiş gibi.
static func _unfinished(id := "", extra := 0) -> Array:
	var cards: Array = _played_copies()
	for c in cards:
		if c.id == id:
			_scale_need(c, extra)
	_play_out(cards, weeks_left(), team())
	return cards.filter(func(c: Dictionary) -> bool: return phase(c) < PHASE_DONE).map(
		func(c: Dictionary) -> String: return c.id)


## Kopya kartlar `people` ekibiyle sprintin sonuna oynanır: içinde bulunulan hafta _end_week gibi, atamasını koruyarak
## (mesai ya da kısalan test bu haftanın işini hızlandırır, kimse yer değiştirmez), kalan haftalar yeniden atanarak.
## `ahead` verilirse sonraki sütunun kopyaları da oynanır (önce sprintin kartları, sonra onlar; PM'ler hazırlar) ve kartların
## hepsi bu hafta biterse sprint kapanır, sonrasında önden gidilmez. `log` `_play_out`taki gibi doldurulur.
static func _finish_sprint(cards: Array, people: Array, ahead: Array = [], log = null) -> void:
	var by_id: Dictionary = {}
	for person in people:
		by_id[person.id] = person
	var week: Dictionary = {"cards": [], "ahead": []} if log != null else {}
	if log != null:
		log.append(week)
	var budget: Dictionary = {}
	for c in cards:
		for id in c.assignees:
			if by_id.has(id):
				budget[id] = _work(c, by_id[id], budget.get(id, by_id[id].points), week.get("cards"))
	for c in ahead:
		for id in c.assignees:
			if by_id.has(id):
				budget[id] = _work(c, by_id[id], budget.get(id, by_id[id].points), week.get("ahead"))
	SprintPrep.week(ahead, people, weeks_left() - 1)
	_play_out(cards, weeks_left() - 1, people, [] if _finished(cards) else ahead, log, GameState.day + 1)


static func _in_sprint(id: String) -> bool:
	return mode() == "active" and id in _p().sprint.cards


## Kartın kalan test işi yarıya iner (ihtiyacından düşer; biten iş ve öbür aşamalar değişmez); düşen iş `cut`ta kalır,
## yakalama gereken testin yapılan payı kadardır (SprintBugs.catch_rate).
static func _halve_test(c: Dictionary) -> void:
	var half: float = (float(c.need[TEST_PHASE]) - float(c.progress[TEST_PHASE])) / 2.0
	c.need[TEST_PHASE] = float(c.need[TEST_PHASE]) - half
	c.cut = float(c.get("cut", 0.0)) + half


## "Testi kısalt": söz olayının ya da karar kâğıdının kartının testi kısalır; kartın kimliği, kart yoksa "".
static func cut_test(c: Dictionary) -> String:
	if c.is_empty():
		return ""
	_halve_test(c)
	_changed()
	return c.id


## Söz olayının seçeneği (testi kısalt, fazla mesai) kartı gönderir: testi bitmişse düzeltmesi bitmese de sprint
## kapanışında sürüme girer, düzeltilmemiş bulunan hata kartın hattında açık hata olur (SprintBugs.sent).
static func send(c: Dictionary) -> void:
	if not c.is_empty():
		c.send = true


# --- Söz olayı -------------------------------------------------------------------------

## Sprintin son haftasında, bu sprinte söz verilmiş (açık, `due_sprint` bu sprint) bir kademenin hiçbir kartı ekibin
## hızıyla yetişmiyorsa {card (ilk kart), promises (o kademeye verilmiş açık sözler), account (sözlerin en büyük
## hesabı)}; birden çok kademe yetişmiyorsa sözü en büyük hesaba verilmiş olan. Yoksa {}.
static func late_promise() -> Dictionary:
	if mode() != "active" or week() < sprint_weeks():
		return {}
	var open: Array = PromiseRegistry.get_all().filter(func(p: Promise) -> bool:
		return p.status == "open" and p.due_sprint == sprint_number())
	if open.is_empty():
		return {}
	var late: Array = _unfinished()
	var found: Dictionary = {}
	for c in _sprint_cards():
		var owed: Array = open.filter(func(p: Promise) -> bool: return p.feature_id == c.step)
		if owed.is_empty() or _sprint_cards().any(
				func(other: Dictionary) -> bool: return other.step == c.step and other.id not in late):
			continue
		var accounts: Array = owed.map(func(p: Promise) -> Customer: return CustomerRegistry.get_customer(p.customer_id))
		accounts.sort_custom(SprintCatalog.larger_account)
		if found.is_empty() or SprintCatalog.larger_account(accounts[0], found.account):
			found = {"card": c, "promises": owed, "account": accounts[0]}
	return found


## Söz olayı: kart yetişmiyorsa `product.promise_due` istenir, sprintin tek kesintisi sayılır. Konuşan kartta çalışan
## ilk çalışandır (atama sırası aşama sırasıdır); çalışan yoksa (kurucu ya da kimse) kurucunun notudur. Kayıt, kartın
## koşulları ve metni okusun diye istekten önce yazılır; motor reddederse silinir.
static func _ask_promise() -> void:
	var due: Dictionary = late_promise()
	if due.is_empty():
		return
	var card: Dictionary = due.card
	_p()["promise_due"] = {"card": card.id, "step": card.step,
		"promises": due.promises.map(func(p: Promise) -> String: return p.id)}
	var given: Dictionary = {"customer": due.account.id}
	var crew: Array = promise_crew()
	if not crew.is_empty():
		given["employee"] = crew[0]
	if EventGate.request("product.promise_due", given):
		record_interrupt("promise")
	else:
		_p().erase("promise_due")


## Son söz olayının kaydı ({card, step, promises}); olay hiç gelmediyse {}.
static func promise_event() -> Dictionary:
	return _p().get("promise_due", {})


## Söz olayının kartı; kart sprintten çıktıysa {}.
static func promise_card() -> Dictionary:
	return _p().get("cards", {}).get(String(promise_event().get("card", "")), {})


## Söz olayının kartında çalışan çalışanlar (kurucu hariç).
static func promise_crew() -> Array:
	return promise_card().get("assignees", []).filter(
		func(id: String) -> bool: return CharacterRegistry.get_character(id).category == "employee")


## Söz olayının hâlâ açık sözleri.
static func event_promises() -> Array:
	return (promise_event().get("promises", []) as Array).map(
		func(id: String) -> Promise: return PromiseRegistry.get_promise(id)).filter(
		func(p: Promise) -> bool: return p != null and p.status == "open")


## Söz olayının kartının adı (kademenin adı); olay hiç gelmediyse "".
static func promise_name() -> String:
	var step: String = String(promise_event().get("step", ""))
	return SprintCatalog.step_name(step) if step != "" else ""


## Bu sprintin kart sayısı (bitenler dahil); tür seçilmeden 0.
static func sprint_card_count() -> int:
	return _sprint_cards().size()


## Söz kilidi: kademe planlanabilir sprintte yetişir mi. Kartı koşan ya da planlanabilir sprintte
## duruyorsa yerini almıştır. Yoksa kalanı, o sprinte söz verilmiş ama plana girmemiş kademelerin
## kalanıyla birlikte (birkaç hesaba verilen söz kademeyi bir kez sayar), o sprintin boş puanına
## sığar: ekibin kapasitesi eksi oraya konmuş kartların kalanı; koşan sprintin mesai çarpanı
## sonrakine geçmez. Sprint döngüsü olmayan ürünün sözü gün sayar, sığma sorusu yoktur.
static func fits_plannable(step: String) -> bool:
	if not is_typed():
		return true
	var p: Dictionary = _p()
	var planned: Array = (p.sprint.cards + (p.next.cards if mode() != "plan" else [])).map(
		func(id: String) -> String: return p.cards[id].step)
	if step in planned:
		return true
	var owed: Array = [step]
	for promise in PromiseRegistry.get_all():
		if promise.status == "open" and promise.due_sprint == plannable_sprint() \
				and promise.feature_id not in planned + owed:
			owed.append(promise.feature_id)
	var need: float = 0.0
	for s in owed:
		var stored: Array = p.cards.values().filter(func(c: Dictionary) -> bool: return c.step == s)
		need += remaining(stored[0]) if not stored.is_empty() else float(SprintCatalog.step_effort(s))
	var hours: float = float(p.sprint.get("hours_mult", 1.0)) if mode() == "active" else 1.0
	var room: float = capacity() - used() if mode() == "plan" else capacity() / hours - points_left(p.next.cards)
	return need <= room + EPS


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

## Biten haftanın işi kartlara, sonra sonraki sütunun önden hazırlanan kartlarına dökülür, PM'ler o kartları hazırlar
## (SprintPrep); sprintin süresi dolduysa ya da kartlarının hepsi bittiyse sprint kapanır, değilse 2. haftanın kararı ve
## ataması yapılır. Kişinin haftalık puanı atamanın sırasıyla harcanır: ekip hafta içinde değişmediyse
## sonuç önizlemeyle aynıdır. Kurucunun sprint payı harcamadan sonra yenilenir: harcama ve atama
## haftanın başında donmuş aynı sayıyı okur.
static func _end_week() -> void:
	var people: Dictionary = {}
	for person in team():
		people[person.id] = person
	var budget: Dictionary = {}
	var worked_ids: Array = []
	for c in _sprint_cards() + _ahead_cards():
		if c.decision or c.state == "done":
			continue
		var before: int = phase(c)
		for id in c.assignees:
			if people.has(id):
				budget[id] = _work(c, people[id], budget.get(id, people[id].points))
				worked_ids.append(id)
		var after: int = phase(c)
		if after != before:
			EventBus.card_phase_changed.emit(c.id, after)
		# Karar fiili eforu düşürüp kartı haftasız da bitirmiş olabilir.
		if after == PHASE_DONE:
			c.state = "done"
			EventBus.card_done.emit(c.id)
	worked_ids.append_array(SprintPrep.week(_ahead_cards(), people.values(), weeks_left()))
	_p().worked = {"day": GameState.day, "ids": worked_ids}
	GameState.freeze_founder_sprint_pay()
	if week() > sprint_weeks() or _finished(_sprint_cards()):
		_close()
	else:
		_staff_week(true)
		_ask_promise()


## Yeni haftanın ataması ve (`ask_paper`) sprintin karar kâğıdı. Kâğıt atamadan sonra istenir ki konuşan kartında
## çalışan biri olsun; kâğıt gelirse kartı beklediği için kişileri yeniden dağıtılır.
static func _staff_week(ask_paper: bool) -> void:
	_assign(_sprint_cards(), team(), _ahead_cards())
	if ask_paper and _request_decision():
		_assign(_sprint_cards(), team(), _ahead_cards())


## Haftanın ataması: önce sprintin kartları sırasıyla, sonra sonraki sütunun önden hazırlanan kartları
## (`ahead`). Kartın sıradaki fazına uyan kişi önce, sonra haftasından çok puanı kalan; kart bu hafta
## bitecek kadar kişi alır. Kartını bitirenin kalan puanı sıradaki karta geçer. Tasarım rolü yalnız ilk
## fazda çalışır; sprintte o fazı bekleyen kart kalmayınca sonraki sütuna önden gider, oraya başkası
## gitmez. Sprint puanı olmayan PM atamaya girmez: haftasını sonraki sütunun kartlarını hazırlamaya verir (SprintPrep).
## Kilitli kişi (kartın `pinned`ı, `until` gününe `day` varmadıkça) yalnız o karta gider ve onun atamasında rolden önce gelir;
## o hafta çalışamıyorsa kart kimsesiz bekler.
static func _assign(cards: Array, people: Array, ahead: Array = [], day: int = GameState.day) -> void:
	var free: Array = people.filter(func(person: Dictionary) -> bool: return person.points > 0.0).map(
		func(person: Dictionary) -> Dictionary: return person.merged({"left": person.points}))
	var all: Array = cards + ahead
	var locked: Dictionary = {}
	var waits: Array = []
	for c in all:
		var pin: Dictionary = c.get("pinned", {})
		if day < pin.get("until", 0) and phase(c) < PHASE_DONE:
			locked[pin.person] = c.id
			if free.all(func(person: Dictionary) -> bool: return person.id != pin.person):
				waits.append(c.id)
	for i in all.size():
		var c: Dictionary = all[i]
		c.assignees = []
		if c.decision or c.id in waits:
			continue
		var probe: Dictionary = c.duplicate(true)
		while phase(probe) < PHASE_DONE:
			var at: int = phase(probe)
			var able: Array = free.filter(func(p: Dictionary) -> bool:
				return (at == 0 or not p.ahead) and (p.ahead or i < cards.size()))
			# Kilit yokken kilidin süzgeci ve sırası koşmaz: plan ekranı haftaları kurulum başına onlarca kez oynatır.
			if not locked.is_empty():
				able = able.filter(func(p: Dictionary) -> bool: return locked.get(p.id, c.id) == c.id)
			if able.is_empty():
				break
			var role: String = _role(probe, at)
			able.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
				if (role in a.fits) != (role in b.fits):
					return role in a.fits
				if a.left != b.left:
					return a.left > b.left
				return a.id < b.id)
			if not locked.is_empty():
				var k: int = able.find_custom(func(p: Dictionary) -> bool: return locked.get(p.id) == c.id)
				if k > 0:
					able.push_front(able.pop_at(k))
			var person: Dictionary = able[0]
			free.erase(person)
			person.left = _work(probe, person, person.left)
			c.assignees.append(person.id)
			if person.left > EPS:
				free.append(person)


## Kişinin bütçesi kartın sıradaki fazlarına dökülür, harcanmayanı döner; uymadığı rolün fazında
## yarı hızla, hazırlanmış kartta PM'in hazırlık kazancı (`prep_gain`, SprintPrep) kadar hızlı, önden giden ilk fazın ardında
## durur. Yapılan iş kartta kişiye yazılır (SprintBugs.record); test biten kartın hatası o anda belirlenir ve bulunanların
## düzeltmesi Geliştirme satırına eklenir (SprintBugs.settle). `log` verilirse yapılan her iş parçası oraya yazılır (kart,
## kişi, aşama, aşamanın rolü, yapılan iş, harcanan bütçe): oynatma zaman eksenine buradan dökülür (SprintTimeline). Atamanın
## sınaması (`_assign`) yazmaz.
static func _work(c: Dictionary, person: Dictionary, budget: float, log = null) -> float:
	var at: int = phase(c)
	while at < PHASE_DONE and budget > EPS and (at == 0 or not person.ahead):
		var role: String = _role(c, at)
		var speed: float = (1.0 if role in person.fits else float(SprintCatalog.cfg("no_role_speed"))) \
			* (1.0 + float(c.get("prep_gain", 0.0)))
		var work: float = minf(float(c.need[at]) - float(c.progress[at]), budget * speed)
		c.progress[at] = float(c.progress[at]) + work
		SprintBugs.record(c, at, person.id, work)
		if log != null:
			log.append({"card": c.id, "person": person.id, "stage": at, "role": role, "work": work, "spent": work / speed})
		budget -= work / speed
		if at == TEST_PHASE and not c.get("tested", false) and float(c.need[at]) - float(c.progress[at]) <= EPS:
			SprintBugs.settle(c)
		at = phase(c)
	return budget


## Kartların kopyaları `people` ekibiyle (team() biçimi) `weeks` hafta oynanır; hafta _end_week gibi atama
## sırasıyla dökülür, sprintin kartlarından sonra sonraki sütunun kopyalarına (`ahead`), PM'ler o kopyaları hazırlar.
## Kartların hepsi biten haftada sprint kapanır: sonrasında önden gidilmez. {split: {kart: {kişi: {id, name, weeks}}},
## spare: sprintin hiçbir kartına harcanmayan puan, önden gidilen de}. `log` verilirse her hafta `{cards, ahead}` olarak
## ona eklenir: sprintin kartlarına ve sonraki sütunun kartlarına harcamanın `_work` kayıtları, harcama sırasıyla. `from_day`
## ilk oynanan haftanın günüdür: kart kilitleri her haftanın gününe göre okunur.
static func _play_out(cards: Array, weeks: int, people: Array, ahead: Array = [], log = null, from_day: int = GameState.day) -> Dictionary:
	var by_id: Dictionary = {}
	for person in people:
		by_id[person.id] = person
	var split: Dictionary = {}
	var spare: float = 0.0
	for _w in weeks:
		_assign(cards, by_id.values(), ahead, from_day + _w)
		var week: Dictionary = {"cards": [], "ahead": []} if log != null else {}
		if log != null:
			log.append(week)
		var budget: Dictionary = {}
		for c in cards:
			for id in c.assignees:
				budget[id] = _work(c, by_id[id], budget.get(id, by_id[id].points), week.get("cards"))
				var row: Dictionary = (split.get_or_add(c.id, {}) as Dictionary).get_or_add(id,
					{"id": id, "name": by_id[id].name, "weeks": 0})
				row.weeks += 1
		for id in by_id:
			spare += budget.get(id, by_id[id].points)
		for c in ahead:
			for id in c.assignees:
				budget[id] = _work(c, by_id[id], budget.get(id, by_id[id].points), week.get("ahead"))
		SprintPrep.week(ahead, people, weeks - _w - 1)
		if _finished(cards):
			ahead = []
	return {"split": split, "spare": spare}


## Sprintin kâğıt fırsatında (ilk haftanın sonunda) sprint başına tek zar atılır: `sprint.json`
## `decision.sprint_chance`'ın [WORKING] altında kalırsa sprintin bir kartı için havuzdan bir kâğıt istenir, yoksa
## sprint kâğıtsızdır. Söz olayı ya da acil durum gelen sprintte kâğıt gelmez
## (`_paper_blocked`); aynı anda tek karar bekler. Havuz ağırlıklı sırayla denenir (`decision.seen_weight` [WORKING]: kâğıt kaç
## kez görüldüyse ağırlığı 1 / (1 + seen_weight × görülme)), her kâğıt sprintin bitmemiş kartlarında sırayla. Kâğıdın
## konuşanı varsa (`speaker_role`) o kartın konuşanı `_speaker`'dır ve kimsesi olmayan kart için kâğıt gelmez.
## Kartın koşulları bekleyen kartı okur, bu yüzden karar istekten önce yazılır; motor reddederse silinir ve
## sıradaki çift denenir. Kâğıt istendiyse true.
static func _request_decision() -> bool:
	var p: Dictionary = _p()
	var number: int = sprint_number()
	if not p.decision.is_empty() or int(p.get("decision_sprint", -1)) == number or _paper_blocked():
		return false
	p["decision_sprint"] = number
	if EvDice.unit("paper", GameState.day, "sprint", "") >= float(SprintCatalog.cfg("decision.sprint_chance")):
		return false
	var pool: Array = (SprintCatalog.cfg("decision.cards") as Array).duplicate()
	var order: Dictionary = {}
	for event_id in pool:
		order[event_id] = pow(EvDice.unit("paper", GameState.day, "pick", event_id),
			1.0 + float(SprintCatalog.cfg("decision.seen_weight")) * EvLatches.fires(event_id))
	pool.sort_custom(func(a: String, b: String) -> bool: return order[a] > order[b])
	var open: Array = _sprint_cards().filter(func(c: Dictionary) -> bool: return phase(c) < PHASE_DONE)
	for event_id in pool:
		var paper: Dictionary = EvCatalog.card(event_id)
		var role: Variant = paper.get("speaker_role", [])
		var roles: Array = role if role is Array else [role]
		for c in open:
			var speaker: String = _speaker(c, roles, String(paper.get("stage", "any"))) if not roles.is_empty() else ""
			if not roles.is_empty() and speaker == "":
				continue
			var given: Dictionary = {}
			if speaker != "":
				given["founder" if CharacterRegistry.get_character(speaker).category == "founder" else "employee"] = speaker
			if HRConstants.ROLE_PRODUCT_MANAGER in roles and c.customer_id != "":
				given["customer"] = c.customer_id
			p.decision = {"card_id": c.id, "event_id": event_id, "speaker": speaker}
			c.decision = true
			if EventGate.request(event_id, given):
				_watch_decision()
				record_interrupt("paper")
				EventBus.card_decision_requested.emit(c.id)
				return true
			c.decision = false
	p.decision = {}
	return false


## Kâğıdı söyleyecek kişi, yoksa "": PM kâğıdını çeyreği planlayan PM söyler ve konusu sprintteki müşteri isteği kartıdır
## (PM sprint kartı almaz, önden gider); öbürlerini kartın bu haftaki atananlarından rolü `roles`'tan biri olan ve
## (`stage` "any" değilse) o aşamada çalışan ilk kişi. Payı Destek'te kalan kişi atanmaz, tasarımcı yokken PM tasarımcı
## sayılmaz.
static func _speaker(c: Dictionary, roles: Array, stage: String) -> String:
	if HRConstants.ROLE_PRODUCT_MANAGER in roles:
		var pm: Character = SprintCatalog.quarter_pm()
		return pm.id if pm != null and c.kind == "request" else ""
	for id in c.assignees:
		if CharacterRegistry.get_character(id).role in roles and (stage == "any" or role_of(id) == stage):
			return id
	return ""


## Sprintin kesintisi söz olayı ya da acil durumsa, söz olayı şimdi geliyorsa ya da bugün servisin çökmediği bir acil
## durum saatini bekliyorsa (sürümün ertesi sabahı oyuncunun başlattığı sprint) kâğıt gelmez.
static func _paper_blocked() -> bool:
	var waiting: String = String(GameState.incident.get("pending", {}).get("kind", ""))
	return not late_promise().is_empty() or _interrupted_by(["incident", "promise"]) \
		or (waiting != "" and waiting not in IncidentSystem.SERVICE_DOWN)


## Bu sprintte kâğıt geldi: acil durum yalnız servisin çöktüğü tür olabilir (`IncidentSystem.SERVICE_DOWN`), öbürü
## sonraki sprinte kayar (`IncidentSystem.daily_tick`).
static func paper_sprint() -> bool:
	return _interrupted_by(["paper"])


## Son kesinti bu sprintindir ve türü `kinds`'ten biridir.
static func _interrupted_by(kinds: Array) -> bool:
	var record: Dictionary = _p().get("interrupt", {})
	return int(record.get("sprint", 0)) == sprint_number() and String(record.get("kind", "")) in kinds


## Kâğıt ne kuyrukta ne masadaysa oyuncu karar vermiştir; kart yeniden ilerler.
static func _settle_decision() -> void:
	var decision: Dictionary = _p().decision
	if decision.is_empty():
		return
	var event_id: String = decision.event_id
	if EventGate.instances_of(event_id) > 0 or EventGate.on_desk(event_id):
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


## Sprint sürerken kalkan kararın kartına ekip döner: haftanın ataması baştan yapılır ve seçimin değiştirdiği kartı okur.
static func _clear_decision() -> void:
	var c: Dictionary = decision_card()
	_p().decision = {}
	if c.is_empty():
		return
	c.decision = false
	if mode() == "active" and c.id in _p().sprint.cards:
		_staff_week(false)


## Hafta ortasında ekipten ayrılan, Ekip'in gününde izne giden, işi sprint dışına geçen (Ar-Ge, Destek) ve
## izinden dönen kişi haftanın atamasını değiştirir. Sprint koşmuyorken ekibin her değişikliği (işi değişen,
## işe alınan, eğitime giden, ayrılan) planın tutuşunu yeniden okur: kimse çalışamıyorsa plan saati tutmaz.
static func _watch_team() -> void:
	if not EventBus.hr_day_processed.is_connected(_on_team_changed):
		EventBus.hr_day_processed.connect(_on_team_changed)
		EventBus.character_removed.connect(_on_team_changed.unbind(1))
		EventBus.assignment_changed.connect(_on_assignment_changed)
		EventBus.employee_hired.connect(_on_assignment_changed)
		EventBus.training_started.connect(_on_assignment_changed.unbind(1))


## Şirkette hiç PM kalmayınca devir bayrağı silinir: sonraki PM devri kendiliğinden açmaz. İzindeki ya da
## eğitimdeki PM şirkettedir ve bayrağı tutar.
static func _on_team_changed() -> void:
	if not is_typed():
		return
	if not CharacterRegistry.get_employees().any(func(c: Character) -> bool: return c.role == HRConstants.ROLE_PRODUCT_MANAGER):
		_p().delegate = false
	if mode() == "active":
		_restaff()
	_changed()


## Koşan sprintin ataması hafta içindeki iş değişikliğiyle, işe alımla ya da eğitimle değil Ekip'in
## gününde yenilenir.
static func _on_assignment_changed(_id: String) -> void:
	if is_typed() and mode() != "active":
		_changed()


## Devirde oyuncu saati sürdürünce sprint başlar: hafta planda ya da sürüm notunda geçmez.
static func _watch_speed() -> void:
	if not TimeManager.speed_changed.is_connected(_on_speed_changed):
		TimeManager.speed_changed.connect(_on_speed_changed)


static func _on_speed_changed(speed: int) -> void:
	if speed > 0 and mode() != "active" and delegated():
		_auto_start()


## Ekipte olmayan kişi karttan düşer; boştakiler kimsesiz kalan kartlara haftanın kalanında atanır.
static func _restaff() -> void:
	var people: Array = team()
	var here: Array = people.map(func(person: Dictionary) -> String: return person.id)
	var busy: Array = []
	for c in _sprint_cards():
		c.assignees = c.assignees.filter(func(id: String) -> bool: return id in here)
		busy.append_array(c.assignees)
	_assign(_sprint_cards().filter(func(c: Dictionary) -> bool: return c.assignees.is_empty()),
		people.filter(func(person: Dictionary) -> bool: return person.id not in busy))


## Masada bekleyen sprint kararının kâğıdı (EventGate.desk_papers satırı), yoksa {}; `last` kâğıdın son
## haftasıdır. Üst barın Sıradaki yuvası ve Ürün'ün karar satırı buradan okur.
static func decision_paper() -> Dictionary:
	var event_id: String = _p().get("decision", {}).get("event_id", "")
	for p in EventGate.desk_papers():
		if p.event_id == event_id:
			return p.merged({"last": bool(p.expiring) or int(p.weeks_left) <= 1})
	return {}


## Bekleyen kararın kartı; karar yoksa ya da kart artık saklanmıyorsa {}.
static func decision_card() -> Dictionary:
	return _p().get("cards", {}).get(String(_p().get("decision", {}).get("card_id", "")), {})


## Oyuncuyu beklemeyen sprint kendiliğinden başlar: devirde liderin önerisiyle (bu sprint ve sonraki sütun dolar), planlanacak
## kart yokken boş. Öneri boşsa sonraki sütunun kartları alınır; kapısı açık kart kalmazsa boş sprint başlar: sprint numarası
## ilerler, talep, söz ve araştırma sprint sayar. Ekip yoksa başlamaz. MVP kapısı oyuncuyu
## bekler: ürün ne kendiliğinden yayınlanır ne bir sprint daha bekler.
static func _auto_start() -> void:
	if _p().release.get("gate", false):
		return
	if mode() == "release":
		plan_next()
		# Devirde plan_next sprinti başlattı.
		if mode() != "plan":
			return
	if capacity() == 0:
		return
	_refresh_fix_cards()
	apply_lead()
	if _sprint_cards().is_empty():
		for id in _p().next.cards.duplicate():
			_place(_p().cards[id], true)
	_p().auto_started = sprint_number()
	_begin()
	EventBus.sprint_auto_started.emit(sprint_number())


## Sprint kapanışı: bu sprintte biten kartlar çıkar, etkileri uygulanır; bitmeyenler ilerlemesiyle sonraki
## sprinte devreder. Kimlik yeteneklerinden üçü K1'e varınca kapanış sürüm kapısında durur, ürünü CANLI v1.0 yapan publish'tir;
## canlıda çıkan kart her sürümde +0.1.
## Hâlâ bekleyen karar açık kalır: kâğıdı aynı dağıtımın olay yuvasında süresi dolup on_expire
## ile çözülür ve ertesi okumada kart serbest kalır; beklerken ilerlemediği için devretmiştir.
## Düzeltme kartı hattının bütün açık hatasını düşer; testten kaçan hata kartının hattına düşer, ürün canlı olana dek
## bekler. Söz olayında gönderilen kart (`send`) testi bittiyse düzeltmesi bitmeden çıkar, düzeltilmemiş hata da hattına
## düşer. Düzeltmesi bitmemiş öbür kart sessizce bırakılır: kalan işiyle sonraki sprinte devreder; devredenler sonraki
## sütunun başına dizilir, son gecede başa alınan kart onların da önündedir (`_next_column`). Sürüm kaydı aşama
## başına kapanışta kalan ihtiyacı ve o aşamanın art arda taşan kapanış sayısını taşır (`overflow`), kaçan hatanın
## hatlarını `escaped`ta, sprintin koştuğu haftayı `velocity.weeks`te (erken kapanan sprint bir haftadır).
static func _close() -> void:
	var p: Dictionary = _p()
	var sprint: Dictionary = p.sprint
	var number: int = int(sprint.number)
	var velocity: Dictionary = {"done": done_points(), "total": sprint.capacity, "weeks": week() - 1}
	var ship: Array = []
	var carried: Array = []
	for c in _sprint_cards():
		if c.state == "done" or SprintBugs.sent(c):
			ship.append(c)
		else:
			carried.append(c)
	# Araştırmanın işi bir aşamaya yazılmaz; sayaç bir önceki sürüm kaydından sürer, kaydın alanı yoksa 0'dan.
	var before: Dictionary = p.releases.back().get("overflow", {}) if not p.releases.is_empty() else {}
	var overflow: Dictionary = {}
	for i in PHASE_DONE:
		var out: float = 0.0
		for c in carried:
			var left: float = float(c.need[i]) - float(c.progress[i])
			out += left if c.kind != "research" and left > EPS else 0.0
		overflow[STAGES[i]] = {"out": out,
			"streak": int(before.get(STAGES[i], {}).get("streak", 0)) + 1 if out > 0.0 else 0}
	var areas: Array = SprintCatalog.area_ids()
	var levels: Dictionary = {}
	var alerts: Dictionary = {}
	for a in areas:
		levels[a] = ProductQuality.level(a)
		alerts[a] = SprintCatalog.area_alert(a)
	var closed: int = 0
	var escaped: Array = []
	for c in ship:
		match c.kind:
			"fix":
				# Sürüm notu gerçekten kapananı yazar: hattın o anki hatası, kartın planlanırkenki değil.
				c.bugs = ProductState.clear_line_bugs(c.line)
				closed += c.bugs
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
		# Yeniden yazılmış hatta (ProductState.line_blocked) kaçan hata yazılmaz; oyuncunun seçtiği çıkış hatası
		# (`leaks`) yine düşer.
		if not ProductState.line_blocked(c.line):
			for _i in SprintBugs.leaving(c):
				escaped.append(c.line)
		c.state = "done"
		p.cards.erase(c.id)
	# Araştırma ve düzeltecek hata bulamayan düzeltme kartı sürüm yapmaz.
	var releases := func(c: Dictionary) -> bool:
		return c.kind != "research" and not (c.kind == "fix" and c.bugs == 0)
	# MVP'ye varan kapanış kapıda durur: ürün oyuncu yayınlayana dek kapalı kalır.
	var gate: bool = not ProductState.is_live() and SprintCatalog.mvp_cards_left() == 0
	var public: bool = ProductState.is_live() and ship.any(releases)
	var n: int = ProductState.version() + 1 if public else 0
	if public:
		_go_public(n)
	# Hatayı bulan kullanıcıdır: biten kartın hatası kartının hattına düşer, ürün canlı olana dek bekler.
	for c in ship:
		for line in c.get("leaks", {}):
			for _i in int(c.leaks[line]):
				p.pending_faulty.append(line)
	p.pending_faulty.append_array(escaped)
	_land_faulty()
	# Sürüm notu hattın kapanıştan sonraki sayısını da yazar: kaçan bir hata aynı hatta düşmüş olabilir.
	for c in ship:
		if c.kind == "fix":
			c.bugs_after = ProductState.line_bugs(c.line)
	for c in carried:
		c.state = "carried"
		c.assignees = []
		c.erase("send")
	# Devreden düzeltme kartı hata deposundan okunur; hattında hata kalmadıysa silinmiştir.
	_refresh_fix_cards()
	carried = carried.filter(func(c: Dictionary) -> bool: return p.cards.has(c.id))
	var changed: Array = []
	var cleared: Array = []
	for a in areas:
		var to: float = ProductQuality.level(a)
		if SprintCatalog.display_level(to) != SprintCatalog.display_level(levels[a]):
			changed.append({"area": a, "from": levels[a], "to": to})
		if alerts[a] and not SprintCatalog.area_alert(a):
			cleared.append(a)
	var snapshot := func(c: Dictionary) -> Dictionary: return c.duplicate(true)
	# Biten ve kalan puan tek kaynaktan: planlama kartın kalanını aynı remaining()'den okur.
	var release: Dictionary = {"number": n, "sprint": number, "shipped": ship.map(snapshot),
		"carried": (carried + _carried_out()).map(func(c: Dictionary) -> Dictionary:
			return {"id": c.id, "done": total(c) - remaining(c), "total": roundi(total(c)), "to_sprint": number + 1}),
		"velocity": velocity, "expected": _expected(changed, closed), "actual": {}, "press": {},
		"gate": gate, "day": GameState.day, "changed_areas": changed,
		"alerts_cleared": cleared, "escaped": escaped, "overflow": overflow}
	release.press = SprintBridges.press_line(release)
	var carried_ids: Array = carried.map(func(c: Dictionary) -> String: return c.id)
	p.next.cards = _next_column(carried_ids)
	p.next.erase("first")
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
		SprintBridges.thank(p.releases.back())
	B2BSalesSystem.charge_trust_drains()
	EventBus.sprint_closed.emit(number)


## Ürün kamuya açılır: sürüm bayrakları ve geçmişi, ayın öne çıkanı ve köprüler. v1.0 MVP'dir:
## ürün canlıya geçer, sunucu açılır. Sinyalleri çağıran sürüm kaydını yazdıktan sonra atar.
static func _go_public(n: int) -> void:
	if n == 1:
		GameState.set_flag("mvp_shipped", true)
		GameState.set_flag("mvp_launch_day", GameState.day)
	GameState.set_flag("mvp_version", n)
	var history: Array = GameState.get_flag("mvp_version_history", [])
	history.append({"version": n, "day": GameState.day})
	GameState.set_flag("mvp_version_history", history)
	GameState.submit_month_highlight("PROD_SHIP_FIRST_TITLE" if n == 1 else "PROD_SHIP_VERSION_TITLE",
		{"version": version_text(n)}, 50)
	ProductState.refresh_on_publish()
	if n == 1:
		SprintBridges.on_mvp()
	SprintBridges.on_release()


## Sürüme kaçan hatalar kartlarının hattına düşer; ürün canlı olana dek (v1.0) bekler.
static func _land_faulty() -> void:
	if not ProductState.is_live():
		return
	for line in _p().pending_faulty:
		ProductState.add_bugs(line, 1)
	_p().pending_faulty = []


## Sürümde beklenen: değişen ilk alanın yeni durumu, yoksa kapanan hatalar, yoksa değişiklik yok.
static func _expected(changed: Array, closed: int) -> Dictionary:
	if not changed.is_empty():
		var area: String = changed[0].area
		return {"key": "PRODUCT_RESULT_LEVEL_EXPECTED", "args": {"area": area, "to": ProductQuality.word(area)}}
	if closed > 0:
		return {"key": Fmt.count_key("PRODUCT_RESULT_BUGS_EXPECTED", closed), "args": {"n": closed}}
	return {"key": "PRODUCT_RESULT_NONE_EXPECTED", "args": {}}


## Sürümden bir gün sonra gerçekleşen sonuç, hem geçmişteki kayda hem açık sürüm notuna.
static func _fill_actual() -> void:
	var p: Dictionary = _p()
	for r in p.releases:
		# v1.0'ın sonucu yayının kendisidir: kapıda boş geçen sprintle yayınlansa da yazılır.
		if GameState.day != int(r.day) + 1 or (r.shipped.is_empty() and int(r.number) != 1):
			continue
		r.actual = SprintBridges.actual_sentence(r)
		r.reviews = SprintBridges.pick_reviews(r)
		if not p.release.is_empty() and int(p.release.sprint) == int(r.sprint):
			p.release.actual = r.actual
			p.release.reviews = r.reviews


# --- İç -------------------------------------------------------------------------------

static func _p() -> Dictionary:
	return GameState.product


static func _changed() -> void:
	sync_plan_hold()
	EventBus.product_state_changed.emit()


## Saat sprint planını bekler (awaits_plan): tutuş alınır ya da bırakılır, hız değişmez. Toplu adımın
## içinde (gece, toplantı) adımın sonuna ertelenir: gece kapanışında alınan tutuş toplu adımı 08:00'den
## önce keserdi. Kabuk kurulurken de çağrılır (yükleme tutuşları siler, TimeManager.reset); ekip ve hız
## dinleyicileri burada bağlanır, yüklenen oyunda ilk tikten önce de.
static func sync_plan_hold() -> void:
	_watch_team()
	_watch_speed()
	if TimeManager.is_batching():
		if not EventBus.clock_batch_ended.is_connected(sync_plan_hold):
			EventBus.clock_batch_ended.connect(sync_plan_hold, CONNECT_ONE_SHOT)
		return
	if awaits_plan():
		TimeManager.hold_clock(HOLD_PLAN)
	else:
		TimeManager.release_clock(HOLD_PLAN)


## Tür seçilmeden de okunur (lider önerisi used()'i sorar); o zaman boştur.
static func _sprint_cards() -> Array:
	var cards: Dictionary = _p().get("cards", {})
	return (_p().get("sprint", {}).get("cards", []) as Array).map(func(id: String) -> Dictionary: return cards[id])


## Sonraki sütunun önden hazırlanan kartları (ready_share).
static func _ahead_cards() -> Array:
	return (_p().next.cards as Array).map(func(id: String) -> Dictionary: return _p().cards[id]).filter(
		func(c: Dictionary) -> bool: return ready_share(c) >= 0.0)


## Sprintin kartlarının hepsi bitti: sprint o haftanın sonunda kapanır. Boş sprint süresini doldurur.
static func _finished(cards: Array) -> bool:
	return not cards.is_empty() and cards.all(func(c: Dictionary) -> bool: return phase(c) == PHASE_DONE)


## Başlamamış kartın kapısı açık olmalı (başlatma kapalıyı sonraki sütuna geçirir); koşan kartın kapısı bir daha sorulmaz.
static func _starts(c: Dictionary) -> bool:
	return c.state == "running" or SprintCatalog.gate_reason(c.step) == ""


## Koşan ya da bitmiş kart yerinden oynamaz; kilitli kademe alınmaz.
static func _movable(c: Dictionary) -> bool:
	return not c.is_empty() and c.state not in ["running", "done"] and SprintCatalog.gate_reason(c.step) == ""


## Başlamamış düzeltme kartının hata sayısı ve eforu hata deposundan okunur; hattında hata kalmayan kart silinir.
## Koşan kartınki başlatmada kilitlenmiştir. Depo hata düşünce ve kart çıkınca değişir; günlük tikte, kapanıştan
## sonra ve başlatmadan önce çağrılır.
static func _refresh_fix_cards() -> void:
	var p: Dictionary = _p()
	for c in p.cards.values():
		if c.kind == "fix" and c.state in ["candidate", "planned", "carried"]:
			# Kâğıdın eklediği ya da aldığı puan ve kısaltılmış test kalır: aşamalar oranıyla büyür ya da küçülür.
			var was: int = SprintCatalog.fix_effort(c.bugs)
			c.bugs = ProductState.line_bugs(c.line)
			_scale_need(c, SprintCatalog.fix_effort(c.bugs) - was)
			# A card a decision paper waits on stays until the paper settles: its expiry acts on it.
			if c.bugs == 0 and not c.decision:
				p.cards.erase(c.id)
				p.sprint.cards.erase(c.id)
				p.next.cards.erase(c.id)


## Sprint sürerken karar fiiliyle sonraki sprinte geçen kartlar: hız ve devreden onları da sayar.
static func _carried_out() -> Array:
	var cards: Dictionary = _p().cards
	return (_p().sprint.get("carried_out", []) as Array).filter(func(id: String) -> bool:
		return cards.has(id) and cards[id].state == "carried").map(func(id: String) -> Dictionary: return cards[id])


## Kartı bu sprinte ya da sonrakine koyar; adaysa saklanan kart olur, devreden damgası kalır.
static func _place(c: Dictionary, this_sprint: bool) -> void:
	var p: Dictionary = _p()
	p.sprint.lead_applied = false
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


## Kartın eforu: aşama ihtiyaçlarının toplamı, karar fiilinin değişikliğiyle.
static func total(c: Dictionary) -> float:
	return float(c.need[0]) + float(c.need[1]) + float(c.need[2])


## Kartın eforu `points` puan değişir (eksi: azalır): her aşamanın ihtiyacı payı kadar dağılır, kısaltılmış testin düşen
## işi de (yakalama oranı sabit kalır).
static func _scale_need(c: Dictionary, points: float) -> void:
	var scale: float = 1.0 + points / total(c)
	for i in PHASE_DONE:
		c.need[i] = float(c.need[i]) * scale
	c.cut = float(c.get("cut", 0.0)) * scale


static func _worked(c: Dictionary) -> float:
	return float(c.progress[0]) + float(c.progress[1]) + float(c.progress[2])


## Kartın sıradaki fazı; üçü dolmuşsa PHASE_DONE. İhtiyacı olmayan faz öncekiler bitince biter.
static func phase(c: Dictionary) -> int:
	for i in PHASE_DONE:
		if float(c.need[i]) - float(c.progress[i]) > EPS:
			return i
	return PHASE_DONE


static func _role(c: Dictionary, at: int) -> String:
	return (SprintCatalog.cfg("roles." + String(c.kind)) as Array)[at]


## Kişinin koşan sprintte bu hafta çalıştığı fazın rolü, sonraki sütunda önden çalıştığı kart da (PM'in hazırlığı
## "product"); işi yoksa "".
static func role_of(person_id: String) -> String:
	if mode() != "active":
		return ""
	var ahead: Array = _ahead_cards()
	for c in _sprint_cards() + ahead:
		var at: int = phase(c)
		if person_id in c.assignees and at < PHASE_DONE:
			return _role(c, at)
	return "product" if ahead.any(func(c: Dictionary) -> bool:
		return c.get("prep_by", "") == person_id and float(c.get("prep_done", 0.0)) < 1.0 - EPS) else ""


## Kişinin uyduğu sprint rolleri: kurucu sprint.json'daki rollerde, çalışan ana ya da ikincil
## alanında.
static func _fits(c: Character) -> Array:
	if c.category == "founder":
		return (SprintCatalog.cfg("founder_roles") as Array).duplicate()
	var areas: Dictionary = SprintCatalog.cfg("role_areas")
	return areas.keys().filter(func(r: String) -> bool: return HRConstants.can_hold_area(c.role, areas[r], c.category))


## Y(s): alanın 0-10 puanının hız çarpanı, a + b·s + c·s² (`sprint.json` `skill_curve` [a, b, c], [WORKING]). Testin
## yakalaması da aynı eğriden okur (SprintBugs.catch_rate).
static func skill_y(s: float) -> float:
	var curve: Array = SprintCatalog.cfg("skill_curve")
	return curve[0] + curve[1] * s + curve[2] * s * s


## Kişisiz haftalık puan (işe alım dosyası da okur): 10 × Y(s) × çalışma saati; s rolün ana alanının 0-10 puanı;
## verim kişinindir, burada yok.
static func points_for(role_id: String, role_stats: Dictionary, hours: int) -> float:
	var s: float = float(int(role_stats.get(HRConstants.role_key_area(role_id), 0)))
	return float(SprintCatalog.cfg("person_points_week")) * skill_y(s) * HRConstants.hours_output_mult(hours)


## Haftalık puan: 10 × Y(s) (kurucu sabit) × verim × çalışma saati × sprint payı; çalışanda huyun hız ve verim
## çarpanı, kurucuda toplantılardan kalan pay (sprint payı değil, `GameState.founder_sprint_pay`). PM puan üretmez,
## haftasını hazırlığa verir (SprintPrep).
static func _points(c: Character, hours: int) -> float:
	if c.category == "founder":
		return float(SprintCatalog.cfg("person_points_week")) * float(SprintCatalog.cfg("founder_mult")) \
			* HRSystem.productivity(c) * HRConstants.hours_output_mult(hours) * GameState.founder_sprint_pay * _share(c)
	return 0.0 if c.role == HRConstants.ROLE_PRODUCT_MANAGER else paced(c, points_for(c.role, c.role_stats, hours))


## Çalışanın haftalık işi: rolünün kişisiz hızı `base`, verim, huyun hız ve verim çarpanı ve sprint payıyla çarpılır.
static func paced(c: Character, base: float) -> float:
	return base * HRSystem.productivity(c) * HRConstants.trait_mult(c.traits, "speed_mult") \
		* HRConstants.trait_mult(c.traits, "output_mult") * _share(c)


## Kişinin sprint payı: Yapım ve Test işlerinin her biri odak payını (HRConstants.focus_mult) getirir. Tek
## işte 1, Yapım ve Test'te 1, Yapım ve Destek'te 0,5; yalnız Destek'te ya da Ar-Ge'de 0 (ekipte değil).
static func _share(c: Character) -> float:
	return c.assigned_job_ids.filter(func(job: String) -> bool: return job in SPRINT_JOBS).size() \
		* HRConstants.focus_mult(HRSystem.job_count(c))
