class_name HRCandidateGenerator
extends RefCounted

# Atlas aday dosyası üretici (§10.2) — a PURE function of (role, LEVEL, seed).
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
# the archetype shapes landed without rewriting it:
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
#   {"name": String, "role": String, "level": int, "archetype": String,
#    "axes": {altı alan + leadership},   # HRConstants.EMPLOYEE_SKILL_KEYS, her biri 0..AREA_MAX
#    "salary": int, "traits": Array[String], "note_index": int}
#
# `level` DOSYADA TAŞINIR ve işe alımda Character.level'a yazılır (§3, §15). Eski `band`
# anahtarı bir BÜTÇE seçeneğiydi ve işe alımda ATILIYORDU: aday üretilirken okunuyor,
# çalışana hiç geçmiyordu. Seviye ise kişide kalıcıdır — terfinin değiştirdiği alan odur.


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
# §10.2'nin üç arama-başına çekimi: fiyat çapası, üçlünün fiyat farkı, ve beş yıldızlı aday.
const SALT_ANCHOR := 149
const SALT_SPREAD := 167
const SALT_FIVE_STAR := 181

# seed_for's weights — spawn_prospect's `day * 7 + count * 13` shape, with role and band folded
# in so two searches commissioned on the same day for different roles do not return the same
# three people with different job titles.
const SEED_DAY_STRIDE := 7
const SEED_HIRES_STRIDE := 13
const SEED_ROLE_STRIDE := 101
const SEED_LEVEL_STRIDE := 17

# Fractional-share resolution. TRAIT_COST_SHARE × CANDIDATE_COUNT is 1.5 people and half a
# person cannot carry a trait, so the remainder becomes a per-search draw in percent: some
# searches bring one bad trait, some bring two, and the SHARE holds across searches instead of
# being silently rounded into a fixed number.
const TRAIT_SHARE_RESOLUTION := 100

# Kesirli olasılıkları tamsayı aritmetiğine çevirme çözünürlüğü (bu dosyada RNG YOK, §10.2'nin
# "nadir" ve "hafif riskli" sözcükleri seed'den türetilir).
const CHANCE_RESOLUTION := 1000

# Salaries are quoted to a $50 step — nobody asks for $9.873 a month. Presentation
# granularity, not a knob: at $100 the tightest junior window cannot hold three distinct
# quotes — _salary_trio's arithmetic works IN this step, so two files can never collide.
const SALARY_ROUND_TO := 50


# --- Public surface ---

