extends RefCounted

# Ürün sprint ekranının debug kaynağı (sekmenin set_source'u): beş mockup (c1..c5) ve uç
# durumlar. Simülasyon yok: act() geçiş tablosunu sürer ve kartları listeler arasında taşır;
# bu sprintin kartları yalnız kapasite bloğunun yükünü kurar, pano onları çizmez; sağ sütun yalnız Hazırlık'ı (PM'siz) ve aşama yükünü
# çizer, sonraki sprintin kartları aşama payı ve hazırlayanı olmadan satırdır. model() her çağrıda
# baştan kurulur, taşımalar günlükten yeniden oynanır; metin o anki dilde çözülür (özel adlar düz).

## Geçiş tablosu: eylem → [geçerli olduğu orta sütun kipi, varılan aşama].
const STAGES := {"start": ["plan", "active"], "advance": ["active", "release"], "plan_next": ["release", "replan"]}
## Uç durumun ve aşamanın üstüne kurulduğu mockup; listede olmayan c1'dir.
const BASES := {"active": "c2", "mvp": "c2", "release": "c3",
	"no_release": "c3", "gate": "c3", "release_fix": "c3", "release_reviews": "c3",
	"goal_menu": "c4", "approved": "c4"}
## id → [ad TR, ad EN, kısa ad TR, kısa ad EN]; kısa ad hedefte.
const AREAS := {
	"core": ["Çekirdek", "Core", "Çekirdek", "Core"],
	"onboarding": ["İlk Kullanım ve Erişim", "Onboarding & Access", "İlk kullanım", "Onboarding"],
	"growth": ["Büyüme", "Growth", "Büyüme", "Growth"],
	"integrations": ["Entegrasyonlar", "Integrations", "Entegrasyonlar", "Integrations"],
	"trust": ["Güven & Ölçek", "Trust & Scale", "Güven", "Trust"],
	"revenue": ["Gelir", "Revenue", "Gelir", "Revenue"],
}
## c1'in bu sprinti; çeyreğin ilk sütunu ve sprinti boşaltan uç durumlar da bunu okur.
const C1_SPRINT := ["kesinti", "kisa_kayit", "filtreli"]

var _stage: String
var _log: Array = []


func _init(fixture_id: String) -> void:
	_stage = fixture_id


func model() -> Dictionary:
	var m: Dictionary = _build(_stage)
	# The left column and the strip read these; the fixtures carry no modules or requests.
	m.merge({"founder": {"on": true, "locked": "", "rnd_text": ""}, "requests": null, "modules": [], "prep": {"pms": []}})
	for entry in _log:
		_apply(m, entry[0], entry[1])
	_header_and_capacity(m)
	return m


## Sprint başlığı, kapasite bloğu, alt şerit ve sağ sütun yeni sözleşmeyi okur: kapasite fikstürün çubuğundan üç aşamaya eşit bölünür,
## kimse oturmaz, panoda satır yoktur, devir yoktur, sonraki sprintin kartları paysız satırdır; çeyreğin saati ve hedefi (yoksa "hedef
## yok") sabittir.
func _header_and_capacity(m: Dictionary) -> void:
	var c: Dictionary = m.center
	var bar: Dictionary = c.capacity
	var stages: Array = SprintSystem.STAGES
	c.merge({"team_empty": bar.total == 0, "now_at": 0.0, "crew": null, "people": {}, "candidates": [], "close_at": float(c.weeks),
		"start_skips": c.mode == "plan" and bar.total > 0 and c.cards.is_empty(), "delegate": {"on": false, "pm": null},
		"progress": {"done": bar.done, "total": bar.used, "known": []}, "cards": [],
		"capacity": stages.map(func(stage: String) -> Dictionary:
			return {"stage": stage, "work": bar.used / 3.0, "team": bar.total / 3.0, "done": 0.0, "out": maxf(0.0, bar.used - bar.total) / 3.0,
				"out_inside": 0.0, "streak": 0, "hot": false, "shared": false, "stays": [], "people": [], "away": [], "cluster": null})}, true)
	m.next = {"sprint": m.next.sprint, "carried": [], "load": stages.map(func(stage: String) -> Dictionary:
		return {"stage": stage, "carried": 0.0, "planned": 0.0, "team": bar.total / 3.0}),
		"cards": m.next.cards.map(func(card: Dictionary) -> Dictionary:
			return {"id": card.id, "kind": card.kind, "name": card.name, "effort": card.effort, "raw_effort": card.effort, "ahead": false,
				"parts": [], "prep": null, "buttons": ["pull", "remove"] if c.mode == "plan" else ["remove"]})}
	m.quarter.merge({"q": 1, "year": 2012, "pos": 1, "total": 6})
	var goal: Variant = m.quarter.goal
	m.quarter.goal = {"area_id": "", "area_name": "", "meter": null} if goal == null else {"area_id": goal.area_id,
		"area_name": goal.area_name, "meter": {"text": goal.text, "now": goal.now, "target": goal.target, "total": goal.total,
			"progress_text": goal.progress_text}}


