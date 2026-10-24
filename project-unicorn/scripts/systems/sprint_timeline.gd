class_name SprintTimeline
extends RefCounted

# Sprintin zaman ekseni: motorun oynatmasının günlüğünden (SprintSystem.timeline) her kartın aşamalarının sprint içindeki yeri,
# beklemeler, kurucunun görüşme günleri ve kişilerin parçaları. Okur ve yerleştirir, motorun sonucunu yazmaz. Zaman sprintin
# başından hafta sayılır (kesirli, sprint çizgisi `sprint_weeks`); koşan sprintte eksenin başı (`start`) bu haftanın başıdır.
#
# Kişinin haftası: kişinin her parçası haftalık puanına oranla ardışık bir aralık alır, sıfırdan başlar ve harcama sırasıyla
# ilerler. Kartın haftası: kartın o haftaki parçalarının en erken başlangıcından en geç bitişine; aşamalar o aralığa faz sırasıyla
# ve o haftaki işleriyle orantılı genişlikte arka arkaya yerleşir, böylece bir aşama aynı kartın önceki aşaması bitmeden
# başlamaz. Testin bulduğu hatanın Geliştirmedeki düzeltme işi test bittikten sonra yapılır: kartın sonunda ayrı bir Geliştirme
# aşaması (`fix`) olur. Aşama sayıları (`need`, `pre`, `done0`, `in_sprint`, `out`, parçaların işi) kartın hazırlanma kazancına
# bölünür (görünen efor); `need_raw` bölünmemiş hâlidir.
#
# timeline = {start, close_at, team: {satır: ekibin haftalık puanı}, outcome (planlamada `plan_outcome` ile aynı oynatmanın
#             sonucu, SprintSystem.timeline yazar; yoksa null),
#             cards: {kart: {finishes, founder, late, h, h0, prep: {by, gain, done}, stages: [stage]}},
#             ahead: {kart: {prep: {by, done}, <aşama>: {done, people, start}}},
#             people: {kişi: {busy, unspent, row, pieces: [{from, to, card, stage, ahead}]}}}
# stage = {stage ("design" | "dev" | "test" | "product"), fix, need, need_raw, pre (sprintten önce yapılmış), done0 (sprintte,
#          eksenin başından önce yapılmış), in_sprint (eksenin sonuna dek yapılan, done0 dahil), out (sprint çizgisinden
#          sonraya kalan), out_from, out_to (sprint dışı payın taralı alanı), start, end (-1: bu eksende aralığı yok), before
#          (koşan sprintte eksenin başından önce bitti; start = end = -1), people,
#          waits: [{from, to, person, role, busy: {card, stage} ya da {}}], meet: [{from, to, kinds, week}],
#          pieces: [{from, to, work, people}]}
# Önden iş (`ahead: true`) yalnız kişinin parçalarındadır; sprintin kartının aşama parçası önden iş olmaz. Kişinin `row`u kapasite
# satırıdır (`capacity_rows`), `unspent` hiçbir karta (önden işe de) harcanmayan ham puandır. Dördüncü girdi (`fix: true`) Test'ten sonra
# gelir ve düzeltme işini taşır: testin bulduğu da, oynatmanın öngördüğü de (kartın gerçek bitişi); kartın eforuna yalnız bulunmuş
# olan sayılır (ProductModel).

## Kartın aşama türleri faz sırasıdır; sonuncusu testten sonra Geliştirmeye dönen düzeltme işidir.
const FIX := 3
## Sprint dışı payın taralı alanı en çok bu kadar hafta uzar.
const OUT_MAX := 0.6


## `run` (SprintSystem._replay biçimi), oynatmanın `log`u, oynatılan `people` ekibi, eksenin başı `start` ve sprint koşuyor
## mu (`running`: sprintten önce yapılmış iş kartın `progress_at_start`ıdır).
static func build(run: Dictionary, log: Array, people: Array, start: int, running: bool) -> Dictionary:
	var by_id: Dictionary = {}
	var founder := ""
	for person in people:
		by_id[person.id] = person
		if person.founder:
			founder = person.id
	var seen: Dictionary = _clock(log, by_id, start)
	var lost: float = 1.0 - GameState.founder_sprint_pay
	var ctx := {"start": start, "weeks": log.size(), "running": running, "founder": founder, "by_id": by_id, "seen": seen,
		"rows": capacity_rows(people, seen[founder].roles if founder != "" else {}), "lost": lost, "hatch": _hatches(log, founder, start, lost),
		"by_card": _by_card(log),
		"kinds": GameState.founder_meetings_frozen.map(func(m: Dictionary) -> String: return m.kind)}
	var cards: Dictionary = {}
	for i in run.cards.size():
		cards[run.cards[i].id] = _card(run.from[i], run.cards[i], ctx)
	var closes: int = start + log.size()
	if not cards.is_empty() and cards.values().all(func(card: Dictionary) -> bool: return card.finishes):
		closes = start + 1
		for j in log.size():
			if not log[j].cards.is_empty():
				closes = start + j + 1
	return {"start": start, "close_at": float(closes), "cards": cards, "ahead": _ahead(run, log, running),
		"people": _people(seen, by_id, ctx.rows, log.size()), "team": ctx.rows.points}


