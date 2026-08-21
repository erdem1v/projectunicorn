class_name HRCandidateGenerator
extends RefCounted

# Atlas aday dosyası üretici (HR design doc §3) — a PURE function of (role, band, seed).
#
# No dispatch slot: nothing ticks this file. HRSearchSystem calls generate() exactly once, on
# the day the files arrive, with the seed it stored when the search was commissioned — which is
# why the same three people are on the table tomorrow, after a reload, and in every process.
#
# Owns: the candidate file shape, the off-role rotation, the salary placement in the band, the
# trait cross-distribution, and THE invariant (is_non_dominated_set). Owns no tunable — every
# number that means anything comes from HRConstants. The consts below are the deterministic
# mixer's arithmetic (moduli, per-field salts, the quote-rounding step); they carry no balance
# meaning, which is exactly why they are not knobs in HRConstants.
#
# WRITE-THROUGH LAW: this file writes NOTHING. No registry, no GameState field, no signal, no
# cash, no static state. Its only reads outside HRConstants are GameState.day and
# GameState.run_hires inside seed_for(), and the whole rest of the file is a function of what
# the caller hands it.
#
# THE MECHANIC IS NON-DOMINANCE. Three files, and no file may be better-or-equal on all three
# axes AND cheaper-or-equal than another. The moment one file dominates, the choice stops being
# a choice and the arayış is a formality with an extra click. So it is not a comment: it is
# is_non_dominated_set(), called as a post-condition of generate() and asserted over 100+
# generations in the smoke suite. The predicate is deliberately SHAPE-AGNOSTIC — it never
# asserts equal totals and never asserts a distinct strict argmax — which is why the mixed
# BAND_SHAPE profiles (strictly increasing totals per band) landed without rewriting it:
# rising totals force rising quotes, and a pricier file can never dominate on price.
#
# NO RNG. AT ALL. No randi/randf/RandomNumberGenerator/shuffle/pick_random, no Time: every
# varying field is pure integer arithmetic on the seed, then pool[n % pool.size()] — the house
# pattern from PitchSystem.spawn_prospect and B2BSalesSystem.pick_pain_feature. Two reasons,
# both load-bearing. Same seed must produce byte-identical files forever (a save/load must not
# reshuffle the files already on the player's desk), and drawing from the global RNG stream
# here would displace the draws that events and the resignation roll consume.
#
# Candidate file shape (plain Dictionary — transient data, no Resource):
#   {"name": String, "role": String, "band": String,
#    "axes": {altı alan + leadership},   # HRConstants.EMPLOYEE_SKILL_KEYS, her biri 0..AREA_MAX
#    "salary": int, "traits": Array[String], "note_index": int}


# --- Deterministic mixer (arithmetic, NOT tunables) ---
# One seed has to fan out into a dozen independent draws: name, surname, note, how many good
# traits, which ones, who carries the bad one. _mix folds a per-field salt into the seed so
# those draws never move in lockstep (a single `seed % pool.size()` would tie the surname to
# the first name for every seed). MINSTD's multiplier over a prime modulus, sized so every
# intermediate product stays orders of magnitude inside 64-bit.
const MIX_MODULUS := 1000003
const MIX_MULTIPLIER := 48271
const MIX_INCREMENT := 12345
const MIX_SALT_STRIDE := 7919

# Per-field salts, distinct so no two fields of one candidate share a draw. CANDIDATE_STRIDE
# separates candidate k's whole block of draws from candidate k+1's.
const SALT_FIRST_NAME := 11
const SALT_LAST_NAME := 23
const SALT_NOTE := 37
const SALT_POSITIVE_COUNT := 53
const SALT_POSITIVE_PICK := 71
const SALT_NEGATIVE_COUNT := 89
const SALT_NEGATIVE_WHICH := 101
const SALT_NEGATIVE_PICK := 113
const SALT_CANDIDATE_STRIDE := 131

# seed_for's weights — spawn_prospect's `day * 7 + count * 13` shape, with role and band folded
# in so two searches commissioned on the same day for different roles do not return the same
# three people with different job titles.
const SEED_DAY_STRIDE := 7
const SEED_HIRES_STRIDE := 13
const SEED_ROLE_STRIDE := 101
const SEED_BAND_STRIDE := 17

