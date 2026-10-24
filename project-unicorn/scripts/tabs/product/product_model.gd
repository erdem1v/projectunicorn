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
#   ui: {view: "overview"|"sprint"|"quarter", open_area: area id or "", history_open, hover_card: card id or "",
#         server_preview: kademe id or "" (açık geçiş önizlemesi)},
#   overview: {server: server} or null (v1.0'dan önce: GENEL BAKIŞ kilitli; fikstürde de yok),
#   areas: [area],
#   customers: null (B2C, satır yok) | [customer] ([] = "Açık talep yok"),
#   center: center,
#   next: {sprint: int or -1, flags: [{k: "rival"|"deadline", text}], cards: [card]},
# }
# area = {id, name, level 0..3 (.5 olabilir), level_to: -1 or 0..3 (sürüm oku),
#         word: "strong"|"enough"|"weak"|"none", word_to: "" or word, sentence, goal_text (çeyrek hedefi olarak),
#         bug_rows: [bug_row] (yalnız açık hatası olan hatlar, en çok hatalısı önde), alert (uyarı üçgeni),
#         rival_topic: "" or String,
#         capabilities: [{name, tier 0..3}],
#         candidates: [card], empty (aday kalmadı)}
# bug_row = {text: "Fatura · 6 açık hata · 3 hesap · 140 kullanıcı", tip, delta (son haftalık tike göre: okun yönü, 0 = ok yok)}
# customer = {name, request, tag_sprint: -1 or int, due_sprint: -1 or int,
#             value (yıllık $), area_name, card_id (talebin kartı), buttons: [...],
#             addable ("+" bu talep için açık)}
# center = {mode: "plan"|"active"|"release", sprint (-1 = sprint yok), weeks (sprintin süresi), week (active),
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
#                     reviews: [{source, text}] (B2C güncellemesinin öne çıkan yorumları, gelene dek boş),
#                     lead: person + {text, self}} or null}
# server = {tiers: [{id, name, tip (üstüne gelince; kilitliyse gerekçe), off (kilitli), preview (geçiş önizlemesi),
#                    final (Kurumsal'ın geri dönüşsüzlük notu ya da "")}], active (kademenin sırası),
#           capacity: "Kapasite 6.500 koltuk · ayda $15.600", percent (çubuğun yükü, tam yüzde; kapasitesizde 0), state
#           (InfraSystem.capacity_state), load: "Yük %80 · boş pay ..." ("" kapasitesizde),
#           note: {text, tone: "over"|"warn"|"quiet", glyph} or null (tek satır: kesinti uyarısı, son otomatik büyüme ya da büyüme),
#           clause: "Kurumsal sunucu bekleyen 2 hesap" ya da "" (maddesi açık B2B hesap yoksa),
#           decrease/increase: {text, tip}, auto: {on, tip}}
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
#         remaining: -1 or float (kesirli), priority (öncelikli düzeltme),
#         spills (planda puan alır ama bitmez), no_start: -1 or int (planda puan almaz, kaydığı sprint),
#         planned_done (kesirli, planda sprint sonunda biten puan), addable ("+" bu aday için açık),
#         ready: -1 or 0..1 (sonraki sütunda önden hazırlanan kartın hazır payı; planda sprint sonundaki),
#         buttons: ["add"|"send_next"|"pull"|"remove"]}   # var olan düğmeler; "+" addable ile açılır
# part = {k: "level", area, from, to, from_word, to_word} | {k: "holds", area, word} | {k: "alert_clear", area}
#      | {k: "cap", name, from, to, from_word, to_word} | {k: "bugs_closed", n}
#      | {k: "bugs", n, accounts (B2C'de -1), users, top ("" ise yok), top_users}   # düzeltme kartının hata satırı
#      | {k: "request", customer, value} | {k: "research", area} | {k: "request_on_time", customer}
#      | {k: "promise", customer}   # kademeye verilmiş açık söz; kart onu etiketle de taşır
#   level ve cap parçalarında from/to seviyedir (0..3); from_word/to_word o seviyenin beklentiye göre
#   kelimesidir (ProductQuality.word_for), kelime ve renk ondan.
#
# Yeni ekranın okuma yüzeyi, yukarıdakilerin yanında (efor sayıları görünen eforudur: kalan ihtiyaç ÷ hazırlık kazancı):
#   founder: {on (kurucu sprint kartı alır), locked: "" | "running" | "rnd", rnd_text},
#   requests: null (B2C) | [{customer, card_id, card_name, module_id, value (yıllık), due_text (sözün, yoksa talebin son sprinti:
#             "bu çeyrek", "gelecek çeyrek" ya da "{q}. çeyrek"), soon (bu çeyrek), planned (kartı bu sprintin planında), tip}]
#             (planlı olmayan önde, bu çeyrek önde, sonra son tarih),
#   modules: [{id, name, mono, planned (bu sprintte kartı var), candidates: [{id, name, effort, parts (aşama başına efor),
#             planned (bu sprintin planında), stamp (başka sprintte: sprint numarası, yoksa -1), addable, bugs, fix_text}]}]
#            (kilitli aday ve adaylarının hepsi kilitli modül yok),
#   prep: {pms: [{person, stars, cards (bu sprintin kartlarından hazırladıklarının adı), preparing (sonraki sütunda hazırladığı var)}]},
#   quarter: + {q, year (ürün çeyreğinin başladığı takvim çeyreği), pos, total (çeyreğin kaçıncı sprinti, kaç sprintlik)},
#   center: + {now_at (koşan sprintin haftasında şimdiki an, sprint başından hafta), close_at (SprintTimeline), progress: {done,
#             total} (koşarken), crew (bir aşamada 9'dan çok kişi varsa {n, sprint, training, leave, research, pm, out}),
#             suggest: {amount, cards: [{name, done, effort}]} | null, candidates (boş planın ilk üç önerisi: kart satırı),
#             start_skips, team_empty, mvp (v1.0'dan önce `mvp_line`ın aynısı, canlıda null)},
#   next: + {load: [{stage, carried, planned, team}], carried: [{card, card_id, stage, effort}]} (devreden: planlamada ve koşarken
#         zaman ekseninin `out`u, sürüm notunda sonraki sütunun devreden kartlarının kalan ihtiyacı; ikisini de aynı işlevler
#         hesaplar, kartın aynı aşamadaki payları tek satırdır; planlı: planlamada ve koşarken sonraki sütunun kartlarının sprint
#         sonundaki kalan ihtiyacı ve hazırlık kazancı, sürüm notunda bugünkü).
# person = {id, name, role_text, look, stars, founder}.
# Kart satırı = {id, kind, name, effort, raw_effort, module, fix_text, slot: {kind: "due" (+ text, soon) | "carried" | "late"}
#   ya da {}, pm, ask, risk, risk_raw (0..1: beklenen hatanın tavana oranı, hazırlanmamış hâli), late, founder, buttons,
#   stages (SprintTimeline aşamaları)}.
# Düzeltme işi: `effort`, `raw_effort` ve `suggest.cards[].effort` kartın kendi kalan ihtiyacıdır: testin BULDUĞU düzeltmeyi sayar
#   (test hata bulunca kartın eforu büyür), oynatmanın yalnız ÖNGÖRDÜĞÜ düzeltmeyi saymaz. `stages`taki dördüncü girdi (`fix: true`)
#   öngörüleni de taşır, çünkü kartın gerçek bitişi odur; aşama satırlarının dolgusu ve taşması da onu sayar. Gösterim kuralı:
#   planlamada ve kartın testi bitmeden o parça çizilir ama ekranda da ipucunda da hata sayısı yazmaz (plan sayıyı bulur, göstermez);
#   sayı test bitince kartın "Test: N hata buldu" satırıyla gelir. Hiçbir model alanı öngörülen hata sayısını taşımaz
#   (`risk` ve `risk_raw` göstergedir).

