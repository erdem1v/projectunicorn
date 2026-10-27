class_name ProductModel
extends RefCounted

# Ürün sekmesinin sprint ekranının görünüm sözleşmesi. Sekme yalnız bu Dictionary'yi çizer.
# Üreten (canlı adaptör ya da debug fikstürü) içerik alanlarını çözülmüş metin olarak verir;
# eşik ve izinler bool gelir. Bileşenler kendi dilbilgisini PRODUCT_* anahtarlarından kurar.
#
# PRD terimi → sözleşme adı:
#   Alan → area {id, name, goal_text} (çeyrek hedefinin menüsü) · Modül → module (sol sütun)
#   Kart → card {id, kind, effort, roles, state, effect} (sonraki sütun, ÇEYREK ve sürüm notu); bu sprintin kartı pano satırıdır
#   (`center.cards`, aşağıda)
#   Sprint → center {sprint, capacity, cards} · Sürüm → center.release {version, shipped, carried, velocity, press}
#   tür yeni/cila/düzeltme/araştırma → kind feature|polish|fix|research
#   kart durumları → SprintCard.State
#   roller → roles: design|dev|test|product (en çok üç ikon)
#
# model = {
#   header: {name, live_version: "1.4" or "" (MVP öncesi), market: "B2C"|"B2B" or "" (tür yok), type_text,
#            users, paying (canlı B2C'de kitle ve ödeyen; -1 = yok)},
#   versions: [{label: "v1.4", sprint: int or -1, shipped_count: int or -1,   # -1 çizilmez
#               result: {kind: "expected"|"actual", text} or null}],
#   quarter: {state: "locked_no_pm"|"open",
#             goal: {area_id ("" hedef yok, "bugs" Hatalar ya da alan), area_name, meter: {text, now, target, total, progress_text} or
#             null (yalnız alan hedefinde)} or null (sprint yok), columns: [column]},
#   ui: {view: "overview"|"sprint"|"quarter", open_area: area id or "", history_open, hover_card: card id or "" (imleç bir adayın
#         "+"ında), server_preview: kademe id or "" (açık geçiş önizlemesi), requests_open (talep listesinin fazlası açık)},
#   overview: {server: server} or null (v1.0'dan önce: GENEL BAKIŞ kilitli; fikstürde de yok),
#   areas: [{id, name, goal_text}],
#   center: center,
#   next: {sprint: int or -1, flags: [{k: "rival"|"deadline", text}], cards: [card]},
# }
# center = {mode: "plan"|"active"|"release", sprint (-1 = sprint yok), weeks (sprintin süresi), week (active),
#           staffed (kadroda çalışan var), cards: [row],
#           plan_hold (planlama oyuncuyu bekliyor, saat duruyor),
#           next_version: {label, weeks: int or -1} or null (MVP öncesi),
#           mvp: {version, area, need, done (bu sprintte biten dahil), sprint (-1 = tahmin yok), week}
#                     or null (canlıda),
#           spare (planda hiçbir karta gitmeyen puan var), ceiling_pct (yükün "+" kapanan eşiği, yüzde), can_start,
#           start_reason: "" or String (başlat kapalıysa kapanan koşul),
#           rnd_node: {id (araştırdığı düğüm), text ("Kurucu Ar-Ge'de: …")} or null (kurucu Ar-Ge'de değil),
#           release: {version: "v5" or "" (sürüm çıkmadı), gate (MVP kapısı: Yayınla / Bir sprint daha;
#                     başlık ve gövde mvp'den), rnd_open (v1.0 notu: Ar-Ge açıldı), shipped: [card],
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
# column = {sprint, kind: "current"|"proposed"|"empty", capacity: {used, total, done, state: "ok"|"over"|"blocked",
#           segments: [{pts}]} or null (puanlar kesirli), pm, flags: [...], cards: [card], approved}
# card = {id, name, kind, roles: [...], effort, state: SprintCard.State, effect: [part],
#         locked_node: "" or String, locked_rnd: "" or String (kilidin açılmamış Ar-Ge düğümü; kart oraya götürür),
#         remaining: -1 or float (kesirli), priority (öncelikli düzeltme),
#         ready: -1 or 0..1 (sonraki sütunda önden hazırlanan kartın hazır payı; planda sprint sonundaki),
#         buttons: ["add"|"send_next"|"pull"|"remove"]}   # var olan düğmeler
# part = {k: "level", area, from, to, from_word, to_word} | {k: "holds", area, word} | {k: "alert_clear", area}
#      | {k: "cap", name, from, to, from_word, to_word}
#      | {k: "bugs", n, accounts (B2C'de -1), users, top ("" ise yok), top_users}   # düzeltme kartının hata satırı
#      | {k: "request", customer, value} | {k: "research", area}
#      | {k: "promise", customer}   # kademeye verilmiş açık söz; kart onu etiketle de taşır
#   level ve cap parçalarında from/to seviyedir (0..3); from_word/to_word o seviyenin beklentiye göre
#   kelimesidir (ProductQuality.word_for), kelime ve renk ondan.
#
# Yeni ekranın okuma yüzeyi, yukarıdakilerin yanında (efor sayıları görünen eforudur: kalan ihtiyaç ÷ hazırlık kazancı):
#   founder: {on (kurucu sprint kartı alır), locked: "" | "running" | "rnd", rnd_text},
#   requests: null (B2C) | [{customer, card_id, card_name, module_id, mono (modülün iki harfi), value (yıllık), due_text (sözün, yoksa talebin son sprinti:
#             "bu çeyrek", "gelecek çeyrek" ya da "{q}. çeyrek"), soon (bu çeyrek), planned (kartı bu sprintin planında), tip}]
#             (planlı olmayan önde, bu çeyrek önde, sonra son tarih),
#   modules: [{id, name, mono, planned (bu sprintte kartı var), candidates: [{id, name, effort, parts: [{stage, effort}] (sıfırdan
#             büyük aşama payları, eforu kesirli), planned (bu sprintin planında), stamp (başka sprintte: sprint numarası, yoksa
#             -1), addable (null: "+"nın değeri henüz istenmedi, `resolve_addable` ister; false: adaylıktan çıkmış kartın "+"ı yok),
#             bugs, fix_text}]}] (kilitli aday ve adaylarının hepsi kilitli modül yok),
#   prep: {pms: [{person, stars, cards (bu sprintin kartlarından hazırladıklarının adı), preparing (sonraki sütunda hazırladığı var)}]},
#   quarter: + {q, year (ürün çeyreğinin başladığı takvim çeyreği), pos, total (çeyreğin kaçıncı sprinti, kaç sprintlik)},
#   center: + {now_at (koşan sprintin haftasında şimdiki an, sprint başından hafta), close_at (SprintTimeline), progress: {done,
#             total} (koşarken), crew (bir aşamada `CLUSTER_OVER`dan çok kişi varsa {n, sprint, training, leave, research, pm, out}),
#             capacity: [{stage, work (dolgu), team (oluk), done (koşarken bu haftanın şimdiye dek yaptığı), out (sprint dışına kalan),
#             out_inside (onun önceki aşamayı beklerken kalan kısmı), streak (art arda taşan sprint, taşmıyorsa 0), hot (en çok taşan
#             aşama ve streak >= 2), shared (ekip yalnız kurucu), stays: [{card, effort}], people: [{person, busy, cut, effort}],
#             away: [{person, reason: training|leave|research|meetings}], cluster: null | {founders: [person], stars: [{stars, n,
#             person}], away: [{reason, n, person}]}}] or null (sprint yok ve sürüm notunda; efor sayıları kesirli, iş ve ekip
#             koşan sprintte kalan haftaların),
#             suggest: {amount, cards: [{name, done, effort}]} | null (öneri bu sprinte de sütuna da kart eklemiyorsa; yalnız
#             sütuna ekliyorsa {amount: 0.0, cards: []}: sayı çizilmez, yalnız düğme), candidates (boş planın ilk üç önerisi: kart satırı),
#             people ({kimlik: person + pieces}: panonun çubuklarında yüzü çizilenler; planlamada yalnız kurucu, koşarken aşamalarda
#             çalışan herkes ve parçaları, `SprintTimeline` kişi parçası biçiminde), start_skips, team_empty},
#   next: + {load: [{stage, carried, planned, team}], carried: [{card, card_id, stage, effort}]} (devreden: planlamada ve koşarken
#         zaman ekseninin `out`u, sürüm notunda sonraki sütunun devreden kartlarının kalan ihtiyacı; ikisini de aynı işlevler
#         hesaplar, kartın aynı aşamadaki payları tek satırdır; planlı: planlamada ve koşarken sonraki sütunun kartlarının sprint
#         sonundaki kalan ihtiyacı ve hazırlık kazancı, sürüm notunda bugünkü).
# person = {id, name, role_text, look, stars, founder}.
# Kart satırı (pano) = {id, kind, name, effort, raw_effort, module, fix_text, slot: {kind: "due" (+ text, soon) | "carried" | "late"}
#   ya da {}, pm, ask, risk, risk_raw (0..1: beklenen hatanın tavana oranı, hazırlanmamış hâli), late, founder, buttons,
#   stages (SprintTimeline aşamaları)}. Planlamada düğmeler "→" ve "×", koşarken yok; kapısı sonradan kapanıp başlamayacak kart
#   zaman ekseninde yoktur: `stages` boş, yalnız "×". `effort` kartın sprintteki yüküdür (`SprintSystem.card_load` ÷ hazırlık kazancı),
#   `raw_effort` bölünmemiş hâli: sprintin başındaki kalan ihtiyaç; koşarken yalnız testin bulduğu düzeltme işi onu büyütür.
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
## Bir aşamanın satırı bu kadar kişiden çoksa yüzlerin yerini yıldız kümeleri alır.
const CLUSTER_OVER := 9
## Kartın bulunduğu yerdeki düğmeleri.
const BUTTONS := {
	SprintCard.State.KILITLI: ["add"],
	SprintCard.State.SPRINT_PLAN: ["send_next", "remove"],
	SprintCard.State.SPRINT_AKTIF: [],
	SprintCard.State.PLANLANAN: ["pull", "remove"],
	SprintCard.State.DEVREDEN: ["pull", "remove"],
}


