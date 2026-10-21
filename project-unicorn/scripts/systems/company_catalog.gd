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
#     subject.
#   - The smoke suite's synthetic "Testing" sector is deliberately absent —
#     hand-built fixtures stay outside the catalog.

const COMPANIES := {
	"insurance": [   # LOC-DATA company name (proper noun)
		{"name": "Ege Sigorta"},   # LOC-DATA company name (proper noun)
		{"name": "Poyraz Sigorta"},   # LOC-DATA company name (proper noun)
		{"name": "Deniz Sigorta"},   # LOC-DATA company name (proper noun)
		{"name": "Adriatic Assurance"},   # LOC-DATA company name (proper noun)
		{"name": "Vega Sigorta"},   # LOC-DATA company name (proper noun)
	],
	"construction": [   # LOC-DATA company name (proper noun)
		{"name": "Kuzey İnşaat"},   # LOC-DATA company name (proper noun)
		{"name": "Anadolu Yapı"},   # LOC-DATA company name (proper noun)
		{"name": "Marmara İnşaat"},   # LOC-DATA company name (proper noun)
		{"name": "Terra Yapı"},   # LOC-DATA company name (proper noun)
		{"name": "Donau Bau"},   # LOC-DATA company name (proper noun)
	],
	"logistics": [   # LOC-DATA company name (proper noun)
		{"name": "Deniz Lojistik"},   # LOC-DATA company name (proper noun)
		{"name": "Nordica Lojistik"},   # LOC-DATA company name (proper noun)
		{"name": "Ege Kargo"},   # LOC-DATA company name (proper noun)
		{"name": "Marmara Lojistik"},   # LOC-DATA company name (proper noun)
		{"name": "Nordwind GmbH"},   # LOC-DATA company name (proper noun)
	],
	"health": [   # LOC-DATA company name (proper noun)
		{"name": "Aras Klinik"},   # LOC-DATA company name (proper noun)
		{"name": "Marmara Klinik"},   # LOC-DATA company name (proper noun)
		{"name": "Bosphorus Sağlık"},   # LOC-DATA company name (proper noun)
		{"name": "Vita Medikal"},   # LOC-DATA company name (proper noun)
		{"name": "Medisa Grup"},   # LOC-DATA company name (proper noun)
	],
	"manufacturing": [   # LOC-DATA company name (proper noun)
		{"name": "Beykoz Üretim"},   # LOC-DATA company name (proper noun)
		{"name": "Trakya Fabrika"},   # LOC-DATA company name (proper noun)
		{"name": "Ege Metal"},   # LOC-DATA company name (proper noun)
		{"name": "Vulkan Döküm"},   # LOC-DATA company name (proper noun)
		{"name": "Ferrum Endüstri"},   # LOC-DATA company name (proper noun)
	],
	"retail": [   # LOC-DATA company name (proper noun)
		{"name": "Anadolu Market"},   # LOC-DATA company name (proper noun)
		{"name": "Brightline Retail"},   # LOC-DATA company name (proper noun)
		{"name": "Kardelen Mağazacılık"},   # LOC-DATA company name (proper noun)
		{"name": "Ekin Gıda Marketleri"},   # LOC-DATA company name (proper noun)
		{"name": "Modena Concept"},   # LOC-DATA company name (proper noun)
	],
	"real_estate": [   # LOC-DATA company name (proper noun)
		{"name": "Palmiye Holding"},   # LOC-DATA company name (proper noun)
		{"name": "Kıyı Gayrimenkul"},   # LOC-DATA company name (proper noun)
		{"name": "Metrekare Danışmanlık"},   # LOC-DATA company name (proper noun)
		{"name": "Vestera Holding"},   # LOC-DATA company name (proper noun)
		{"name": "Panorama Emlak"},   # LOC-DATA company name (proper noun)
	],
	"textile": [   # LOC-DATA company name (proper noun)
		{"name": "Beykoz Tekstil"},   # LOC-DATA company name (proper noun)
		{"name": "Menderes Dokuma"},   # LOC-DATA company name (proper noun)
		{"name": "İplikhane"},   # LOC-DATA company name (proper noun)
		{"name": "Nova Tekstil"},   # LOC-DATA company name (proper noun)
		{"name": "Aegea Textile Group"},   # LOC-DATA company name (proper noun)
	],
	"legal": [   # LOC-DATA company name (proper noun)
		{"name": "Bosphorus Legal"},   # LOC-DATA company name (proper noun)
		{"name": "Kavanagh & Sons"},   # LOC-DATA company name (proper noun)
		{"name": "Aslan & Duru Hukuk"},   # LOC-DATA company name (proper noun)
		{"name": "Meridyen Hukuk"},   # LOC-DATA company name (proper noun)
		{"name": "Lex Anadolu"},   # LOC-DATA company name (proper noun)
	],
	"technology": [   # LOC-DATA company name (proper noun)
		{"name": "Nexus Yazılım"},   # LOC-DATA company name (proper noun)
		{"name": "Piksel Teknoloji"},   # LOC-DATA company name (proper noun)
		{"name": "Volt Sistemleri"},   # LOC-DATA company name (proper noun)
		{"name": "Atlas Bilişim"},   # LOC-DATA company name (proper noun)
		{"name": "Origo Labs"},   # LOC-DATA company name (proper noun)
	],
	"ecommerce": [   # LOC-DATA company name (proper noun)
		{"name": "Sepet Ticaret"},   # LOC-DATA company name (proper noun)
		{"name": "Hızlı Pazar"},   # LOC-DATA company name (proper noun)
		{"name": "Vitrin Online"},   # LOC-DATA company name (proper noun)
		{"name": "Loka Store"},   # LOC-DATA company name (proper noun)
		{"name": "Adriatica Market"},   # LOC-DATA company name (proper noun)
	],
	"media": [   # LOC-DATA company name (proper noun)
		{"name": "Kanal Medya"},   # LOC-DATA company name (proper noun)
		{"name": "Punto Yayın"},   # LOC-DATA company name (proper noun)
		{"name": "Ekran Prodüksiyon"},   # LOC-DATA company name (proper noun)
		{"name": "Anadolu Digital"},   # LOC-DATA company name (proper noun)
		{"name": "Nordlicht Studio"},   # LOC-DATA company name (proper noun)
	],
	"finance": [   # LOC-DATA company name (proper noun)
		{"name": "Kule Finans"},   # LOC-DATA company name (proper noun)
		{"name": "Argos Yatırım"},   # LOC-DATA company name (proper noun)
		{"name": "Pusula Portföy"},   # LOC-DATA company name (proper noun)
		{"name": "Helvetia Data AG"},   # LOC-DATA company name (proper noun)
		{"name": "Lira Kapital"},   # LOC-DATA company name (proper noun)
	],
}


static func names_for_sector(sector: String) -> Array:
	# Name strings only. Unknown sector → empty array (no shared fallback).
	var out: Array = []
	for rec in COMPANIES.get(sector, []):
		out.append(rec["name"])
	return out
