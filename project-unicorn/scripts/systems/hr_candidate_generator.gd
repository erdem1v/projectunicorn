class_name HRCandidateGenerator
extends RefCounted

# Atlas aday dosyası üretici (§10.2) — a PURE function of (role, level, seed).
#
# HRSearchSystem calls generate() once, on the day the files arrive, with the seed it stored
# when the search was commissioned — so the same three people are on the table after a reload.
# This file writes nothing; its only reads outside HRConstants are in seed_for().
#
# THE MECHANIC IS NON-DOMINANCE: no file may be better-or-equal on every axis AND
# cheaper-or-equal than another, or the choice stops being a choice. is_non_dominated_set() is
# the post-condition of generate(). It is deliberately shape-agnostic (no equal totals, no
# strict argmax), so the archetype shapes can move in the balance pass without rewriting it.
#
# NO RNG: every varying field is integer arithmetic on the seed. Same seed must produce
# byte-identical files forever, and drawing from the global stream here would displace the
# draws that events and the resignation roll consume.
#
# Candidate file shape (plain Dictionary):
#   {"name": String, "role": String, "level": int, "archetype": String,
#    "axes": {altı alan + leadership},   # HRConstants.EMPLOYEE_SKILL_KEYS, her biri 0..AREA_MAX
#    "salary": int, "traits": Array[String], "note_index": int}


# --- Deterministic mixer (arithmetic, NOT tunables) ---
# _mix folds a per-field salt into the seed so the draws never move in lockstep (a single
# `seed % pool.size()` would tie the surname to the first name). MINSTD's multiplier over a
# prime modulus, sized so every intermediate product stays well inside 64-bit.
const MIX_MODULUS := 1000003
const MIX_MULTIPLIER := 48271
const MIX_INCREMENT := 12345
const MIX_SALT_STRIDE := 7919

# Per-field salts, distinct so no two fields share a draw. CANDIDATE_STRIDE separates
# candidate k's block of draws from candidate k+1's.
const SALT_FIRST_NAME := 11
const SALT_LAST_NAME := 23
const SALT_NOTE := 37
const SALT_POSITIVE_PICK := 71
const SALT_NEGATIVE_COUNT := 89
const SALT_NEGATIVE_PICK := 113
const SALT_CANDIDATE_STRIDE := 131
# §10.2'nin üç arama-başına çekimi: fiyat çapası, üçlünün fiyat farkı, ve tepe dosya.
const SALT_ANCHOR := 149
const SALT_SPREAD := 167
const SALT_FIVE_STAR := 181

# seed_for's weights, with role and level folded in so two searches on the same day for
# different roles do not return the same three people with different job titles.
const SEED_DAY_STRIDE := 7
const SEED_HIRES_STRIDE := 13
const SEED_ROLE_STRIDE := 101
const SEED_LEVEL_STRIDE := 17

# Kesirli olasılıkları tamsayı aritmetiğine çevirme çözünürlüğü.
const CHANCE_RESOLUTION := 1000

# Salaries are quoted to a $50 step. _salary_trio works IN this step, so the tightest junior
# window still holds three distinct quotes.
const SALARY_ROUND_TO := 50


static func generate(role_id: String, level: int, seed_value: int) -> Array:
	var files: Array = []
	if not HRConstants.is_employee_role(role_id):
		push_warning("[HRCandidateGenerator] generate for non-employee role '%s'" % role_id)
	if not HRConstants.is_level(level):
		push_error("[HRCandidateGenerator] generate for unknown level %d" % level)
		return files

	# THE TOP FILE, drawn per search (§10.2, Satış §11.7): one file — the Uzman, whose peak is
	# already his archetype — reaches the role's ceiling and asks the band's top.
	var top_file: bool = _rolls(seed_value, SALT_FIVE_STAR,
		HRConstants.role_top_chance(role_id, level))
	# Prices are a property of the SET (§10.2 "fark en düşük ile en yüksek arasında %20–45").
	var quotes: Dictionary = _salary_trio(role_id, level, seed_value, top_file)

	# One shared list per pool so nothing repeats across the three files.
	var used_first: Array = []
	var used_last: Array = []
	var used_notes: Array = []
	var used_traits: Array = []

	for k in range(HRConstants.CANDIDATE_COUNT):
		var salt: int = SALT_CANDIDATE_STRIDE * k
		# Aday k = arketip k: üçlü sabittir (§10.2), çekim yok.
		var archetype: String = String(HRConstants.ARCHETYPES[k % HRConstants.ARCHETYPES.size()])
		var first_name: String = _take_unused(HRConstants.FIRST_NAMES, used_first,
			_mix(seed_value, SALT_FIRST_NAME + salt))
		var last_name: String = _take_unused(HRConstants.LAST_NAMES, used_last,
			_mix(seed_value, SALT_LAST_NAME + salt))
		files.append({
			"name": ("%s %s" % [first_name, last_name]).strip_edges(),
			"role": role_id,
			"level": level,
			"archetype": archetype,
			"axes": _skills_for(role_id, level, archetype, k,
				top_file and archetype == HRConstants.ARCHETYPE_UZMAN),
			"salary": int(quotes[archetype]),
			"traits": _pick_traits(seed_value, k, _wants_cost_trait(seed_value, archetype),
				used_traits, role_id),
			# The INDEX is stored, never the sentence: a stored sentence would freeze one
			# language into state.
			"note_index": _take_unused(range(HRConstants.FILE_NOTES_COUNT), used_notes,
				_mix(seed_value, SALT_NOTE + salt)),
		})

	# §10.2: "Hiçbir aday bir diğerini bütün eksenlerde yenemez. ÜRETİMDEN SONRA KONTROL EDİLİR."
	# The files are still returned so a broken constant surfaces as a loud log, not an empty tab.
	if not is_non_dominated_set(files):
		push_error("[HRCandidateGenerator] dominated file in the generated set (role '%s', level %d, seed %d): %s — see HRConstants.ARCHETYPE_SHAPE"
			% [role_id, level, seed_value, str(files)])
	return files


