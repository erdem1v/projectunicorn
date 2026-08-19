extends Node

# Investor roster — the static truth for Series A Hunt (Spec 4 / VC_PITCH_DESIGN.md §2).
# Autoload (CustomerRegistry shell) but the DATA is a const table (PhaseGate GATES style):
# one registry feeds BOTH systems — archetype weights the meeting's check difficulties AND
# writes the table's opening offer + patience pool (Spec 6). Consistency is free.
#
# Per-run VC RUNTIME state (open/closed/callback/pending_sheet) lives on GameState.vc_states,
# NEVER here (§7 / PhaseGate rule: static truth in the system, persistent state on GameState).
#
# Naming caution: get_investor (not get) — Object.get(prop) is reserved.
#
# Conviction weights map each Beat-2 angle → SkillCheck difficulty (PitchConstants.DIFF_*).
# The easiest angle is the VC's "favored" one, revealed as a marker on a successful Beat 1.
# All numbers are working placeholders (calibration pass edits this table + PitchConstants).

const INVESTORS := [
	{
		"id": "anchor",
		"display_name": "Anchor Capital",
		"role_key": "INV_ROLE_SENIOR_PARTNER",
		"archetype_key": "INV_ARCH_ANCHOR",
		"domain": "metrics",
		"domain_chip_key": "INV_CHIP_METRICS",
		"weights": {"metrik": PitchConstants.DIFF_KOLAY, "vizyon": PitchConstants.DIFF_CETIN, "traction": PitchConstants.DIFF_ORTA},
		"interrogation_intensity": "mid",
		"patience_pool": 3,
		"term_bands": {"valuation": "high", "dilution": "high", "board": "seat_veto"},
		"opening_terms": {"valuation_m": 18, "dilution_pct": 22, "board_seats": 1, "board_veto": true},
		"warm_intro": false,
		"portrait_path": "res://assets/art/investors/portrait_anchor.webp",
		"room_path": "res://assets/art/rooms/room_anchor.webp",
	},
	{
		"id": "nexus",
		"display_name": "Nexus Ventures",
		"role_key": "INV_ROLE_MANAGING_PARTNER",
		"archetype_key": "INV_ARCH_NEXUS",
		"domain": "team",
		"domain_chip_key": "INV_CHIP_TEAM",
		"weights": {"metrik": PitchConstants.DIFF_ORTA, "vizyon": PitchConstants.DIFF_ORTA, "traction": PitchConstants.DIFF_KOLAY},
		"interrogation_intensity": "mid",
		"patience_pool": 4,
		"term_bands": {"valuation": "low", "dilution": "low", "board": "clean"},
		"opening_terms": {"valuation_m": 10, "dilution_pct": 15, "board_seats": 0, "board_veto": false},
		"warm_intro": false,
		"portrait_path": "res://assets/art/investors/portrait_nexus.webp",
		"room_path": "res://assets/art/rooms/room_nexus.webp",
	},
	{
		"id": "bosphorus",
		"display_name": "Bosphorus Partners",
		"role_key": "INV_ROLE_FOUNDING_PARTNER",
		"archetype_key": "INV_ARCH_BOSPHORUS",
		"domain": "narrative",
		"domain_chip_key": "INV_CHIP_NARRATIVE",
		"weights": {"metrik": PitchConstants.DIFF_CETIN, "vizyon": PitchConstants.DIFF_KOLAY, "traction": PitchConstants.DIFF_ORTA},
		"interrogation_intensity": "soft",
		"patience_pool": 2,
		"term_bands": {"valuation": "mid", "dilution": "mid", "board": "seat_flex"},
		"opening_terms": {"valuation_m": 14, "dilution_pct": 18, "board_seats": 1, "board_veto": false},
		"warm_intro": true,
		"portrait_path": "res://assets/art/investors/portrait_bosphorus.webp",
		"room_path": "res://assets/art/rooms/room_bosphorus.webp",
	},
	{
		"id": "meridian",
		"display_name": "Meridian Growth",
		"role_key": "INV_ROLE_GROWTH_PARTNER",
		"archetype_key": "INV_ARCH_MERIDIAN",
		"domain": "product",
		"domain_chip_key": "INV_CHIP_PRODUCT",
		"weights": {"metrik": PitchConstants.DIFF_KOLAY, "vizyon": PitchConstants.DIFF_CETIN, "traction": PitchConstants.DIFF_ORTA},
		"interrogation_intensity": "hard",
		"patience_pool": 2,
		"term_bands": {"valuation": "generous", "dilution": "mid", "board": "observer"},
		"opening_terms": {"valuation_m": 16, "dilution_pct": 18, "board_seats": 0, "board_veto": false},
		"warm_intro": false,
		"portrait_path": "res://assets/art/investors/portrait_meridian.webp",
		"room_path": "res://assets/art/rooms/room_meridian.webp",
	},
	# Locked Tier-2 teaser (wishlist telegraph, §2) — no meeting, greyed card.
	{
		"id": "locked_tier2",
		"display_name": "— · Tier 2'de",
		"role_key": "",
		"archetype_key": "",
		"domain": "",
		"domain_chip_key": "",
		"weights": {},
		"interrogation_intensity": "",
		"patience_pool": 0,
		"term_bands": {},
		"opening_terms": {},
		"warm_intro": false,
		"portrait_path": "",
		"room_path": "",
		"locked": true,
	},
]


# --- Read API ---

func get_investor(vc_id: String) -> Dictionary:
	for inv in INVESTORS:
		if inv.get("id", "") == vc_id:
			return inv
	return {}


func get_all() -> Array:
	return INVESTORS


# Pitchable roster (excludes the locked teaser) — the schedulable VCs.
func get_active() -> Array:
	var out: Array = []
	for inv in INVESTORS:
		if not inv.get("locked", false):
			out.append(inv)
	return out


func is_locked(vc_id: String) -> bool:
	return get_investor(vc_id).get("locked", false)


# The VC's favored Beat-2 angle (lowest difficulty) — revealed by a Beat-1 success.
func favored_angle(vc_id: String) -> String:
	var w: Dictionary = get_investor(vc_id).get("weights", {})
	var best := ""
	var best_diff := 99
	for angle in w:
		if int(w[angle]) < best_diff:
			best_diff = int(w[angle])
			best = angle
	return best


# ============================================================================
# COPY ACCESSORS — the words left this table for strings.csv (Faz 2 · B7).
# ============================================================================
# role_line / archetype_line / domain_chip held finished Turkish, and term_bands held
# Turkish words that rode along on TermSheet (an @export) into whatever read it. The table
# keeps ids; the words are resolved at render time.

## "Kıdemli Ortak" / "Senior Partner". "" for the locked Tier-2 slot.
func role_line(investor_id: String) -> String:
	return _copy(investor_id, "role_key")


## The one-line read on how this VC behaves in the room.
func archetype_line(investor_id: String) -> String:
	return _copy(investor_id, "archetype_key")


## The domain badge shown on the hunt card ("METRİK" / "METRICS").
func domain_chip(investor_id: String) -> String:
	return _copy(investor_id, "domain_chip_key")


func _copy(investor_id: String, field: String) -> String:
	var key: String = String(get_investor(investor_id).get(field, ""))
	return "" if key == "" else TranslationServer.translate(key)


## Term-band id → word ("yüksek" / "high"). The bands are stored as ids on TermSheet, so a
## sheet written in one language reads correctly in the other.
func term_band_label(band_id: String) -> String:
	if band_id == "":
		return ""
	return TranslationServer.translate("TERM_BAND_" + band_id.to_upper())