## Kaynak verilmediğinde sekmenin okuduğu model: ürün durumundan (GameState.product) ve sprint
## sistemlerinden kurulur. Tür seçilmeden alan ve kart yoktur; sekme o zaman tür seçiciyi açar.
static func live() -> Dictionary:
	_addable.clear()
	_ghosts.clear()
	var p: Dictionary = GameState.product
	var mode: String = SprintSystem.mode()
	var release: Dictionary = p.get("release", {}) if mode == "release" else {}
	# Bu ya da sonraki sprintte duran kartın sprint numarası: adaydaki kopyası soluklaşıp damga alır.
	var tags: Dictionary = {}
	for key in ["sprint", "next"]:
		var s: Dictionary = p.get(key, {})
		for id in s.get("cards", []):
			tags[id] = int(s.number)
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
	# Liderin önerisi yalnız planlamada, devir kapalıyken ve uygulanmamışken (plan değişince bayrak düşer) okunur.
	var suggestion: Dictionary = SprintCatalog.NO_LEAD
	if mode == "plan" and n > 0 and not SprintSystem.delegated() and not p.sprint.get("lead_applied", false):
		suggestion = SprintCatalog.lead_suggestion()
	var planned: Array = p.get("sprint", {}).get("cards", []).map(func(id: String) -> String: return p.cards[id].area)
	var areas: Array = []
	var modules: Array = []
	var pool: Dictionary = {}
	for a in SprintCatalog.areas_for(ProductState.subtype(), ProductState.market_type()):
		var cards: Array = SprintCatalog.candidates(a.id)
		for c in cards:
			pool[c.id] = c
		areas.append({"id": a.id, "name": SprintCatalog.area_name(a.id), "goal_text": goal_text(a.id)})
		var module: Variant = _module(a.id, cards, a.id in planned, n, tags)
		if module != null:
			modules.append(module)
	var center: Dictionary = _center(mode, release, outcome)
	center.merge(_plan_view(mode, run, suggestion, pool), true)
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
		"ui": {"view": "sprint", "open_area": "", "history_open": false, "hover_card": "", "server_preview": "",
			"requests_open": false},
		"overview": {"server": _server()} if live_now else null,
		"areas": areas,
		"founder": _founder(mode, center.rnd_node),
		"requests": _requests(tags),
		"modules": modules,
		"prep": _prep(),
		"center": center,
		"next": next,
	}


