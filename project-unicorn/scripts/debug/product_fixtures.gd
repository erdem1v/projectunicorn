extends RefCounted

# Ürün sprint ekranının debug kaynağı (sekmenin set_source'u): beş mockup (c1..c5), kart
# galerisi (cards) ve uç durumlar. Simülasyon yok: act() geçiş tablosunu sürer ve kartları
# listeler arasında taşır. model() her çağrıda baştan kurulur, taşımalar günlükten yeniden
# oynanır; metin o anki dilde çözülür (özel adlar düz).

## Geçiş tablosu: eylem → [geçerli olduğu orta sütun kipi, varılan aşama].
const STAGES := {"start": ["plan", "active"], "advance": ["active", "release"], "plan_next": ["release", "replan"]}
## Uç durumun ve aşamanın üstüne kurulduğu mockup; listede olmayan c1'dir.
const BASES := {"active": "c2", "decision": "c2", "mvp": "c2", "release": "c3", "no_release": "c3",
	"beta_open": "c3", "b2b_no_requests": "c5"}
## id → [renk yuvası, ad TR, ad EN, kısa ad TR, kısa ad EN]; kısa ad etki satırında ve hedefte.
const AREAS := {
	"core": [0, "Çekirdek", "Core", "Çekirdek", "Core"],
	"onboarding": [1, "Onboarding & Erişim", "Onboarding & Access", "Onboarding", "Onboarding"],
	"growth": [2, "Büyüme", "Growth", "Büyüme", "Growth"],
	"integrations": [2, "Entegrasyonlar", "Integrations", "Entegrasyonlar", "Integrations"],
	"trust": [3, "Güven & Ölçek", "Trust & Scale", "Güven", "Trust"],
	"revenue": [4, "Gelir", "Revenue", "Gelir", "Revenue"],
}
## Fikstür seviyesinin (0..3) kelimesi; fikstür beklentiyi her alanda aynı tutar.
const WORDS := ["none", "weak", "enough", "strong"]
## c1'in bu sprinti; çeyreğin ilk sütunu ve sprinti boşaltan uç durumlar da bunu okur.
const C1_SPRINT := ["kesinti", "kisa_kayit", "filtreli"]

var _stage: String
var _log: Array = []


func _init(fixture_id: String) -> void:
	_stage = fixture_id


func model() -> Dictionary:
	var m: Dictionary = _build(_stage)
	for entry in _log:
		_apply(m, entry[0], entry[1])
	return m


