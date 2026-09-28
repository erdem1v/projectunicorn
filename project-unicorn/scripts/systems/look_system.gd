class_name LookSystem
extends RefCounted

# How an office person looks, drawn once from a seed and kept: sex, the four parts their role's
# style allows (PeopleParts), palette indices for skin, hair and clothes, picked so the clothes go
# together (a suit's trousers usually match its jacket, trousers never repeat the top, a dress's
# skirt is the dress, shoes reach the hem), and glasses. Values are bools, ints and strings only,
# so a saved look reads back the same. Looks are kept apart from each other. OfficeBody draws it.

## A redraw steps the seed by this much.
const RESEED := 7919
const GLASSES := 0.25
## A suit's tie is left off this often (tie -1: the shirt shows).
const NO_TIE := 0.5
## Two people seen together differ in at least this many of the slots a glance tells people apart
## by; after TRIES draws the most apart one is kept.
const MIN_APART := 2
const TRIES := 64
## The founder looks like the portrait chosen at the start (assets/art/founders/founder_NN.webp,
## in order): the same sex, skin, hair, face hair, glasses and top as near as the wardrobe comes.
const FOUNDER_LOOKS := [
	{"sex": "w", "head": "w_scifi", "body": "w_casual", "legs": "w_casual", "feet": "w_casual", "skin": 4, "hair": 1,
		"top": 3, "top2": 3, "tie": 0, "bottom": 2, "shoe": 1, "height": 2, "girth": 1, "glasses": false},
	{"sex": "m", "head": "m_adventurer", "body": "m_suit", "legs": "m_suit", "feet": "m_suit", "skin": 5, "hair": 0,
		"top": 2, "top2": 0, "tie": -1, "bottom": -1, "shoe": 1, "height": 3, "girth": 1, "glasses": false},
	{"sex": "w", "head": "w_witch", "body": "w_suit", "legs": "w_suit", "feet": "w_suit", "skin": 1, "hair": 4,
		"top": 2, "top2": 3, "tie": 0, "bottom": -1, "shoe": 1, "height": 2, "girth": 1, "glasses": false},
	{"sex": "m", "head": "m_casual", "body": "m_adventurer", "legs": "m_casual", "feet": "m_casual", "skin": 0, "hair": 3,
		"top": 4, "top2": 3, "tie": 0, "bottom": 1, "shoe": 0, "height": 2, "girth": 1, "glasses": false},
	{"sex": "w", "head": "w_suit", "body": "w_casual", "legs": "w_casual", "feet": "w_casual", "skin": 0, "hair": 0,
		"top": 3, "top2": 3, "tie": 0, "bottom": 2, "shoe": 1, "height": 1, "girth": 0, "glasses": false},
	{"sex": "m", "head": "m_casual", "body": "m_adventurer", "legs": "m_casual", "feet": "m_casual", "skin": 1, "hair": 0,
		"top": 1, "top2": 0, "tie": 0, "bottom": 1, "shoe": 3, "height": 2, "girth": 1, "glasses": true},
	{"sex": "w", "head": "w_suit", "body": "w_casual", "legs": "w_casual", "feet": "w_casual", "skin": 3, "hair": 0,
		"top": 1, "top2": 1, "tie": 0, "bottom": 1, "shoe": 3, "height": 2, "girth": 1, "glasses": false},
	{"sex": "m", "head": "m_hoodie", "body": "m_adventurer", "legs": "m_casual", "feet": "m_casual", "skin": 2, "hair": 0,
		"top": 3, "top2": 0, "tie": 0, "bottom": 2, "shoe": 0, "height": 2, "girth": 1, "glasses": false},
	{"sex": "w", "head": "w_adventurer", "body": "w_suit", "legs": "w_suit", "feet": "w_suit", "skin": 5, "hair": 7,
		"top": 0, "top2": 3, "tie": 0, "bottom": -1, "shoe": 1, "height": 1, "girth": 2, "glasses": false},
	{"sex": "w", "head": "w_suit", "body": "w_suit", "legs": "w_suit", "feet": "w_suit", "skin": 1, "hair": 0,
		"top": 7, "top2": 5, "tie": 0, "bottom": 3, "shoe": 1, "height": 2, "girth": 1, "glasses": false},
	{"sex": "w", "head": "w_formal", "body": "w_suit", "legs": "w_suit", "feet": "w_suit", "skin": 3, "hair": 1,
		"top": 4, "top2": 3, "tie": 0, "bottom": -1, "shoe": 2, "height": 2, "girth": 1, "glasses": false},
]


