class_name ProductModel
extends RefCounted

# Ürün sekmesinin sprint ekranının görünüm sözleşmesi. Sekme yalnız bu Dictionary'yi çizer.
# Üreten (canlı adaptör ya da debug fikstürü) içerik alanlarını çözülmüş metin olarak verir;
# eşik ve izinler bool gelir. Bileşenler kendi dilbilgisini PRODUCT_* anahtarlarından kurar.
#
# PRD terimi → sözleşme adı:
#   Alan → area {id, name, slot} · Yetenek / Kademe → capability {name, tier 0..3}
#   Kart → card {id, kind, effort, roles, phases, state, assignees, effect}
#   Sprint → center {sprint, capacity, cards, beta} · Sürüm → center.release {version, shipped, carried, velocity, press}
#   tür yeni/cila/düzeltme/araştırma → kind feature|polish|fix|research
#   kart durumları → SprintCard.State · fazlar → phases [design, dev, test], her biri done|active|waiting
#   roller → roles: design|dev|test|product (en çok üç ikon)
#
# model = {
#   header: {name, live_version: "1.4" or "" (MVP öncesi), market: "B2C"|"B2B", type_text (büyük harf)},
#   versions: [{label: "v1.4", sprint: int or -1, shipped_count: int or -1}],   # -1 çizilmez
#   quarter: {state: "locked_no_pm"|"open",
#             goal: {slot, area_name, text, now, target, total, progress_text} or null, columns: [column]},
#   ui: {view: "sprint"|"quarter", open_area: area id or "", history_open, voices_open, hover_card: card id or ""},
#   areas: [area],
#   customers: null (B2C, satır yok) | [customer] ([] = "Açık talep yok"),
#   center: center,
#   next: {sprint: int or -1, flags: [{k: "rival"|"deadline", text}], cards: [card]},
# }
# area = {id, name, slot 0..4, level 0..3 (.5 olabilir), level_to: -1 or 0..3 (sürüm oku),
#         word: "strong"|"enough"|"weak"|"none", word_to: "" or word, sentence, tone: "normal"|"alert",
#         voices: {n, new}, alert ("!"), rival_topic: "" or String,
#         capabilities: [{name, tier 0..3, rivals_have, rivals_total, rival_names: [String]}],
#         candidates: [card], voices_list: [{text, new}], empty (aday kalmadı)}
# customer = {name, request: "" or String, tickets, tag_sprint: -1 or int, due_sprint: -1 or int,
#             value (yıllık $), area_slot: -1 or int, area_name, card_id (talebin kartı), buttons: [...]}
# center = {mode: "plan"|"active"|"release", sprint (-1 = sprint yok), weeks, week (active),
#           capacity: {used, total, done, state: "ok"|"over"|"blocked", segments: [{slot, pts}]} or null,
#           team: [{initials, name, role_text, me}], warning_text: "" or String, cards: [card],
#           forecast: [part], status: {done, running, decisions},
#           next_version: {label, weeks: int or -1, beta_extra, cards_left: int or -1} or null,
#           can_add, can_start, start_block ("En az bir kart ekle" ipucu), beta: {open} or null,
#           lead_tip: {initials, name, text} or null,
#           release: {version: "v5" or "" (sürüm çıkmadı), beta, shipped: [card],
#                     carried: [{name, kind, slot, done, total, to_sprint}], velocity: {done, total},
#                     result: {kind: "expected"|"actual", text} or null, press, lead: {initials, name, text}} or null}
# column = {sprint, kind: "current"|"proposed"|"empty", capacity: {...} or null, pm, flags: [...], cards: [card], approved}
# card = {id, name, kind, slot, roles: [...], effort, state: SprintCard.State, effect: [part], tag_sprint: -1 or int,
#         phases: [] or [3 states], assignees: [{initials, name, role_text}],
#         decision: {event_id, initials, speaker, text} or null, effort_split: [{name, weeks}],
#         locked_node: "" or String, remaining: -1 or int, spills, urgent,
#         buttons: ["add"|"send_next"|"pull"|"remove"]}   # var olan düğmeler; "+" can_add ile açılır
# part = {k: "level", area, from, to, from_word, to_word} | {k: "holds", area, word} | {k: "alert_clear", area}
#      | {k: "cap", name, from, to, from_word, to_word} | {k: "tickets", n} | {k: "voices", n}
#      | {k: "request", customer, value} | {k: "rival_gap"} | {k: "research", area} | {k: "request_on_time", customer}
#   level ve cap parçalarında from/to seviyedir (0..3); from_word/to_word o seviyenin beklentiye göre
#   kelimesidir (SprintCatalog.word_for), kelime ve renk ondan.