# Fractional-share resolution. TRAIT_COST_SHARE × CANDIDATE_COUNT is 1.5 people and half a
# person cannot carry a trait, so the remainder becomes a per-search draw in percent: some
# searches bring one bad trait, some bring two, and the SHARE holds across searches instead of
# being silently rounded into a fixed number.
const TRAIT_SHARE_RESOLUTION := 100

# Salaries are quoted to a $50 step — nobody asks for $9.873 a month. Presentation
# granularity, not a knob: at $100 the tightest junior window cannot hold three distinct
# quotes (BAND_SHAPE's gap rule needs window_low·PREMIUM·Δ(peak+total)/36 >= this step).
const SALARY_ROUND_TO := 50


# --- Public surface ---

static func generate(role_id: String, band_id: String, seed_value: int) -> Array:
	var files: Array = []
	if not HRConstants.is_employee_role(role_id):
		push_warning("[HRCandidateGenerator] generate for non-employee role '%s' — see HRConstants.EMPLOYEE_ROLES" % role_id)
	if HRConstants.band_shape(band_id, 0).is_empty():
		push_error("[HRCandidateGenerator] band_shape('%s') is empty — see HRConstants.BAND_SHAPE" % band_id)
		return files

	# Who carries a bad trait is decided for the WHOLE batch first: TRAIT_COST_SHARE is a
	# property of the set, not of one file, and the trait pools have to be reserved before the
	# per-file loop starts spending them.
	var carries_negative: Array = _cost_carriers(seed_value)
	# Cross-distribution bookkeeping. One shared list per pool so nothing repeats across the
	# three files: two Kerems or two "Cam kalp"s in one batch reads as a generator bug, and the
	# trait no-repeat rule is explicit in the design (design doc §3).
	var used_first: Array = []
	var used_last: Array = []
	var used_notes: Array = []
	var used_traits: Array = []

	for k in range(HRConstants.CANDIDATE_COUNT):
		var salt: int = SALT_CANDIDATE_STRIDE * k
		# Candidate k = profile k of the band (cheapest first). The peak is PINNED to the
		# role's key area; what rotates is which of the four off-role areas gets the +1.
		var axes: Dictionary = _skills_for(role_id, HRConstants.band_shape(band_id, k), k)
		if not HRConstants.validate_employee_skills(axes):
			push_error("[HRCandidateGenerator] generated skills are not the employee shape: %s" % str(axes))
		var first_name: String = _take_unused(HRConstants.FIRST_NAMES, used_first,
			_mix(seed_value, SALT_FIRST_NAME + salt) % maxi(HRConstants.FIRST_NAMES.size(), 1))
		var last_name: String = _take_unused(HRConstants.LAST_NAMES, used_last,
			_mix(seed_value, SALT_LAST_NAME + salt) % maxi(HRConstants.LAST_NAMES.size(), 1))
		files.append({
			"name": ("%s %s" % [first_name, last_name]).strip_edges(),
			"role": role_id,
			"band": band_id,
			"axes": axes,
			"salary": _salary_for(role_id, band_id, HRConstants.band_shape(band_id, k)),
			"traits": _pick_traits(seed_value, k, bool(carries_negative[k]), used_traits),
			# The INDEX is stored, never the sentence. A candidate file is state, and a
			# stored sentence would freeze one language into it — the same rule that moved
			# the B2C user-base name out of Customer.company_name.
			"note_index": _take_unused_index(used_notes,
				_mix(seed_value, SALT_NOTE + salt) % maxi(HRConstants.FILE_NOTES_COUNT, 1)),
		})

	# THE post-condition. Not a warning: a dominated file kills the mechanic, so it has to be
	# loud in every log the moment a shape change introduces one. The files are still returned
	# (the same non-blocking grammar as CharacterRegistry._validate_shape) so a broken constant
	# surfaces as a screaming log rather than an empty HR tab nobody can diagnose.
	if not is_non_dominated_set(files):
		push_error("[HRCandidateGenerator] dominated file in the generated set (role '%s', band '%s', seed %d): %s — see HRConstants.BAND_SHAPE"
			% [role_id, band_id, seed_value, str(files)])
	return files