func act(kind: String, args: Dictionary) -> void:
	if kind == "decide":
		var card: Dictionary = model().center.cards.filter(func(c: Dictionary) -> bool: return c.id == args.card_id)[0]
		# Fikstür olay kartı yalnız bu çağrı boyunca açılan kapsamdadır.
		var shipped: Array = EvTuning.SHIPPED_SCOPES.duplicate()
		EvTuning.SHIPPED_SCOPES.append("fixture")
		EventGate.force_fire(card.decision.event_id)
		EvTuning.SHIPPED_SCOPES.assign(shipped)
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
		"c4":
			m.ui.view = "quarter"
			m.quarter = _quarter()
		"replan":
			_place(m, "filtreli", "next")
			m.next = _notly_next(true)
			m.header.live_version = "1.5"
		"cards":
			m.center.cards = [
				_deck("gorusme", SprintCard.State.ADAY, {"urgent": true}),
				_deck("ilk_tur", SprintCard.State.ADAY_ALINMIS, {"tag_sprint": 8}),
				_deck("mobil_giris", SprintCard.State.SPRINT_PLAN, {"spills": true}),
				_deck("oto_yedek", SprintCard.State.DEVREDEN, {"remaining": 2}),
				_deck("etiketler", SprintCard.State.PLANLANAN),
				_deck("akilli_arama", SprintCard.State.KILITLI, {"locked_node": tr("PRODUCT_LOCKED_NODE").format({"node": _p("Gelişmiş arama", "Advanced search")})}),
				_deck("baglanti", SprintCard.State.BETA_BEKLIYOR),
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
			_clear_sprint(m)
			m.center.team = []
			m.center.warning_text = tr("PRODUCT_TEAM_NOBODY")
			m.center.lead_tip = null
		"over_100":
			_place(m, "mobil_giris", "center")
		"over_125":
			_place(m, "mobil_giris", "center")
			_place(m, "ilk_tur", "center")
		"empty_start":
			_clear_sprint(m)
		"no_release":
			# Hiç kart bitmedi: çıkan yok, hız sıfır, basın satırı yok.
			m.center.release.version = ""
			m.center.release.shipped = []
			m.center.release.velocity.done = 0
			m.center.release.press = ""
			m.center.release.result = null
			m.header.live_version = "1.4"
		"beta_open":
			m.center.release.beta = true
			m.center.beta.open = true
			m.header.live_version = "1.4"
		"b2b_no_requests":
			m.customers = []
			m.next.flags = []
		"locked_k3":
			m.ui.open_area = "core"
			_area_of(m, "core").candidates.append(_deck("akilli_arama", SprintCard.State.KILITLI,
				{"locked_node": tr("PRODUCT_LOCKED_NODE").format({"node": _p("Gelişmiş arama", "Advanced search")})}))
		"history_empty":
			m.versions = []
			m.ui.history_open = true
			m.header.live_version = ""
		"mvp":
			m.versions = []
			m.header.live_version = ""
			m.center.next_version = {"label": _version("1.0"), "weeks": 1, "beta_extra": false, "cards_left": 3}
		"quarter_no_pm":
			m.quarter.state = "locked_no_pm"
		"voices_open":
			m.ui.voices_open = true
	return m


func _apply(m: Dictionary, kind: String, args: Dictionary) -> void:
	match kind:
		"add", "pull": _place(m, args.card_id, "center")
		"send_next": _place(m, args.card_id, "next")
		"remove": _place(m, args.card_id, "")
		"beta":
			var beta: Dictionary = m.center.beta
			beta.open = not beta.open
			if m.center.next_version != null:
				m.center.next_version.beta_extra = beta.open
		"apply_lead":
			m.center.lead_tip = null   # fikstür yuvaları doldurmaz; öneri kullanıldı diye düşer
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
			m.quarter.goal.slot = AREAS[args.area_id][0]
			m.quarter.goal.area_name = _short(args.area_id)
		"voices_seen":
			var heard: Dictionary = _area_of(m, args.area)
			heard.voices["new"] = 0
			for v in heard.voices_list:
				v["new"] = false


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


## Kapasite kartlardan toplanır; planlamada "+" ve başlat izinleri de buradan.
func _resum(c: Dictionary) -> void:
	c.capacity = _capacity(c.cards, c.capacity.total, c.capacity.done)
	if c.mode != "plan":
		return
	var cap: Dictionary = c.capacity
	c.can_add = cap.total > 0 and cap.used * 4 <= cap.total * 5   # yük %125'e kadar "+" açık
	c.can_start = cap.total > 0 and not c.cards.is_empty()
	c.start_block = c.cards.is_empty()


## Kapasiteyi aşan kart "devreder" der; devreden kart kalan puanıyla sayılır.
func _capacity(cards: Array, total: int, done: int) -> Dictionary:
	var used := 0
	var segments: Array = []
	for card in cards:
		var pts: int = card.remaining if card.remaining >= 0 else card.effort
		used += pts
		card.spills = used > total
		segments.append({"slot": card.slot, "pts": pts})
	var state: String = "blocked" if total == 0 else ("over" if used > total else "ok")
	return {"used": used, "total": total, "done": done, "state": state, "segments": segments}


# --- Mockup'lar -------------------------------------------------------------

func _c1() -> Dictionary:
	return {
		"header": _header("Notly", "B2C", _p("NOT & BİLGİ ARACI", "NOTES & KNOWLEDGE TOOL")),
		"versions": _versions(),
		"quarter": {"state": "locked_no_pm", "goal": null, "columns": []},
		"ui": _ui_state("onboarding", "kisa_kayit"),
		"areas": _notly_areas(false),
		"customers": null,
		"center": _center("plan", _sprint_cards(), {
			"forecast": [_level("onboarding", 1, 2), _clear("trust"), {"k": "tickets", "n": 3}],
			"lead_tip": _lead(_p("Kesinti ve kayıt bu sprintte bitmeli.", "The outage fix and sign-up must land this sprint.")),
		}),
		"next": _notly_next(false),
	}


func _c2() -> Dictionary:
	var m := _c1()
	m.ui = _ui_state("", "")
	m.center = _center("active", _active_cards(), {
		"capacity": {"total": 12, "done": 2},
		"status": {"done": 1, "running": 2, "decisions": 1},
		"next_version": {"label": _version("1.5"), "weeks": 1, "beta_extra": false, "cards_left": -1},
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
		"beta": false,
		"shipped": [_deck("kisa_kayit", SprintCard.State.BITTI), _deck("kesinti", SprintCard.State.BITTI)],
		"carried": [{"name": carried.name, "kind": carried.kind, "slot": carried.slot, "done": 3, "total": 5, "to_sprint": 8}],
		"velocity": {"done": 8, "total": 12},
		"result": {"kind": "actual", "text": _p("İlk hafta: 10 yeni kullanıcıdan 6'sı kaldı (önce 4).",
			"First week: 6 of 10 new users stayed (4 before).")},
		"press": _p("TeknoGündem · Notly kayıt akışını kısalttı.", "TeknoGündem · Notly shortened its sign-up flow."),
		"lead": _lead(_p("Arama bir sprint daha ister.", "Search needs one more sprint.")),
	}})
	m.next = _notly_next(true)
	return m


