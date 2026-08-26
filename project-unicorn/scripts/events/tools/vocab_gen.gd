class_name EvVocabGen
extends RefCounted

# Regenerates docs/content/events_draft/_vocabulary.md FROM THE ENGINE.
#
#     godot --headless --path . --event-vocab
#
# WHY THIS IS GENERATED AND THE OLD ONE WAS NOT. The hand-kept version drifted in three
# measurable ways within two months of being written — it listed 43 modifiers including two
# that had been deleted with the overtime system and one that had been retired, said 27
# conditions where there were 29, and its line numbers were 20-30 out. Its own §g.8 admits it.
# That is not neglect; it is what a hand-kept extract of a moving target does. `08_event_ve_
# anlati.md` §12 asks for it to be generated, and this is that.
#
# WHAT IT DOES NOT TOUCH. Three sections of that file are hand-written editorial reasoning and
# are preserved verbatim between markers: the trigger-hook map, the legacy-function map, and
# the known-gaps list. Nobody would reconstruct those from source, and regenerating over them
# would be the tool destroying the thing it was meant to protect.

const OUT_PATH := "res://docs/content/events_draft/_vocabulary.md"
const KEEP_BEGIN := "<!-- HAND-WRITTEN — REGENERATION SKIPS THIS BLOCK -->"
const KEEP_END := "<!-- END HAND-WRITTEN -->"


static func run() -> bool:
	EvCatalog.reload()
	EvSeams.ensure_installed()

	var kept: String = _extract_kept()
	var L: PackedStringArray = []

	L.append("# Event authoring · vocabulary")
	L.append("")
	L.append("**GENERATED from the engine — do not hand-edit outside the marked block.**")
	L.append("Regenerate: `godot --headless --path . --event-vocab`")
	L.append("")
	L.append("Every card may use only what is listed here. Anything a draft wants that is not")
	L.append("here is written `[VOCAB?] <what it wants>` for an effect or `[COND?] <…>` for a")
	L.append("prerequisite, and the node is not wired until the item ships. Nothing is invented —")
	L.append("that rule is GDD v2 ch.11 §3, and §21's DELTA workflow is how an item gets added.")
	L.append("")
	L.append("Counts are what the engine actually has, at generation time:")
	L.append("")
	L.append("| | count |")
	L.append("|---|---|")
	L.append("| Seams (read) | **%d** |" % EvSeams.all_names().size())
	L.append("| Effect verbs (write) | **%d** |" % (EvEffects.NEUTRAL_VERBS.size()
		+ EvEffects.ECONOMIC_VERBS.size() + EvEffects.TERMINAL_VERBS.size()))
	L.append("| Cards in the catalogue | %d |" % EvCatalog.card_ids().size())
	L.append("| Arcs | %d |" % EvCatalog.arc_ids().size())
	L.append("")

	# --- effects, grouped by the origin that may use them -------------------
	L.append("## a · Effect verbs")
	L.append("")
	L.append("**The grouping IS the rule.** An effect's origin decides what it may do — that is")
	L.append("invariant I2, and it is enforced by the dispatch table rather than by a lint pass,")
	L.append("so a verb absent from a group is unreachable from it rather than merely discouraged.")
	L.append("")
	L.append("| origin | may use |")
	L.append("|---|---|")
	L.append("| an option's `effects` | neutral + economic + terminal |")
	L.append("| `on_expire.penalties` | neutral + economic **negative only** |")
	L.append("| `on_invalidate.penalties`, arc auto-steps, signal handlers | neutral only |")
	L.append("| a `check` branch | neutral + economic, **never terminal** (I6) |")
	L.append("")
	L.append("### Neutral — available everywhere")
	L.append("")
	for verb in EvEffects.NEUTRAL_VERBS:
		L.append("- `%s`" % verb)
	L.append("")
	L.append("### Economic — a played decision only")
	L.append("")
	L.append("Barred from ambient origins entirely; on expiry, allowed only in the negative.")
	L.append("")
	for verb in EvEffects.ECONOMIC_VERBS:
		L.append("- `%s`" % verb)
	L.append("")
	L.append("### Terminal")
	L.append("")
	L.append("Requires `requires_telegraph` naming a card or flag that has already fired (I3).")
	L.append("")
	for verb in EvEffects.TERMINAL_VERBS:
		L.append("- `%s`" % verb)
	L.append("")

	# --- seams --------------------------------------------------------------
	L.append("## b · Seams — everything a condition may read")
	L.append("")
	L.append("A name not on this list is a **build error** (§17.1), not a runtime warning. An")
	L.append("entity-scoped seam needs a `scope` naming the slot when the card has more than one")
	L.append("slot of that type (§17.12).")
	L.append("")
	var namespaces: Dictionary = {}
	for name in EvSeams.all_names():
		var ns: String = String(name).split(".")[0]
		namespaces.get_or_add(ns, []).append(name)
	var ns_keys: Array = namespaces.keys()
	ns_keys.sort()
	for ns in ns_keys:
		L.append("### `%s.`" % ns)
		L.append("")
		L.append("| seam | scope | type | owner | note |")
		L.append("|---|---|---|---|---|")
		for name in (namespaces[ns] as Array):
			L.append("| `%s` | %s | %s | %s | %s |" % [name,
				"entity" if EvSeams.kind_of(String(name)) == EvSeams.Kind.ENTITY else "global",
				_type_name(EvSeams.type_of(String(name))),
				EvSeams.owner_of(String(name)),
				_note_of(String(name))])
		L.append("")

	# --- conditions ---------------------------------------------------------
	L.append("## c · Condition vocabulary")
	L.append("")
	L.append("Nested dictionaries. Combinators: `all` (AND) · `any` (OR) · `none` · `not`.")
	L.append("An empty `all` is TRUE, an empty `any` is FALSE, an empty `none` is TRUE.")
	L.append("")
	L.append("A node may carry `\"reason\"` — one authored sentence shown when it refuses. An")
	L.append("`any` that gates an option **must** carry one: when a disjunction fails, every")
	L.append("branch failed, and naming one of them is arbitrary and usually misleading.")
	L.append("")
	L.append("```json")
	L.append("{\"seam\": \"hr.headcount\", \"op\": \">=\", \"value\": 3}")
	L.append("{\"seam\": \"phase.current\", \"op\": \"in\", \"value\": [2, 3]}")
	L.append("{\"flag\": \"frank_seed_taken\"}")
	L.append("{\"flag_unset\": \"acquisition_declined\"}")
	L.append("{\"days_since_flag\": \"mvp_launch\", \"op\": \">=\", \"value\": 30}")
	L.append("{\"flag_expires_within\": \"negotiation_window\", \"days\": 3}")
	L.append("{\"history\": \"chose\", \"event\": \"hr.raise_request\", \"option\": \"accept\"}")
	L.append("{\"history\": \"fired\", \"event\": \"hr.raise_request\"}")
	L.append("{\"history\": \"days_since\", \"event\": \"hr.raise_request\", \"op\": \">=\", \"value\": 30}")
	L.append("{\"history\": \"resolution\", \"event\": \"sales.offer\", \"value\": \"expired\"}")
	L.append("{\"arc\": \"active\", \"id\": \"arc_promise_mobile\"}")
	L.append("{\"arc\": \"at_step\", \"id\": \"arc_promise_mobile\", \"step\": 2}")
	L.append("{\"arc\": \"ended\", \"id\": \"arc_promise_mobile\", \"outcome\": \"kept\"}")
	L.append("{\"entity_exists\": \"employee_a\"}")
	L.append("{\"entity_count\": \"employee\", \"op\": \">=\", \"value\": 2}")
	L.append("{\"entity_seam\": \"hr.morale\", \"scope\": \"employee_a\", \"op\": \"<\", \"value\": 50}")
	L.append("```")
	L.append("")
	L.append("**A flag is engine memory, not game state.** `flag` and `flag_unset` read the")
	L.append("engine's own store. Anything a SYSTEM owns — `series_a_closed`, `mvp_shipped` —")
	L.append("is read through its seam, never as a flag: the engine store has never heard of it,")
	L.append("so `flag_unset` would silently read true forever.")
	L.append("")

	# --- arcs ---------------------------------------------------------------
	L.append("## d · Arcs in the catalogue")
	L.append("")
	L.append("| arc | type | policy | steps |")
	L.append("|---|---|---|---|")
	for arc_id in EvCatalog.arc_ids():
		var arc: Dictionary = EvCatalog.arc(arc_id)
		L.append("| `%s` | %s | %s | %d |" % [arc_id, arc.get("type", "?"),
			(arc.get("on_invalidate", {}) as Dictionary).get("policy", "?"),
			(arc.get("steps", []) as Array).size()])
	L.append("")

	L.append(KEEP_BEGIN)
	L.append(kept if kept != "" else _kept_placeholder())
	L.append(KEEP_END)
	L.append("")

	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f == null:
		push_error("[EvVocabGen] cannot write %s" % OUT_PATH)
		return false
	f.store_string("\n".join(L))
	f.close()
	print("[EvVocabGen] wrote %s — %d seams, %d verbs, %d cards"
		% [OUT_PATH, EvSeams.all_names().size(),
			EvEffects.NEUTRAL_VERBS.size() + EvEffects.ECONOMIC_VERBS.size()
				+ EvEffects.TERMINAL_VERBS.size(),
			EvCatalog.card_ids().size()])
	return true


