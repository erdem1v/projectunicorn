class_name B2BConstants
extends RefCounted

# THE single tunables block for the B2B Sales System (all stages A-E). Every number
# here is a WORKING PLACEHOLDER — calibration is a separate last pass (PROJECT_SPEC
# §10: numbers last). Grouped by stage. Pure statics; no state, no scene dependency.

# ============================ Stage A — lifecycle ============================
const ONBOARDING_DAYS := 30             # first-impressions window after signing
const RISK_TRIGGER_DAYS := 3            # consecutive days under tolerance → Risk phase
const CHURN_COUNTDOWN_DAYS := 7         # visible "Churn'e ~N gün" counter length
const EXPANSION_MATURE_DAYS := 45       # active + this old → eligible for expansion
const SAT_DRIFT_STEP := 3               # max satisfaction move per day (drift toward target)
const ONBOARDING_AMP := 1.5             # onboarding-window swing amplifier
const RIVAL_SATISFACTION_HOOK := false  # TODO: rival pressure (−); OFF until a rival system exists
const SCALE_DEMO_MAX := 3               # demo generates 1..3 star; 4-5 (Tier 2) gated

const TOLERANCE_BASE := 35              # scale-1 tolerance floor
const TOLERANCE_PER_SCALE := 5          # + per star (larger/loyal endures low satisfaction longer)
# Sector stickiness nudge (some sectors switch vendors less). Working; default 0.
const SECTOR_TOLERANCE_BONUS := {
	"İnşaat": 5, "Sağlık": 5, "Sigorta": 3,
}


static func seed_tolerance(scale: int, industry: String) -> int:
	# Seeded at signing from scale + sector (A.2). Larger/older/loyal = higher.
	var t: int = TOLERANCE_BASE + (maxi(scale, 1) - 1) * TOLERANCE_PER_SCALE
	t += int(SECTOR_TOLERANCE_BONUS.get(industry, 0))
	return clampi(t, 0, 100)


static func support_load_for(scale: int) -> int:
	# CS-capacity cost of managing this account (larger = heavier). Stage D/E.
	return clampi(scale, 1, 5)


static func roll_scale(archetype: String) -> int:
	# 1..5 star size (A.4). Demo caps at SCALE_DEMO_MAX; 4-5 gated behind an unlock
	# flag (Tier 2 enterprise), so the engine simply does not generate them in demo.
	var base := 2
	match archetype:
		"enterprise": base = 5
		"mid": base = 3
		_: base = 2
	if not GameState.get_flag("b2b_high_scale_unlocked", false):
		base = mini(base, SCALE_DEMO_MAX)
	return base


# ======================= Stage B — event families / retention ================
const COMPLAINT_BUG_GATE := 6           # live bugs above this → product-complaint family eligible
const RIVAL_LURE_ENABLED := false       # TODO: rival-lure family; OFF until a rival system exists
const RETAIN_DELAY_MAX_USES := 2        # "Oyala" works this many times, then the customer catches on
const RETAIN_DELAY_DAYS := 3            # days the churn countdown is pushed out by a stall
const RETAIN_DISCOUNT_PCT := 0.15       # "İndirim ver" MRR cut fraction
const RETAIN_SAT_BUMP := 8              # satisfaction relief from a discount
# Retention brand/reputation deltas (every option touches brand/reputation, B.3).
const RETAIN_PROMISE_REP := 1
const RETAIN_DELAY_BRAND := -1
const RETAIN_DISCOUNT_REP := -1
const RETAIN_RELEASE_BRAND := -2


# --- Content tables (working TR drafts; Erdem voice-passes) ---------------------
# Sector-voiced product complaints — the customer speaks their lived experience of a
# failing product (bug-load / low stability). NO raw numbers. Keyed by industry.
const COMPLAINT_VOICE := {
	"Sigorta": "Sisteminiz son haftalarda sürekli düşüyor, ekibim poliçe işlerini yürütemiyor.",
	"İnşaat": "Sahadaki ekip sisteme bağlanamıyor, bağlantı sürekli kopuyor. Böyle iş yürümez.",
	"Lojistik": "Sevkiyat saatinde sistem donuyor, operasyon aksıyor.",
	"Sağlık": "Ekranlar sürekli çöküyor, hasta kapıda beklerken sistemi açamıyoruz.",
	"Üretim": "Hat başında sistem takılıyor, üretim raporu tutmuyor.",
	"Perakende": "Yoğun saatte sistem kilitleniyor, kasa akmıyor.",
	"Emlak": "Sistem sık sık kopuyor, ekip müşteriye dönemiyor.",
	"Tekstil": "Sipariş ekranı sürekli hata veriyor, üretim planı kayıyor.",
	"Hukuk": "Dosyalara erişemiyoruz, sistem gün içinde defalarca düşüyor.",
	"Teknoloji": "Sisteminiz sürekli hata veriyor, ekibimiz üretime dönemiyor.",
	"E-ticaret": "Kampanya saatinde sistem çöküyor, siparişleri kaybediyoruz.",
	"Medya": "Yayın anında sistem donuyor, akış kesiliyor.",
	"Finans": "Sistem gün içinde düşüyor, işlemler askıda kalıyor.",
	"Testing": "Sisteminiz son zamanlarda sık sık aksıyor, ekibim işini yapamıyor.",
}
const COMPLAINT_VOICE_FALLBACK := "Sisteminiz son zamanlarda sık sık aksıyor, ekibim işini yapamıyor."

