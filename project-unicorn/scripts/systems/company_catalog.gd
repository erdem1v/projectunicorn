class_name CompanyCatalog
extends RefCounted

# Company catalog — the curated head of each sector's name pool (SalesNamePool puts these
# names first, then its generated ones). 13 sectors × 5 companies.
#
# Fiction rules:
#   - Mix: Turkish firms, Turkish-international hybrids, foreign firms operating
#     regionally. No joke names, no real trademarks. Names are proper nouns
#     (LANGUAGE INTEGRITY LAW exempts them).
#   - A company's character may colour an event's wording; it must never DRIVE an event's
#     subject. That one line per id sits in strings.csv as COMPANY_BG_<ID>; only the smoke
#     suite reads those rows today.
#   - The smoke suite's synthetic "Testing" sector is deliberately absent —
#     hand-built fixtures stay outside the catalog.

const COMPANIES := {
	"insurance": [   # LOC-DATA company name (proper noun)
		{"name": "Ege Sigorta", "id": "EGE_SIGORTA"},   # LOC-DATA company name (proper noun)
		{"name": "Poyraz Sigorta", "id": "POYRAZ_SIGORTA"},   # LOC-DATA company name (proper noun)
		{"name": "Deniz Sigorta", "id": "DENIZ_SIGORTA"},   # LOC-DATA company name (proper noun)
		{"name": "Adriatic Assurance", "id": "ADRIATIC_ASSURANCE"},   # LOC-DATA company name (proper noun)
		{"name": "Vega Sigorta", "id": "VEGA_SIGORTA"},   # LOC-DATA company name (proper noun)
	],
	"construction": [   # LOC-DATA company name (proper noun)
		{"name": "Kuzey İnşaat", "id": "KUZEY_INSAAT"},   # LOC-DATA company name (proper noun)
		{"name": "Anadolu Yapı", "id": "ANADOLU_YAPI"},   # LOC-DATA company name (proper noun)
		{"name": "Marmara İnşaat", "id": "MARMARA_INSAAT"},   # LOC-DATA company name (proper noun)
		{"name": "Terra Yapı", "id": "TERRA_YAPI"},   # LOC-DATA company name (proper noun)
		{"name": "Donau Bau", "id": "DONAU_BAU"},   # LOC-DATA company name (proper noun)
	],
	"logistics": [   # LOC-DATA company name (proper noun)
		{"name": "Deniz Lojistik", "id": "DENIZ_LOJISTIK"},   # LOC-DATA company name (proper noun)
		{"name": "Nordica Lojistik", "id": "NORDICA_LOJISTIK"},   # LOC-DATA company name (proper noun)
		{"name": "Ege Kargo", "id": "EGE_KARGO"},   # LOC-DATA company name (proper noun)
		{"name": "Marmara Lojistik", "id": "MARMARA_LOJISTIK"},   # LOC-DATA company name (proper noun)
		{"name": "Nordwind GmbH", "id": "NORDWIND_GMBH"},   # LOC-DATA company name (proper noun)
	],
	"health": [   # LOC-DATA company name (proper noun)
		{"name": "Aras Klinik", "id": "ARAS_KLINIK"},   # LOC-DATA company name (proper noun)
		{"name": "Marmara Klinik", "id": "MARMARA_KLINIK"},   # LOC-DATA company name (proper noun)
		{"name": "Bosphorus Sağlık", "id": "BOSPHORUS_SAGLIK"},   # LOC-DATA company name (proper noun)
		{"name": "Vita Medikal", "id": "VITA_MEDIKAL"},   # LOC-DATA company name (proper noun)
		{"name": "Medisa Grup", "id": "MEDISA_GRUP"},   # LOC-DATA company name (proper noun)
	],
	"manufacturing": [   # LOC-DATA company name (proper noun)
		{"name": "Beykoz Üretim", "id": "BEYKOZ_URETIM"},   # LOC-DATA company name (proper noun)
		{"name": "Trakya Fabrika", "id": "TRAKYA_FABRIKA"},   # LOC-DATA company name (proper noun)
		{"name": "Ege Metal", "id": "EGE_METAL"},   # LOC-DATA company name (proper noun)
		{"name": "Vulkan Döküm", "id": "VULKAN_DOKUM"},   # LOC-DATA company name (proper noun)
		{"name": "Ferrum Endüstri", "id": "FERRUM_ENDUSTRI"},   # LOC-DATA company name (proper noun)
	],
	"retail": [   # LOC-DATA company name (proper noun)
		{"name": "Anadolu Market", "id": "ANADOLU_MARKET"},   # LOC-DATA company name (proper noun)
		{"name": "Brightline Retail", "id": "BRIGHTLINE_RETAIL"},   # LOC-DATA company name (proper noun)
		{"name": "Kardelen Mağazacılık", "id": "KARDELEN_MAGAZACILIK"},   # LOC-DATA company name (proper noun)
		{"name": "Ekin Gıda Marketleri", "id": "EKIN_GIDA_MARKETLERI"},   # LOC-DATA company name (proper noun)
		{"name": "Modena Concept", "id": "MODENA_CONCEPT"},   # LOC-DATA company name (proper noun)
	],
	"real_estate": [   # LOC-DATA company name (proper noun)
		{"name": "Palmiye Holding", "id": "PALMIYE_HOLDING"},   # LOC-DATA company name (proper noun)
		{"name": "Kıyı Gayrimenkul", "id": "KIYI_GAYRIMENKUL"},   # LOC-DATA company name (proper noun)
		{"name": "Metrekare Danışmanlık", "id": "METREKARE_DANISMANLIK"},   # LOC-DATA company name (proper noun)
		{"name": "Vestera Holding", "id": "VESTERA_HOLDING"},   # LOC-DATA company name (proper noun)
		{"name": "Panorama Emlak", "id": "PANORAMA_EMLAK"},   # LOC-DATA company name (proper noun)
	],
	"textile": [   # LOC-DATA company name (proper noun)
		{"name": "Beykoz Tekstil", "id": "BEYKOZ_TEKSTIL"},   # LOC-DATA company name (proper noun)
		{"name": "Menderes Dokuma", "id": "MENDERES_DOKUMA"},   # LOC-DATA company name (proper noun)
		{"name": "İplikhane", "id": "IPLIKHANE"},   # LOC-DATA company name (proper noun)
		{"name": "Nova Tekstil", "id": "NOVA_TEKSTIL"},   # LOC-DATA company name (proper noun)
		{"name": "Aegea Textile Group", "id": "AEGEA_TEXTILE_GROUP"},   # LOC-DATA company name (proper noun)
	],
	"legal": [   # LOC-DATA company name (proper noun)
		{"name": "Bosphorus Legal", "id": "BOSPHORUS_LEGAL"},   # LOC-DATA company name (proper noun)
		{"name": "Kavanagh & Sons", "id": "KAVANAGH_SONS"},   # LOC-DATA company name (proper noun)
		{"name": "Aslan & Duru Hukuk", "id": "ASLAN_DURU_HUKUK"},   # LOC-DATA company name (proper noun)
		{"name": "Meridyen Hukuk", "id": "MERIDYEN_HUKUK"},   # LOC-DATA company name (proper noun)
		{"name": "Lex Anadolu", "id": "LEX_ANADOLU"},   # LOC-DATA company name (proper noun)
	],
	"technology": [   # LOC-DATA company name (proper noun)
		{"name": "Nexus Yazılım", "id": "NEXUS_YAZILIM"},   # LOC-DATA company name (proper noun)
		{"name": "Piksel Teknoloji", "id": "PIKSEL_TEKNOLOJI"},   # LOC-DATA company name (proper noun)
		{"name": "Volt Sistemleri", "id": "VOLT_SISTEMLERI"},   # LOC-DATA company name (proper noun)
		{"name": "Atlas Bilişim", "id": "ATLAS_BILISIM"},   # LOC-DATA company name (proper noun)
		{"name": "Origo Labs", "id": "ORIGO_LABS"},   # LOC-DATA company name (proper noun)
	],
	"ecommerce": [   # LOC-DATA company name (proper noun)
		{"name": "Sepet Ticaret", "id": "SEPET_TICARET"},   # LOC-DATA company name (proper noun)
		{"name": "Hızlı Pazar", "id": "HIZLI_PAZAR"},   # LOC-DATA company name (proper noun)
		{"name": "Vitrin Online", "id": "VITRIN_ONLINE"},   # LOC-DATA company name (proper noun)
		{"name": "Loka Store", "id": "LOKA_STORE"},   # LOC-DATA company name (proper noun)
		{"name": "Adriatica Market", "id": "ADRIATICA_MARKET"},   # LOC-DATA company name (proper noun)
	],
	"media": [   # LOC-DATA company name (proper noun)
		{"name": "Kanal Medya", "id": "KANAL_MEDYA"},   # LOC-DATA company name (proper noun)
		{"name": "Punto Yayın", "id": "PUNTO_YAYIN"},   # LOC-DATA company name (proper noun)
		{"name": "Ekran Prodüksiyon", "id": "EKRAN_PRODUKSIYON"},   # LOC-DATA company name (proper noun)
		{"name": "Anadolu Digital", "id": "ANADOLU_DIGITAL"},   # LOC-DATA company name (proper noun)
		{"name": "Nordlicht Studio", "id": "NORDLICHT_STUDIO"},   # LOC-DATA company name (proper noun)
	],
	"finance": [   # LOC-DATA company name (proper noun)
		{"name": "Kule Finans", "id": "KULE_FINANS"},   # LOC-DATA company name (proper noun)
		{"name": "Argos Yatırım", "id": "ARGOS_YATIRIM"},   # LOC-DATA company name (proper noun)
		{"name": "Pusula Portföy", "id": "PUSULA_PORTFOY"},   # LOC-DATA company name (proper noun)
		{"name": "Helvetia Data AG", "id": "HELVETIA_DATA_AG"},   # LOC-DATA company name (proper noun)
		{"name": "Lira Kapital", "id": "LIRA_KAPITAL"},   # LOC-DATA company name (proper noun)
	],
}


static func all() -> Array:
	# Flattened [{name, sector, id}] — smoke integrity checks iterate this.
	var out: Array = []
	for sector in COMPANIES:
		for rec in COMPANIES[sector]:
			out.append({"name": rec["name"], "sector": sector, "id": rec["id"]})
	return out


static func names_for_sector(sector: String) -> Array:
	# Name strings only. Unknown sector → empty array (no shared fallback).
	var out: Array = []
	for rec in COMPANIES.get(sector, []):
		out.append(rec["name"])
	return out
