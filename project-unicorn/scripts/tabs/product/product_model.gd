class_name ProductModel
extends RefCounted

# Ürün sekmesinin sprint ekranının görünüm sözleşmesi. Sekme yalnız bu Dictionary'yi çizer.
# Üreten (canlı adaptör ya da debug fikstürü) içerik alanlarını çözülmüş metin olarak verir;
# eşik ve izinler bool gelir. Bileşenler kendi dilbilgisini PRODUCT_* anahtarlarından kurar.
#
# PRD terimi → sözleşme adı:
#   Alan → area {id, name} · Yetenek / Kademe → capability {name, tier 0..3}
#   Kart → card {id, kind, effort, roles, phases, state, assignees, effect}
#   Sprint → center {sprint, capacity, cards} · Sürüm → center.release {version, shipped, carried, velocity, press}
#   tür yeni/cila/düzeltme/araştırma → kind feature|polish|fix|research
#   kart durumları → SprintCard.State · fazlar → phases [design, dev, test], her biri done|active|waiting
#   roller → roles: design|dev|test|product (en çok üç ikon)
#
# model = {
#   header: {name, live_version: "1.4" or "" (MVP öncesi), market: "B2C"|"B2B" or "" (tür yok), type_text,
#            users, paying (canlı B2C'de kitle ve ödeyen; -1 = yok)},
#   versions: [{label: "v1.4", sprint: int or -1, shipped_count: int or -1,   # -1 çizilmez
#               result: {kind: "expected"|"actual", text} or null}],
#   quarter: {state: "locked_no_pm"|"open",
#             goal: {area_id, area_name, text, now, target, total, progress_text} or null, columns: [column]},
#   ui: {view: "sprint"|"quarter", open_area: area id or "", history_open, voices_open, hover_card: card id or ""},
#   areas: [area],
#   customers: null (B2C, satır yok) | [customer] ([] = "Açık talep yok"),
#   center: center,
#   next: {sprint: int or -1, flags: [{k: "rival"|"deadline", text}], cards: [card]},
# }
# area = {id, name, level 0..3 (.5 olabilir), level_to: -1 or 0..3 (sürüm oku),
#         word: "strong"|"enough"|"weak"|"none", word_to: "" or word, sentence, goal_text (çeyrek hedefi olarak),
#         voices: {n, new}, alert (uyarı üçgeni), rival_topic: "" or String,
#         capabilities: [{name, tier 0..3}],
#         candidates: [card], voices_list: [{text, new}], empty (aday kalmadı)}
# customer = {name, request: "" or String, tickets, tag_sprint: -1 or int, due_sprint: -1 or int,
#             value (yıllık $), area_name: "" or String, card_id (talebin kartı), buttons: [...],
#             addable ("+" bu talep için açık)}
# center = {mode: "plan"|"active"|"release", sprint (-1 = sprint yok), weeks (sprintin süresi), week (active),
#           lengths: [int] (planlamada seçilebilen süreler),
#           capacity: {used, total, done, state: "ok"|"over"|"blocked", segments: [{pts}]} or null (puanlar kesirli),
#           team: [person + {share}] (share: sprint payı, 1 ya da Yapım ve Destek tutanda 0,5), staffed (kadroda çalışan var),
#           warning_text: "" or String (eksik rol),
#           idle_text: "" or String (koşan sprintte bu hafta kartı olmayanlar ve öneri),
#           cards: [card], forecast: [part], status: {done, running (işçili), queued, decisions},
#           empty (koşan sprint kartsız başladı), pm_started: "" or String (sprinti devirle başlatan PM'in adı),
#           plan_hold (planlama oyuncuyu bekliyor, saat duruyor), delegate: {on, name (PM)} or null (PM yok),
#           next_version: {label, weeks: int or -1} or null (MVP öncesi),
#           mvp_line: {version, area, need, done (bu sprintte biten dahil), sprint (-1 = tahmin yok), week}
#                     or null (canlıda),
#           can_add (sprint kart alıyor, kartsız soru), spare (planda hiçbir karta gitmeyen puan var),
#           ceiling_pct (yükün "+" kapanan eşiği, yüzde), can_start,
#           start_reason: "" or String (başlat kapalıysa kapanan koşul),
#           rnd_node: {id (araştırdığı düğüm), text ("Kurucu Ar-Ge'de: …")} or null (kurucu Ar-Ge'de değil),
#           lead_tip: person + {text, self (lider kurucunun kendisi)} or null,
#           release: {version: "v5" or "" (sürüm çıkmadı), gate (MVP kapısı: Yayınla / Bir sprint daha;
#                     başlık ve gövde mvp_line'dan), rnd_open (v1.0 notu: Ar-Ge açıldı), shipped: [card],
#                     carried: [{name, kind, done (kesirli), total, to_sprint}], velocity: {done, total} (kesirli),
#                     result: {kind: "expected"|"actual", text} or null, press: {outlet (anahtar), text} or {},
#                     lead: person + {text, self}} or null}
# person = {name, role_text, look ({} ise baş harfler)}
# column = {sprint, kind: "current"|"proposed"|"empty", capacity: {...} or null, pm, flags: [...], cards: [card], approved}
# card = {id, name, kind, roles: [...], effort, state: SprintCard.State, effect: [part], tag_sprint: -1 or int,
#         phases: [] or [3 states] (karar bekleyen ve sıradaki kartta üçü waiting),
#         phase_pts: {done, total} (sıradaki fazın puanları, kesirli) or null, assignees: [person],
#         queued (aktifte işçisi ve kararı olmayan, bitmemiş kart: "Sırada"),
#         decision: {event_id, item (gelen kutusundaki kâğıt), sender (Inbox'un göndericisi), subject, weeks_left,
#                    last} or null (kart "İş durdu · karar bekliyor"),
#         effort_split: [{name, weeks}],
#         locked_node: "" or String, locked_rnd: "" or String (kilidin açılmamış Ar-Ge düğümü; kart oraya götürür),
#         remaining: -1 or float (kesirli), urgent,
#         spills (planda puan alır ama bitmez), no_start: -1 or int (planda puan almaz, kaydığı sprint),
#         planned_done (kesirli, planda sprint sonunda biten puan), addable ("+" bu aday için açık),
#         ready: -1 or 0..1 (sonraki sütunda önden hazırlanan kartın hazır payı; planda sprint sonundaki),
#         buttons: ["add"|"send_next"|"pull"|"remove"]}   # var olan düğmeler; "+" addable ile açılır
# part = {k: "level", area, from, to, from_word, to_word} | {k: "holds", area, word} | {k: "alert_clear", area}
#      | {k: "cap", name, from, to, from_word, to_word} | {k: "tickets", n} | {k: "voices", n}
#      | {k: "request", customer, value} | {k: "research", area} | {k: "request_on_time", customer}
#      | {k: "promise", customer}   # kademeye verilmiş açık söz; kart onu etiketle de taşır
#   level ve cap parçalarında from/to seviyedir (0..3); from_word/to_word o seviyenin beklentiye göre
#   kelimesidir (SprintCatalog.word_for), kelime ve renk ondan.