const INBOX := preload("res://scripts/ui/components/inbox.gd")
## Kademenin adı.
const TIER_KEYS := {InfraSystem.PROVIDER_LOCAL: "PRODUCT_SERVER_TIER_ECONOMY", InfraSystem.PROVIDER_CLOUD: "PRODUCT_SERVER_TIER_STANDARD",
	InfraSystem.PROVIDER_ENTERPRISE: "PRODUCT_SERVER_TIER_ENTERPRISE"}
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
	var n: int = SprintSystem.sprint_number()
	# Plan ekranı motorun oynatmasını söyler: kim kaç hafta, devreden, başlamayan, SPRINT SONUNDA ve sonraki
	# sütunun hazır payı. Zaman ekseni (koşan sprintte de) aynı oynatmadır: plan bir kez oynanır.
	var run: Dictionary = SprintSystem.timeline() if n > 0 and mode != "release" else {}
	var outcome: Dictionary = run.outcome if mode == "plan" and not run.is_empty() else {}
	# Liderin önerisi: eski çizim cümlesini plan uygulanmamışken, yeni çizim satırını devir kapalıyken okur.
	var delegated: bool = SprintSystem.delegated()
	var suggestion: Array = []
	if mode == "plan" and n > 0 and not (p.sprint.get("lead_applied", false) and delegated):
		suggestion = SprintCatalog.lead_suggestion()
	var planned: Array = p.get("sprint", {}).get("cards", []).map(func(id: String) -> String: return p.cards[id].area)
	var areas: Array = []
	var modules: Array = []
	var pool: Dictionary = {}
	for a in SprintCatalog.areas_for(ProductState.subtype(), ProductState.market_type()):
		var cards: Array = SprintCatalog.candidates(a.id)
		for c in cards:
			pool[c.id] = c
		var area: Dictionary = _area(a.id, cards, tags, changed.get(a.id, {}))
		areas.append(area)
		var module: Variant = _module(area, cards, a.id in planned, n)
		if module != null:
			modules.append(module)
	var center: Dictionary = _center(mode, release, outcome, suggestion)
	center.merge(_plan_view(mode, run, center, [] if delegated else suggestion, pool), true)
	var next: Dictionary = _next(mode, outcome, run)
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
		"ui": {"view": "sprint", "open_area": "", "history_open": false, "hover_card": "", "server_preview": ""},
		"overview": {"server": _server()} if live_now else null,
		"areas": areas,
		"customers": _customers(tags) if ProductState.market_type() == "b2b" else null,
		"founder": _founder(mode, center.rnd_node),
		"requests": _requests(tags),
		"modules": modules,
		"prep": _prep(),
		"center": center,
		"next": next,
	}


# --- Alanlar ve müşteriler --------------------------------------------------------

## Sürüm notunda değişen alan oklu okunur: eski seviye ve kelimesi → bugünkü. `cards` alanın aday kartlarıdır
## (`SprintCatalog.candidates`).
static func _area(id: String, cards: Array, tags: Dictionary, changed: Dictionary) -> Dictionary:
	var word: String = ProductQuality.word(id)
	var candidates: Array = cards.map(func(c: Dictionary) -> Dictionary: return _candidate(c, tags))
	var area := {"id": id, "name": SprintCatalog.area_name(id),
		"level": SprintCatalog.area_level(id), "level_to": -1, "word": word, "word_to": "",
		"sentence": SprintCatalog.area_sentence(id), "goal_text": goal_text(id),
		"bug_rows": _bug_rows(id),
		"alert": SprintCatalog.area_alert(id), "rival_topic": SprintCatalog.rival_topic(id),
		"capabilities": SprintCatalog.capabilities(id).map(_capability),
		"candidates": candidates, "empty": candidates.is_empty()}
	if not changed.is_empty():
		area.level = SprintCatalog.display_level(float(changed.from))
		area.level_to = SprintCatalog.display_level(float(changed.to))
		area.word = ProductQuality.word_for(float(changed.from), ProductQuality.expectation(id))
		area.word_to = word
	return area


static func _capability(line_id: String) -> Dictionary:
	return {"name": SprintCatalog.cap_name(line_id), "tier": SprintCatalog.tier(line_id)}


## Alanın yalnız açık hatası olan hatları, en çok hatalısı önde (eşitlikte yeteneklerin sırası).
static func _bug_rows(area_id: String) -> Array:
	var lines: Array = SprintCatalog.capabilities(area_id).filter(
		func(line_id: String) -> bool: return ProductState.line_bugs(line_id) > 0)
	var order: Array = lines.duplicate()
	lines.sort_custom(func(a: String, b: String) -> bool:
		var more: int = ProductState.line_bugs(a) - ProductState.line_bugs(b)
		return more > 0 if more != 0 else order.find(a) < order.find(b))
	return lines.map(bug_row)


