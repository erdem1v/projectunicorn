class_name EvWatch
extends RefCounted

# EFFECTS HELD BACK UNTIL A SPRINT CARD'S TEST IS DONE. An `after_test` effect leaves one entry here:
#
#     {card_id, effects, context, event_id, names}
#
# `card_id` is the sprint card, `event_id` the card that asked, `context` its frozen scope and `names` what a history row reads
# of it. Pure data like EvSchedule's entries, so a save carries it. The sprint tells when a card's phase moved
# (EventBus.card_phase_changed); the test is done once the card carries `tested`, and the bugs it found are `found`.

## Entries, oldest first.
static var _entries: Array = []


## Watch `card_id`'s test for `event_id`. The names are frozen now: the entities in `context` may be gone when the test ends.
static func add(card_id: String, effects: Array, context: Dictionary, event_id: String) -> void:
	_entries.append({"card_id": card_id, "effects": effects.duplicate(true),
		"context": context.duplicate(true), "event_id": event_id,
		"names": EvPresenter.freeze_names(context).merged(EvPresenter.freeze_seams(EvCatalog.card(event_id), context))})


## A card moved to another phase. A card whose test is done ends its watches: when the test found a bug the effects land and
## the history gets a row beside the choice's (`<outcome>_tested`). The choice is the one that set the watch up: the card may
## have been answered again since, about another sprint card.
static func on_phase(card_id: String, _phase: int) -> void:
	var card: Dictionary = SprintCatalog.card_by_id(card_id)
	if not bool(card.get("tested", false)):
		return
	for entry in _entries.filter(func(en: Dictionary) -> bool: return en.card_id == card_id):
		_entries.erase(entry)
		if int(card.get("found", 0)) >= 1:
			var landed: Array = EvEffects.run_check_branch(entry.effects, entry.context, entry.event_id)
			var chosen: Dictionary = EvHistory.rows().filter(func(row: Dictionary) -> bool:
				return row.event_id == entry.event_id and row.resolution == EvHistory.RESOLUTION_CHOSEN and (row.deltas as Array).any(
					func(d: Dictionary) -> bool: return d.get("verb", "") == "after_test" and d.get("card", "") == card_id)).back()
			EvHistory.record(entry.event_id, EvHistory.RESOLUTION_CHOSEN, chosen.option_id, chosen.outcome_id + "_tested",
				entry.context, landed, "", false, entry.names, false, MailClock.now())


static func size() -> int:
	return _entries.size()


static func reset() -> void:
	_entries.clear()


static func to_dict() -> Dictionary:
	return {"watch": _entries.duplicate(true)}


## An entry whose card the catalogue no longer knows is dropped, as EvSchedule drops a scheduled one.
static func from_dict(d: Dictionary) -> void:
	_entries = (d.get("watch", []) as Array).filter(
		func(en: Dictionary) -> bool: return EvCatalog.has_card(String(en.get("event_id", ""))))
