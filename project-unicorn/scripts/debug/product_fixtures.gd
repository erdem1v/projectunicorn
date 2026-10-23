extends RefCounted

# Ürün sprint ekranının debug kaynağı (sekmenin set_source'u): beş mockup (c1..c5), kart
# galerisi (cards) ve uç durumlar. Simülasyon yok: act() geçiş tablosunu sürer ve kartları
# listeler arasında taşır. model() her çağrıda baştan kurulur, taşımalar günlükten yeniden
# oynanır; metin o anki dilde çözülür (özel adlar düz).

const INBOX := preload("res://scripts/ui/components/inbox.gd")
## Geçiş tablosu: eylem → [geçerli olduğu orta sütun kipi, varılan aşama].
const STAGES := {"start": ["plan", "active"], "advance": ["active", "release"], "plan_next": ["release", "replan"]}
## Uç durumun ve aşamanın üstüne kurulduğu mockup; listede olmayan c1'dir.
const BASES := {"active": "c2", "decision": "c2", "mvp": "c2", "pm_started": "c2", "release": "c3",
	"no_release": "c3", "gate": "c3", "release_fix": "c3", "release_reviews": "c3", "b2b_no_requests": "c5",
	"fix_long_name": "c5",
	"bug_lines_b2b": "c5", "bug_lines_many": "c5", "goal_menu": "c4", "approved": "c4"}
## id → [ad TR, ad EN, kısa ad TR, kısa ad EN]; kısa ad etki satırında ve hedefte.
const AREAS := {
	"core": ["Çekirdek", "Core", "Çekirdek", "Core"],
	"onboarding": ["İlk Kullanım ve Erişim", "Onboarding & Access", "İlk kullanım", "Onboarding"],
	"growth": ["Büyüme", "Growth", "Büyüme", "Growth"],
	"integrations": ["Entegrasyonlar", "Integrations", "Entegrasyonlar", "Integrations"],
	"trust": ["Güven & Ölçek", "Trust & Scale", "Güven", "Trust"],
	"revenue": ["Gelir", "Revenue", "Gelir", "Revenue"],
}
## Fikstür seviyesinin (0..3) kelimesi; fikstür beklentiyi her alanda aynı tutar.
const WORDS := ["none", "weak", "enough", "strong"]
## c1'in bu sprinti; çeyreğin ilk sütunu ve sprinti boşaltan uç durumlar da bunu okur.
const C1_SPRINT := ["kesinti", "kisa_kayit", "filtreli"]
## Karar bekleyen ve sıradaki kartın fazları.
const WAITING := ["waiting", "waiting", "waiting"]

var _stage: String
var _log: Array = []


func _init(fixture_id: String) -> void:
	_stage = fixture_id


func model() -> Dictionary:
	var m: Dictionary = _build(_stage)
	for entry in _log:
		_apply(m, entry[0], entry[1])
	# Fikstürde "+" sprintin geneline bağlıdır: her aday ve talep satırı merkezin can_add'ini okur; `no_room` işaretli
	# kart sprintte boş puan kalsa da o puanı kullanamaz.
	for list in m.areas.map(func(a: Dictionary) -> Array: return a.candidates) + [m.customers if m.customers != null else []]:
		for c in list:
			c.addable = m.center.can_add and not c.get("no_room", false)
	return m


