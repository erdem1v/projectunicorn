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
	"construction": 5, "health": 5, "insurance": 3,
}


static func seed_tolerance(scale: int, industry: String) -> int:
	# Seeded at signing from scale + sector (A.2). Larger/older/loyal = higher.
	var t: int = TOLERANCE_BASE + (maxi(scale, 1) - 1) * TOLERANCE_PER_SCALE
	t += int(SECTOR_TOLERANCE_BONUS.get(industry, 0))
	return clampi(t, 0, 100)


# support_load_for() DELETED (Task 2b). It was `clampi(scale, 1, 5)` on a value already
# clamped to 1..5 — an identity function whose only caller fed a Customer field with zero
# readers and no registry seam. The CS model that landed counts ACCOUNTS, and where account
# weight is genuinely needed the request channel reads `scale` directly: a second field
# holding the same number is a sync hazard, not a feature.


static func roll_scale(archetype: String) -> int:
	# 1..5 star size (A.4). Demo caps at SCALE_DEMO_MAX; 4-5 gated behind an unlock
	# flag (Tier 2 enterprise), so the engine simply does not generate them in demo.
	var base: int = CustomerArchetypes.scale_base(archetype)
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
const CHURN_BRAND := -2                 # brand hit at the ACTUAL churn moment (countdown expiry)


# --- Sector identity ----------------------------------------------------------
# SECTORS ARE IDS, NOT WORDS. They used to be Turkish display names ("İnşaat") doing
# double duty as dictionary keys AND as the label on screen — and `industry` is a
# persisted @export on Customer and Prospect, so that Turkish text was being written
# into save files. That is the exact thing the BILINGUAL BIRTH LAW forbids: store ids,
# render labels at display time. The id is now ASCII and the label comes from
# strings.csv via sector_label().
const SECTORS := ["construction", "health", "logistics", "insurance", "manufacturing",
	"retail", "real_estate", "textile", "legal", "technology", "ecommerce", "media",
	"finance"]
# A FIXTURE sector, deliberately outside SECTORS: smoke and the run probe need a prospect
# whose sector is not one of the thirteen the CompanyCatalog stocks. It carries its own
# copy rows so the derived-key check covers it, but no company pool and no affinity entry.
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
# The four tables that used to live here (COMPLAINT_VOICE, PAIN_PHRASE, SECTOR_CONTACT,
# FEATURE_LABEL_TR) are now rows in strings.csv, derived from the id. One id therefore
# yields one key in both languages and the table cannot drift from the CSV.
# A derived key is invisible to a grep for tr("LITERAL"), so the smoke case
# `loc_b2b_derived_keys` walks SECTORS and the feature ids and asserts every derived key
# resolves — that is what stops a typo rendering a raw token on screen.

static func sector_label(industry: String) -> String:
	return _derived("SECTOR_", industry, "SECTOR_FALLBACK")


static func sector_contact(industry: String) -> String:
	return _derived("B2B_CONTACT_", industry, "B2B_CONTACT_FALLBACK")


static func complaint_voice(industry: String) -> String:
	return _derived("B2B_COMPLAINT_", industry, "B2B_COMPLAINT_FALLBACK")


static func feature_label(feature_id: String) -> String:
	return _derived("FEATURE_LABEL_", feature_id, "FEATURE_LABEL_FALLBACK")


static func pain_phrase(feature_id: String) -> String:
	return _derived("B2B_PAIN_", feature_id, "B2B_PAIN_FALLBACK")


# TranslationServer returns the KEY itself when a row is missing, which on screen looks
# like a raw token. Rather than ship that, an unresolved derived key falls back to the
# family's fallback row — the same behaviour the old .get(key, FALLBACK) tables had.
# TranslationServer (not tr()) because these are statics with no Object to translate through.
static func _derived(prefix: String, id: String, fallback_key: String) -> String:
	if id == "":
		return TranslationServer.translate(fallback_key)
	var key: String = prefix + id.to_upper()
	var out: String = TranslationServer.translate(key)
	return out if out != key else TranslationServer.translate(fallback_key)

