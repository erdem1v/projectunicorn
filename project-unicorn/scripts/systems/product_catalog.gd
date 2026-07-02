class_name ProductCatalog
extends RefCounted

# Read-only catalog data for sub-product types and feature pools.
# Hardcoded for demo; JSON externalization to data/products/ is content-phase
# work. Voice strings are working drafts — Erdem revises in content pass.

# market_type ("b2c" | "b2b") drives the PostShip sales model (Spec PostShip §A):
# B2C → audience/organic + growth decisions; B2B → prospect + pitch dialogue.
# First pass is binary; hybrids are future work. Erdem may revise the marking.
# Product Lifecycle Part 1: `name_human` = jargon-free display name, `bet` =
# founder-voice market bet (shown as the type card's two lines). `name` kept as a
# short internal label + fallback. Multi-Modal App removed (Erdem: "kimse tıklamaz").
# Working TR — Erdem content-revises.
const SUB_PRODUCT_TYPES := {
	"ai": [
		{"id": "ai_assistant", "name": "AI Assistant", "name_human": "Yapay Zeka Asistanı",
			"bet": "İnsanların her gün sorduğu şeye hızlı, temiz cevap. ChatGPT'nin üşendiği nişi kap.",
			"pitch": "ChatGPT'nin yetmediği yerlerde devreye giren asistan.", "market_type": "b2c"},
		{"id": "ai_photo_editor", "name": "Photo Editor", "name_human": "Görsel Düzenleyici",
			"bet": "Photoshop açmaya üşenen milyonlar var. Tek tıkla iyi görünsünler, para versinler.",
			"pitch": "Photoshop'un karmaşıklığını unutturan bir araç.", "market_type": "b2c", "price_tendency": "volume"},
		{"id": "ai_code_copilot", "name": "Code Copilot", "name_human": "Kod Yazan Asistan",
			"bet": "Junior geliştiriciye 7/24 duran bir kıdemli. Güvenini kazan, ekipleri peşinden gelsin.",
			"pitch": "Junior developer'lar için en iyi pair programmer.", "market_type": "b2c"},
		{"id": "ai_vector_search", "name": "Vector Search", "name_human": "Kurumsal Arama",
			"bet": "Şirketler kendi verisinde kayboluyor. Anlamlı aramayı sat, IT bütçesi açılır.",
			"pitch": "Veri arama, ama anlama getir.", "market_type": "b2b", "price_tendency": "premium"},
	],
	"saas": [
		{"id": "saas_project_mgmt", "name": "Project Management", "name_human": "Proje Yönetimi",
			"bet": "Asana'dan bıkan çok. Daha hafif, daha hızlı bir alternatif ol.",
			"pitch": "Asana ölmedi, sadece arkanı dönmüş. Bunu yenilemek için bir fırsat.", "market_type": "b2b"},
		{"id": "saas_crm", "name": "CRM", "name_human": "Müşteri Takip (CRM)",
			"bet": "Satış ekipleri deal kaybediyor. Hepsini tek ekranda topla, vazgeçemesinler.",
			"pitch": "Sales takip platformu. Müşteri kaybeden satıcı yok.", "market_type": "b2b"},
		{"id": "saas_analytics", "name": "Analytics Dashboard", "name_human": "Veri Panosu",
			"bet": "Yönetici grafiğe para verir. Karmaşık veriyi tek bakışta anlaşılır yap.",
			"pitch": "Veriyi grafik haline getir. Yöneticiler bunun için para verir.", "market_type": "b2b"},
		{"id": "saas_billing", "name": "Billing Platform", "name_human": "Faturalama Altyapısı",
			"bet": "Herkes tahsilat ister, kimse kurmak istemez. Sıkıcı ama vazgeçilmez ol.",
			"pitch": "Para almayı kolaylaştır. İşin geri kalanı şirketin sorunu.", "market_type": "b2b"},
		{"id": "saas_dev_tools", "name": "Dev Tools", "name_human": "Geliştirici Araçları",
			"bet": "Mühendislerin günlük acısını çöz. Severlerse şirketlerine sokarlar.",
			"pitch": "Diğer mühendislerin pain point'lerini sırtlanmak.", "market_type": "b2b", "price_tendency": "premium"},
	],
	"social": [],
}