## Aşamanın `at` anına dek yapılan işi (sprintte, eksenin başındakiyle birlikte): parçanın işi parça içinde doğrusal akar.
static func done_at(stage: Dictionary, at: float) -> float:
	var done: float = stage.done0
	for piece in stage.pieces:
		done += float(piece.work) * clampf((at - piece.from) / maxf(piece.to - piece.from, SprintSystem.EPS), 0.0, 1.0)
	return done


## Günlüğün her kaydına kişinin zamanında yerini (`from`, `to`) yazar. {kişi: {pieces, spent (önden iş dahil kartlara harcanan
## bütçe), roles (sprintin kartlarında aşama başına süre)}}.
static func _clock(log: Array, by_id: Dictionary, start: int) -> Dictionary:
	var seen: Dictionary = {}
	for id in by_id:
		seen[id] = {"pieces": [], "spent": 0.0, "roles": {}}
	for j in log.size():
		var at: Dictionary = {}
		for side in ["cards", "ahead"]:
			for e in log[j][side]:
				var span: float = e.spent / by_id[e.person].points
				e["from"] = start + j + float(at.get(e.person, 0.0))
				e["to"] = e.from + span
				at[e.person] = float(at.get(e.person, 0.0)) + span
				var person: Dictionary = seen[e.person]
				person.pieces.append({"from": e.from, "to": e.to, "card": e.card, "stage": e.role, "ahead": side == "ahead"})
				person.spent += e.spent
				if side == "cards":
					person.roles[e.role] = float(person.roles.get(e.role, 0.0)) + span
	return seen


## Haftanın sprint kartlarına harcama kayıtları, kart başına.
static func _by_card(log: Array) -> Array:
	return log.map(func(week: Dictionary) -> Dictionary:
		var out: Dictionary = {}
		for e in week.cards:
			(out.get_or_add(e.card, []) as Array).append(e)
		return out)


## Kurucunun haftalık görüşme taraması {from, to} ya da {} (kurucunun o hafta parçası yok): kurucunun o haftaki ilk parçasının
## başından haftanın görüşmelere giden payı `lost` (gün × 0,2 hafta) kadar. Pay hafta dönerken donar, kalan bütün haftalar onu
## alır.
static func _hatches(log: Array, founder: String, start: int, lost: float) -> Array:
	var out: Array = []
	for j in log.size():
		var works := false
		for side in ["cards", "ahead"]:
			for e in log[j][side]:
				works = works or e.person == founder
		out.append({"from": float(start + j), "to": start + j + lost} if works and lost > SprintSystem.EPS else {})
	return out


## Kapasite satırları: {of: {kişi: satır ya da "" (PM)}, points: {satır: ekibin haftalık puanı}}; satır kuralının tek evi.
## Çalışanın satırı rolünün aşamasıdır; kurucununki `founder_roles`ta (kartlarda aşama başına süre) en çok çalıştığı aşama,
## hiç çalışmıyorsa (zaman ekseni yokken de) Geliştirme.
static func capacity_rows(people: Array, founder_roles: Dictionary = {}) -> Dictionary:
	var of: Dictionary = {}
	for person in people:
		var row := "dev"
		if not person.founder:
			row = SprintCatalog.row_of(CharacterRegistry.get_character(person.id))
		else:
			for role in ["design", "dev", "test"]:
				if founder_roles.get(role, 0.0) > founder_roles.get(row, 0.0):
					row = role
		of[person.id] = row
	var points: Dictionary = row_power(people, of)
	for row in points:
		points[row] /= SprintSystem.sprint_weeks()
	return {"of": of, "points": points}


## Satır başına ekibin sprint boyunca puanı: her satırın kişileri `SprintSystem.capacity_of`a verilir. `of` kişinin satırıdır
## (PM'in satırı yoktur).
static func row_power(people: Array, of: Dictionary) -> Dictionary:
	var seated: Dictionary = {}
	for person in people:
		if of[person.id] != "":
			(seated.get_or_add(of[person.id], []) as Array).append(person)
	var power: Dictionary = {}
	for row in seated:
		power[row] = SprintSystem.capacity_of(seated[row])
	return power