func act(kind: String, args: Dictionary) -> void:
	if kind == "rnd":
		# Ar-Ge'ye yol canlıdaki gibi sayfayı açar; model değişmez.
		EventBus.tab_changed.emit("rnd")
		EventBus.rnd_node_requested.emit(args.node, false)
	elif STAGES.has(kind):
		if model().center.mode == STAGES[kind][0]:
			_stage = STAGES[kind][1]
			_log.clear()
	else:
		_log.append([kind, args])


func _build(id: String) -> Dictionary:
	var m: Dictionary
	match BASES.get(id, id):
		"c2": m = _c2()
		"c3": m = _c3()
		"c5": m = _c5()
		_: m = _c1()
	match id:
		"c4", "goal_menu", "approved":
			m.ui.view = "quarter"
			m.quarter = _quarter()
			if id == "approved":
				_apply(m, "approve", {"sprint": 8})
		"replan":
			_place(m, "filtreli", "next")
			m.next = _notly_next(true)
			m.header.live_version = "1.5"
		"cap_zero":
			m.center.capacity.total = 0
			m.center.staffed = false
			_clear_sprint(m)
		"team_none":
			# Kadro var ama Yapım ya da Test işinde kimse yok: kartlar planda, sprint başlamaz.
			m.center.capacity.total = 0
			_resum(m.center)
		"over_100":
			_place(m, "mobil_giris", "center")
		"over_125":
			_place(m, "mobil_giris", "center")
			_place(m, "ilk_tur", "center")
		"empty_start":
			_clear_sprint(m)
		"no_release":
			# MVP öncesi kapanış, hiç kart bitmedi: sürüm yok, çıkan yok, hız sıfır, basın satırı yok; v1.0'a
			# iki kart kaldı.
			m.versions = []
			m.header.live_version = ""
			m.center.mvp = _mvp_line()
			m.center.release.version = ""
			m.center.release.shipped = []
			m.center.release.velocity.done = 0
			m.center.release.press = {}
			m.center.release.result = null
		"gate":
			# MVP kapısı: Çekirdek'in üç kartı bitti, ürün oyuncunun Yayınla'sını bekliyor; sürüm ve basın yok.
			m.versions = []
			m.header.live_version = ""
			m.center.mvp = _mvp_line().merged({"done": 3}, true)
			m.center.release.version = ""
			m.center.release.gate = true
			m.center.release.press = {}
			m.center.release.result = null
		"release_fix":
			# Düzeltme satırları kapanıştaki gerçek sayıyı yazar: planlanırken 5 olan hat kapanışta 9'du; öbürü, hatalı
			# kapanan bir kartın hatası aynı hatta düştüğü için 1'e indi.
			var note: Dictionary = m.center.release
			note.shipped = [_deck("kisa_kayit", SprintCard.State.BITTI), _shipped_fix("kesinti", 9, 0),
				_shipped_fix("esitleme", 6, 1)]
			note.result = {"kind": "actual", "text": tr(Fmt.count_key("PRODUCT_RESULT_BUGS_ACTUAL", 15)).format({"n": 15})}
		"release_reviews":
			# Sürümden bir tik sonra B2C güncellemesinin yorumları: adlı yeni özellik, kapanan düzeltme ve güncellemeyi
			# suçlayan olumsuz yorum.
			m.center.release.reviews = SprintBridges.review_lines({"reviews": {"feature": "line_note_tool_capture_k2",
				"at": -1, "ids": ["PRODUCT_REVIEW_NEW_NAMED_2", "PRODUCT_REVIEW_FIX_2", "PRODUCT_REVIEW_NEG_INTEGRATIONS_1"]}})
		"history_empty":
			m.versions = []
			m.ui.history_open = true
			m.header.live_version = ""
		"history":
			m.ui.history_open = true
			m.ui.open_area = ""
		"mvp":
			m.versions = []
			m.header.live_version = ""
			m.center.mvp = _mvp_line()
		"quarter_no_pm":
			m.quarter.state = "locked_no_pm"
	return m


