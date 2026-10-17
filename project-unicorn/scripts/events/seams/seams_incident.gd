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
		func() -> int: return SprintSystem.payers("").size(),
		"Incident", "people a night fix costs morale (SprintSystem.payers); 0 locks the option")
	EvSeams.register("olay.service_up", G, TYPE_BOOL,
		func() -> bool: return IncidentSystem.service_up(),
		"Incident", "no emergency is open, or the fix it was answered with is done")