const INBOX := preload("res://scripts/ui/components/inbox.gd")
## Kartın bulunduğu yerdeki düğmeleri; "+" kartın addable'ıyla açılır.
const BUTTONS := {
	SprintCard.State.ADAY: ["add", "send_next"],
	SprintCard.State.KILITLI: ["add", "send_next"],
	SprintCard.State.SPRINT_PLAN: ["send_next", "remove"],
	SprintCard.State.SPRINT_AKTIF: ["remove"],
	SprintCard.State.PLANLANAN: ["pull", "remove"],
	SprintCard.State.DEVREDEN: ["pull", "remove"],
}


## Kaynak verilmediğinde sekmenin okuduğu model: ürün durumundan (GameState.product) ve sprint
## sistemlerinden kurulur. Tür seçilmeden alan ve kart yoktur; sekme o zaman tür seçiciyi açar.
static func live() -> Dictionary:
	var p: Dictionary = GameState.product
	var mode: String = SprintSystem.mode()
	var release: Dictionary = p.get("release", {}) if mode == "release" else {}
	# Bu ya da sonraki sprintte duran kartın sprint numarası: adaydaki kopyası soluklaşıp damga alır.
	var tags: Dictionary = {}
	for key in ["sprint", "next"]:
		var s: Dictionary = p.get(key, {})
		for id in s.get("cards", []):
			tags[id] = int(s.number)
	var changed: Dictionary = {}
	for ch in release.get("changed_areas", []):
		changed[ch.area] = ch
	var versions: Array = []
	for r in p.get("releases", []):
		if int(r.number) > 0:
			# Sprintlerden önceki sürümün (eski kayıt) sprinti -1'dir; kart sayısı da bilinmez.
			versions.append({"label": SprintSystem.version_label(int(r.number)), "sprint": int(r.sprint),
				"shipped_count": -1 if int(r.sprint) < 0 else r.shipped.size(), "result": _result(r)})
	var live_now: bool = ProductState.is_live()
	var b2c_live: bool = live_now and ProductState.market_type() == "b2c"
	# Plan ekranı motorun oynatmasını söyler: kim kaç hafta, devreden, başlamayan, SPRINT SONUNDA ve sonraki
	# sütunun hazır payı.
	var outcome: Dictionary = SprintSystem.plan_outcome() if mode == "plan" and SprintSystem.sprint_number() > 0 else {}
	var center: Dictionary = _center(mode, release, outcome)
	var next: Dictionary = _next(mode, outcome)
	return {
		"header": {
			# Adsız ürün tür adıyla okunur.
			"name": SalesSystem.product_display_name(),
			"live_version": SprintSystem.version_text(ProductState.version()) if live_now else "",
			"market": ProductState.market_type().to_upper(),
			"type_text": ProductCatalog.type_name(ProductState.subtype()),
			"users": int(SalesSystem.b2c_audience()) if b2c_live else -1,
			"paying": SalesSystem.b2c_paying_users() if b2c_live else -1,
		},
		"versions": versions,
		"quarter": _quarter(center, next),
		"ui": {"view": "sprint", "open_area": "", "history_open": false, "voices_open": false, "hover_card": ""},
		"areas": SprintCatalog.areas_for(ProductState.subtype(), ProductState.market_type()).map(
			func(a: Dictionary) -> Dictionary: return _area(a.id, tags, changed.get(a.id, {}))),
		"customers": _customers(tags) if ProductState.market_type() == "b2b" else null,
		"center": center,
		"next": next,
	}