# --- Modüller ve talepler ------------------------------------------------------------

## "+"nın değeri ve hayalet hesabı (`SprintSystem.timeline([aday])`) sayfanın bir sonraki kurulumuna kadar kart kimliğiyle burada
## durur: `live()` atar, `addable` ve `ghost` ister.
static var _addable: Dictionary = {}
static var _ghosts: Dictionary = {}
## Bir karede "+" değerlerine harcanan süre: en az bir kart hesaplanır, süre dolunca kare biter.
const ADDABLE_FRAME_MS := 8.0


## Kartın "+" değeri (`SprintSystem.can_add`); henüz istenmediyse null. `live()` adayların değerini vermez: sayfa ekrandaki
## sırayla `resolve_addable` ister.
static func addable(card_id: String) -> Variant:
	return _addable.get(card_id)


## `ids` sırasıyla, değeri bilinmeyen kartların "+" değerini hesaplar ve en az biri hesaplandıktan sonra `ADDABLE_FRAME_MS`
## dolunca durur. Döner: bu çağrıda değeri öğrenilenler.
static func resolve_addable(ids: Array) -> Array:
	var started: int = Time.get_ticks_usec()
	var learned: Array = []
	for id: String in ids:
		if _addable.has(id):
			continue
		_addable[id] = SprintSystem.can_add(id)
		learned.append(id)
		if (Time.get_ticks_usec() - started) / 1000.0 >= ADDABLE_FRAME_MS:
			break
	return learned


## Adayın "+"ına gelince kurulan hayalet: planın bu kart eklenmiş oynatması (`SprintSystem.timeline`); üstüne gelme başına bir kez.
static func ghost(card_id: String) -> Dictionary:
	if not _ghosts.has(card_id):
		_ghosts[card_id] = SprintSystem.timeline([SprintCatalog.card_by_id(card_id)])
	return _ghosts[card_id]


## Hayaletin pano satırı: adayın düşeceği yerde (planın sonunda, planla birlikte oynatılmış); motorun tanımadığı kimlik (debug
## fikstürünün kartı) satır vermez.
static func ghost_row(card_id: String) -> Dictionary:
	var c: Dictionary = SprintCatalog.card_by_id(card_id)
	return {} if c.is_empty() else _row(c, ghost(card_id).cards[card_id], ["add"])


## Hat satırı: metni hata parçasından (`SprintCatalog.bugs_part`) ve geçen haftaya göre değişimden kurulur (Destek raporunun tablosu).
static func bug_row_of(line_name: String, part: Dictionary, delta: int) -> Dictionary:
	var bits: PackedStringArray = [line_name, SprintUiShared.count("PRODUCT_BUG_COUNT", int(part.n))]
	bits.append_array(SprintUiShared.impact_bits(part))
	var tip: PackedStringArray = [_t("PRODUCT_BUGS_TIP_PREV").format(
		{"bugs": SprintUiShared.count("PRODUCT_BUG_COUNT", int(part.n) - delta)})]
	if part.top != "":
		tip.append(_t("PRODUCT_BUGS_TIP_TOP").format(
			{"account": part.top, "users": SprintUiShared.count("PRODUCT_USER_COUNT", int(part.top_users))}))
	return {"text": SprintUiShared.SEP.join(bits), "tip": "\n".join(tip), "delta": delta}


