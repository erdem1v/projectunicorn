class_name EvPresenter
extends RefCounted

# THE SURFACE LAYER (GDD §11, §12). Turns a card Dictionary into something the existing modal
# can render, and builds the desk rows.
#
#   interrupt  a blocking modal, time stops
#   paper      the desk (notice stack, Events page), time flows
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
## Lint parses card text with it too, so a token lint passes is one this resolves.
static var SEAM_RE: RegEx = _compile(r"\{seam:([a-z_]+\.[a-z_]+)\}")


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
	var text: Dictionary = text_block(card)

	var ev := GameEvent.new()
	ev.id = event_id
	ev.title = resolve_text(text.get("title", ""), context)
	ev.subtitle = resolve_text(text.get("subtitle", ""), context)
	ev.body_text = resolve_text(text.get("body", ""), context)
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
		choice.label = resolve_text(labels.get(opt_id, opt_id), context)
		# The modal re-evaluates the lock at render time, so a lock can change between
		# admission and display.
		choice.unlock_condition = opt.get("requires", {})
		choice.unlock_reason_text = resolve_text(reasons.get(opt_id, ""), context)
		# Carried only for the modal's chip builder; EvEngine.resolve is the one path that
		# applies effects and writes history.
		choice.modifiers = opt.get("effects", [])
		ev.choices.append(choice)
	return ev


## The card's text block in the live locale. Turkish is canonical: a missing block (a build
## error under §17.8) falls back to it.
static func text_block(card: Dictionary) -> Dictionary:
	var all_text: Dictionary = card.get("text", {})
	var locale: String = "en" if Fmt.is_english() else "tr"
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

## What the desk lists, most urgent first. The model is uncapped (§11.4); `visible_slots` caps
## the rows, and EvPapers.ordered() keeps the papers with the fewest weeks left inside the cap.
## `id` is the paper's key, which is what open_paper takes; `category` is the card's category,
## which the surface puts in words. `weeks_left` 1 reads "this week", and `expiring`
## (EvPapers.is_expiring) is the row's one highlight.
static func desk_papers(visible_slots: int) -> Array:
	var out: Array = []
	for key in EvPapers.visible(visible_slots):
		var card: Dictionary = EvCatalog.card(EvPapers.event_id_of(key))
		out.append({
			"id": key,
			"title": resolve_text(text_block(card).get("title", ""), EvPapers.context_of(key)),
			"category": String(card.get("category", "")),
			"weeks_left": EvPapers.weeks_left(key),
			# §11.4: remaining time is on the paper, emphasised in its last week — the only
			# warning a deferred decision gets.
			"expiring": EvPapers.is_expiring(key),
			"target": "event:%s" % key,
		})
	return out


# --- Text resolution -------------------------------------------------------

## Resolve one text value. Three shapes:
##
## 1. A Dictionary -> variant text {by_seam, variants}, picked by a seam's integer value.
## 2. A bare SCREAMING_SNAKE token -> a localization key. A deliberate deviation from §3.2:
##    ported content's reviewed text already lives in strings.csv, and copying it inline would
##    give one string two homes. New content writes prose inline.
## 3. Anything else -> literal prose, interpolated.
static func resolve_text(value: Variant, context: Dictionary) -> String:
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
	# Keyed back to the authored spelling, so "01" is found as written; lint refuses a key
	# that is not an integer at all.
	var by_int: Dictionary = {}
	for k in variants:
		by_int[int(k)] = k
	var keys: Array = by_int.keys()
	keys.sort()
	var chosen: int = keys[0]
	for k in keys:
		if k <= value:
			chosen = k
	return resolve_text(variants[by_int[chosen]], context)


## `{slot}` / `{slot.name}` -> the bound entity's display name. `{seam:name}` -> a seam's value
## (§8.4): a number typed into prose goes stale silently, a number read from a seam cannot.
static func _interpolate(text: String, context: Dictionary) -> String:
	if not text.contains("{"):
		return text
	var out: String = text

	# Seams first, so a seam that returns prose containing {customer} still gets its entity
	# substitution below. The guard stops a seam whose value contains itself.
	var m: RegExMatch = SEAM_RE.search(out)
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
		m = SEAM_RE.search(out)

	for slot in context:
		var bound: Dictionary = context[slot]
		var display: String = _display_name(String(bound.get("type", "")), String(bound.get("id", "")))
		out = out.replace("{%s}" % slot, display).replace("{%s.name}" % slot, display)
	return out