func act(kind: String, args: Dictionary) -> void:
	if kind == "decide":
		var card: Dictionary = model().center.cards.filter(func(c: Dictionary) -> bool: return c.id == args.card_id)[0]
		# Fikstür olay kartı yalnız bu çağrı boyunca açılan kapsamdadır.
		var shipped: Array = EvTuning.SHIPPED_SCOPES.duplicate()
		EvTuning.SHIPPED_SCOPES.append("fixture")
		EventGate.force_fire(card.decision.event_id)
		EvTuning.SHIPPED_SCOPES.assign(shipped)
	elif kind == "rnd":
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
		"cards":
			m.center.cards = [
				_deck("gorusme", SprintCard.State.ADAY, {"priority": true, "addable": true}),
				_deck("ilk_tur", SprintCard.State.ADAY_ALINMIS, {"tag_sprint": 8}),
				_deck("mobil_giris", SprintCard.State.SPRINT_PLAN, {"spills": true, "planned_done": 7.5}),
				_deck("ucretli", SprintCard.State.SPRINT_PLAN, {"no_start": 8}),
				_deck("oto_yedek", SprintCard.State.DEVREDEN, {"remaining": 1.25}),
				_deck("etiketler", SprintCard.State.PLANLANAN),
				_deck("akilli_arama", SprintCard.State.KILITLI, {"locked_node": tr("PROD_LOCK_RESEARCH").format({"node": _p("Gelişmiş arama", "Advanced search")}),
					"locked_rnd": "semantic_index"}),
				_deck("efatura", SprintCard.State.SPRINT_AKTIF, {"phases": WAITING, "queued": true}),
			] + _active_cards()
			m.ui.hover_card = "mobil_giris"
			# Mini kartlar çeyrek sütunlarında: ÇEYREK görünümü açık.
			m.quarter = _quarter()
		"no_candidates":
			var onboarding: Dictionary = _area_of(m, "onboarding")
			onboarding.candidates = []
			onboarding["empty"] = true
		"cap_zero":
			m.center.capacity.total = 0
			m.center.team = []
			m.center.staffed = false
			m.center.warning_text = ""
			_clear_sprint(m)
			m.center.lead_tip = null
		"team_split":
			# Deniz Yapım ve Destek tutar: sprintte yarım payla; Kaan yalnız Destek'te, ekipte yok.
			var team: Array = _team()
			m.center.team = [team[0], team[1].merged({"share": 0.5}, true), team[2]]
			m.center.capacity.total = 50
			_resum(m.center)
		"team_none":
			# Kadro var ama Yapım ya da Test işinde kimse yok: kartlar planda, sprint başlamaz.
			m.center.team = []
			m.center.capacity.total = 0
			m.center.warning_text = ""
			m.center.lead_tip = null
			m.center.forecast = []
			_resum(m.center)
		"over_100":
			_place(m, "mobil_giris", "center")
		"over_125":
			_place(m, "mobil_giris", "center")
			_place(m, "ilk_tur", "center")
		"plus_closed":
			# Sprintte boş puan var (50/60) ama Mobil giriş yazılım aşamasından başlar ve yazılımcı dolu: "+" kapalı;
			# araştırma kartı ilk aşamadan başlar, "+" açık.
			for c in _area_of(m, "onboarding").candidates:
				c["no_room"] = c.id == "mobil_giris"
		"start_shut":
			# Planlandıktan sonra kapısı kapanan Kısa kayıt: plan baştan "Bu sprint başlamaz" der, puan almaz, sprint sonunda
			# Zayıf → Yeterli satırı yoktur; kapasite çubuğu yükünü hâlâ sayar.
			for c in m.center.cards:
				c["gate_closed"] = c.id == "kisa_kayit"
				if c.gate_closed:
					c.effort_split = []
			_resum(m.center)
			m.center.forecast = m.center.forecast.filter(func(part: Dictionary) -> bool: return part.k != "level")
		"empty_start":
			_clear_sprint(m)
		"no_release":
			# MVP öncesi kapanış, hiç kart bitmedi: sürüm yok, çıkan yok, hız sıfır, basın satırı yok; v1.0'a
			# iki kart kaldı.
			m.versions = []
			m.header.live_version = ""
			m.center.mvp_line = _mvp_line()
			m.center.release.version = ""
			m.center.release.shipped = []
			m.center.release.velocity.done = 0
			m.center.release.press = {}
			m.center.release.result = null
		"gate":
			# MVP kapısı: Çekirdek'in üç kartı bitti, ürün oyuncunun Yayınla'sını bekliyor; sürüm ve basın yok.
			m.versions = []
			m.header.live_version = ""
			m.center.mvp_line = _mvp_line().merged({"done": 3}, true)
			m.center.release.version = ""
			m.center.release.gate = true
			m.center.release.press = {}
			m.center.release.result = null
		"b2b_no_requests":
			m.customers = []
			m.next.flags = []
		"fix_long_name":
			# B2B düzeltme kartının hata satırı: en büyük hesabın adı satıra sığmayacak kadar uzun, sarar. Geniş kartta
			# (bu sprint), açık alandaki dar kartta ve sonraki sütundaki kartta.
			var effect: Array = [_bugs(6, 3, 140, "Anadolu Lojistik ve Taşımacılık Sanayi A.Ş.", 100), _clear("trust")]
			for list in [m.center.cards, _area_of(m, "trust").candidates]:
				for c in list:
					if c.id == "kesinti":
						c.effect = effect
			m.next.cards.push_front(_deck("kesinti", SprintCard.State.PLANLANAN, {"id": "kesinti_sonraki", "effect": effect}))
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
		"locked_k3":
			m.ui.open_area = "core"
			_area_of(m, "core").candidates.append(_deck("akilli_arama", SprintCard.State.KILITLI,
				{"locked_node": tr("PROD_LOCK_RESEARCH").format({"node": _p("Gelişmiş arama", "Advanced search")}),
				"locked_rnd": "semantic_index"}))
		"history_empty":
			m.versions = []
			m.ui.history_open = true
			m.header.live_version = ""
		"history":
			m.ui.history_open = true
			m.ui.open_area = ""
		"pm_started":
			m.center.pm_started = "Deniz"
			m.center.delegate = {"on": true, "name": "Deniz"}
		"mvp":
			m.versions = []
			m.header.live_version = ""
			m.center.next_version = null
			m.center.mvp_line = _mvp_line()
		"quarter_no_pm":
			m.quarter.state = "locked_no_pm"
		"bug_lines_b2b":
			# Hat paneli, B2B: üç hat, biri arttı, biri azaldı, biri aynı; en büyük hesap ipucunda.
			m.customers = []
			_area_of(m, "core").capabilities = [_cap(_p("Fatura", "Invoicing"), 2), _cap(_p("Stok", "Stock"), 2),
				_cap(_p("Defter", "Ledger"), 1)]
			_area_of(m, "core").candidates = [_deck("fatura_fix", SprintCard.State.ADAY)]
			_bug_lines(m, "core", [
				[_p("Fatura", "Invoicing"), _bugs(6, 3, 140, "Nordica", 100), 2],
				[_p("Stok", "Stock"), _bugs(3, 1, 40, "Palmiye", 40), -1],
				[_p("Defter", "Ledger"), _bugs(1, 2, 90, "Beykoz", 60), 0]])
		"bug_lines_b2c":
			# Hat paneli, B2C: kullanıcı sayısı var, hesap yok.
			_area_of(m, "core").capabilities.push_front(_cap(_p("Eşitleme", "Sync"), 1))
			_area_of(m, "core").candidates.push_front(_deck("esitleme", SprintCard.State.ADAY))
			_bug_lines(m, "core", [
				[_p("Eşitleme", "Sync"), _bugs(5, -1, 300), -1],
				[_p("Arama", "Search"), _bugs(2, -1, 120), 1],
				[_p("Editör", "Editor"), _bugs(1, -1, 60), 0]])
		"bug_lines_many":
			# Rastgele dağılımın hâli: çekirdeğin beş hattının hepsinde 1 ya da 2 hata, kalabalık sayılarla.
			m.customers = []
			_area_of(m, "core").capabilities = [_cap(_p("Nakit Akışı", "Cash Flow"), 2),
				_cap(_p("Veri Girişi", "Data Entry"), 1), _cap(_p("Defter", "Ledger"), 2), _cap(_p("Stok", "Stock"), 2),
				_cap(_p("Fatura", "Invoicing"), 2)]
			_bug_lines(m, "core", [
				[_p("Nakit Akışı", "Cash Flow"), _bugs(2, 14, 1240, "Nordica", 300), 1],
				[_p("Veri Girişi", "Data Entry"), _bugs(2, 4, 210, "Palmiye", 90), 1],
				[_p("Defter", "Ledger"), _bugs(2, 5, 350, "Nordica", 300), 0],
				[_p("Stok", "Stock"), _bugs(1, 4, 310, "Beykoz", 120), -1],
				[_p("Fatura", "Invoicing"), _bugs(1, 3, 140, "Nordica", 100), 1]])
	return m


