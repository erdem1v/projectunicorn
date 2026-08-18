extends Node

# Rival registry (Product Lifecycle Part 1) — single source of truth for the
# competitive field. Mirrors CustomerRegistry: a Dictionary id→Rival, read-only
# query API, mutations emit on EventBus so scenes (RightPanel) self-update.
#
# Seeded from RivalCatalog at _ready. Rivals evolve slowly on the daily tick
# (advance_all, called by TimeManager) — startups fast, established slow, giants
# static — so a player who stops feeding their product gets passed.
#
# STRUCTURAL CEILING: rival advancement uses QualityModel.grow with per-tier
# asymptotes. The player's Rev3 axes are bounded by the catalog pool sums (+
# strengthen accretion paid in efor/time), which sit far below the giant band
# (composite ≈ 285). Enforced by the number bands, not a clamp.

const TIER_ASYMPTOTE := {"startup": 100.0, "established": 200.0, "giant": 330.0}

var _rivals: Dictionary = {}   # id -> Rival


func _ready() -> void:
	for r in RivalCatalog.build_all():
		r.status = _status_for(r)
		_rivals[r.id] = r
		EventBus.rival_added.emit(r.id)


func reset() -> void:
	# Run-boundary reset (SaveManager.reset_all_owners). Rivals are the ONE registry that
	# cannot simply be emptied: advance_all() mutates innovation/stability/experience every
	# single day, so by day 140 the field is nothing like the catalog — but an empty field
	# is not a valid state either. _rival_relative_quality benchmarks the player's audience
	# churn against the same-type startup average, and with no rivals it returns the player's
	# own quality, i.e. the competitive pressure that Calibration Law 1 calls load-bearing
	# silently switches off. So this RE-SEEDS from the catalog rather than clearing.
	#
	# No rival_added emits: the shell is not in the tree at reset time (same doctrine as
	# CharacterRegistry.reset()), and _ready already covered the one moment listeners exist.
	_rivals.clear()
	for r in RivalCatalog.build_all():
		r.status = _status_for(r)
		_rivals[r.id] = r


func insert_raw(rival: Rival) -> void:
	# SAVE RESTORE ONLY. OVERWRITES the catalog-seeded record of the same id rather than
	# rejecting it, which is what makes restore an OVERLAY on top of reset(): a save written
	# before a catalog entry existed still gets that rival at its catalog starting values
	# instead of leaving a hole every share/league query would have to guard against.
	if rival == null or rival.id == "":
		push_warning("[RivalRegistry] insert_raw() called with null or missing id")
		return
	_rivals[rival.id] = rival


# --- Read API ---

func get_rival(rival_id: String) -> Rival:
	return _rivals.get(rival_id, null)


func get_all() -> Array[Rival]:
	var out: Array[Rival] = []
	for r in _rivals.values():
		out.append(r)
	return out


func get_by_type(sub_type_id: String) -> Array[Rival]:
	var out: Array[Rival] = []
	for r in _rivals.values():
		if r.sub_product_type_id == sub_type_id:
			out.append(r)
	return out


func get_by_tier(tier: String) -> Array[Rival]:
	var out: Array[Rival] = []
	for r in _rivals.values():
		if r.tier == tier:
			out.append(r)
	return out


# Rank the player among same-type STARTUP rivals. Returns {rank, total, text}.
# rank is 1-based (1 = ahead of every startup rival). total = startup rivals + the
# player. `player_composite` should be the player's type-weighted composite.
func get_player_rank_in_startup_league(sub_type_id: String, player_composite: float) -> Dictionary:
	var axes: Array = ProductCatalog.get_quality_axes(sub_type_id)
	var league: int = 0
	var better: int = 0
	for r in _rivals.values():
		if r.tier == "startup" and r.sub_product_type_id == sub_type_id:
			league += 1
			if r.composite(axes) > player_composite:
				better += 1
	var total: int = league + 1
	var rank: int = better + 1
	# WORKING TR — "lig" vokabüleri emekli (Fix 3): sıralama artık kalite kıyası
	# olarak okunur, pazar anlatısı get_market_snapshot'ındır.
	return {"rank": rank, "total": total, "text": "startup sınıfında %d/%d" % [rank, total]}


# --- Advancement (called daily by TimeManager) ---