# Sector-appropriate company names for prospect generation (E.2 keeps fiction clean —
# a construction prospect reads "Kuzey İnşaat", not a generic label) live in
# CompanyCatalog — the single company/background source (Fix 2). The old
# SECTOR_COMPANIES table here covered 9 of 13 sectors at 3 names each and served
# four sectors one shared fallback list, which is how "Beykoz Tekstil" appeared
# as an Emlak, Hukuk AND Perakende prospect in one run.


# ======================= Stage C — promises ==================================
const PROMISE_DEADLINE_DAYS := 14
const PROMISE_KEPT_SAT := 15
const PROMISE_BROKEN_SAT := -20         # doubled drop (returns angrier)
const PROMISE_BROKEN_BRAND := -3
const PROMISE_PARTIAL_SAT := -5         # soft penalty for a late (post-deadline) ship

# SIGN CORRECTION (Task 2b). `tolerance` is the satisfaction level BELOW which an account
# enters Risk (b2b_sales_system.gd:97 `satisfaction < tolerance`), so a HIGHER tolerance means
# a PICKIER customer, not a more patient one. These two constants were written the other way
# round: the broken-promise line carried -5 and was commented "returns angrier", but lowering
# tolerance makes the account calmer — a broken word literally RELIEVED the customer, which is
# the opposite of what it must do. Signs flipped so the code matches the fiction:
#   kept   → LOWER tolerance → endures more before Risk → loyalty, as intended
#   broken → HIGHER tolerance → snaps sooner → the promised "returns angrier"
# The same inversion exists in TOLERANCE_PER_SCALE and SECTOR_TOLERANCE_BONUS above. Those are
# balance shape rather than a broken cause-and-effect, so they are REPORTED to the curve
# session and left alone here.
const PROMISE_KEPT_TOLERANCE := -5
const PROMISE_BROKEN_TOLERANCE := 5


# ======================= Stage D — Customer Success ==========================
const CS_BASE_CAPACITY := 3
# The founder hands an account over only once they are carrying more than this many directly —
# which is exactly what this constant always claimed to mean and, until Task 2b, never did
# (zero readers). It gates STEWARDSHIP only: the request channel is uncapped and runs from the
# rep's first day, so a hire is never idle. Deliberately NOT an erosion penalty on the excess —
# that would change behaviour for runs with no CS staff and break the additive-coupling proof.
const FOUNDER_DIRECT_CAP := 4           # founder manages at most ~this many directly
const CS_ESCALATION_SAT := 35           # CS-managed customer crosses this → one escalation
const CS_DAMPEN_MIN := 0.4              # floor on the erosion slowdown a great CS gives
const CS_REFUSE_BRAND := 3              # brand DROP magnitude on refusing a CS's promise
const CS_REFUSE_MORALE := 10            # morale DROP magnitude for that CS employee


static func cs_capacity(pace: int) -> int:
	# How many accounts one rep can steward, rising with HIZ. Reads PACE, not UZMANLIK: how
	# MANY you can carry is a volume question, and the shipped role contract already says so
	# (hr_constants.gd:118 — pace = "Talep işleme temposu"). UZMANLIK keeps the quality half
	# (cs_dampen + the absorb/escalate valve), so both axes on a Müşteri Temsilcisi file are
	# load-bearing and the hire is a real trade-off rather than one stat plus decoration.
	# Ladder: HIZ 0-2 → 3, 3-5 → 4, 6-8 → 5, 9 → 6.
	return CS_BASE_CAPACITY + int(float(maxi(pace, 0)) / float(CS_PACE_PER_SLOT))


# Churn suppression per UZMANLIK point (HR Coupling). DERIVED, not chosen: the old law was
# `1 − cs_skill/200` on a 0-100 scale, and the equivalence anchor is that a UZMANLIK-5 rep
# dampens exactly as the seeded cs_skill-55 rep did → 1 − 5×0.055 = 0.725 = 1 − 55/200, byte-equal.
# At the top of the ruler this gives 1 − 9×0.055 = 0.505, essentially the old 0.5 at cs_skill 100 —
# so CS_DAMPEN_MIN stays structurally unreachable, exactly as it was before. That floor is kept
# rather than deleted because it is the guard if the per-point value is ever raised.
const CS_DAMPEN_PER_POINT := 0.055


