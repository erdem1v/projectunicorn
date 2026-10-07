class_name EvTicker
extends RefCounted

# THE TICKER CONTRACT (GDD §18). The ticker is never the ONLY channel for anything: a
# meaningful outcome that scrolls past is also in History, and an arc's also carries a card.
#
# The channel underneath is lossy — NewsFeedSystem drops the NEWEST line when its buffer fills —
# so a push is best-effort. Hence the hard rule: the tempo governor never demotes a card into
# the ticker (§13.2's ladder is interrupt → paper → stop).

const PRIORITY_PLAYER := "player"    ## an outcome of something the player did — never dropped
const PRIORITY_WORLD := "world"      ## a rival move, sector news; anything else is ambient noise

## Player-outcome lines, kept because the feed may drop them (§18.3).
static var _held: Array = []


## Push one line: a localization key or a card's own prose, with the card's slots filled from
## `context` ("{customer} stopped asking"). A key goes out as data and reads in the reader's
## language; prose is already text.
static func push(line: String, priority: String, context: Dictionary = {}) -> void:
	if line == "":
		return
	var text: String = EvPresenter.resolve_text(line, context)
	EventBus.headline_added.emit(_source_for(priority), _line_of(line, text, context))
	if priority == PRIORITY_PLAYER:
		_held.append({"day": GameState.day, "key": line, "text": text})


## The line as the signal carries it: a key and the name of every slot (its id once the entity
## is gone), or the prose as {txt}. A composed name stays a {key, args} line, so it reads in the
## reader's language.
static func _line_of(line: String, text: String, context: Dictionary) -> Dictionary:
	if not EvPresenter.is_key(line):
		return {"txt": text}
	var names: Dictionary = EvPresenter.freeze_names(context)
	var args: Dictionary = {}
	for slot in context:
		var kept: Variant = names.get(slot, String(context[slot].get("id", "")))
		args[slot] = {"key": kept["key"], "args": {"product": kept["arg"]}} if kept is Dictionary else kept
	return {"key": line, "args": args}


static func _source_for(priority: String) -> String:
	match priority:
		PRIORITY_PLAYER: return "TICKER_SRC_INTERNAL"
		PRIORITY_WORLD: return NewsFeedSystem.outlet_key(0)
	return NewsFeedSystem.outlet_key(1)


static func reset() -> void:
	_held.clear()


static func to_dict() -> Dictionary:
	return {"held": _held.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	_held = (d.get("held", []) as Array).duplicate(true)