## Kartın bulunduğu yerdeki düğmeleri; "+" modelin can_add'iyle açılır.
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
				"shipped_count": -1 if int(r.sprint) < 0 else r.shipped.size()})
	var live_now: bool = ProductState.is_live()
	var center: Dictionary = _center(mode, release)
	var next: Dictionary = _next(mode)
	return {
		"header": {
			# Adsız ürün tür adıyla okunur.
			"name": SalesSystem.product_display_name(),
			"live_version": SprintSystem.version_text(ProductState.version()) if live_now else "",
			"market": ProductState.market_type().to_upper(),
			"type_text": Fmt.upper(ProductCatalog.type_name(ProductState.subtype())),
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

## Kırmızımsı zemin hem "!" hem beklentinin altında kalan alan içindir. Sürüm notunda değişen
## alan oklu okunur: eski seviye ve kelimesi → bugünkü.
static func _area(id: String, tags: Dictionary, changed: Dictionary) -> Dictionary:
	var word: String = SprintCatalog.area_word(id)
	var alert: bool = SprintCatalog.area_alert(id)
	var voices: Array = SprintCatalog.voices(id)
	var candidates: Array = SprintCatalog.candidates(id).map(
		func(c: Dictionary) -> Dictionary: return _candidate(c, tags))
	var area := {"id": id, "name": SprintCatalog.area_name(id), "slot": _slot(id),
		"level": SprintCatalog.area_level(id), "level_to": -1, "word": word, "word_to": "",
		"sentence": SprintCatalog.area_sentence(id), "tone": "alert" if alert or word == "weak" else "normal",
		"voices": {"n": voices.size(), "new": voices.filter(func(v: Dictionary) -> bool: return v.new).size()},
		"alert": alert, "rival_topic": SprintCatalog.rival_topic(id),
		"capabilities": SprintCatalog.capabilities(id).map(_capability),
		"candidates": candidates, "voices_list": voices, "empty": candidates.is_empty()}
	if not changed.is_empty():
		area.level = float(changed.from)
		area.level_to = float(changed.to)
		area.word = SprintCatalog.word_for(float(changed.from), SprintCatalog.expectation(id))
		area.word_to = word
	return area


static func _capability(line_id: String) -> Dictionary:
	var rivals: Array = SprintCatalog.rival_names(line_id)
	return {"name": SprintCatalog.cap_name(line_id), "tier": SprintCatalog.tier(line_id), "rivals_have": rivals.size(),
		"rivals_total": SprintCatalog.rival_table().rivals.size(), "rival_names": rivals}


## Aday: sprintte ya da sonrakinde duran kart soluk ve damgalı, kapısı kapalı kart kilitli.
static func _candidate(c: Dictionary, tags: Dictionary) -> Dictionary:
	if c.state != "candidate":
		return _card(c, SprintCard.State.ADAY_ALINMIS, {"tag_sprint": tags.get(c.id, -1)})
	var lock: String = SprintCatalog.gate_reason(c.step)
	if lock != "":
		return _card(c, SprintCard.State.KILITLI, {"locked_node": lock})
	return _card(c, SprintCard.State.ADAY)


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
			"tag_sprint": tag, "due_sprint": int(r.due_sprint), "value": int(r.value), "area_slot": _slot(area_id),
			"area_name": SprintCatalog.area_short(area_id), "card_id": card_id,
			"buttons": BUTTONS[SprintCard.State.ADAY] if tag < 0 else []})
	return out


# --- Bu sprint ------------------------------------------------------------------------