func _apply(m: Dictionary, kind: String, args: Dictionary) -> void:
	match kind:
		"add", "pull": _place(m, args.card_id, "center")
		"send_next": _place(m, args.card_id, "next")
		"remove": _place(m, args.card_id, "")
		"apply_lead":
			m.center.suggest = null   # fikstür yuvaları doldurmaz; öneri kullanıldı diye satır gizlenir
		"publish":
			# Kapıdaki not v1.0'ın sürüm notu olur: ürün canlı, Ar-Ge açık.
			var r: Dictionary = m.center.release
			r.gate = false
			r.rnd_open = true
			r.version = _version("1.0")
			r.result = {"kind": "expected", "text": tr("PRODUCT_RESULT_MVP_EXPECTED")}
			m.header.live_version = "1.0"
			m.center.mvp = null
		"approve", "approve_all":
			for col in m.quarter.columns:
				if col.kind == "proposed" and (kind == "approve_all" or col.sprint == args.sprint):
					col.approved = true
		"edit":
			# Düzenlenen PM sütunu SPRINT görünümünde sonraki sprint olarak açılır (görünümü sekme değiştirir).
			var col: Dictionary = m.quarter.columns.filter(func(c: Dictionary) -> bool: return c.sprint == args.sprint)[0]
			m.next.sprint = col.sprint
			m.next.cards = col.cards
		"pick_goal":
			m.quarter.goal.area_id = args.area_id
			m.quarter.goal.area_name = _short(args.area_id)
			m.quarter.goal.text = _area_of(m, args.area_id).goal_text


## Kartı taşır: "center" bu sprint, "next" sonraki, "" plandan çıkar. İki sütunda olmayan kart desteden gelir.
func _place(m: Dictionary, id: String, where: String) -> void:
	var found: Array = (m.center.cards + m.next.cards).filter(func(c: Dictionary) -> bool: return c.id == id)
	var card: Dictionary = found[0].duplicate(true) if not found.is_empty() else _deck(id, SprintCard.State.SPRINT_PLAN)
	m.center.cards = m.center.cards.filter(func(c: Dictionary) -> bool: return c.id != id)
	m.next.cards = m.next.cards.filter(func(c: Dictionary) -> bool: return c.id != id)
	if where != "":
		var target: Dictionary = m.center if where == "center" else m.next
		card.state = SprintCard.State.SPRINT_PLAN if where == "center" else SprintCard.State.PLANLANAN
		target.cards.append(card)
	_resum(m.center)


func _clear_sprint(m: Dictionary) -> void:
	for card_id in C1_SPRINT:
		_place(m, card_id, "")


## Kapasite kartlardan toplanır; planlamada "+" ve başlat izinleri de buradan: "+" boş puan kaldıkça açık, ekip varken başlat açık.
func _resum(c: Dictionary) -> void:
	c.capacity = _capacity(c.cards, c.capacity.total, c.capacity.done)
	if c.mode != "plan":
		return
	var cap: Dictionary = c.capacity
	c.spare = cap.used < cap.total
	c.can_start = cap.total > 0
	c.start_reason = "" if c.can_start else tr("PRODUCT_TEAM_NOBODY_JOBS")