# --- Alanlar ve müşteriler --------------------------------------------------------

## Sürüm notunda değişen alan oklu okunur: eski seviye ve kelimesi → bugünkü.
static func _area(id: String, tags: Dictionary, changed: Dictionary) -> Dictionary:
	var word: String = SprintCatalog.area_word(id)
	var voices: Array = SprintCatalog.voices(id)
	var candidates: Array = SprintCatalog.candidates(id).map(
		func(c: Dictionary) -> Dictionary: return _candidate(c, tags))
	var area := {"id": id, "name": SprintCatalog.area_name(id),
		"level": SprintCatalog.area_level(id), "level_to": -1, "word": word, "word_to": "",
		"sentence": SprintCatalog.area_sentence(id), "goal_text": goal_text(id),
		"voices": {"n": voices.size(), "new": voices.filter(func(v: Dictionary) -> bool: return v.new).size()},
		"alert": SprintCatalog.area_alert(id), "rival_topic": SprintCatalog.rival_topic(id),
		"capabilities": SprintCatalog.capabilities(id).map(_capability),
		"candidates": candidates, "voices_list": voices, "empty": candidates.is_empty()}
	if not changed.is_empty():
		area.level = float(changed.from)
		area.level_to = float(changed.to)
		area.word = SprintCatalog.word_for(float(changed.from), SprintCatalog.expectation(id))
		area.word_to = word
	return area


static func _capability(line_id: String) -> Dictionary:
	return {"name": SprintCatalog.cap_name(line_id), "tier": SprintCatalog.tier(line_id)}


