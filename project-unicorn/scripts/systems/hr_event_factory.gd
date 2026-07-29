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


# --- Departure: named, one line, in the person's own voice (design doc §6) ---

static func build_resignation(emp: Character) -> GameEvent:
	# The roll already happened in HRMoraleSystem; this event PRESENTS the outcome. The
	# single choice carries the hr_departure modifier so the removal still runs through
	# the sanctioned seam on resolve (CharacterRegistry.remove → run_departures + signal).
	var ev := GameEvent.new()
	ev.id = "ev_hr_resign_%s" % emp.id
	ev.category = "reactive"
	ev.tags = [TAG_BUILD_SAFE, "hr_departure"]
	ev.priority = 9
	ev.title = "Ayrılık"
	ev.character_id = emp.id     # portrait + "İsim · Rol" + trait chips come free
	ev.body_text = HRConstants.resign_voice(emp.id)
	ev.choices = [_choice("Anlaşıldı", [{"type": "hr_departure", "character_id": emp.id}])]
	return ev


# --- Overtime safety valve: a CHOICE, never a silent exclusion (design doc §7b) ---

static func build_overtime_valve(emp: Character, dept_id: String) -> GameEvent:
	var ev := GameEvent.new()
	ev.id = "ev_hr_valve_%s" % emp.id
	ev.category = "reactive"
	ev.tags = [TAG_BUILD_SAFE, "hr_overtime"]
	ev.priority = 10             # a person about to quit outranks routine beats
	ev.title = "Mesai sınırı"
	ev.character_id = emp.id
	ev.body_text = "%s\n\n**%s** bölümündeki ek mesai sürüyor. Devam edilirse bu riski bilerek alıyorsun." % [
		HRConstants.valve_voice(emp.id),
		HRConstants.department_label(dept_id),
	]
	ev.choices = [
		_choice("Mesaiyi durdur", [{"type": "hr_overtime_stop", "department": dept_id}]),
		_choice("Devam et", [{"type": "hr_overtime_continue", "department": dept_id, "character_id": emp.id}]),
	]
	return ev


# --- Placeholder positive morale events (design doc §6 + §12.8) ---
# Morale never self-heals, so without these the demo is one-directional and broken.
# Content sprint replaces the copy; the TRIGGERS (HRMoraleSystem's readable surface)
# and the effect channel stay. All three use the EXISTING morale_all_employees modifier,
# so they need no new modifier type and render with the "Ekip +N" badge for free.

static func build_calm_stretch(days: int) -> GameEvent:
	var ev := _positive("ev_hr_calm_stretch", "Sakin bir dönem")
	ev.body_text = "Ekip %d gündür ek mesai görmedi. Kimse akşam sekizde ekran başında değil, ve bu fark ediliyor." % days
	ev.choices = [_choice("İyi", [{"type": "morale_all_employees", "delta": HRConstants.CALM_STRETCH_MORALE}])]
	return ev


static func build_big_signing(customer_name: String, mrr: int) -> GameEvent:
	var ev := _positive("ev_hr_big_signing", "Ofiste iyi haber")
	ev.body_text = "**%s** imzaladı, aylık %s. Haber mutfağa varmadan herkes duymuş." % [
		customer_name, _money(mrr),
	]
	ev.choices = [_choice("Hak ettiler", [{"type": "morale_all_employees", "delta": HRConstants.BIG_SIGNING_MORALE}])]
	return ev


static func build_ship_glow(version: int) -> GameEvent:
	var ev := _positive("ev_hr_ship_glow", "Yayında")
	ev.body_text = "Sürüm %d çıktı ve tutuyor. Aylardır uğraşılan şeyin karşılığını görmek ekibi ayağa kaldırdı." % version
	ev.choices = [_choice("Devam", [{"type": "morale_all_employees", "delta": HRConstants.SHIP_GLOW_MORALE}])]
	return ev


# --- Internals ---

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