## A look for `role` and `sex` from `from_seed`.
static func _make(from_seed: int, role: String, sex: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = from_seed
	var style: Dictionary = PeopleParts.STYLES[PeopleParts.ROLE_STYLES.get(role, "casual")][sex]
	var pick := func(list: Array) -> Variant: return list[rng.randi_range(0, list.size() - 1)]
	var index := func(palette: String) -> int: return rng.randi_range(0, PeopleParts.PALETTES[palette].size() - 1)
	var body: String = pick.call(style.Body)
	var legs: String = body if PeopleParts.DRESSES.has(body) else pick.call(style.Legs)
	var look := {
		"sex": sex, "head": pick.call(PeopleParts.HEADS[sex]), "body": body, "legs": legs,
		"feet": pick.call(style.Feet.filter(func(f: String) -> bool: return PeopleParts.SHOE_TOP[f] >= PeopleParts.HEM[legs])),
		"skin": index.call("skin"), "hair": rng.rand_weighted(PeopleParts.HAIR_WEIGHTS),
		"top": index.call(PeopleParts.top_palette(body, "top")),
		"top2": index.call(PeopleParts.top_palette(body, "top2")),
		"tie": -1 if rng.randf() < NO_TIE else index.call("tie"), "shoe": index.call("shoe"),
		"height": rng.randi_range(0, OfficeBody.HEIGHTS.size() - 1),
		"girth": rng.randi_range(0, OfficeBody.GIRTHS.size() - 1),
		"glasses": rng.randf() < GLASSES,
	}
	look["bottom"] = _bottom(rng, look)
	return look


## Trousers that go with the top: the jacket's own colour for a matched suit, else any bottom
## that is not the top's colour.
static func _bottom(rng: RandomNumberGenerator, look: Dictionary) -> int:
	var bottoms: Array = PeopleParts.PALETTES.bottom
	var top_palette := PeopleParts.top_palette(look.body, "top")
	var top: String = PeopleParts.PALETTES[top_palette][look.top]
	if top_palette == "jacket" and look.legs == look.body and rng.randf() < PeopleParts.SUIT_MATCH:
		return -1
	var options := range(bottoms.size()).filter(func(i: int) -> bool: return bottoms[i] != top)
	return options[rng.randi_range(0, options.size() - 1)]


## A look for `role` and `sex` from `from_seed` whose signature the run has not handed out yet and
## that stands MIN_APART slots from each look in `around` (the people it will be seen with).
static func _unique(from_seed: int, role: String, sex: String, around: Array) -> Dictionary:
	var best := {}
	var best_gap := -1
	for i in TRIES:
		var look := _make(from_seed + i * RESEED, role, sex)
		if GameState.issued_looks.has(signature(look)):
			continue
		var gap: int = around.reduce(func(m: int, other: Dictionary) -> int: return mini(m, apart(look, other)), MIN_APART)
		if gap >= MIN_APART:
			return look
		if gap > best_gap:
			best = look
			best_gap = gap
	return best if not best.is_empty() else _make(from_seed, role, sex)


## The founder's look: the portrait chosen at the start (in FounderConstants.PORTRAIT_IDS order),
## or the first when none was chosen (smoke and harness runs).
static func founder(portrait_id: String) -> Dictionary:
	return (FOUNDER_LOOKS[maxi(0, FounderConstants.PORTRAIT_IDS.find(portrait_id))] as Dictionary).duplicate()


## A look for `person_name` in `role` from `from_seed`, apart from every look the run has issued and
## from the people in `around`. The first name gives the sex (HRConstants.FIRST_NAME_SEX); a name
## worn by both draws it.
static func for_person(from_seed: int, person_name: String, role: String, around: Array) -> Dictionary:
	var sex: String = HRConstants.FIRST_NAME_SEX.get(person_name.get_slice(" ", 0), "m" if posmod(from_seed, 2) == 0 else "w")
	return _unique(from_seed, role, sex, around)


## In how many glance slots two looks differ: sex, face and hair style, hair colour, skin, top
## part, top colour, trouser colour, glasses.
static func apart(a: Dictionary, b: Dictionary) -> int:
	var sa := _glance(a)
	var sb := _glance(b)
	return range(sa.size()).filter(func(i: int) -> bool: return sa[i] != sb[i]).size()


static func signature(look: Dictionary) -> String:
	var keys := look.keys()
	keys.sort()
	return "|".join(keys.map(func(k: Variant) -> String: return "%s=%s" % [k, look[k]]))


static func _glance(look: Dictionary) -> Array:
	var top: String = PeopleParts.PALETTES[PeopleParts.top_palette(look.body, "top")][look.top]
	var bottom: String = top if PeopleParts.bottom_is_top(look) else PeopleParts.PALETTES.bottom[look.bottom]
	return [look.sex, look.head, look.hair, look.skin, look.body, top, bottom, look.glasses]