## Aday: sprintte ya da sonrakinde duran kart soluk ve damgalı, kapısı kapalı kart kilitli.
static func _candidate(c: Dictionary, tags: Dictionary) -> Dictionary:
	if c.state != "candidate":
		return _card(c, SprintCard.State.ADAY_ALINMIS, {"tag_sprint": tags.get(c.id, -1)})
	var lock: String = SprintCatalog.gate_reason(c.step)
	if lock != "":
		return _card(c, SprintCard.State.KILITLI, {"locked_node": lock, "locked_rnd": _locked_rnd(c.step)})
	return _card(c, SprintCard.State.ADAY, {"addable": SprintSystem.can_add(c.id)})


## Açık talepler; hesabı kapanmış müşterinin talebi yazılmaz. Talep kartı aday kartın aynısıdır:
## aynı kademenin özellik kartı planlıysa talep onunla karşılanır.
static func _customers(tags: Dictionary) -> Array:
	var stored: Dictionary = GameState.product.get("cards", {})
	var out: Array = []
	for r in GameState.product.get("requests", []):
		var customer: String = SprintCatalog.customer_name(r)
		if r.status != "open" or customer == "":
			continue
		var card_id: String = "feat:" + r.step if stored.has("feat:" + r.step) else String(r.card_id)
		var area_id: String = SprintCatalog.area_of_line(r.line)
		var tag: int = tags.get(card_id, -1)
		out.append({"name": customer, "request": SprintCatalog.step_name(r.step), "tickets": 0,
			"tag_sprint": tag, "due_sprint": int(r.due_sprint), "value": int(r.value),
			"area_name": SprintCatalog.area_short(area_id), "card_id": card_id,
			"buttons": BUTTONS[SprintCard.State.ADAY] if tag < 0 else [], "addable": tag < 0 and SprintSystem.can_add(card_id)})
	return out


# --- Bu sprint ------------------------------------------------------------------------