## Hat satırı (alanın AÇIK HATALAR bölümü): `text` "Fatura · 6 açık hata · 3 hesap · 140 kullanıcı" (B2C'de hesapsız), `delta`
## açık hatanın son haftalık tike göre değişimi (okun yönü, 0 ise ok yok), `tip` geçen haftanın sayısı ve B2B'de en büyük hesap.
static func bug_row(line_id: String) -> Dictionary:
	return bug_row_of(SprintCatalog.cap_name(line_id), SprintCatalog.bugs_part(line_id, ProductState.line_bugs(line_id)),
		ProductState.open_bugs_delta(line_id))


## Satırın metni, hata parçasından (`SprintCatalog.bugs_part`) ve değişimden kurulur; fikstür de bunu çağırır.
static func bug_row_of(line_name: String, part: Dictionary, delta: int) -> Dictionary:
	var bits: PackedStringArray = [line_name, SprintUiShared.count("PRODUCT_BUG_COUNT", int(part.n))]
	bits.append_array(SprintUiShared.impact_bits(part))
	var tip: PackedStringArray = [_t("PRODUCT_BUGS_TIP_PREV").format(
		{"bugs": SprintUiShared.count("PRODUCT_BUG_COUNT", int(part.n) - delta)})]
	if part.top != "":
		tip.append(_t("PRODUCT_BUGS_TIP_TOP").format(
			{"account": part.top, "users": SprintUiShared.count("PRODUCT_USER_COUNT", int(part.top_users))}))
	return {"text": SprintUiShared.SEP.join(bits), "tip": "\n".join(tip), "delta": delta}


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
		out.append({"name": customer, "request": SprintCatalog.step_name(r.step),
			"tag_sprint": tag, "due_sprint": int(r.due_sprint), "value": int(r.value),
			"area_name": SprintCatalog.area_short(area_id), "card_id": card_id,
			"buttons": BUTTONS[SprintCard.State.ADAY] if tag < 0 else [], "addable": tag < 0 and SprintSystem.can_add(card_id)})
	return out


## Yeni sol sütunun modülü: kilitli aday listelenmez, adaylarının hepsi kilitli olan modül de (kilitler Ar-Ge'de görünür). `area`
## alanın çizim kaydı (adaylarının durumu ve "+"ı oradan okunur), `cards` ham adayları, `planned` modülün bu sprintin planında
## kartı olması, `sprint` bu sprintin numarası.
static func _module(area: Dictionary, cards: Array, planned: bool, sprint: int) -> Variant:
	var listed: Array = []
	for i in cards.size():
		if area.candidates[i].state != SprintCard.State.KILITLI:
			listed.append(_module_card(cards[i], area.candidates[i], sprint))
	if listed.is_empty() and not cards.is_empty():
		return null
	return {"id": area.id, "name": area.name, "mono": _t("PRODUCT_AREA_" + String(area.id).to_upper() + "_MONO"),
		"planned": planned, "candidates": listed}


## Modülün adayı: aşama başına efor (kalan ihtiyaç ÷ hazırlık kazancı), bu sprintin planında mı (tik) ya da hangi başka
## sprintte (damga) ve düzeltme kartında hata sayısı ile metni.
static func _module_card(c: Dictionary, shown: Dictionary, sprint: int) -> Dictionary:
	var parts: Array = _parts(c)
	var tag: int = shown.tag_sprint
	var fix: bool = c.kind == "fix"
	return {"id": c.id, "name": shown.name, "effort": roundi(parts[0] + parts[1] + parts[2]), "parts": parts,
		"planned": tag == sprint, "stamp": tag if tag != sprint else -1, "addable": shown.addable,
		"bugs": c.bugs if fix else 0, "fix_text": SprintUiShared.bugs_text(shown.effect[0]) if fix else ""}


## Müşteri talepleri (B2B; B2C'de null): her açık talep bir satır. Son tarih sözün, yoksa talebin son sprintidir (`_due`).
## Sıra: planı olmayan önde, bu çeyrek önde, sonra son tarih.
static func _requests(tags: Dictionary) -> Variant:
	if ProductState.market_type() != "b2b":
		return null
	var stored: Dictionary = GameState.product.get("cards", {})
	var promised: Dictionary = {}
	for promise in PromiseRegistry.get_all():
		if promise.status == "open" and promise.due_sprint >= 0:
			var key: String = promise.customer_id + "|" + promise.feature_id
			promised[key] = mini(int(promised.get(key, promise.due_sprint)), promise.due_sprint)
	var keyed: Array = []
	for r in GameState.product.get("requests", []):
		var customer: String = SprintCatalog.customer_name(r)
		if r.status != "open" or customer == "":
			continue
		var card_id: String = "feat:" + r.step if stored.has("feat:" + r.step) else String(r.card_id)
		var area_id: String = SprintCatalog.area_of_line(r.line)
		var promise: int = promised.get(String(r.customer_id) + "|" + String(r.step), -1)
		var due: int = promise if promise >= 0 else int(r.due_sprint)
		var when: Dictionary = _due(due)
		var card_name: String = SprintCatalog.step_name(r.step)
		var parts: PackedStringArray = [customer,
			_t("PRODUCT_TIP_CARD_MODULE").format({"card": card_name, "module": SprintCatalog.area_name(area_id)}),
			_t("PRODUCT_PER_YEAR").format({"amount": Fmt.money_exact(int(r.value))})]
		if promise >= 0:
			parts.append(_t("PRODUCT_TIP_PROMISE").format({"when": when.text}))
		var planned: bool = tags.get(card_id, -1) == SprintSystem.sprint_number()
		keyed.append([[int(planned), int(not when.soon), due, keyed.size()], {"customer": customer, "card_id": card_id,
			"card_name": card_name, "module_id": area_id, "value": int(r.value), "due_text": when.text, "soon": when.soon,
			"planned": planned, "tip": SprintUiShared.SEP.join(parts)}])
	keyed.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
	return keyed.map(func(k: Array) -> Dictionary: return k[1])


