class_name GameEvent
extends Resource

# A card's renderable view: `EvPresenter.build_view` builds it from a card id and a frozen
# context, EventModal draws it, and it is thrown away when the modal closes. Never saved — the
# queue holds ids and the words are resolved in the live locale on every open, which is what
# makes a mid-run language switch safe (§3.2). Eligibility, latching and effects live in the
# engine, never here.
#
# The class is GameEvent, not Event, because Godot reserves `Event`; the field is `title`, not
# `name`, mirroring Character.character_name.

@export var id: String = ""
@export var title: String = ""
@export var subtitle: String = ""                  # e.g. "Cihangir · 13:42"

@export var character_id: String = ""              # "" = no character context strip
@export var body_text: String = ""                 # **bold** *italic* via markdown→BBCode in modal

@export var choices: Array[EventChoice] = []
@export var tags: Array[String] = []
