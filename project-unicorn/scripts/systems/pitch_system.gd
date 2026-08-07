class_name PitchSystem
extends RefCounted

# Pitch dialogue driver — PostShip spec §D/§E. Pure static logic; the
# PitchDialogueModal is a thin renderer that calls begin()/get_stage()/choose().
#
# 4-scene medium-depth (Disco-flavored) flow:
#   intro   → approach sets a small bonus
#   value   → framing SkillCheck (sales/influence) → bonus ±
#   pricing → anchor-high / fair / safe sets target MRR + close difficulty
#   close   → final Satış (sales) SkillCheck → SIGNED / CALLBACK / LOST
# Satış ≥ reveal threshold (SkillCheck.can_read_prospect) exposes the
# prospect's hidden budget_band/real_need, informing the pricing choice.
#
# §10: a customer (MRR) is created ONLY on SIGNED, from this played dialogue.

const PITCH_COOLDOWN_DAYS := 2
const VALUE_BASE_DIFFICULTY := 1
const CLOSE_BASE_DIFFICULTY := 1

# Target MRR bands per archetype live in CustomerArchetypes (single data home).

# Prospect generation pools (working drafts; Erdem revises). Company names live
# in CompanyCatalog (single source, Fix 2) — only the need lines remain here.
const _NEEDS := ["Ekip dağınık, tek bir yerde toplamak istiyorlar.",
	"Manuel süreçler zaman yiyor, otomasyon arıyorlar.",
	"Mevcut araçları pahalı ve şişkin, sade bir şey istiyorlar.",
	"Raporlama kâbus, yönetim net veri istiyor."]
const _REAL_NEEDS := ["Aslında derdi bütçe değil — patronuna 'modernleştik' diyebilmek.",
	"Asıl korkusu rakibin gerisinde kalmak.",
	"Geçen yıl yanlış araca para yatırdı, bu sefer garanti istiyor."]

# --- Per-pitch state ---
static var _active: bool = false
static var _prospect: Prospect = null
static var _stage_idx: int = 0
static var _accum_bonus: int = 0
static var _price_mult: float = 0.55
static var _close_diff_delta: int = 0
static var _last_band: String = ""


# --- Lead generation (Frank intro / Find Prospects / referral events) ---

static func spawn_prospect(archetype: String, source: String) -> Prospect:
	# NULL CONTRACT (Fix 1): returns null — nothing registered, no counter burned — when
	# every catalog company in the product's affinity sectors is already excluded. Exclusion
	# set = every company SIGNED this run (GameState.b2b_signed_company_names; churn does NOT
	# re-open cold prospecting — win-back is a future dedicated path) ∪ every company live in
	# ProspectRegistry. A LOST lead's name is freed and may return later; a signed one never.
	#
	# The id counter is MONOTONIC (GameState.run_prospects_spawned), not the live pool size:
	# ProspectRegistry.count() drops when a lead is signed or lost, so a same-day respawn
	# rebuilt an id that already existed. ProspectRegistry.add then push_warning'd and DROPPED
	# the lead while this function still returned it — the caller reports success and nothing
	# is registered. Rare while spawning is pull-based; routine once a sales rep spawns daily.
	# The content mixer `n` deliberately keeps reading count(): it selects sector/company/pain
	# and is not required to be unique, and changing it would move every existing fixture.
	var n: int = (GameState.day * 7 + ProspectRegistry.count() * 13)
	# E.2: draw the industry from the ACTIVE product's sector affinity (a vector-search
	# product yields only tech/finance prospects; ops yields only construction/etc.), and
	# the company name from that sector so the fiction matches. The walk starts at the
	# mixer's sector and stays INSIDE the affinity pool (smoke asserts industry ∈ pool);
	# a sector whose companies are all taken defers to the pool's next sector.
	var sub_id: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var sectors: Array = B2BConstants.sector_pool(sub_id)
	var excluded: Dictionary = _excluded_names()
	var chosen_sector: String = ""
	var eligible: Array = []
	for off in sectors.size():
		var s: String = String(sectors[(n + off) % sectors.size()])
		var cand: Array = _eligible_for_sector(s, excluded)
		if not cand.is_empty():
			chosen_sector = s
			eligible = cand
			break
	if chosen_sector == "":
		return null
	var p := Prospect.new()
	GameState.run_prospects_spawned += 1
	p.id = "lead_%d_%d" % [GameState.day, GameState.run_prospects_spawned]
	p.archetype = archetype
	p.industry = chosen_sector
	p.company_name = String(eligible[n % eligible.size()])
	# B.4: tie the surface need to a feature that EXISTS in the active product's pool,
	# so a later special request maps to something the player can actually build.
	var pain_fid: String = B2BSalesSystem.pick_pain_feature(sub_id, n)
	p.pain_feature_id = pain_fid
	p.need_summary = B2BConstants.pain_phrase(pain_fid) if pain_fid != "" else _NEEDS[n % _NEEDS.size()]
	p.real_need = _REAL_NEEDS[n % _REAL_NEEDS.size()]
	p.difficulty_stars = _difficulty_for(archetype)
	p.scale = B2BConstants.roll_scale(archetype)   # 1..5 stars; demo-capped to 1-3 (A.4)
	p.budget_band = _budget_for(archetype)
	# E.3: value shown as a RANGE band (floor if it goes poorly, ceiling if well).
	var band: Dictionary = CustomerArchetypes.mrr_band(archetype)
	var mid: float = (float(band["low"]) + float(band["high"])) * 0.5
	p.value_band_min = int(round(mid * B2BConstants.VALUE_BAND_LOW_FRAC))
	p.value_band_max = int(round(mid * B2BConstants.VALUE_BAND_HIGH_FRAC))
	p.source = source
	p.spawned_on_day = GameState.day
	ProspectRegistry.add(p)
	return p


