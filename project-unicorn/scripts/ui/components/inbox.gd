extends RefCounted

# Gelen kutusu: Olaylar penceresinin, ofisin bildirim yığınının, üst barın kapı yuvasının ve rayın
# Olaylar rozetinin tek görünüm modeli. Kendi durumu yoktur, her okumada kurulur: etkin karar,
# kuyruktakilerin sayısı, masadaki kâğıtlar, canlı durumdan türeyen hatırlatıcılar (saatleri ve
# okundu işaretleri yoktur), geçmiş kararlar (EventGate.history) ve motor dışı mesajlar
# (GameState.messages). Yazdığı tek şey bir mesajın okundu işaretidir, sahibinin yolundan.
# Her öğe bir göndericiden gelmiş mail gibi okunur: kartın `sender`'ı, Frank konuşuyorsa Frank,
# yoksa kartın bağlı öznesi ya da kategorisi göndericiyi adlandırır.
# Dışarıdan preload ile erişilir: global class cache'e bağımlılık yok (headless tuzağı).

## Olaylar sayfası bu gruptadır; seçim isteği ona gider.
const GROUP := &"inbox"
const MENTOR_ID := "char_mentor_frank"
## A message kind's topic.
const MESSAGE_TOPICS := {"intro": "EVENT_TAG_MENTOR", "summary": "EVENT_TAG_AGENDA",
	"sales_week": "EVENT_TAG_CUSTOMER", "rnd_note": "EVENT_TAG_PRODUCT", "rnd_discovery": "EVENT_TAG_PRODUCT"}
## A category's sender when the card's speaker and slots name none.
const CATEGORY_SENDERS := {"funding": "frank", "founder": "self", "team": "self", "world": "press",
	"rival": "press", "customer": "desk", "product": "desk"}
## The outlet a category's news comes from.
const CATEGORY_OUTLETS := {"world": "WORLD_OUTLET_SEKTOR", "rival": "WORLD_OUTLET_GIRISIM"}
## The paper that offers an account more: it stands for the account's reminder and reads as growth.
const EXPANSION_CARD := "customer.expansion"


## Opens the inbox on `item_id` (Olaylar comes up if it is not the open window; an open one keeps
## its filter and scroll).
static func show(item_id: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree.get_first_node_in_group(GROUP) == null:
		EventBus.tab_changed.emit("events")
	tree.call_group(GROUP, &"select", item_id)


## Everything the inbox lists, in its order: what waits (the decision on screen, the queue as one
## row, the papers, the reminders), then the past (messages and decisions), newest first. An item
## is {id, kind, day (-1 undated), waiting, unread, topic, sender, subject, line} and its kind's own
## fields.
static func items() -> Array:
	var out: Array = []
	if EventGate.active_id() != "":
		out.append(active_item())
	if EventGate.queue_size() > 0:
		out.append({"id": "queue", "kind": "queue", "day": -1, "waiting": true, "unread": true,
			"count": EventGate.queue_size()})
	out.append_array(desk())
	var past: Array = []
	for i in GameState.messages.size():
		past.append(_message_item(GameState.messages[i]).merged({"seq": i}))
	var rows: Array = EventGate.history()
	for i in rows.size():
		var row: Dictionary = rows[i]
		if String(row.resolution) in [EvHistory.RESOLUTION_CHOSEN, EvHistory.RESOLUTION_EXPIRED] \
				and not row.has("forced") and EventGate.is_catalogued(String(row.event_id)) \
				and String(EventGate.catalogue_card(String(row.event_id)).get("class", "")) != "ambient":
			past.append(_history_item(i, row).merged({"seq": i}))
	# Newest week first; within a week the messages, then the decisions, each newest first. The order
	# is total because sort_custom is not stable.
	past.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.day) != int(b.day):
			return int(a.day) > int(b.day)
		if (a.kind == "message") != (b.kind == "message"):
			return a.kind == "message"
		return int(a.seq) > int(b.seq))
	out.append_array(past)
	return out