static func _center(mode: String, release: Dictionary, outcome: Dictionary) -> Dictionary:
	var p: Dictionary = GameState.product
	var sprint: Dictionary = p.get("sprint", {})
	var n: int = SprintSystem.sprint_number()
	var total: float = SprintSystem.capacity()
	var team: Array = SprintSystem.team()
	var lead: Character = _lead()
	var pm: Character = SprintCatalog.quarter_pm()
	var sprint_cards: Array = sprint.get("cards", [])
	var decision: Variant = _decision()
	var eta: Dictionary = SprintSystem.mvp_eta() if n > 0 else {}
	var need: int = int(SprintCatalog.cfg("mvp_lines"))
	# Sürüm koşulunda bu sprintte biten Çekirdek K1 de bitmiş sayılır.
	var finished: int = p.get("cards", {}).values().filter(func(c: Dictionary) -> bool:
		return c.area == "core" and int(c.target_tier) == 1 and c.state == "done").size()
	var cards: Array = []
	var segments: Array = []
	var load: float = 0.0
	var status := {"done": 0, "running": 0, "queued": 0, "decisions": 0}
	for id in sprint_cards:
		var c: Dictionary = p.cards[id]
		var card: Dictionary
		var pts: float = SprintSystem.card_load(c)
		match [mode, c.state]:
			["plan", _]:
				var o: Dictionary = outcome.cards[id]
				card = _planned(c, SprintCard.State.SPRINT_PLAN, {"remaining": _remaining(c), "effort_split": o.split,
					"spills": not o.finishes and o.done > SprintSystem.EPS, "no_start": n + 1 if o.done <= SprintSystem.EPS else -1,
					"planned_done": SprintSystem.total(c) - SprintSystem.remaining(c) + o.done})
			[_, "done"]:
				card = _card(c, SprintCard.State.BITTI, {"phases": _phases(c), "assignees": _people(c.assignees, team)})
				status.done += 1
			_:
				# Karar bekleyen ve işçisi olmayan kart ilerlemez: fazları bekler, sayaçta kendi parçasındadır.
				var at: int = SprintSystem.phase(c)
				var people: Array = _people(c.assignees, team)
				var part: String = "decisions" if c.decision \
					else ("queued" if people.is_empty() and at < SprintSystem.PHASE_DONE else "running")
				status[part] += 1
				card = _card(c, SprintCard.State.SPRINT_AKTIF, {"assignees": people, "queued": part == "queued",
					"phases": _phases(c) if part == "running" else ["waiting", "waiting", "waiting"],
					"phase_pts": {"done": float(c.progress[at]), "total": float(c.shares[at]) * SprintSystem.total(c)}
						if at < SprintSystem.PHASE_DONE else null,
					"decision": decision if c.decision else null})
		segments.append({"pts": pts})
		load += pts
		cards.append(card)
	var lead_ids: Array = SprintCatalog.lead_suggestion() if mode == "plan" and not sprint.get("lead_applied", false) else []
	var warning: String = ""
	if not team.is_empty() and not team.any(func(t: Dictionary) -> bool: return "test" in t.fits):
		warning = _t("PRODUCT_ROLE_MISSING").format({"role": HRConstants.area_label("qa")})
	# Boştaki kişiye iş kendiliğinden verilmez: satır onu sayar ve oyuncuya bir hamle önerir.
	var idle: int = team.filter(func(t: Dictionary) -> bool: return SprintSystem.role_of(t.id) == "").size() \
		if mode == "active" else 0
	var idle_text: String = "" if idle == 0 else _t(Fmt.count_key("PRODUCT_IDLE", idle)).format({"n": idle}) \
		+ SprintUiShared.SEP + _t("PRODUCT_IDLE_PLAN")
	# Araştıran kurucu sprint ekibinden düşer: Ürün bunu düğümün adıyla söyler ve Ar-Ge'ye götürür.
	var rnd: Variant = null
	if CharacterRegistry.get_founder().assigned_job_ids.has(HRConstants.JOB_RESEARCH):
		rnd = {"id": RnDSystem.active(),
			"text": _t("PRODUCT_TEAM_IN_RND").format({"node": ResearchSeam.node_name(RnDSystem.active())})}
	var can_start: bool = SprintSystem.can_start()
	var reason: String = ""
	if mode == "plan" and not can_start:
		reason = (_t("PRODUCT_TEAM_NOBODY_JOBS") if rnd == null else rnd.text) if total == 0 else _t("PRODUCT_START_NEED_CARD")
	return {
		"mode": mode, "sprint": n if n > 0 else -1, "weeks": SprintSystem.sprint_weeks(), "week": SprintSystem.week(),
		"lengths": (SprintCatalog.cfg("sprint_lengths") as Array).map(func(w: float) -> int: return int(w)),
		"capacity": _bar(load, total, SprintSystem.done_points(), segments) if n > 0 else null,
		"team": team.map(func(t: Dictionary) -> Dictionary:
			return _person(CharacterRegistry.get_character(t.id)).merged({"share": t.share})),
		"staffed": not CharacterRegistry.get_employees().is_empty(),
		"warning_text": warning, "idle_text": idle_text, "cards": cards,
		"forecast": SprintCatalog.forecast(sprint_cards.filter(func(id: String) -> bool: return outcome.cards[id].finishes))
			if mode == "plan" else [],
		"status": status,
		"empty": mode == "active" and int(p.get("empty_sprint", -1)) == n,
		# Devir dışında sprint yalnız planlanacak kart yokken kendiliğinden başlar, o da boş başlar.
		"pm_started": pm.character_name if pm != null and mode == "active" and int(p.get("auto_started", -1)) == n
			and int(p.get("empty_sprint", -1)) != n else "",
		"plan_hold": mode == "plan" and SprintSystem.awaits_plan(),
		"delegate": {"on": bool(p.get("delegate", false)), "name": pm.character_name} if pm != null else null,
		# MVP öncesi v1.0'ın tarihini sürüm koşulu verir; bu sprintin sonu onu vaat etmez.
		"next_version": {"label": SprintSystem.version_label(ProductState.version() + 1),
			"weeks": SprintSystem.weeks_left()} if n > 0 and ProductState.is_live() else null,
		"mvp_line": null if n <= 0 or ProductState.is_live() else {"version": SprintSystem.version_label(1),
			"area": SprintCatalog.area_short("core"), "need": need,
			"done": need - SprintCatalog.mvp_cards_left() + finished,
			"sprint": eta.get("sprint", -1), "week": eta.get("week", -1)},
		"can_add": SprintSystem.can_add(), "spare": outcome.get("spare", 0.0) > SprintSystem.EPS,
		"ceiling_pct": roundi(float(SprintCatalog.cfg("cap_ceiling")) * 100.0),
		"can_start": can_start, "start_reason": reason, "rnd_node": rnd,
		"lead_tip": null if lead_ids.is_empty() else _person(lead).merged({"text": SprintCatalog.lead_sentence(lead_ids),
			"self": lead.category == "founder"}),
		"release": _release(release, lead) if not release.is_empty() else null,
	}