static func cs_dampen(expertise: int) -> float:
	# Higher UZMANLIK → slower satisfaction erosion for hands-off customers. Erosion ONLY;
	# upward recovery is full-strength (see B2BSalesSystem._tick_satisfaction).
	return clampf(1.0 - float(maxi(expertise, 0)) * CS_DAMPEN_PER_POINT, CS_DAMPEN_MIN, 1.0)


# ======================= Stage E — 2nd product / affinity / expansion =========
# Prospect industry pool per B2B product's sector affinity (E.2). The active
# mvp_sub_product_type_id selects the sector list; a prospect's industry is drawn
# only from it, so a vector-search product never yields a construction prospect.
const SECTOR_AFFINITY := {
	"ai_vector_search": ["technology", "ecommerce", "media", "finance"],
	"saas_ops": ["construction", "logistics", "health", "insurance", "manufacturing"],
}
const SECTOR_AFFINITY_FALLBACK := ["logistics", "real_estate", "textile", "insurance", "retail", "legal", "construction", "health"]

# Prospect value shown as a RANGE, not a fixed number (E.3): the floor if it goes
# poorly, the ceiling if well. Placeholder half-width fractions around the archetype
# band midpoint; the signed MRR still lands inside via the pitch price lever.
const VALUE_BAND_LOW_FRAC := 0.65
const VALUE_BAND_HIGH_FRAC := 1.15

# Expansion (E.4): a healthy mature account grows seats → MRR. Working amounts.
# Per-archetype seat steps live in CustomerArchetypes (single data home); the flat
# per-seat rate stays here (not archetype-keyed).
const EXPANSION_PER_SEAT_MRR := 120


static func sector_pool(sub_id: String) -> Array:
	return SECTOR_AFFINITY.get(sub_id, SECTOR_AFFINITY_FALLBACK)


# --- B2B pitch meeting room art (the remap SEAM). Placeholder: every sector maps to
#     the existing neutral meeting room until the sector-specific art lands (fabrika /
#     hukuk bürosu / klinik / startup ofisi — planned). When it arrives, each entry is a
#     one-line remap to res://assets/art/rooms/room_<sector>.webp. ---
const SECTOR_ROOM_DEFAULT := "res://assets/art/rooms/room_anchor.webp"
const SECTOR_ROOM := {
	"construction": SECTOR_ROOM_DEFAULT, "logistics": SECTOR_ROOM_DEFAULT, "health": SECTOR_ROOM_DEFAULT,
	"insurance": SECTOR_ROOM_DEFAULT, "manufacturing": SECTOR_ROOM_DEFAULT, "technology": SECTOR_ROOM_DEFAULT,
	"ecommerce": SECTOR_ROOM_DEFAULT, "media": SECTOR_ROOM_DEFAULT, "finance": SECTOR_ROOM_DEFAULT,
}


static func sector_room(industry: String) -> String:
	return String(SECTOR_ROOM.get(industry, SECTOR_ROOM_DEFAULT))


static func expansion_seats(archetype: String) -> int:
	return CustomerArchetypes.expansion_seats(archetype)


# ============ Stage F — HR coupling (satış masası + müşteri masası, Task 2b) ==========
# WORKING PLACEHOLDERS, like every number above. These live HERE and not in HRConstants on
# purpose: hr_constants.gd:62-76 rules that HRConstants owns the PEOPLE numbers (bands,
# morale, traits, leave, the Liderlik curves) while a formula's coefficients live next to the
# arithmetic that uses them — B2BConstants.CS_DAMPEN_PER_POINT is the worked precedent. Every
# number below is a coefficient on a Sales/Customer formula, so it belongs to this file.
#
# THE INVARIANT THAT SHAPES ALL OF IT: with zero Satış Uzmanı and zero Müşteri Temsilcisi,
# every formula here multiplies out to nothing and the game behaves exactly as it did before
# Task 2b. Both desks test their headcount before touching any state.