## Son sprintin ürün çeyreğine göre tarihi {text, soon}: çeyreğin son sprintine dek "bu çeyrek", sonraki çeyreğin içinde "gelecek
## çeyrek", ötesi o çeyreğin ilk sprintinin tahmini başlangıcının takvim çeyreği (bugünkü sprintin başından aradaki sprintler
## kadar ileri sayılır).
static func _due(sprint: int) -> Dictionary:
	var p: Dictionary = GameState.product
	var total: int = SprintSystem.sprints_in(int(SprintCatalog.cfg("quarter_weeks")))
	var ahead: int = floori(float(sprint - int(p.quarter.start_sprint)) / total)
	if ahead <= 0:
		return {"text": _t("PRODUCT_DUE_THIS_Q"), "soon": true}
	if ahead == 1:
		return {"text": _t("PRODUCT_DUE_NEXT_Q"), "soon": false}
	var first: int = int(p.quarter.start_sprint) + ahead * total
	var start: int = int(p.sprint.start_day) + (first - int(p.sprint.number)) * SprintSystem.sprint_weeks()
	return {"text": _t("PRODUCT_DUE_Q").format({"q": _calendar_quarter(GameState.get_date_dict(start))}), "soon": false}


## Kurucu anahtarı: koşan sprintte ve kurucu Ar-Ge'deyken (`rnd`: `center.rnd_node`) basılmaz, değeri saklanır.
static func _founder(mode: String, rnd: Variant) -> Dictionary:
	return {"on": GameState.founder_in_sprint, "locked": "running" if mode == "active" else ("rnd" if rnd != null else ""),
		"rnd_text": "" if rnd == null else rnd.text}


## Hazırlık: ekipteki her PM, bu sprintin kartlarından hazırladıklarının adları ve sonraki sütunda hazırladığı kart var mı.
static func _prep() -> Dictionary:
	var p: Dictionary = GameState.product
	var of := func(id: String) -> Dictionary: return p.cards[id]
	var sprint: Array = p.get("sprint", {}).get("cards", []).map(of)
	var next: Array = p.get("next", {}).get("cards", []).map(of)
	var pms: Array = []
	for c in CharacterRegistry.get_active_employees():
		if c.role != HRConstants.ROLE_PRODUCT_MANAGER:
			continue
		var face: Dictionary = _face(c, HRConstants.AREA_PRODUCT)
		var prepared: Array = sprint.filter(func(x: Dictionary) -> bool:
			return x.get("prep_by", "") == c.id and float(x.get("prep_done", 0.0)) > SprintSystem.EPS)
		pms.append({"person": face, "stars": face.stars,
			"cards": prepared.map(func(x: Dictionary) -> String: return SprintCatalog.card_name(x)),
			"preparing": next.any(func(x: Dictionary) -> bool:
				return x.get("prep_by", "") == c.id and float(x.get("prep_done", 0.0)) < 1.0 - SprintSystem.EPS)})
	return {"pms": pms}


# --- Bu sprint ------------------------------------------------------------------------

## `suggestion`: planlamada `SprintCatalog.lead_suggestion()` (planlama devredilmemişse ya da plan uygulanmamışsa okunur).
static func _center(mode: String, release: Dictionary, outcome: Dictionary, suggestion: Array) -> Dictionary:
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
					"phase_pts": {"done": float(c.progress[at]), "total": float(c.need[at])}
						if at < SprintSystem.PHASE_DONE else null,
					"decision": decision if c.decision else null})
		segments.append({"pts": pts})
		load += pts
		cards.append(card)
	var lead_ids: Array = suggestion if not sprint.get("lead_applied", false) else []
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
		"shipped": r.shipped.map(_shipped),
		"carried": r.carried.map(func(item: Dictionary) -> Dictionary:
			var c: Dictionary = SprintCatalog.card_by_id(item.id)
			return {"name": SprintCatalog.card_name(c), "kind": _kind(c), "done": item.done, "total": item.total,
				"to_sprint": int(item.to_sprint)}),
		"velocity": r.velocity,
		"result": _result(r),
		"press": {} if press.is_empty() else {"outlet": press.outlet, "text": SprintBridges.resolve(press)},
		"reviews": SprintBridges.review_lines(r),
		"lead": _person(lead).merged({"text": SprintCatalog.release_lead_sentence(r), "self": lead.category == "founder"}),
	}


## Çıkan kart; düzeltme kartının adı kapanıştaki hata sayısını da taşır: "Fatura düzeltmesi · 6 → 0 açık hata".
static func _shipped(c: Dictionary) -> Dictionary:
	var card: Dictionary = _card(c, SprintCard.State.BITTI)
	if c.kind == "fix":
		card.name += SprintUiShared.SEP + _t(Fmt.count_key("PRODUCT_FX_BUGS_FIXED", int(c.bugs_after))).format(
			{"from": int(c.bugs), "to": int(c.bugs_after)})
	return card


## Sürümün sonuç satırı: ertesi gün gerçekleşen, o gelene kadar beklenen; ikisi de yoksa null.
## Sürüm notu ertesi gün kapanmış olur, gerçekleşeni Geçmiş gösterir.
static func _result(r: Dictionary) -> Variant:
	var said: Dictionary = r.expected if r.actual.is_empty() else r.actual
	return null if said.is_empty() else {"kind": "expected" if r.actual.is_empty() else "actual",
		"text": SprintBridges.resolve(said)}


## Merkezin yeni alanları: `run` zaman ekseni (`SprintSystem.timeline`; sürüm notunda {}), `offered` devir kapalıyken liderin
## önerisi, `pool` aday kartlar (kimlikle).
static func _plan_view(mode: String, run: Dictionary, center: Dictionary, offered: Array, pool: Dictionary) -> Dictionary:
	var total: float = center.capacity.total if center.capacity != null else 0.0
	var now: float = _now_at(mode)
	return {"now_at": now, "close_at": run.get("close_at", 0.0), "progress": _progress(run, now) if mode == "active" else null,
		"crew": _crew(run), "suggest": _suggest(offered, pool), "candidates": _candidates(offered, pool),
		"start_skips": mode == "plan" and total > 0.0 and SprintSystem.starting().is_empty(), "team_empty": total == 0.0,
		"mvp": center.mvp_line}