## Sürüm notu: çıkanlar bitmiş kart, devredenler ilerlemesiyle; sonuç ertesi gün gerçekleşene döner.
static func _release(r: Dictionary, lead: Character) -> Dictionary:
	var press: Dictionary = r.get("press", {})
	return {
		"version": SprintSystem.version_label(int(r.number)),
		"gate": r.get("gate", false),
		# Ar-Ge ağacı v1.0 ile açılır.
		"rnd_open": int(r.number) == 1,
		"shipped": r.shipped.map(func(c: Dictionary) -> Dictionary: return _card(c, SprintCard.State.BITTI)),
		"carried": r.carried.map(func(item: Dictionary) -> Dictionary:
			var c: Dictionary = SprintCatalog.card_by_id(item.id)
			return {"name": SprintCatalog.card_name(c), "kind": _kind(c), "done": item.done, "total": item.total,
				"to_sprint": int(item.to_sprint)}),
		"velocity": r.velocity,
		"result": _result(r),
		"press": {} if press.is_empty() else {"outlet": press.outlet, "text": SprintBridges.resolve(press)},
		"lead": _person(lead).merged({"text": SprintCatalog.release_lead_sentence(r), "self": lead.category == "founder"}),
	}


## Sürümün sonuç satırı: ertesi gün gerçekleşen, o gelene kadar beklenen; ikisi de yoksa null.
## Sürüm notu ertesi gün kapanmış olur, gerçekleşeni Geçmiş gösterir.
static func _result(r: Dictionary) -> Variant:
	var said: Dictionary = r.expected if r.actual.is_empty() else r.actual
	return null if said.is_empty() else {"kind": "expected" if r.actual.is_empty() else "actual",
		"text": SprintBridges.resolve(said)}


# --- Sonraki sprint -----------------------------------------------------------------

## Sprint sürerken ya da sürüm notunda kart bu sprinte çekilemez. Planlanan kart önden hazırlandığı kadar
## hazır payını taşır: planda sprint sonundakini (`outcome`), koşan sprintte ve sürüm notunda bugünkünü.
static func _next(mode: String, outcome: Dictionary) -> Dictionary:
	var p: Dictionary = GameState.product
	var next: Dictionary = p.get("next", {})
	if next.is_empty():
		return {"sprint": -1, "flags": [], "cards": []}
	var n: int = int(next.number)
	var buttons: Array = BUTTONS[SprintCard.State.PLANLANAN] if mode == "plan" else ["remove"]
	var cards: Array = []
	for id in next.cards:
		var c: Dictionary = p.cards[id]
		match c.state:
			"carried":
				cards.append(_planned(c, SprintCard.State.DEVREDEN, {"remaining": _remaining(c), "buttons": buttons}))
			_:
				var ready: float = outcome.ready.get(id, -1.0) if mode == "plan" else SprintSystem.ready_share(c)
				cards.append(_planned(c, SprintCard.State.PLANLANAN, {"buttons": buttons,
					"ready": ready if ready > SprintSystem.EPS else -1.0}))
	return {"sprint": n, "flags": _flags(n), "cards": cards}


## Sprint başlığının bayrakları: gri, o sprintin rakip çıkışı; kırmızı, son tarihi o sprint olan talep.
static func _flags(n: int) -> Array:
	var flags: Array = SprintCatalog.rival_launch_in(n).map(func(l: Dictionary) -> Dictionary:
		return {"k": "rival", "text": _t("PRODUCT_RIVAL_TOPIC").format({"topic": l.topic})})
	for r in GameState.product.get("requests", []):
		var customer: String = SprintCatalog.customer_name(r)
		if r.status == "open" and int(r.due_sprint) == n and customer != "":
			flags.append({"k": "deadline", "text": _t("PRODUCT_FLAG_DEADLINE").format(
				{"customer": customer, "request": SprintCatalog.step_name(r.step)})})
	return flags