# Short TR labels for demo B2B features — used in promise button copy (no English on
# screen). Covers both demo products (ai_vector_search + saas_ops).
const FEATURE_LABEL_TR := {
	"ai_vec_embed_api": "anlam altyapısı",
	"ai_vec_search_api": "anlamlı arama",
	"ai_vec_filter": "gelişmiş filtreleme",
	"ai_vec_dashboard": "yönetim paneli",
	"ai_vec_scaling": "ölçeklenme",
	"ai_vec_sdk": "hazır kütüphane",
	"saas_ops_workflow": "süreç otomasyonu",
	"saas_ops_reporting": "raporlama panosu",
	"saas_ops_integration": "sistem entegrasyonu",
	"saas_ops_scheduling": "randevu planlama",
	"saas_ops_field": "saha bağlantısı",
	"saas_ops_mobile": "mobil uygulama",
}
const FEATURE_LABEL_FALLBACK := "yeni özellik"

# In-voice surface pain lines for prospects/special-requests, keyed by feature id
# (B.4: the pain maps to a feature that EXISTS in the product pool).
const PAIN_PHRASE := {
	"ai_vec_embed_api": "Verimizi anlamlandıracak bir altyapı arıyoruz, kelime eşleşmesi yetmiyor.",
	"ai_vec_search_api": "Aradığımızı tarif edebilmek istiyoruz, birebir kelime değil.",
	"ai_vec_filter": "Aramayı tarihe ve etikete göre daraltamıyoruz, ekip boğuluyor.",
	"ai_vec_dashboard": "Kullanımı göremiyoruz, yönetim kör uçuyor.",
	"ai_vec_scaling": "Yoğunlukta sistem yavaşlıyor, ölçeklenme derdimiz var.",
	"ai_vec_sdk": "Entegrasyon zor, hazır bir kütüphane olmadan bağlanamıyoruz.",
	"saas_ops_workflow": "Süreçler hâlâ elle yürüyor, otomasyon arıyoruz.",
	"saas_ops_reporting": "Raporlama karmaşası içindeyiz, yönetim net veri istiyor.",
	"saas_ops_integration": "Sistemlerimiz birbiriyle konuşmuyor, entegrasyon şart.",
	"saas_ops_scheduling": "Randevu ve planlama dağınık, çakışmalar yaşıyoruz.",
	"saas_ops_field": "Sahadaki ekip bağlantı sorunundan çalışamıyor.",
	"saas_ops_mobile": "Ekip telefondan giremiyor, saha kopuk kalıyor.",
}
const PAIN_PHRASE_FALLBACK := "Bu tarafta ciddi bir eksik var, çözecek bir araç arıyoruz."

# Sector-appropriate contact role shown under the customer name in the modal.
const SECTOR_CONTACT := {
	"Sigorta": "BT Müdürü", "İnşaat": "Saha Sorumlusu", "Lojistik": "Operasyon Müdürü",
	"Sağlık": "Başhekim Yardımcısı", "Üretim": "Üretim Müdürü", "Perakende": "Mağaza Müdürü",
	"Emlak": "Satış Müdürü", "Tekstil": "Planlama Şefi", "Hukuk": "Ofis Yöneticisi",
	"Teknoloji": "CTO", "E-ticaret": "Operasyon Direktörü", "Medya": "Yayın Yönetmeni",
	"Finans": "Risk Müdürü",
}
const SECTOR_CONTACT_FALLBACK := "Yetkili"