## Kartın zaman ekseni kaydı: `c0` sprintin başındaki kart, `c1` oynatılmış kopyası.
static func _card(c0: Dictionary, c1: Dictionary, ctx: Dictionary) -> Dictionary:
	var k: float = 1.0 + float(c1.get("prep_gain", 0.0))
	var fix := 0.0
	for cost in c1.get("fix", []):
		fix += float(cost)
	var base: float = float(c1.need[1]) - fix
	var keys: Array = SprintCatalog.cfg("roles." + String(c1.kind))
	var pre_at: Array = c0.get("progress_at_start", c0.progress) if ctx.running else c0.progress
	var total: Array = [c1.need[0], base, c1.need[2], fix]
	var pre: Array = [pre_at[0], minf(pre_at[1], base), pre_at[2], maxf(0.0, pre_at[1] - base)]
	var begun: Array = [c0.progress[0], minf(c0.progress[1], base), c0.progress[2], maxf(0.0, c0.progress[1] - base)]
	var ended: Array = [c1.progress[0], minf(c1.progress[1], base), c1.progress[2], maxf(0.0, c1.progress[1] - base)]
	var stages: Array = []
	for kind in (4 if fix > SprintSystem.EPS else 3):
		var left: float = maxf(0.0, total[kind] - pre[kind])
		stages.append({"stage": keys[1 if kind == FIX else kind], "fix": kind == FIX, "need": left / k, "need_raw": left,
			"pre": pre[kind] / k, "done0": maxf(0.0, begun[kind] - pre[kind]) / k,
			"in_sprint": maxf(0.0, ended[kind] - pre[kind]) / k, "out": maxf(0.0, total[kind] - ended[kind]) / k,
			"before": ctx.running and total[kind] > SprintSystem.EPS and begun[kind] >= total[kind] - SprintSystem.EPS,
			"out_from": -1.0, "out_to": -1.0, "start": -1.0, "end": -1.0, "people": [], "waits": [], "meet": [], "pieces": []})
	var by_founder := false
	var dev: float = float(c0.progress[1])
	for j in ctx.weeks:
		var entries: Array = ctx.by_card[j].get(c1.id, [])
		for e in entries:
			e["kind"] = e.stage
			if e.stage == SprintSystem.DEV_PHASE:
				e["kind"] = FIX if dev >= base - SprintSystem.EPS else SprintSystem.DEV_PHASE
				dev += e.work
			by_founder = by_founder or e.person == ctx.founder
		_lay(entries, stages, k, j, ctx)
	_span(stages, ctx)
	var finishes: bool = SprintSystem.phase(c1) == SprintSystem.PHASE_DONE
	var judged: Dictionary = c1 if fix <= SprintSystem.EPS else c1.merged({"need": [c1.need[0], base, c1.need[2]]}, true)
	var risk: Dictionary = SprintBugs.expected(judged)
	return {"finishes": finishes, "founder": by_founder, "late": by_founder and not finishes and ctx.lost > SprintSystem.EPS,
		"h": risk.h, "h0": risk.h0, "stages": stages,
		"prep": {"by": c1.get("prep_by", ""), "gain": float(c1.get("prep_gain", 0.0)), "done": float(c1.get("prep_done", 0.0))}}


## Aşamaların eksendeki yeri: başlangıç ve bitiş ilk ve son parçadan, çalışanlar parçaların birleşiminden; aşama öncekinin
## bitişinden sonra başlıyorsa aradaki boşluk bekleme, hiç başlamayan aşama sprint sonuna dek bekleme; sprint dışına kalan pay
## sprint çizgisinden (ya da aşamanın bitişinden, hangisi sonraysa) taranır.
static func _span(stages: Array, ctx: Dictionary) -> void:
	var ready := float(ctx.start)
	var horizon: float = float(ctx.start + ctx.weeks)
	for stage in stages:
		if stage.pieces.is_empty():
			if stage.need - stage.done0 > SprintSystem.EPS and ready < horizon - SprintSystem.EPS:
				stage.waits.append({"from": ready, "to": horizon, "person": "", "role": stage.stage, "busy": {}})
				ready = horizon
			continue
		stage.start = stage.pieces[0].from
		stage.end = stage.pieces[-1].to
		for piece in stage.pieces:
			for id in piece.people:
				if id not in stage.people:
					stage.people.append(id)
		if stage.start > ready + SprintSystem.EPS:
			stage.waits.append(_wait(ready, stage, ctx))
		ready = stage.end
	for stage in stages:
		if stage.out > SprintSystem.EPS:
			stage.out_from = maxf(horizon, stage.end)
			var pace: float = _pace(stage, ctx)
			stage.out_to = stage.out_from + (OUT_MAX if pace <= 0.0 else minf(OUT_MAX, stage.out / pace))