# --- Çeyrek ----------------------------------------------------------------------------

## ÇEYREK PM varken açılır. Sütunlar bu sprint, PM'in planladığı sprintler ve çeyreği varsayılan sprint
## süresiyle altı sütuna tamamlayan boşlardır (1 haftalık sprintin on iki sütunu pencereye sığmaz);
## sonraki sprintin sütunu orada duran kartların üstüne PM'in önerisini ekler. Gelecek sprintin
## kapasitesi bugünkü ekiptir.
static func _quarter(center: Dictionary, next: Dictionary) -> Dictionary:
	if SprintCatalog.quarter_pm() == null:
		return {"state": "locked_no_pm", "goal": null, "columns": []}
	if center.sprint < 0:
		return {"state": "open", "goal": null, "columns": []}
	var total: float = SprintSystem.capacity()
	var columns: Array = [{"sprint": center.sprint, "kind": "current", "capacity": center.capacity, "pm": false,
		"flags": _flags(center.sprint), "cards": center.cards, "approved": false}]
	for plan in SprintCatalog.pm_plans():
		var cards: Array = (next.cards if plan.number == next.sprint else []) + plan.cards.map(
			func(id: String) -> Dictionary: return _card(SprintCatalog.card_by_id(id), SprintCard.State.PLANLANAN))
		var used: float = 0.0
		var segments: Array = []
		for c in cards:
			var pts: float = c.remaining if c.remaining >= 0 else c.effort
			used += pts
			segments.append({"pts": pts})
		columns.append({"sprint": plan.number, "kind": "proposed", "capacity": _bar(used, total, 0, segments),
			"pm": true, "flags": _flags(plan.number), "cards": cards, "approved": plan.approved})
	for n in range(columns.back().sprint + 1,
			center.sprint + int(SprintCatalog.cfg("quarter_weeks") / SprintCatalog.cfg("sprint_weeks"))):
		columns.append({"sprint": n, "kind": "empty", "capacity": null, "pm": false, "flags": _flags(n), "cards": [],
			"approved": false})
	return {"state": "open", "goal": _goal(), "columns": columns}


## Hedef şeridi: alan seviyesinin hedefe (beklentiye) oranı onluk vekil ölçekte, hedef ortadaki
## çizgidedir; alanın cümlesi o çizgiyi anlatır.
static func _goal() -> Dictionary:
	var id: String = SprintCatalog.quarter_goal()
	var mark: int = int(SprintCatalog.cfg("pm.goal_mark"))
	var total: int = int(SprintCatalog.cfg("pm.goal_squares"))
	var now: int = mini(roundi(SprintCatalog.area_level(id) / SprintCatalog.expectation(id) * mark), total)
	return {"area_id": id, "area_name": SprintCatalog.area_short(id), "text": goal_text(id),
		"now": now, "target": mark, "total": total,
		"progress_text": _t("PRODUCT_GOAL_PROGRESS").format({"now": now, "total": total})}


## Alanın çeyrek hedefi olarak cümlesi (şerit ve hedef menüsü); fikstür de buradan okur.
static func goal_text(area_id: String) -> String:
	return _t("PRODUCT_GOAL_" + area_id.to_upper())


# --- Kart ------------------------------------------------------------------------------

static func _card(c: Dictionary, state: SprintCard.State, extra := {}) -> Dictionary:
	var card := {"id": c.id, "name": SprintCatalog.card_name(c), "kind": _kind(c), "roles": c.roles,
		"effort": roundi(SprintSystem.total(c)), "state": state, "effect": SprintCatalog.card_effect(c),
		"tag_sprint": -1, "phases": [], "phase_pts": null, "assignees": [], "queued": false, "decision": null,
		"effort_split": [], "locked_node": "", "locked_rnd": "",
		"remaining": -1, "spills": false, "no_start": -1, "planned_done": 0.0, "addable": false, "ready": -1.0,
		"urgent": SprintCatalog.is_urgent(c), "buttons": BUTTONS.get(state, [])}
	card.merge(extra, true)
	return card