static func eligible_company_count() -> int:
	# UI predicate for the find card's "havuz kuru" state: how many catalog companies
	# in the active product's affinity sectors could still become a lead right now.
	# Shares the exclusion arithmetic with spawn_prospect via the two helpers below,
	# so the predicate and the picker cannot drift apart.
	var sub_id: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var excluded: Dictionary = _excluded_names()
	var total: int = 0
	for s in B2BConstants.sector_pool(sub_id):
		total += _eligible_for_sector(String(s), excluded).size()
	return total


static func _excluded_names() -> Dictionary:
	# Set (Dictionary keys) of company names spawn may not offer (Fix 1).
	var ex: Dictionary = {}
	for nm in GameState.b2b_signed_company_names:
		ex[nm] = true
	for nm in ProspectRegistry.get_company_names():
		ex[nm] = true
	return ex


static func _eligible_for_sector(sector: String, excluded: Dictionary) -> Array:
	var out: Array = []
	for nm in CompanyCatalog.names_for_sector(sector):
		if not excluded.has(nm):
			out.append(nm)
	return out


static func _difficulty_for(archetype: String) -> int:
	return CustomerArchetypes.difficulty_stars(archetype)


static func _budget_for(archetype: String) -> String:
	return CustomerArchetypes.budget_band(archetype)


# --- Value-driven pricing range (E) ---

static func _value_premium_position() -> float:
	# Map product worth ($/user from the value algorithm) to a 0..1 "how premium"
	# position used to place the recommended price within the archetype's MRR band.
	var optimal: float = float(SalesSystem.product_value()["optimal"])
	return clampf((optimal - 4.0) / 24.0, 0.0, 1.0)   # ~$4 → band-low, ~$28 → band-high (working)


static func _price_mult_window() -> Dictionary:
	# Recommended price_mult window (±0.18 around the value position).
	var v: float = _value_premium_position()
	return {"lo": clampf(v - 0.18, 0.0, 1.0), "hi": clampf(v + 0.18, 0.0, 1.0), "mid": v}


static func _pitch_value_hint() -> String:
	# Satış-gated value range for the pricing stage (E.1/E.2). Below threshold the
	# precise range is hidden — the player offers blind (mirrors the budget_band gate).
	if not SkillCheck.can_read_prospect():
		return "Bütçesini kestiremiyorsun — körlemesine teklif vereceksin."
	var win: Dictionary = _price_mult_window()
	var band: Dictionary = CustomerArchetypes.mrr_band(_prospect.archetype)
	var lo_mo: int = int(round(lerpf(float(band["low"]), float(band["high"]), win["lo"])))
	var hi_mo: int = int(round(lerpf(float(band["low"]), float(band["high"]), win["hi"])))
	var seats: int = SalesSystem._seats_for_archetype(_prospect.archetype)
	var per_lo: int = int(round(float(lo_mo) / maxf(1.0, float(seats))))
	var per_hi: int = int(round(float(hi_mo) / maxf(1.0, float(seats))))
	return "Satış okuması — %d seat. Ürün değerin bu segmentte seat başına ~$%d-%d → ~$%d-%d/ay. Bu aralıkta oyna." \
		% [seats, per_lo, per_hi, lo_mo, hi_mo]


# --- Pitch lifecycle ---

static func is_active() -> bool:
	return _active


