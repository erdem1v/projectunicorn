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
#   header: {name, live_version: "4" or "" (MVP öncesi), market: "B2C"|"B2B", type_text (büyük harf)},
#   versions: [{label: "v4", sprint: int or -1, shipped_count: int or -1}],   # -1 çizilmez
#   quarter: {state: "locked_no_pm"|"coming_soon"|"open",
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
# part = {k: "level", area, from, to} | {k: "holds", area, word} | {k: "alert_clear", area}
#      | {k: "cap", name, from, to} | {k: "tickets", n} | {k: "voices", n} | {k: "request", customer, value}
#      | {k: "rival_gap"} | {k: "research", area} | {k: "request_on_time", customer}
#   level ve cap parçalarında from/to seviyedir (0..3); kelime ve renk SprintUiShared.level_word'den.

## Hata ayıklama rölesinin anahtarı; komut satırı bayrağı olmadan da ekranı açar.
static var forced := false


## Yalnız debug build: `--product-rev7` komut satırında ya da Main Run Args'ta, veya `forced`.
static func enabled() -> bool:
	if not OS.is_debug_build():
		return false
	var args: PackedStringArray = OS.get_cmdline_args()
	args.append_array(String(ProjectSettings.get_setting("application/run/main_args", "")).split(" ", false))
	return forced or "--product-rev7" in args


## Kaynak verilmediğinde sekmenin okuduğu model: yalnız gerçek başlık ve sürüm geçmişi; sprint
## sistemleri bağlanana kadar alanlar, kartlar ve kapasite boş.
static func live() -> Dictionary:
	var versions: Array = []
	for e in GameState.get_flag("mvp_version_history", []):
		versions.append({"label": TranslationServer.translate("PROD_VERSION_SHORT").format({"version": int(e["version"])}),
			"sprint": -1, "shipped_count": -1})
	var has_pm: bool = CharacterRegistry.count_active_by_role(HRConstants.ROLE_PRODUCT_MANAGER) > 0
	return {
		"header": {
			# Adsız ürün tür adıyla okunur; canlı ürün en az v1'dir (eski sekmeyle aynı kural).
			"name": SalesSystem._product_name(),
			"live_version": str(maxi(ProductState.version(), 1)) if ProductState.is_live() else "",
			"market": ProductState.market_type().to_upper(),
			"type_text": Fmt.upper(ProductCatalog.type_name(ProductState.subtype())),
		},
		"versions": versions,
		"quarter": {"state": "coming_soon" if has_pm else "locked_no_pm", "goal": null, "columns": []},
		"ui": {"view": "sprint", "open_area": "", "history_open": false, "voices_open": false, "hover_card": ""},
		"areas": [],
		"customers": null,
		"center": {
			"mode": "plan", "sprint": -1, "weeks": 0, "week": 0, "capacity": null, "team": [],
			"warning_text": "", "cards": [], "forecast": [], "status": {"done": 0, "running": 0, "decisions": 0},
			"next_version": null, "can_add": false, "can_start": false, "start_block": false,
			"beta": null, "lead_tip": null, "release": null,
		},
		"next": {"sprint": -1, "flags": [], "cards": []},
	}
