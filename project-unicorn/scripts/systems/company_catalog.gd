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
		"Ege Sigorta",   # LOC-DATA company name (proper noun)
		"Poyraz Sigorta",   # LOC-DATA company name (proper noun)
		"Deniz Sigorta",   # LOC-DATA company name (proper noun)
		"Adriatic Assurance",   # LOC-DATA company name (proper noun)
		"Vega Sigorta",   # LOC-DATA company name (proper noun)
	],
	"construction": [   # LOC-DATA company name (proper noun)
		"Kuzey İnşaat",   # LOC-DATA company name (proper noun)
		"Anadolu Yapı",   # LOC-DATA company name (proper noun)
		"Marmara İnşaat",   # LOC-DATA company name (proper noun)
		"Terra Yapı",   # LOC-DATA company name (proper noun)
		"Donau Bau",   # LOC-DATA company name (proper noun)
	],
	"logistics": [   # LOC-DATA company name (proper noun)
		"Deniz Lojistik",   # LOC-DATA company name (proper noun)
		"Nordica Lojistik",   # LOC-DATA company name (proper noun)
		"Ege Kargo",   # LOC-DATA company name (proper noun)
		"Marmara Lojistik",   # LOC-DATA company name (proper noun)
		"Nordwind GmbH",   # LOC-DATA company name (proper noun)
	],
	"health": [   # LOC-DATA company name (proper noun)
		"Aras Klinik",   # LOC-DATA company name (proper noun)
		"Marmara Klinik",   # LOC-DATA company name (proper noun)
		"Bosphorus Sağlık",   # LOC-DATA company name (proper noun)
		"Vita Medikal",   # LOC-DATA company name (proper noun)
		"Medisa Grup",   # LOC-DATA company name (proper noun)
	],
	"manufacturing": [   # LOC-DATA company name (proper noun)
		"Beykoz Üretim",   # LOC-DATA company name (proper noun)
		"Trakya Fabrika",   # LOC-DATA company name (proper noun)
		"Ege Metal",   # LOC-DATA company name (proper noun)
		"Vulkan Döküm",   # LOC-DATA company name (proper noun)
		"Ferrum Endüstri",   # LOC-DATA company name (proper noun)
	],
	"retail": [   # LOC-DATA company name (proper noun)
		"Anadolu Market",   # LOC-DATA company name (proper noun)
		"Brightline Retail",   # LOC-DATA company name (proper noun)
		"Kardelen Mağazacılık",   # LOC-DATA company name (proper noun)
		"Ekin Gıda Marketleri",   # LOC-DATA company name (proper noun)
		"Modena Concept",   # LOC-DATA company name (proper noun)
	],
	"real_estate": [   # LOC-DATA company name (proper noun)
		"Palmiye Holding",   # LOC-DATA company name (proper noun)
		"Kıyı Gayrimenkul",   # LOC-DATA company name (proper noun)
		"Metrekare Danışmanlık",   # LOC-DATA company name (proper noun)
		"Vestera Holding",   # LOC-DATA company name (proper noun)
		"Panorama Emlak",   # LOC-DATA company name (proper noun)
	],
	"textile": [   # LOC-DATA company name (proper noun)
		"Beykoz Tekstil",   # LOC-DATA company name (proper noun)
		"Menderes Dokuma",   # LOC-DATA company name (proper noun)
		"İplikhane",   # LOC-DATA company name (proper noun)
		"Nova Tekstil",   # LOC-DATA company name (proper noun)
		"Aegea Textile Group",   # LOC-DATA company name (proper noun)
	],
	"legal": [   # LOC-DATA company name (proper noun)
		"Bosphorus Legal",   # LOC-DATA company name (proper noun)
		"Kavanagh & Sons",   # LOC-DATA company name (proper noun)
		"Aslan & Duru Hukuk",   # LOC-DATA company name (proper noun)
		"Meridyen Hukuk",   # LOC-DATA company name (proper noun)
		"Lex Anadolu",   # LOC-DATA company name (proper noun)
	],
	"technology": [   # LOC-DATA company name (proper noun)
		"Nexus Yazılım",   # LOC-DATA company name (proper noun)
		"Piksel Teknoloji",   # LOC-DATA company name (proper noun)
		"Volt Sistemleri",   # LOC-DATA company name (proper noun)
		"Atlas Bilişim",   # LOC-DATA company name (proper noun)
		"Origo Labs",   # LOC-DATA company name (proper noun)
	],
	"ecommerce": [   # LOC-DATA company name (proper noun)
		"Sepet Ticaret",   # LOC-DATA company name (proper noun)
		"Hızlı Pazar",   # LOC-DATA company name (proper noun)
		"Vitrin Online",   # LOC-DATA company name (proper noun)
		"Loka Store",   # LOC-DATA company name (proper noun)
		"Adriatica Market",   # LOC-DATA company name (proper noun)
	],
	"media": [   # LOC-DATA company name (proper noun)
		"Kanal Medya",   # LOC-DATA company name (proper noun)
		"Punto Yayın",   # LOC-DATA company name (proper noun)
		"Ekran Prodüksiyon",   # LOC-DATA company name (proper noun)
		"Anadolu Digital",   # LOC-DATA company name (proper noun)
		"Nordlicht Studio",   # LOC-DATA company name (proper noun)
	],
	"finance": [   # LOC-DATA company name (proper noun)
		"Kule Finans",   # LOC-DATA company name (proper noun)
		"Argos Yatırım",   # LOC-DATA company name (proper noun)
		"Pusula Portföy",   # LOC-DATA company name (proper noun)
		"Helvetia Data AG",   # LOC-DATA company name (proper noun)
		"Lira Kapital",   # LOC-DATA company name (proper noun)
	],
}


static func names_for_sector(sector: String) -> Array:
	# A mutable copy of the sector's names. Unknown sector → empty array (no shared fallback).
	return (COMPANIES.get(sector, []) as Array).duplicate()
