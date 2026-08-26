class_name EvPresenter
extends RefCounted

# THE SURFACE LAYER (GDD §11, §12). Decides where a card appears and turns a card Dictionary
# into something the existing modal can render.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# THE FOUR CLASSES AND THEIR SURFACES (§11.1)
# ─────────────────────────────────────────────────────────────────────────────────────────
#
#   interrupt  a blocking modal, time stops        crisis, arc turning point, terminal warning
#   paper      the ODA desk, time flows            a decision that is not urgent
#   info       the owning module's badge           a report, a notification
#   ambient    the news ticker                     rival noise, an arc's fade trail
#
# `info` DOES NOT GET AN ENGINE QUEUE. The GDD lists it as a class and it is one, but its
# surface is the badge the owning module already maintains — `RnDSystem.attention_count()`,
# `HRSystem.attention_count()`. Giving the engine its own badge state would duplicate a
# counter that already exists and put the engine in charge of another module's rail entry,
# which is the WRITE-THROUGH LAW inverted. So an `info` card fires a `notify` effect and the
# module counts it.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# WHY AN ADAPTER RATHER THAN A NEW MODAL
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# `EventModal` takes a `GameEvent` Resource; cards are Dictionaries. The obvious move is to
# rewrite the modal. Two reasons not to:
#
#   1. UI design is explicitly out of scope for this rebuild. The card's appearance goes
#      through the mockup pipeline, and a rewrite now would be a redesign nobody approved.
#   2. `event_modal.gd`'s locked-option treatment is CORRECT and hard-won: 50% alpha,
#      `gui_input` never connected, effect chips **suppressed** so a locked path cannot leak
#      its cost, and the authored reason badge in its place (`:412-425`). Rewriting it would
#      put all of that at risk for no gain this round.
#
# So the adapter builds a throwaway `GameEvent` at display time. It is ~40 lines, it never
# reaches persistence — the queue stores ids — and it dies the day the modal is rebuilt.
#
# TEXT IS RESOLVED HERE AND NOWHERE ELSE (§3.2). "Motor hiçbir aşamada metne dokunmaz." The
# queue holds ids; the locale is read at the moment of display. That is what makes a mid-run
# language switch safe: a paper on the desk simply renders in the other language, because
# nothing anywhere stored a rendered string.

const MODAL_SCENE := "res://scenes/modals/EventModal.tscn"


## Which surface a class wants. `main.gd` reads this to decide what to mount.
static func surface_for(card_class: String) -> String:
	match card_class:
		"interrupt": return "modal"
		"paper": return "desk"
		"info": return "badge"
	return "ticker"


# --- The adapter -----------------------------------------------------------

## Build a renderable `GameEvent` from a card id and its frozen context.
##
## Text is resolved at THIS moment, from the live locale. Nothing here is cached and nothing
## here is stored.
static func build_view(event_id: String, context: Dictionary) -> GameEvent:
	var card: Dictionary = EvCatalog.card(event_id)
	if card.is_empty():
		return null

	var locale: String = "en" if TranslationServer.get_locale().begins_with("en") else "tr"
	var text: Dictionary = (card.get("text", {}) as Dictionary).get(locale, {})
	# A missing block falls back to Turkish, which is canonical. §17.8 makes a missing block a
	# build error, so this only fires for content that reached runtime some other way.
	if text.is_empty():
		text = (card.get("text", {}) as Dictionary).get("tr", {})

	var ev := GameEvent.new()
	ev.id = event_id
	ev.category = String(card.get("category", "reactive"))
	ev.title = _resolve_text(text.get("title", ""), context)
	ev.subtitle = _resolve_text(text.get("subtitle", ""), context)
	ev.body_text = _resolve_text(text.get("body", ""), context)
	ev.tags = _typed_tags(card.get("tags", []))

	# §14 ch.7's uniform grammar: every card shows a small avatar of its source. A speaker is
	# a character id when the card names one, and the scope's subject otherwise — so a card
	# about an employee is visibly about that employee without the author restating it.
	var speaker: String = String(card.get("speaker", ""))
	if speaker == "":
		speaker = _subject_character(context)
	ev.character_id = speaker

	var options: Array = card.get("options", [])
	var labels: Dictionary = text.get("options", {})
	var reasons: Dictionary = text.get("locked_reasons", {})
	for o in options:
		var opt: Dictionary = o
		var opt_id: String = String(opt.get("id", ""))
		var choice := EventChoice.new()
		choice.label = _resolve_text(labels.get(opt_id, opt_id), context)
		# The lock is re-evaluated by the modal at render time against this dictionary, which
		# is how a lock can change between admission and display.
		choice.unlock_condition = opt.get("requires", {})
		choice.unlock_reason_text = _resolve_text(reasons.get(opt_id, ""), context)
		# Effects are carried so the modal's chip builder can describe them. The engine never
		# applies them from here — resolution goes through EvEngine.resolve, which is the only
		# path that writes history.
		choice.modifiers = opt.get("effects", [])
		ev.choices.append(choice)

	return ev


