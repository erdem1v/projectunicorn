class_name B2BConstants
extends RefCounted

# THE tunables block for the B2B account machine (lifecycle, retention, promises, Customer
# Success, expansion) and its HR coupling; the Sales module's meeting/pipeline numbers live in
# SalesConstants. Every number here is a WORKING PLACEHOLDER — calibration is a separate last
# pass (numbers last). Pure statics; no state, no scene dependency.

# ================================ Lifecycle ==================================
const ONBOARDING_DAYS := 30             # first-impressions window after signing
const RISK_TRIGGER_DAYS := 3            # consecutive days under tolerance → Risk phase
# HYSTERESIS: after an account LEAVES Risk it cannot re-enter for this many days, however far
# under its bar it drifts (the streak keeps counting; the countdown and the retention card do
# not start). The bump a rescue buys (+8) decays back under the bar in ~3 days, so without
# this the retention card would return every few days. Three weeks is the founder's time to
# move the CAUSE (a sprint, a version) before the account asks again.
const RISK_REENTRY_DAYS := 21           # [WORKING] days after leaving Risk before it can re-enter
const CHURN_COUNTDOWN_DAYS := 7         # visible "Churn'e ~N gün" counter length
const EXPANSION_MATURE_DAYS := 45       # active + this old → eligible for expansion
const SAT_DRIFT_STEP := 3               # max satisfaction move per day (drift toward target)
const ONBOARDING_AMP := 1.5             # onboarding-window swing amplifier

# TOLERANCE BAND — the satisfaction bar under which an account starts toward Risk:
# BASE + PER × (scale − 1) + sector bonus. Pinned against the probe's 5-account book
# (2 small · 2 mid+sector · 1 enterprise): a good v1 (target ~55) should satisfy ~60 % of it
# and a weak v1 (~42) ~20 %: bars small(scale 2) 42 · small+insurance 45 ·
# mid/enterprise(scale 3) 51 · +health/construction 56.
# Sign note (see PROMISE_* below): higher scale = pickier; unchanged, intended.
const TOLERANCE_BASE := 33              # scale-1 tolerance floor
const TOLERANCE_PER_SCALE := 9          # + per star (larger = pickier; Tier-2 scale 5 → 69, re-seat with that unlock)
# Per-sector addition to the bar (same sign as TOLERANCE_PER_SCALE: + = pickier). Working;
# unlisted sectors add 0.
const SECTOR_TOLERANCE_BONUS := {
	"construction": 5, "health": 5, "insurance": 3,
}


static func seed_tolerance(scale: int, industry: String) -> int:
	# Seeded at signing from scale + sector. Higher = pickier (enters Risk sooner).
	var t: int = TOLERANCE_BASE + (maxi(scale, 1) - 1) * TOLERANCE_PER_SCALE
	t += int(SECTOR_TOLERANCE_BONUS.get(industry, 0))
	return clampi(t, 0, 100)


# ======================== Event families / retention =========================
const COMPLAINT_BUG_GATE := 6           # live bugs above this → product-complaint family eligible
const RETAIN_DELAY_MAX_USES := 2        # "Oyala" works this many times, then the customer catches on
# "İndirim ver" use cap: per account, across BOTH discount channels (the retention card and
# the CS renewal card — both resolve through apply_discount). Past the cap the row stays
# VISIBLE but locked, with the reason on its sub-line (B2B_DISCOUNT_SPENT_DESC). Without a
# ceiling a 15 % cut is a strictly dominant move.
const RETAIN_DISCOUNT_MAX_USES := 2     # [WORKING] discounts per account, then the row locks
const RETAIN_DELAY_DAYS := 3            # days the churn countdown is pushed out by a stall
const RETAIN_DISCOUNT_PCT := 0.15       # "İndirim ver" MRR cut fraction
const RETAIN_SAT_BUMP := 8              # satisfaction relief from a discount
# Retention brand/reputation deltas (every option touches brand/reputation).
const RETAIN_PROMISE_REP := 1
# The stall costs REPUTATION, not brand (a private credibility cost, like the discount's).
# The card carries `add_reputation -1`; this is the number the smoke guard reads.
const RETAIN_DELAY_REP := -1
const RETAIN_DISCOUNT_REP := -1
const CHURN_BRAND := -2                 # brand hit at the ACTUAL churn moment (countdown expiry)