## Yeni sol sütunun modülü: kilitli aday listelenmez, adaylarının hepsi kilitli olan modül de (kilitler Ar-Ge'de görünür). `cards`
## alanın ham adayları, `planned` modülün bu sprintin planında kartı olması, `sprint` bu sprintin numarası, `tags` bu ve sonraki
## sprintin kartlarının sprint numarası.
static func _module(area_id: String, cards: Array, planned: bool, sprint: int, tags: Dictionary) -> Variant:
	var listed: Array = cards.filter(func(c: Dictionary) -> bool:
		return c.state != "candidate" or SprintCatalog.gate_reason(c.step) == "")
	if listed.is_empty() and not cards.is_empty():
		return null
	return {"id": area_id, "name": SprintCatalog.area_name(area_id), "mono": _mono(area_id), "planned": planned,
		"candidates": listed.map(func(c: Dictionary) -> Dictionary: return _module_card(c, int(tags.get(c.id, -1)), sprint))}


## Modülün adayı: sıfırdan büyük aşama paylarının eforu (kalan ihtiyaç ÷ hazırlık kazancı, aşama kartın türünün rolünden), bu
## sprintin planında mı (tik) ya da hangi başka sprintte (damga; `tag` bu ve sonraki sprintin kartının sprint numarası, yoksa -1),
## düzeltme kartında hata sayısı ile metni. Adaylıktan çıkmış kartın (sprintte, sonrakinde) "+"ı yoktur (`addable` false), adayınki bilinmez.
static func _module_card(c: Dictionary, tag: int, sprint: int) -> Dictionary:
	var parts: Array = _parts(c)
	var roles: Array = SprintCatalog.cfg("roles." + String(c.kind))
	var fix: bool = c.kind == "fix"
	return {"id": c.id, "name": SprintCatalog.card_name(c), "effort": roundi(parts[0] + parts[1] + parts[2]),
		"parts": range(3).filter(func(i: int) -> bool: return parts[i] > SprintSystem.EPS).map(
			func(i: int) -> Dictionary: return {"stage": roles[i], "effort": parts[i]}),
		"planned": tag == sprint, "stamp": tag if tag != sprint else -1, "addable": null if c.state == "candidate" else false,
		"bugs": c.bugs if fix else 0, "fix_text": SprintUiShared.bugs_text(SprintCatalog.bugs_part(c.line, c.bugs)) if fix else ""}


## Modülün iki harfli işareti.
static func _mono(area_id: String) -> String:
	return _t("PRODUCT_AREA_" + area_id.to_upper() + "_MONO")


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
			"card_name": card_name, "module_id": area_id, "mono": _mono(area_id), "value": int(r.value),
			"due_text": when.text, "soon": when.soon,
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

static func _center(mode: String, release: Dictionary, outcome: Dictionary) -> Dictionary:
	var p: Dictionary = GameState.product
	var sprint: Dictionary = p.get("sprint", {})
	var n: int = SprintSystem.sprint_number()
	var total: float = SprintSystem.capacity()
	var lead: Character = _lead()
	var sprint_cards: Array = sprint.get("cards", [])
	var eta: Dictionary = SprintSystem.mvp_eta() if n > 0 else {}
	var need: int = int(SprintCatalog.cfg("mvp_lines"))
	# Sürüm koşulunda bu sprintte biten Çekirdek K1 de bitmiş sayılır.
	var finished: int = p.get("cards", {}).values().filter(func(c: Dictionary) -> bool:
		return c.area == "core" and int(c.target_tier) == 1 and c.state == "done").size()
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
		"staffed": not CharacterRegistry.get_employees().is_empty(),
		"plan_hold": mode == "plan" and SprintSystem.awaits_plan(),
		# MVP öncesi v1.0'ın tarihini sürüm koşulu verir; bu sprintin sonu onu vaat etmez.
		"next_version": {"label": SprintSystem.version_label(ProductState.version() + 1),
			"weeks": SprintSystem.weeks_left()} if n > 0 and ProductState.is_live() else null,
		"mvp": null if n <= 0 or ProductState.is_live() else {"version": SprintSystem.version_label(1),
			"area": SprintCatalog.area_short("core"), "need": need,
			"done": need - SprintCatalog.mvp_cards_left() + finished,
			"sprint": eta.get("sprint", -1), "week": eta.get("week", -1)},
		"spare": outcome.get("spare", 0.0) > SprintSystem.EPS,
		"ceiling_pct": roundi(float(SprintCatalog.cfg("cap_ceiling")) * 100.0),
		"can_start": can_start, "start_reason": reason, "rnd_node": rnd,
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


## Merkezin zaman eksenine ve öneriye bağlı alanları: `run` zaman ekseni (`SprintSystem.timeline`; sürüm notunda {}), `offered`
## liderin önerisi (öneri satırı görünmeyecekse `NO_LEAD`), `pool` aday kartlar (kimlikle).
static func _plan_view(mode: String, run: Dictionary, offered: Dictionary, pool: Dictionary) -> Dictionary:
	var total: float = SprintSystem.capacity()
	var now: float = now_at(mode)
	var cards: Array = _cards(mode, run)
	return {"cards": cards, "people": _faces(mode, cards, run), "now_at": now, "close_at": run.get("close_at", 0.0),
		"progress": _progress(run, now) if mode == "active" else null,
		"capacity": _capacity(mode, run, now), "crew": _crew(run), "suggest": _suggest(offered, pool),
		"candidates": _candidates(offered.this, pool),
		"start_skips": mode == "plan" and total > 0.0 and SprintSystem.starting().is_empty(), "team_empty": total == 0.0}