static func _display_name(entity_type: String, entity_id: String) -> String:
	match entity_type:
		EvScope.TYPE_EMPLOYEE, EvScope.TYPE_FOUNDER:
			var c: Character = CharacterRegistry.get_character(entity_id)
			return c.character_name if c != null else entity_id
		EvScope.TYPE_CUSTOMER:
			var cu: Customer = CustomerRegistry.get_customer(entity_id)
			return cu.company_name if cu != null else entity_id
		EvScope.TYPE_RIVAL:
			var r: Rival = RivalRegistry.get_rival(entity_id)
			return r.company_name if r != null else entity_id
	return entity_id


static func _subject_character(context: Dictionary) -> String:
	for slot in context:
		var bound: Dictionary = context[slot]
		if String(bound.get("type", "")) in [EvScope.TYPE_EMPLOYEE, EvScope.TYPE_FOUNDER]:
			return String(bound.get("id", ""))
	return ""


static func _typed_tags(tags: Array) -> Array[String]:
	var out: Array[String] = []
	for t in tags:
		out.append(String(t))
	return out


# --- The desk --------------------------------------------------------------

## What the ODA desk should render, most urgent first.
##
## `visible_slots` is three, because the sealed art has three paper positions
## (oda_layout.gd:198). The MODEL is uncapped — §11.4 is right that a desk needs no capacity
## limit once every paper has a clock — and this decides which three are shown.
##
## URGENCY WINS A SLOT (approved amendment A3). `EvPapers.ordered()` sorts by days remaining,
## so a paper inside its last three days is always in the visible set and cannot run its clock
## down behind the overflow chip. A consequence that lands off-screen is not a consequence.
static func desk_papers(visible_slots: int = 3) -> Array:
	var out: Array = []
	for event_id in EvPapers.visible(visible_slots):
		var card: Dictionary = EvCatalog.card(String(event_id))
		var locale: String = "en" if TranslationServer.get_locale().begins_with("en") else "tr"
		var text: Dictionary = (card.get("text", {}) as Dictionary).get(locale, {})
		var left: int = EvPapers.days_left(String(event_id))
		out.append({
			"id": event_id,
			"title": _resolve_text(text.get("title", ""), EvPapers.context_of(String(event_id))),
			"tag": String(card.get("category", "")).to_upper(),
			"days_left": left,
			# §11.4: the remaining time is visible on the paper, with emphasis in the last
			# three days. That emphasis is the only warning a deferred decision gets.
			"urgent": left <= EvTuning.EXPIRY_URGENT_DAYS,
			"target": "event:%s" % event_id,
		})
	return out


static func desk_overflow(visible_slots: int = 3) -> int:
	return EvPapers.overflow_count(visible_slots)


# --- Text resolution -------------------------------------------------------
# a reason that is not "it would be convenient".