static func is_non_dominated_set(files: Array) -> bool:
	# The invariant VERBATIM, price included: for every ordered pair, NOT (A >= B on all three
	# axes AND A.salary <= B.salary). Deliberately shape-agnostic — it assumes neither equal
	# totals nor a distinct strict argmax, so BAND_SHAPE's profile mix can keep evolving in
	# the balance pass without any test being rewritten.
	#
	# Paired by INDEX, not by value: `a != b` on two Dictionaries is an equality question with
	# its own semantics, and two files that happen to be identical DO dominate each other,
	# which is precisely the case this predicate must catch rather than skip.
	for i in range(files.size()):
		for j in range(files.size()):
			if i == j:
				continue
			if _dominates(files[i], files[j]):
				return false
	return true


static func seed_for(role_id: String, band_id: String) -> int:
	# Derived from run state, never from Time and never from randi: the day the search was
	# commissioned, how many people have been hired so far, and which role/band was asked for.
	# Two searches on the same day for the same role/band would repeat — but they cannot
	# coexist (one search at a time), and by the time the second one starts either the day or
	# run_hires has moved.
	var role_index: int = maxi(HRConstants.EMPLOYEE_ROLES.find(role_id) + 1, 0)
	var band_index: int = maxi(HRConstants.BANDS.find(band_id) + 1, 0)
	return SEED_DAY_STRIDE * GameState.day \
		+ SEED_HIRES_STRIDE * GameState.run_hires \
		+ SEED_ROLE_STRIDE * role_index \
		+ SEED_BAND_STRIDE * band_index


# --- Skills: the band shape read by MEANING, with a rotating off-role bump ---

static func _skills_for(role_id: String, shape: Array, rotation: int) -> Dictionary:
	# THE SHAPE IS READ BY MEANING, NOT BY POSITION (2026-08-21, GDD v2 ch. 07 rev 2).
	#   shape[0] -> the role's KEY area        (ROLE_AREAS[role].key)
	#   shape[1] -> the role's SECONDARY area  (ROLE_AREAS[role].secondary)
	#   shape[2] -> every OTHER area
	# Until rev 2 this walked the three axis keys and rotated them, so each file's peak landed
	# on a different axis. With six areas that same rotation would hand a Tasarımcı his peak
	# in Satış — a candidate whose title and numbers disagree. The peak is pinned instead.
	#
	# What rotation still buys, and why it is kept: the three files must differ QUALITATIVELY,
	# not only in price. Candidate k gets +1 on the k'th off-role area, so one developer knows
	# a little Ürün and the next a little Müşteri Başarısı. That is also the texture rev 2 §2
	# asks for when it promises "tek kişilik ekipte boşluk kalmaz".
	#
	# NON-DOMINANCE SURVIVES, and for the same reason as before: BAND_SHAPE profiles have
	# strictly increasing totals and quotes strictly increase with them, so a pricier file can
	# never undercut a cheaper one, and a cheaper file is strictly lower on the key area. The
	# +1 bump cannot break it either — it is +1 on both sides of every comparison at most once.
	# generate()'s post-condition still says so out loud.
	#
	# Built by walking AREAS (not the shape) so the result always holds EXACTLY the ruler keys
	# and passes the CharacterRegistry key-lock, whatever length a future BAND_SHAPE entry has.
	var out: Dictionary = {}
	var key_area: String = HRConstants.role_key_area(role_id)
	var secondary: String = HRConstants.role_secondary_area(role_id)
	var key_v: int = int(shape[0]) if shape.size() > 0 else HRConstants.AREA_MIN
	var sec_v: int = int(shape[1]) if shape.size() > 1 else key_v
	var rest_v: int = int(shape[2]) if shape.size() > 2 else sec_v
	var others: Array[String] = []
	for area_key in HRConstants.AREAS:
		var a: String = String(area_key)
		if a == key_area:
			out[a] = clampi(key_v, HRConstants.AREA_MIN, HRConstants.AREA_MAX)
		elif a == secondary:
			out[a] = clampi(sec_v, HRConstants.AREA_MIN, HRConstants.AREA_MAX)
		else:
			out[a] = clampi(rest_v, HRConstants.AREA_MIN, HRConstants.AREA_MAX)
			others.append(a)
	if not others.is_empty():
		var bumped: String = others[rotation % others.size()]
		out[bumped] = clampi(int(out[bumped]) + 1, HRConstants.AREA_MIN, HRConstants.AREA_MAX)
	# Liderlik is drawn from the shape's floor, not from the role: rev 2 §2 puts it on
	# everyone, and a candidate who happens to lead well is a find, not a job description.
	# Rotation gives the three files different leadership so "kimi sorumlu yapacağım" has
	# something to chew on from the first hire.
	out[HRConstants.SKILL_LEADERSHIP] = clampi(rest_v - 1 + rotation,
		HRConstants.AREA_MIN, HRConstants.AREA_MAX)
	return out


