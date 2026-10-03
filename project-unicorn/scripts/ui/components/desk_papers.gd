extends RefCounted

# Masadaki kâğıtların tek türetme ve çizim evi: Olaylar sayfası ve ofisin not yığını buradan okur.
# İKİ CİNS KÂĞIT. Motor kâğıtları saati işleyen KARARLARDIR, tıklanınca kartı açar; sıralamanın
# sahibi motordur ve listenin başına gelir (en acili önde). Hatırlatıcılar canlı durumdan türer,
# saati yoktur, tıklanınca sekmesine götürür.
# Dışarıdan preload ile erişilir: global class cache'e bağımlılık yok (headless tuzağı).

## Motor kâğıdının etiketi kartın kategorisinden, olay modalının kaynak etiketleriyle aynı
## sözcükler; tabloda olmayan kategori (dünya, kurucu) gündemdir.
const CATEGORY_TAGS := {"customer": "EVENT_TAG_CUSTOMER", "team": "EVENT_TAG_TEAM",
	"product": "EVENT_TAG_PRODUCT", "funding": "DESK_PAPER_TAG_FUNDING"}


## [{id, dot, tag, title, weeks_left (-1 = saatsiz), expiring, tab, subpage}]. `expiring` motorun
## son hafta vurgusudur; hatırlatıcıda hep false. Motor kâğıdının `tab`'ı boştur: tıklanınca
## kendi kartı açılır.
static func gather() -> Array:
	var papers: Array = []
	for e in EventGate.desk_papers(64):
		var expiring: bool = bool(e["expiring"])
		papers.append({"id": String(e["id"]), "title": String(e["title"]),
			"tag": TranslationServer.translate(CATEGORY_TAGS.get(e["category"], "EVENT_TAG_AGENDA")),
			"weeks_left": int(e["weeks_left"]), "expiring": expiring, "tab": "", "subpage": "",
			"dot": UiTokens.ACCENT_DEEP if expiring else UiTokens.health_color(&"warn")})
	if GameState.phase_gate_ready and GameState.pending_next_phase > 0:
		papers.append(_reminder("gate", UiTokens.ACCENT_DEEP,
			TranslationServer.translate("DESK_PAPER_TAG_GATE"),
			TranslationServer.translate("DESK_PAPER_GATE_TITLE"), "finance"))
	var sheets: Array = GameState.active_sheets
	if not sheets.is_empty():
		var title: String = TranslationServer.translate("DESK_PAPER_SHEETS_TITLE").format({"n": sheets.size()})
		if sheets.size() == 1:
			var sheet: TermSheet = sheets[0]
			var weeks: int = sheet.weeks_left(GameState.day)
			# Süresi dolan teklifin sayacak haftası kalmaz; kâğıt fonun cevap beklediğini söyler.
			title = TranslationServer.translate("HUNT_DECISION_DUE") if sheet.is_decision_due(GameState.day) \
				else TranslationServer.translate(Fmt.count_key("DESK_PAPER_SHEET_TITLE", weeks)).format({"weeks": weeks})
		papers.append(_reminder("sheet", UiTokens.health_color(&"warn"),
			TranslationServer.translate("DESK_PAPER_TAG_FUNDING"), title, "finance",
			"yatirim"))   # LOC-DATA route id
	if HRSearchSystem.has_files_ready():
		papers.append(_reminder("atlas", UiTokens.INK_MUTED,
			TranslationServer.translate("DESK_PAPER_TAG_ATLAS"),
			TranslationServer.translate("DESK_PAPER_ATLAS_TITLE").format(
				{"n": HRSearchSystem.get_files().size()}), "hr"))
	# Sözleşme yenileme penceresi ve fatura vadesi motorda yok; genişleme aşamasındaki B2B
	# hesabı onların yerini tutar.
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.lifecycle_phase == "expansion":
			papers.append(_reminder("exp_" + c.id, UiTokens.health_green(), Fmt.upper(c.company_name),
				TranslationServer.translate("DESK_PAPER_EXPANSION_TITLE"), "sales"))
	return papers


## Masayı değiştiren sinyaller, iki yüzeyin tek listesi: kâğıtlar motorun her değişikliğinde
## (`desk_changed`, saatlik tikte gelen kâğıt dahil) ve karar çözülünce, hatırlatıcılar ve Frank'in
## satırı sahiplerinin sinyalinde değişir. `c` 0-2 argümanı kabul etmeli.
static func connect_changes(c: Callable) -> void:
	for sig in [EventBus.desk_changed, EventBus.event_triggered, EventBus.event_resolved,
			EventBus.mentor_advisory_changed, EventBus.phase_changed, EventBus.day_tick_completed,
			EventBus.sheet_granted, EventBus.sheet_expired, EventBus.sheet_walked,
			EventBus.customer_added, EventBus.customer_removed, EventBus.customer_health_changed]:
		sig.connect(c)


## Kâğıdın satırı, iki yüzeyde aynı: nokta, etiket, başlık ve saati olan kâğıtta kalan hafta. Son
## haftasında "bu hafta" der; vurgu ertelenmiş bir kararın aldığı tek uyarıdır.
static func make_row(paper: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(UiFactory.make_dot(paper["dot"], 6))
	row.add_child(UiFactory.make_label(String(paper["tag"]), &"MicroLabel"))
	var title := UiFactory.make_label(String(paper["title"]), &"BodySerif")
	title.clip_text = true
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	var weeks_left: int = int(paper["weeks_left"])
	if weeks_left >= 0:
		row.add_child(UiFactory.make_label(
			TranslationServer.translate("DESK_PAPER_THIS_WEEK") if weeks_left == 1
				else TranslationServer.translate("DESK_PAPER_WEEKS").format({"n": weeks_left}),
			&"MicroLabel", UiTokens.ACCENT_DEEP if bool(paper["expiring"]) else UiTokens.INK_MUTED))
	return row


## Kâğıdın tek tıklama yolu: motor kâğıdı kartını açar, hatırlatıcı sekmesine gider.
static func open(paper: Dictionary) -> void:
	var tab: String = String(paper["tab"])
	if tab == "":
		EventGate.open_paper(String(paper["id"]))
		return
	EventBus.tab_changed.emit(tab)
	if String(paper["subpage"]) != "":
		# Sekme açılışı senkron: alt sayfa isteği bağlanmış dinleyiciye düşer.
		EventBus.finance_subpage_requested.emit(String(paper["subpage"]))


static func _reminder(id: String, dot: Color, tag: String, title: String, tab: String,
		subpage: String = "") -> Dictionary:
	return {"id": id, "dot": dot, "tag": tag, "title": title, "weeks_left": -1, "expiring": false,
		"tab": tab, "subpage": subpage}