## Kapasitenin yükü kartların toplamıdır; devreden kart kalan puanıyla sayılır.
func _capacity(cards: Array, total: float, done: float) -> Dictionary:
	var used := 0.0
	var segments: Array = []
	for card in cards:
		var pts: float = card.remaining if card.remaining >= 0 else card.effort
		used += pts
		segments.append({"pts": pts})
	var state: String = "blocked" if total == 0 else ("over" if used > total else "ok")
	return {"used": used, "total": total, "done": done, "state": state, "segments": segments}


# --- Mockup'lar -------------------------------------------------------------

func _c1() -> Dictionary:
	return {
		"header": _header("Notly", "B2C", tr("PROD_TYPE_NOTE_TOOL_NAME")),
		"versions": _versions(),
		"quarter": {"state": "locked_no_pm", "goal": null, "columns": []},
		"ui": _ui_state("onboarding", "kisa_kayit"),
		"areas": ["core", "onboarding", "growth", "trust", "revenue"].map(_area),
		"center": _center("plan", _sprint_cards(), {
			"suggest": {"amount": 20.0, "cards": [{"name": _p("Kesinti düzeltmesi", "Outage fix"), "done": 10.0, "effort": 10.0},
				{"name": _p("Kısa kayıt", "Short sign-up"), "done": 10.0, "effort": 15.0}]},
		}),
		"next": _notly_next(false),
	}


func _c2() -> Dictionary:
	var m := _c1()
	m.ui = _ui_state("", "")
	m.center = _center("active", _active_cards(), {"capacity": {"total": 60, "done": 10}})
	return m


func _c3() -> Dictionary:
	var m := _c1()
	m.header.live_version = "1.5"
	m.ui = _ui_state("", "")
	var carried := _deck("filtreli", SprintCard.State.DEVREDEN)
	m.center = _center("release", [], {"week": 2, "release": {
		"version": _version("1.5"),
		"gate": false,
		"rnd_open": false,
		"shipped": [_deck("kisa_kayit", SprintCard.State.BITTI), _shipped_fix("kesinti", 5, 0)],
		"carried": [{"name": carried.name, "kind": carried.kind, "done": 15, "total": 25, "to_sprint": 8}],
		"velocity": {"done": 40, "total": 60},
		"result": {"kind": "actual", "text": _p("10 yeni kullanıcıdan 6'sı ilk hafta kaldı (önce 4).",
			"6 of 10 new users stayed the first week (4 before).")},
		"press": {"outlet": "WORLD_OUTLET_TEKNOGUNDEM",
			"text": _p("Notly kayıt akışını kısalttı.", "Notly shortened its sign-up flow.")},
		"reviews": [],
		"lead": _lead(_p("Arama bir sprint daha ister.", "Search needs one more sprint.")),
	}})
	m.next = _notly_next(true)
	return m


func _c5() -> Dictionary:
	var plan := SprintCard.State.SPRINT_PLAN
	return {
		"header": _header("Fatura", "B2B", _p("Faturalama SaaS'ı", "Invoicing SaaS")),
		"versions": _versions(),
		"quarter": {"state": "locked_no_pm", "goal": null, "columns": []},
		"ui": _ui_state("trust", ""),
		"areas": ["core", "onboarding", "integrations", "trust"].map(_area),
		"center": _center("plan", [_deck("sso", plan), _deck("kesinti", plan, {"effort": 12}), _deck("excel", plan)], {
			"suggest": {"amount": 12.0, "cards": [{"name": "SSO", "done": 12.0, "effort": 12.0}]},
		}),
		"next": {"sprint": 8, "cards": [_deck("efatura", SprintCard.State.PLANLANAN)]},
	}


