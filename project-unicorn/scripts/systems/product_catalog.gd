class_name ProductCatalog
extends RefCounted

# Read-only catalog data for sub-product types and feature pools.
# Hardcoded for demo; JSON externalization to data/products/ is content-phase
# work. Voice strings are working drafts — Erdem revises in content pass.

# market_type ("b2c" | "b2b") drives the PostShip sales model (Spec PostShip §A):
# B2C → audience/organic + growth decisions; B2B → prospect + pitch dialogue.
# First pass is binary; hybrids are future work. Erdem may revise the marking.
const SUB_PRODUCT_TYPES := {
	"ai": [
		{"id": "ai_assistant", "name": "AI Assistant", "pitch": "ChatGPT'nin yetmediği yerlerde devreye giren asistan.", "market_type": "b2c"},
		{"id": "ai_photo_editor", "name": "Photo Editor", "pitch": "Photoshop'un karmaşıklığını unutturan bir araç.", "market_type": "b2c"},
		{"id": "ai_code_copilot", "name": "Code Copilot", "pitch": "Junior developer'lar için en iyi pair programmer.", "market_type": "b2c"},
		{"id": "ai_multimodal_app", "name": "Multi-Modal App", "pitch": "Text + görsel + ses, hepsi bir arada.", "market_type": "b2c"},
		{"id": "ai_vector_search", "name": "Vector Search Service", "pitch": "Veri arama, ama anlama getir.", "market_type": "b2b"},
	],
	"saas": [
		{"id": "saas_project_mgmt", "name": "Project Management", "pitch": "Asana ölmedi, sadece arkanı dönmüş. Bunu yenilemek için bir fırsat.", "market_type": "b2b"},
		{"id": "saas_crm", "name": "CRM", "pitch": "Sales takip platformu. Müşteri kaybeden satıcı yok.", "market_type": "b2b"},
		{"id": "saas_analytics", "name": "Analytics Dashboard", "pitch": "Veriyi grafik haline getir. Yöneticiler bunun için para verir.", "market_type": "b2b"},
		{"id": "saas_billing", "name": "Billing Platform", "pitch": "Para almayı kolaylaştır. İşin geri kalanı şirketin sorunu.", "market_type": "b2b"},
		{"id": "saas_dev_tools", "name": "Dev Tools", "pitch": "Diğer mühendislerin pain point'lerini sırtlanmak.", "market_type": "b2b"},
	],
	"social": [],
}