## The papers and reminders, as the inbox lists them and the office's notice stack previews them:
## the papers most urgent first, then the reminders. The decision on screen is not among them (the
## top bar's gate slot is), nor a reminder about its subject.
static func desk() -> Array:
	var out: Array = []
	var active: String = EventGate.active_id()
	var ctx: Dictionary = EventGate.active_context()
	var busy: Array = ctx.values().map(func(b: Dictionary) -> String: return String(b.get("id", "")))
	var expansion_papers: Array = []
	for p in EventGate.desk_papers():
		var grow: bool = String(p.event_id) == EXPANSION_CARD
		if grow:
			expansion_papers.append(_bound(p.context, EvScope.TYPE_CUSTOMER))
		if String(p.event_id) == active and p.context == ctx:
			continue
		out.append(_paper_item(p).merged({"grow": grow}))
	if GameState.phase_gate_ready and GameState.pending_next_phase > 0:
		out.append(_reminder("gate", "DESK_PAPER_TAG_GATE", frank(),
			TranslationServer.translate("DESK_PAPER_GATE_TITLE"), "finance"))
	var sheets: Array = GameState.active_sheets
	if not sheets.is_empty():
		var sheet: TermSheet = sheets[0]
		var weeks: int = sheet.weeks_left(GameState.day)
		var title: String = TranslationServer.translate("DESK_PAPER_SHEETS_TITLE").format({"n": sheets.size()})
		if sheets.size() == 1:
			# Süresi dolan teklifin sayacak haftası kalmaz; kâğıt fonun cevap beklediğini söyler.
			title = TranslationServer.translate("HUNT_DECISION_DUE") if sheet.is_decision_due(GameState.day) \
				else TranslationServer.translate(Fmt.count_key("DESK_PAPER_SHEET_TITLE", weeks)).format({"weeks": weeks})
		out.append(_reminder("sheet", "DESK_PAPER_TAG_FUNDING", investor(String(sheet.vc_id)), title,
			"finance", "yatirim"))   # LOC-DATA route id
	if HRSearchSystem.has_files_ready():
		var atlas: String = TranslationServer.translate("DESK_PAPER_TAG_ATLAS")
		out.append(_reminder("atlas", "DESK_PAPER_TAG_ATLAS", _desk(atlas, GameState.company_name),
			TranslationServer.translate("DESK_PAPER_ATLAS_TITLE").format({"n": HRSearchSystem.get_files().size()}), "hr"))
	for c in CustomerRegistry.get_by_market("b2b"):
		if busy.has(c.id) or not c.lifecycle_phase in ["risk", "expansion"] \
				or (c.lifecycle_phase == "expansion" and expansion_papers.has(c.id)):
			continue
		var risk: bool = c.lifecycle_phase == "risk"
		var r := _reminder("customer:" + c.id, "EVENT_TAG_CUSTOMER", contact(c),
			TranslationServer.translate("INBOX_SUBJ_RISK" if risk else "INBOX_SUBJ_GROW"), "sales")
		r.merge({"customer": c.id, "risk": risk, "grow": not risk,
			"value": Fmt.money_chip(c.mrr) + TranslationServer.translate("SALES_PER_MONTH"),
			"state": TranslationServer.translate("SALES_CHIP_RISK" if risk else "SALES_CHIP_EXPANSION"),
			"line": TranslationServer.translate("SALES_REASON_PREFIX").format({"reason": risk_reason()}) if risk
				else TranslationServer.translate("SALES_EXPANSION_FICTION"),
			"request": "" if risk and c.cs_escalated else ("customer.retention" if risk else EXPANSION_CARD)}, true)
		out.append(r)
	for e in CharacterRegistry.get_employees():
		if busy.has(e.id) or not HRConstants.is_flight_risk(e.morale):
			continue
		var r := _reminder("employee:" + e.id, "EVENT_TAG_TEAM", employee(e),
			TranslationServer.translate("HR_BADGE_FLIGHT_RISK"), "hr")
		r.merge({"employee": e.id, "risk": true, "morale": e.morale,
			"state": TranslationServer.translate("HR_BADGE_FLIGHT_RISK"),
			"line": HRConstants.role_label(e.role)}, true)
		out.append(r)
	return out