## Kartın `j`. haftadaki parçaları (`kind` yazılmış) aşamalara yerleşir; kurucunun çalıştığı aşamaya o haftanın görüşme taraması
## (aşama parçasıyla kesişen kısmı) yazılır.
static func _lay(entries: Array, stages: Array, k: float, j: int, ctx: Dictionary) -> void:
	if entries.is_empty():
		return
	var first: float = INF
	var last: float = -INF
	var work: Array = [0.0, 0.0, 0.0, 0.0]
	var who: Array = [[], [], [], []]
	for e in entries:
		first = minf(first, e.from)
		last = maxf(last, e.to)
		work[e.kind] += e.work / k
		if e.person not in who[e.kind]:
			who[e.kind].append(e.person)
	var sum: float = work[0] + work[1] + work[2] + work[3]
	var hatch: Dictionary = ctx.hatch[j]
	var at: float = first
	var piece: Dictionary = {}
	for kind in stages.size():
		if work[kind] <= 0.0:
			continue
		piece = {"from": at, "to": at + (last - first) * work[kind] / sum, "work": work[kind], "people": who[kind]}
		stages[kind].pieces.append(piece)
		at = piece.to
		if ctx.founder in who[kind] and not hatch.is_empty():
			var meet_from: float = maxf(piece.from, hatch.from)
			var meet_to: float = minf(piece.to, hatch.to)
			if meet_to - meet_from > SprintSystem.EPS:
				stages[kind].meet.append({"from": meet_from, "to": meet_to, "kinds": ctx.kinds, "week": ctx.start + j + 1})
	piece.to = last


## Aşamanın başlamasını `ready`den geciktiren bekleme: aşamada sonradan çalışan ilk kişi ve o kişinin `ready` anında yaptığı iş.
static func _wait(ready: float, stage: Dictionary, ctx: Dictionary) -> Dictionary:
	var person: String = stage.people[0]
	var busy: Dictionary = {}
	for p in ctx.seen[person].pieces:
		if p.from <= ready + SprintSystem.EPS and p.to > ready + SprintSystem.EPS:
			busy = {"card": p.card, "stage": p.stage}
			break
	return {"from": ready, "to": stage.start, "person": person, "role": stage.stage, "busy": busy}


## Sprint dışı payı taramanın hızı: aşamada son çalışanların haftalık puanı; kimse çalışmadıysa aşama satırının ekibinin.
static func _pace(stage: Dictionary, ctx: Dictionary) -> float:
	if stage.pieces.is_empty():
		return float(ctx.rows.points.get(stage.stage, 0.0))
	var crew: Array = []
	for id in stage.pieces[-1].people:
		crew.append(ctx.by_id[id])
	return SprintSystem.capacity_of(crew) / SprintSystem.sprint_weeks()


## Sonraki sütunun önden hazırlanan kartları: hazırlık (planlamada oynatmanın sonundaki, koşan sprintte bugünkü) ve aşama başına
## eksen boyunca önden yapılan iş, sprint sonundaki hazırlık kazancıyla görünen efor (kart sonraki sprinte o kazançla girer).
static func _ahead(run: Dictionary, log: Array, running: bool) -> Dictionary:
	var out: Dictionary = {}
	var gain: Dictionary = {}
	for c in (run.ahead_from if running else run.ahead):
		out[c.id] = {"prep": {"by": c.get("prep_by", ""), "done": float(c.get("prep_done", 0.0))}}
	for c in run.ahead:
		gain[c.id] = 1.0 + float(c.get("prep_gain", 0.0))
	for week in log:
		for e in week.ahead:
			var stage: Dictionary = out[e.card].get_or_add(e.role, {"done": 0.0, "people": [], "start": e.from})
			stage.done += e.work / gain[e.card]
			stage.start = minf(stage.start, e.from)
			if e.person not in stage.people:
				stage.people.append(e.person)
	return out


## Kişi başına doluluk (sprintin kartlarındaki parçaların süresi ÷ oynatılan hafta, önden iş hariç), parçalar, hiçbir karta
## harcanmayan puan ve kapasite satırı.
static func _people(seen: Dictionary, by_id: Dictionary, rows: Dictionary, weeks: int) -> Dictionary:
	var out: Dictionary = {}
	for id in by_id:
		var busy := 0.0
		for p in seen[id].pieces:
			if not p.ahead:
				busy += p.to - p.from
		out[id] = {"busy": busy / weeks, "pieces": seen[id].pieces,
			"unspent": maxf(0.0, weeks * by_id[id].points - seen[id].spent), "row": rows.of[id]}
	return out