func _c5() -> Dictionary:
	var aday := SprintCard.State.ADAY
	var alinmis := SprintCard.State.ADAY_ALINMIS
	var plan := SprintCard.State.SPRINT_PLAN
	return {
		"header": _header("Fatura", "B2B", _p("FATURALAMA SAAS'I", "INVOICING SAAS")),
		"versions": _versions(),
		"quarter": {"state": "locked_no_pm", "goal": null, "columns": []},
		"ui": _ui_state("trust", ""),
		"areas": [
			_area("core", 2, _p("Fatura kesme çalışıyor, tahsilat takibi zayıf", "Invoicing works, collections tracking is weak"),
				_heard([_p("Tahsilatı ayrı bir tabloda izliyoruz", "We track collections in a separate sheet")], 0)),
			_area("onboarding", 2, _p("Kurulum bir günde bitiyor", "Setup is done in a day"), {}),
			_area("integrations", 1, _p("Muhasebe programına aktarım yok", "No export to accounting software"),
				_heard([_p("Muhasebeci her ay Excel istiyor", "Our accountant asks for Excel every month"),
					_p("e-Fatura gönderemiyoruz", "We can't send e-invoices")], 0).merged({
				"tone": "alert",
				"candidates": [_deck("excel", alinmis, {"tag_sprint": 7}), _deck("efatura", alinmis, {"tag_sprint": 8})],
			})),
			_area("trust", 1, _p("Geçen hafta 2 saat kesinti oldu · SSO yok", "Two hours of downtime last week · no SSO"), {
				"alert": true,
				"capabilities": [_cap(_p("Kullanıcı rolleri", "User roles"), 2, ["Kasa", "Mizan", "Hesap"]),
					_cap(_p("Yedekleme", "Backups"), 0, ["Kasa", "Mizan"]), _cap("SSO", 0, ["Kasa"])],
				"candidates": [_deck("sso", alinmis, {"tag_sprint": 7}), _deck("kesinti", alinmis, {"tag_sprint": 7}),
					_deck("oto_yedek", aday, {"effect": [_level("trust", 2, 3)]})],
			}),
		],
		"customers": [
			_customer("Nordica", "SSO", "sso", 8, 12000, "trust"),
			_customer("Palmiye", _p("Excel dışa aktarma", "Excel export"), "excel", 10, 4000, "integrations"),
			{"name": "Beykoz", "request": "", "tickets": 2, "tag_sprint": -1, "due_sprint": -1, "value": 0,
				"area_slot": -1, "area_name": "", "buttons": [], "card_id": ""},
		],
		"center": _center("plan", [_deck("sso", plan), _deck("kesinti", plan), _deck("excel", plan)], {
			"forecast": [_level("trust", 1, 2), {"k": "request_on_time", "customer": "Nordica"},
				{"k": "request_on_time", "customer": "Palmiye"}, _clear("trust")],
			"lead_tip": _lead(_p("SSO gecikirse Nordica yenilemez.", "If SSO slips, Nordica won't renew.")),
		}),
		"next": {"sprint": 8, "cards": [_deck("efatura", SprintCard.State.PLANLANAN)], "flags": [{"k": "deadline",
			"text": tr("PRODUCT_FLAG_DEADLINE").format({"customer": "Nordica", "request": "SSO"})}]},
	}


