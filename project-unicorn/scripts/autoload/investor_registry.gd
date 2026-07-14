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
		"role_line": "Kıdemli Ortak",
		"archetype_line": "Agresif ama cömert. Kontrolü sever.",
		"domain": "metrics",
		"domain_chip": "METRİK",
		"weights": {"metrik": PitchConstants.DIFF_KOLAY, "vizyon": PitchConstants.DIFF_CETIN, "traction": PitchConstants.DIFF_ORTA},
		"interrogation_intensity": "mid",
		"patience_pool": 3,
		"term_bands": {"valuation": "yüksek", "dilution": "yüksek", "board": "koltuk + veto ister"},
		"warm_intro": false,
		"portrait_path": "res://assets/art/investors/portrait_anchor.webp",
		"room_path": "res://assets/art/rooms/room_anchor.webp",
	},
	{
		"id": "nexus",
		"display_name": "Nexus Ventures",
		"role_line": "Yönetici Ortak",
		"archetype_line": "Temkinli. Kurucuyu sever, riski sevmez.",
		"domain": "team",
		"domain_chip": "EKİP",
		"weights": {"metrik": PitchConstants.DIFF_ORTA, "vizyon": PitchConstants.DIFF_ORTA, "traction": PitchConstants.DIFF_KOLAY},
		"interrogation_intensity": "mid",
		"patience_pool": 4,
		"term_bands": {"valuation": "düşük", "dilution": "düşük", "board": "temiz"},
		"warm_intro": false,
		"portrait_path": "res://assets/art/investors/portrait_nexus.webp",
		"room_path": "res://assets/art/rooms/room_nexus.webp",
	},
	{
		"id": "bosphorus",
		"display_name": "Bosphorus Partners",
		"role_line": "Kurucu Ortak",
		"archetype_line": "İlişki adamı. Kapıyı Frank açar.",
		"domain": "narrative",
		"domain_chip": "ANLATI",
		"weights": {"metrik": PitchConstants.DIFF_CETIN, "vizyon": PitchConstants.DIFF_KOLAY, "traction": PitchConstants.DIFF_ORTA},
		"interrogation_intensity": "soft",
		"patience_pool": 2,
		"term_bands": {"valuation": "orta", "dilution": "orta", "board": "koltuk (esnek)"},
		"warm_intro": true,
		"portrait_path": "res://assets/art/investors/portrait_bosphorus.webp",
		"room_path": "res://assets/art/rooms/room_bosphorus.webp",
	},
	{
		"id": "meridian",
		"display_name": "Meridian Growth",
		"role_line": "Büyüme Ortağı",
		"archetype_line": "Sektörü senden iyi bilir. Sabrı yoktur.",
		"domain": "product",
		"domain_chip": "ÜRÜN",
		"weights": {"metrik": PitchConstants.DIFF_KOLAY, "vizyon": PitchConstants.DIFF_CETIN, "traction": PitchConstants.DIFF_ORTA},
		"interrogation_intensity": "hard",
		"patience_pool": 2,
		"term_bands": {"valuation": "cömert", "dilution": "orta", "board": "gözlemci"},
		"warm_intro": false,
		"portrait_path": "res://assets/art/investors/portrait_meridian.webp",
		"room_path": "res://assets/art/rooms/room_meridian.webp",
	},
	# Locked Tier-2 teaser (wishlist telegraph, §2) — no meeting, greyed card.
	{
		"id": "locked_tier2",
		"display_name": "— · Tier 2'de",
		"role_line": "",
		"archetype_line": "",
		"domain": "",
		"domain_chip": "",
		"weights": {},
		"interrogation_intensity": "",
		"patience_pool": 0,
		"term_bands": {},
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