# --- Sector identity ----------------------------------------------------------
# SECTORS ARE IDS, NOT WORDS. `industry` is a persisted @export on Customer and Prospect, so
# it holds the ASCII id; the sector copy on screen is a strings.csv row derived from the id at
# display time (B2B_CONTACT_<ID>, B2B_COMPLAINT_<ID>) — the BILINGUAL BIRTH LAW's "store ids,
# render labels".
const SECTORS := ["construction", "health", "logistics", "insurance", "manufacturing",
	"retail", "real_estate", "textile", "legal", "technology", "ecommerce", "media",
	"finance"]
# A FIXTURE sector, deliberately outside SECTORS: smoke and the run probe need a prospect
# whose sector is not one of the thirteen the CompanyCatalog stocks. It carries its own
# copy rows so the derived-key check covers it, but no company pool.
const SECTOR_FIXTURE := "testing"

# Saves written before this migration carry the old Turkish name in `industry`.
# SaveManager's v1→v2 migration maps them through this table; it is the ONLY place the
# legacy spellings survive, and it is data, not copy.
const LEGACY_SECTOR_IDS := {
	"İnşaat": "construction", "Sağlık": "health", "Lojistik": "logistics",        # LOC-DATA legacy save values
	"Sigorta": "insurance", "Üretim": "manufacturing", "Perakende": "retail",     # LOC-DATA legacy save values
	"Emlak": "real_estate", "Tekstil": "textile", "Hukuk": "legal",               # LOC-DATA legacy save values
	"Teknoloji": "technology", "E-ticaret": "ecommerce", "Medya": "media",        # LOC-DATA legacy save values
	"Finans": "finance", "Testing": "testing",                                    # LOC-DATA legacy save values
}


# --- Sector / feature copy ------------------------------------------------------
# Copy is derived from the id: one id yields one strings.csv key in both languages, so no
# table can drift from the CSV. A derived key is invisible to a grep for tr("LITERAL"), so
# the smoke case `loc_b2b_derived_keys` walks SECTORS and the feature ids and asserts every
# derived key resolves — that is what stops a typo rendering a raw token on screen.

static func sector_contact(industry: String) -> String:
	return _derived("B2B_CONTACT_", industry, "B2B_CONTACT_FALLBACK")


static func complaint_voice(industry: String) -> String:
	return _derived("B2B_COMPLAINT_", industry, "B2B_COMPLAINT_FALLBACK")


static func feature_label(feature_id: String) -> String:
	# A line step names itself (PROD_STEP_* rows, the same name the product screen shows).
	var step: Dictionary = ProductLines.step(feature_id)
	if not step.is_empty():
		return TranslationServer.translate(String(step.get("name_key", "FEATURE_LABEL_FALLBACK")))
	return _derived("FEATURE_LABEL_", feature_id, "FEATURE_LABEL_FALLBACK")


# TranslationServer returns the KEY itself when a row is missing, which on screen looks
# like a raw token. Rather than ship that, an unresolved derived key falls back to the
# family's fallback row.
# TranslationServer (not tr()) because these are statics with no Object to translate through.
static func _derived(prefix: String, id: String, fallback_key: String) -> String:
	if id == "":
		return TranslationServer.translate(fallback_key)
	var key: String = prefix + id.to_upper()
	var out: String = TranslationServer.translate(key)
	return out if out != key else TranslationServer.translate(fallback_key)


# ================================= Promises ==================================
const PROMISE_DEADLINE_DAYS := 14
const PROMISE_KEPT_SAT := 15
const PROMISE_BROKEN_SAT := -20         # doubled drop (returns angrier)
const PROMISE_BROKEN_BRAND := -3
const PROMISE_PARTIAL_SAT := -5         # soft penalty for a late (post-deadline) ship

# `tolerance` is the satisfaction level BELOW which an account enters Risk, so a HIGHER
# tolerance is a PICKIER customer:
#   kept   → LOWER tolerance → endures more before Risk → loyalty
#   broken → HIGHER tolerance → snaps sooner → "returns angrier"
const PROMISE_KEPT_TOLERANCE := -5
const PROMISE_BROKEN_TOLERANCE := 5
# Cap on the broken-promise ratchet: a broken word makes an account pickier, never
# impossible — tolerance stops this far above where it was seeded.
const PROMISE_TOLERANCE_CEILING := 10


