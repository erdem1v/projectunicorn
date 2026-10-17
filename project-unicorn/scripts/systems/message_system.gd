class_name MessageSystem
extends RefCounted

# The inbox's messages that are not engine cards: Frank's intro, the period summary, the R&D
# note and discovery, the weekly sales report. Engine decisions are read from EvHistory and
# never copied here. A message is a CSV key and its args, never text, so it reads in the
# language it is opened in. The only writer of GameState.messages.
#
# A message comes in with the workday (MailClock): an urgent one at once, any other at an arrival time inside
# the company window, waiting in GameState.mail_outbox until then. Delivery is also what announces it: the
# period summary and the product note raise their signal when they are delivered, not when they are written.

## [WORKING] Messages kept. Past it the oldest read message goes; an unread one never does.
const CAPACITY := 50


## Returns the id, `kind:day:n`, where n counts that kind's earlier messages the same day; "" while the
## message waits in the outbox.
static func post(kind: String, key: String, args: Dictionary = {}, urgent := false) -> String:
	var msg := {"kind": kind, "key": key, "args": args, "at": MailClock.arrival("%s|%s" % [kind, key], urgent)}
	if int(msg.at) > MailClock.now():
		GameState.mail_outbox.append(msg)
		return ""
	return _deliver(msg)


## Delivers the outbox's messages whose time has come.
static func release() -> void:
	var due: Array = []
	var waiting: Array = []
	for msg in GameState.mail_outbox:
		(due if MailClock.delivered(int(msg.at)) else waiting).append(msg)
	if due.is_empty():
		return
	GameState.mail_outbox.assign(waiting)
	for msg in due:
		_deliver(msg)


static func _deliver(msg: Dictionary) -> String:
	var day: int = int(msg.at) / MailClock.DAY_MINUTES
	var n: int = GameState.messages.filter(
		func(m: Dictionary) -> bool: return m.kind == msg.kind and m.day == day).size()
	var id: String = "%s:%d:%d" % [msg.kind, day, n]
	GameState.messages.append({"id": id, "kind": msg.kind, "day": day, "key": msg.key, "args": msg.args,
		"at": int(msg.at), "read": false})
	var over: int = GameState.messages.size() - CAPACITY
	var i: int = 0
	while over > 0 and i < GameState.messages.size():
		if GameState.messages[i].read:
			GameState.messages.remove_at(i)
			over -= 1
		else:
			i += 1
	EventBus.messages_changed.emit()
	match String(msg.kind):
		"summary":
			EventBus.summary_ready.emit(msg.args)
		"rnd_note":
			EventBus.product_note_issued.emit(day)
	return id


static func mark_read(id: String) -> void:
	for m in GameState.messages:
		if m.id == id and not m.read:
			m.read = true
			EventBus.messages_changed.emit()
			return