## Sprintin kart satırları (pano), planın sırasıyla: planlamada "→" ve "×", koşarken düğmesiz. Kapısı sonradan kapanıp
## başlamayacak kart zaman ekseninde yoktur: satırı boş `stages` ve yalnız "×" taşır. Sürüm notunda satır yoktur.
static func _cards(mode: String, run: Dictionary) -> Array:
	if run.is_empty():
		return []
	var p: Dictionary = GameState.product
	return p.sprint.cards.map(func(id: String) -> Dictionary:
		var t: Dictionary = run.cards.get(id, {})
		return _row(p.cards[id], t, [] if mode == "active" else BUTTONS[SprintCard.State.SPRINT_PLAN] if not t.is_empty() else ["remove"]))


## Panonun çubuklarında yüzü çizilen kişiler {kimlik: person + pieces}: planlamada çalıştığı kartta çubuğun ucunda kurucu, koşarken
## aşamalarında çalışan herkes (`pieces` onların şimdi neredeki parçasıdır).
static func _faces(mode: String, rows: Array, run: Dictionary) -> Dictionary:
	var areas: Dictionary = SprintCatalog.cfg("role_areas")
	var founder: String = CharacterRegistry.get_founder().id
	var out: Dictionary = {}
	for row: Dictionary in rows:
		for s: Dictionary in row.stages:
			for id: String in s.people:
				if not out.has(id) and (mode == "active" or id == founder):
					var seat: Dictionary = run.people[id]
					out[id] = _face(CharacterRegistry.get_character(id), areas[seat.row] if seat.row != "" else HRConstants.AREA_PRODUCT).merged(
						{"pieces": seat.pieces if mode == "active" else []})
	return out


## Koşan sprintte şimdiki an: sprint başından hafta. Haftanın içindeki yer mesainin geçen payıdır (mesai öncesi 0, gece 1).
static func now_at(mode: String) -> float:
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


## Ekip özeti, bir aşamanın satırı `CLUSTER_OVER`dan çok kişi tutarsa (yıldız kümeleri; ekip rozeti): {n, sprint, training, leave, research,
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
	return counts if heads.values().max() > CLUSTER_OVER else null


## Kapasite bloğunun üç satırı (`SprintSystem.STAGES` sırasıyla; sürüm notunda ve sprint yokken null). İş (dolgu), kartların aşamadaki
## kalan ihtiyacıdır; ekip (oluk), aşamaya giden iş artı satırın kişilerinin hiçbir karta harcamadığı puandır: ikisi de koşan sprintte
## kalan haftalarınındır ve `done` bu haftanın şimdiye dek yaptığı iştir. Taşma (`out`) zaman ekseninin sprint dışı payıdır:
## oluğun ötesindeki kısmı dış, kalanı (önceki aşamayı beklerken) iç taşma (`out_inside`). `streak` taşan aşamanın art arda taşan
## sprint sayısıdır (en az 2 ise rozet), `hot` en çok taşan aşama o süreklilikteyse. `stays` aşamada kalan kartlar [{card, effort}].
## `people` aşamada çalışanlar {person, busy (kalan haftaların dolu payı), cut (görüşmelerin aldığı pay), effort (sprintteki gücü)},
## `away` seçilemeyenler {person, reason}; `cluster` satır `CLUSTER_OVER`dan çok kişi tutunca yüzlerin yerini alan kümeler. Ekip yalnız
## kurucuysa üç satır `shared`dır ve kurucu Test satırındadır.
static func _capacity(mode: String, run: Dictionary, now: float) -> Variant:
	if run.is_empty():
		return null
	var rows: Array = SprintSystem.STAGES.map(func(stage: String) -> Dictionary:
		return {"stage": stage, "work": 0.0, "team": 0.0, "done": 0.0, "out": 0.0, "stays": {}})
	var seats: Dictionary = _seats(run)
	for id in run.cards:
		for s in run.cards[id].stages:
			if s.stage not in SprintSystem.STAGES:
				continue
			var row: Dictionary = rows[SprintSystem.STAGES.find(s.stage)]
			row.work += s.need - s.done0
			row.team += s.in_sprint - s.done0
			row.out += s.out
			if s.out > SprintSystem.EPS:
				row.stays[id] = row.stays.get(id, 0.0) + s.out
	for id in run.people:
		if run.people[id].row != "":
			rows[SprintSystem.STAGES.find(run.people[id].row)].team += run.people[id].unspent
	var made: Dictionary = stage_done(run.cards.values().map(func(card: Dictionary) -> Array: return card.stages), now) if mode == "active" else {}
	var before: Dictionary = GameState.product.releases.back().get("overflow", {}) if not GameState.product.releases.is_empty() else {}
	var worst: Dictionary = rows.reduce(func(a: Dictionary, b: Dictionary) -> Dictionary: return b if b.out > a.out else a, rows[0])
	var solo: bool = _solo(seats)
	for row in rows:
		var outer: float = maxf(0.0, row.work - row.team)
		row["out_inside"] = clampf(row.out - outer, 0.0, row.out)
		row["streak"] = int(before.get(row.stage, {}).get("streak", 0)) + 1 if row.out > SprintSystem.EPS else 0
		row["hot"] = row.stage == worst.stage and row.streak >= 2
		row["shared"] = solo
		row["stays"] = row.stays.keys().map(func(id: String) -> Dictionary:
			return {"card": SprintCatalog.card_name(GameState.product.cards[id]), "effort": row.stays[id]})
		row.stays.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.effort > b.effort)
		row["done"] = made.get(row.stage, 0.0)
		var seat: Dictionary = seats[row.stage]
		row["people"] = seat.people
		row["away"] = seat.away
		row["cluster"] = _cluster(seat)
	return rows