## Koşan sprintte şimdiki an: sprint başından hafta. Haftanın içindeki yer mesainin geçen payıdır (mesai öncesi 0, gece 1).
static func _now_at(mode: String) -> float:
	if mode != "active":
		return 0.0
	var start: int = WorkHoursSystem.start_hour()
	var hour: float = TimeManager.day_minute() / 60.0
	return SprintSystem.week() - 1 + clampf((hour - start) / float(WorkHoursSystem.workday_end() - start), 0.0, 1.0)


## Koşan sprintin ilerlemesi, görünen eforla: kartların şimdiye dek yaptığı iş (zaman ekseninin ara değeri) bilinen yükünü
## (`SprintSystem.card_load`) aşmaz; testin henüz bulmadığı hatanın düzeltme işi yüke girmediği için sayılmaz.
static func _progress(run: Dictionary, at: float) -> Dictionary:
	var done := 0.0
	var total := 0.0
	for id in run.cards:
		var c: Dictionary = GameState.product.cards[id]
		var known: float = SprintSystem.card_load(c) / (1.0 + float(c.get("prep_gain", 0.0)))
		var made := 0.0
		for stage in run.cards[id].stages:
			made += SprintTimeline.done_at(stage, at)
		done += minf(made, known)
		total += known
	return {"done": done, "total": total}


## Ekip özeti, bir aşamanın satırı 9'dan çok kişi tutarsa (yıldız kümeleri; ekip rozeti): {n, sprint, training, leave, research,
## pm, out}. Her çalışan bir kez sayılır: önce ekip dışı nedeni, sonra PM, sonra sprintte çalışan, kalanı sprint dışı. Kurucu
## anahtarı açıkken sayılır (sprintte, ya da toplantıdaysa sprint dışı). Satırı kişinin yüzünün durduğu aşamadır: ekip dışı
## nedeni olan da orada durur, yalnız Destek'te çalışan dizide görünmez ve satırı doldurmaz.
static func _crew(run: Dictionary) -> Variant:
	var left: Dictionary = {}
	for a in SprintSystem.away():
		left[a.id] = a.reason
	var counts := {"n": 0, "sprint": 0, "training": 0, "leave": 0, "research": 0, "pm": 0, "out": 0}
	var heads := {"design": 0, "dev": 0, "test": 0}
	var working: Array = run.get("people", {}).keys() if not run.is_empty() \
		else SprintSystem.team().map(func(t: Dictionary) -> String: return t.id)
	var people: Array = CharacterRegistry.get_employees()
	if GameState.founder_in_sprint:
		people.append(CharacterRegistry.get_founder())
	for c in people:
		var kind: String = left.get(c.id, "")
		var seated: bool = kind != "" or c.id in working
		if kind == "meetings":
			kind = "out"
		elif kind == "":
			kind = "pm" if c.role == HRConstants.ROLE_PRODUCT_MANAGER else ("sprint" if seated else "out")
		counts[kind] += 1
		counts.n += 1
		var row: String = run.get("people", {}).get(c.id, {}).get("row", "dev") if c.category == "founder" \
			else SprintCatalog.row_of(c)
		if seated and row != "":
			heads[row] += 1
	return counts if heads.values().max() > 9 else null


## Planı boş sprintte liderin önerisi (devir kapalıyken, plana en az bir kart ekleyecekse): {amount, cards: [{name, done,
## effort}]}. `done` her kartın plana eklenince bu sprintte yapacağı iş, `amount` onların toplamı; tek oynatma.
static func _suggest(offered: Array, pool: Dictionary) -> Variant:
	if offered.is_empty():
		return null
	var played: Dictionary = SprintSystem.timeline(offered.map(func(id: String) -> Dictionary: return pool[id]))
	var cards: Array = []
	var amount := 0.0
	for id in offered:
		var done := 0.0
		for stage in played.cards[id].stages:
			done += stage.in_sprint
		amount += done
		cards.append({"name": SprintCatalog.card_name(pool[id]), "done": done, "effort": _effort(pool[id])})
	return {"amount": amount, "cards": cards}


## EKLENEBİLİR: planda kart yokken önerinin ilk üç kartı, her biri boş plana tek başına eklenmiş gibi oynatılarak (satır
## kartları: "+" tek kart ekler).
static func _candidates(offered: Array, pool: Dictionary) -> Array:
	if SprintSystem.sprint_card_count() > 0:
		return []
	return offered.slice(0, 3).map(func(id: String) -> Dictionary:
		return _row(pool[id], SprintSystem.timeline([pool[id]]).cards[id], ["add"]))


## Kart satırı: `c` oynanmamış kart, `t` zaman ekseninin o karttaki kaydı. Efor kartın kalan ihtiyacıdır (`_effort`), risk
## beklenen hatanın tavana (`SprintBugs.ceiling`) oranı ve hazırlanmamış hâli.
static func _row(c: Dictionary, t: Dictionary, buttons: Array) -> Dictionary:
	var ref: float = SprintBugs.ceiling()
	var preparer: Character = CharacterRegistry.get_character(t.prep.by)
	var due: int = SprintCatalog.due_sprint(c)
	var slot: Dictionary = {}
	if due >= 0:
		slot = _due(due).merged({"kind": "due"})
	elif c.state == "carried":
		slot = {"kind": "carried"}
	elif t.late:
		slot = {"kind": "late"}
	return {"id": c.id, "kind": _kind(c), "name": SprintCatalog.card_name(c), "effort": roundi(_effort(c)),
		"raw_effort": roundi(SprintSystem.remaining(c)),
		"module": SprintCatalog.area_short(c.area),
		"fix_text": SprintUiShared.bugs_text(SprintCatalog.bugs_part(c.line, c.bugs)) if c.kind == "fix" else "",
		"slot": slot, "pm": null if preparer == null else _face(preparer, HRConstants.AREA_PRODUCT), "ask": _ask(c),
		"risk": minf(1.0, t.h / ref) if ref > 0.0 else 0.0, "risk_raw": minf(1.0, t.h0 / ref) if ref > 0.0 else 0.0,
		"late": t.late, "founder": t.founder, "buttons": buttons, "stages": t.stages}