static func is_non_dominated_set(files: Array) -> bool:
	# Paired by INDEX, not by value: two identical files DO dominate each other, which is
	# precisely the case this predicate must catch.
	for i in range(files.size()):
		for j in range(files.size()):
			if i != j and _dominates(files[i], files[j]):
				return false
	return true


static func seed_for(role_id: String, level: int) -> int:
	# Derived from run state, never from Time or randi. Two searches with the same inputs
	# cannot coexist (one search at a time), and by the second either day or run_hires moved.
	var role_index: int = HRConstants.EMPLOYEE_ROLES.find(role_id) + 1
	return SEED_DAY_STRIDE * GameState.day \
		+ SEED_HIRES_STRIDE * GameState.run_hires \
		+ SEED_ROLE_STRIDE * role_index \
		+ SEED_LEVEL_STRIDE * (clampi(level, HRConstants.LEVEL_JUNIOR, HRConstants.LEVEL_SENIOR) + 1)


static func _skills_for(role_id: String, level: int, archetype: String, rotation: int,
		top_file: bool) -> Dictionary:
	# The shape is read by MEANING: [key area, secondary area, every other area]. The peak is
	# pinned to the key area so a designer never gets his peak in Satış.
	# Candidate k gets +1 on the k'th off-role area so the three files differ qualitatively; it
	# only ADDS, so it cannot introduce a domination the shapes did not already have.
	# Built by walking AREAS so the result holds exactly the ruler keys (registry key-lock).
	var shape: Array = HRConstants.archetype_shape(level, archetype, role_id)
	var key_area: String = HRConstants.role_key_area(role_id)
	var secondary: String = HRConstants.role_secondary_area(role_id)
	var out: Dictionary = {}
	var others: Array[String] = []
	for area_key in HRConstants.AREAS:
		var a: String = String(area_key)
		if a == key_area:
			out[a] = int(shape[0])
		elif a == secondary:
			out[a] = int(shape[1])
		else:
			out[a] = int(shape[2])
			others.append(a)
	var bumped: String = others[rotation % others.size()]
	out[bumped] = mini(int(out[bumped]) + 1, HRConstants.AREA_MAX)
	# Liderlik seviyeden okunur, arketipin "diğer alanlar" değerinden değil (gerekçe
	# HRConstants.archetype_leadership'te).
	out[HRConstants.SKILL_LEADERSHIP] = HRConstants.archetype_leadership(level, archetype)
	if top_file:
		# Written after the rotation bump so the ceiling is exact; the ceiling itself is the
		# role's and the level's (§11.7).
		out[key_area] = HRConstants.role_top_value(role_id, level)
	return out


