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
# Design-doc redesign (Part 1): `category_tr` (mono kategori alt-etiketi) + `desc_tr`
# (tek satır kart açıklaması) DISPLAY-ONLY — yalnız product_tab kart görseli okur,
# hiçbir hesaba girmez.
# İçerik working-metin — Erdem voice-pass bekliyor (final copy kilitlemeyin).
const SUB_PRODUCT_TYPES := {
	"ai": [
		{"id": "ai_assistant", "name": "AI Assistant", "name_human": "Yapay Zeka Asistanı",
			"category_tr": "ASİSTAN", "desc_tr": "Genel amaçlı sohbet asistanı.",
			"bet": "İnsanların her gün sorduğu şeye hızlı, temiz cevap. ChatGPT'nin üşendiği nişi kap.",
			"pitch": "ChatGPT'nin yetmediği yerlerde devreye giren asistan.", "market_type": "b2c"},
		{"id": "ai_photo_editor", "name": "Photo Editor", "name_human": "Görsel Düzenleyici",
			"category_tr": "GÖRSEL · ÜRETKEN", "desc_tr": "Görsel düzenleme ve üretim aracı.",
			"bet": "Photoshop açmaya üşenen milyonlar var. Tek tıkla iyi görünsünler, para versinler.",
			"pitch": "Photoshop'un karmaşıklığını unutturan bir araç.", "market_type": "b2c", "price_tendency": "volume"},
		{"id": "ai_code_copilot", "name": "Code Copilot", "name_human": "Kod Yazan Asistan",
			"category_tr": "GELİŞTİRİCİ", "desc_tr": "Kod yazımını hızlandıran yardımcı.",
			"bet": "Junior geliştiricinin yanında 7/24 duran bir kıdemli. Önce güvenini kazan, ekipler peşinden gelsin.",
			"pitch": "Kod yazarken öneren, tamamlayan, açıklayan asistan. Geliştiricinin yeni masa arkadaşı.", "market_type": "b2c"},
		{"id": "ai_vector_search", "name": "Vector Search", "name_human": "Kurumsal Arama",
			"category_tr": "ARAMA", "desc_tr": "Anlamsal kurumsal arama motoru.",
			"bet": "Şirketler kendi verisinde kayboluyor. Anlamlı aramayı sat, IT bütçesi açılır.",
			"pitch": "Şirket verisinde kelimeyle değil anlamla arama yapan motor. Aradığını tarif edemesen de bulur.", "market_type": "b2b", "price_tendency": "premium"},
	],
	"saas": [
		{"id": "saas_project_mgmt", "name": "Project Management", "name_human": "Proje Yönetimi",
			"category_tr": "İŞ AKIŞI", "desc_tr": "Ekiplerin işi tek panodan yürüttüğü araç.",
			"bet": "Asana'dan bıkan çok. Daha hafif, daha hızlı bir alternatif ol.",
			"pitch": "Kim neyi ne zaman yapacak — ekiplerin işi tek panodan takip ettiği araç.", "market_type": "b2b"},
		{"id": "saas_crm", "name": "CRM", "name_human": "Müşteri Takip (CRM)",
			"category_tr": "SATIŞ", "desc_tr": "Müşteri ve görüşmeleri tek ekranda toplar.",
			"bet": "Satış ekipleri deal kaybediyor. Hepsini tek ekranda topla, vazgeçemesinler.",
			"pitch": "Satış ekibinin müşterileri ve görüşmeleri tek ekranda takip ettiği sistem. Unutulan müşteri, kaçan satış kalmaz.", "market_type": "b2b"},
		{"id": "saas_analytics", "name": "Analytics Dashboard", "name_human": "Veri Panosu",
			"category_tr": "ANALİTİK", "desc_tr": "Metrik ve gösterge paneli seti.",
			"bet": "Yönetici grafiğe para verir. Karmaşık veriyi tek bakışta anlaşılır yap.",
			"pitch": "Dağınık şirket verisini yöneticinin tek bakışta anlayacağı grafiklere çevirir.", "market_type": "b2b"},
		{"id": "saas_billing", "name": "Billing Platform", "name_human": "Faturalama Altyapısı",
			"category_tr": "FİNANS · ALTYAPI", "desc_tr": "Abonelik ve tahsilat altyapısı.",
			"bet": "Herkes tahsilat ister, kimse kurmak istemez. Sıkıcı ama vazgeçilmez ol.",
			"pitch": "Abonelik, fatura ve tahsilatı şirketler adına yürüten altyapı. Sıkıcı, ama herkes muhtaç.", "market_type": "b2b"},
		{"id": "saas_dev_tools", "name": "Dev Tools", "name_human": "Geliştirici Araçları",
			"category_tr": "GELİŞTİRİCİ", "desc_tr": "Geliştiricinin günlük angaryasını üstlenir.",
			"bet": "Mühendislerin günlük acısını çöz. Severlerse şirketlerine sokarlar.",
			"pitch": "Geliştiricilerin her gün uğraştığı angaryayı üstlenen araç seti. Mühendisten mühendise.", "market_type": "b2b", "price_tendency": "premium"},
		{"id": "saas_ops", "name": "Ops Platform", "name_human": "Süreç Otomasyon Platformu",
			"category_tr": "OPERASYON", "desc_tr": "Sahadan yönetime süreçleri tek yerde toplar.",
			"bet": "Sahada iş yürüten şirketler kâğıtla boğuluyor. Süreci dijitalleştir, vazgeçemesinler.",
			"pitch": "İnşaattan lojistiğe, süreçleri uçtan uca otomatikleştiren operasyon platformu.", "market_type": "b2b", "price_tendency": "neutral"},
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
# İçerik working-metin — Erdem voice-pass bekliyor (final copy kilitlemeyin).
const FEATURE_POOLS := {
	"ai_assistant": [
		{"id": "ai_assistant_chat", "name": "Chat Interface", "voice": "Kullanıcının asistanla konuştuğu ekran. Olmazsa olmaz; müşteri ilk buna bakar.", "complexity": 2, "pull": 4, "stakes": 2, "dimension_contribution": {"innovation": 0.5, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_memory", "name": "Conversation Memory", "voice": "Önceki konuşmaları hatırlayan asistan. Pahalı ama vazgeçilmez.", "complexity": 3, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 2.0, "stability": 2.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_tools", "name": "Tool Use", "voice": "Asistan sadece konuşmaz, işlemi de yapar. Yazması ayrı bir cehennem.", "complexity": 4, "pull": 5, "stakes": 5, "dimension_contribution": {"innovation": 3.0, "stability": 0.5, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_voice", "name": "Voice Mode", "voice": "Asistanla sesli konuşma. Konuşmak yazmaktan kolay — çoğu zaman.", "complexity": 3, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 2.0, "stability": 0.5, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_image", "name": "Image Understanding", "voice": "Asistan görsele bakıp anlıyor. En azından biz öyle söylüyoruz.", "complexity": 4, "pull": 4, "stakes": 4, "dimension_contribution": {"innovation": 3.0, "stability": 0.5, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_assistant_streaming", "name": "Streaming Output", "voice": "Cevaplar bir anda değil, yazarak gelir. Daha az korkutucu.", "complexity": 2, "pull": 3, "stakes": 1, "dimension_contribution": {"innovation": 0.5, "stability": 1.0, "usability": 2.5}, "requires_research": false, "tags": []},
	],
	"ai_photo_editor": [
		{"id": "ai_photo_bg_removal", "name": "Background Removal", "voice": "Arka planı tek tıkla sil. Herkesin beklediği şey; olmazsa uygulama indirilmez bile.", "complexity": 2, "pull": 5, "stakes": 2, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "ai_photo_inpaint", "name": "Generative Inpaint", "voice": "Fotoğraftan istemediğini sil, boşluğu yapay zeka doldursun. Eski sevgililer dahil.", "complexity": 4, "pull": 5, "stakes": 4, "dimension_contribution": {"innovation": 3.0, "stability": 0.5, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "ai_photo_upscale", "name": "AI Upscaling", "voice": "Bulanık görseli netleştir. Sihir gibi görünür, mühendislik gibi maliyetlidir.", "complexity": 3, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 2.0, "stability": 1.0, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "ai_photo_style_transfer", "name": "Style Transfer", "voice": "Selfie'yi Van Gogh'a çevir. Influencer'lar bayılır.", "complexity": 3, "pull": 4, "stakes": 2, "dimension_contribution": {"innovation": 3.0, "stability": 0.5, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "ai_photo_batch", "name": "Batch Processing", "voice": "100 fotoğrafı aynı anda işle. Kurumsal müşterinin gözleri parlar.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 0.5, "stability": 2.0, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "ai_photo_filters", "name": "Smart Filters", "voice": "Instagram'ın yaptığını yap, biraz daha akıllı. Çok değil.", "complexity": 1, "pull": 3, "stakes": 1, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
	],
	"ai_code_copilot": [
		{"id": "ai_code_autocomplete", "name": "Inline Autocomplete", "voice": "Kod yazarken satır ortasında öneri. Hızlıysa seviliyor, gecikirse kapatılıyor.", "complexity": 3, "pull": 5, "stakes": 4, "dimension_contribution": {"innovation": 1.5, "stability": 2.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "ai_code_chat", "name": "Code Chat Sidebar", "voice": "Editörden çıkmadan asistanla sohbet. Pencereler arası gidip gelmek tarih oluyor.", "complexity": 2, "pull": 4, "stakes": 2, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "ai_code_refactor", "name": "Smart Refactor", "voice": "Çirkin kodu temiz koda çevir. Çoğu zaman.", "complexity": 4, "pull": 4, "stakes": 4, "dimension_contribution": {"innovation": 2.5, "stability": 2.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_code_explain", "name": "Code Explanation", "voice": "Bu kod ne yapıyor? Junior'ın en sevdiği buton.", "complexity": 2, "pull": 3, "stakes": 1, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "ai_code_test_gen", "name": "Test Generation", "voice": "Testleri senin yerine yazar. CI yeşillenir, ruh huzura erer.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 1.5, "stability": 3.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_code_multi_file", "name": "Multi-File Context", "voice": "Tek dosyayı değil bütün repo'yu görerek öneri verir. Teknik olarak en zor kısım bu.", "complexity": 5, "pull": 4, "stakes": 5, "dimension_contribution": {"innovation": 3.0, "stability": 1.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_code_diff_review", "name": "PR Review Assist", "voice": "PR'ı senin yerine okuyup yorum bırakır. Kıdemlilerin yeni gözdesi.", "complexity": 4, "pull": 4, "stakes": 4, "dimension_contribution": {"innovation": 2.0, "stability": 2.0, "usability": 1.5}, "requires_research": false, "tags": []},
	],
	"ai_vector_search": [
		{"id": "ai_vec_embed_api", "name": "Embedding API", "voice": "Metni anlam taşıyan vektöre çeviren API. Müşteri nasıl çalıştığını anlamaz ama kullanır.", "complexity": 3, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 1.5, "stability": 3.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_vec_search_api", "name": "Similarity Search API", "voice": "Bir sorgu ver, anlamca en yakın kayıtları bulsun. Ürünün kalbi burası.", "complexity": 3, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 1.0, "stability": 3.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "ai_vec_filter", "name": "Metadata Filtering", "voice": "Anlam aramasını tarih ve etiketle daralt. Kurumsal müşterinin ilk sorduğu şey.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 1.0, "stability": 2.0, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "ai_vec_dashboard", "name": "Admin Dashboard", "voice": "Kullanım grafiklerini gösteren yönetim paneli. Geliştirici bakmaz, CTO bakar.", "complexity": 2, "pull": 2, "stakes": 2, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "ai_vec_scaling", "name": "Auto Scaling", "voice": "Trafik arttıkça sistem kendini büyütür. Kimse fark etmez — çökene kadar.", "complexity": 5, "pull": 3, "stakes": 5, "dimension_contribution": {"innovation": 1.0, "stability": 3.5, "usability": 0.5}, "requires_research": false, "tags": []},
		{"id": "ai_vec_sdk", "name": "Client SDK", "voice": "Python ve JS için hazır kütüphane. Yoksa kimse entegre etmeye uğraşmaz.", "complexity": 2, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 1.0, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
	],
	"saas_project_mgmt": [
		{"id": "saas_pm_tasks", "name": "Task Board", "voice": "Görevlerin sürüklendiği Kanban panosu. Yoksa ürün sayılmazsın.", "complexity": 2, "pull": 4, "stakes": 2, "dimension_contribution": {"innovation": 0.5, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "saas_pm_gantt", "name": "Gantt Timeline", "voice": "Projeyi zaman çizelgesi olarak göster. Kullanıcı istemez, satın alan yönetici ister.", "complexity": 3, "pull": 3, "stakes": 2, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 2.5}, "requires_research": false, "tags": []},
		{"id": "saas_pm_comments", "name": "Threaded Comments", "voice": "Görevin altında tartışma. Slack trafiğini azaltmaz, sadece taşır.", "complexity": 2, "pull": 3, "stakes": 2, "dimension_contribution": {"innovation": 0.5, "stability": 1.0, "usability": 2.5}, "requires_research": false, "tags": []},
		{"id": "saas_pm_integrations", "name": "Third-Party Integrations", "voice": "GitHub, Slack, Figma bağlantıları. Üçü de yoksa kurumsal müşteri kapıdan döner.", "complexity": 4, "pull": 4, "stakes": 4, "dimension_contribution": {"innovation": 1.0, "stability": 3.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_pm_automation", "name": "Workflow Automation", "voice": "\"Şu olunca şunu yap\" kuralları. Meraklı kullanıcıyı ürüne bağlayan şey.", "complexity": 4, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 2.5, "stability": 1.5, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "saas_pm_reporting", "name": "Reporting", "voice": "Yöneticinin haftalık rapor ihtiyacını karşılar. Renkli pasta grafik şart.", "complexity": 3, "pull": 3, "stakes": 2, "dimension_contribution": {"innovation": 1.0, "stability": 1.5, "usability": 2.5}, "requires_research": false, "tags": []},
	],
	"saas_crm": [
		{"id": "saas_crm_contacts", "name": "Contact Database", "voice": "Müşteri ve kişi kayıtlarının tutulduğu veritabanı. Bu olmadan CRM diyemezsin.", "complexity": 2, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 0.5, "stability": 2.0, "usability": 2.5}, "requires_research": false, "tags": []},
		{"id": "saas_crm_pipeline", "name": "Sales Pipeline", "voice": "Her satış fırsatının hangi aşamada olduğunu gösteren hat. Satış müdürünün ilk baktığı ekran.", "complexity": 3, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 1.0, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "saas_crm_email", "name": "Email Sync", "voice": "Gmail / Outlook bağla. OAuth cehennemi seni bekliyor.", "complexity": 4, "pull": 4, "stakes": 5, "dimension_contribution": {"innovation": 1.0, "stability": 3.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_crm_forecast", "name": "Revenue Forecast", "voice": "Gelecek ay ne kadar satılacağını tahmin eden grafik. Yanılır ama satar.", "complexity": 3, "pull": 3, "stakes": 2, "dimension_contribution": {"innovation": 2.5, "stability": 1.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_crm_mobile", "name": "Mobile App", "voice": "Saha satış ekibi telefondan girmek ister. Sadece web'de kalan CRM ölür.", "complexity": 4, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 1.5, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "saas_crm_call_log", "name": "Call Logging", "voice": "Müşteri aramasını kaydet, özetini otomatik çıkar. Yapay zeka dokunuşu artık mecburi.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 2.5, "stability": 1.5, "usability": 1.5}, "requires_research": false, "tags": []},
	],
	"saas_analytics": [
		{"id": "saas_an_dashboards", "name": "Custom Dashboards", "voice": "Herkes kendi panosunu sürükle-bırakla kurar. Olmazsa veriye kimse bakmaz.", "complexity": 3, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 1.0, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "saas_an_query", "name": "SQL Query Editor", "voice": "SQL yazıp veriyi doğrudan sorgulama. Veri ekibi bunu bulamazsa rakibe gider.", "complexity": 4, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 1.5, "stability": 2.0, "usability": 2.5}, "requires_research": false, "tags": []},
		{"id": "saas_an_alerts", "name": "Anomaly Alerts", "voice": "Bir metrik ters gittiğinde Slack'a uyarı düşer. Geç düşerse iş işten geçmiş olur.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 2.0, "stability": 2.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_an_share", "name": "Shareable Reports", "voice": "Raporu tek linkle dışarı paylaş. Kimin görebileceği kısmı 'küçük' bir detay.", "complexity": 2, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 1.0, "stability": 1.5, "usability": 2.5}, "requires_research": false, "tags": []},
		{"id": "saas_an_etl", "name": "Data Connectors", "voice": "Stripe, Postgres, Mixpanel — veriyi hepsinden içeri çek. Bakımı ayrı bir işkence.", "complexity": 5, "pull": 4, "stakes": 5, "dimension_contribution": {"innovation": 1.0, "stability": 3.5, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "saas_an_embed", "name": "Embedded Analytics", "voice": "Müşterinin kendi ürününe gömülen dashboard. Enterprise satışın anahtarı.", "complexity": 4, "pull": 4, "stakes": 4, "dimension_contribution": {"innovation": 2.5, "stability": 2.0, "usability": 1.5}, "requires_research": false, "tags": []},
	],
	"saas_billing": [
		{"id": "saas_bill_subscriptions", "name": "Subscription Management", "voice": "Abonelikleri kur, aylık tahsilatı otomatik yürüt. Ürünün varlık sebebi.", "complexity": 3, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 0.5, "stability": 3.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_bill_invoice", "name": "Invoice Generation", "voice": "PDF üret, mail at. Muhasebenin kalbini kazan.", "complexity": 2, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 0.5, "stability": 2.0, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "saas_bill_tax", "name": "Tax Calculation", "voice": "KDV, satış vergisi, VAT — vergiyi doğru hesapla. Ülke sayısı kadar kural, ülke sayısı kadar bug.", "complexity": 5, "pull": 2, "stakes": 5, "dimension_contribution": {"innovation": 0.5, "stability": 4.0, "usability": 0.5}, "requires_research": false, "tags": []},
		{"id": "saas_bill_dunning", "name": "Failed Payment Recovery", "voice": "Reddedilen kartı tekrar dene, müşteriye hatırlatma gönder. Sessizce kaybedilen aboneleri kurtarır.", "complexity": 3, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 1.5, "stability": 3.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "saas_bill_webhooks", "name": "Webhook System", "voice": "Ödeme olaylarını müşterinin kendi sistemine anında bildir. Stripe standardı; herkes bekler.", "complexity": 3, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 1.0, "stability": 3.0, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "saas_bill_proration", "name": "Plan Proration", "voice": "Plan değişince kalan günleri kuruşuna kadar hesapla. Tek bug, support cehennemi demek.", "complexity": 4, "pull": 2, "stakes": 5, "dimension_contribution": {"innovation": 0.5, "stability": 3.5, "usability": 1.0}, "requires_research": false, "tags": []},
	],
	"saas_dev_tools": [
		{"id": "saas_dev_cli", "name": "Command-Line Tool", "voice": "Ürünü terminalden kullandıran komut satırı aracı. Yoksa ilk issue bunun için açılır.", "complexity": 2, "pull": 3, "stakes": 2, "dimension_contribution": {"innovation": 1.0, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "saas_dev_api", "name": "REST API", "voice": "Ürünün dışa açılan kapısı; her şey buradan geçer. Versiyonlamayı bozan müşteri kaybeder.", "complexity": 3, "pull": 4, "stakes": 5, "dimension_contribution": {"innovation": 1.0, "stability": 3.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_dev_docs", "name": "Interactive Docs", "voice": "İçinde canlı deneme yapılan dokümantasyon. Okunmayan doküman, entegre edilmeyen ürün demek.", "complexity": 3, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 1.0, "stability": 1.0, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "saas_dev_ci_plugin", "name": "CI Plugin", "voice": "GitHub Actions, GitLab, CircleCI eklentileri. Pipeline'a girmeyen araç unutulur.", "complexity": 4, "pull": 3, "stakes": 4, "dimension_contribution": {"innovation": 1.5, "stability": 3.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_dev_logs", "name": "Live Log Stream", "voice": "Hata ararken canlı log akışı. Yoksa herkes yine SSH'a döner.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 1.5, "stability": 2.5, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_dev_sandbox", "name": "Test Sandbox", "voice": "Geliştirici prod'a dokunmadan güvenle denesin. Olmazsa korkar, hiç kullanmaz.", "complexity": 3, "pull": 3, "stakes": 3, "dimension_contribution": {"innovation": 1.5, "stability": 2.5, "usability": 2.0}, "requires_research": false, "tags": []},
	],
	"saas_ops": [
		{"id": "saas_ops_workflow", "name": "Workflow Automation", "voice": "\"Şu olunca şunu yap\" kurallarıyla süreci otomatikleştir. Manuel takip biter.", "complexity": 4, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 2.5, "stability": 1.5, "usability": 2.0}, "requires_research": false, "tags": []},
		{"id": "saas_ops_reporting", "name": "Reporting Dashboards", "voice": "Yönetimin tek bakışta gördüğü panolar. Rapor kâbusu biter.", "complexity": 3, "pull": 3, "stakes": 2, "dimension_contribution": {"innovation": 1.0, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
		{"id": "saas_ops_integration", "name": "System Integration", "voice": "Mevcut sistemlerle konuşur; veri iki kez girilmez. Kurumsalın ilk sorduğu şey.", "complexity": 5, "pull": 4, "stakes": 5, "dimension_contribution": {"innovation": 1.0, "stability": 3.5, "usability": 1.0}, "requires_research": false, "tags": []},
		{"id": "saas_ops_scheduling", "name": "Scheduling & Appointments", "voice": "Randevu ve planlamayı tek takvimde topla. Çakışma, unutma kalmaz.", "complexity": 3, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 1.0, "stability": 2.0, "usability": 2.5}, "requires_research": false, "tags": []},
		{"id": "saas_ops_field", "name": "Field Connectivity", "voice": "Sahadaki ekip zayıf bağlantıda bile çalışır, sonra senkronlar. Sahanın bel kemiği.", "complexity": 5, "pull": 4, "stakes": 5, "dimension_contribution": {"innovation": 2.0, "stability": 3.0, "usability": 1.5}, "requires_research": false, "tags": []},
		{"id": "saas_ops_mobile", "name": "Mobile App", "voice": "Saha ekibi telefondan girer. Sadece masaüstünde kalan ürün sahada ölür.", "complexity": 4, "pull": 4, "stakes": 3, "dimension_contribution": {"innovation": 1.5, "stability": 1.5, "usability": 3.0}, "requires_research": false, "tags": []},
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
	"saas_ops": [
		{"axis": "innovation", "weight": 0.9, "display_label": "İnovasyon"},
		{"axis": "stability", "weight": 1.5, "display_label": "Saha Güvenilirliği"},
		{"axis": "usability", "weight": 1.1, "display_label": "Kullanılabilirlik"},
	],
}


static func get_sub_product_types(subgenre: String) -> Array:
	return SUB_PRODUCT_TYPES.get(subgenre, [])


## Merged product pool (onboarding rework 2026-07-16: the Subgenre onboarding
## step is gone — product type is decided in-game, so the picker offers EVERY
## pool). Picking a type write-through-sets GameState.subgenre from its pool
## (see ProductSystem.start_build) so subgenre events/VC seeding keep working.
static func get_all_sub_product_types() -> Array:
	var all: Array = []
	for subgenre_key in SUB_PRODUCT_TYPES:
		all.append_array(SUB_PRODUCT_TYPES[subgenre_key])
	return all


## Pool (subgenre key) a sub-product type belongs to; "" if unknown.
static func get_pool_of(sub_product_type_id: String) -> String:
	for subgenre_key in SUB_PRODUCT_TYPES:
		for sub_type in SUB_PRODUCT_TYPES[subgenre_key]:
			if String(sub_type.get("id", "")) == sub_product_type_id:
				return subgenre_key
	return ""


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
