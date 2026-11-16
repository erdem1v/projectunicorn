class_name Reputation
extends RefCounted

## İtibarın ürün ve müşteri girdileri (PRD_ERP §4.3): yayına çıkan kademe, tutulan ve bozulan söz, kaybedilen hesap, sürümden
## kaçan hatanın dokunduğu hesaplar. Sinyalleri dinler, İtibar'ı `GameState.set_reputation` ile yazar ve her değişimi nedeniyle
## `reputation_log` bayrağına kaydeder; Satış başlığının ipucu oradan okur, düşüş haber şeridine düşer. Olay fiillerinin
## (olay kartıyla kaybedilen hesap, `churn_customer`, dahil) ve hata ihmalinin (`SupportSystem`) değişimi kendi yerinde
## yazılır, bu kayda girmez. Ağırlıklar `SalesConstants.REP_*`.

const LOG := "reputation_log"
const NEWS_SOURCE := "NOTICE_SRC_SALES"


## Sinyallere bağlanır; TimeManager açılışta bir kez çağırır.
static func wire() -> void:
	EventBus.line_upgraded.connect(_on_tier)
	EventBus.promise_kept.connect(_on_kept)
	EventBus.promise_broken.connect(_on_broken)
	EventBus.customer_churned.connect(_on_lost)
	EventBus.version_shipped.connect(_on_release)


## Son değişimler, en yeni önde: {day, kind, delta, args}. `kind` ve `args`: "tier" {line, tier}, "kept", "partial" (bozulmuş
## sözün geç tutulması) ve "broken" {customer},
## "lost" {customer}, "escaped" {line, accounts}; `customer` hesabın adıdır (kaybedilen hesap kayıttan silinir).
static func recent() -> Array:
	return GameState.get_flag(LOG, [])


## Değişimin satırı ({key, args}, `NewsFeedSystem.line_text` çözer): neden ve İtibar'ın oynadığı; Satış başlığının ipucu ve
## haber şeridi okur.
static func line(row: Dictionary) -> Dictionary:
	var key: String = "REPUTATION_" + String(row.kind).to_upper()
	var args: Dictionary = row.args
	match String(row.kind):
		"tier":
			args = {"step": {"key": SprintCatalog.step_name_key(String(ProductLines.step_at(row.args.line, int(row.args.tier)).id))}}
		"escaped":
			args = {"module": {"key": ProductLines.line(row.args.line).name_key}, "n": int(row.args.accounts)}
			if int(row.args.accounts) == 1:
				key += "_ONE"
	return {"key": "REPUTATION_ROW", "args": {"reason": {"key": key, "args": args},
		"delta": ("+" if int(row.delta) > 0 else "") + str(int(row.delta))}}


## Yayından önce biten kademe kimseye görünmedi: İtibar'ı oynatmaz.
static func _on_tier(line_id: String, tier: int) -> void:
	if not ProductState.is_live():
		return
	_add("tier", SalesConstants.REP_TIER, {"line": line_id, "tier": tier})


static func _on_kept(promise_id: String) -> void:
	var p: Promise = PromiseRegistry.get_promise(promise_id)
	_add(p.status, SalesConstants.REP_KEPT if p.status == "kept" else SalesConstants.REP_PARTIAL, _account(p.customer_id))


static func _on_broken(promise_id: String) -> void:
	_add("broken", -SalesConstants.REP_BROKEN, _account(PromiseRegistry.get_promise(promise_id).customer_id))


static func _on_lost(customer_id: String) -> void:
	_add("lost", -SalesConstants.REP_LOST, _account(customer_id))


## Kaçan hatası en az bir hesaba dokunan sürüm `REP_ESCAPED` düşürür, kaç hesaba dokunduğundan bağımsız: bedel şirketin
## ölçeğiyle büyümesin (bir hesapta da elli hesapta da aynı). Kayıt dokunulan hesap sayısını (her hesap bir kez) ve en çok hesaba
## dokunan hattı taşır.
static func _on_release(_number: int) -> void:
	var touched: Dictionary = {}
	var worst: String = ""
	var most: int = 0
	for escaped: String in GameState.product.releases.back().get("escaped", []):
		var accounts: Array = SprintCatalog.line_accounts(escaped)
		for c: Customer in accounts:
			touched[c.id] = true
		if accounts.size() > most:
			most = accounts.size()
			worst = escaped
	if not touched.is_empty():
		_add("escaped", -SalesConstants.REP_ESCAPED, {"line": worst, "accounts": touched.size()})


static func _account(customer_id: String) -> Dictionary:
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	return {"customer": c.company_name if c != null else customer_id}


## İtibar'ı `delta` kadar oynatır; sınırda kalan (−10..100) değişim kayda girmez, düşüş haber şeridine nedeniyle düşer.
static func _add(kind: String, delta: int, args: Dictionary) -> void:
	var before: int = GameState.reputation
	GameState.set_reputation(before + delta)
	var moved: int = GameState.reputation - before
	if moved == 0:
		return
	var rows: Array = recent().duplicate()
	rows.push_front({"day": GameState.day, "kind": kind, "delta": moved, "args": args})
	GameState.set_flag(LOG, rows.slice(0, SalesConstants.REP_LOG_MAX))
	if moved < 0:
		EventBus.headline_added.emit(NEWS_SOURCE, line(rows[0]))