static func reset() -> void:
	# Run-boundary reset (SaveManager.reset_all_owners). MEETING-LOCAL STATE IS RESET, NEVER
	# SERIALISED — and the save gate is what makes that honest rather than a carve-out:
	# SaveManager.can_save() refuses while is_active(), so a pitch is provably idle at every
	# save point and there is nothing mid-sitting for a schema to describe. A pitch is one
	# sitting; it does not survive closing the game, and it must not survive the company.
	_active = false
	_prospect = null
	_stage_idx = 0
	_accum_bonus = 0
	_price_mult = 0.55
	_close_diff_delta = 0
	_last_band = ""


static func can_pitch() -> bool:
	return GameState.day >= int(GameState.get_flag("next_pitch_day", 0))


static func begin(prospect_id: String) -> bool:
	var p: Prospect = ProspectRegistry.get_prospect(prospect_id)
	if p == null:
		push_warning("[PitchSystem] begin: unknown prospect %s" % prospect_id)
		return false
	_active = true
	_prospect = p
	_stage_idx = 0
	_accum_bonus = 0
	_price_mult = 0.55
	_close_diff_delta = 0
	_last_band = ""
	return true


static func get_stage() -> Dictionary:
	# Returns the renderable current stage (text + choices + dynamic lines).
	if not _active:
		return {}
	match _stage_idx:
		0:
			var reveal := ""
			if SkillCheck.can_read_prospect():
				reveal = "Satış okuması — bütçe: %s. %s" % [_prospect.budget_band, _prospect.real_need]
			return {
				"id": "intro",
				"speaker": "%s · %s" % [_prospect.company_name, _prospect.industry],
				"npc": "« Frank iyi şeyler söyledi. Göster bakalım — neyi farklı yapıyorsun? »",
				"inner": "İlk on saniye. Adam zaten Frank'e güveniyor; kapı aralık. Mesele kapıyı nasıl açtığım.",
				"reveal": reveal,
				"choices": [
					{"label": "Sıcak başla — önce onu dinle", "bonus": 1},
					{"label": "Direkt ürüne gir", "bonus": 0},
					{"label": "Kendinden emin gir — 'bunu görmen lazım'", "bonus": 1},
				],
			}
		1:
			return {
				"id": "value",
				"speaker": "%s · %s" % [_prospect.company_name, _prospect.industry],
				"npc": "« Bizde zaten bir sistem var. Seninki ne ekliyor? »",
				"inner": "Klasik itiraz: 'zaten bir şeyimiz var.' Çerçeveyi cevabım belirler.",
				"reveal": "",
				"choices": [
					{"label": "Dürüst ol — taze ama derdine birebir", "skill": "sales", "diff": VALUE_BASE_DIFFICULTY},
					{"label": "Vizyon sat — nereye gittiğimizi anlat", "skill": "influence", "diff": VALUE_BASE_DIFFICULTY + 1},
					{"label": "Onun derdine odaklan, dilinden konuş", "skill": "sales", "diff": VALUE_BASE_DIFFICULTY - 1},
				],
			}
		2:
			var hint := _pitch_value_hint()
			return {
				"id": "pricing",
				"speaker": "%s · %s" % [_prospect.company_name, _prospect.industry],
				"npc": "« Tamam, ilgimi çektin. Rakam konuşalım. »",
				"inner": "İşin döndüğü yer. Yüksek tutarsam ya kaparım ya kaçar; düşük tutarsam garanti ama masada para bırakırım. %s" % hint,
				"reveal": "",
				"choices": [
					{"label": "Yüksek çıpa at — değerine güven", "price_mult": 1.0, "close_diff": 2},
					{"label": "Adil fiyat — orta nokta", "price_mult": 0.55, "close_diff": 0},
					{"label": "Güvenli fiyat — anlaşmayı garantile", "price_mult": 0.2, "close_diff": -1},
				],
			}
		_:
			var band_line := _band_flavor(_last_band)
			return {
				"id": "close",
				"speaker": "%s · %s" % [_prospect.company_name, _prospect.industry],
				"npc": "« Bir düşüneyim... yoksa hemen mi karar versem? »",
				"inner": "Son viraj. Geri çekilirsem kaçar; itersem ya imza ya kapı. %s" % band_line,
				"reveal": "",
				"choices": [
					{"label": "Nazikçe ama kararlı kapat", "skill": "sales", "diff": CLOSE_BASE_DIFFICULTY, "mrr_mult": 1.0},
					{"label": "Bir taviz ver, güven inşa et", "skill": "sales", "diff": CLOSE_BASE_DIFFICULTY - 1, "mrr_mult": 0.9},
					{"label": "Sert kapat — 'bugün karar ver'", "skill": "sales", "diff": CLOSE_BASE_DIFFICULTY + 1, "mrr_mult": 1.1},
				],
			}


