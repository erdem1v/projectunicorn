class_name PitchConstants
extends RefCounted

# Single calibration surface for VC pitch GLOBAL knobs (Spec 4 / VC_PITCH_DESIGN.md §9).
# Per-VC knobs (term bands, patience, conviction weights) live in InvestorRegistry — the
# other single location. EVERY number here is a working placeholder; the calibration pass
# (last, one session) touches this file + the InvestorRegistry table and nothing else. The
# doc fixes STRUCTURE only.

# --- Conviction track zones (§3) — Soğuk 0-39 / Ilık 40-69 / Kazanıldı 70-100 ---
const ZONE_BOUNDS := [40, 70]          # [ilik_min, kazanildi_min]; passed to MeetingScene conviction
const ILIK_MIN := 40
const WON_MIN := 70

# --- Seeding (§3 macro moment) — base + run-state weights ---
const SEED_BASE := 20
const SEED_MRR_REFERENCE := 5000       # traction threshold reference (≈ SalesSystem target)
const SEED_MRR_MAX_BONUS := 20         # full bonus when MRR ≫ reference (scaled)
const SEED_BRAND_FLOOR := 50           # brand at floor = 0 contribution
const SEED_BRAND_MAX := 12             # ± cap from brand distance to floor
const SEED_SHUTTER_PENALTY := -15      # Kepenk active (ledger 12 — thin runway priced in)
const SEED_THIN_RUNWAY_PENALTY := -8   # runway below comfort but not shuttered
const SEED_SCANDAL_PENALTY := -12      # unmanaged major scandal
const SEED_LEVERAGE_BONUS := 15        # a live sheet already in pocket (§6)
const SEED_WARM_INTRO_BONUS := 12      # Bosphorus via Frank
const SEED_DIMENSION_MATCH_BONUS := 8  # Meridian ↔ subgenre/product dimension
const SEED_CALLBACK_BONUS := 10        # re-entry after a met callback (§5)

# --- Difficulty band → SkillCheck.resolve diff int (visible Disco labels) ---
const DIFF_KOLAY := 1
const DIFF_ORTA := 2
const DIFF_ZORLU := 3
const DIFF_CETIN := 3                   # "Çetin" reads harder than Zorlu by copy; same diff for now

# --- Beat 2 Anlatı deltas ---
const BEAT2_SUCCESS_MIN := 15          # near_pass margin
const BEAT2_SUCCESS_MAX := 25          # crit_success margin
const BEAT2_FAIL := -5

# --- Beat 3 Sorgu postures ---
const DURUST_SUCCESS := 20
const DURUST_FAIL := -8
const DURUST_DIFF := DIFF_ORTA
const SPIN_SUCCESS := 28
const SPIN_FAIL := -15
const SPIN_DIFF := DIFF_ZORLU
const GECISTIR_SUCCESS := 5
const GECISTIR_FAIL := -5
const GECISTIR_DIFF := DIFF_KOLAY
const GECISTIR_CAP := 65               # deflection can never win the room (§4 Beat 3)

# --- Beat 1 perception + Beat 4 push ---
const BEAT1_DIFF := DIFF_ORTA
const MASAYI_ZORLA_DIFF := DIFF_ZORLU  # Ilık fork gamble; failure = RET (hard, Erdem call C)

# --- Prep (§1) ---
const MEETING_LEAD_DAYS := 3           # request → meeting day
const PREP_DAYS := 2
const PREP_MIN_DAYS_BEFORE := 2        # prep startable only if ≥ this many full days remain
const PREP_BONUS := 2                  # SkillCheck bonus units on the focused check (+~20% odds)

# --- Sheet economy (§5) ---
const SHEET_VALIDITY_DAYS := 14
const MAX_SHEETS := 2
const WARNING_DAYS := 3                 # expiry warning event + TopBar chip threshold (ledger 14)

# --- Cascade / callbacks ---
const CASCADE_TABLES := 3               # UI "Kapanan masa: N/3"; EndingsSystem owns the real gate
const CALLBACK_MRR_GROWTH_PCT := 20     # "MRR +20% over meeting-day value"
const CALLBACK_BUGS_UNDER := 3          # "active bugs under N"

# --- Run wall ---
const DAY180_WARN_DAY := 179            # Frank "yarın son gün, cebinde teklif var" (ledger 16)


## Difficulty label (Turkish, shown in odds text) for a diff int.
static func diff_label(diff: int) -> String:
	match diff:
		DIFF_KOLAY: return "Kolay"
		DIFF_ORTA: return "Orta"
		_: return "Zorlu"