func advance_all(days: int = 1) -> void:
	var any_changed: bool = false
	for r in _rivals.values():
		if r.momentum <= 0.0:
			continue   # giants are static
		var a: float = float(TIER_ASYMPTOTE.get(r.tier, 100.0))
		for _i in days:
			r.innovation = QualityModel.grow(r.innovation, r.momentum, a)
			r.stability = QualityModel.grow(r.stability, r.momentum, a)
			r.experience = QualityModel.grow(r.experience, r.momentum, a)
		var new_status: String = _status_for(r)
		if new_status != r.status:
			r.status = new_status
			EventBus.rival_status_changed.emit(r.id, new_status)
		any_changed = true
	if any_changed:
		EventBus.rival_advanced.emit()


func _status_for(r: Rival) -> String:
	if r.tier == "giant":
		return "DOMINANT"
	if r.tier == "established":
		return "STEADY"
	return "SCALING" if r.momentum >= 0.6 else "QUIET"


# ======================= Pazar payı (Dünya İnandırıcılığı Fix 3) ================
# LİG çerçevesinin yerini alan sunum katmanı. STATELESS: get_market_snapshot her
# çağrıda yalnız (RivalCatalog seed'leri + momentum, GameState.day, GameState.mrr,
# MARKET_TOTAL_MRR) girdilerinden türetilen SAF fonksiyondur — canlı kalite
# eksenleri OKUNMAZ (advance_all onları her gün mutasyona uğratır; bugünden
# "geçen haftanın payı"nı hesaplamak ancak saf bir fonksiyonla doğru kalır).
# Kalite ligi (composite, rank API, ekonomi bağı) olduğu gibi durur: pay, MRR
# anlatısıdır, kalite yarışı değil. RNG yok — doku, hafta-bloklu hash wobble.
#
# Tüketiciler (ODA board + ticker feed): get_market_snapshot(sub_id) /
# get_player_share_pct() / format_share(pct). Repaint sinyali: day_advanced +
# mrr_changed yeterlidir (snapshot durumsuz olduğundan her okuma günceldir).

const SHARE_GROWTH_PER_DAY := 0.004    # momentum başına günlük göreli büyüme  # WORKING
const SHARE_WOBBLE_AMP := 0.08         # hafta-bloklu doku genliği (momentum ölçekli)  # WORKING
# Eşik, rakiplerin HAFTALIK rutin hamlesinin altında durmalı, yoksa rakip haber
# kaynağı açlıktan ölür (90 günlük smoke bunu ölçer). Ölçülen rutin bant (10 alt-tür
# × 11 satır × 200 gün): 0,006 (en küçük startup) … 0,051 (lider startup); yerleşikler
# 0,025 ve 0,045, holdingler 0,009-0,015, dev tam 0,000. 0,02 bandın İÇİNDE durur —
# en küçük iki startup ile iki holding "yatay" sayılır, kalan her satır kımıldar.
# Kardeş sabit NewsFeedSystem.RIVAL_BIG_MOVE_PCT aynı taramadan türedi: o, rutin
# bandın ÜSTÜNDE durup yalnız sıçramayı yakalar. % puan.
const SHARE_TREND_EPSILON := 0.02      # altı "yatay" sayılır  # WORKING
const SHARE_MOVED_WINDOW_DAYS := 7     # trend + moved_recently penceresi


func get_market_snapshot(sub_type_id: String) -> Dictionary:
	# {player_pct, others_pct, market_total_mrr, rivals: [{id, name, tier, share_pct,
	#  trend(-1|0|+1), moved_recently}] pay-azalan}. Toplam (player + rivals + others)
	# = 100 — "diğerleri" (uzun kuyruk) artıktır, taşmada adlandırılmışlar ölçeklenir.
	var day: int = GameState.day
	var player_pct: float = clampf(100.0 * float(GameState.mrr) / float(RivalCatalog.MARKET_TOTAL_MRR), 0.0, 90.0)
	var rows: Array = []
	var raw_sum: float = 0.0
	for i in RivalCatalog.TEMPLATE.size():
		var t: Dictionary = RivalCatalog.TEMPLATE[i]
		var rid: String = "rv_%s_%d" % [sub_type_id, i]
		var r: Rival = get_rival(rid)
		var display_name: String = r.product_name if r != null else "%s #%d" % [sub_type_id, i]
		rows.append(_share_row(rid, display_name, String(t["tier"]),
			float(RivalCatalog.SHARE_SEED[i]), float(t["momentum"]), day))
	for actor in RivalCatalog.MARKET_ACTORS:
		rows.append(_share_row(String(actor["id"]), String(actor["name"]), "holding",
			float(actor["share"]), float(actor["momentum"]), day))
	for row in rows:
		raw_sum += float(row["share_pct"])
	var budget: float = 100.0 - player_pct
	if raw_sum > budget:
		var scale: float = budget / raw_sum
		for row in rows:
			row["share_pct"] = float(row["share_pct"]) * scale
		raw_sum = budget
	rows.sort_custom(func(a, b): return float(a["share_pct"]) > float(b["share_pct"]))
	return {
		"player_pct": player_pct,
		"others_pct": maxf(budget - raw_sum, 0.0),
		"market_total_mrr": RivalCatalog.MARKET_TOTAL_MRR,
		"rivals": rows,
	}