## Resolve one text value. THREE SHAPES, and the dispatch between them is deliberate.
##
## 1. A Dictionary  -> variant text: {by_seam, variants}. The Series A gate already rewrites
##    its own body by decline count (phase_gate_system.gd:266-276), so variant text was
##    shipping in the game before the schema had a word for it. This is
##    EVENT_POOL_DESIGN_v1 §5.7 delivered narrowly, for the card that needs it, rather than as
##    a general facility nobody has asked for. A missing variant falls back to the lowest key,
##    so a seam that grows past the authored range degrades to the first body rather than to
##    an empty card.
##
## 2. A bare SCREAMING_SNAKE token -> a localization key.
##    A DEVIATION FROM §3.2, and taken knowingly. The ported code-built families' text is
##    already in localization/strings.csv — about 60 rows, written, reviewed and gated by
##    loc_csv_integrity. Copying them inline would give one reviewed string two homes and the
##    two would drift the first time either moved. New content writes prose inline, which is
##    the GDD's shape; ported content keeps its key until the writing round rewrites it.
##
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


static var _KEY_RE: RegEx = _compile("^[A-Z][A-Z0-9_]{2,}$")
static var _SEAM_RE: RegEx = _compile(r"\{seam:([a-z_]+\.[a-z_]+)\}")


static func _compile(pattern: String) -> RegEx:
	var re := RegEx.new()
	re.compile(pattern)
	return re


static func _resolve_variant(spec: Dictionary, context: Dictionary) -> String:
	var seam: String = String(spec.get("by_seam", ""))
	var variants: Dictionary = spec.get("variants", {})
	if variants.is_empty():
		return ""
	var value: int = int(EvSeams.read(seam)) if seam != "" and EvSeams.has(seam) else 0
	var keys: Array = variants.keys()
	keys.sort()
	var chosen: String = String(variants.get(str(value), variants[keys[0]]))
	return _resolve_text(chosen, context)


## `{slot}` -> the bound entity's display name. `{seam:name}` -> a seam's value.
##
## THE SEAM FORM IS §8.4's MECHANISM, and it exists because of a bug that shipped:
## END_META_BANKRUPTCY_FRANK says "Yedi gün kırmızıda kaldın" while SHUTTER_DAYS has been 30
## since the Frank v6 pass. A number typed into prose goes stale silently and nothing can
## catch it. A number read from a seam cannot.
##
## The B2B family needs the same thing for PROSE rather than numbers: the complaint body is
## per-sector, so one card carries {seam:musteri.complaint_voice} instead of fifteen near-copies
## each hard-coding one sector's line.
static func _interpolate(text: String, context: Dictionary) -> String:
	if not text.contains("{"):
		return text
	var out: String = text

	# Seam reads first, so a seam that returns prose containing {customer} still gets its
	# entity substitution below.
	var m: RegExMatch = _SEAM_RE.search(out)
	var guard: int = 0
	while m != null and guard < 16:
		guard += 1
		var seam_name: String = m.get_string(1)
		var value: String = ""
		if EvSeams.has(seam_name):
			if EvSeams.kind_of(seam_name) == EvSeams.Kind.ENTITY:
				var entity_id: String = EvScope.id_in(context, "", seam_name)
				value = str(EvSeams.read_for(seam_name, entity_id)) if entity_id != "" else ""
			else:
				value = str(EvSeams.read(seam_name))
		else:
			# Lint makes this a build error, so reaching here means content got in another way.
			push_error("[EvPresenter] card text reads unknown seam '%s'" % seam_name)
		out = out.replace(m.get_string(0), value)
		m = _SEAM_RE.search(out)

	for slot in context:
		var bound: Dictionary = context[slot]
		var display: String = _display_name(String(bound.get("type", "")), String(bound.get("id", "")))
		out = out.replace("{%s}" % slot, display)
		out = out.replace("{%s.name}" % slot, display)
	return out