# --- Salary: a narrow window inside the role/band, priced off the profile ---

static func _salary_for(role_id: String, band_id: String, shape: Array) -> int:
	var window: Array = _salary_window(role_id, band_id)
	var window_low: int = int(window[0])
	var window_high: int = int(window[1])
	var asked: int = _round_to(float(window_low) * (1.0 + _shape_premium(shape)), SALARY_ROUND_TO)
	return clampi(asked, window_low, window_high)


static func _salary_window(role_id: String, band_id: String) -> Array:
	# Two rules pull against each other: every file sits inside HRConstants.salary_band(), and
	# the three quotes stay within SALARY_SPREAD_MAX of each other. A band is far wider than
	# that spread (developer/mid is $8-12K, 50% apart), so the files occupy a narrow WINDOW cut
	# out of the band — centred in it, so the quotes read like the tier the player paid for
	# instead of hugging its floor. Centring only shrinks the max/min ratio, so the spread rule
	# holds by construction rather than by luck.
	var band: Array = HRConstants.salary_band(role_id, band_id)
	if band.size() < 2:
		push_error("[HRCandidateGenerator] salary_band('%s', '%s') is not a [low, high] pair: %s — see HRConstants.SALARY_BANDS"
			% [role_id, band_id, str(band)])
		return [0, 0]
	var band_low: int = mini(int(band[0]), int(band[1]))
	var band_high: int = maxi(int(band[0]), int(band[1]))
	# Widest window the spread rule allows, anchored at the band floor and clipped by the band.
	var width: int = maxi(0, mini(band_high, int(floor(float(band_low) * (1.0 + HRConstants.SALARY_SPREAD_MAX)))) - band_low)
	var centred_low: int = band_low + int(floor(float(band_high - band_low - width) / 2.0))
	# Rounded INWARD to the quote granularity so both bounds stay legal, then clamped to the
	# band so even a pathological SALARY_BANDS row cannot produce an out-of-band quote.
	var window_low: int = clampi(_ceil_to(float(centred_low), SALARY_ROUND_TO), band_low, band_high)
	var window_high: int = clampi(_floor_to(float(centred_low + width), SALARY_ROUND_TO), window_low, band_high)
	return [window_low, window_high]