func _apply(m: Dictionary, kind: String, args: Dictionary) -> void:
	match kind:
		"add", "pull": _place(m, args.card_id, "center")
		"send_next": _place(m, args.card_id, "next")
		"remove": _place(m, args.card_id, "")
		"apply_lead":
			m.center.lead_tip = null   # fikstür yuvaları doldurmaz; öneri kullanıldı diye düşer
		"publish":
			# Kapıdaki not v1.0'ın sürüm notu olur: ürün canlı, Ar-Ge açık.
			var r: Dictionary = m.center.release
			r.gate = false
			r.rnd_open = true
			r.version = _version("1.0")
			r.result = {"kind": "expected", "text": tr("PRODUCT_RESULT_MVP_EXPECTED")}
			m.header.live_version = "1.0"
			m.center.mvp_line = null
		"approve", "approve_all":
			for col in m.quarter.columns:
				if col.kind == "proposed" and (kind == "approve_all" or col.sprint == args.sprint):
					col.approved = true
		"edit":
			# Düzenlenen PM sütunu SPRINT görünümünde sonraki sprint olarak açılır (görünümü sekme değiştirir).
			var col: Dictionary = m.quarter.columns.filter(func(c: Dictionary) -> bool: return c.sprint == args.sprint)[0]
			m.next.sprint = col.sprint
			m.next.flags = col.flags
			m.next.cards = col.cards
		"pick_goal":
			m.quarter.goal.area_id = args.area_id
			m.quarter.goal.area_name = _short(args.area_id)
			m.quarter.goal.text = _area_of(m, args.area_id).goal_text