static func generate(role_id: String, level: int, seed_value: int) -> Array:
	var files: Array = []
	if not HRConstants.is_employee_role(role_id):
		push_warning("[HRCandidateGenerator] generate for non-employee role '%s' — see HRConstants.EMPLOYEE_ROLES" % role_id)
	if not HRConstants.is_level(level):
		push_error("[HRCandidateGenerator] generate for unknown level %d — see HRConstants.LEVELS" % level)
		return files

	# §10.2 BEŞ YILDIZLI ADAY, ARAMA BAŞINA çekilir: "bir alanda 5,0 yıldızı olan aday havuzda
	# NADİRDİR, yalnız KIDEMLİ bantta çıkar, ve maaş talebi bandın TAVANINDADIR." Uzman'a
	# takılıyor çünkü tepe noktası zaten onun arketipi; Dengeli'ye takmak arketipi çelerdi.
	# THE TOP FILE, role-aware (§10.2 for everyone, Satış rev 6 §11.7 for sellers). The name
	# stayed `five_star` through the rest of this function on purpose: it is the same branch,
	# doing the same thing — one file in the trio reaches its ROLE's ceiling and is priced at
	# the top of the band — and only the ceiling and the odds now depend on who is being hired.
	var five_star: bool = _rolls(seed_value, SALT_FIVE_STAR,
		HRConstants.role_top_chance(role_id, level))
	# Fiyatlar ÜÇLÜ OLARAK belirlenir, dosya dosya değil: §10.2'nin fiyat kuralı bir SETİN
	# özelliğidir ("fark en düşük ile en yüksek arasında %20–45"), tek bir adayın değil.
	var quotes: Dictionary = _salary_trio(role_id, level, seed_value, five_star)

	# Cross-distribution bookkeeping. One shared list per pool so nothing repeats across the
	# three files: two Kerems or two "Cam kalp"s in one batch reads as a generator bug.
	var used_first: Array = []
	var used_last: Array = []
	var used_notes: Array = []
	var used_traits: Array = []

	for k in range(HRConstants.CANDIDATE_COUNT):
		var salt: int = SALT_CANDIDATE_STRIDE * k
		# Aday k = arketip k. Üçlü SABİTTİR (§10.2 "her aramada sabit bir üçlü arketip
		# çekilir"), o yüzden burada bir çekim yok — sıra tablonun sırasıdır.
		var archetype: String = String(HRConstants.ARCHETYPES[k % HRConstants.ARCHETYPES.size()])
		var axes: Dictionary = _skills_for(role_id, level, archetype, k,
			five_star and archetype == HRConstants.ARCHETYPE_UZMAN)   # §11.7: the ONE file
		if not HRConstants.validate_employee_skills(axes):
			push_error("[HRCandidateGenerator] generated skills are not the employee shape: %s" % str(axes))
		var first_name: String = _take_unused(HRConstants.FIRST_NAMES, used_first,
			_mix(seed_value, SALT_FIRST_NAME + salt) % maxi(HRConstants.FIRST_NAMES.size(), 1))
		var last_name: String = _take_unused(HRConstants.LAST_NAMES, used_last,
			_mix(seed_value, SALT_LAST_NAME + salt) % maxi(HRConstants.LAST_NAMES.size(), 1))
		files.append({
			"name": ("%s %s" % [first_name, last_name]).strip_edges(),
			"role": role_id,
			"level": level,
			"archetype": archetype,
			"axes": axes,
			"salary": int(quotes.get(archetype, 0)),
			"traits": _pick_traits(seed_value, k, _wants_cost_trait(seed_value, archetype),
				used_traits, role_id),
			# The INDEX is stored, never the sentence. A candidate file is state, and a
			# stored sentence would freeze one language into it — the same rule that moved
			# the B2C user-base name out of Customer.company_name.
			"note_index": _take_unused_index(used_notes,
				_mix(seed_value, SALT_NOTE + salt) % maxi(HRConstants.FILE_NOTES_COUNT, 1)),
		})

	# THE post-condition, §10.2 verbatim: "Hiçbir aday bir diğerini bütün eksenlerde yenemez.
	# ÜRETİMDEN SONRA KONTROL EDİLİR." Not a warning — a dominated file kills the mechanic.
	# The files are still returned (the same non-blocking grammar as
	# CharacterRegistry._validate_shape) so a broken constant surfaces as a screaming log
	# rather than an empty HR tab nobody can diagnose.
	if not is_non_dominated_set(files):
		push_error("[HRCandidateGenerator] dominated file in the generated set (role '%s', level %d, seed %d): %s — see HRConstants.ARCHETYPE_SHAPE"
			% [role_id, level, seed_value, str(files)])
	return files

static func is_non_dominated_set(files: Array) -> bool:
	# The invariant VERBATIM, price included: for every ordered pair, NOT (A >= B on all three
	# axes AND A.salary <= B.salary). Deliberately shape-agnostic — it assumes neither equal
	# totals nor a distinct strict argmax, so the archetype shapes can keep evolving in
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


static func seed_for(role_id: String, level: int) -> int:
	# Derived from run state, never from Time and never from randi: the day the search was
	# commissioned, how many people have been hired so far, and which role/level was asked for.
	# Two searches on the same day for the same role/level would repeat — but they cannot
	# coexist (one search at a time), and by the time the second one starts either the day or
	# run_hires has moved.
	var role_index: int = maxi(HRConstants.EMPLOYEE_ROLES.find(role_id) + 1, 0)
	return SEED_DAY_STRIDE * GameState.day \
		+ SEED_HIRES_STRIDE * GameState.run_hires \
		+ SEED_ROLE_STRIDE * role_index \
		+ SEED_LEVEL_STRIDE * (clampi(level, HRConstants.LEVEL_JUNIOR, HRConstants.LEVEL_SENIOR) + 1)

# --- Skills: the band shape read by MEANING, with a rotating off-role bump ---