# ============================= Customer Success ==============================
# HESAP KAPASİTESİ YILDIZDAN TÜRER, tek çift sabitten (direktör hükmü). Çapa örnekleri
# direktörün kendi sayıları: 1★ → 6 · 1,5★ → 7 · 2★ → 8. AREA_MAX'te 14 veriyor — ayarlanmış
# bir sayı değil, bilinçli bir kalibrasyon yüzeyi. [K]
const ACCOUNT_CAP_BASE := 4             # [K] taban: yıldızsız bir sahip bile bu kadar taşır
const ACCOUNT_CAP_PER_STAR := 2         # [K] her tam yıldız bu kadar slot ekler
const CS_ESCALATION_SAT := 35           # CS-managed customer crosses this → one escalation
const CS_DAMPEN_MIN := 0.4              # floor on the erosion slowdown a great CS gives
const CS_REFUSE_BRAND := 3              # brand DROP magnitude on refusing a CS's promise
const CS_REFUSE_MORALE := 10            # morale DROP magnitude for that CS employee


## KAÇ HESAP TAŞINIR: 4 + 2 × yıldız, ve sahibin KİM olduğu sorulmaz.
##
## Aynı çağrı hem temsilci hem kurucu için kullanılır; "kurucu şu kadar taşır" diye ayrı bir
## sabit YOK. Kurucunun kapasitesi kendi MÜŞTERİ İLİŞKİLERİ yıldızından çıkar, tıpkı
## herkesinki gibi.
##
## Yıldız üzerinden okunuyor, puan üzerinden değil: `stars_for` yarım yıldızları taşıyor
## (POINTS_PER_STAR 2), yani 1,5★ gerçekten 7 slot demek.
static func account_capacity(customer_success: int) -> int:
	var stars: float = HRConstants.stars_for(maxi(customer_success, 0))
	return ACCOUNT_CAP_BASE + int(round(float(ACCOUNT_CAP_PER_STAR) * stars))


# Churn suppression per point of the steward's effective MÜŞTERİ İLİŞKİLERİ output. Anchored so
# an output of 5 dampens to 1 − 5×0.055 = 0.725 (smoke pins it). Effective output can pass the ruler (high-morale band,
# output_mult trait), and CS_DAMPEN_MIN is the floor there.
const CS_DAMPEN_PER_POINT := 0.055


static func cs_dampen(expertise: int) -> float:
	# Higher MÜŞTERİ İLİŞKİLERİ output → slower satisfaction erosion for hands-off customers. Erosion ONLY;
	# upward recovery is full-strength (see B2BSalesSystem._tick_satisfaction).
	return clampf(1.0 - float(maxi(expertise, 0)) * CS_DAMPEN_PER_POINT, CS_DAMPEN_MIN, 1.0)


# ================================= Expansion =================================
# A healthy mature account grows seats → MRR. The account's own signed seat_price is the rate
# (Satış §5.4); this flat per-seat rate is only the fallback for an account with no stamp.
const EXPANSION_PER_SEAT_MRR := 120
# Seats one expansion adds, per archetype (Customer.company_size); anything else counts as small.
const EXPANSION_SEATS := {"small": 3, "mid": 6, "enterprise": 12}


static func expansion_seats(archetype: String) -> int:
	return int(EXPANSION_SEATS.get(archetype, EXPANSION_SEATS["small"]))


# ================= HR coupling (müşteri masası) ==================
# WORKING PLACEHOLDERS, like every number above. These live HERE and not in HRConstants on
# purpose: HRConstants' "Formula-coefficient homes" note rules that it owns the PEOPLE numbers
# (bands, morale, traits, leave, the Liderlik curves) while a formula's coefficients live next
# to the arithmetic that uses them — B2BConstants.CS_DAMPEN_PER_POINT is the worked precedent.
# Every number below is a coefficient on a customer-desk formula, so it belongs to this file.
#
# THE INVARIANT THAT SHAPES ALL OF IT: with zero Müşteri Temsilcisi every formula here
# multiplies out to nothing. The desk tests its headcount before touching any state.

# Extra reps on the SAME request queue interfere with each other, so rank-0 counts full,
# rank-1 counts this fraction, rank-2 that fraction squared, and so on. This is
# role-STRUCTURAL (a queue gets crowded), which is why it is not a UYUM reading.
const REP_STACK_DECAY := 0.6