## Aşama başına bu haftanın `at` anına dek yaptığı iş {aşama: efor}: `stages` kartların aşama listeleridir, eksenin başından önce
## yapılan iş (`done0`) sayılmaz. Saatlik güncelleme saklanan parçalardan bunu okur.
static func stage_done(stages: Array, at: float) -> Dictionary:
	var done := {"design": 0.0, "dev": 0.0, "test": 0.0}
	for card: Array in stages:
		for s: Dictionary in card:
			if done.has(s.stage):
				done[s.stage] += SprintTimeline.done_at(s, at) - s.done0
	return done


## Aşama başına oturanlar {people, away}: sprint ekibinden çalışanlar (`run.people`; satırı zaman ekseninin kapasite satırı) ve
## `SprintSystem.away()`ın seçilemeyenleri; PM'in ve yalnız Destek'te çalışanın satırı yoktur. Kurucu önde, sonra yıldız çoktan aza.
## Ekip yalnız kurucuysa o Test satırında oturur (`_solo`).
static func _seats(run: Dictionary) -> Dictionary:
	var team: Dictionary = {}
	for t in SprintSystem.team():
		team[t.id] = t
	var areas: Dictionary = SprintCatalog.cfg("role_areas")
	var seats: Dictionary = {}
	for stage in SprintSystem.STAGES:
		seats[stage] = {"people": [], "away": []}
	for id in run.people:
		var row: String = run.people[id].row
		if row != "":
			var c: Character = CharacterRegistry.get_character(id)
			seats[row].people.append({"person": _face(c, areas[row]), "busy": run.people[id].busy,
				"cut": 1.0 - GameState.founder_sprint_pay if c.category == "founder" else 0.0, "effort": SprintSystem.capacity_of([team[id]])})
	for gone in SprintSystem.away():
		var c: Character = CharacterRegistry.get_character(gone.id)
		var row: String = run.people.get(gone.id, {}).get("row", "dev") if c.category == "founder" else SprintCatalog.row_of(c)
		if row != "":
			seats[row].away.append({"person": _face(c, areas[row]), "reason": gone.reason})
	var order := func(a: Dictionary, b: Dictionary) -> bool:
		if a.person.founder != b.person.founder:
			return a.person.founder
		return a.person.stars > b.person.stars if a.person.stars != b.person.stars else a.person.id < b.person.id
	for seat in seats.values():
		seat.people.sort_custom(order)
		seat.away.sort_custom(order)
	if _solo(seats):
		for seat in seats.values():
			for key in ["people", "away"]:
				var moved: Array = seat[key].duplicate()
				seat[key].clear()
				seats["test"][key].append_array(moved)
	return seats


## Ekip yalnız kurucu mu: bütün satırlarda (çalışan ve seçilemeyen) oturan tek kişi ve o kurucu.
static func _solo(seats: Dictionary) -> bool:
	var sitting: Array = []
	for seat in seats.values():
		sitting.append_array(seat.people)
		sitting.append_array(seat.away)
	return sitting.size() == 1 and sitting[0].person.founder


## Kalabalık satırın yüzlerinin yerini alan kümeler: kurucular tek tek, her yıldız için bir temsilci yüz ve sayı, seçilemeyenler
## nedenine göre ayrı küme; satır `CLUSTER_OVER`ı aşmıyorsa null.
static func _cluster(seat: Dictionary) -> Variant:
	if seat.people.size() + seat.away.size() <= CLUSTER_OVER:
		return null
	var founders: Array = []
	var stars: Dictionary = {}
	for p in seat.people:
		if p.person.founder:
			founders.append(p.person)
		else:
			stars.get_or_add(p.person.stars, []).append(p.person)
	var away: Dictionary = {}
	for gone in seat.away:
		away.get_or_add(gone.reason, []).append(gone.person)
	var by_stars: Array = stars.keys()
	by_stars.sort()
	by_stars.reverse()
	return {"founders": founders,
		"stars": by_stars.map(func(s: float) -> Dictionary: return {"stars": s, "n": stars[s].size(), "person": stars[s][0]}),
		"away": away.keys().map(func(r: String) -> Dictionary: return {"reason": r, "n": away[r].size(), "person": away[r][0]})}


## Adayın bu aşamalarda sprinte ekleyeceği efor {aşama: efor} (hayalet): planın o kartla oynatmasında kartın aşama ihtiyacı.
## Motorun tanımadığı kimlik (debug fikstürünün kartı) hayalet vermez.
static func ghost_effort(card_id: String) -> Dictionary:
	var out: Dictionary = {}
	if SprintCatalog.card_by_id(card_id).is_empty():
		return out
	for s in ghost(card_id).cards[card_id].stages:
		if s.stage in SprintSystem.STAGES:
			out[s.stage] = out.get(s.stage, 0.0) + s.need
	return out