## Kartı taşır: "center" bu sprint, "next" sonraki, "" adaylara geri. Adaydaki kopyası soluklaşıp
## sprint damgası alır ya da yeniden açılır; talep kartıysa müşterinin damgası da.
func _place(m: Dictionary, id: String, where: String) -> void:
	var lists: Array = [m.center.cards, m.next.cards]
	for a in m.areas:
		lists.append(a.candidates)
	var card: Dictionary
	for list in lists:
		for c in list:
			if c.id == id:
				card = c.duplicate(true)
	m.center.cards = m.center.cards.filter(func(c: Dictionary) -> bool: return c.id != id)
	m.next.cards = m.next.cards.filter(func(c: Dictionary) -> bool: return c.id != id)
	var sprint := -1
	if where != "":
		var target: Dictionary = m.center if where == "center" else m.next
		sprint = target.sprint
		card.state = SprintCard.State.SPRINT_PLAN if where == "center" else SprintCard.State.PLANLANAN
		card.buttons = ProductModel.BUTTONS[card.state]
		card.tag_sprint = -1
		target.cards.append(card)
	for list in lists.slice(2):
		for c in list:
			if c.id == id:
				c.state = SprintCard.State.ADAY if sprint < 0 else SprintCard.State.ADAY_ALINMIS
				c.buttons = ProductModel.BUTTONS.get(c.state, [])
				c.tag_sprint = sprint
	if m.customers != null:
		for customer in m.customers:
			if customer.card_id == id:
				customer.tag_sprint = sprint
				customer.buttons = ProductModel.BUTTONS[SprintCard.State.ADAY] if sprint < 0 else []
	_resum(m.center)


func _clear_sprint(m: Dictionary) -> void:
	for card_id in C1_SPRINT:
		_place(m, card_id, "")
	m.center.forecast = []


## Kapasite kartlardan toplanır; planlamada "+" ve başlat izinleri de buradan: "+" boş puan kaldıkça açık.
func _resum(c: Dictionary) -> void:
	c.capacity = _capacity(c.cards, c.capacity.total, c.capacity.done, c.sprint + 1)
	if c.mode != "plan":
		return
	var cap: Dictionary = c.capacity
	c.spare = cap.used < cap.total
	c.can_add = c.spare
	c.can_start = cap.total > 0 and not c.cards.is_empty()
	c.start_reason = "" if c.can_start else tr("PRODUCT_TEAM_NOBODY_JOBS" if cap.total == 0 else "PRODUCT_START_NEED_CARD")


## Kapasiteyi aşan kart sırayla dolar: bir kısmını alan "devreder · x/y" der, hiç alamayan sonraki
## sprinte kayar (`next`); devreden kart kalan puanıyla sayılır.
func _capacity(cards: Array, total: float, done: float, next: int) -> Dictionary:
	var used := 0.0
	var segments: Array = []
	for card in cards:
		var pts: float = card.remaining if card.remaining >= 0 else card.effort
		var shut: bool = card.get("gate_closed", false)
		card.spills = not shut and used < total and used + pts > total
		card.no_start = next if shut or used >= total else -1
		card.planned_done = card.effort - pts if shut else card.effort - pts + clampf(total - used, 0.0, pts)
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
		"areas": _notly_areas(false),
		"customers": null,
		"center": _center("plan", _sprint_cards(), {
			"forecast": [_level("onboarding", 1, 2), _clear("trust"), {"k": "bugs_closed", "n": 5}],
			"lead_tip": _lead(_p("Kesinti ve kayıt bu sprintte bitmeli.", "The outage fix and sign-up must land this sprint.")),
		}),
		"next": _notly_next(false),
	}