## Kartın eforu: kalan ihtiyaç ÷ hazırlık kazancı. Oynanmamış karttan okunur: testin bulduğu düzeltme işi kartta olduğu için
## sayılır, oynatmanın öngördüğü iş sayılmaz.
static func _effort(c: Dictionary) -> float:
	return SprintSystem.remaining(c) / (1.0 + float(c.get("prep_gain", 0.0)))


## Kartın aşama başına kalan ihtiyacı [tasarım, geliştirme, test] (`_effort`un parçaları); hazırlık kazancı `gains`ta varsa
## oradan (`SprintSystem.prep_gains`), yoksa kartınkidir.
static func _parts(c: Dictionary, gains: Dictionary = {}) -> Array:
	var k: float = 1.0 + float(gains.get(c.id, c.get("prep_gain", 0.0)))
	return [0, 1, 2].map(func(i: int) -> float: return maxf(0.0, float(c.need[i]) - float(c.progress[i])) / k)


## Kartın bekleyen sorusu {person (soran), item (gelen kutusundaki kâğıt)}; karar yoksa null.
static func _ask(c: Dictionary) -> Variant:
	var paper: Variant = _decision() if c.decision else null
	if paper == null:
		return null
	var speaker: Character = CharacterRegistry.get_character(String(GameState.product.decision.speaker))
	return {"person": null if speaker == null else _face(speaker, HRConstants.role_key_area(speaker.role)), "item": paper.item}


# --- Sonraki sprint -----------------------------------------------------------------

## Sprint sürerken ya da sürüm notunda kart bu sprinte çekilemez. Planlanan kart önden hazırlandığı kadar
## hazır payını taşır: planda sprint sonundakini (`outcome`), koşan sprintte ve sürüm notunda bugünkünü. `run` zaman ekseni
## (`SprintSystem.timeline`; sürüm notunda {}): aşama yükü ve devreden iş ondan okunur.
static func _next(mode: String, outcome: Dictionary, run: Dictionary) -> Dictionary:
	var p: Dictionary = GameState.product
	var next: Dictionary = p.get("next", {})
	if next.is_empty():
		return {"sprint": -1, "flags": [], "cards": [], "load": [], "carried": []}
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
	var released: bool = mode == "release"
	var carried: Array = next.cards.filter(func(id: String) -> bool: return released and p.cards[id].state == "carried")
	var planned: Array = next.cards.filter(func(id: String) -> bool: return id not in carried)
	var shares: Array = _shares(carried) if released else _out_shares(run)
	var of: Dictionary = {}
	if released:
		of = SprintTimeline.capacity_rows(SprintSystem.team()).of
	else:
		for id in run.people:
			of[id] = run.people[id].row
	var power: Dictionary = SprintTimeline.row_power(SprintSystem.team(), of)
	var ahead: Dictionary = {} if released else run.ahead
	var gains: Dictionary = {} if released else SprintSystem.prep_gains(int(run.close_at) - run.start)
	return {"sprint": n, "flags": _flags(n), "cards": cards, "load": _load(shares, planned, ahead, power, gains),
		"carried": _carried(shares)}


## Sonraki sprintin aşama yükü [{stage, carried, planned, team}], görünen eforla. `shares` bu sprintten devreden paylar
## (`_out_shares` ya da `_shares`), `ids` sonraki sütunun planlı kartları: kalan ihtiyaçları sprint sonundaki hazırlık kazancına
## (`gains`) bölünür ve sprintte önden yapılacak iş (`ahead`, aynı kazançla) düşülür, çünkü kart sonraki sprinte o hâliyle girer.
## `power` satır başına ekibin sprint boyunca puanı (`SprintTimeline.row_power`).
static func _load(shares: Array, ids: Array, ahead: Dictionary, power: Dictionary, gains: Dictionary) -> Array:
	var planned: Array = _shares(ids, gains)
	var out: Array = []
	for stage in ["design", "dev", "test"]:
		var carried := 0.0
		for s in shares:
			if s.stage == stage:
				carried += s.effort
		var left := 0.0
		for s in planned:
			if s.stage == stage:
				left += maxf(0.0, s.effort - float(ahead.get(s.card_id, {}).get(stage, {}).get("done", 0.0)))
		out.append({"stage": stage, "carried": carried, "planned": left, "team": float(power.get(stage, 0.0))})
	return out


## Devreden satırları [{card, card_id, stage, effort}], en büyüğü önde: kartın aynı aşamadaki payları (taban iş ve düzeltme işi)
## tek satırdır; araştırma kartı aşama saymaz.
static func _carried(shares: Array) -> Array:
	var rows: Dictionary = {}
	for s in shares:
		if s.stage != "product":
			var row: Dictionary = rows.get_or_add(s.card_id + "|" + s.stage, {"card": SprintCatalog.card_name(
				GameState.product.cards[s.card_id]), "card_id": s.card_id, "stage": s.stage, "effort": 0.0})
			row.effort += s.effort
	var out: Array = rows.values()
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a.effort > b.effort if a.effort != b.effort else a.card_id + a.stage < b.card_id + b.stage)
	return out


## Kartların aşama payları [{card_id, stage, effort}]: kalan ihtiyaç (`_parts`, `gains` onun kazancı), aşama kartın türünün rolünden.
static func _shares(ids: Array, gains: Dictionary = {}) -> Array:
	var out: Array = []
	for id in ids:
		var c: Dictionary = GameState.product.cards[id]
		var roles: Array = SprintCatalog.cfg("roles." + String(c.kind))
		var parts: Array = _parts(c, gains)
		for i in 3:
			if parts[i] > SprintSystem.EPS:
				out.append({"card_id": id, "stage": roles[i], "effort": parts[i]})
	return out


## Bu sprintten sonraya kalan aşama payları [{card_id, stage, effort}]: zaman ekseninin `out`u (düzeltme işi Geliştirme'dedir).
static func _out_shares(run: Dictionary) -> Array:
	var out: Array = []
	for id in run.cards:
		for s in run.cards[id].stages:
			if s.out > SprintSystem.EPS:
				out.append({"card_id": id, "stage": s.stage, "effort": s.out})
	return out


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