# Shared by both desks: extra people on the SAME queue interfere with each other, so rank-0
# counts full, rank-1 counts this fraction, rank-2 that fraction squared, and so on. This is
# role-STRUCTURAL (a queue gets crowded), which is why it is not a UYUM reading — see the
# rapport verdict in the task plan.
const REP_STACK_DECAY := 0.6

# --- Satış masası (SalesRepSystem) ---
# THE §10 BOUNDARY. An archetype whose MRR band CEILING is at or under this may close
# autonomously; anything above it enters the played pitch. Gating on the band ceiling rather
# than the computed deal value makes the line TIER-based and un-gameable — a rep can never
# sneak a "mid" account under it by pricing low. Bands are non-overlapping (small tops out at
# 500, mid starts at 800), so 600 sits in the gap. The headroom is deliberately asymmetric:
# if a balance pass raises small.high some small deals stop auto-closing, which is MORE
# player decisions and harmless; if it lowered mid.low, mid deals would start auto-closing,
# which is an actual §10 violation. sales_threshold_separates_tiers guards the gap.
const AUTONOMOUS_CLOSE_MRR_MAX := 600
# Leads/day per HIZ point of the ranked sales team. ANCHOR: the founder's own "Aday bul"
# button is 2 leads / 5 days = 0.40/day (sales_tab.gd:13-14). A mid rep (HIZ 6) sits at 0.36
# — roughly one founder's-button-worth, so a hire doubles the pipeline without replacing the
# player's action. That comparison, not the raw number, is what the curve session should argue.
const LEAD_PER_PACE_POINT := 0.06
const LEAD_DAILY_MAX := 2               # en fazla bu kadar otonom aday tek günde düşer
const PIPELINE_SOFT_CAP := 8            # bu kadar açık aday varken satışçı yenisini aramaz
# Warm/close progress per day per UZMANLIK point of the ranked team, DIVIDED by the lead's
# difficulty_stars (1/2/4). That divisor is the only job difficulty_stars has outside the
# pitch close roll, and it is what makes a big account take weeks while a small one takes days.
const WARM_PER_EXPERTISE_POINT := 0.05
const AUTO_CLOSE_PROGRESS := 1.0        # bu ilerlemede rutin aday kendi kendine imzalar
const WARM_BONUS_MAX := 2               # ısıtılmış büyük adayın kurucuya taşıdığı bonus tavanı
# Where in the archetype's band a rep-closed deal lands. A better closer places higher, but a
# small deal can never leave the small band, so it can never cross AUTONOMOUS_CLOSE_MRR_MAX.
const AUTO_CLOSE_MRR_FRAC := 0.5
const AUTO_CLOSE_MRR_PER_EXPERTISE := 0.04

