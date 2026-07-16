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

# --- Beat skill routing (SKILL-RENAME 2026-07-16) ---
# Erdem: VC persuasion beats read Nüfuz (investor relations); the traction angle reads
# Satış. One const per beat so a per-site remap is a one-token change.
const BEAT1_SKILL := "influence"        # Odayı oku
const BEAT3_SKILL := "influence"        # Sorgu postures (dürüst / spin / geçiştir)
const BEAT4_PUSH_SKILL := "influence"   # Masayı zorla
const ANGLE_SKILL := {"vizyon": "influence"}   # Beat 2 anlatı; fallback: "sales" (traction)

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

# --- Term Sheet Table (Spec 6 / ENDGAME_DESIGN.md §5) — the push-your-luck negotiation ---
# Every number is a working placeholder (calibration pass tunes it). Each lever's push reads
# ONE founder skill (the payoff of the onboarding skill choice) — kept as an editable data
# table so the mapping never hides inside table logic:
const LEVER_SKILL := {"valuation": "sales", "dilution": "negotiation", "board": "influence"}
# Per-lever base difficulty (SkillCheck diff units). Kept 0-2 so "temel" reads legibly —
# diff 3 would zero the base (BASE_CHANCE − 3·DIFFICULTY_STEP = 0). Board is hardest (control),
# valuation easiest (a market argument).
const LEVER_DIFF := {"valuation": 0, "dilution": 1, "board": 2}
# Push step sizes — one successful push moves the lever this far the founder's way.
const VAL_STEP := 4                     # valuation +$4M per push (higher = founder-good)
const DIL_STEP := 4                     # dilution −4pp per push (lower = founder-good)
const DIL_FLOOR := 10                   # dilution can't be pushed below this (%)
# Board has no numeric step — a fixed sequence: drop veto first, then drop the seat (§8).
# Odds self-damping: each push to a lever lowers its own subsequent odds (decision 9).
const PUSH_DECAY := 0.12                # −12pp per prior push to that lever
const PUSH_ODDS_FLOOR := 0.05           # a lever never becomes literally impossible (ledger 6)
# Leverage — a second live sheet (§8): bonus to ALL push odds + a one-notch-better opening.
const LEVERAGE_BONUS_UNITS := 1         # SkillCheck bonus units (each = +BONUS_STEP = +10pp)
const LEVERAGE_OPEN_NOTCH := 4          # opening valuation starts +$4M better when leverage is live
# Dial spin duration (seconds) — the push roll presentation.
const DIAL_SPIN_SECS := 0.8

## Difficulty label (Turkish, shown in odds text) for a diff int.
static func diff_label(diff: int) -> String:
	match diff:
		DIFF_KOLAY: return "Kolay"
		DIFF_ORTA: return "Orta"
		_: return "Zorlu"


## Founder-skill display label for the odds split (§5). Single label home is
## FounderConstants (CSV-backed since SKILL-RENAME); kept here as a delegate so
## existing callers (term sheet table, meeting) stay unchanged.
static func skill_label(skill_name: String) -> String:
	return FounderConstants.skill_label(skill_name)