## ÇEYREK PM varken açılır. Sütunlar bu sprint, PM'in planladığı sprintler ve çeyreği altı sütuna tamamlayan boşlardır;
## sonraki sprintin sütunu orada duran kartların üstüne PM'in önerisini ekler. Gelecek sprintin kapasitesi bugünkü ekiptir.
## Çeyreğin saati (`q`, `year`, `pos`, `total`) PM'siz de dolar.
static func _quarter(center: Dictionary, next: Dictionary) -> Dictionary:
	var clock: Dictionary = _quarter_clock(center.sprint)
	if SprintCatalog.quarter_pm() == null:
		return clock.merged({"state": "locked_no_pm", "goal": null, "columns": []})
	if center.sprint < 0:
		return clock.merged({"state": "open", "goal": null, "columns": []})
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
	return clock.merged({"state": "open", "goal": _goal(), "columns": columns})


## Ürün çeyreğinin saati: sprint `n` çeyreğin kaçıncı sprinti (`pos`), çeyrek kaç sprintlik (`total`) ve hangi takvim çeyreği ve
## yılında başladı (`q`, `year`). Başlangıç günü kayıtlıdır; alanı olmayan eski kayıt sprintin başından geri sayar.
static func _quarter_clock(n: int) -> Dictionary:
	if n < 0:
		return {"q": 0, "year": 0, "pos": 0, "total": 0}
	var p: Dictionary = GameState.product
	var pos: int = n - int(p.quarter.start_sprint) + 1
	var start: int = int(p.quarter.get("start_day", int(p.sprint.start_day) - (pos - 1) * SprintSystem.sprint_weeks()))
	var date: Dictionary = GameState.get_date_dict(start)
	return {"q": _calendar_quarter(date), "year": int(date.year), "pos": pos,
		"total": SprintSystem.sprints_in(int(SprintCatalog.cfg("quarter_weeks")))}


## Tarihin takvim çeyreği (1..4).
static func _calendar_quarter(date: Dictionary) -> int:
	return 1 + floori((int(date.month) - 1) / 3.0)


## Hedef şeridi: alan seviyesinin sıradaki yıldızın beklentisine oranı onluk vekil ölçekte, hedef ortadaki
## çizgidedir; alanın cümlesi o çizgiyi anlatır.
static func _goal() -> Dictionary:
	var id: String = SprintCatalog.pm_goal()
	var mark: int = int(SprintCatalog.cfg("pm.goal_mark"))
	var total: int = int(SprintCatalog.cfg("pm.goal_squares"))
	var now: int = mini(roundi(ProductQuality.next_ratio(id) * mark), total)
	return {"area_id": id, "area_name": SprintCatalog.area_short(id), "text": goal_text(id),
		"now": now, "target": mark, "total": total,
		"progress_text": _t("PRODUCT_GOAL_PROGRESS").format({"now": now, "total": total})}


## Alanın çeyrek hedefi olarak cümlesi (şerit ve hedef menüsü); fikstür de buradan okur.
static func goal_text(area_id: String) -> String:
	return _t("PRODUCT_GOAL_" + area_id.to_upper())


# --- Genel Bakış -----------------------------------------------------------------------

## Sunucu bloğu. Her sayı InfraSystem'den, kesinti katları IncidentSystem'den okunur; metin burada çözülür.
static func _server() -> Dictionary:
	var kind: String = "SEATS" if ProductState.market_type() == "b2b" else "USERS"
	var provider: String = InfraSystem.provider()
	var unit: int = InfraSystem.unit_size()
	var units: int = InfraSystem.units()
	var capacity: int = InfraSystem.purchased_capacity()
	var served: int = InfraSystem.served_count()
	var percent: int = InfraSystem.load_percent()
	var bill: int = InfraSystem.monthly_bill()
	var unit_price: int = InfraSystem.unit_price(provider)
	var step: int = InfraSystem.capacity_step()
	var more: int = units + step
	var fewer: int = maxi(units - step, 0)
	var load_text: String = ""
	if capacity > 0:
		load_text = _t("PRODUCT_SERVER_LOAD_OVER_" + kind).format({"load": percent, "short": Fmt.group(served - capacity)}) \
			if percent > InfraSystem.LOAD_OVER else _t("PRODUCT_SERVER_LOAD_" + kind).format({"load": percent,
				"spare": Fmt.group(capacity - served),
				"spare_cost": Fmt.money_exact(roundi(float(capacity - served) / unit * unit_price))})
	var decrease: String = _t("PRODUCT_SERVER_WARN_NONE").format({"mult": Fmt.number(IncidentSystem.load_mult(InfraSystem.STATE_OVER), 2)}) \
		if fewer == 0 else _t("PRODUCT_SERVER_TIP_DECREASE_" + kind).format({"n": Fmt.group((units - fewer) * unit),
			"old_cost": Fmt.money_exact(bill), "new_cost": Fmt.money_exact(fewer * unit_price), "old_load": percent,
			"new_load": InfraSystem.load_percent(fewer)})
	if fewer > 0 and InfraSystem.load_percent(fewer) > InfraSystem.LOAD_OVER:
		decrease += "\n" + _t("PRODUCT_SERVER_TIP_DECREASE_SHORT").format({"load": InfraSystem.load_percent(fewer)})
	var waiting: int = B2BSalesSystem.clause_waiting()
	return {
		"tiers": InfraSystem.PROVIDER_IDS.map(func(id: String) -> Dictionary: return _tier(id, kind, provider, units, bill)),
		"active": InfraSystem.PROVIDER_IDS.find(provider),
		"capacity": _t("PRODUCT_SERVER_CAPACITY_" + kind).format({"n": Fmt.group(capacity), "bill": Fmt.money_exact(bill)}),
		"percent": percent if capacity > 0 else 0, "state": InfraSystem.capacity_state(), "load": load_text,
		"note": _server_note(kind, capacity, percent),
		"clause": _t(Fmt.count_key("SALES_CLAUSE_WAITING", waiting)).format({"n": waiting}) if waiting > 0 else "",
		"decrease": {"text": _t("PRODUCT_SERVER_BTN_DECREASE").format({"n": Fmt.group(step * unit)}), "tip": decrease,
			"off": units <= InfraSystem.CAPACITY_MIN},
		"increase": {"text": _t("PRODUCT_SERVER_BTN_INCREASE").format({"n": Fmt.group(step * unit)}),
			"tip": _t("PRODUCT_SERVER_TIP_INCREASE_" + kind).format({"n": Fmt.group(step * unit), "old_cost": Fmt.money_exact(bill),
				"new_cost": Fmt.money_exact(more * unit_price), "old_load": percent, "new_load": InfraSystem.load_percent(more)})},
		"auto": {"on": ProductState.infra_auto(),
			"tip": _t("PRODUCT_SERVER_AUTO_TIP").format({"edge": InfraSystem.AUTO_EDGE, "target": InfraSystem.AUTO_TARGET})},
	}