static func _skills_for(role_id: String, level: int, archetype: String, rotation: int,
		five_star: bool) -> Dictionary:
	# THE SHAPE IS READ BY MEANING, NOT BY POSITION.
	#   shape[0] -> the role's KEY area        (ROLE_AREAS[role].key)
	#   shape[1] -> the role's SECONDARY area  (ROLE_AREAS[role].secondary, may be "")
	#   shape[2] -> every OTHER area
	# The peak is PINNED to the key area: a rotation over six areas would hand a UX/UI
	# Designer his peak in Satış — a candidate whose title and numbers disagree.
	#
	# ROTATION SURVIVES THE ARKETİP GEÇİŞİNİ, and it is not decoration: the three files must
	# differ QUALITATIVELY. Candidate k gets +1 on the k'th off-role area, so one developer
	# happens to know a little Ürün and the next a little Müşteri İlişkileri. It can only ADD,
	# so it can never introduce a domination that the shapes did not already have.
	#
	# Built by walking AREAS (not the shape) so the result always holds EXACTLY the ruler keys
	# and passes the CharacterRegistry key-lock.
	var shape: Array = HRConstants.archetype_shape(level, archetype, role_id)
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
	# LİDERLİK SEVİYEDEN OKUNUR, arketipin "diğer alanlar" değerinden DEĞİL
	# (HRConstants.archetype_leadership — gerekçe orada, ve ölçülmüş bir gerekçe: türetilmiş
	# hâlinde Uzman ile Pazarlık junior'da berabere kalıyor ve Uzman rakibini BÜTÜN eksenlerde
	# yeniyordu). Liderlik'i herkes taşır: iyi lider çıkan aday bir buluştur, bir iş tanımı değil.
	out[HRConstants.SKILL_LEADERSHIP] = HRConstants.archetype_leadership(level, archetype)
	if five_star:
		# §10.2: the top file's peak is in the KEY AREA, written AFTER the rotation bump so the
		# ceiling is exact. WHAT it reaches is the role's AND the level's (§11.7): ★2 for a
		# junior seller, ★3,5 for a senior one, the ruler's end for everyone else.
		out[key_area] = HRConstants.role_top_value(role_id, level)
	return out

# --- Salary: a narrow window inside the role/band, priced off the profile ---

static func _salary_trio(role_id: String, level: int, seed_value: int, five_star: bool) -> Dictionary:
	# §10.2 FİYAT, ÜÇLÜ OLARAK. Sıra tablodan: Pazarlık en düşük, Dengeli en yüksek, Uzman
	# "orta–yüksek" (HRConstants.ARCHETYPE_PRICE_UZMAN_SHARE). Fark %20–45: "alt sınır kararı
	# anlamlı yapar; üst sınır 'pahalı olan zaten daha iyi' refleksini engeller."
	#
	# ARİTMETİK YUVARLAMA ADIMINDA YAPILIR, oranla değil. Yani en düşük ve en yüksek teklif
	# doğrudan $50'lik adımlardan seçilir ve aradaki oran ÖLÇÜLDÜĞÜNDE de %20–45'te kalır —
	# önce oranı çekip sonra yuvarlasaydık yuvarlama farkı bandın dışına taşabilirdi.
	var band: Array = HRConstants.salary_band_for_level(role_id, level)
	if band.size() < 2:
		push_error("[HRCandidateGenerator] salary_band_for_level('%s', %d) is not a [low, high] pair: %s"
			% [role_id, level, str(band)])
		return {}
	var band_low: int = mini(int(band[0]), int(band[1]))
	var band_high: int = maxi(int(band[0]), int(band[1]))

	# En ucuz teklifin çapası. Bandın tabanına yapışmasın diye seed'den kaydırılır, ama
	# kaydırma EN GENİŞ farkın bile bandın tavanına sığacağı yere kadar.
	var low_max: int = _floor_to(float(band_high) / (1.0 + HRConstants.SALARY_SPREAD_MIN_R11), SALARY_ROUND_TO)
	low_max = maxi(low_max, band_low)
	var low: int = band_low
	if five_star:
		# TOP FILE: the Uzman asks the band CEILING (§10.2's named exception). The anchor is
		# therefore not free — it has to sit high enough that the ceiling is still inside the
		# %20-45 spread rule, or the trio silently breaks a rule §10.2 states in the same
		# paragraph as the exception.
		#
		# THIS WAS A LATENT BUG, and it stayed hidden because it needs the top file to appear:
		# at FIVE_STAR_CHANCE 0.08 on seniors only, the seeds the invariant case walks rarely
		# produced one. Satış rev 6 §11.7 gives the junior sales search a ~25 % top file and it
		# surfaced immediately (hr_candidate_invariants, sales_rep/lvl0 seed 19876: a
		# 1500..2250 trio is a 50 % spread). Every role's band has high/low = 1.5 > 1.45, so
		# the old "pin the anchor to the floor" line could never satisfy the rule for ANY role.
		low = maxi(_ceil_to(float(band_high) / (1.0 + HRConstants.SALARY_SPREAD_MAX_R11),
			SALARY_ROUND_TO), band_low)
	else:
		var steps_low: int = (low_max - band_low) / SALARY_ROUND_TO
		low += SALARY_ROUND_TO * (_mix(seed_value, SALT_ANCHOR) % (steps_low + 1))

	# En yüksek teklif: %20 ile %45 arasındaki YASAL adımlardan biri, bandın tavanıyla kesilir.
	var high_min: int = _ceil_to(float(low) * (1.0 + HRConstants.SALARY_SPREAD_MIN_R11), SALARY_ROUND_TO)
	var high_max: int = mini(
		_floor_to(float(low) * (1.0 + HRConstants.SALARY_SPREAD_MAX_R11), SALARY_ROUND_TO),
		_floor_to(float(band_high), SALARY_ROUND_TO))
	high_max = maxi(high_max, high_min)
	var steps_high: int = (high_max - high_min) / SALARY_ROUND_TO
	var high: int = high_min + SALARY_ROUND_TO * (_mix(seed_value, SALT_SPREAD) % (steps_high + 1))

	# Uzman aradadır; boşluk en dar hâlde bile yuvarlama adımından büyük (1500 × 0,20 × 0,6 =
	# 180 ve × 0,4 = 120), yani üç dosya asla aynı rakama düşmez.
	var mid: int = clampi(
		_round_to(float(low) + float(high - low) * HRConstants.ARCHETYPE_PRICE_UZMAN_SHARE, SALARY_ROUND_TO),
		low, high)
	if five_star:
		# §10.2: "maaş talebi bandın TAVANINDADIR. Erken oyunda oyuncunun parası ona yetmez;
		# o bir yıldız çalışandır ve öyle fiyatlanır." Bu, üçlünün %20–45 kuralına konmuş
		# ADI KONMUŞ bir istisnadır — beş yıldızlı aday karşılaştırılabilir olmak için değil,
		# içeriden yetiştirmenin (§5.3) karşısına GERÇEK bir alternatif koymak için vardır.
		mid = band_high
	return {
		HRConstants.ARCHETYPE_PAZARLIK: low,
		HRConstants.ARCHETYPE_UZMAN: mid,
		HRConstants.ARCHETYPE_DENGELI: high,
	}