func _notly_next(carried: bool) -> Dictionary:
	var cards: Array = [_deck("ilk_tur", SprintCard.State.PLANLANAN), _deck("oto_yedek", SprintCard.State.PLANLANAN)]
	if carried:
		cards.push_front(_deck("filtreli", SprintCard.State.DEVREDEN, {"remaining": 10}))
	return {"sprint": 8, "cards": cards}


func _quarter() -> Dictionary:
	var planned := SprintCard.State.PLANLANAN
	return {
		"state": "open",
		"goal": {"area_id": "onboarding", "area_name": _short("onboarding"), "text": ProductModel.goal_text("onboarding"),
			"now": 4, "target": 5, "total": 10, "progress_text": tr("PRODUCT_GOAL_PROGRESS").format({"now": 4, "total": 10})},
		"columns": [
			_column(7, "current", _sprint_cards(), []),
			_column(8, "proposed", [_deck("ilk_tur", planned), _deck("mobil_giris", planned), _deck("oto_yedek", planned)],
				[_rival_flag()]),
			_column(9, "proposed", [_deck("etiketler", planned), _deck("baglanti", planned)], []),
			_column(10, "proposed", [_deck("ucretli", planned)], []),
			_column(11, "empty", [], []),
			_column(12, "empty", [], []),
		],
	}


func _column(sprint: int, kind: String, cards: Array, flags: Array) -> Dictionary:
	var col := {"sprint": sprint, "kind": kind, "capacity": null, "pm": kind == "proposed", "flags": flags,
		"cards": cards, "approved": false}
	if kind != "empty":
		col.capacity = _capacity(cards, 60, 0)
	return col


## c2'nin kartları: biten ve sürenler.
func _active_cards() -> Array:
	return [_deck("kesinti", SprintCard.State.BITTI), _deck("kisa_kayit", SprintCard.State.SPRINT_AKTIF),
		_deck("filtreli", SprintCard.State.SPRINT_AKTIF)]


func _sprint_cards() -> Array:
	return C1_SPRINT.map(func(card_id: String) -> Dictionary: return _deck(card_id, SprintCard.State.SPRINT_PLAN))


# --- Parçalar ---------------------------------------------------------------

## id → [tür, efor, ad].
func _deck_table() -> Dictionary:
	return {
		"kesinti": ["fix", 10, _p("Kesinti düzeltmesi", "Outage fix")],
		"esitleme": ["fix", 10, _p("Eşitleme düzeltmesi", "Sync fix")],
		"kisa_kayit": ["feature", 15, _p("Kısa kayıt", "Short sign-up")],
		"ilk_tur": ["feature", 10, _p("İlk tur rehberi", "First-run guide")],
		"mobil_giris": ["feature", 20, _p("Mobil giriş", "Mobile login")],
		"filtreli": ["polish", 25, _p("Filtreli arama", "Filtered search")],
		"oto_yedek": ["feature", 15, _p("Otomatik yedekleme", "Automatic backups")],
		"etiketler": ["feature", 20, _p("Etiketler", "Tags")],
		"baglanti": ["feature", 20, _p("Bağlantıyla paylaşım", "Share by link")],
		"ucretli": ["feature", 30, _p("Ücretli plan", "Paid plan")],
		"akilli_arama": ["feature", 40, _p("Akıllı arama", "Smart search")],
		"sso": ["feature", 25, "SSO (Nordica)"],
		"excel": ["feature", 15, _p("Tablo dışa aktarma (Palmiye)", "Spreadsheet export (Palmiye)")],
		"efatura": ["feature", 25, _p("e-Fatura entegrasyonu", "e-Invoice integration")],
	}


func _deck(id: String, state: int, extra := {}) -> Dictionary:
	var d: Array = _deck_table()[id]
	var card := {"id": id, "name": d[2], "kind": d[0], "effort": d[1], "state": state, "remaining": -1}
	card.merge(extra, true)
	return card


## Sürüm notundaki düzeltme satırı: adı kapanıştaki "önce → sonra" sayıyı da taşır (ProductModel._shipped).
func _shipped_fix(id: String, from: int, to: int) -> Dictionary:
	var card: Dictionary = _deck(id, SprintCard.State.BITTI)
	card.name += SprintUiShared.SEP + tr(Fmt.count_key("PRODUCT_FX_BUGS_FIXED", to)).format({"from": from, "to": to})
	return card


