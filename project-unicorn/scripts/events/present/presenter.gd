class_name EvPresenter
extends RefCounted

# THE SURFACE LAYER (GDD §11, §12). Turns a card Dictionary into something the existing modal
# can render, and builds the desk rows.
#
#   interrupt  a blocking modal, time stops
#   paper      the ODA desk, time flows
#   info       the owning module's badge — no engine queue: the module already counts its own
#              attention (RnDSystem/HRSystem.attention_count), so an info card fires `notify`
#   ambient    the news ticker
#
# `EventModal` takes a `GameEvent` Resource, so the adapter builds a throwaway one at display
# time. It never reaches persistence — the queue stores ids — and it keeps the modal's locked-
# option treatment (suppressed effect chips, authored reason badge) intact.
#
# TEXT IS RESOLVED HERE AND NOWHERE ELSE (§3.2). The queue holds ids; the locale is read at the
# moment of display, which is what makes a mid-run language switch safe.

static var _KEY_RE: RegEx = _compile("^[A-Z][A-Z0-9_]{2,}$")
static var _SEAM_RE: RegEx = _compile(r"\{seam:([a-z_]+\.[a-z_]+)\}")


static func _compile(pattern: String) -> RegEx:
	var re := RegEx.new()
	re.compile(pattern)
	return re


# --- The adapter -----------------------------------------------------------

## Build a renderable `GameEvent` from a card id and its frozen context.
static func build_view(event_id: String, context: Dictionary) -> GameEvent:
	var card: Dictionary = EvCatalog.card(event_id)
	if card.is_empty():
		return null
	var text: Dictionary = _text_block(card)

	var ev := GameEvent.new()
	ev.id = event_id
	ev.category = String(card.get("category", "reactive"))
	ev.title = _resolve_text(text.get("title", ""), context)
	ev.subtitle = _resolve_text(text.get("subtitle", ""), context)
	ev.body_text = _resolve_text(text.get("body", ""), context)
	for t in card.get("tags", []):
		ev.tags.append(String(t))

	# §14 ch.7: every card shows its source's avatar — the named speaker, else the scope's
	# person, so a card about an employee is visibly about that employee.
	var speaker: String = String(card.get("speaker", ""))
	ev.character_id = speaker if speaker != "" else _subject_character(context)

	var labels: Dictionary = text.get("options", {})
	var reasons: Dictionary = text.get("locked_reasons", {})
	for o in card.get("options", []):
		var opt: Dictionary = o
		var opt_id: String = String(opt.get("id", ""))
		var choice := EventChoice.new()
		choice.label = _resolve_text(labels.get(opt_id, opt_id), context)
		# The modal re-evaluates the lock at render time, so a lock can change between
		# admission and display.
		choice.unlock_condition = opt.get("requires", {})
		choice.unlock_reason_text = _resolve_text(reasons.get(opt_id, ""), context)
		# Carried only for the modal's chip builder; EvEngine.resolve is the one path that
		# applies effects and writes history.
		choice.modifiers = opt.get("effects", [])
		ev.choices.append(choice)
	return ev


## The card's text block in the live locale. Turkish is canonical: a missing block (a build
## error under §17.8) falls back to it.
static func _text_block(card: Dictionary) -> Dictionary:
	var all_text: Dictionary = card.get("text", {})
	var locale: String = "en" if TranslationServer.get_locale().begins_with("en") else "tr"
	var text: Dictionary = all_text.get(locale, {})
	return text if not text.is_empty() else all_text.get("tr", {})


static func _display_name(entity_type: String, entity_id: String) -> String:
	match entity_type:
		EvScope.TYPE_EMPLOYEE, EvScope.TYPE_FOUNDER:
			var c: Character = CharacterRegistry.get_character(entity_id)
			return c.character_name if c != null else entity_id
		EvScope.TYPE_CUSTOMER:
			# display_name(), not company_name: the B2C userbase record has an EMPTY
			# company_name and carries name_key + name_arg so a save does not freeze a language.
			var cu: Customer = CustomerRegistry.get_customer(entity_id)
			return cu.display_name() if cu != null else entity_id
		EvScope.TYPE_RIVAL:
			var r: Rival = RivalRegistry.get_rival(entity_id)
			return r.company_name if r != null else entity_id
		EvScope.TYPE_INVESTOR:
			# Investor names are proper nouns and do not localize.
			var inv: Dictionary = InvestorRegistry.get_investor(entity_id)
			return String(inv.get("display_name", entity_id))
	return entity_id