func _c2() -> Dictionary:
	var m := _c1()
	m.ui = _ui_state("", "")
	m.center = _center("active", _active_cards(), {
		"capacity": {"total": 60, "done": 10},
		"status": {"done": 1, "running": 1, "queued": 0, "decisions": 1},
		"next_version": {"label": _version("1.5"), "weeks": 1},
	})
	return m


func _c3() -> Dictionary:
	var m := _c1()
	m.header.live_version = "1.5"
	m.ui = _ui_state("", "")
	m.areas = _notly_areas(true)
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
	var aday := SprintCard.State.ADAY
	var alinmis := SprintCard.State.ADAY_ALINMIS
	var plan := SprintCard.State.SPRINT_PLAN
	return {
		"header": _header("Fatura", "B2B", _p("Faturalama SaaS'ı", "Invoicing SaaS")),
		"versions": _versions(),
		"quarter": {"state": "locked_no_pm", "goal": null, "columns": []},
		"ui": _ui_state("trust", ""),
		"areas": [
			_area("core", 2, _p("Fatura kesme çalışıyor, tahsilat takibi zayıf", "Invoicing works, collections tracking is weak"),
				{}),
			_area("onboarding", 2, _p("Kurulum bir günde bitiyor", "Setup is done in a day"), {}),
			_area("integrations", 1, _p("Muhasebe programına aktarım yok", "No export to accounting software"), {
				"candidates": [_deck("excel", alinmis, {"tag_sprint": 7}), _deck("efatura", alinmis, {"tag_sprint": 8})],
			}),
			_area("trust", 1, _p("Geçen hafta 2 saat kesinti oldu · SSO yok", "Two hours of downtime last week · no SSO"), {
				"alert": true,
				"capabilities": [_cap(_p("Kullanıcı rolleri", "User roles"), 2),
					_cap(_p("Yedekleme", "Backups"), 0), _cap("SSO", 0)],
				"candidates": [_deck("sso", alinmis, {"tag_sprint": 7}),
					_deck("kesinti", alinmis, {"tag_sprint": 7, "effect": _fix_b2b()}),
					_deck("oto_yedek", aday, {"effect": [_level("trust", 2, 3)]})],
			}),
		],
		"customers": [
			_customer("Nordica", "SSO", "sso", 8, 12000, "trust"),
			_customer("Palmiye", _p("Tablo dışa aktarma", "Spreadsheet export"), "excel", 10, 4000, "integrations"),
		],
		"center": _center("plan", [_deck("sso", plan), _deck("kesinti", plan, {"effect": _fix_b2b()}), _deck("excel", plan)], {
			"forecast": [_level("trust", 1, 2), {"k": "request_on_time", "customer": "Nordica"},
				{"k": "request_on_time", "customer": "Palmiye"}, _clear("trust"), {"k": "bugs_closed", "n": 6}],
			"lead_tip": _lead(_p("SSO gecikirse Nordica yenilemez.", "If SSO slips, Nordica won't renew.")),
		}),
		"next": {"sprint": 8, "cards": [_deck("efatura", SprintCard.State.PLANLANAN)], "flags": [{"k": "deadline",
			"text": tr("PRODUCT_FLAG_DEADLINE").format({"customer": "Nordica", "request": "SSO"})}]},
	}