static func _center(mode: String, release: Dictionary) -> Dictionary:
	var p: Dictionary = GameState.product
	var sprint: Dictionary = p.get("sprint", {})
	var n: int = SprintSystem.sprint_number()
	var weeks: int = int(SprintCatalog.cfg("sprint_weeks"))
	var total: int = SprintSystem.capacity()
	var used: int = SprintSystem.used()
	var team: Array = SprintSystem.team()
	var lead: Character = _lead()
	var sprint_cards: Array = sprint.get("cards", [])
	var cards: Array = []
	var segments: Array = []
	var load: int = 0
	var status := {"done": 0, "running": 0, "decisions": 0}
	# Kapasite çubuğunun dilimleri kartların yüküdür (SprintSystem.card_load).
	for id in sprint_cards:
		var c: Dictionary = p.cards[id]
		var card: Dictionary
		var pts: int = SprintSystem.card_load(c)
		match [mode, c.state]:
			["plan", _]:
				card = _card(c, SprintCard.State.SPRINT_PLAN, {"remaining": _remaining(c),
					"effort_split": SprintSystem.effort_split(id)})
				load += pts
				card.spills = load > total
			[_, "done"]:
				card = _card(c, SprintCard.State.BITTI, {"phases": _phases(c), "assignees": _people(c.assignees)})
				status.done += 1
			_:
				card = _card(c, SprintCard.State.SPRINT_AKTIF, {"phases": _phases(c),
					"assignees": _people(c.assignees), "decision": _decision(c, lead)})
				status.running += 1
				status.decisions += int(c.decision)
		segments.append({"slot": card.slot, "pts": pts})
		cards.append(card)
	# Betada bekleyen kartlar bu sprintin sonunda yayına girer; kapasite tüketmez.
	for c in p.get("cards", {}).values():
		if c.state == "beta" and mode != "release":
			cards.append(_card(c, SprintCard.State.BETA_BEKLIYOR))
	var lead_ids: Array = SprintCatalog.lead_suggestion() if mode == "plan" and not sprint.get("lead_applied", false) else []
	var warning: String = ""
	if team.is_empty():
		warning = _t("PRODUCT_TEAM_NOBODY")
	elif not team.any(func(t: Dictionary) -> bool: return "test" in t.fits):
		warning = _t("PRODUCT_ROLE_MISSING").format({"role": HRConstants.area_label("qa")})
	return {
		"mode": mode, "sprint": n if n > 0 else -1, "weeks": weeks, "week": SprintSystem.week(),
		"capacity": _bar(used, total, SprintSystem.done_points(), segments) if n > 0 else null,
		"team": team.map(func(t: Dictionary) -> Dictionary:
			return _person(CharacterRegistry.get_character(t.id)).merged({"me": t.founder})),
		"warning_text": warning, "cards": cards,
		"forecast": SprintCatalog.forecast(sprint_cards) if mode == "plan" else [],
		"status": status,
		"next_version": {"label": SprintSystem.version_label(ProductState.version() + 1),
			"weeks": weeks - maxi(SprintSystem.week(), 1) + 1, "beta_extra": bool(sprint.get("beta", false)),
			"cards_left": -1 if ProductState.is_live() else SprintCatalog.mvp_cards_left()} if n > 0 else null,
		"can_add": SprintSystem.can_add(), "can_start": SprintSystem.can_start(),
		"start_block": mode == "plan" and sprint_cards.is_empty(),
		"beta": {"open": bool(sprint.get("beta", false))} if n > 0 else null,
		"lead_tip": null if lead_ids.is_empty() else _person(lead).merged({"text": SprintCatalog.lead_sentence(lead_ids)}),
		"release": _release(release, lead) if not release.is_empty() else null,
	}


## Sürüm notu: çıkanlar bitmiş kart, devredenler ilerlemesiyle; sonuç ertesi gün gerçekleşene döner.
static func _release(r: Dictionary, lead: Character) -> Dictionary:
	var actual: Dictionary = r.get("actual", {})
	var said: Dictionary = actual if not actual.is_empty() else r.get("expected", {})
	var press: Dictionary = r.get("press", {})
	return {
		# Betaya giden kartların sürümü bir sprint sonra çıkar: not o sürümün numarasını taşır.
		"version": SprintSystem.version_label(int(r.number) if int(r.number) > 0 or not r.beta
			else ProductState.version() + 1),
		"beta": r.beta,
		"shipped": r.shipped.map(func(c: Dictionary) -> Dictionary: return _card(c, SprintCard.State.BITTI)),
		"carried": r.carried.map(func(item: Dictionary) -> Dictionary:
			var c: Dictionary = SprintCatalog.card_by_id(item.id)
			return {"name": SprintCatalog.card_name(c), "kind": _kind(c), "slot": _slot(c.area), "done": item.done,
				"total": item.total, "to_sprint": int(item.to_sprint)}),
		"velocity": r.velocity,
		"result": null if said.is_empty() else {"kind": "expected" if actual.is_empty() else "actual",
			"text": SprintBridges.resolve(said)},
		"press": "" if press.is_empty() else _t(press.outlet) + SprintUiShared.SEP + SprintBridges.resolve(press),
		"lead": _person(lead).merged({"text": SprintCatalog.release_lead_sentence(r)}),
	}


# --- Sonraki sprint -----------------------------------------------------------------

## Sprint sürerken ya da sürüm notunda kart bu sprinte çekilemez.
static func _next(mode: String) -> Dictionary:
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
				cards.append(_card(c, SprintCard.State.DEVREDEN, {"remaining": _remaining(c), "buttons": buttons}))
			"beta":
				cards.append(_card(c, SprintCard.State.BETA_BEKLIYOR))
			_:
				cards.append(_card(c, SprintCard.State.PLANLANAN, {"buttons": buttons}))
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

