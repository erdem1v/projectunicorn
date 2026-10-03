class_name MessageSystem
extends RefCounted

# The inbox's messages that are not engine cards: Frank's intro, the period summary, the R&D
# note and discovery, the weekly sales report. Engine decisions are read from EvHistory and
# never copied here. A message is a CSV key and its args, never text, so it reads in the
# language it is opened in. The only writer of GameState.messages.

## [WORKING] Messages kept. Past it the oldest read message goes; an unread one never does.
const CAPACITY := 50


## Returns the id, `kind:day:n`, where n counts that kind's earlier messages the same day.
static func post(kind: String, key: String, args: Dictionary = {}) -> String:
	var n: int = GameState.messages.filter(
		func(m: Dictionary) -> bool: return m.kind == kind and m.day == GameState.day).size()
	var id: String = "%s:%d:%d" % [kind, GameState.day, n]
	GameState.messages.append(
		{"id": id, "kind": kind, "day": GameState.day, "key": key, "args": args, "read": false})
	var over: int = GameState.messages.size() - CAPACITY
	var i: int = 0
	while over > 0 and i < GameState.messages.size():
		if GameState.messages[i].read:
			GameState.messages.remove_at(i)
			over -= 1
		else:
			i += 1
	EventBus.messages_changed.emit()
	return id


static func mark_read(id: String) -> void:
	for m in GameState.messages:
		if m.id == id and not m.read:
			m.read = true
			EventBus.messages_changed.emit()
			return
