class_name HREventFactory
extends RefCounted

# Builds the HR module's engine-fired events. Pure statics, no state — mirrors
# B2BEventFactory exactly (which is the house template for runtime-authored events).
# Callers hand the result to EventManager.enqueue().
#
# Two things every caller must know:
#
# 1. enqueue() BYPASSES EventManager._is_eligible entirely, so `one_shot`,
#    `cooldown_days` and the active-build `build_safe` gate DO NOTHING on a synthetic
#    event. The "build_safe" tag below is house convention for readability only. Hold
#    every once-only latch in the calling SYSTEM (the way B2BSalesSystem holds
#    c.cs_escalated), never on the event.
#
# 2. resolve_choice appends synthetics to EventManager._history, and the one_shot guard
#    scans that history by id — so a synthetic id colliding with a JSON event id would
#    permanently suppress the JSON one. Every id here is namespaced per character or
#    department for exactly that reason.
#
# Copy is WORKING TR (a voice pass comes with the content sprint). Turkish literals, no
# CSV keys — same convention as B2BEventFactory.

const TAG_BUILD_SAFE := "build_safe"


# --- Departure: named, one line, in the person's own voice (§11.3) ---

static func build_resignation(emp: Character) -> GameEvent:
	# The roll already happened in HRMoraleSystem; this event PRESENTS the outcome. The
	# single choice carries the hr_departure modifier so the removal still runs through
	# the sanctioned seam on resolve (CharacterRegistry.remove → run_departures + signal).
	var ev := GameEvent.new()
	ev.id = "ev_hr_resign_%s" % emp.id
	ev.category = "reactive"
	ev.tags = [TAG_BUILD_SAFE, "hr_departure"]
	ev.priority = 9
	ev.title = TranslationServer.translate("HR_EV_RESIGN_TITLE")
	ev.character_id = emp.id     # portrait + "İsim · Rol" + trait chips come free
	ev.body_text = HRConstants.resign_voice(emp.id)
	ev.choices = [_choice(TranslationServer.translate("HR_EV_RESIGN_ACK"), [{"type": "hr_departure", "character_id": emp.id}])]
	return ev


# --- Internals ---# --- Internals ---

static func _positive(event_id: String, title: String) -> GameEvent:
	var ev := GameEvent.new()
	ev.id = event_id
	ev.category = "reactive"
	ev.tags = [TAG_BUILD_SAFE, "hr_positive"]
	ev.priority = 4              # below system beats; good news can wait its turn
	ev.title = title
	# Synthetic speaker deliberately UNSET: this is the room, not a person. The modal
	# hides the speaker strip when neither character_id nor speaker_name is present.
	return ev


static func _choice(label: String, modifiers: Array) -> EventChoice:
	var c := EventChoice.new()
	c.label = label
	c.modifiers = modifiers
	return c


static func _money(amount: int) -> String:
	# One formatter for the HR module (HRConstants.money_tr).
	return HRConstants.money_tr(amount)