# --- Müşteri masası (CustomerRepSystem) ---
# Capacity is a VOLUME question, so it reads HIZ — matching the shipped role contract
# hr_constants.gd:118 ("Talep işleme temposu"). Replaces CS_SKILL_PER_SLOT, which divided by
# 25 on what used to be a 0-100 cs_skill scale and therefore returned exactly
# CS_BASE_CAPACITY for every possible rep on the live 0-9 ruler — not merely uncalled, dead.
const CS_PACE_PER_SLOT := 3
# The founder onboards every new account personally; delegation begins once it settles.
const CS_ASSIGNABLE_PHASES := ["active", "risk", "expansion"]
# Request channel. Fires for the WHOLE customer book, founder-managed accounts included, from
# the rep's first day — this is what stops a fresh hire from idling until the founder is over
# FOUNDER_DIRECT_CAP. Stewardship (assigned_to) is the separate, capped job.
const CS_REQUEST_INTERVAL_DAYS := 22    # WORKING — bir hesap bu aralıkla talep açar (eski 12)
# Faz, hesap imzalanırken bu adımla yürüyen bir sayaçtan atanır (bkz. Customer.cs_request_phase).
# 9 ile 22 aralarında asal → sayaç tüm yuvaları dolaşır, ardışık düşmez: 0, 9, 18, 5, 14, 1, 10…
# Eski `id.hash() % INTERVAL` yaklaşımı müşteri id'leri son karakteri dışında aynı olduğu için
# ARDIŞIK faz üretiyordu. Aynı düşük-uyumsuzluk hilesi HR'da izin ayı için zaten kullanılıyor.
const CS_PHASE_STRIDE := 9
# Şirket geneli tavan: bir hesap ne kadar sık talep açarsa açsın, oyuncu 7 günde en fazla bu
# kadar CS kararıyla kesilir. WORKING. Retention/churn modalleri bu tavana DAHİL DEĞİL — onlar
# ölen bir hesabın sonucu, rutin trafik değil (Erdem kararı 2026-08-03).
const CS_ESCALATION_WEEKLY_CAP := 2
const CS_ESCALATION_WINDOW_DAYS := 7
const CS_THROUGHPUT_BASE := 0.5         # HIZ-0 bir temsilcinin bile günlük talep kapasitesi
const CS_THROUGHPUT_PER_PACE := 0.15    # HIZ puanı başına günlük ek talep kapasitesi
# Absorb-vs-escalate is the UZMANLIK valve: ceiling = CS_ABSORB_BASE + UZMANLIK, compared
# against a request's difficulty (see CustomerRepSystem._request_difficulty). At UZMANLIK 5
# the ceiling is 7, which absorbs an unhappy scale-3 account asking for an unshipped feature;
# at UZMANLIK 4 that same request reaches the player. Two-directional by construction.
const CS_ABSORB_BASE := 3               # WORKING (eski 2) — rutin talepler daha çok yutulur
const CS_ESCALATE_AFTER_DAYS := 3       # bu kadar gün karşılanmayan talep oyuncuya çıkar
const CS_REQUEST_IGNORE_SAT := -6       # "Şimdilik olmaz" — talep düşer, memnuniyet düşer

# --- Talep türleri (2b fixes) ---
# Tek şablon dönüyordu ve her talebin varsayılanı "söz ver"di. Üç tür artık kendi gövde
# metnini ve kendi seçenek setini kurar; söz vermek YALNIZ `feature`'ın varsayılanı.
# Aynı hesaptan arka arkaya aynı tür gelmez (Customer.last_request_kind).
const CS_KIND_FEATURE := "feature"      # özellik isteği
const CS_KIND_COMPLAINT := "complaint"  # şikâyet
const CS_KIND_RENEWAL := "renewal"      # yenileme sinyali
const CS_REQUEST_KINDS := [CS_KIND_FEATURE, CS_KIND_COMPLAINT, CS_KIND_RENEWAL]
# WORKING — tür başına efekt büyüklükleri (curve oturumunda ayarlanacak)
const CS_PRIORITIZE_SAT := 4            # "Önceliklendir" — küçük memnuniyet kazancı
const CS_DISCOUNT_PCT := 15             # "İndirim ver" — MRR yüzde kaç düşer
const CS_DISCOUNT_SAT := 8              # indirimin memnuniyet karşılığı
const CS_EXPLAIN_SAT := -3              # "Açıkla ve reddet" — dürüst ret, ucuz ama bedava değil
const CS_RENEWAL_TALK_SAT := 6          # "Yenilemeyi görüş"
const CS_RENEWAL_STALL_SAT := -5        # "Beklet" — sinyali görmezden gelmenin bedeli

# --- Söz dayanıklılığı (the _promise_offset fix) ---
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
#     HRConstants.NOTICE_SOURCE_HR, kept here because the emitters are sales-domain). ---
# Localized at EMIT time. The ticker stream is transient, so an item written before a
# language switch keeps its old attribution until it scrolls off — the same accepted
# staleness class as an already-open modal. B5 owns the ticker and may move this to a
# key rendered at display time when it does.
static func notice_source_sales() -> String:
	return TranslationServer.translate("NOTICE_SRC_SALES")


static func notice_source_customer() -> String:
	return TranslationServer.translate("NOTICE_SRC_CUSTOMER")