static func _salary_trio(role_id: String, level: int, seed_value: int, top_file: bool) -> Dictionary:
	# §10.2: Pazarlık en düşük, Dengeli en yüksek, Uzman "orta–yüksek"; fark %20–45.
	# Arithmetic is done IN the rounding step, so the measured spread stays inside %20–45 —
	# drawing the ratio first and rounding after could push it outside.
	var band: Array = HRConstants.salary_band_for_level(role_id, level)
	var band_low: int = int(band[0])
	var band_high: int = int(band[1])

	var low: int = band_low
	if top_file:
		# The Uzman asks the band CEILING, so the anchor must sit high enough that the ceiling
		# is still inside the %45 spread (every band's high/low is 1.5 > 1.45).
		low = maxi(_ceil_to(float(band_high) / (1.0 + HRConstants.SALARY_SPREAD_MAX_R11)), band_low)
	else:
		# Shifted off the floor by the seed, but only as far as the narrowest spread still fits.
		var low_max: int = maxi(_floor_to(float(band_high) / (1.0 + HRConstants.SALARY_SPREAD_MIN_R11)), band_low)
		var steps_low: int = (low_max - band_low) / SALARY_ROUND_TO
		low += SALARY_ROUND_TO * (_mix(seed_value, SALT_ANCHOR) % (steps_low + 1))

	var high_min: int = _ceil_to(float(low) * (1.0 + HRConstants.SALARY_SPREAD_MIN_R11))
	var high_max: int = maxi(mini(
		_floor_to(float(low) * (1.0 + HRConstants.SALARY_SPREAD_MAX_R11)),
		_floor_to(float(band_high))), high_min)
	var steps_high: int = (high_max - high_min) / SALARY_ROUND_TO
	var high: int = high_min + SALARY_ROUND_TO * (_mix(seed_value, SALT_SPREAD) % (steps_high + 1))

	# Uzman aradadır; en dar hâlde bile boşluk yuvarlama adımından büyük, üç teklif çakışmaz.
	var mid: int = clampi(
		_round_to(float(low) + float(high - low) * HRConstants.ARCHETYPE_PRICE_UZMAN_SHARE),
		low, high)
	if top_file:
		# §10.2's named exception: the top file is priced at the band ceiling.
		mid = band_high
	return {
		HRConstants.ARCHETYPE_PAZARLIK: low,
		HRConstants.ARCHETYPE_UZMAN: mid,
		HRConstants.ARCHETYPE_DENGELI: high,
	}


static func _wants_cost_trait(seed_value: int, archetype: String) -> bool:
	# §10.2 huy rolü: Pazarlık her zaman bedelli (TRIO_COST_TRAIT_MIN'i garantileyen tek yol),
	# Uzman seed'e bağlı yazı-tura, Dengeli hep bedelsiz.
	match archetype:
		HRConstants.ARCHETYPE_PAZARLIK:
			return true
		HRConstants.ARCHETYPE_UZMAN:
			return _rolls(seed_value, SALT_NEGATIVE_COUNT, HRConstants.UZMAN_COST_TRAIT_CHANCE)
	return false


static func _pick_traits(seed_value: int, index: int, wants_cost: bool, used: Array,
		role_id: String) -> Array[String]:
	# Tek trait: işaretli dosyanınki bedelli havuzdan, diğerlerininki bedelsiz havuzdan.
	# `used` iki havuzda paylaşılır; en dar havuz (bedelsiz) üç dosyaya hâlâ yeter.
	var pool: Array = HRConstants.cost_trait_ids(role_id) if wants_cost \
		else HRConstants.free_trait_ids(role_id)
	var salt: int = (SALT_NEGATIVE_PICK if wants_cost else SALT_POSITIVE_PICK) \
		+ SALT_CANDIDATE_STRIDE * index
	var traits: Array[String] = []
	var picked: String = str(_take_unused(pool, used, _mix(seed_value, salt)))
	if picked != "":
		traits.append(picked)
	return traits


static func _mix(seed_value: int, salt: int) -> int:
	# Non-negative by construction so `% pool.size()` never indexes backwards.
	var n: int = (absi(seed_value) % MIX_MODULUS) + MIX_SALT_STRIDE * (absi(salt) % MIX_MODULUS)
	n = (n % MIX_MODULUS) * MIX_MULTIPLIER + MIX_INCREMENT
	return n % MIX_MODULUS


static func _rolls(seed_value: int, salt: int, chance: float) -> bool:
	var threshold: int = int(round(clampf(chance, 0.0, 1.0) * float(CHANCE_RESOLUTION)))
	return _mix(seed_value, salt) % CHANCE_RESOLUTION < threshold


static func _take_unused(pool: Array, used: Array, draw: int) -> Variant:
	# pool[draw % size], then a deterministic forward walk past anything the batch already
	# took (a retry would need randomness). An exhausted pool returns "".
	for step in range(pool.size()):
		var entry: Variant = pool[(draw + step) % pool.size()]
		if not used.has(entry):
			used.append(entry)
			return entry
	return ""


static func _dominates(a: Dictionary, b: Dictionary) -> bool:
	# Missing keys read as the ruler floor so a malformed hand-built file stays loud rather
	# than crashing the predicate.
	var a_axes: Dictionary = a.get("axes", {})
	var b_axes: Dictionary = b.get("axes", {})
	for axis_key in HRConstants.EMPLOYEE_SKILL_KEYS:
		if int(a_axes.get(axis_key, HRConstants.AREA_MIN)) < int(b_axes.get(axis_key, HRConstants.AREA_MIN)):
			return false
	return int(a.get("salary", 0)) <= int(b.get("salary", 0))


static func _round_to(value: float) -> int:
	return int(round(value / SALARY_ROUND_TO)) * SALARY_ROUND_TO


static func _ceil_to(value: float) -> int:
	return int(ceil(value / SALARY_ROUND_TO)) * SALARY_ROUND_TO


static func _floor_to(value: float) -> int:
	return int(floor(value / SALARY_ROUND_TO)) * SALARY_ROUND_TO
