class_name SalesNamePool
extends RefCounted

# COMPANY NAME POOL (§11.3) — the machinery that makes §3's "havuz tükenmez" true.
#
# WHAT CHANGED AND WHY. Before rev 6 the 65 names in `CompanyCatalog` WERE the supply: a run
# saw only its sub-type's affinity sectors (20-25 companies), every signature removed a name
# forever, and when the list ran dry `spawn_prospect` returned null and the tab said the pool
# was empty. Calibration Round A measured the end of that: ~25 accounts and a plateau from
# month 7 (finding F1). §19 retires the catalogue's SOLE-SUPPLY role, not the catalogue —
# "isimler §11.3 havuzuna ve kahraman hesaplara devşirilir". So the 65 curated names stay and
# become the memorable minority; this file is the majority behind them.
#
# HOW A NAME IS BUILT. Canonical style, read off the curated set: `<Stem> <SectorWord>`
# ("Kuzey İnşaat", "Deniz Lojistik"). STEMS below are NEW — none collides with a catalogue
# name, and `_build_pool` de-duplicates anyway. Names are PROPER NOUNS and do not localise
# (BILINGUAL BIRTH LAW), which is why they are literals here with the house `LOC-DATA` marker
# rather than CSV keys.
#
# THESE ARE THE PLACEHOLDER SET §11.3 ASKS FOR. The director scans and revises them; the two
# tables below are the whole surface, so "find every generated name" is one grep, not an
# archaeology dig. They deliberately do NOT carry the `PH:` prose tag: a lead card reading
# "PH: Kuzey Lojistik" is unreadable, and a proper noun is not a narrative string.
#
# DETERMINISM. No RNG. Every draw is integer arithmetic over the seed, the house pattern from
# `HRCandidateGenerator._mix`. Two runs with the same seed meet the same companies.

# --- New stems (§11.3 placeholder set) -------------------------------------
# Geography, weather and mineral words in the curated set's register. Deliberately short —
# a lead card gives a company name one line.
const STEMS := [
	"Akdeniz", "Alaçatı", "Altınyol", "Ayvalık", "Bakırçay",       # LOC-DATA company name stem (proper noun)
	"Boğaziçi", "Çukurova", "Efes", "Erciyes", "Gediz",            # LOC-DATA company name stem (proper noun)
	"Granit", "Haliç", "Karadeniz", "Kervan", "Kılavuz",           # LOC-DATA company name stem (proper noun)
	"Liman", "Meltem", "Mercan", "Munzur", "Obsidyen",             # LOC-DATA company name stem (proper noun)
	"Pergama", "Rüzgar", "Safir", "Selçuk", "Sultanahmet",         # LOC-DATA company name stem (proper noun)
	"Taurus", "Tuna", "Uludağ", "Yıldız", "Zeytin",                # LOC-DATA company name stem (proper noun)
	"Adria", "Borealis", "Calder", "Danube", "Elbruz",             # LOC-DATA company name stem (proper noun)
	"Fenrir", "Granada", "Havel", "Iberia", "Juno",                # LOC-DATA company name stem (proper noun)
	"Karst", "Lumen", "Meridian", "Nimbus", "Orion",               # LOC-DATA company name stem (proper noun)
	"Pontus", "Quarzo", "Rhein", "Sirocco", "Thalassa",            # LOC-DATA company name stem (proper noun)
]

