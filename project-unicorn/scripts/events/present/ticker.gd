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


## Push one line. `line_key` is a localization key, never prose (§3.2).
static func push(line_key: String, priority: String, _context: Dictionary = {}) -> void:
	if line_key == "":
		return
	var text: String = TranslationServer.translate(line_key)
	EventBus.headline_added.emit(_source_for(priority), text)
	if priority == PRIORITY_PLAYER:
		_held.append({"day": GameState.day, "key": line_key, "text": text})


static func _source_for(priority: String) -> String:
	match priority:
		PRIORITY_PLAYER: return TranslationServer.translate("TICKER_SRC_INTERNAL")
		PRIORITY_WORLD: return NewsFeedSystem.outlet_name(0)
	return NewsFeedSystem.outlet_name(1)


static func reset() -> void:
	_held.clear()


static func to_dict() -> Dictionary:
	return {"held": _held.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	_held = (d.get("held", []) as Array).duplicate(true)