## Liderin önerisi (devir kapalıyken, bu sprinte ya da sonraki sütuna kart ekleyecekse): {amount, cards: [{name, done, effort}]}.
## `done` her kartın plana eklenince bu sprintte yapacağı iş, `amount` onların toplamı; tek oynatma. Yalnız sütuna ekliyorsa
## {amount: 0.0, cards: []}: sayı ve "efor daha sığar" çizilmez, yalnız düğme.
static func _suggest(offered: Dictionary, pool: Dictionary) -> Variant:
	if offered.this.is_empty():
		return null if offered.next.is_empty() else {"amount": 0.0, "cards": []}
	var played: Dictionary = SprintSystem.timeline(offered.this.map(func(id: String) -> Dictionary: return pool[id]))
	var cards: Array = []
	var amount := 0.0
	for id in offered.this:
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


## Kart satırı: `c` kart, `t` zaman ekseninin o karttaki kaydı (başlamayacak kartta {}). Efor kartın sprintteki yüküdür (`_effort`),
## risk beklenen hatanın tavana (`SprintBugs.ceiling`) oranı ve hazırlanmamış hâli. Hata metni hesap sayısı ve kullanıcıyla biter:
## en büyük hesabın adı satıra sığmaz.
static func _row(c: Dictionary, t: Dictionary, buttons: Array) -> Dictionary:
	var ref: float = SprintBugs.ceiling()
	var preparer: Character = CharacterRegistry.get_character(String(t.get("prep", {}).get("by", "")))
	var due: int = SprintCatalog.due_sprint(c)
	var late: bool = t.get("late", false)
	var slot: Dictionary = {}
	if due >= 0:
		slot = _due(due).merged({"kind": "due"})
	elif c.state == "carried":
		slot = {"kind": "carried"}
	elif late:
		slot = {"kind": "late"}
	return {"id": c.id, "kind": _kind(c), "name": SprintCatalog.card_name(c), "effort": roundi(_effort(c)),
		"raw_effort": roundi(SprintSystem.card_load(c)),
		"module": SprintCatalog.area_short(c.area),
		"fix_text": SprintUiShared.bugs_text(SprintCatalog.bugs_part(c.line, c.bugs), false) if c.kind == "fix" else "",
		"slot": slot, "pm": null if preparer == null else _face(preparer, HRConstants.AREA_PRODUCT), "ask": _ask(c),
		"risk": minf(1.0, t.get("h", 0.0) / ref) if ref > 0.0 else 0.0, "risk_raw": minf(1.0, t.get("h0", 0.0) / ref) if ref > 0.0 else 0.0,
		"late": late, "founder": t.get("founder", false),
		"buttons": buttons.filter(func(b: String) -> bool: return b != "remove" or not c.get("follow", false)),
		"stages": t.get("stages", [])}


## Kartın eforu: sprintteki yükü ÷ hazırlık kazancı. Yük sprintin başındaki kalan ihtiyaçtır; koşarken yalnız testin bulduğu
## düzeltme işi onu büyütür, oynatmanın öngördüğü iş sayılmaz.
static func _effort(c: Dictionary) -> float:
	return SprintSystem.card_load(c) / (1.0 + float(c.get("prep_gain", 0.0)))


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
	var goal: Variant = _goal() if center.sprint >= 0 else null
	if SprintCatalog.quarter_pm() == null:
		return clock.merged({"state": "locked_no_pm", "goal": goal, "columns": []})
	if center.sprint < 0:
		return clock.merged({"state": "open", "goal": null, "columns": []})
	var total: float = SprintSystem.capacity()
	var columns: Array = [{"sprint": center.sprint, "kind": "current", "capacity": _sprint_bar(), "pm": false,
		"flags": _flags(center.sprint), "cards": _current_cards(center.mode), "approved": false}]
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
	return clock.merged({"state": "open", "goal": goal, "columns": columns})


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


## Çeyreğin hedefi: seçilen alan, `SprintCatalog.GOAL_BUGS` ("Hatalar") ya da hedef yok (kimlik ve ad boş). `meter` yalnız alan
## hedefinde ÇEYREK şeridinin ölçeridir: alan seviyesinin sıradaki yıldızın beklentisine oranı onluk vekil ölçekte, hedef ortadaki
## çizgidedir; alanın cümlesi o çizgiyi anlatır.
static func _goal() -> Dictionary:
	var id: String = SprintCatalog.quarter_goal()
	if id == "":
		return {"area_id": "", "area_name": "", "meter": null}
	if id == SprintCatalog.GOAL_BUGS:
		return {"area_id": id, "area_name": _t("PRODUCT_QUARTER_BUGS"), "meter": null}
	var mark: int = int(SprintCatalog.cfg("pm.goal_mark"))
	var total: int = int(SprintCatalog.cfg("pm.goal_squares"))
	var now: int = mini(roundi(ProductQuality.next_ratio(id) * mark), total)
	return {"area_id": id, "area_name": SprintCatalog.area_short(id), "meter": {"text": goal_text(id), "now": now, "target": mark,
		"total": total, "progress_text": _t("PRODUCT_GOAL_PROGRESS").format({"now": now, "total": total})}}