# --- Müşteri masası (CustomerRepSystem) ---
# Phases the morning delegation sweep (_delegate_excess) may hand over; it never reaches into
# onboarding. A newly signed account can still land on a rep at signing, through
# CustomerRepSystem.auto_assign_new, when a rep has room.
const CS_ASSIGNABLE_PHASES := ["active", "risk", "expansion"]
# Request channel. Fires for the WHOLE customer book, founder-managed accounts included, from
# the rep's first day. Stewardship (assigned_to) is the separate, capped job.
const CS_REQUEST_INTERVAL_DAYS := 22    # WORKING — bir hesap bu aralıkla talep açar
# Faz, hesap imzalanırken bu adımla yürüyen bir sayaçtan atanır (bkz. Customer.cs_request_phase).
# 9 ile 22 aralarında asal → sayaç tüm yuvaları dolaşır, ardışık düşmez: 0, 9, 18, 5, 14, 1, 10…
const CS_PHASE_STRIDE := 9
# Şirket geneli tavan: bir hesap ne kadar sık talep açarsa açsın, oyuncu 7 günde en fazla bu
# kadar CS kararıyla kesilir. WORKING. Retention/churn modalleri bu tavana DAHİL DEĞİL — onlar
# ölen bir hesabın sonucu, rutin trafik değil (Erdem kararı).
const CS_ESCALATION_WEEKLY_CAP := 2
const CS_ESCALATION_WINDOW_DAYS := 7
const CS_THROUGHPUT_BASE := 0.5         # hiç katkısı olmayan bir temsilcinin bile günlük talep kapasitesi
const CS_THROUGHPUT_PER_PACE := 0.15    # MÜŞTERİ İLİŞKİLERİ katkısının puanı başına günlük ek talep
# Absorb-vs-escalate is the judgement valve: ceiling = CS_ABSORB_BASE + the top rep's MÜŞTERİ
# İLİŞKİLERİ points, compared against a request's difficulty (CustomerRepSystem.
# request_difficulty). At 4 points the ceiling is 7, which absorbs an unhappy scale-3 account
# asking for an unshipped feature (1+2+2+2); at 3 points that same request reaches the player.
const CS_ABSORB_BASE := 3               # WORKING — rutin talepler daha çok yutulur
const CS_ESCALATE_AFTER_DAYS := 3       # bu kadar gün karşılanmayan talep oyuncuya çıkar

# --- Talep türleri ---
# Üç tür kendi gövde metnini ve kendi seçenek setini kurar; söz vermek YALNIZ `feature`'ın
# varsayılanı. Aynı hesaptan arka arkaya aynı tür gelmez (Customer.last_request_kind).
const CS_KIND_FEATURE := "feature"      # özellik isteği
const CS_KIND_COMPLAINT := "complaint"  # şikâyet
const CS_KIND_RENEWAL := "renewal"      # yenileme sinyali
const CS_REQUEST_KINDS := [CS_KIND_FEATURE, CS_KIND_COMPLAINT, CS_KIND_RENEWAL]

# --- Söz dayanıklılığı (Customer.trust_offset) ---
# Kept/broken promises shift the account's satisfaction TARGET, not just its current value.
# Without this the -20 of PROMISE_BROKEN_SAT is erased by SAT_DRIFT_STEP (3/day) inside a
# week and a broken word leaves no trace. The offset forgives on its own, so one mistake
# makes an account FRAGILE for a month rather than doomed forever.
const PROMISE_KEPT_OFFSET := 6.0
const PROMISE_PARTIAL_OFFSET := -2.0
const PROMISE_BROKEN_OFFSET := -12.0
const TRUST_OFFSET_MIN := -25.0
const TRUST_OFFSET_MAX := 10.0
const TRUST_OFFSET_DECAY_PER_DAY := 0.4   # -12 → 0 in 30 days

# --- Ticker attribution (EventBus.headline_added source; sibling of
#     HRConstants.notice_source_hr(), kept here because the emitters are sales-domain). ---
# Localized at EMIT time. The ticker stream is transient, so an item written before a
# language switch keeps its old attribution until it scrolls off — the same accepted
# staleness class as an already-open modal.
static func notice_source_sales() -> String:
	return TranslationServer.translate("NOTICE_SRC_SALES")