func _notly_areas(released: bool) -> Array:
	var aday := SprintCard.State.ADAY
	var alinmis := SprintCard.State.ADAY_ALINMIS
	return [
		_area("core", 3, _p("Kullanıcılar arama ve editörü seviyor", "Users love the search and the editor"), {
			"capabilities": [_cap(_p("Arama", "Search"), 2),
				_cap(_p("Editör", "Editor"), 3)],
			"candidates": [_deck("filtreli", alinmis, {"tag_sprint": 7}), _deck("etiketler", aday)],
		}),
		_area("onboarding", 1, _p("10 yeni kullanıcıdan 6'sı ilk hafta kalıyor", "6 of 10 new users stay past the first week")
			if released else _p("10 yeni kullanıcıdan 6'sı ilk hafta bırakıyor", "6 of 10 new users quit in the first week"), {
			"level_to": 2 if released else -1,
			"word_to": "enough" if released else "",
			"rival_topic": _p("mobil", "mobile"),
			"capabilities": [_cap(_p("Kayıt", "Sign-up"), 1),
				_cap(_p("İlk tur", "First run"), 0), _cap(_p("Mobil", "Mobile"), 0)],
			"candidates": [_deck("kisa_kayit", alinmis, {"tag_sprint": 7}), _deck("ilk_tur", alinmis, {"tag_sprint": 8}),
				_deck("mobil_giris", aday), _deck("gorusme", aday)],
		}),
		_area("growth", 2, _p("Paylaşım yok, davet gelmiyor", "No sharing, no invites coming in"), {
			"capabilities": [_cap(_p("Paylaşım", "Sharing"), 0)],
			"candidates": [_deck("baglanti", aday)],
		}),
		_area("trust", 1, _p("Geçen hafta 2 saat kesinti oldu", "Two hours of downtime last week"), {
			"alert": not released,
			"capabilities": [_cap(_p("Yedekleme", "Backups"), 0),
				_cap(_p("İzleme", "Monitoring"), 1)],
			"candidates": [_deck("kesinti", alinmis, {"tag_sprint": 7}), _deck("oto_yedek", alinmis, {"tag_sprint": 8})],
		}),
		_area("revenue", 0, _p("Ücretli plan henüz yok", "No paid plan yet"), {
			"capabilities": [_cap(_p("Ücretli plan", "Paid plan"), 0)],
			"candidates": [_deck("ucretli", aday)],
		}),
	]


func _notly_next(carried: bool) -> Dictionary:
	var cards: Array = [_deck("ilk_tur", SprintCard.State.PLANLANAN), _deck("oto_yedek", SprintCard.State.PLANLANAN)]
	if carried:
		cards.push_front(_deck("filtreli", SprintCard.State.DEVREDEN, {"remaining": 10}))
	return {"sprint": 8, "flags": [_rival_flag()], "cards": cards}


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
		col.capacity = _capacity(cards, 60, 0, sprint + 1)
	return col


## c2'nin kartları: biten, test aşamasındaki ve karar bekleyen.
func _active_cards() -> Array:
	return [
		_deck("kesinti", SprintCard.State.BITTI, {"phases": ["done", "done", "done"], "assignees": [_person("Kaan")]}),
		_deck("kisa_kayit", SprintCard.State.SPRINT_AKTIF, {"phases": ["done", "done", "active"],
			"phase_pts": {"done": 2.0, "total": 3.0}, "assignees": [_person("Ece"), _person("Kaan")]}),
		_deck("filtreli", SprintCard.State.SPRINT_AKTIF, {"phases": WAITING, "decision": {"event_id": "fixture.thesis_open",
			"item": "", "sender": INBOX.named_employee("Deniz", ""), "subject": EvPresenter.text_block(EvCatalog.card("product.sprint_dev_shorter_path")).title,
			"weeks_left": 1, "last": true}}),
	]


func _sprint_cards() -> Array:
	return C1_SPRINT.map(func(card_id: String) -> Dictionary: return _deck(card_id, SprintCard.State.SPRINT_PLAN))


# --- Parçalar ---------------------------------------------------------------