## The signals that change what the inbox lists. `c` takes 0 to 2 arguments.
static func connect_changes(c: Callable) -> void:
	for sig in [EventBus.desk_changed, EventBus.event_triggered, EventBus.event_resolved,
			EventBus.event_set_aside, EventBus.messages_changed, EventBus.phase_changed,
			EventBus.day_tick_completed, EventBus.sheet_granted, EventBus.sheet_expired,
			EventBus.sheet_walked, EventBus.customer_added, EventBus.customer_removed,
			EventBus.customer_health_changed, EventBus.morale_changed, EventBus.character_removed]:
		sig.connect(c)


## [all, waiting, unread]: the queue row counts its cards.
static func counts(list: Array) -> Array:
	var n := [0, 0, 0]
	for it in list:
		var w: int = int(it.get("count", 1))
		n[0] += w
		n[1] += w if it.waiting else 0
		n[2] += w if it.unread else 0
	return n


## The inbox's item for the decision on screen.
static func active_item() -> Dictionary:
	var event_id: String = EventGate.active_id()
	var ctx: Dictionary = EventGate.active_context()
	var it := card_item("active", event_id, ctx, {}, GameState.day)
	it.merge({"kind": "active", "waiting": true, "from_desk": EventGate.active_from_desk()}, true)
	for p in EventGate.desk_papers():
		if String(p.event_id) == event_id and p.context == ctx:
			it.merge({"weeks_left": int(p.weeks_left), "expiring": bool(p.expiring)}, true)
	return it


## Marks a message read on its owner's path: the latest Ar-Ge note's read state is RnDSystem's.
static func mark_read(it: Dictionary) -> void:
	if it.get("kind", "") != "message" or not it.unread:
		return
	var notes: Array = GameState.messages.filter(func(m: Dictionary) -> bool: return m.kind == "rnd_note")
	if not notes.is_empty() and notes[-1].id == it.msg.id:
		RnDSystem.mark_note_read()
	else:
		MessageSystem.mark_read(String(it.msg.id))


## Why an account is in Risk, as the Sales tab says it.
static func risk_reason() -> String:
	return TranslationServer.translate("SALES_REASON_OUTAGE" if ProductSystem.live_bug_count() > B2BConstants.COMPLAINT_BUG_GATE
		else "SALES_REASON_SATISFACTION")


# --- Items ---------------------------------------------------------------------------------------

## A card as an item: its view in the live language with the names it kept, its sender and topic.
static func card_item(id: String, event_id: String, ctx: Dictionary, names: Dictionary, day: int) -> Dictionary:
	var card: Dictionary = EventGate.catalogue_card(event_id)
	var ev: GameEvent = EventGate.render(event_id, ctx, names)
	var from: Dictionary = card_sender(card, ctx, names)
	return {"id": id, "event_id": event_id, "ctx": ctx, "names": names, "event": ev, "day": day,
		"unread": false, "waiting": false, "sender": from, "subject": ev.title, "line": first_line(ev.body_text),
		"paper": String(card.get("class", "")) == "paper", "hourly": String(card.get("tick", "")) == "hourly",
		"topic": "EVENT_TAG_MENTOR" if from.kind == "frank" else String(EvChips.source_tag(ev, String(card.get("category", ""))).key)}


static func _paper_item(p: Dictionary) -> Dictionary:
	var it := card_item("paper:" + String(p.id), String(p.event_id), p.context, p.names, int(p.admitted_day))
	it.merge({"kind": "paper", "key": String(p.id), "waiting": true, "unread": not bool(p.opened),
		"weeks_left": int(p.weeks_left), "expiring": bool(p.expiring)}, true)
	return it