# Sector-appropriate company names for prospect generation (E.2 keeps fiction clean —
# a construction prospect reads "Kuzey İnşaat", not a generic label).
const SECTOR_COMPANIES := {
	"İnşaat": ["Kuzey İnşaat", "Anadolu Yapı", "Marmara İnşaat"],
	"Lojistik": ["Deniz Lojistik", "Nordica Lojistik", "Ege Kargo"],
	"Sağlık": ["Aras Klinik", "Marmara Klinik", "Bosphorus Sağlık"],
	"Sigorta": ["Ege Sigorta", "Anadolu Sigorta", "Deniz Sigorta"],
	"Üretim": ["Beykoz Üretim", "Trakya Fabrika", "Ege Metal"],
	"Teknoloji": ["Nexus Yazılım", "Piksel Teknoloji", "Volt Sistemleri"],
	"E-ticaret": ["Sepet Ticaret", "Hızlı Pazar", "Vitrin Online"],
	"Medya": ["Kanal Medya", "Punto Yayın", "Ekran Prodüksiyon"],
	"Finans": ["Kule Finans", "Anadolu Yatırım", "Pusula Portföy"],
}
const SECTOR_COMPANIES_FALLBACK := ["Nordica", "Palmiye Holding", "Beykoz Tekstil"]


static func sector_companies(industry: String) -> Array:
	return SECTOR_COMPANIES.get(industry, SECTOR_COMPANIES_FALLBACK)


static func sector_contact(industry: String) -> String:
	return String(SECTOR_CONTACT.get(industry, SECTOR_CONTACT_FALLBACK))


static func complaint_voice(industry: String) -> String:
	return String(COMPLAINT_VOICE.get(industry, COMPLAINT_VOICE_FALLBACK))


static func feature_label(feature_id: String) -> String:
	return String(FEATURE_LABEL_TR.get(feature_id, FEATURE_LABEL_FALLBACK))


static func pain_phrase(feature_id: String) -> String:
	return String(PAIN_PHRASE.get(feature_id, PAIN_PHRASE_FALLBACK))


# ======================= Stage C — promises ==================================
const PROMISE_DEADLINE_DAYS := 14
const PROMISE_KEPT_SAT := 15
const PROMISE_KEPT_TOLERANCE := 5
const PROMISE_BROKEN_SAT := -20         # doubled drop (returns angrier)
const PROMISE_BROKEN_TOLERANCE := -5
const PROMISE_BROKEN_BRAND := -3
const PROMISE_PARTIAL_SAT := -5         # soft penalty for a late (post-deadline) ship


# ======================= Stage D — Customer Success ==========================
const CS_BASE_CAPACITY := 3
const CS_SKILL_PER_SLOT := 25
const FOUNDER_DIRECT_CAP := 4           # founder manages at most ~this many directly
const CS_ESCALATION_SAT := 35           # CS-managed customer crosses this → one escalation
const CS_DAMPEN_MIN := 0.4              # floor on the erosion slowdown a great CS gives
const CS_REFUSE_BRAND := 3              # brand DROP magnitude on refusing a CS's promise
const CS_REFUSE_MORALE := 10            # morale DROP magnitude for that CS employee


static func cs_capacity(skill: int) -> int:
	# How many customers one CS rep can hold, rising with skill.
	return CS_BASE_CAPACITY + int(float(maxi(skill, 0)) / float(CS_SKILL_PER_SLOT))


static func cs_dampen(skill: int) -> float:
	# Higher CS skill → slower satisfaction erosion for hands-off customers.
	return clampf(1.0 - float(maxi(skill, 0)) / 200.0, CS_DAMPEN_MIN, 1.0)


# ======================= Stage E — 2nd product / affinity / expansion =========
# Prospect industry pool per B2B product's sector affinity (E.2). The active
# mvp_sub_product_type_id selects the sector list; a prospect's industry is drawn
# only from it, so a vector-search product never yields a construction prospect.
const SECTOR_AFFINITY := {
	"ai_vector_search": ["Teknoloji", "E-ticaret", "Medya", "Finans"],
	"saas_ops": ["İnşaat", "Lojistik", "Sağlık", "Sigorta", "Üretim"],
}
const SECTOR_AFFINITY_FALLBACK := ["Lojistik", "Emlak", "Tekstil", "Sigorta", "Perakende", "Hukuk", "İnşaat", "Sağlık"]

# Prospect value shown as a RANGE, not a fixed number (E.3): the floor if it goes
# poorly, the ceiling if well. Placeholder half-width fractions around the archetype
# band midpoint; the signed MRR still lands inside via the pitch price lever.
const VALUE_BAND_LOW_FRAC := 0.65
const VALUE_BAND_HIGH_FRAC := 1.15

# Expansion (E.4): a healthy mature account grows seats → MRR. Working amounts.
const EXPANSION_SEATS := {"small": 3, "mid": 6, "enterprise": 12}
const EXPANSION_PER_SEAT_MRR := 120


static func sector_pool(sub_id: String) -> Array:
	return SECTOR_AFFINITY.get(sub_id, SECTOR_AFFINITY_FALLBACK)


static func expansion_seats(archetype: String) -> int:
	return int(EXPANSION_SEATS.get(archetype, 3))
