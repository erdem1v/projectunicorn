class_name CompanyCatalog
extends RefCounted

# Company catalog — the SINGLE source of prospect/customer company fiction
# (Dünya İnandırıcılığı Fix 2). Replaces B2BConstants.SECTOR_COMPANIES (9 sectors
# × 3 names, four sectors sharing one 3-name fallback — the root of the "Beykoz
# appears everywhere" break). 13 sectors × 5 companies = 65, matching the full
# SECTOR_CONTACT / COMPLAINT_VOICE sector set so no sector ever falls through to
# a shared fallback again.
#
# # WORKING TR — background lines are working copy; Erdem voice-passes later.
#
# Fiction rules (task-locked):
#   - Mix: Turkish firms, Turkish-international hybrids, foreign firms operating
#     regionally. No joke names, no real trademarks. Names are proper nouns
#     (LANGUAGE INTEGRITY LAW exempts them); backgrounds are clean Turkish.
#   - The background line is ONE line of character (sector feel, size feel,
#     temperament). The event system may QUOTE it to color wording; it must never
#     DRIVE an event's subject (Fix 5 rule). UI may show it on a customer card.
#     It lives in strings.csv as COMPANY_BG_<ID>, not here — see background_for.
#   - The smoke suite's synthetic "Testing" sector is deliberately absent —
#     hand-built fixtures stay outside the catalog.
#
# Naming note: two legacy pool names were live trademarks of real Turkish
# companies (Anadolu Sigorta, Anadolu Yatırım) and were replaced (Poyraz
# Sigorta, Argos Yatırım). Every other legacy name carried over unchanged.

const COMPANIES := {
	"insurance": [
		{"name": "Ege Sigorta", "id": "EGE_SIGORTA"},
		{"name": "Poyraz Sigorta", "id": "POYRAZ_SIGORTA"},
		{"name": "Deniz Sigorta", "id": "DENIZ_SIGORTA"},
		{"name": "Adriatic Assurance", "id": "ADRIATIC_ASSURANCE"},
		{"name": "Vega Sigorta", "id": "VEGA_SIGORTA"},
	],
	"construction": [
		{"name": "Kuzey İnşaat", "id": "KUZEY_INSAAT"},
		{"name": "Anadolu Yapı", "id": "ANADOLU_YAPI"},
		{"name": "Marmara İnşaat", "id": "MARMARA_INSAAT"},
		{"name": "Terra Yapı", "id": "TERRA_YAPI"},
		{"name": "Donau Bau", "id": "DONAU_BAU"},
	],
	"logistics": [
		{"name": "Deniz Lojistik", "id": "DENIZ_LOJISTIK"},
		{"name": "Nordica Lojistik", "id": "NORDICA_LOJISTIK"},
		{"name": "Ege Kargo", "id": "EGE_KARGO"},
		{"name": "Marmara Lojistik", "id": "MARMARA_LOJISTIK"},
		{"name": "Nordwind GmbH", "id": "NORDWIND_GMBH"},
	],
	"health": [
		{"name": "Aras Klinik", "id": "ARAS_KLINIK"},
		{"name": "Marmara Klinik", "id": "MARMARA_KLINIK"},
		{"name": "Bosphorus Sağlık", "id": "BOSPHORUS_SAGLIK"},
		{"name": "Vita Medikal", "id": "VITA_MEDIKAL"},
		{"name": "Medisa Grup", "id": "MEDISA_GRUP"},
	],
	"manufacturing": [
		{"name": "Beykoz Üretim", "id": "BEYKOZ_URETIM"},
		{"name": "Trakya Fabrika", "id": "TRAKYA_FABRIKA"},
		{"name": "Ege Metal", "id": "EGE_METAL"},
		{"name": "Vulkan Döküm", "id": "VULKAN_DOKUM"},
		{"name": "Ferrum Endüstri", "id": "FERRUM_ENDUSTRI"},
	],
	"retail": [
		{"name": "Anadolu Market", "id": "ANADOLU_MARKET"},
		{"name": "Brightline Retail", "id": "BRIGHTLINE_RETAIL"},
		{"name": "Kardelen Mağazacılık", "id": "KARDELEN_MAGAZACILIK"},
		{"name": "Ekin Gıda Marketleri", "id": "EKIN_GIDA_MARKETLERI"},
		{"name": "Modena Concept", "id": "MODENA_CONCEPT"},
	],
	"real_estate": [
		{"name": "Palmiye Holding", "id": "PALMIYE_HOLDING"},
		{"name": "Kıyı Gayrimenkul", "id": "KIYI_GAYRIMENKUL"},
		{"name": "Metrekare Danışmanlık", "id": "METREKARE_DANISMANLIK"},
		{"name": "Vestera Holding", "id": "VESTERA_HOLDING"},
		{"name": "Panorama Emlak", "id": "PANORAMA_EMLAK"},
	],
	"textile": [
		{"name": "Beykoz Tekstil", "id": "BEYKOZ_TEKSTIL"},
		{"name": "Menderes Dokuma", "id": "MENDERES_DOKUMA"},
		{"name": "İplikhane", "id": "IPLIKHANE"},
		{"name": "Nova Tekstil", "id": "NOVA_TEKSTIL"},
		{"name": "Aegea Textile Group", "id": "AEGEA_TEXTILE_GROUP"},
	],
	"legal": [
		{"name": "Bosphorus Legal", "id": "BOSPHORUS_LEGAL"},
		{"name": "Kavanagh & Sons", "id": "KAVANAGH_SONS"},
		{"name": "Aslan & Duru Hukuk", "id": "ASLAN_DURU_HUKUK"},
		{"name": "Meridyen Hukuk", "id": "MERIDYEN_HUKUK"},
		{"name": "Lex Anadolu", "id": "LEX_ANADOLU"},
	],
	"technology": [
		{"name": "Nexus Yazılım", "id": "NEXUS_YAZILIM"},
		{"name": "Piksel Teknoloji", "id": "PIKSEL_TEKNOLOJI"},
		{"name": "Volt Sistemleri", "id": "VOLT_SISTEMLERI"},
		{"name": "Atlas Bilişim", "id": "ATLAS_BILISIM"},
		{"name": "Origo Labs", "id": "ORIGO_LABS"},
	],
	"ecommerce": [
		{"name": "Sepet Ticaret", "id": "SEPET_TICARET"},
		{"name": "Hızlı Pazar", "id": "HIZLI_PAZAR"},
		{"name": "Vitrin Online", "id": "VITRIN_ONLINE"},
		{"name": "Loka Store", "id": "LOKA_STORE"},
		{"name": "Adriatica Market", "id": "ADRIATICA_MARKET"},
	],
	"media": [
		{"name": "Kanal Medya", "id": "KANAL_MEDYA"},
		{"name": "Punto Yayın", "id": "PUNTO_YAYIN"},
		{"name": "Ekran Prodüksiyon", "id": "EKRAN_PRODUKSIYON"},
		{"name": "Anadolu Digital", "id": "ANADOLU_DIGITAL"},
		{"name": "Nordlicht Studio", "id": "NORDLICHT_STUDIO"},
	],
	"finance": [
		{"name": "Kule Finans", "id": "KULE_FINANS"},
		{"name": "Argos Yatırım", "id": "ARGOS_YATIRIM"},
		{"name": "Pusula Portföy", "id": "PUSULA_PORTFOY"},
		{"name": "Helvetia Data AG", "id": "HELVETIA_DATA_AG"},
		{"name": "Lira Kapital", "id": "LIRA_KAPITAL"},
	],
}