func _notly_areas(released: bool) -> Array:
	var aday := SprintCard.State.ADAY
	var alinmis := SprintCard.State.ADAY_ALINMIS
	var onboarding: Dictionary
	if released:
		onboarding = _heard([_p("Doğrulama e-postası geç geliyor", "The verification email arrives late")], 0)
		onboarding.merge({"level_to": 2, "word_to": "enough"})
	else:
		onboarding = _heard([_p("Kayıtta şifre kuralı anlaşılmıyor", "The password rule at sign-up is unclear"),
			_p("Doğrulama e-postası geç geliyor", "The verification email arrives late"),
			_p("Kayıt formu çok uzun", "The sign-up form is too long"),
			_p("Telefondan giriş yapamıyorum", "I can't log in from my phone")], 1)
		onboarding.merge({"tone": "alert"})
	return [
		_area("core", 3, _p("Kullanıcılar arama ve editörü seviyor", "Users love the search and the editor"),
			_heard([_p("Etikete göre arama olsa iyi olur", "Searching by tag would help")], 0).merged({
			"capabilities": [_cap(_p("Arama", "Search"), 2, ["Memora", "Pinbox", "Defter"]),
				_cap(_p("Editör", "Editor"), 3, ["Memora", "Defter"])],
			"candidates": [_deck("filtreli", alinmis, {"tag_sprint": 7}), _deck("etiketler", aday)],
		})),
		_area("onboarding", 1, _p("10 yeni kullanıcıdan 6'sı ilk hafta kalıyor", "6 of 10 new users stay past the first week")
			if released else _p("10 yeni kullanıcıdan 6'sı ilk hafta bırakıyor", "6 of 10 new users quit in the first week"),
			onboarding.merged({
			"rival_topic": _p("mobil", "mobile"),
			"capabilities": [_cap(_p("Kayıt", "Sign-up"), 1, ["Memora", "Pinbox"]),
				_cap(_p("İlk tur", "First run"), 0, ["Memora"]), _cap(_p("Mobil", "Mobile"), 0, ["Pinbox"])],
			"candidates": [_deck("kisa_kayit", alinmis, {"tag_sprint": 7}), _deck("ilk_tur", alinmis, {"tag_sprint": 8}),
				_deck("mobil_giris", aday), _deck("gorusme", aday)],
		})),
		_area("growth", 2, _p("Paylaşım yok, davet gelmiyor", "No sharing, no invites coming in"),
			_heard([_p("Notumu paylaşamıyorum", "I can't share a note")], 0).merged({
			"capabilities": [_cap(_p("Paylaşım", "Sharing"), 0, ["Memora", "Pinbox"])],
			"candidates": [_deck("baglanti", aday)],
		})),
		_area("trust", 1, _p("Geçen hafta 2 saat kesinti oldu", "Two hours of downtime last week"), {
			"tone": "alert", "alert": not released,
			"capabilities": [_cap(_p("Yedekleme", "Backups"), 0, ["Memora", "Pinbox"]),
				_cap(_p("İzleme", "Monitoring"), 1, ["Memora", "Pinbox", "Defter"])],
			"candidates": [_deck("kesinti", alinmis, {"tag_sprint": 7}), _deck("oto_yedek", alinmis, {"tag_sprint": 8})],
		}),
		_area("revenue", 0, _p("Ücretli plan henüz yok", "No paid plan yet"), {
			"capabilities": [_cap(_p("Ücretli plan", "Paid plan"), 0, ["Memora", "Pinbox", "Defter"])],
			"candidates": [_deck("ucretli", aday)],
		}),
	]


