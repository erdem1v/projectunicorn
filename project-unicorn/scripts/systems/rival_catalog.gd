class_name RivalCatalog
extends RefCounted

# Read-only rival seed data (Product Lifecycle Part 1). Mirrors ProductCatalog:
# hardcoded GDScript const now, JSON externalization is content-phase work.
#
# Per sub-product-type: 8 rivals = 1 giant + 2 established + 5 startup. Dimension
# numbers come from a shared TEMPLATE so the tier BANDS are consistent across every
# type (which is what makes the structural giant-unreachable guarantee hold — see
# rival_registry.gd). Names are per-type flavor (working; Erdem revises in content).
#
# TEMPLATE index order matches tier order: [giant, established, established,
# startup, startup, startup, startup, startup].
#
# Composite bands (equal-weight, for reference — actual composite is type-weighted):
#   giant       ≈ 285   (asymptote 330, momentum 0 → static)
#   established ≈ 140-161
#   startup     ≈ 32-71  (asymptote 100)
# A Phase-1 player's composite stays < 110 by construction (QualityModel.grow),
# so the player can brush the established floor but never enters the giant band.
# All numbers BALANCE-TUNABLE.
const TEMPLATE := [
	{"tier": "giant",       "innovation": 290.0, "stability": 280.0, "experience": 285.0, "momentum": 0.0},
	{"tier": "established", "innovation": 165.0, "stability": 150.0, "experience": 168.0, "momentum": 0.10},
	{"tier": "established", "innovation": 138.0, "stability": 132.0, "experience": 150.0, "momentum": 0.08},
	{"tier": "startup",     "innovation": 82.0,  "stability": 58.0,  "experience": 74.0,  "momentum": 0.70},
	{"tier": "startup",     "innovation": 64.0,  "stability": 50.0,  "experience": 66.0,  "momentum": 0.60},
	{"tier": "startup",     "innovation": 50.0,  "stability": 42.0,  "experience": 56.0,  "momentum": 0.55},
	{"tier": "startup",     "innovation": 40.0,  "stability": 35.0,  "experience": 46.0,  "momentum": 0.50},
	{"tier": "startup",     "innovation": 31.0,  "stability": 30.0,  "experience": 37.0,  "momentum": 0.45},
]

# Per-type product names (index 0 = giant, 1-2 = established, 3-7 = startup).
const NAMES := {
	"ai_assistant":      ["OpenChat", "Claria", "Muse AI", "Kestrel", "Pocket Aide", "Verba", "Nook", "Echo Desk"],
	"ai_photo_editor":   ["PixelForge", "Retušo", "Lumina", "SnapMint", "GlowKit", "Frame9", "Tint", "Kolaj"],
	"ai_code_copilot":   ["DevPilot", "Cursor+", "Syntaxa", "PairUp", "Loopcraft", "Semic", "Refacto", "Junie"],
	"ai_multimodal_app": ["OmniStudio", "Polymind", "Fusio", "MixModal", "Vizion", "Sesbir", "Multi", "Kanvas"],
	"ai_vector_search":  ["VectorScale", "Pinelake", "Embedda", "Nöronet", "Simqore", "Metrika", "Aramax", "Indexa"],
	"saas_project_mgmt": ["Asana", "MonDay", "Trellium", "Sprintboard", "Kanbo", "Planera", "Tasket", "Roadmapp"],
	"saas_crm":          ["Salesloop", "HubOrbit", "Pipeplus", "Dealflow", "Leada", "CRMkolay", "Kontakt", "Satışçı"],
	"saas_analytics":    ["Lookera", "Metrion", "Dashy", "Insighta", "Grafkatör", "Queryn", "Panelist", "Veritas"],
	"saas_billing":      ["Stripe+", "Faturon", "Billwise", "Tahsila", "Subskript", "Prorata", "Ödemely", "Recurro"],
	"saas_dev_tools":    ["Datadoggo", "Sentrio", "Logstream", "CIforge", "Sandboxy", "Devkit", "APIgate", "Terminus"],
}


# Build one Rival per (sub-type, TEMPLATE row). Status is set by RivalRegistry.
static func build_all() -> Array:
	var out: Array = []
	for subgenre in ProductCatalog.SUB_PRODUCT_TYPES:
		for rec in ProductCatalog.SUB_PRODUCT_TYPES[subgenre]:
			var sub_id: String = String(rec.get("id", ""))
			if sub_id == "":
				continue
			var names: Array = NAMES.get(sub_id, [])
			for i in TEMPLATE.size():
				var t: Dictionary = TEMPLATE[i]
				var r := Rival.new()
				r.id = "rv_%s_%d" % [sub_id, i]
				r.product_name = String(names[i]) if i < names.size() else "%s #%d" % [sub_id, i]
				r.sub_product_type_id = sub_id
				r.tier = String(t["tier"])
				r.innovation = float(t["innovation"])
				r.stability = float(t["stability"])
				r.experience = float(t["experience"])
				r.momentum = float(t["momentum"])
				out.append(r)
	return out