## id → [tür, alan, roller, efor, ad, etki, efor dökümü [ad, hafta]].
func _deck_table() -> Dictionary:
	var founder := _p("Kurucu", "Founder")
	return {
		"kesinti": ["fix", "trust", ["dev"], 10, _p("Kesinti düzeltmesi", "Outage fix"), [_bugs(5, -1, 300), _clear("trust")],
			[["Kaan", 1]]],
		"esitleme": ["fix", "core", ["dev"], 10, _p("Eşitleme düzeltmesi", "Sync fix"), [_bugs(5, -1, 300)], [["Kaan", 1]]],
		"fatura_fix": ["fix", "core", ["dev"], 10, _p("Fatura düzeltmesi", "Invoicing fix"),
			[_bugs(6, 3, 140, "Nordica", 100)], [["Kaan", 1]]],
		"kisa_kayit": ["feature", "onboarding", ["design", "dev"], 15, _p("Kısa kayıt", "Short sign-up"),
			[_level("onboarding", 1, 2)], [["Ece", 1], ["Kaan", 1]]],
		"ilk_tur": ["feature", "onboarding", ["design", "dev"], 10, _p("İlk tur rehberi", "First-run guide"),
			[_level("onboarding", 1, 2)], [["Ece", 1], ["Kaan", 1]]],
		"mobil_giris": ["feature", "onboarding", ["dev", "test"], 20, _p("Mobil giriş", "Mobile login"),
			[_level("onboarding", 1, 2)], [["Kaan", 2]]],
		"gorusme": ["research", "onboarding", ["product"], 5, _p("5 kullanıcıyla görüş", "Talk to 5 users"),
			[{"k": "research", "area": _short("onboarding")}], [[founder, 1]]],
		"filtreli": ["polish", "core", ["dev"], 25, _p("Filtreli arama", "Filtered search"),
			[{"k": "holds", "area": _short("core"), "word": "strong"}, _cap_fx(_p("Arama", "Search"), 2, 3)],
			[["Deniz", 2]]],
		"oto_yedek": ["feature", "trust", ["dev"], 15, _p("Otomatik yedekleme", "Automatic backups"),
			[_level("trust", 1, 2)], [["Deniz", 1], ["Kaan", 1]]],
		"etiketler": ["feature", "core", ["design", "dev"], 20, _p("Etiketler", "Tags"),
			[_cap_fx(_p("Etiketler", "Tags"), 0, 1)], [["Ece", 1], ["Deniz", 1]]],
		"baglanti": ["feature", "growth", ["dev"], 20, _p("Bağlantıyla paylaşım", "Share by link"),
			[_level("growth", 2, 3)], [["Kaan", 2]]],
		"ucretli": ["feature", "revenue", ["design", "dev"], 30, _p("Ücretli plan", "Paid plan"),
			[_level("revenue", 0, 1)], [["Ece", 1], ["Deniz", 2]]],
		"akilli_arama": ["feature", "core", ["dev"], 40, _p("Akıllı arama", "Smart search"),
			[_cap_fx(_p("Arama", "Search"), 2, 3)], []],
		"sso": ["feature", "trust", ["dev", "test"], 25, "SSO (Nordica)",
			[_level("trust", 1, 2), {"k": "request", "customer": "Nordica", "value": 12000}], [["Kaan", 2]]],
		"excel": ["feature", "integrations", ["dev"], 15, _p("Tablo dışa aktarma (Palmiye)", "Spreadsheet export (Palmiye)"),
			[_level("integrations", 1, 2), {"k": "request", "customer": "Palmiye", "value": 4000}], [["Deniz", 1]]],
		"efatura": ["feature", "integrations", ["dev", "test"], 25, _p("e-Fatura entegrasyonu", "e-Invoice integration"),
			[_level("integrations", 1, 2)], [["Deniz", 2]]],
	}


func _deck(id: String, state: int, extra := {}) -> Dictionary:
	var d: Array = _deck_table()[id]
	var card := {"id": id, "name": d[4], "kind": d[0], "roles": d[2], "effort": d[3],
		"state": state, "effect": d[5], "tag_sprint": -1, "phases": [], "phase_pts": null, "assignees": [],
		"queued": false, "decision": null,
		"effort_split": d[6].map(func(s: Array) -> Dictionary: return {"name": s[0], "weeks": s[1]}),
		"locked_node": "", "locked_rnd": "", "remaining": -1, "spills": false, "no_start": -1, "planned_done": 0.0,
		"addable": false, "ready": -1.0, "buttons": ProductModel.BUTTONS.get(state, []),
		"priority": d[5].any(func(part: Dictionary) -> bool:
			return part.k == "bugs" and part.n >= int(SprintCatalog.cfg("fix_effort.priority")))}
	card.merge(extra, true)
	return card


## Sürüm notundaki düzeltme satırı: adı kapanıştaki "önce → sonra" sayıyı da taşır (ProductModel._shipped).
func _shipped_fix(id: String, from: int, to: int) -> Dictionary:
	var card: Dictionary = _deck(id, SprintCard.State.BITTI)
	card.name += SprintUiShared.SEP + tr(Fmt.count_key("PRODUCT_FX_BUGS_FIXED", to)).format({"from": from, "to": to})
	return card


