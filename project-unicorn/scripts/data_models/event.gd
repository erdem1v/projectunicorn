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
@export var category: String = "reactive"
@export var title: String = ""
@export var subtitle: String = ""                  # e.g. "Cihangir · 13:42"

@export var character_id: String = ""              # "" = no character context strip
@export var body_text: String = ""                 # **bold** *italic* via markdown→BBCode in modal

# Mentor aside, presentation-only.
@export var mentor_line: String = ""               # one italic line above the choices; "" = absent
@export var mentor_choice: int = -1                # index of the MENTOR TAVSİYESİ choice; -1 = none

# Synthetic speaker: when character_id is empty but speaker_name is set, the modal draws a
# non-Character speaker strip (a customer in its own voice) from these fields directly.
@export var speaker_name: String = ""
@export var speaker_role: String = ""
@export var speaker_status: String = ""            # status pill text
@export var speaker_status_kind: String = "neutral" # UiFactory badge kind for the pill
@export var speaker_chips: Array = []              # extra chips: Array of {text, kind}
@export var speaker_initial: String = ""           # avatar initials; "" → derived from speaker_name

@export var choices: Array[EventChoice] = []
@export var tags: Array[String] = []

# English siblings, resolved at render time through Localization.pick; empty = TR fallback.
@export var title_en: String = ""
@export var subtitle_en: String = ""
@export var body_text_en: String = ""
@export var mentor_line_en: String = ""