# --- Sector words, in the curated set's register ---------------------------
# Two to four per sector so a stem yields more than one company and the pool scales with the
# product of the two tables rather than the length of one.
const SECTOR_WORDS := {
	"insurance": ["Sigorta", "Poliçe", "Teminat"],                       # LOC-DATA company name suffix (proper noun)
	"construction": ["İnşaat", "Yapı", "Beton", "Proje"],                # LOC-DATA company name suffix (proper noun)
	"logistics": ["Lojistik", "Kargo", "Nakliyat", "Terminal"],          # LOC-DATA company name suffix (proper noun)
	"health": ["Klinik", "Sağlık", "Medikal", "Poliklinik"],             # LOC-DATA company name suffix (proper noun)
	"manufacturing": ["Üretim", "Fabrika", "Metal", "Endüstri"],         # LOC-DATA company name suffix (proper noun)
	"retail": ["Market", "Mağazacılık", "Perakende"],                    # LOC-DATA company name suffix (proper noun)
	"real_estate": ["Gayrimenkul", "Emlak", "Holding", "Arsa"],          # LOC-DATA company name suffix (proper noun)
	"textile": ["Tekstil", "Dokuma", "Konfeksiyon"],                     # LOC-DATA company name suffix (proper noun)
	"legal": ["Hukuk", "Danışmanlık", "Legal"],                          # LOC-DATA company name suffix (proper noun)
	"technology": ["Yazılım", "Teknoloji", "Bilişim", "Sistemler"],      # LOC-DATA company name suffix (proper noun)
	"ecommerce": ["Ticaret", "Pazar", "Online", "Sepet"],                # LOC-DATA company name suffix (proper noun)
	"media": ["Medya", "Yayın", "Prodüksiyon", "Stüdyo"],                # LOC-DATA company name suffix (proper noun)
	"finance": ["Finans", "Yatırım", "Portföy", "Kapital"],              # LOC-DATA company name suffix (proper noun)
	"testing": ["Test"],   # the SECTOR_FIXTURE sector, so harness fixtures draw a name too
}

# Deterministic mixer, same shape as HRCandidateGenerator._mix (see its header for why an
# in-project integer mixer rather than a stream draw).
const MIX_MODULUS := 1000003
const MIX_MULTIPLIER := 48271
const MIX_INCREMENT := 12345
const MIX_SALT_STRIDE := 7919
const SALT_NAME := 211

# Cached per-sector pools. Built once, never invalidated: both source tables are consts.
static var _pools: Dictionary = {}


## Every company name this sector can ever offer: the curated catalogue first (so the
## memorable names come up early in a run), then the generated set. Order is stable.
static func pool_for(sector: String) -> Array:
	if _pools.has(sector):
		return _pools[sector] as Array
	_pools[sector] = _build_pool(sector)
	return _pools[sector] as Array


static func _build_pool(sector: String) -> Array:
	var seen: Dictionary = {}
	var out: Array = []
	for nm in CompanyCatalog.names_for_sector(sector):
		var s: String = String(nm)
		if not seen.has(s):
			seen[s] = true
			out.append(s)
	var words: Array = SECTOR_WORDS.get(sector, []) as Array
	for w in words:
		for stem in STEMS:
			var name: String = "%s %s" % [String(stem), String(w)]
			if not seen.has(name):
				seen[name] = true
				out.append(name)
	return out


## How many names this sector could still offer right now. The honest answer to "can the
## faucet run", and it is never zero for a real sector — that is the point of §3.
static func available_count(sector: String, excluded: Dictionary) -> int:
	var n: int = 0
	for nm in pool_for(sector):
		if not excluded.has(nm):
			n += 1
	return n


## Draw one unused name. `excluded` is a SET (dictionary keys): live leads, signed companies,
## and companies still inside their return lock. Returns "" only if a sector has no words at
## all, which is a content error rather than a play state.
static func take(sector: String, seed_value: int, excluded: Dictionary) -> String:
	var pool: Array = pool_for(sector)
	if pool.is_empty():
		push_warning("[SalesNamePool] no names for sector '%s' — see SECTOR_WORDS" % sector)
		return ""
	var start: int = _mix(seed_value, SALT_NAME) % pool.size()
	for offset in pool.size():
		var candidate: String = String(pool[(start + offset) % pool.size()])
		if not excluded.has(candidate):
			return candidate
	return ""


## Total addressable names across every sector a sub-product can reach. Read by the smoke
## case that proves the pool cannot run dry the way the catalogue could.
static func total_for_sectors(sectors: Array) -> int:
	var n: int = 0
	for s in sectors:
		n += pool_for(String(s)).size()
	return n


static func _mix(seed_value: int, salt: int) -> int:
	var n: int = (absi(seed_value) % MIX_MODULUS) + MIX_SALT_STRIDE * (absi(salt) % MIX_MODULUS)
	return absi((n * MIX_MULTIPLIER + MIX_INCREMENT) % MIX_MODULUS)