static func choose(idx: int) -> Dictionary:
	# Applies the chosen option's mechanics, advances, and returns either
	# {"done": false, "check": <optional skillcheck result>} or
	# {"done": true, "result": {...}}.
	if not _active:
		return {"done": true, "result": {"outcome": "LOST"}}
	var stage: Dictionary = get_stage()
	var choices: Array = stage.get("choices", [])
	if idx < 0 or idx >= choices.size():
		return {"done": false}
	var c: Dictionary = choices[idx]
	var out: Dictionary = {"done": false}

	match stage.get("id", ""):
		"intro":
			_accum_bonus += int(c.get("bonus", 0))
		"value":
			var chk: Dictionary = SkillCheck.resolve(String(c.get("skill", "sales")), int(c.get("diff", 1)), _accum_bonus)
			_last_band = String(chk.get("band", ""))
			_accum_bonus += 2 if chk.get("passed", false) else -1
			out["check"] = chk
		"pricing":
			_price_mult = float(c.get("price_mult", 0.55))
			_close_diff_delta = int(c.get("close_diff", 0))
			# Value-range modifier (E.3): above the value window the prospect balks
			# (harder close); below is an easy close but low MRR (low MRR already
			# falls out of the band lerp in _resolve_outcome).
			var win: Dictionary = _price_mult_window()
			if _price_mult > win["hi"]:
				_close_diff_delta += 1
			elif _price_mult < win["lo"]:
				_close_diff_delta -= 1
		"close":
			var chk2: Dictionary = SkillCheck.resolve("sales",
				CLOSE_BASE_DIFFICULTY + _close_diff_delta + _prospect.difficulty_stars - 1,
					_accum_bonus + SalesRepSystem.warm_bonus_for(_prospect))
				# The sales desk's groundwork rides the EXISTING bonus channel. SkillCheck stays
				# founder-only and that is correct: the founder is the one in the room, the rep
				# warmed the lead up to the door.
			var mrr_mult: float = float(c.get("mrr_mult", 1.0))
			out = {"done": true, "result": _resolve_outcome(chk2, mrr_mult)}
			return out

	_stage_idx += 1
	return out


static func signing_satisfaction_seed() -> int:
	# A signed B2B account's initial satisfaction: Stability + Experience (reliability + ease —
	# what a business buyer feels on day one), off effective stability. Extracted from
	# _resolve_outcome so SalesRepSystem's autonomous close seeds an account IDENTICALLY to a
	# played pitch; two copies of this expression would silently drift apart.
	var dims: Dictionary = QualityModel.economy_dims_from_flags()
	return int(round(
		(QualityModel.axis_score(dims, "stability") + QualityModel.axis_score(dims, "experience")) * 0.5))


static func _resolve_outcome(chk: Dictionary, mrr_mult: float) -> Dictionary:
	var band: String = String(chk.get("band", "fail"))
	var quality_seed: int = signing_satisfaction_seed()
	# Cooldown applies regardless of outcome.
	GameState.set_flag("next_pitch_day", GameState.day + PITCH_COOLDOWN_DAYS)

	var outcome := "LOST"
	if band == "crit_success" or band == "success":
		outcome = "SIGNED"
	elif band == "near_pass":
		outcome = "SIGNED"
		mrr_mult *= 0.85  # negotiated down a touch
	elif band == "near_miss":
		outcome = "CALLBACK"
	else:
		outcome = "LOST"

	var result := {"outcome": outcome, "band": band, "company": _prospect.company_name, "check": chk}

	if outcome == "SIGNED":
		var bandvals: Dictionary = CustomerArchetypes.mrr_band(_prospect.archetype)
		var target: float = lerpf(float(bandvals["low"]), float(bandvals["high"]), clampf(_price_mult, 0.0, 1.0))
		var mrr: int = int(round(target * mrr_mult))
		var satisfaction: int = clampi(quality_seed + (5 if band == "crit_success" else 0), 0, 100)
		var cust: Customer = SalesSystem.add_b2b_customer(_prospect, mrr, satisfaction)
		ProspectRegistry.remove(_prospect.id)
		result["mrr"] = mrr
		result["customer_id"] = cust.id
	elif outcome == "LOST":
		ProspectRegistry.remove(_prospect.id)
	# CALLBACK: prospect stays in the pool for a retry after cooldown.

	_active = false
	_prospect = null
	return result


static func _band_flavor(band: String) -> String:
	match band:
		"crit_success": return "Az önce onu tam yakaladın — havada bir güven var."
		"success": return "İyi gitti, beni ciddiye alıyor."
		"near_pass": return "İkna oldu ama tam değil; pürüz kaldı."
		"near_miss": return "Tereddüt ediyor. Az kalsın."
		"fail", "crit_fail": return "Çuvalladım galiba. Toparlamam lazım."
		_: return ""
