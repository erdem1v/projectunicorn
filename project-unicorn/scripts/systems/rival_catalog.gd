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
#
# TESCİLLİ MARKA YASAĞI (CompanyCatalog'un adlandırma yasası, aynı kural burada da
# geçerli): gerçek marka yok, şaka ad yok. Bu tablo bir zamanlar oyuncunun ODA
# panosunda, ticker'da ve Ürün sekmesinde GERÇEK rakiplerin tescilli adlarını
# gösteriyordu — üstelik trademark sahibiyle AYNI pazarda rakip ENTITY olarak, ki bu
# bir metin içinde markadan söz etmekten bambaşka bir maruziyet sınıfı. CompanyCatalog
# temizlenirken (Anadolu Sigorta → Poyraz Sigorta) bu dosya atlanmıştı; 2026-08-07
# süpürmesinde kapatıldı. İNDEKS SIRASI KİLİTLİ: TEMPLATE tier'ları ve SHARE_SEED
# payları indeks-hizalı, o yüzden adlar YERİNDE değişir, asla yeniden sıralanmaz.
const NAMES := {
	"ai_assistant":      ["Refik AI", "Aselia", "Perga AI", "Kestrel", "Pocket Aide", "Söyleç", "Kovan", "Echo Desk"],   # LOC-DATA product name (proper noun)
	"ai_photo_editor":   ["PixelForge", "Retušo", "Işılt", "Kadraj", "GlowKit", "Frame9", "Poz", "Kolaj"],   # LOC-DATA product name (proper noun)
	"ai_code_copilot":   ["Zanaat", "Kalfa", "Syntaxa", "PairUp", "Loopcraft", "Semic", "Refacto", "Çırak"],   # LOC-DATA product name (proper noun)
	"ai_vector_search":  ["VectorScale", "Bulgu", "Embedda", "Nöronet", "Simqore", "Nirengi", "İzsürer", "Fihrist"],   # LOC-DATA product name (proper noun)
	"saas_project_mgmt": ["Vardiya", "Çizelge", "Panoya", "Sprintboard", "Dizge", "Tasarı", "Tasket", "Roadmapp"],   # LOC-DATA product name (proper noun)
	"saas_crm":          ["Sadakat", "Yörünge", "Pipeplus", "Dealflow", "Leada", "CRMkolay", "Rehber", "Satışçı"],   # LOC-DATA product name (proper noun)
	"saas_analytics":    ["Mercek", "Metrion", "Dashy", "Insighta", "Grafkatör", "Queryn", "Panelist", "Sağlama"],   # LOC-DATA product name (proper noun)
	"saas_billing":      ["Kasadar", "Faturon", "Billwise", "Tahsila", "Subskript", "Oranla", "Ödemely", "Recurro"],   # LOC-DATA product name (proper noun)
	"saas_dev_tools":    ["Nöbetçi", "Karakol", "Kütükçü", "CIforge", "Sandboxy", "Devkit", "APIgate", "Uçbirim"],   # LOC-DATA product name (proper noun)
	"saas_ops":          ["FlowSuite", "Prosedo", "Operanda", "Akista", "Otomo", "Süreçly", "Rutin", "Adımla"],   # LOC-DATA product name (proper noun)
}
# (Dünya İnandırıcılığı onarımı: saas_ops satırı eklendi — canlı üründü ama isimsizdi,
# board'da "saas_ops #0..7" fallback'i görünüyordu. Yetim ai_multimodal_app satırı
# silindi — o alt-tür ProductCatalog'dan kaldırılmıştı.)


# ======================= Pazar payı seed'leri (Fix 3) ==========================
# LİG çerçevesinin yerini alan pazar payı modelinin veri tabanı. TEMPLATE ile
# indeks-hizalı: SHARE_SEED[i], TEMPLATE[i] rakibinin pazar payı yüzdesi çekirdeği.
# Bir avuç büyük firma pazarın çoğunu tutar; startup'lar oyuncunun bandına yakın
# küçük dilimlerde oturur. Payların toplamı 100 olmak zorunda DEĞİL — kalan,
# snapshot'ta "uzun kuyruk" (diğerleri) dilimi olur. Tümü WORKING (curve seansı).
const SHARE_SEED := [34.0, 16.0, 11.0, 2.6, 1.9, 1.4, 0.9, 0.5]

# Yalnız-pay pazar aktörleri: her alt-tür pazarında AYNI adlarla görünen, holding
# tarzı global oyuncular. Rival ENTITY DEĞİLLER — kalite ligi, ekonomi bağı
# (_rival_relative_quality), VC sorgusu ve rank API'si onları hiç görmez; yalnız
# get_market_snapshot dilim üretir. Adlandırılmış rakip sayısını pazar başına
# 8+3 = 11'e çıkarırlar (görev bandı 8-12). Paylar + momentum WORKING.
# (Marka süpürmesi 2026-08-07: "Doruk Teknoloji Holding" YAŞAYAN bir Türk markasıydı —
# CompanyCatalog'da temizlenen Anadolu Sigorta/Anadolu Yatırım ile aynı sınıf, ve bu
# aktörler ODA panosunda pazar payı satırı olarak GÖRÜNÜYOR. "Silverbirch Software" da
# gerçek bir yazılım firması. İkisi de aynı anlam alanında kurgusal karşılıklarıyla
# değişti; id'ler kasten korundu, çünkü kayıtlı durum ve shot fixture'ları onlara bakar.)
const MARKET_ACTORS := [
	{"id": "ma_silverbirch", "name": "Akkavak Yazılım", "share": 6.5, "momentum": 0.06},   # LOC-DATA market actor name (proper noun)
	{"id": "ma_doruk",       "name": "Yalçın Teknoloji Holding", "share": 5.2, "momentum": 0.10},   # LOC-DATA market actor name (proper noun)
	{"id": "ma_ostrand",     "name": "Ostrand Systems", "share": 3.8, "momentum": 0.08},   # LOC-DATA market actor name (proper noun)
]

# Modellenen pazarın toplam aylık geliri (MRR cinsinden). Oyuncunun payı =
# GameState.mrr / bu sabit. WORKING — kalibrasyon defteri maddesi (2026-08-06):
# MRR 5.000 (Traction hedefi) → %0,33; erken oyun → %0,1 altı ("kıymık");
# Series A kapısı bandındaki oyuncu (~40-80K MRR) → ~%2,7-5,3. His meselesi,
# curve seansında tartışılacak — şimdilik dokunma.
const MARKET_TOTAL_MRR := 1_500_000


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
				r.id = "rv_%s_%d" % [sub_id, i]   # LOC-DATA rival id
				r.product_name = String(names[i]) if i < names.size() else "%s #%d" % [sub_id, i]
				r.sub_product_type_id = sub_id
				r.tier = String(t["tier"])
				r.innovation = float(t["innovation"])
				r.stability = float(t["stability"])
				r.experience = float(t["experience"])
				r.momentum = float(t["momentum"])
				out.append(r)
	return out