# Product Lifecycle Part 1: each feature carries three player-facing axes beyond
# `complexity` (build time + bug source):
#   pull    (1-5) — audience draw.
#   stakes  (1-5) — reputation damage multiplier if this area breaks.
#   dimension_contribution {innovation, stability, usability} — RELATIVE weights
#     steering WHICH quality axis this feature grows during the build (FeatureBuild
#     .get_dimension_weights sums + normalizes them). This is the feature→quality link.
#   requires_research (bool) — R&D-tree seed; always false in Phase 1.
# Values are working — Erdem balance/voice-revises. Multi-Modal pool removed.
const FEATURE_POOLS := {
	"ai_assistant": [
		{"id": "ai_assistant_chat", "name": "Chat Interface", "voice": "Olmazsa olmaz. Müşteri buna bakar.", "complexity": 2, "pull": 4, "stakes": 2, "dimension_contribution": {"innovation": 0.5, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_memory", "name": "Conversation Memory", "voice": "Önceki konuşmaları hatırlayan asistan. Pahalı ama vazgeçilmez.", "complexity": 3, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 2.0, "stability": 2.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_tools", "name": "Tool Use", "voice": "Sadece konuşmayan, eylem alan asistan. Implementation cehennemi.", "complexity": 4, "pull": 5, "stakes": 5, "dimension_contribution": {"innovation": 3.0, "stability": 0.5, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_voice", "name": "Voice Mode", "voice": "Konuşmak yazmaktan kolay. Çoğu zaman.", "complexity": 3, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 2.0, "stability": 0.5, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_image", "name": "Image Understanding", "voice": "Görüyor, anlıyor. En azından öyle söylüyoruz.", "complexity": 4, "pull": 4, "stakes": 4, "dimension_contribution": {"innovation": 3.0, "stability": 0.5, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_streaming", "name": "Streaming Output", "voice": "Cevaplar bir anda değil, yazarak gelir. Daha az korkutucu.", "complexity": 2, "pull": 3, "stakes": 1, "dimension_contribution": {"innovation": 0.5, "stability": 1.0, "usability": 2.5}, "requires_research": false, "tags": []},
	],
	"ai_photo_editor": [
		{"id": "ai_photo_bg_removal", "name": "Background Removal", "voice": "Tek tık. Herkesin beklediği şey. Olmazsa indirilmez bile.", "complexity": 2, "pull": 5, "stakes": 2, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "ai_photo_inpaint", "name": "Generative Inpaint", "voice": "Fotoğraftan eski sevgili silme. Pazarlama'ya bunu söyleme.", "complexity": 4, "pull": 5, "stakes": 4, "dimension_contribution": {"innovation": 3.0, "stability": 0.5, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "ai_photo_upscale", "name": "AI Upscaling", "voice": "Bulanık görseli netleştir. Sihir gibi görünür, mühendislik gibi maliyetlidir.", "complexity": 3, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 2.0, "stability": 1.0, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "ai_photo_style_transfer", "name": "Style Transfer", "voice": "Selfie'yi Van Gogh'a çevir. Influencer'lar bayılır.", "complexity": 3, "pull": 4, "stakes": 2, "dimension_contribution": {"innovation": 3.0, "stability": 0.5, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "ai_photo_batch", "name": "Batch Processing", "voice": "100 fotoğrafı aynı anda işle. B2B müşterisi bunu görünce gözleri parlar.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 0.5, "stability": 2.0, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "ai_photo_filters", "name": "Smart Filters", "voice": "Instagram'ın yaptığını yap, biraz daha akıllı. Çok değil.", "complexity": 1, "pull": 3, "stakes": 1, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
	],
	"ai_code_copilot": [
		{"id": "ai_code_autocomplete", "name": "Inline Autocomplete", "voice": "Yazarken öneri ver. Latency düşükse seviliyor, yüksekse kapatılıyor.", "complexity": 3, "pull": 5, "stakes": 4, "dimension_contribution": {"innovation": 1.5, "stability": 2.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "ai_code_chat", "name": "Code Chat Sidebar", "voice": "IDE içinde sohbet. Tab'lar arası gidip gelmek artık tarih.", "complexity": 2, "pull": 4, "stakes": 2, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "ai_code_refactor", "name": "Smart Refactor", "voice": "Çirkin kodu temiz koda çevir. Çoğu zaman.", "complexity": 4, "pull": 4, "stakes": 4, "dimension_contribution": {"innovation": 2.5, "stability": 2.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_code_explain", "name": "Code Explanation", "voice": "Bu kod ne yapıyor? Junior'ın en sevdiği buton.", "complexity": 2, "pull": 3, "stakes": 1, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "ai_code_test_gen", "name": "Test Generation", "voice": "Test yazmaktan kaçanları kurtaran feature. CI yeşillenir, ruh huzura erer.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 1.5, "stability": 3.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_code_multi_file", "name": "Multi-File Context", "voice": "Bütün repo'yu görüp öneri ver. Context window düşmanın.", "complexity": 5, "pull": 4, "stakes": 5, "dimension_contribution": {"innovation": 3.0, "stability": 1.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_code_diff_review", "name": "PR Review Assist", "voice": "PR'ı senin yerine oku. Senior'ların yeni asistan'ı.", "complexity": 4, "pull": 4, "stakes": 4, "dimension_contribution": {"innovation": 2.0, "stability": 2.0, "usability": 1.5}, "requires_research": false, "tags": []},
	],
	"ai_vector_search": [
		{"id": "ai_vec_embed_api", "name": "Embedding API", "voice": "Metni vektöre çevir. Müşteri ne yaptığını anlamayacak ama kullanacak.", "complexity": 3, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 1.5, "stability": 3.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_vec_search_api", "name": "Similarity Search API", "voice": "Bir vektör ver, en yakınlarını bul. Klasik.", "complexity": 3, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 1.0, "stability": 3.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_vec_filter", "name": "Metadata Filtering", "voice": "Sadece vektör değil, etiketle de ara. Enterprise sevdi mi tamam.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 1.0, "stability": 2.0, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "ai_vec_dashboard", "name": "Admin Dashboard", "voice": "Kullanım grafikleri. Dev'ler bakmaz, CTO bakar.", "complexity": 2, "pull": 2, "stakes": 2, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "ai_vec_scaling", "name": "Auto Scaling", "voice": "Trafik geldikçe genişle. SRE ekibi sevmese de gerekli.", "complexity": 5, "pull": 3, "stakes": 5, "dimension_contribution": {"innovation": 1.0, "stability": 3.5, "usability": 0.5}, "requires_research": false, "tags": []},
		{"id": "ai_vec_sdk", "name": "Client SDK", "voice": "Python ve JS için kütüphane. Yoksa kimse entegre etmez.", "complexity": 2, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 1.0, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
	],
	"saas_project_mgmt": [
		{"id": "saas_pm_tasks", "name": "Task Board", "voice": "Kanban. Yoksa ürün değildir.", "complexity": 2, "pull": 4, "stakes": 2, "dimension_contribution": {"innovation": 0.5, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "saas_pm_gantt", "name": "Gantt Timeline", "voice": "PM'lerin sevdiği grafik. Kullanıcı yok, müşteri var.", "complexity": 3, "pull": 3, "stakes": 2, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 2.5}, "requires_research": false, "tags": []},
		{"id": "saas_pm_comments", "name": "Threaded Comments", "voice": "Task altında konuşmak. Slack'ı azaltmaz, çoğaltır.", "complexity": 2, "pull": 3, "stakes": 2, "dimension_contribution": {"innovation": 0.5, "stability": 1.0, "usability": 2.5}, "requires_research": false, "tags": []},
		{"id": "saas_pm_integrations", "name": "Third-Party Integrations", "voice": "GitHub, Slack, Figma. Üçü olmazsa enterprise gülmüyor.", "complexity": 4, "pull": 4, "stakes": 4, "dimension_contribution": {"innovation": 1.0, "stability": 3.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_pm_automation", "name": "Workflow Automation", "voice": "If-this-then-that, ama corporate. Power user'ı bağlar.", "complexity": 4, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 2.5, "stability": 1.5, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "saas_pm_reporting", "name": "Reporting", "voice": "Yöneticinin haftalık rapor ihtiyacı. Renkli pie chart şart.", "complexity": 3, "pull": 3, "stakes": 2, "dimension_contribution": {"innovation": 1.0, "stability": 1.5, "usability": 2.5}, "requires_research": false, "tags": []},
	],
	"saas_crm": [
		{"id": "saas_crm_contacts", "name": "Contact Database", "voice": "Müşteri kayıt etmek. Olmadan zaten CRM değil.", "complexity": 2, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 0.5, "stability": 2.0, "usability": 2.5}, "requires_research": false, "tags": []},
		{"id": "saas_crm_pipeline", "name": "Sales Pipeline", "voice": "Deal'ları stage stage takip et. Sales head'in sevgilisi.", "complexity": 3, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 1.0, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "saas_crm_email", "name": "Email Sync", "voice": "Gmail / Outlook bağla. OAuth cehennemi seni bekliyor.", "complexity": 4, "pull": 4, "stakes": 5, "dimension_contribution": {"innovation": 1.0, "stability": 3.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_crm_forecast", "name": "Revenue Forecast", "voice": "Tahmin grafiği. Yanlış çıkar ama satar.", "complexity": 3, "pull": 3, "stakes": 2, "dimension_contribution": {"innovation": 2.5, "stability": 1.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_crm_mobile", "name": "Mobile App", "voice": "Sales saha ekibi mobile ister. Web-only CRM ölmüş demektir.", "complexity": 4, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 1.5, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "saas_crm_call_log", "name": "Call Logging", "voice": "Aramayı kayda al, otomatik özet üret. AI dokunuşu zorunlu.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 2.5, "stability": 1.5, "usability": 1.5}, "requires_research": false, "tags": []},
	],
	"saas_analytics": [
		{"id": "saas_an_dashboards", "name": "Custom Dashboards", "voice": "Sürükle bırak grafik. Olmazsa kimse bakmaz.", "complexity": 3, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 1.0, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "saas_an_query", "name": "SQL Query Editor", "voice": "Data team'in yeni evi. Editor olmazsa Looker'a kaçarlar.", "complexity": 4, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 1.5, "stability": 2.0, "usability": 2.5}, "requires_research": false, "tags": []},
		{"id": "saas_an_alerts", "name": "Anomaly Alerts", "voice": "Bir şey ters gittiğinde Slack'a düşsün. Geç düşerse geç olur.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 2.0, "stability": 2.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_an_share", "name": "Shareable Reports", "voice": "Linkle paylaş. Auth katmanı çok küçük bir detay.", "complexity": 2, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 1.0, "stability": 1.5, "usability": 2.5}, "requires_research": false, "tags": []},
		{"id": "saas_an_etl", "name": "Data Connectors", "voice": "Stripe, Postgres, Mixpanel — hepsi içeri. Maintenance işkencesi başlıyor.", "complexity": 5, "pull": 4, "stakes": 5, "dimension_contribution": {"innovation": 1.0, "stability": 3.5, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "saas_an_embed", "name": "Embedded Analytics", "voice": "Müşterinin kendi ürününe gömülen dashboard. Enterprise satışın anahtarı.", "complexity": 4, "pull": 4, "stakes": 4, "dimension_contribution": {"innovation": 2.5, "stability": 2.0, "usability": 1.5}, "requires_research": false, "tags": []},
	],
	"saas_billing": [
		{"id": "saas_bill_subscriptions", "name": "Subscription Management", "voice": "Aylık tahsilat. Yoksa zaten billing değilsin.", "complexity": 3, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 0.5, "stability": 3.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_bill_invoice", "name": "Invoice Generation", "voice": "PDF üret, mail at. Muhasebenin kalbini kazan.", "complexity": 2, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 0.5, "stability": 2.0, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "saas_bill_tax", "name": "Tax Calculation", "voice": "KDV, sales tax, VAT. Ülke kadar versiyon, ülke kadar bug.", "complexity": 5, "pull": 2, "stakes": 5, "dimension_contribution": {"innovation": 0.5, "stability": 4.0, "usability": 0.5}, "requires_research": false, "tags": []},
		{"id": "saas_bill_dunning", "name": "Failed Payment Recovery", "voice": "Kartı reddedildi mi tekrar dene, mail at. Churn'ün sessiz katili.", "complexity": 3, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 1.5, "stability": 3.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "saas_bill_webhooks", "name": "Webhook System", "voice": "Stripe gibi ol — event'ları müşteri sistemine bildir.", "complexity": 3, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 1.0, "stability": 3.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "saas_bill_proration", "name": "Plan Proration", "voice": "Plan değiştirince doğru hesapla. Bir tane bug = support cehennemi.", "complexity": 4, "pull": 2, "stakes": 5, "dimension_contribution": {"innovation": 0.5, "stability": 3.5, "usability": 1.0}, "requires_research": false, "tags": []},
	],
	"saas_dev_tools": [
		{"id": "saas_dev_cli", "name": "Command-Line Tool", "voice": "Terminal kullanıcısı eğer CLI yoksa GitHub'a issue açar.", "complexity": 2, "pull": 3, "stakes": 2, "dimension_contribution": {"innovation": 1.0, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "saas_dev_api", "name": "REST API", "voice": "Her şey buradan geçer. Versiyonlama hatası = customer kaybı.", "complexity": 3, "pull": 4, "stakes": 5, "dimension_contribution": {"innovation": 1.0, "stability": 3.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_dev_docs", "name": "Interactive Docs", "voice": "Stripe gibi olmazsa kimse okumaz. Okunmazsa entegre edilmez.", "complexity": 3, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "saas_dev_ci_plugin", "name": "CI Plugin", "voice": "GitHub Actions, GitLab, CircleCI. Üçü de olmazsa kimse umursamaz.", "complexity": 4, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 1.5, "stability": 3.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_dev_logs", "name": "Live Log Stream", "voice": "Debug yaparken canlı log. Yoksa SSH'a düşersin.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 1.5, "stability": 2.5, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_dev_sandbox", "name": "Test Sandbox", "voice": "Geliştirici prod'a vurmadan denesin. Olmazsa korkup kullanmaz.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 1.5, "stability": 2.5, "usability": 2.0}, "requires_research": false, "tags": []},
	],
}


# Per-sub-type quality-axis weighting (Product Lifecycle Part 1). Kept as a
# parallel dict keyed by sub-type id (not embedded in SUB_PRODUCT_TYPES) so the
# type records stay readable. Each entry: [{axis, weight, display_label}] over the
# three canonical QualityModel axes. `weight` = how much that pazar cares about the
# axis (feeds composite_quality). `display_label` renames the canonical axis for
# presentation only (engine axis id stays "innovation"/"stability"/"usability").
# Working values — Erdem tunes at the balance pass.
const QUALITY_AXES := {
	# --- AI (mostly B2C) ---
	"ai_assistant": [
		{"axis": "innovation", "weight": 1.4, "display_label": "İnovasyon"},
		{"axis": "stability", "weight": 0.7, "display_label": "Kararlılık"},
		{"axis": "usability", "weight": 1.3, "display_label": "Kullanılabilirlik"},
	],
	"ai_photo_editor": [
		{"axis": "innovation", "weight": 1.3, "display_label": "İnovasyon"},
		{"axis": "stability", "weight": 0.6, "display_label": "Kararlılık"},
		{"axis": "usability", "weight": 1.4, "display_label": "Kullanılabilirlik"},
	],
	"ai_code_copilot": [
		{"axis": "innovation", "weight": 1.0, "display_label": "İnovasyon"},
		{"axis": "stability", "weight": 1.4, "display_label": "Kararlılık"},
		{"axis": "usability", "weight": 0.9, "display_label": "Editör Akışı"},
	],
	"ai_vector_search": [
		{"axis": "innovation", "weight": 0.8, "display_label": "İnovasyon"},
		{"axis": "stability", "weight": 1.6, "display_label": "Veri Güvenliği & Ölçek"},
		{"axis": "usability", "weight": 0.9, "display_label": "Entegrasyon Kolaylığı"},
	],
	# --- SaaS (all B2B) ---
	"saas_project_mgmt": [
		{"axis": "innovation", "weight": 0.8, "display_label": "İnovasyon"},
		{"axis": "stability", "weight": 1.1, "display_label": "Kararlılık"},
		{"axis": "usability", "weight": 1.3, "display_label": "Kullanılabilirlik"},
	],
	"saas_crm": [
		{"axis": "innovation", "weight": 0.8, "display_label": "İnovasyon"},
		{"axis": "stability", "weight": 1.2, "display_label": "Kararlılık"},
		{"axis": "usability", "weight": 1.2, "display_label": "Kullanılabilirlik"},
	],
	"saas_analytics": [
		{"axis": "innovation", "weight": 1.1, "display_label": "İnovasyon"},
		{"axis": "stability", "weight": 1.2, "display_label": "Kararlılık"},
		{"axis": "usability", "weight": 0.9, "display_label": "Kullanılabilirlik"},
	],
	"saas_billing": [
		{"axis": "innovation", "weight": 0.7, "display_label": "İnovasyon"},
		{"axis": "stability", "weight": 1.6, "display_label": "Doğruluk & Güvenlik"},
		{"axis": "usability", "weight": 0.9, "display_label": "Kullanılabilirlik"},
	],
	"saas_dev_tools": [
		{"axis": "innovation", "weight": 1.1, "display_label": "İnovasyon"},
		{"axis": "stability", "weight": 1.4, "display_label": "Kararlılık"},
		{"axis": "usability", "weight": 0.9, "display_label": "Entegrasyon Kolaylığı"},
	],
}


static func get_sub_product_types(subgenre: String) -> Array:
	return SUB_PRODUCT_TYPES.get(subgenre, [])


static func get_feature_pool(sub_product_type_id: String) -> Array:
	return FEATURE_POOLS.get(sub_product_type_id, [])


static func get_feature_by_id(feature_id: String) -> Dictionary:
	for pool_key in FEATURE_POOLS:
		var pool: Array = FEATURE_POOLS[pool_key]
		for feature in pool:
			if feature.get("id", "") == feature_id:
				return feature
	return {}


static func get_sub_product_type_by_id(id: String) -> Dictionary:
	for subgenre_key in SUB_PRODUCT_TYPES:
		var list: Array = SUB_PRODUCT_TYPES[subgenre_key]
		for sub_type in list:
			if sub_type.get("id", "") == id:
				return sub_type
	return {}


# Sales model selector for the PostShip phase. Defaults to "b2c" for unknown ids
# (safe: B2C needs no prospect pipeline). Forward-compat: other sales params
# (price tier, target-market desc) can be read off the same sub-type record.
static func get_market_type(sub_product_type_id: String) -> String:
	var st: Dictionary = get_sub_product_type_by_id(sub_product_type_id)
	return String(st.get("market_type", "b2c"))


# Optional pricing lean per sub-type: "premium" | "neutral" | "volume". Defaults
# to "neutral" when the record omits it. Shifts SalesSystem.product_value()'s optimal.
static func get_price_tendency(sub_product_type_id: String) -> String:
	var st: Dictionary = get_sub_product_type_by_id(sub_product_type_id)
	return String(st.get("price_tendency", "neutral"))


# Per-sub-type quality-axis weights + display labels (Product Lifecycle Part 1).
# Returns [] for unknown ids → QualityModel falls back to equal DEFAULT_AXES.
static func get_quality_axes(sub_product_type_id: String) -> Array:
	return QUALITY_AXES.get(sub_product_type_id, [])


# Product-name suggestion pool (Product Lifecycle Part 1 — the "🎲 Öner" button).
# Working set; Erdem revises. Deterministic pick keeps runs reproducible.
const PRODUCT_NAME_POOL := [
	"Pulse", "Nova", "Kairo", "Vela", "Loop", "Mira", "Flux", "Orbit", "Ember", "Sable",
	"Nimbus", "Cadence", "Quill", "Atlas", "Beacon", "Ripple", "Vertex", "Halo", "Drift", "Onyx",
]


static func suggest_product_name(index: int) -> String:
	if PRODUCT_NAME_POOL.is_empty():
		return "Ürün"
	return String(PRODUCT_NAME_POOL[abs(index) % PRODUCT_NAME_POOL.size()])