# --- Traits: 1-2 positive, at most 1 negative, nothing repeated across the batch ---

static func _wants_cost_trait(seed_value: int, archetype: String) -> bool:
	# §10.2 tablosunun HUY ROLÜ sütunu, birebir:
	#   Pazarlık  "genellikle bedelli huy taşır"   -> HER ZAMAN. Ayırt edici eksen huydur ve
	#                                                 TRIO_COST_TRAIT_MIN'i garantiyle
	#                                                 karşılayan tek yol budur — bir olasılık
	#                                                 bazı aramaları bedelsiz bırakırdı.
	#   Uzman     "nötr ya da hafif riskli"        -> seed'e bağlı yazı-tura.
	#   Dengeli   "genellikle güvenli"             -> hep bedelsiz (gerekçe HRConstants'ta).
	match archetype:
		HRConstants.ARCHETYPE_PAZARLIK:
			return true
		HRConstants.ARCHETYPE_UZMAN:
			return _rolls(seed_value, SALT_NEGATIVE_COUNT, HRConstants.UZMAN_COST_TRAIT_CHANCE)
	return false

static func _pick_traits(seed_value: int, index: int, wants_cost: bool, used: Array,
		role_id: String = "") -> Array[String]:
	# TEK TRAIT (HRConstants.TRAIT_COUNT). `_wants_cost_trait` bir dosyayı işaretlediyse o
	# dosyanın TEK trait'i BEDELLİ olanıdır; işaretlemediyse bedelsiz havuzdan biri.
	#
	# `used` iki havuzda da paylaşılır: batch içinde hiçbir trait iki dosyada görünmez.
	# Havuzlar 3 ve 5, dosya 3 — tek trait kuralında tükenme ihtimali yok. En dar hâl
	# bedelsiz havuz: üç dosyanın ÜÇÜ de bedelsiz çıkarsa havuz tam tükenir ve hâlâ
	# yeter; dördüncü dosya olsaydı yetmezdi (CANDIDATE_COUNT 3'te sabit).
	var salt: int = SALT_CANDIDATE_STRIDE * index
	var traits: Array[String] = []
	if wants_cost:
		var cost_pool: Array = HRConstants.cost_trait_ids(role_id)
		var cost_id: String = _take_unused(cost_pool, used,
			_mix(seed_value, SALT_NEGATIVE_PICK + salt) % maxi(cost_pool.size(), 1))
		if cost_id != "":
			traits.append(cost_id)
	else:
		var free_pool: Array = HRConstants.free_trait_ids(role_id)
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


## Bir olasılığı seed'den çözer. RNG YOK — bu dosyanın tamamı (rolls dahil) aynı deterministik
## mikserin üstünde durur, çünkü aynı seed sonsuza dek bayt-aynı dosyalar üretmek zorunda ve
## global RNG akışı olay destesiyle istifa zarına aittir.
static func _rolls(seed_value: int, salt: int, chance: float) -> bool:
	var threshold: int = int(round(clampf(chance, 0.0, 1.0) * float(CHANCE_RESOLUTION)))
	return _mix(seed_value, salt) % CHANCE_RESOLUTION < threshold


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