static func _shape_premium(shape: Array) -> float:
	# How much more than the window floor this profile asks for, capped at
	# HRConstants.SALARY_PEAK_PREMIUM. Measured as (peak + total) against the ceiling both
	# could reach, which is two rules in one number:
	#   - the PEAK term is the design's "keskin uzman biraz daha pahalı" (design doc §3);
	#   - the TOTAL term is what keeps a MIXED set non-dominated. Beating another profile on
	#     all three axes always raises the total, so a strictly better file automatically
	#     quotes a strictly higher salary and cannot dominate on price too.
	# The term is LIVE: BAND_SHAPE holds three profiles per band with strictly increasing
	# totals, so the three quotes are pairwise distinct by arithmetic, not luck. The gap
	# rule that keeps rounding from collapsing them: adjacent profiles differ in
	# (peak + total) by >= 4 (junior) / 3 (mid, senior), and the tightest windows give
	#   junior 5000·0.10·4/36 = 55.6 · mid 7600·0.10·3/36 = 63.3 · senior 10800·0.10·3/36 = 90.0
	# — all >= SALARY_ROUND_TO (50), and two raw values >= a rounding step apart can never
	# round onto one multiple. Shrink a band floor or a profile gap below that line and the
	# smoke's distinct-salary assertion screams.
	# PRICED OFF THE 3-LONG SHAPE, NOT THE SIX AREAS (2026-08-21). Deliberate: the shape is
	# what BAND_SHAPE's whole invariant table is written about (strictly increasing totals,
	# gaps wide enough that two quotes cannot round together), and pricing the spread-out
	# six-key dict instead would change every quoted salary in the game for no design reason.
	# Same arithmetic, same numbers, same ceiling AREA_MAX × 4 — the migration moved zero lira.
	var total: int = 0
	var peak: int = HRConstants.AREA_MIN
	for v in shape:
		var value: int = int(v)
		total += value
		peak = maxi(peak, value)
	var ceiling: int = HRConstants.AREA_MAX * 4
	if ceiling <= 0:
		return 0.0
	return HRConstants.SALARY_PEAK_PREMIUM * clampf(float(peak + total) / float(ceiling), 0.0, 1.0)


# --- Traits: 1-2 positive, at most 1 negative, nothing repeated across the batch ---

static func _cost_carriers(seed_value: int) -> Array:
	# ŞEKİL AYNI, KELİME DEĞİŞTİ (2026-08-21, H2). Eskiden "kötü trait taşıyan dosya"ydı;
	# artık "BEDELLİ trait taşıyan dosya". R4 iyi/kötü ayrımını kaldırdı ama üretici hâlâ
	# bir ayrım istiyor: her dosya aynı pürüzsüzlükte olursa seçim bir takas olmaktan
	# çıkar. Ayrım artık görevin kendi Cost sütunundan türetiliyor, icat değil.
	#
	# Sayı TRAIT_COST_SHARE'den, kesirli kişi seed çekimiyle (TRAIT_SHARE_RESOLUTION),
	# HANGİ dosyaların taşıdığı seed türevi bir başlangıç indeksiyle — bedelli trait
	# hep aynı kartta durmasın.
	var carriers: Array = []
	for _k in range(HRConstants.CANDIDATE_COUNT):
		carriers.append(false)
	if HRConstants.TRAIT_MAX_COST <= 0 or HRConstants.CANDIDATE_COUNT <= 0:
		return carriers
	var expected: float = float(HRConstants.CANDIDATE_COUNT) * HRConstants.TRAIT_COST_SHARE
	var whole: int = int(floor(expected))
	var remainder: int = int(round((expected - floor(expected)) * float(TRAIT_SHARE_RESOLUTION)))
	var count: int = whole
	if _mix(seed_value, SALT_NEGATIVE_COUNT) % TRAIT_SHARE_RESOLUTION < remainder:
		count += 1
	count = mini(count, mini(HRConstants.CANDIDATE_COUNT, HRConstants.cost_trait_ids().size()))
	var start: int = _mix(seed_value, SALT_NEGATIVE_WHICH) % HRConstants.CANDIDATE_COUNT
	for j in range(count):
		carriers[(start + j) % HRConstants.CANDIDATE_COUNT] = true
	return carriers