func _area(id: String, level: int, sentence: String, extra: Dictionary) -> Dictionary:
	var area := {"id": id, "name": _p(AREAS[id][0], AREAS[id][1]), "level": level,
		"level_to": -1, "word": WORDS[level], "word_to": "", "sentence": sentence, "goal_text": ProductModel.goal_text(id),
		"bug_rows": [], "alert": false, "rival_topic": "",
		"capabilities": [], "candidates": [], "empty": false}
	area.merge(extra, true)
	return area


func _area_of(m: Dictionary, id: String) -> Dictionary:
	return m.areas.filter(func(a: Dictionary) -> bool: return a.id == id)[0]


## Alanın hatalı hatları [[hat adı, hata parçası, değişim]], en çok hatalısı önde: satırlar `ProductModel.bug_row_of`'tan,
## cümlesine model gibi toplam eklenir ve alan açık açılır.
func _bug_lines(m: Dictionary, id: String, lines: Array) -> void:
	var area: Dictionary = _area_of(m, id)
	var total := 0
	for line in lines:
		area.bug_rows.append(ProductModel.bug_row_of(line[0], line[1], line[2]))
		total += int(line[1].n)
	area.sentence += SprintUiShared.SEP + SprintUiShared.count("PRODUCT_BUG_COUNT", total)
	m.ui.open_area = id


func _cap(cap_name: String, tier: int) -> Dictionary:
	return {"name": cap_name, "tier": tier}


func _center(mode: String, cards: Array, extra: Dictionary) -> Dictionary:
	var c := {"mode": mode, "sprint": 7, "weeks": 2, "week": 1, "capacity": {"total": 60, "done": 0},
		"team": _team(), "staffed": true, "warning_text": tr("PRODUCT_ROLE_MISSING").format({"role": _p("Test", "QA")}),
		"idle_text": "", "cards": cards, "forecast": [], "status": {"done": 0, "running": 0, "queued": 0, "decisions": 0},
		"empty": false, "pm_started": "", "plan_hold": false, "delegate": null,
		"next_version": null, "mvp_line": null, "can_add": false, "spare": false, "ceiling_pct": 125, "can_start": false,
		"start_reason": "", "rnd_node": null, "lead_tip": null, "release": null}
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


func _customer(customer: String, request: String, card_id: String, due: int, value: int, area: String) -> Dictionary:
	return {"name": customer, "request": request, "tag_sprint": 7, "due_sprint": due, "value": value,
		"area_name": _short(area), "buttons": [], "card_id": card_id}


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
	return {"view": "sprint", "open_area": open_area, "history_open": false, "hover_card": hover_card}


func _rival_flag() -> Dictionary:
	return {"k": "rival", "text": tr("PRODUCT_RIVAL_TOPIC").format({"topic": _p("mobil", "mobile")})}


func _level(area: String, from: int, to: int) -> Dictionary:
	return {"k": "level", "area": _short(area), "from": from, "to": to, "from_word": WORDS[from], "to_word": WORDS[to]}


func _cap_fx(cap_name: String, from: int, to: int) -> Dictionary:
	return {"k": "cap", "name": cap_name, "from": from, "to": to, "from_word": WORDS[from], "to_word": WORDS[to]}


func _clear(area: String) -> Dictionary:
	return {"k": "alert_clear", "area": _short(area)}


## Düzeltme kartının hata satırı; B2C'de hesap sayısı -1 ve en büyük hesap "".
func _bugs(n: int, accounts: int, users: int, top := "", top_users := 0) -> Dictionary:
	return {"k": "bugs", "n": n, "accounts": accounts, "users": users, "top": top, "top_users": top_users}


## c5'in B2B düzeltme kartı: altı hata, üç hesap, 140 kullanıcı, en büyüğü Nordica.
func _fix_b2b() -> Array:
	return [_bugs(6, 3, 140, "Nordica", 100), _clear("trust")]


func _short(area: String) -> String:
	return _p(AREAS[area][2], AREAS[area][3])


func _version(n: String) -> String:
	return tr("PROD_VERSION_SHORT").format({"version": n})


func _p(tr_text: String, en_text: String) -> String:
	return Localization.pick(tr_text, en_text)
