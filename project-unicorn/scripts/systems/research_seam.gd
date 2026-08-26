class_name ResearchSeam
extends RefCounted

# GDD — ÜRÜN MODÜLÜ rev 6.1 §12.5 · AR-GE KAPISI, henüz ağacı olmayan.
#
# K3 kademeleri Ar-Ge düğümü ister. Ar-Ge modülü kendi paketiyle gelir (Ar-Ge GDD
# rev 1.1). O gelene kadar `completed()` HER DÜĞÜM İÇİN false döner ve K3'ler
# kilitli kalır. BU BİR HATA DEĞİL, SIRALAMADIR — belge açıkça yazıyor: "geçici
# bypass yazılmaz."
#
# Ar-Ge paketi indiğinde DEĞİŞECEK TEK ŞEY `completed()`in gövdesidir: gerçek
# ağaca sorar. Çağıran taraf (LineGates) hiç değişmez.
#
# DÜĞÜM KİMLİKLERİNİN TEK KAYNAĞI Ar-Ge GDD §4'tür (20 düğüm). rev 6.1 öncesinde
# bu dosyada altı isim vardı ve ikisi (data_model · security_cert) o listede
# yoktu; tablo aşağıda Ar-Ge §4'ten birebir alınmıştır.

## Ar-Ge §3 — kademeli açılan dal yapısı. Her ailede bir KÖK, iki DAL, iki DEVAM.
## Oyuncu ağacın tamamını asla görmez.
const PLACE_ROOT := "root"
const PLACE_BRANCH := "branch"
const PLACE_CONT := "continuation"

const FAMILY_CAPABILITY := "capability"   # Ürün alanı
const FAMILY_PLATFORM := "platform"       # Yazılım alanı
const FAMILY_PRACTICE := "practice"       # Test alanı
const FAMILY_DESIGN := "design"           # Tasarım alanı

## The twenty nodes, verbatim from Ar-Ge GDD §4.1-§4.4.
## `name_key` resolves through the localization layer — the names are Turkish
## canonical (Veri Modeli, Semantik İndeks…), not proper nouns, so they translate.
## The Ar-Ge package may take these keys over; until then this module owns them
## because the lock line has to print a name today.
const NODES := {
	# --- §4.1 CAPABILITY — Ürün alanı ---
	"data_model":         {"family": "capability", "place": "root"},
	"ai_engine":          {"family": "capability", "place": "branch"},
	"semantic_index":     {"family": "capability", "place": "branch"},
	"edge_inference":     {"family": "capability", "place": "continuation"},
	"knowledge_graph":    {"family": "capability", "place": "continuation"},
	# --- §4.2 PLATFORM — Yazılım alanı ---
	"scalable_backend":   {"family": "platform", "place": "root"},
	"security_cert":      {"family": "platform", "place": "branch"},
	"analytics_engine":   {"family": "platform", "place": "branch"},
	"model_optimization": {"family": "platform", "place": "continuation"},
	"data_warehouse":     {"family": "platform", "place": "continuation"},
	# --- §4.3 PRACTICE — Test alanı ---
	"bug_tracker":        {"family": "practice", "place": "root"},
	"cicd":               {"family": "practice", "place": "branch"},
	"test_automation":    {"family": "practice", "place": "branch"},
	"incident_playbook":  {"family": "practice", "place": "continuation"},
	"self_service":       {"family": "practice", "place": "continuation"},
	# --- §4.4 DESIGN — Tasarım alanı ---
	"design_system":      {"family": "design", "place": "root"},
	"user_research":      {"family": "design", "place": "branch"},
	"onboarding_flow":    {"family": "design", "place": "branch"},
	"accessibility":      {"family": "design", "place": "continuation"},
	"personalization":    {"family": "design", "place": "continuation"},
}

## §12.5 — the BINDING shared-line K3 map. Identical in all three subtypes, and
## `ProductLines` validates the content files against it, so a content edit cannot
## quietly drift away from the tree.
const SHARED_LINE_NODES := {
	"line_shared_integrations": "data_model",
	"line_shared_durability":   "scalable_backend",
	"line_shared_security":     "security_cert",
	"line_shared_mobile":       "design_system",
}

## Ar-Ge §4 "Açtığı şey" — the ten Ürün-side constants a completed node will move.
## NOTHING READS THIS YET. It exists so the R&D package is a value change rather
## than a hunt: each named constant lives in the system that owns the arithmetic,
## and this table says which node reaches for it.
const NODE_EFFECTS := {
	"scalable_backend":   "InfraSystem.LOAD_DIVISOR 20 -> 28",
	"bug_tracker":        "SupportSystem.VALIDATION_COEF 0.8 -> 1.0",
	"cicd":               "ProductSystem.BUG_RATE_CEIL 0.45 -> 0.35",
	"test_automation":    "ProductSystem.BETA_DECAY 0.85 -> 0.90",
	"incident_playbook":  "InfraSystem.OVERAGE_SATISFACTION -0.8 -> -0.5",
	"self_service":       "SupportSystem.INFLOW_BASE 0.2 -> 0.14",
	"model_optimization": "ProductLines licence cost -40%",
	"onboarding_flow":    "SalesSystem B2C conversion x1.15",
	"design_system":      "experience-step effort -20%",
	"edge_inference":     "AI-step usage weight -1",
}


## Has this research node been completed? Always false until the Ar-Ge package
## lands. Callers must not special-case the absence.
static func completed(node_id: String) -> bool:
	if not NODES.has(node_id):
		push_error("[ResearchSeam] unknown node '%s'" % node_id)
		return false
	return RnDSystem.node_completed(node_id)


static func is_node(node_id: String) -> bool:
	return NODES.has(node_id)


## Ar-Ge §3.1 ADALET KURALI — "Telegraflanmış hiçbir şey ulaşılmaz olmaz."
## A visible locked K3 binds to a root or a branch, never to a continuation node;
## continuation nodes carry content that was never promised. `ProductLines`
## enforces this at load.
static func placement(node_id: String) -> String:
	return String((NODES.get(node_id, {}) as Dictionary).get("place", ""))


static func family(node_id: String) -> String:
	return String((NODES.get(node_id, {}) as Dictionary).get("family", ""))


static func may_gate_visible_step(node_id: String) -> bool:
	var place: String = placement(node_id)
	return place == PLACE_ROOT or place == PLACE_BRANCH


## The name the lock line prints: Kilit: Ar-Ge "Veri Modeli" ✗ → Araştır
## Falls back to the raw id so a bad content file is visible on screen rather
## than silently blank.
static func node_name(node_id: String) -> String:
	if not NODES.has(node_id):
		return node_id
	var key: String = name_key(node_id)
	var out: String = TranslationServer.translate(key)
	return node_id if out == key else out


static func name_key(node_id: String) -> String:
	return "PROD_RND_NODE_%s" % node_id.to_upper()


## True once the real tree exists. §12.9: before it lands the "→ Araştır" link
## renders but is INERT, and its hover says so.
static func tree_available() -> bool:
	return RnDSystem.tree_open()