static func _pick_traits(seed_value: int, index: int, wants_cost: bool, used: Array) -> Array[String]:
	# TEK TRAIT (HRConstants.TRAIT_COUNT). `_cost_carriers` bir dosyayı işaretlediyse o
	# dosyanın TEK trait'i BEDELLİ olanıdır; işaretlemediyse bedelsiz üçlüden biri.
	#
	# `used` iki havuzda da paylaşılır: batch içinde hiçbir trait iki dosyada görünmez.
	# Havuzlar 3 ve 5, dosya 3 — tek trait kuralında tükenme ihtimali yok. En dar hâl
	# bedelsiz havuz: üç dosyanın ÜÇÜ de bedelsiz çıkarsa havuz tam tükenir ve hâlâ
	# yeter; dördüncü dosya olsaydı yetmezdi (CANDIDATE_COUNT 3'te sabit).
	var salt: int = SALT_CANDIDATE_STRIDE * index
	var traits: Array[String] = []
	if wants_cost:
		var cost_pool: Array = HRConstants.cost_trait_ids()
		var cost_id: String = _take_unused(cost_pool, used,
			_mix(seed_value, SALT_NEGATIVE_PICK + salt) % maxi(cost_pool.size(), 1))
		if cost_id != "":
			traits.append(cost_id)
	else:
		var free_pool: Array = HRConstants.free_trait_ids()
		var free_id: String = _take_unused(free_pool, used,
			_mix(seed_value, SALT_POSITIVE_PICK + salt) % maxi(free_pool.size(), 1))
		if free_id != "":
			traits.append(free_id)
	if not HRConstants.validate_employee_traits(traits):
		push_error("[HRCandidateGenerator] trait set failed HRConstants.validate_employee_traits: %s" % str(traits))
	return traits


# --- Pure-integer helpers ---

static func _mix(seed_value: int, salt: int) -> int:
	# ONE seed, as many independent draws as there are fields. Non-negative by construction so
	# `% pool.size()` can never index backwards. This is the whole RNG budget of this file.
	var n: int = (absi(seed_value) % MIX_MODULUS) + MIX_SALT_STRIDE * (absi(salt) % MIX_MODULUS)
	n = (n % MIX_MODULUS) * MIX_MULTIPLIER + MIX_INCREMENT
	return n % MIX_MODULUS


static func _take_unused(pool: Array, used: Array, start_index: int) -> String:
	# pool[n % size], then a deterministic forward walk past anything the batch already took.
	# A walk rather than a retry: re-drawing until it lands on a free slot would need
	# randomness this file is not allowed to have, and would not terminate deterministically.
	# Bounded by the pool size, so an exhausted pool returns "" instead of spinning.
	if pool.is_empty():
		return ""
	for step in range(pool.size()):
		var candidate_id: String = String(pool[(start_index + step) % pool.size()])
		if not used.has(candidate_id):
			used.append(candidate_id)
			return candidate_id
	return ""


static func _unused_count(pool: Array, used: Array) -> int:
	var n: int = 0
	for entry in pool:
		if not used.has(String(entry)):
			n += 1
	return n


static func _dominates(a: Dictionary, b: Dictionary) -> bool:
	# A dominates B when A is at least as good on EVERY axis and does not cost more. Reading
	# missing keys as the ruler floor / free keeps a malformed hand-built file loud rather than
	# crashing the predicate the smoke leans on.
	var a_axes: Dictionary = a.get("axes", {})
	var b_axes: Dictionary = b.get("axes", {})
	for axis_key in HRConstants.EMPLOYEE_SKILL_KEYS:
		if int(a_axes.get(axis_key, HRConstants.AREA_MIN)) < int(b_axes.get(axis_key, HRConstants.AREA_MIN)):
			return false
	return int(a.get("salary", 0)) <= int(b.get("salary", 0))


static func _round_to(value: float, step: int) -> int:
	if step <= 1:
		return int(round(value))
	return int(round(value / float(step))) * step


static func _ceil_to(value: float, step: int) -> int:
	if step <= 1:
		return int(ceil(value))
	return int(ceil(value / float(step))) * step


static func _floor_to(value: float, step: int) -> int:
	if step <= 1:
		return int(floor(value))
	return int(floor(value / float(step))) * step


## _take_unused's twin for a pool addressed by INDEX rather than by value. Needed because
## the file note is stored as an index now (the sentence lives in strings.csv), and the
## batch still has to avoid handing two candidates the same note. Same deterministic
## forward walk, same bounded exhaustion behaviour.
static func _take_unused_index(used: Array, start_index: int) -> int:
	var size: int = maxi(HRConstants.FILE_NOTES_COUNT, 1)
	for step in range(size):
		var idx: int = (start_index + step) % size
		if not used.has(idx):
			used.append(idx)
			return idx
	return start_index % size