static func _subject_character(context: Dictionary) -> String:
	for slot in context:
		var bound: Dictionary = context[slot]
		if String(bound.get("type", "")) in [EvScope.TYPE_EMPLOYEE, EvScope.TYPE_FOUNDER]:
			return String(bound.get("id", ""))
	return ""


# --- The desk --------------------------------------------------------------

## What the ODA desk renders, most urgent first. The model is uncapped (§11.4); `visible_slots`
## is the art's three positions, and EvPapers.ordered() keeps urgent papers inside them.
static func desk_papers(visible_slots: int = 3) -> Array:
	var out: Array = []
	for event_id in EvPapers.visible(visible_slots):
		var card: Dictionary = EvCatalog.card(String(event_id))
		var left: int = EvPapers.days_left(String(event_id))
		out.append({
			"id": event_id,
			"title": _resolve_text(_text_block(card).get("title", ""), EvPapers.context_of(String(event_id))),
			"tag": String(card.get("category", "")).to_upper(),
			"days_left": left,
			# §11.4: remaining time is on the paper, emphasised in the last days — the only
			# warning a deferred decision gets.
			"urgent": left <= EvTuning.EXPIRY_URGENT_DAYS,
			"target": "event:%s" % event_id,
		})
	return out


static func desk_overflow(visible_slots: int = 3) -> int:
	return EvPapers.overflow_count(visible_slots)


# --- Text resolution -------------------------------------------------------

## Resolve one text value. Three shapes:
##
## 1. A Dictionary -> variant text {by_seam, variants}, picked by a seam's integer value.
## 2. A bare SCREAMING_SNAKE token -> a localization key. A deliberate deviation from §3.2:
##    ported content's reviewed text already lives in strings.csv, and copying it inline would
##    give one string two homes. New content writes prose inline.
## 3. Anything else -> literal prose, interpolated.
static func _resolve_text(value: Variant, context: Dictionary) -> String:
	if typeof(value) == TYPE_DICTIONARY:
		return _resolve_variant(value as Dictionary, context)
	var text: String = String(value)
	if text == "":
		return ""
	if _KEY_RE.search(text) != null:
		text = TranslationServer.translate(text)
	return _interpolate(text, context)


## The variant with the largest key not above the seam's value; the lowest key when every key
## is above it. So a counter that grows past the authored range stays on the last variant, and
## a sparse map ({"0", "3"}) keeps "0" for the values in between.
static func _resolve_variant(spec: Dictionary, context: Dictionary) -> String:
	var seam: String = String(spec.get("by_seam", ""))
	var variants: Dictionary = spec.get("variants", {})
	if variants.is_empty():
		return ""
	var value: int = int(EvSeams.read(seam)) if seam != "" and EvSeams.has(seam) else 0
	var keys: Array = variants.keys().map(func(k): return int(k))
	keys.sort()
	var chosen: int = keys[0]
	for k in keys:
		if k <= value:
			chosen = k
	return _resolve_text(variants[str(chosen)], context)


## `{slot}` / `{slot.name}` -> the bound entity's display name. `{seam:name}` -> a seam's value
## (§8.4): a number typed into prose goes stale silently, a number read from a seam cannot.
static func _interpolate(text: String, context: Dictionary) -> String:
	if not text.contains("{"):
		return text
	var out: String = text

	# Seams first, so a seam that returns prose containing {customer} still gets its entity
	# substitution below. The guard stops a seam whose value contains itself.
	var m: RegExMatch = _SEAM_RE.search(out)
	var guard: int = 0
	while m != null and guard < 16:
		guard += 1
		var seam_name: String = m.get_string(1)
		var value: String = ""
		if not EvSeams.has(seam_name):
			push_error("[EvPresenter] card text reads unknown seam '%s'" % seam_name)
		elif EvSeams.kind_of(seam_name) == EvSeams.Kind.ENTITY:
			var entity_id: String = EvScope.id_in(context, "", seam_name)
			if entity_id != "":
				value = str(EvSeams.read_for(seam_name, entity_id))
		else:
			value = str(EvSeams.read(seam_name))
		out = out.replace(m.get_string(0), value)
		m = _SEAM_RE.search(out)

	for slot in context:
		var bound: Dictionary = context[slot]
		var display: String = _display_name(String(bound.get("type", "")), String(bound.get("id", "")))
		out = out.replace("{%s}" % slot, display).replace("{%s.name}" % slot, display)
	return out