func get_player_share_pct() -> float:
	return clampf(100.0 * float(GameState.mrr) / float(RivalCatalog.MARKET_TOTAL_MRR), 0.0, 90.0)


func format_share(pct: float) -> String:
	# Kıymığın görünmesi tasarımın kalbi: tek ondalık; eşiğin altı "henüz yok denecek
	# kadar küçük" okunur, görünmez değil. BİÇİM ARTIK YERELDEN geliyor (Fmt): işaretin
	# yeri ve ondalık ayracı dile göre değişir (%0,3 ↔ 0.3%), taban metni SHARE_FLOOR
	# anahtarında. Buradaki KARAR yalnız eşiğin kendisi — 0,1'in altı ayrı bir cümledir.
	if pct < 0.1:
		return TranslationServer.translate("SHARE_FLOOR")
	return Fmt.percent(pct, 1)


func _share_row(rid: String, display_name: String, tier: String,
		seed: float, momentum: float, day: int) -> Dictionary:
	var now: float = _share_at(rid, seed, momentum, day)
	var prev: float = _share_at(rid, seed, momentum, maxi(day - SHARE_MOVED_WINDOW_DAYS, 0))
	var delta: float = now - prev
	var trend: int = 0
	if delta > SHARE_TREND_EPSILON:
		trend = 1
	elif delta < -SHARE_TREND_EPSILON:
		trend = -1
	return {
		"id": rid, "name": display_name, "tier": tier,
		"share_pct": now, "trend": trend,
		"delta_pct": absf(delta),
		"moved_recently": absf(delta) >= SHARE_TREND_EPSILON,
	}


func _share_at(rid: String, seed: float, momentum: float, day: int) -> float:
	# Saf pay eğrisi: yavaş momentum büyümesi × hafta-bloklu deterministik wobble.
	# Momentum 0 (dev) → tamamen durağan; kalite modelindeki "giants are static"
	# ile aynı fiction. Wobble genliği momentumla ölçeklenir: yerleşikler kıpırdar,
	# startup'lar oynar.
	#
	# ÖLÇÜM NOTU (curve seansının maddesi): wobble PRATİKTE doku üretmiyor. hash()
	# djb2'dir ve hafta numarası dizginin SONUNA yazılır — ardışık hafta anahtarları
	# ardışık tamsayıya düşer, %1000 sonrası w haftada yalnız +0,001 kayar. Tek gerçek
	# sıçrama haftanın basamak sayısı değişince olur (hafta 9→10, yani gün 70). Sonuç:
	# haftalık delta neredeyse tamamen büyüme terimidir (seed × momentum × 0,028) ve
	# koşu başına TEK büyük hamle penceresi vardır. Paylar tutarlı, ama "doku" iddiası
	# şu an gerçekleşmiyor; düzeltmek ODA panosundaki görünen payları oynatır, o yüzden
	# ayrı karar. Haber eşikleri bu GERÇEK dağılıma göre ayarlandı, iddiaya göre değil.
	var grown: float = seed * (1.0 + momentum * SHARE_GROWTH_PER_DAY * float(day))
	var week: int = int(float(day) / float(SHARE_MOVED_WINDOW_DAYS))
	var w: float = float(absi(hash("%s|%d" % [rid, week])) % 1000) / 1000.0
	var amp: float = SHARE_WOBBLE_AMP * momentum
	return maxf(grown * (1.0 + amp * (w * 2.0 - 1.0)), 0.0)