static func _history_item(i: int, row: Dictionary) -> Dictionary:
	var it := card_item("h:%d" % i, String(row.event_id), row.entities, row.get("names", {}), int(row.day))
	var expired: bool = row.resolution == EvHistory.RESOLUTION_EXPIRED
	var label: String = ""
	for c in (it.event as GameEvent).choices.size():
		if String(EventGate.catalogue_card(String(row.event_id)).options[c].get("id", "")) == String(row.option_id):
			label = ((it.event as GameEvent).choices[c] as EventChoice).label
	it.merge({"kind": "history", "row": row, "option": label, "expired": expired,
		"stamp": "MAIL_STAMP_EXPIRED" if expired else ("MAIL_STAMP_LEFT" if it.sender.gone else "MAIL_STAMP_ANSWERED"),
		"line": "" if expired else TranslationServer.translate("INBOX_CHOICE").format({"option": label})}, true)
	return it


static func _message_item(m: Dictionary) -> Dictionary:
	var it := {"id": "m:" + String(m.id), "kind": "message", "msg": m, "day": int(m.day), "waiting": false,
		"unread": not bool(m.read), "topic": MESSAGE_TOPICS.get(m.kind, "EVENT_TAG_AGENDA"),
		"subject": TranslationServer.translate(String(m.key)), "line": "", "right": "INBOX_ROW_REPORT"}
	var a: Dictionary = m.args
	match String(m.kind):
		"intro":
			it.sender = founder_note()
			it.line = first_line(TranslationServer.translate("MENTOR_INTRO_BODY"))
			it.right = ""
		"summary":
			it.sender = _desk(TranslationServer.translate("MAIL_SENDER_ACCOUNTS"), GameState.company_name)
			var d: Dictionary = SummarySystem.display(a)
			it.subject = d.title
			it.line = "%s %s → %s · %s %s" % [TranslationServer.translate("FIN_CAP_MRR"), Fmt.money_chip(int(a.mrr.from)),
				Fmt.money_chip(int(a.mrr.to)), TranslationServer.translate("MONTH_ROW_CASH"), signed_money(int(a.cash.to) - int(a.cash.from))]
		"sales_week":
			var rep: String = ""
			for r in a.rows:
				rep = String(r.get("rep", "")) if rep == "" else rep
			it.sender = named_employee(rep, HRConstants.ROLE_SALES_REP)
			it.sender.well = false   # a report leaves the room to its table
			var total: int = 0
			var names: PackedStringArray = []
			for r in a.rows:
				total += int(r.mrr)
				names.append(String(r.company))
			it.line = "%s · %s" % [", ".join(names), Fmt.money_exact(total) + TranslationServer.translate("SALES_PER_MONTH")]
		"rnd_note":
			it.sender = named_employee(String(a.get("author_name", "")), String(a.get("author_role", "")))
			it.line = first_line(note_lines(a)[0])
		"rnd_discovery":
			var node: String = String(a.node)
			it.sender = named_employee(String(a.get("author_name", "")), String(a.get("author_role", "")))
			it.subject = ResearchSeam.node_name(node)
			it.kind_key = String(m.key)
			it.line = first_line(RnDUiShared.t_or("PROD_RND_NODE_%s_DISCOVERY" % node.to_upper(), ""))
			it.right = "INBOX_ROW_DISCOVERY"
	return it


static func _reminder(id: String, topic: String, from: Dictionary, subject: String, tab: String,
		subpage: String = "") -> Dictionary:
	return {"id": "r:" + id, "kind": "reminder", "day": -1, "waiting": false, "unread": false, "topic": topic,
		"sender": from, "subject": subject, "line": "", "tab": tab, "subpage": subpage}


## The Ar-Ge note's three lines (§6.3), the empty ones dropped; the demand line falls back to its
## documented degraded sentence (§6.4).
static func note_lines(a: Dictionary) -> Array:
	var out: Array = []
	for row in [[String(a.get("demand_key", "")), {"line": String(a.get("line", ""))}, "RND_NOTE_DEMAND_NONE"],
			[String(a.get("rival_key", "")), {"rival": String(a.get("rival", ""))}, ""],
			[String(a.get("tech_key", "")), {"node": ResearchSeam.node_name(String(a.get("node", "")))}, ""]]:
		var text: String = RnDUiShared.t_or(row[0], "").format(row[1]) if row[0] != "" \
			else (TranslationServer.translate(row[2]) if row[2] != "" else "")
		if text != "":
			out.append(text)
	return out


