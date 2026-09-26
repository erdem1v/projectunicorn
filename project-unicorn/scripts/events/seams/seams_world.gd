class_name EvSeamsWorld
extends RefCounted

# The `phase.`, `rival.`, `investor.` and `time.` namespaces.

static func install() -> void:
	_install_phase()
	_install_time()
	_install_rival()
	_install_investor()


static func _install_phase() -> void:
	var G := EvSeams.Kind.GLOBAL

	EvSeams.register("phase.current", G, TYPE_INT,
		func() -> int: return GameState.phase,
		"Phase", "WRAPPER; 1 Bootstrap, 2 Traction, 3 Series A Hunt")
	EvSeams.register("phase.name", G, TYPE_STRING,
		func() -> String: return GameState.phase_display_name(GameState.phase),
		"Phase", "for prose")
	EvSeams.register("phase.gate_ready", G, TYPE_BOOL,
		func() -> bool: return GameState.phase_gate_ready,
		"Phase", "WRAPPER; a transition is open and unanswered")
	EvSeams.register("phase.gate_declines", G, TYPE_INT,
		func() -> int: return int(GameState.get_flag("gate_declines", 0)),
		"Phase", "WRAPPER; how many times the player has said not yet")

	# The Series A door as a WORD, never the threshold (ch.08 §5): content gets the state and
	# cannot accidentally print the number.
	EvSeams.register("phase.series_a_signal", G, TYPE_STRING,
		func() -> String: return String(PhaseGateSystem.series_a_signal().get("state", "closed")),
		"Phase", "closed | warming | open. The number behind it is deliberately not a seam")
	# Frank's approach lines as a STEP, not a figure (PhaseGateSystem.APPROACH_PCTS).
	EvSeams.register("phase.series_a_approach", G, TYPE_INT,
		func() -> int: return PhaseGateSystem.series_a_approach(),
		"Phase", "0-4: approach marks cleared toward the Series A revenue bar (50/75/90/100 %). A step, never the number")
	# The soft-cap telegraph reads it: a company past its milestone has no day-730 clock.
	EvSeams.register("phase.bootstrap_milestone", G, TYPE_BOOL,
		func() -> bool: return EndingsSystem.bootstrap_milestone_taken(),
		"Phase", "WRAPPER; the bootstrap milestone was taken (EA / full), so the soft cap no longer applies")


static func _install_time() -> void:
	var G := EvSeams.Kind.GLOBAL

	EvSeams.register("time.day", G, TYPE_INT,
		func() -> int: return GameState.day,
		"Time", "WRAPPER; absolute game day, starts at 1. GameState owns it, not TimeManager")
	EvSeams.register("time.hour", G, TYPE_INT,
		func() -> int: return GameState.current_hour, "Time", "WRAPPER; 0-23")
	EvSeams.register("time.weekday", G, TYPE_INT,
		func() -> int: return int(GameState.get_date_dict().get("weekday", 0)),
		"Time", "0-6 from the real calendar; day 1 is a Thursday, 1 Jan 2026")
	EvSeams.register("time.month", G, TYPE_INT,
		func() -> int: return int(GameState.get_date_dict().get("month", 1)),
		"Time", "1-12; real month lengths, not 30-day blocks")
	EvSeams.register("time.speed", G, TYPE_INT,
		func() -> int: return TimeManager.current_speed,
		"Time", "WRAPPER; 0 paused, 1-3")
	EvSeams.register("time.is_paused", G, TYPE_BOOL,
		func() -> bool: return TimeManager.current_speed == 0,
		"Time", "WRAPPER; there is no named predicate for this")
	EvSeams.register("time.run_active", G, TYPE_BOOL,
		func() -> bool: return GameState.run_active,
		"Time", "WRAPPER; false once a terminal has fired")


static func _install_rival() -> void:
	var G := EvSeams.Kind.GLOBAL

	EvSeams.register("rival.count", G, TYPE_INT,
		func() -> int: return RivalRegistry.get_all().size(), "Rivals", "")
	EvSeams.register("rival.player_share_pct", G, TYPE_FLOAT,
		func() -> float: return RivalRegistry.get_player_share_pct(),
		"Rivals", "0.0-90.0, derived from MRR against a fixed market total")

	var E := EvSeams.Kind.ENTITY
	EvSeams.register("rival.status", E, TYPE_STRING,
		func(id: String) -> String:
			var r: Rival = RivalRegistry.get_rival(id)
			return r.status if r != null else "",
		"Rivals", "WRAPPER; DOMINANT | STEADY | SCALING | QUIET")
	EvSeams.register("rival.momentum", E, TYPE_FLOAT,
		func(id: String) -> float:
			var r: Rival = RivalRegistry.get_rival(id)
			return r.momentum if r != null else 0.0,
		"Rivals", "WRAPPER; zero for the giants, who do not accelerate")


static func _install_investor() -> void:
	var G := EvSeams.Kind.GLOBAL
	var E := EvSeams.Kind.ENTITY

	# I7's landing sites for SkillCheck.breakdown(). `founder.skill` is the fallback when the
	# check names a skill with no seam of its own: I7 needs the line explicable, not precise.
	EvSeams.register("founder.skill", G, TYPE_INT,
		func() -> int: return GameState.get_founder_skill("leadership"),
		"Founder", "the skill a check leaned on; the specific seam wins when one exists")
	EvSeams.register("investor.leverage", G, TYPE_INT,
		func() -> int: return int(GameState.get_flag("vc_leverage", 0)),
		"Investment", "the table-side bonus a check adds; 0 outside a sitting")
	EvSeams.register("investor.rejections", G, TYPE_INT,
		func() -> int: return GameState.vc_rejections,
		"Funding", "WRAPPER; three closed tables reach the cascade")
	EvSeams.register("investor.sheets_live", G, TYPE_INT,
		func() -> int: return GameState.active_sheets.size(),
		"Funding", "WRAPPER; term sheets in hand")
	# Prose, resolved at display time so a language switch re-renders it; "" with no sheet.
	EvSeams.register("investor.est_valuation", E, TYPE_STRING,
		func(id: String) -> String: return VCPitchSystem.estimate_valuation_text(id),
		"Funding", "~$lo-hi M around the sheet's opening valuation; never the number")
	EvSeams.register("investor.est_dilution", E, TYPE_STRING,
		func(id: String) -> String: return VCPitchSystem.estimate_dilution_text(id),
		"Funding", "~lo-hi % around the sheet's opening dilution; never the number")
	EvSeams.register("investor.meeting_pending", G, TYPE_BOOL,
		func() -> bool: return not GameState.pending_meeting.is_empty(),
		"Funding", "WRAPPER; one at a time by construction")
	EvSeams.register("investor.series_a_closed", G, TYPE_BOOL,
		func() -> bool: return GameState.series_a_closed, "Funding", "WRAPPER")
	EvSeams.register("investor.angel_taken", G, TYPE_BOOL,
		func() -> bool: return int(GameState.get_flag(AngelRoundSystem.FLAG_ACCEPTED_DAY, 0)) > 0,
		"Funding", "WRAPPER; Frank's cheque was accepted")
	EvSeams.register("investor.pivot_used", G, TYPE_BOOL,
		func() -> bool: return GameState.pivot_used,
		"Funding", "WRAPPER; the VC path is permanently closed")