## Sprinte ya da sonrakine alınmış ama kapısı sonradan kapanmış kart kilitli çizilir ve yalnız
## çıkarılır: başlatma onu almaz, "→" ve "↑" onu reddeder.
static func _planned(c: Dictionary, state: SprintCard.State, extra: Dictionary) -> Dictionary:
	var lock: String = SprintCatalog.gate_reason(c.step)
	if lock == "":
		return _card(c, state, extra)
	return _card(c, SprintCard.State.KILITLI, extra.merged({"locked_node": lock, "locked_rnd": _locked_rnd(c.step),
		"buttons": ["remove"]}, true))


## Kilidin ilk açılmamış Ar-Ge düğümü; kilit araştırma değilse "".
static func _locked_rnd(step: String) -> String:
	for part in LineGates.unmet_parts(step):
		if part.kind == LineGates.KIND_RESEARCH:
			return part.node
	return ""


## Talep kartı çizimde yeni özellik kartıdır.
static func _kind(c: Dictionary) -> String:
	return "feature" if c.kind == "request" else c.kind


## Önceki sprintten ilerlemeyle gelen kartın kalan puanı; ilerlemesi eforundan bir şey eksiltmediyse
## -1 (kart eforuyla durur).
static func _remaining(c: Dictionary) -> float:
	var left: float = SprintSystem.remaining(c)
	return left if left < SprintSystem.total(c) - SprintSystem.EPS else -1.0


## Faz noktası: sıradaki fazdan öncekiler bitti, o sürüyor, sonrakiler bekliyor.
static func _phases(c: Dictionary) -> Array:
	var at: int = SprintSystem.phase(c)
	return range(3).map(func(i: int) -> String: return "done" if i < at else ("active" if i == at else "waiting"))


## Bekleyen sprint kararı: kâğıdı gelen kutusundadır (açıldıysa ekrandaki karardır); satır kâğıdın
## göndericisini, konusunu ve kalan süresini okur.
static func _decision() -> Variant:
	var paper: Dictionary = SprintSystem.decision_paper()
	if paper.is_empty():
		return null
	var it: Dictionary = INBOX.active_item() if EventGate.active_id() == paper.event_id \
		else INBOX.desk().filter(func(i: Dictionary) -> bool: return i.kind == "paper" and i.key == paper.id)[0]
	return {"event_id": paper.event_id, "item": it.id, "sender": it.sender, "subject": it.subject,
		"weeks_left": int(paper.weeks_left), "last": paper.last}


# --- Ekip ------------------------------------------------------------------------------

## Lider: Liderlik'i en yüksek aktif çalışan (eşitlikte küçük kimlik), yoksa kurucu.
static func _lead() -> Character:
	var lead: Character = CharacterRegistry.get_founder()
	var best: int = -1
	for c in CharacterRegistry.get_active_employees():
		var v: int = HRSystem.skill(c, HRConstants.SKILL_LEADERSHIP)
		if v > best or (v == best and c.id < lead.id):
			best = v
			lead = c
	return lead


## Haftanın atananları; ekipten hafta ortasında düşen (ayrılan, izne giden) kartta çizilmez.
static func _people(ids: Array, team: Array) -> Array:
	var here: Array = team.map(func(t: Dictionary) -> String: return t.id)
	return ids.filter(func(id: String) -> bool: return id in here).map(
		func(id: String) -> Dictionary: return _person(CharacterRegistry.get_character(id)))


static func _person(c: Character) -> Dictionary:
	return {"name": c.character_name, "role_text": HRConstants.role_label(c.role), "look": c.look}


# --- Yardımcılar -------------------------------------------------------------------------

## Kapasite çubuğu: kapasite yoksa kilitli, aşılmışsa taşkın.
static func _bar(used: float, total: float, done: float, segments: Array) -> Dictionary:
	return {"used": used, "total": total, "done": done,
		"state": "blocked" if total == 0 else ("over" if used > total + SprintSystem.EPS else "ok"), "segments": segments}


static func _t(key: String) -> String:
	return TranslationServer.translate(key)