## Bloğun tek satırlık notu: kesinti uyarısı, yoksa anahtar açıkken son otomatik büyüme, kapalıyken büyüme; hiçbiri yoksa null.
static func _server_note(kind: String, capacity: int, percent: int) -> Variant:
	var mult: String = Fmt.number(IncidentSystem.load_mult(), 2)
	if capacity <= 0:
		return {"text": _t("PRODUCT_SERVER_WARN_NONE").format({"mult": mult}), "tone": "over", "glyph": "warn"}
	if percent > InfraSystem.LOAD_OVER:
		return {"text": _t("PRODUCT_SERVER_WARN_OVER").format({"load": percent, "mult": mult}), "tone": "over", "glyph": "warn"}
	if percent > InfraSystem.LOAD_AMBER:
		return {"text": _t("PRODUCT_SERVER_WARN_HIGH").format({"load": percent, "edge": InfraSystem.LOAD_AMBER, "mult": mult}),
			"tone": "warn", "glyph": "warn"}
	if ProductState.infra_auto():
		var last: Dictionary = ProductState.infra_auto_last()
		return null if last.is_empty() else {"tone": "quiet", "glyph": "info",
			"text": _t("PRODUCT_SERVER_AUTO_LAST_" + kind).format({"date": Fmt.date_line(GameState.get_date_dict(int(last.day))),
				"old": Fmt.group(int(last.old)), "new": Fmt.group(int(last.new))})}
	var weeks: int = InfraSystem.weeks_to_amber()
	if weeks <= 0:
		return null
	return {"tone": "quiet", "glyph": "clock", "text": _t("PRODUCT_SERVER_GROWTH_ONE" if weeks == 1 else "PRODUCT_SERVER_GROWTH").format(
		{"edge": InfraSystem.LOAD_AMBER, "weeks": weeks})}


## Bir kademe: adı, ipucu (fiyat, kesinti çarpanı, bedeller ve sözleşme şartı) ve seçilince açılan geçiş önizlemesi.
## Kurumsal'dayken alttakiler kilitlidir ve ipucu gerekçedir.
static func _tier(id: String, kind: String, active: String, units: int, bill: int) -> Dictionary:
	var name: String = _t(TIER_KEYS[id])
	var enterprise: bool = id == InfraSystem.PROVIDER_ENTERPRISE
	var off: bool = active == InfraSystem.PROVIDER_ENTERPRISE and not enterprise
	var parts: PackedStringArray = [_t("PRODUCT_SERVER_TIER_TIP_PRICE_" + kind).format(
		{"price": Fmt.money_exact(InfraSystem.unit_price(id)), "unit": Fmt.group(InfraSystem.unit_size())}),
		_t("PRODUCT_SERVER_TIER_TIP_OUTAGE").format({"mult": Fmt.number(IncidentSystem.tier_mult(id), 2)})]
	if id == InfraSystem.PROVIDER_LOCAL:
		parts.append(_t("PRODUCT_SERVER_TIER_TIP_REPORTS").format({"pct": roundi((InfraSystem.LOCAL_INFLOW_MULT - 1.0) * 100.0)}))
	parts.append(_t("PRODUCT_SERVER_TIER_TIP_CLAUSE_" + ("YES" if enterprise else "NO")))
	var final_note: String = _t("PRODUCT_SERVER_TIER_TIP_FINAL") if enterprise else ""
	return {"id": id, "name": name, "off": off, "final": final_note,
		"tip": _t("PRODUCT_SERVER_TIER_LOCKED") if off else "\n".join([name, SprintUiShared.SEP.join(parts), final_note]).strip_edges(),
		"preview": _t("PRODUCT_SERVER_TIER_PREVIEW").format({"from": _t(TIER_KEYS.get(active, "")), "to": name,
			"old": Fmt.money_exact(bill), "new": Fmt.money_exact(units * InfraSystem.unit_price(id))})}


# --- Kart ------------------------------------------------------------------------------

static func _card(c: Dictionary, state: SprintCard.State, extra := {}) -> Dictionary:
	var card := {"id": c.id, "name": SprintCatalog.card_name(c), "kind": _kind(c), "roles": c.roles,
		"effort": roundi(SprintSystem.total(c)), "state": state, "effect": SprintCatalog.card_effect(c),
		"tag_sprint": -1, "phases": [], "phase_pts": null, "assignees": [], "queued": false, "decision": null,
		"effort_split": [], "locked_node": "", "locked_rnd": "",
		"remaining": -1, "spills": false, "no_start": -1, "planned_done": 0.0, "addable": false, "ready": -1.0,
		"priority": SprintCatalog.is_priority(c), "buttons": BUTTONS.get(state, [])}
	card.merge(extra, true)
	if c.get("follow", false):
		card.buttons = card.buttons.filter(func(b: String) -> bool: return b != "remove")
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


## Yüz kaydı: kişi ve `area` alanındaki yıldızı.
static func _face(c: Character, area: String) -> Dictionary:
	return _person(c).merged({"id": c.id, "stars": HRConstants.stars_for(HRSystem.skill(c, area)),
		"founder": c.category == "founder"})


# --- Yardımcılar -------------------------------------------------------------------------

## Kapasite çubuğu: kapasite yoksa kilitli, aşılmışsa taşkın.
static func _bar(used: float, total: float, done: float, segments: Array) -> Dictionary:
	return {"used": used, "total": total, "done": done,
		"state": "blocked" if total == 0 else ("over" if used > total + SprintSystem.EPS else "ok"), "segments": segments}


static func _t(key: String) -> String:
	return TranslationServer.translate(key)