## Çeyrek hedef menüsünün alanı.
func _area(id: String) -> Dictionary:
	return {"id": id, "name": _p(AREAS[id][0], AREAS[id][1]), "goal_text": ProductModel.goal_text(id)}


func _area_of(m: Dictionary, id: String) -> Dictionary:
	return m.areas.filter(func(a: Dictionary) -> bool: return a.id == id)[0]


func _center(mode: String, cards: Array, extra: Dictionary) -> Dictionary:
	var c := {"mode": mode, "sprint": 7, "weeks": 2, "week": 1, "capacity": {"total": 60, "done": 0},
		"staffed": true, "cards": cards,
		"mvp": null, "spare": false, "ceiling_pct": 125, "can_start": false,
		"start_reason": "", "rnd_node": null, "suggest": null, "release": null}
	c.merge(extra, true)
	_resum(c)
	return c


## Fikstürün kişilerinin görünüşü yok: yüzleri baş harfleridir.
func _team() -> Array:
	var engineering := _p("Yazılım", "Engineering")
	return [
		{"name": _p("Kurucu", "Founder"), "role_text": _p("Ürün · Yazılım", "Product · Engineering"), "look": {}, "share": 1.0},
		{"name": "Deniz", "role_text": engineering, "look": {}, "share": 1.0},
		{"name": "Ece", "role_text": _p("Tasarım", "Design"), "look": {}, "share": 1.0},
		{"name": "Kaan", "role_text": engineering, "look": {}, "share": 1.0},
	]


func _person(person_name: String) -> Dictionary:
	return _team().filter(func(p: Dictionary) -> bool: return p.name == person_name)[0]


func _lead(text: String) -> Dictionary:
	return _person("Deniz").merged({"text": text, "self": false})


func _header(product: String, market: String, type_text: String) -> Dictionary:
	# Mockup'larda kitle ve ödeyen ölçüsü yok: canlı B2C'nin ölçüleri live:b2c_live'da.
	return {"name": product, "live_version": "1.4", "market": market, "type_text": type_text, "users": -1, "paying": -1}


## MVP öncesi sürüm koşulu: v1.0'a iki Çekirdek kartı kaldı, motor Sprint 8 sonunu tahmin ediyor.
func _mvp_line() -> Dictionary:
	return {"version": _version("1.0"), "area": _short("core"), "need": 3, "done": 1, "sprint": 8, "week": 16}


func _versions() -> Array:
	return [
		{"label": _version("1.2"), "sprint": 3, "shipped_count": 2, "result": {"kind": "actual",
			"text": _p("Yeni kullanıcıların yarısı ilk hafta kaldı.", "Half of new users stayed the first week.")}},
		{"label": _version("1.3"), "sprint": 5, "shipped_count": 3, "result": {"kind": "actual",
			"text": _p("Kesinti şikâyetleri durdu.", "Outage complaints stopped.")}},
		{"label": _version("1.4"), "sprint": 6, "shipped_count": 2, "result": {"kind": "expected",
			"text": _p("Kullanıcıların yarısı verisini emanet etsin.", "Half of users trust it with their data.")}},
	]


func _ui_state(open_area: String, hover_card: String) -> Dictionary:
	return {"view": "sprint", "open_area": open_area, "history_open": false, "hover_card": hover_card, "requests_open": false}


func _rival_flag() -> Dictionary:
	return {"k": "rival", "text": tr("PRODUCT_RIVAL_TOPIC").format({"topic": _p("mobil", "mobile")})}


func _short(area: String) -> String:
	return _p(AREAS[area][2], AREAS[area][3])


func _version(n: String) -> String:
	return tr("PROD_VERSION_SHORT").format({"version": n})


func _p(tr_text: String, en_text: String) -> String:
	return Localization.pick(tr_text, en_text)
