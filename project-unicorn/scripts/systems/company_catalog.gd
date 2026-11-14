class_name CompanyCatalog
extends RefCounted

# Company catalog — the curated head of each sector's name pool (SalesNamePool puts these
# names first, then its generated ones). The ERP buyer sectors (`erp.json` `buyer_sectors`); wholesale, auto parts
# and food have no curated names and draw from the generated pool alone.
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
	"textile": [   # LOC-DATA company name (proper noun)
		"Beykoz Tekstil",   # LOC-DATA company name (proper noun)
		"Menderes Dokuma",   # LOC-DATA company name (proper noun)
		"İplikhane",   # LOC-DATA company name (proper noun)
		"Nova Tekstil",   # LOC-DATA company name (proper noun)
		"Aegea Textile Group",   # LOC-DATA company name (proper noun)
	],
	"ecommerce": [   # LOC-DATA company name (proper noun)
		"Sepet Ticaret",   # LOC-DATA company name (proper noun)
		"Hızlı Pazar",   # LOC-DATA company name (proper noun)
		"Vitrin Online",   # LOC-DATA company name (proper noun)
		"Loka Store",   # LOC-DATA company name (proper noun)
		"Adriatica Market",   # LOC-DATA company name (proper noun)
	],
}


static func names_for_sector(sector: String) -> Array:
	# A mutable copy of the sector's names. Unknown sector → empty array (no shared fallback).
	return (COMPANIES.get(sector, []) as Array).duplicate()