# --- Senders ---------------------------------------------------------------------------------------
# {kind, name, title, sig_name, sig_line, look, portrait, well, mono, glyph, ink, gone, serif}: the
# header's name and title, the signature's two lines, and the face: a person's look (bust), a
# pre-rendered portrait, or a box with initials or a glyph. `well` adds the large portrait.

## Who a card's mail comes from.
static func card_sender(card: Dictionary, ctx: Dictionary, names: Dictionary) -> Dictionary:
	var kind: String = String(card.get("sender", ""))
	if kind == "" and String(card.get("speaker", "")) == MENTOR_ID:
		kind = "frank"
	var slots := {}
	for slot in ctx:
		slots.get_or_add(String((ctx[slot] as Dictionary).get("type", "")), slot)
	if kind == "":
		for pair in [[EvScope.TYPE_INVESTOR, "investor"], [EvScope.TYPE_EMPLOYEE, "employee"],
				[EvScope.TYPE_CUSTOMER, "contact"], [EvScope.TYPE_PROSPECT, "contact"], [EvScope.TYPE_FOUNDER, "self"]]:
			if slots.has(pair[0]):
				kind = pair[1]
				break
	if kind == "":
		kind = CATEGORY_SENDERS.get(String(card.get("category", "")), "self")
	var slot: String = ""
	for type in {"investor": [EvScope.TYPE_INVESTOR], "employee": [EvScope.TYPE_EMPLOYEE],
			"contact": [EvScope.TYPE_CUSTOMER, EvScope.TYPE_PROSPECT]}.get(kind, []):
		if slot == "":
			slot = slots.get(type, "")
	var id: String = String((ctx.get(slot, {}) as Dictionary).get("id", ""))
	var kept: String = EvPresenter.name_text(names[slot]) if names.has(slot) else ""
	match kind:
		"frank":
			return frank()
		"investor":
			return investor(id)
		"employee":
			var e: Character = CharacterRegistry.get_character(id)
			return employee(e) if e != null else gone_person(kept)
		"contact":
			if slots.has(EvScope.TYPE_PROSPECT) and not slots.has(EvScope.TYPE_CUSTOMER):
				var p: Prospect = ProspectRegistry.get_prospect(id)
				return _person(CounterpartSystem.prospect_people(p)[0], p.company_name) if p != null else gone_person(kept)
			var c: Customer = CustomerRegistry.get_customer(id)
			return contact(c) if c != null else _mono(kept, "", kept)
		"press":
			var outlet: String = CATEGORY_OUTLETS.get(String(card.get("category", "")), "WORLD_OUTLET_SEKTOR")
			var from := _mono(TranslationServer.translate(outlet), "", TranslationServer.translate(outlet))
			from.ink = UiTokens.D_outlet(outlet)
			return from
		"desk":
			return _desk(TranslationServer.translate("MAIL_SENDER_SUPPORT"), GameState.company_name)
	return founder_note()


static func frank() -> Dictionary:
	var m: Character = CharacterRegistry.get_mentor()
	var role: String = HRConstants.role_label(m.role)
	return _sender("frank", m.character_name, role, m.character_name, role, {"well": true, "serif": true,
		"portrait": FounderConstants.portrait_path(FounderConstants.MENTOR_PORTRAIT, Vector2i(40, 40)),
		"well_portrait": FounderConstants.portrait_path(FounderConstants.MENTOR_PORTRAIT, Vector2i(256, 320))})


static func employee(e: Character) -> Dictionary:
	var role: String = HRConstants.role_label(e.role)
	return _sender("employee", e.character_name, role, e.character_name,
		"%s · %s" % [role, GameState.company_name], {"look": e.look, "well": true})