## ÇEYREK PM varken açılır. Sütunlar bu sprint, PM'in planladığı sprintler ve çeyreği altı sütuna
## tamamlayan boşlardır; sonraki sprintin sütunu orada duran kartların üstüne PM'in önerisini
## ekler. Gelecek sprintin kapasitesi bugünkü ekiptir.
static func _quarter(center: Dictionary, next: Dictionary) -> Dictionary:
	if SprintCatalog.quarter_pm() == null:
		return {"state": "locked_no_pm", "goal": null, "columns": []}
	if center.sprint < 0:
		return {"state": "open", "goal": null, "columns": []}
	var total: int = SprintSystem.capacity()
	var columns: Array = [{"sprint": center.sprint, "kind": "current", "capacity": center.capacity, "pm": false,
		"flags": _flags(center.sprint), "cards": center.cards, "approved": false}]
	for plan in SprintCatalog.pm_plans():
		var cards: Array = (next.cards if plan.number == next.sprint else []) + plan.cards.map(
			func(id: String) -> Dictionary: return _card(SprintCatalog.card_by_id(id), SprintCard.State.PLANLANAN))
		var used: int = 0
		var segments: Array = []
		for c in cards:
			var pts: int = c.remaining if c.remaining >= 0 else c.effort
			used += pts
			segments.append({"slot": c.slot, "pts": pts})
		columns.append({"sprint": plan.number, "kind": "proposed", "capacity": _bar(used, total, 0, segments),
			"pm": true, "flags": _flags(plan.number), "cards": cards, "approved": plan.approved})
	for n in range(columns.back().sprint + 1, center.sprint + int(SprintCatalog.cfg("quarter_sprints"))):
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
	return {"slot": _slot(id), "area_name": SprintCatalog.area_short(id), "text": _t("PRODUCT_GOAL_" + id.to_upper()),
		"now": now, "target": mark, "total": total,
		"progress_text": _t("PRODUCT_GOAL_PROGRESS").format({"now": now, "total": total})}


# --- Kart ------------------------------------------------------------------------------

static func _card(c: Dictionary, state: SprintCard.State, extra := {}) -> Dictionary:
	var card := {"id": c.id, "name": SprintCatalog.card_name(c), "kind": _kind(c), "slot": _slot(c.area),
		"roles": c.roles, "effort": roundi(SprintSystem.total(c)), "state": state, "effect": SprintCatalog.card_effect(c),
		"tag_sprint": -1, "phases": [], "assignees": [], "decision": null, "effort_split": [], "locked_node": "",
		"remaining": -1, "spills": false, "urgent": SprintCatalog.is_urgent(c), "buttons": BUTTONS.get(state, [])}
	card.merge(extra, true)
	return card


## Talep kartı çizimde yeni özellik kartıdır.
static func _kind(c: Dictionary) -> String:
	return "feature" if c.kind == "request" else c.kind


## Önceki sprintten ilerlemeyle gelen kartın kalan puanı; ilerlemesi eforundan bir şey eksiltmediyse
## -1 (kart eforuyla durur).
static func _remaining(c: Dictionary) -> int:
	var left: int = SprintSystem.remaining(c)
	return left if left < roundi(SprintSystem.total(c)) else -1


## Faz noktası: sıradaki fazdan öncekiler bitti, o sürüyor, sonrakiler bekliyor.
static func _phases(c: Dictionary) -> Array:
	var at: int = SprintSystem.phase(c)
	return range(3).map(func(i: int) -> String: return "done" if i < at else ("active" if i == at else "waiting"))


## Karar bekleyen kartın satırı: olay kartının başlığı, konuşan kartın sahibi ya da lider.
static func _decision(c: Dictionary, lead: Character) -> Variant:
	if not c.decision:
		return null
	var pending: Dictionary = GameState.product.decision
	var ev: GameEvent = EvPresenter.build_view(String(pending.event_id), {})
	var speaker: Character = CharacterRegistry.get_character(ev.character_id) if ev.character_id != "" else lead
	return {"event_id": pending.event_id, "initials": UiFactory.initials_of(speaker.character_name),
		"speaker": speaker.character_name, "text": ev.title}


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


static func _people(ids: Array) -> Array:
	return ids.map(func(id: Variant) -> Dictionary: return _person(CharacterRegistry.get_character(String(id))))


static func _person(c: Character) -> Dictionary:
	return {"initials": UiFactory.initials_of(c.character_name), "name": c.character_name,
		"role_text": HRConstants.role_label(c.role)}


# --- Yardımcılar -------------------------------------------------------------------------

static func _slot(area_id: String) -> int:
	return int(SprintCatalog.area_def(area_id).slot)


## Kapasite çubuğu: kapasite yoksa kilitli, aşılmışsa taşkın.
static func _bar(used: int, total: int, done: int, segments: Array) -> Dictionary:
	return {"used": used, "total": total, "done": done,
		"state": "blocked" if total == 0 else ("over" if used > total else "ok"), "segments": segments}


static func _t(key: String) -> String:
	return TranslationServer.translate(key)