const FEATURE_POOLS := {
	"ai_assistant": [
		{"id": "ai_assistant_chat", "name": "Chat Interface", "voice": "Olmazsa olmaz. Müşteri buna bakar.", "complexity": 2, "tags": []},
		{"id": "ai_assistant_memory", "name": "Conversation Memory", "voice": "Önceki konuşmaları hatırlayan asistan. Pahalı ama vazgeçilmez.", "complexity": 3, "tags": []},
		{"id": "ai_assistant_tools", "name": "Tool Use", "voice": "Sadece konuşmayan, eylem alan asistan. Implementation cehennemi.", "complexity": 4, "tags": []},
		{"id": "ai_assistant_voice", "name": "Voice Mode", "voice": "Konuşmak yazmaktan kolay. Çoğu zaman.", "complexity": 3, "tags": []},
		{"id": "ai_assistant_image", "name": "Image Understanding", "voice": "Görüyor, anlıyor. En azından öyle söylüyoruz.", "complexity": 4, "tags": []},
		{"id": "ai_assistant_streaming", "name": "Streaming Output", "voice": "Cevaplar bir anda değil, yazarak gelir. Daha az korkutucu.", "complexity": 2, "tags": []},
	],
	"ai_photo_editor": [
		{"id": "ai_photo_bg_removal", "name": "Background Removal", "voice": "Tek tık. Herkesin beklediği şey. Olmazsa indirilmez bile.", "complexity": 2, "tags": []},
		{"id": "ai_photo_inpaint", "name": "Generative Inpaint", "voice": "Fotoğraftan eski sevgili silme. Pazarlama'ya bunu söyleme.", "complexity": 4, "tags": []},
		{"id": "ai_photo_upscale", "name": "AI Upscaling", "voice": "Bulanık görseli netleştir. Sihir gibi görünür, mühendislik gibi maliyetlidir.", "complexity": 3, "tags": []},
		{"id": "ai_photo_style_transfer", "name": "Style Transfer", "voice": "Selfie'yi Van Gogh'a çevir. Influencer'lar bayılır.", "complexity": 3, "tags": []},
		{"id": "ai_photo_batch", "name": "Batch Processing", "voice": "100 fotoğrafı aynı anda işle. B2B müşterisi bunu görünce gözleri parlar.", "complexity": 3, "tags": []},
		{"id": "ai_photo_filters", "name": "Smart Filters", "voice": "Instagram'ın yaptığını yap, biraz daha akıllı. Çok değil.", "complexity": 1, "tags": []},
	],
	"ai_code_copilot": [
		{"id": "ai_code_autocomplete", "name": "Inline Autocomplete", "voice": "Yazarken öneri ver. Latency düşükse seviliyor, yüksekse kapatılıyor.", "complexity": 3, "tags": []},
		{"id": "ai_code_chat", "name": "Code Chat Sidebar", "voice": "IDE içinde sohbet. Tab'lar arası gidip gelmek artık tarih.", "complexity": 2, "tags": []},
		{"id": "ai_code_refactor", "name": "Smart Refactor", "voice": "Çirkin kodu temiz koda çevir. Çoğu zaman.", "complexity": 4, "tags": []},
		{"id": "ai_code_explain", "name": "Code Explanation", "voice": "Bu kod ne yapıyor? Junior'ın en sevdiği buton.", "complexity": 2, "tags": []},
		{"id": "ai_code_test_gen", "name": "Test Generation", "voice": "Test yazmaktan kaçanları kurtaran feature. CI yeşillenir, ruh huzura erer.", "complexity": 3, "tags": []},
		{"id": "ai_code_multi_file", "name": "Multi-File Context", "voice": "Bütün repo'yu görüp öneri ver. Context window düşmanın.", "complexity": 5, "tags": []},
		{"id": "ai_code_diff_review", "name": "PR Review Assist", "voice": "PR'ı senin yerine oku. Senior'ların yeni asistan'ı.", "complexity": 4, "tags": []},
	],
	"ai_multimodal_app": [
		{"id": "ai_mm_text_image", "name": "Text-to-Image", "voice": "Yazıyı görsele çevir. Demolarda iyi görünür, faturada kötü.", "complexity": 4, "tags": []},
		{"id": "ai_mm_image_text", "name": "Image-to-Text", "voice": "Görsele bak, anlat. OCR'dan biraz daha akıllı, biraz daha pahalı.", "complexity": 3, "tags": []},
		{"id": "ai_mm_voice_input", "name": "Voice Input", "voice": "Konuşarak komut ver. Mobile'da yararlı, ofiste komik.", "complexity": 3, "tags": []},
		{"id": "ai_mm_video_clip", "name": "Short Video Generation", "voice": "Birkaç saniyelik klip üret. GPU faturasını sevmeyeceksin.", "complexity": 5, "tags": []},
		{"id": "ai_mm_translation", "name": "Cross-Modal Translation", "voice": "Görselden açıklama, sesten metin, hepsi bir akışta.", "complexity": 4, "tags": []},
		{"id": "ai_mm_history", "name": "Project History", "voice": "Kullanıcı her şeyini sende tutar. Sen de cloud faturasını ödersin.", "complexity": 2, "tags": []},
	],
	"ai_vector_search": [
		{"id": "ai_vec_embed_api", "name": "Embedding API", "voice": "Metni vektöre çevir. Müşteri ne yaptığını anlamayacak ama kullanacak.", "complexity": 3, "tags": []},
		{"id": "ai_vec_search_api", "name": "Similarity Search API", "voice": "Bir vektör ver, en yakınlarını bul. Klasik.", "complexity": 3, "tags": []},
		{"id": "ai_vec_filter", "name": "Metadata Filtering", "voice": "Sadece vektör değil, etiketle de ara. Enterprise sevdi mi tamam.", "complexity": 3, "tags": []},
		{"id": "ai_vec_dashboard", "name": "Admin Dashboard", "voice": "Kullanım grafikleri. Dev'ler bakmaz, CTO bakar.", "complexity": 2, "tags": []},
		{"id": "ai_vec_scaling", "name": "Auto Scaling", "voice": "Trafik geldikçe genişle. SRE ekibi sevmese de gerekli.", "complexity": 5, "tags": []},
		{"id": "ai_vec_sdk", "name": "Client SDK", "voice": "Python ve JS için kütüphane. Yoksa kimse entegre etmez.", "complexity": 2, "tags": []},
	],
	"saas_project_mgmt": [
		{"id": "saas_pm_tasks", "name": "Task Board", "voice": "Kanban. Yoksa ürün değildir.", "complexity": 2, "tags": []},
		{"id": "saas_pm_gantt", "name": "Gantt Timeline", "voice": "PM'lerin sevdiği grafik. Kullanıcı yok, müşteri var.", "complexity": 3, "tags": []},
		{"id": "saas_pm_comments", "name": "Threaded Comments", "voice": "Task altında konuşmak. Slack'ı azaltmaz, çoğaltır.", "complexity": 2, "tags": []},
		{"id": "saas_pm_integrations", "name": "Third-Party Integrations", "voice": "GitHub, Slack, Figma. Üçü olmazsa enterprise gülmüyor.", "complexity": 4, "tags": []},
		{"id": "saas_pm_automation", "name": "Workflow Automation", "voice": "If-this-then-that, ama corporate. Power user'ı bağlar.", "complexity": 4, "tags": []},
		{"id": "saas_pm_reporting", "name": "Reporting", "voice": "Yöneticinin haftalık rapor ihtiyacı. Renkli pie chart şart.", "complexity": 3, "tags": []},
	],
	"saas_crm": [
		{"id": "saas_crm_contacts", "name": "Contact Database", "voice": "Müşteri kayıt etmek. Olmadan zaten CRM değil.", "complexity": 2, "tags": []},
		{"id": "saas_crm_pipeline", "name": "Sales Pipeline", "voice": "Deal'ları stage stage takip et. Sales head'in sevgilisi.", "complexity": 3, "tags": []},
		{"id": "saas_crm_email", "name": "Email Sync", "voice": "Gmail / Outlook bağla. OAuth cehennemi seni bekliyor.", "complexity": 4, "tags": []},
		{"id": "saas_crm_forecast", "name": "Revenue Forecast", "voice": "Tahmin grafiği. Yanlış çıkar ama satar.", "complexity": 3, "tags": []},
		{"id": "saas_crm_mobile", "name": "Mobile App", "voice": "Sales saha ekibi mobile ister. Web-only CRM ölmüş demektir.", "complexity": 4, "tags": []},
		{"id": "saas_crm_call_log", "name": "Call Logging", "voice": "Aramayı kayda al, otomatik özet üret. AI dokunuşu zorunlu.", "complexity": 3, "tags": []},
	],
	"saas_analytics": [
		{"id": "saas_an_dashboards", "name": "Custom Dashboards", "voice": "Sürükle bırak grafik. Olmazsa kimse bakmaz.", "complexity": 3, "tags": []},
		{"id": "saas_an_query", "name": "SQL Query Editor", "voice": "Data team'in yeni evi. Editor olmazsa Looker'a kaçarlar.", "complexity": 4, "tags": []},
		{"id": "saas_an_alerts", "name": "Anomaly Alerts", "voice": "Bir şey ters gittiğinde Slack'a düşsün. Geç düşerse geç olur.", "complexity": 3, "tags": []},
		{"id": "saas_an_share", "name": "Shareable Reports", "voice": "Linkle paylaş. Auth katmanı çok küçük bir detay.", "complexity": 2, "tags": []},
		{"id": "saas_an_etl", "name": "Data Connectors", "voice": "Stripe, Postgres, Mixpanel — hepsi içeri. Maintenance işkencesi başlıyor.", "complexity": 5, "tags": []},
		{"id": "saas_an_embed", "name": "Embedded Analytics", "voice": "Müşterinin kendi ürününe gömülen dashboard. Enterprise satışın anahtarı.", "complexity": 4, "tags": []},
	],
	"saas_billing": [
		{"id": "saas_bill_subscriptions", "name": "Subscription Management", "voice": "Aylık tahsilat. Yoksa zaten billing değilsin.", "complexity": 3, "tags": []},
		{"id": "saas_bill_invoice", "name": "Invoice Generation", "voice": "PDF üret, mail at. Muhasebenin kalbini kazan.", "complexity": 2, "tags": []},
		{"id": "saas_bill_tax", "name": "Tax Calculation", "voice": "KDV, sales tax, VAT. Ülke kadar versiyon, ülke kadar bug.", "complexity": 5, "tags": []},
		{"id": "saas_bill_dunning", "name": "Failed Payment Recovery", "voice": "Kartı reddedildi mi tekrar dene, mail at. Churn'ün sessiz katili.", "complexity": 3, "tags": []},
		{"id": "saas_bill_webhooks", "name": "Webhook System", "voice": "Stripe gibi ol — event'ları müşteri sistemine bildir.", "complexity": 3, "tags": []},
		{"id": "saas_bill_proration", "name": "Plan Proration", "voice": "Plan değiştirince doğru hesapla. Bir tane bug = support cehennemi.", "complexity": 4, "tags": []},
	],
	"saas_dev_tools": [
		{"id": "saas_dev_cli", "name": "Command-Line Tool", "voice": "Terminal kullanıcısı eğer CLI yoksa GitHub'a issue açar.", "complexity": 2, "tags": []},
		{"id": "saas_dev_api", "name": "REST API", "voice": "Her şey buradan geçer. Versiyonlama hatası = customer kaybı.", "complexity": 3, "tags": []},
		{"id": "saas_dev_docs", "name": "Interactive Docs", "voice": "Stripe gibi olmazsa kimse okumaz. Okunmazsa entegre edilmez.", "complexity": 3, "tags": []},
		{"id": "saas_dev_ci_plugin", "name": "CI Plugin", "voice": "GitHub Actions, GitLab, CircleCI. Üçü de olmazsa kimse umursamaz.", "complexity": 4, "tags": []},
		{"id": "saas_dev_logs", "name": "Live Log Stream", "voice": "Debug yaparken canlı log. Yoksa SSH'a düşersin.", "complexity": 3, "tags": []},
		{"id": "saas_dev_sandbox", "name": "Test Sandbox", "voice": "Geliştirici prod'a vurmadan denesin. Olmazsa korkup kullanmaz.", "complexity": 3, "tags": []},
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
