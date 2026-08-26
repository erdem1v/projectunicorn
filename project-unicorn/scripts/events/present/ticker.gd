class_name EvTicker
extends RefCounted

# THE TICKER CONTRACT (GDD §18).
#
# §18.1 is the rule and it is a rule about TRUST, not about a widget: the ticker is never the
# ONLY channel for anything. A meaningful outcome that scrolls past is also in History, and if
# it belongs to a promise arc it also carries a card. Otherwise a player who was reading
# something else at that moment has permanently lost information the game told them once.
#
# THE CHANNEL UNDERNEATH IS LOSSY, AND THAT IS WHY THIS MATTERS. NewsFeedSystem's own header
# (news_feed_system.gd:164-173) says that when its 20% "biz" buffer fills, the NEWEST line is
# dropped — because autonomous closes and departures produce lines faster than the feed drains.
# So a push is best-effort by construction.
#
# The consequence for the engine is a hard rule, stated here because it is easy to violate by
# accident: **the tempo governor never demotes a card into the ticker.** §13.2's ladder is
# interrupt → paper → and stops. Demoting into a lossy channel would satisfy the letter of I4
# ("no card is dropped") while breaking its whole point.

const PRIORITY_PLAYER := "player"    ## an outcome of something the player did — never dropped
const PRIORITY_WORLD := "world"      ## a rival move, sector news
const PRIORITY_AMBIENT := "ambient"  ## general noise

## Player-outcome lines waiting for a channel, kept when the feed refuses them.
static var _held: Array = []


## Push one line. `line_key` is a localization key, never prose — §3.2 keeps text out of the
## engine, and a ticker line is text like any other.
static func push(line_key: String, priority: String, context: Dictionary = {}) -> void:
	if line_key == "":
		return
	var text: String = TranslationServer.translate(line_key)
	var source: String = _source_for(priority, context)
	EventBus.headline_added.emit(source, text)
	if priority == PRIORITY_PLAYER:
		# §18.3: player-outcome lines are never sacrificed. The feed may still drop one, so a
		# copy is held for the run log and the ending screen, which read History anyway — this
		# is belt and braces on the one priority that must not evaporate.
		_held.append({"day": GameState.day, "key": line_key, "text": text})


static func _source_for(priority: String, _context: Dictionary) -> String:
	match priority:
		PRIORITY_PLAYER: return TranslationServer.translate("TICKER_SRC_INTERNAL")
		PRIORITY_WORLD: return NewsFeedSystem.outlet_name(0)
	return NewsFeedSystem.outlet_name(1)


static func held_lines() -> Array:
	return _held.duplicate(true)


static func reset() -> void:
	_held.clear()


static func to_dict() -> Dictionary:
	return {"held": _held.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	_held = (d.get("held", []) as Array).duplicate(true)
