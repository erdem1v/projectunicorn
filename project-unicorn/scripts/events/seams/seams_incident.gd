class_name EvSeamsIncident
extends RefCounted

# The `olay.` namespace: what an emergency card says about the night it came in, and what its options may lock on.
# All global: the night's record is IncidentSystem's (GameState.incident.open), the accounts are the live book.

static func install() -> void:
	var G := EvSeams.Kind.GLOBAL

	EvSeams.register("olay.clock", G, TYPE_STRING,
		func() -> String: return IncidentSystem.start_clock(),
		"Incident", "when the open emergency began, 02:10; a history row reads the latest emergency's")
	EvSeams.register("olay.night_accounts", G, TYPE_INT,
		func() -> int: return IncidentSystem.night_accounts().size(),
		"Incident", "active B2B accounts of a night-shift sector")
	EvSeams.register("olay.accounts", G, TYPE_INT,
		func() -> int: return IncidentSystem.accounts().size(),
		"Incident", "active B2B accounts")
	EvSeams.register("olay.affected_users", G, TYPE_INT,
		func() -> int: return IncidentSystem.tried(),
		"Incident", "B2C: people who tried the app between the outage's start and the card's opening")
	EvSeams.register("olay.payers", G, TYPE_INT,
		func() -> int: return SprintSystem.payers(IncidentSystem.hit_line()).size(),
		"Incident", "people a fix outside the sprint costs morale (SprintSystem.payers, on the line the emergency hit); 0 locks the option")
	EvSeams.register("olay.service_up", G, TYPE_BOOL,
		func() -> bool: return IncidentSystem.service_up(),
		"Incident", "no emergency is open, or the fix it was answered with is done")
	EvSeams.register("olay.version", G, TYPE_STRING,
		func() -> String: return IncidentSystem.version(),
		"Incident", "the version the open regression broke, v1.4")
	EvSeams.register("olay.outage_load", G, TYPE_INT,
		func() -> int: return IncidentSystem.outage_load(),
		"Incident", "the server load, in percent, the open outage was rolled at, for by_seam text; 0 for another kind")
	EvSeams.register("olay.affected_accounts", G, TYPE_INT,
		func() -> int: return SprintCatalog.line_accounts(IncidentSystem.hit_line()).size(),
		"Incident", "active B2B accounts that use the line the emergency hit")
	EvSeams.register("olay.line_users", G, TYPE_INT,
		func() -> int: return SprintCatalog.line_users(IncidentSystem.hit_line()),
		"Incident", "people the line the emergency hit reaches each day (B2C: the audience's share of it)")
	EvSeams.register("olay.shares", G, TYPE_INT,
		func() -> int: return roundi(SalesSystem.b2c_audience() * float(SprintCatalog.cfg("incident.storm.share"))),
		"Incident", "how many times the post going round has been shared: a share of the audience")
	EvSeams.register("olay.variant", G, TYPE_INT,
		func() -> int: return IncidentSystem.variant(),
		"Incident", "which line-specific body a card reads (IncidentSystem.variant), for by_seam text")