static func _extract_kept() -> String:
	var f := FileAccess.open(OUT_PATH, FileAccess.READ)
	if f == null:
		return ""
	var text: String = f.get_as_text()
	var a: int = text.find(KEEP_BEGIN)
	var b: int = text.find(KEEP_END)
	if a < 0 or b < 0 or b <= a:
		return ""
	return text.substr(a + KEEP_BEGIN.length(), b - a - KEEP_BEGIN.length()).strip_edges()


static func _kept_placeholder() -> String:
	return ("\n## e · Hand-written notes\n\n"
		+ "This block survives regeneration. The three sections worth keeping here are the ones\n"
		+ "the old file carried and nobody would reconstruct: the **trigger-hook map** (draft\n"
		+ "hook name → the signal and file:line that fires it today), the **legacy-function map**\n"
		+ "(every retired card id → the arc node that inherited its job), and the list of\n"
		+ "**known gaps** the engine has not closed.\n")


static func _type_name(t: int) -> String:
	match t:
		TYPE_INT: return "int"
		TYPE_FLOAT: return "float"
		TYPE_STRING: return "string"
		TYPE_BOOL: return "bool"
	return "?"


static func _note_of(name: String) -> String:
	# The registry keeps a note per seam; surfacing it here is what makes the table worth
	# reading rather than merely complete.
	return String((EvSeams._seams.get(name, {}) as Dictionary).get("note", ""))