## ÇEYREK'in bu sprint sütununun mini kartları: planlamada kalan puanıyla, kapısı kapanmış kart kilitli; koşarken bitmiş kart bitti.
static func _current_cards(mode: String) -> Array:
	var p: Dictionary = GameState.product
	return p.get("sprint", {}).get("cards", []).map(func(id: String) -> Dictionary:
		var c: Dictionary = p.cards[id]
		if mode == "plan":
			return _planned(c, SprintCard.State.SPRINT_PLAN, {"remaining": _remaining(c)})
		return _card(c, SprintCard.State.BITTI if c.state == "done" else SprintCard.State.SPRINT_AKTIF))


## ÇEYREK'in bu sprint sütununun çubuğu: sprintin kartlarının yükü ve ekibin puanı.
static func _sprint_bar() -> Dictionary:
	var cards: Dictionary = GameState.product.cards
	return _bar(SprintSystem.used(), SprintSystem.capacity(), SprintSystem.done_points(),
		GameState.product.sprint.cards.map(func(id: String) -> Dictionary: return {"pts": SprintSystem.card_load(cards[id])}))


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
	var floor_units: int = InfraSystem.capacity_floor()
	var fewer: int = maxi(units - step, floor_units)
	var lock: String = InfraSystem.lock_reason()
	var lock_tip: String = _t(lock).format({"weeks": Fmt.weeks(InfraSystem.lock_weeks_left())}) if lock != "" else ""
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
		"tiers": InfraSystem.PROVIDER_IDS.map(func(id: String) -> Dictionary: return _tier(id, kind, provider, units, bill, lock_tip)),
		"active": InfraSystem.PROVIDER_IDS.find(provider),
		"capacity": _t("PRODUCT_SERVER_CAPACITY_" + kind).format({"n": Fmt.group(capacity), "bill": Fmt.money_exact(bill)}),
		"percent": percent if capacity > 0 else 0, "state": InfraSystem.capacity_state(), "load": load_text,
		"note": _server_note(kind, capacity, percent),
		"clause": _t(Fmt.count_key("SALES_CLAUSE_WAITING", waiting)).format({"n": waiting}) if waiting > 0 else "",
		"decrease": {"text": _t("PRODUCT_SERVER_BTN_DECREASE").format({"n": Fmt.group(step * unit)}),
			"tip": lock_tip if lock_tip != "" and units <= floor_units else decrease, "off": units <= floor_units},
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
## Kurumsal'dayken alttakiler kilitlidir ve ipucu gerekçedir; sunucu sözleşmesi sürerken (`lock_tip` gerekçesi) etkin kademe
## dışındakiler de.
static func _tier(id: String, kind: String, active: String, units: int, bill: int, lock_tip: String) -> Dictionary:
	var name: String = _t(TIER_KEYS[id])
	var enterprise: bool = id == InfraSystem.PROVIDER_ENTERPRISE
	var off: bool = active == InfraSystem.PROVIDER_ENTERPRISE and not enterprise
	var held: bool = lock_tip != "" and id != active
	var parts: PackedStringArray = [_t("PRODUCT_SERVER_TIER_TIP_PRICE_" + kind).format(
		{"price": Fmt.money_exact(InfraSystem.unit_price(id)), "unit": Fmt.group(InfraSystem.unit_size())}),
		_t("PRODUCT_SERVER_TIER_TIP_OUTAGE").format({"mult": Fmt.number(IncidentSystem.tier_mult(id), 2)})]
	if id == InfraSystem.PROVIDER_LOCAL:
		parts.append(_t("PRODUCT_SERVER_TIER_TIP_REPORTS").format({"pct": roundi((InfraSystem.LOCAL_INFLOW_MULT - 1.0) * 100.0)}))
	parts.append(_t("PRODUCT_SERVER_TIER_TIP_CLAUSE_" + ("YES" if enterprise else "NO")))
	var final_note: String = _t("PRODUCT_SERVER_TIER_TIP_FINAL") if enterprise else ""
	return {"id": id, "name": name, "off": off or held, "final": final_note,
		"tip": _t("PRODUCT_SERVER_TIER_LOCKED") if off else lock_tip if held
			else "\n".join([name, SprintUiShared.SEP.join(parts), final_note]).strip_edges(),
		"preview": _t("PRODUCT_SERVER_TIER_PREVIEW").format({"from": _t(TIER_KEYS.get(active, "")), "to": name,
			"old": Fmt.money_exact(bill), "new": Fmt.money_exact(units * InfraSystem.unit_price(id))})}


# --- Kart ------------------------------------------------------------------------------

static func _card(c: Dictionary, state: SprintCard.State, extra := {}) -> Dictionary:
	var card := {"id": c.id, "name": SprintCatalog.card_name(c), "kind": _kind(c), "roles": c.roles,
		"effort": roundi(SprintSystem.total(c)), "state": state, "effect": SprintCatalog.card_effect(c),
		"locked_node": "", "locked_rnd": "", "remaining": -1, "ready": -1.0,
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


## Sayfanın saat içinde değişebilen ve sinyalsiz okuduğu hâli: masada görünen kâğıtlar ve ekrandaki karar (kartın "?" yuvası), çalışanların
## durumu ve işleri, kurucunun işleri (kim sprintte çalışabilir). Sekme her saatin `desk_changed`ında bunu son kurulumunkiyle karşılaştırır.
static func desk_stamp() -> Array:
	var team: Array = [CharacterRegistry.get_founder().assigned_job_ids.duplicate()]
	for c in CharacterRegistry.get_employees():
		team.append([c.id, c.status, c.assigned_job_ids.duplicate()])
	return [EventGate.active_id(), EvPapers.visible(-1), team]


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