# Lazy name→record index (record gains a "sector" key on first build).
static var _by_name: Dictionary = {}


static func _index() -> Dictionary:
	if _by_name.is_empty():
		for sector in COMPANIES:
			for rec in COMPANIES[sector]:
				_by_name[rec["name"]] = {"name": rec["name"], "sector": sector, "id": rec["id"]}
	return _by_name


static func all() -> Array:
	# Flattened [{name, sector, id, background}] — smoke integrity checks iterate this.
	# `background` is resolved here rather than stored, so the list reads the same as it
	# always did while the words themselves live in the CSV.
	var out: Array = []
	for sector in COMPANIES:
		for rec in COMPANIES[sector]:
			out.append({"name": rec["name"], "sector": sector, "id": rec["id"],
				"background": _background_by_id(String(rec["id"]))})
	return out


static func names_for_sector(sector: String) -> Array:
	# Name strings only — the spawn picker's per-sector candidate list. Unknown
	# sector → empty array (no shared fallback: that was the old fiction break).
	var out: Array = []
	for rec in COMPANIES.get(sector, []):
		out.append(rec["name"])
	return out


static func background_for(company_name: String) -> String:
	# One-line character color for events/cards. Empty for names outside the
	# catalog (hand-built fixtures, legacy saves) — callers treat "" as "skip".
	var rec: Dictionary = _index().get(company_name, {})
	return _background_by_id(String(rec.get("id", "")))


## COMPANY_BG_<ID> → the line, or "" for an unknown id. TranslationServer hands back the
## key itself when a row is missing, which would put a raw token on a customer card, so an
## unresolved id is reported as absent instead.
static func _background_by_id(id: String) -> String:
	if id == "":
		return ""
	var key: String = "COMPANY_BG_" + id
	var out: String = TranslationServer.translate(key)
	return "" if out == key else out


static func sector_for(company_name: String) -> String:
	var rec: Dictionary = _index().get(company_name, {})
	return String(rec.get("sector", ""))


static func count_by_sector() -> Dictionary:
	var out: Dictionary = {}
	for sector in COMPANIES:
		out[sector] = COMPANIES[sector].size()
	return out