func _notly_next(carried: bool) -> Dictionary:
	var cards: Array = [_deck("ilk_tur", SprintCard.State.PLANLANAN), _deck("oto_yedek", SprintCard.State.PLANLANAN)]
	if carried:
		cards.push_front(_deck("filtreli", SprintCard.State.DEVREDEN, {"remaining": 2}))
	return {"sprint": 8, "flags": [_rival_flag()], "cards": cards}


func _quarter() -> Dictionary:
	var planned := SprintCard.State.PLANLANAN
	return {
		"state": "open",
		"goal": {"slot": AREAS["onboarding"][0], "area_name": _short("onboarding"),
			"text": _p("yeni kullanıcıların yarısı kalsın", "half of new users stay"),
			"now": 4, "target": 5, "total": 10, "progress_text": _p("şu an 10'da 4", "now 4 of 10")},
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
		col.capacity = _capacity(cards, 12, 0)
	return col


## c2'nin kartları: biten, test aşamasındaki ve karar bekleyen.
func _active_cards() -> Array:
	return [
		_deck("kesinti", SprintCard.State.BITTI, {"phases": ["done", "done", "done"], "assignees": [_person("KA")]}),
		_deck("kisa_kayit", SprintCard.State.SPRINT_AKTIF, {"phases": ["done", "done", "active"],
			"assignees": [_person("EC"), _person("KA")]}),
		_deck("filtreli", SprintCard.State.SPRINT_AKTIF, {"phases": ["done", "active", "waiting"],
			"assignees": [_person("DE")], "decision": {"event_id": "fixture.thesis_open", "initials": "DE",
			"speaker": "Deniz", "text": _p("Filtreli aramayı iki şekilde yapabiliriz.", "We can build filtered search two ways.")}}),
	]


func _sprint_cards() -> Array:
	return C1_SPRINT.map(func(card_id: String) -> Dictionary: return _deck(card_id, SprintCard.State.SPRINT_PLAN))


# --- Parçalar ---------------------------------------------------------------

## id → [tür, alan, roller, efor, ad, etki, efor dökümü [ad, hafta]].
func _deck_table() -> Dictionary:
	var founder := _p("Kurucu", "Founder")
	return {
		"kesinti": ["fix", "trust", ["dev"], 2, _p("Kesinti düzeltmesi", "Outage fix"), [_clear("trust")], [["Kaan", 1]]],
		"kisa_kayit": ["feature", "onboarding", ["design", "dev"], 3, _p("Kısa kayıt", "Short sign-up"),
			[_level("onboarding", 1, 2), {"k": "tickets", "n": 3}], [["Ece", 1], ["Kaan", 1]]],
		"ilk_tur": ["feature", "onboarding", ["design", "dev"], 2, _p("İlk tur rehberi", "First-run guide"),
			[_level("onboarding", 1, 2), {"k": "tickets", "n": 1}], [["Ece", 1], ["Kaan", 1]]],
		"mobil_giris": ["feature", "onboarding", ["dev", "test"], 4, _p("Mobil giriş", "Mobile login"),
			[_level("onboarding", 1, 2), {"k": "rival_gap"}], [["Kaan", 2]]],
		"gorusme": ["research", "onboarding", ["product"], 1, _p("5 kullanıcıyla görüş", "Talk to 5 users"),
			[{"k": "research", "area": _short("onboarding")}], [[founder, 1]]],
		"filtreli": ["polish", "core", ["dev"], 5, _p("Filtreli arama", "Filtered search"),
			[{"k": "holds", "area": _short("core"), "word": "strong"}, _cap_fx(_p("Arama", "Search"), 2, 3)],
			[["Deniz", 2]]],
		"oto_yedek": ["feature", "trust", ["dev"], 3, _p("Otomatik yedekleme", "Automatic backups"),
			[_level("trust", 1, 2)], [["Deniz", 1], ["Kaan", 1]]],
		"etiketler": ["feature", "core", ["design", "dev"], 4, _p("Etiketler", "Tags"),
			[_cap_fx(_p("Etiketler", "Tags"), 0, 1)], [["Ece", 1], ["Deniz", 1]]],
		"baglanti": ["feature", "growth", ["dev"], 4, _p("Bağlantıyla paylaşım", "Share by link"),
			[_level("growth", 2, 3)], [["Kaan", 2]]],
		"ucretli": ["feature", "revenue", ["design", "dev"], 6, _p("Ücretli plan", "Paid plan"),
			[_level("revenue", 0, 1)], [["Ece", 1], ["Deniz", 2]]],
		"akilli_arama": ["feature", "core", ["dev"], 8, _p("Akıllı arama", "Smart search"),
			[_cap_fx(_p("Arama", "Search"), 2, 3)], []],
		"sso": ["feature", "trust", ["dev", "test"], 5, "SSO (Nordica)",
			[_level("trust", 1, 2), {"k": "request", "customer": "Nordica", "value": 12000}], [["Kaan", 2]]],
		"excel": ["feature", "integrations", ["dev"], 3, _p("Excel dışa aktarma (Palmiye)", "Excel export (Palmiye)"),
			[_level("integrations", 1, 2), {"k": "request", "customer": "Palmiye", "value": 4000}], [["Deniz", 1]]],
		"efatura": ["feature", "integrations", ["dev", "test"], 5, _p("e-Fatura entegrasyonu", "e-Invoice integration"),
			[_level("integrations", 1, 2), {"k": "voices", "n": 2}], [["Deniz", 2]]],
	}


func _deck(id: String, state: int, extra := {}) -> Dictionary:
	var d: Array = _deck_table()[id]
	var card := {"id": id, "name": d[4], "kind": d[0], "slot": AREAS[d[1]][0], "roles": d[2], "effort": d[3],
		"state": state, "effect": d[5], "tag_sprint": -1, "phases": [], "assignees": [], "decision": null,
		"effort_split": d[6].map(func(s: Array) -> Dictionary: return {"name": s[0], "weeks": s[1]}),
		"locked_node": "", "remaining": -1, "spills": false, "urgent": false,
		"buttons": ProductModel.BUTTONS.get(state, [])}
	card.merge(extra, true)
	return card


func _area(id: String, level: int, sentence: String, extra: Dictionary) -> Dictionary:
	var area := {"id": id, "name": _p(AREAS[id][1], AREAS[id][2]), "slot": AREAS[id][0], "level": level,
		"level_to": -1, "word": WORDS[level], "word_to": "", "sentence": sentence,
		"tone": "normal", "voices": {"n": 0, "new": 0}, "alert": false, "rival_topic": "",
		"capabilities": [], "candidates": [], "voices_list": [], "empty": false}
	area.merge(extra, true)
	return area


func _area_of(m: Dictionary, id: String) -> Dictionary:
	return m.areas.filter(func(a: Dictionary) -> bool: return a.id == id)[0]


## Ses satırları; ilk `fresh` tanesi bu sprintte gelmiş (YENİ).
func _heard(texts: Array, fresh: int) -> Dictionary:
	var lines: Array = []
	for i in texts.size():
		lines.append({"text": texts[i], "new": i < fresh})
	return {"voices": {"n": texts.size(), "new": fresh}, "voices_list": lines}


func _cap(cap_name: String, tier: int, rivals: Array) -> Dictionary:
	return {"name": cap_name, "tier": tier, "rivals_have": rivals.size(), "rivals_total": 3, "rival_names": rivals}


func _center(mode: String, cards: Array, extra: Dictionary) -> Dictionary:
	var c := {"mode": mode, "sprint": 7, "weeks": 2, "week": 1, "capacity": {"total": 12, "done": 0},
		"team": _team(), "warning_text": tr("PRODUCT_ROLE_MISSING").format({"role": _p("Test", "QA")}),
		"cards": cards, "forecast": [], "status": {"done": 0, "running": 0, "decisions": 0},
		"next_version": null, "can_add": false, "can_start": false, "start_block": false,
		"beta": {"open": false}, "lead_tip": null, "release": null}
	c.merge(extra, true)
	_resum(c)
	return c


func _team() -> Array:
	var engineering := _p("Yazılım", "Engineering")
	return [
		{"initials": _p("KU", "FO"), "name": _p("Kurucu", "Founder"), "role_text": _p("Ürün · Yazılım", "Product · Engineering"),
			"me": true},
		{"initials": "DE", "name": "Deniz", "role_text": engineering, "me": false},
		{"initials": "EC", "name": "Ece", "role_text": _p("Tasarım", "Design"), "me": false},
		{"initials": "KA", "name": "Kaan", "role_text": engineering, "me": false},
	]


func _person(initials: String) -> Dictionary:
	return _team().filter(func(p: Dictionary) -> bool: return p.initials == initials)[0]


func _lead(text: String) -> Dictionary:
	return {"initials": "DE", "name": "Deniz", "text": text}


func _customer(customer: String, request: String, card_id: String, due: int, value: int, area: String) -> Dictionary:
	return {"name": customer, "request": request, "tickets": 0, "tag_sprint": 7, "due_sprint": due, "value": value,
		"area_slot": AREAS[area][0], "area_name": _short(area), "buttons": [], "card_id": card_id}


func _header(product: String, market: String, type_text: String) -> Dictionary:
	return {"name": product, "live_version": "1.4", "market": market, "type_text": type_text}


func _versions() -> Array:
	return [
		{"label": _version("1.2"), "sprint": 3, "shipped_count": 2},
		{"label": _version("1.3"), "sprint": 5, "shipped_count": 3},
		{"label": _version("1.4"), "sprint": 6, "shipped_count": 2},
	]


func _ui_state(open_area: String, hover_card: String) -> Dictionary:
	return {"view": "sprint", "open_area": open_area, "history_open": false, "voices_open": false, "hover_card": hover_card}


func _rival_flag() -> Dictionary:
	return {"k": "rival", "text": tr("PRODUCT_RIVAL_TOPIC").format({"topic": _p("mobil", "mobile")})}


func _level(area: String, from: int, to: int) -> Dictionary:
	return {"k": "level", "area": _short(area), "from": from, "to": to, "from_word": WORDS[from], "to_word": WORDS[to]}


func _cap_fx(cap_name: String, from: int, to: int) -> Dictionary:
	return {"k": "cap", "name": cap_name, "from": from, "to": to, "from_word": WORDS[from], "to_word": WORDS[to]}


func _clear(area: String) -> Dictionary:
	return {"k": "alert_clear", "area": _short(area)}


func _short(area: String) -> String:
	return _p(AREAS[area][3], AREAS[area][4])


func _version(n: String) -> String:
	return tr("PROD_VERSION_SHORT").format({"version": n})


func _p(tr_text: String, en_text: String) -> String:
	return Localization.pick(tr_text, en_text)