## An employee named in a message, who may have left since.
static func named_employee(person: String, role_id: String) -> Dictionary:
	for e in CharacterRegistry.get_employees():
		if e.character_name == person:
			return employee(e)
	if person == "":
		return founder_note()
	var role: String = HRConstants.role_label(role_id) if role_id != "" else ""
	var from := _sender("employee", person, role, person, "%s · %s" % [role, GameState.company_name] if role != ""
		else GameState.company_name, {"mono": UiFactory.initials_of(person)})
	return from


static func gone_person(person: String) -> Dictionary:
	return _sender("employee", person, "", person, GameState.company_name,
		{"mono": UiFactory.initials_of(person), "gone": true})


## The account's buyer met at the table, when it came from a lead; else the sector's contact.
static func contact(c: Customer) -> Dictionary:
	if c.name_key != "":
		return _desk(TranslationServer.translate("MAIL_SENDER_SUPPORT"), GameState.company_name)
	if c.acquisition_source != "":
		return _person(CounterpartSystem.buyer_of(c), c.company_name)
	var title: String = TranslationServer.translate(B2BConstants.sector_contact(c.industry))
	return _mono(c.company_name, title, title, c.company_name)


static func investor(vc_id: String) -> Dictionary:
	var lead: Dictionary = CounterpartSystem.lead(vc_id)
	return _person(lead, String(InvestorRegistry.get_investor(vc_id).display_name), vc_id)


## The founder's own note.
static func founder_note() -> Dictionary:
	var f: Character = CharacterRegistry.get_founder()
	return _sender("self", f.character_name, TranslationServer.translate("MAIL_SELF_NOTE"), "", "",
		{"look": f.look, "well": true, "well_portrait": FounderConstants.portrait_path(GameState.founder_portrait)})


static func _person(person: Dictionary, company: String, vc_id := "") -> Dictionary:
	var title: String = CounterpartSystem.title(person, vc_id)
	return _sender("contact", String(person.name), title, String(person.name), "%s · %s" % [title, company],
		{"look": person.look})


## A sender with no face: initials in a box.
static func _mono(name: String, title: String, sig_name: String, sig_line := "") -> Dictionary:
	return _sender("contact", name, title, sig_name, sig_line, {"mono": UiFactory.initials_of(name)})


## A desk of the company: a glyph in a box.
static func _desk(name: String, company: String) -> Dictionary:
	return _sender("desk", name, company, name, company, {"glyph": "res://assets/icons/util/doc.svg"})


static func _sender(kind: String, name: String, title: String, sig_name: String, sig_line: String,
		face: Dictionary) -> Dictionary:
	var out := {"kind": kind, "name": name, "title": title, "sig_name": sig_name, "sig_line": sig_line,
		"look": {}, "portrait": "", "well_portrait": "", "well": false, "mono": "", "glyph": "",
		"ink": Color.TRANSPARENT, "gone": false, "serif": false}
	out.merge(face, true)
	return out


# --- Text ----------------------------------------------------------------------------------------

## A body's first line, its markup and Frank's quote marks off.
static func first_line(body: String) -> String:
	for line in body.split("\n", false):
		var text: String = line.replace("**", "").replace("*", "").strip_edges()
		if text != "":
			return text
	return ""


## "Hafta 14 · Nisan 2026", and the hour for an hourly card.
static func date_text(day: int, hour := -1) -> String:
	var date: String = Fmt.date_line(GameState.get_date_dict(day))
	return date if hour < 0 else "%s · %02d:00" % [date, hour]


static func signed_money(value: int) -> String:
	return "±0" if value == 0 else ("+" if value > 0 else "−") + Fmt.money_chip(absi(value))


static func _bound(ctx: Dictionary, type: String) -> String:
	for slot in ctx:
		if String((ctx[slot] as Dictionary).get("type", "")) == type:
			return String((ctx[slot] as Dictionary).get("id", ""))
	return ""
