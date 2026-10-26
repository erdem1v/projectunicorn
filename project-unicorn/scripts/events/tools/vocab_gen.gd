class_name EvVocabGen
extends RefCounted

# Regenerates docs/content/events_draft/_vocabulary.md FROM THE ENGINE.
#
#     godot --headless --path . --event-vocab
#
# Generated because a hand-kept extract of a moving vocabulary drifts from it.
#
# WHAT IT DOES NOT TOUCH: the hand-written block between the KEEP markers is preserved
# verbatim. Nobody would reconstruct it from source.

const ModuleLocks := preload("res://scripts/systems/module_locks.gd")

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
	var verb_count: int = EvEffects.NEUTRAL_VERBS.size() + EvEffects.ECONOMIC_VERBS.size() \
		+ EvEffects.TERMINAL_VERBS.size()
	L.append("| Seams (read) | **%d** |" % EvSeams.all_names().size())
	L.append("| Effect verbs (write) | **%d** |" % verb_count)
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
	L.append("### Parameters worth knowing")
	L.append("")
	L.append("- `amount_seam` × `amount_mult` is a figure read from a seam. A global seam needs nothing more; an entity seam")
	L.append("  needs `amount_slot`, the scope slot whose entity it is read for (the slot's type must be the seam's).")
	L.append("- `schedule_event.delay_weeks` is a number or a window `[lo, hi]`; a window's week is drawn from the day, the")
	L.append("  scheduling card and the scheduled one, so the same day gives the same week.")
	L.append("- An option may carry `effects` and a `check` together: the effects land first, then the branch the dice picks.")
	L.append("")
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
				EvSeams.note_of(String(name))])
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
	L.append("{\"weeks_since_flag\": \"mvp_launch\", \"op\": \">=\", \"value\": 4}")
	L.append("{\"flag_expires_within\": \"negotiation_window\", \"weeks\": 1}")
	L.append("{\"history\": \"chose\", \"event\": \"hr.raise_request\", \"option\": \"accept\"}")
	L.append("{\"history\": \"fired\", \"event\": \"hr.raise_request\"}")
	L.append("{\"history\": \"weeks_since\", \"event\": \"hr.raise_request\", \"op\": \">=\", \"value\": 4}")
	L.append("{\"history\": \"resolution\", \"event\": \"sales.offer\", \"value\": \"expired\"}")
	L.append("{\"arc\": \"active\", \"id\": \"arc_promise_mobile\"}")
	L.append("{\"arc\": \"at_step\", \"id\": \"arc_promise_mobile\", \"step\": 2}")
	L.append("{\"arc\": \"ended\", \"id\": \"arc_promise_mobile\", \"outcome\": \"kept\"}")
	L.append("{\"entity_exists\": \"employee_a\"}")
	L.append("{\"entity_count\": \"employee\", \"op\": \">=\", \"value\": 2}")
	L.append("{\"entity_seam\": \"hr.morale\", \"scope\": \"employee_a\", \"op\": \"<\", \"value\": 50}")
	L.append("{\"year_roll\": 0.5}")
	L.append("```")
	L.append("")
	L.append("`year_roll` is a coin per calendar year: the chance (0 to 1) that the card holds in a given year, rolled from")
	L.append("the year and the card's id, so every look within a year agrees. A `key` shares one roll across cards.")
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

	# --- schema v3 ----------------------------------------------------------
	L.append("## e · Schema v3 — the plausibility block")
	L.append("")
	L.append("Every card carries one and the engine compiles it into ordinary condition leaves")
	L.append("(GDD §3.1, §27.20). The block's SHAPE is §3.1's table; what follows is the value each")
	L.append("field accepts, read off the engine.")
	L.append("")
	L.append("### `phase_band` — where in the run the card lives")
	L.append("")
	L.append("| band | compiles to |")
	L.append("|---|---|")
	for band in EvCatalog.PHASE_BANDS:
		L.append("| `%s` | %s |" % [band, _leaves(EvCatalog.band_leaves(band))])
	L.append("")
	L.append("### `product` — which side of the launch")
	L.append("")
	L.append("| value | compiles to |")
	L.append("|---|---|")
	for state in EvCatalog.PRODUCT_LIVE:
		L.append("| `%s` | `urun.is_live == %s` |"      # LOC-DATA seam name
			% [state, EvCatalog.PRODUCT_LIVE[state]])
	L.append("| `any` | nothing; the card lives on both sides |")
	L.append("")
	L.append("### `modules` — the module pages a card may require")
	L.append("")
	L.append("Each name becomes a `build.module_unlocked.<id>` leaf (§27.22).")
	L.append("")
	for id in ModuleLocks.ids():
		L.append("- `%s`" % id)
	L.append("")
	L.append("### `subject_tenure_weeks` — where seniority is readable")
	L.append("")
	L.append("The floor filters the slot's SELECTOR, so the card binds someone who has been here")
	L.append("that long rather than binding anyone and refusing at the gate. A slot of any other")
	L.append("type has no seniority, and a `system` card is given its subject, so it gets no filter.")
	L.append("")
	L.append("| slot type | seam the floor reads |")
	L.append("|---|---|")
	for slot_type in EvCatalog.TENURE_SEAMS:
		L.append("| `%s` | `%s` |" % [slot_type, EvCatalog.TENURE_SEAMS[slot_type]])
	L.append("")
	L.append("A family may impose a floor of its own, and the higher of the two is compiled:")
	L.append("")
	for family in EvTuning.FAMILY_SUBJECT_TENURE:
		L.append("- `%s` — %d weeks" % [family, EvTuning.FAMILY_SUBJECT_TENURE[family]])
	L.append("")
	L.append("### `family` — the brake the card pays")
	L.append("")
	L.append("Another card from the same family waits out the gap (§13.3 layer 1b); with")
	L.append("`family_subject` the family also waits per person or account (layer 2b). The families")
	L.append("the catalogue already uses, and the gap each pays:")
	L.append("")
	L.append("| family | gap (weeks) | cards |")
	L.append("|---|---|---|")
	var families: Dictionary = {}
	for id in EvCatalog.card_ids():
		var card: Dictionary = EvCatalog.card(id)
		# The same exemption the linter's §17.13 grants: a fixture is reachable only from a shot
		# and a retired card from no week at all, so neither is a family an author may reach for.
		if String(card.get("version_scope", "demo")) in ["fixture", "retired"]:
			continue
		var family: String = String(card.get("family", ""))
		if family != "":
			families[family] = int(families.get(family, 0)) + 1
	var family_keys: Array = families.keys()
	family_keys.sort()
	for family: String in family_keys:
		L.append("| `%s` | %d | %d |" % [family, EvTuning.family_gap(family), families[family]])
	L.append("")
	L.append("A family absent from `EvTuning.FAMILY_GAP_WEEKS` pays the default, %d weeks."
		% EvTuning.FAMILY_GAP_WEEKS_DEFAULT)
	L.append("")
	L.append("### `speaker_role` · `stage` · `pool_group` — the sprint paper")
	L.append("")
	L.append("A card listed in sprint.json `decision.cards` is a sprint paper, asked for at most once a sprint for one of the")
	L.append("sprint's cards. `speaker_role` (%s) is the role of whoever speaks it: the engine binds the" % ", ".join(
		EvLint.PAPER_SPEAKERS.map(func(r: String) -> String: return "`%s`" % r)))
	L.append("person who works the card at `stage` (%s; `any` is any phase) to the card's `employee` slot, or" % ", ".join(
		EvLint.PAPER_STAGES.map(func(s: String) -> String: return "`%s`" % s)))
	L.append("to its `founder` slot for the founder's own note, and a card nobody of that role works is not asked for.")
	L.append("`speaker_role` may be a list of roles: the first person working the card with any of them speaks.")
	L.append("A `product_manager` paper is spoken by the quarter's PM and is about a planned customer request card: its")
	L.append("`customer` slot is the request's account. `pool_group` (%s) counts the paper in the" % ", ".join(
		EvLint.PAPER_GROUPS.map(func(g: String) -> String: return "`%s`" % g)))
	L.append("pool. A paper carries `latch: {cooldown_weeks: 52, max_fires: 3}` (the two stack); a card with no")
	L.append("`speaker_role` is spoken by no one.")
	L.append("A paper's `customer` slot may take `select: line_top | line_warehouse | line_newest | line_slow | request` (an account of")
	L.append("the decision card's line, SprintCatalog.paper_account) and a second `employee` slot `select: sprint_dev` (a developer of")
	L.append("the sprint's team); an option that fits one market only is a card of its own (`_b2c`), since a locked option is never hidden.")
	L.append("")
	L.append("### `select` — how a slot picks its entity")
	L.append("")
	L.append("A slot's `select` names a selector its type answers to (any other name is a build error, §17.12); `%s` binds only" % EvScope.ASKED)
	L.append("what the requester names. A name ending in `:` takes a parameter (`market_rival:giant`). `random` draws by a")
	L.append("hash of the day, the card and the slot: the same day binds the same entity, and a rival is drawn from the")
	L.append("player's market. A slot with no `select` takes the first free entity by id.")
	L.append("")
	L.append("| slot type | selectors |")
	L.append("|---|---|")
	for slot_type in EvScope.SELECTORS:
		L.append("| `%s` | %s |" % [slot_type, ", ".join((EvScope.SELECTORS[slot_type] as Array).map(
			func(name: String) -> String: return "`%s`" % name))])
	L.append("")
	L.append("### The window, the immunity and the demo's reach")
	L.append("")
	L.append("- `delay_weeks: [N, M]` — the week the condition first holds arms a window and the")
	L.append("  card is a candidate `N..M` weeks later (§27.19). `[0, 0]` needs a `delay_reason`.")
	L.append("- A condition un-held for more than %d weeks running throws its window away."
		% EvTuning.DISARM_WEEKS)
	L.append("- The pool is silent for the first %d weeks (§27.21); the quiet floor, requests,"
		% EvTuning.START_IMMUNITY_WEEKS)
	L.append("  arc steps, `system` cards and the `tutorial` / `terminal_warning` tags are exempt.")
	L.append("- `min_week` past week %d is a warning: the demo never reaches it."
		% EvLint.DEMO_WINDOW_WEEKS)
	L.append("")

	# --- who may write a verb -----------------------------------------------
	L.append("## f · Who may write each verb")
	L.append("")
	L.append("Section a groups verbs by the ORIGIN that may run them. This groups them by")
	L.append("AUTHORITY, which is the linter's §17.14: a verb is writable only when it has a")
	L.append("working arm in `EvEffects._apply` AND a chip in `EvChips`, so what an option promises")
	L.append("is what the player is shown and what lands.")
	L.append("")
	L.append("### Writer verbs (%d) — any card, inside the two rules below"
		% EvLint.WRITER_VERBS.size())
	L.append("")
	for verb in EvLint.WRITER_VERBS:
		L.append("- `%s`" % verb)
	L.append("")
	L.append("Two rules narrow the list. A `sprint_card_*` verb belongs to a `tick: request` sprint")
	L.append("decision and to no other card (§17.14, V3). A module verb spends a page the build may")
	L.append("not have opened: never in a demo card, and past the demo only in an option whose")
	L.append("`requires` names the module as open (§17.15, O5).")
	L.append("")
	for verb in EvLint.MODULE_VERBS:
		L.append("- `%s` — needs `build.module_unlocked.%s`"
			% [verb, EvLint.MODULE_VERBS[verb]])
	L.append("")
	L.append("### Reserved (%d) — a `system` card only" % EvLint.SYSTEM_VERBS.size())
	L.append("")
	L.append("Each moves the run itself — a phase, a table, an arc, an ending — so a story card")
	L.append("reaching for one would be deciding the run instead of colouring it.")
	L.append("")
	for verb in EvLint.SYSTEM_VERBS:
		L.append("- `%s`" % verb)
	L.append("")
	var unwritable: Array = []
	for verb in EvEffects.NEUTRAL_VERBS + EvEffects.ECONOMIC_VERBS + EvEffects.TERMINAL_VERBS:
		if not EvLint.WRITER_VERBS.has(verb) and not EvLint.SYSTEM_VERBS.has(verb):
			unwritable.append(verb)
	L.append("### Not writable (%d) — no working arm or no chip" % unwritable.size())
	L.append("")
	L.append("The executor dispatches these, so they are not unknown names; they are names a card")
	L.append("may not say. A draft that wants one writes `[VOCAB?]` and §21's DELTA workflow.")
	L.append("")
	for verb in unwritable:
		L.append("- `%s`" % verb)
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
		% [OUT_PATH, EvSeams.all_names().size(), verb_count, EvCatalog.card_ids().size()])
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


## A compiled leaf list, as the condition an author would have written by hand.
static func _leaves(leaves: Array) -> String:
	var parts: PackedStringArray = []
	for leaf: Dictionary in leaves:
		parts.append("`%s %s %s`" % [leaf["seam"], leaf["op"], leaf["value"]])
	return " ∧ ".join(parts)


static func _kept_placeholder() -> String:
	return ("\n## g · Hand-written notes\n\n"
		+ "This block survives regeneration: editorial notes nobody would reconstruct from\n"
		+ "source, such as the list of **known gaps** the engine has not closed.\n")


static func _type_name(t: int) -> String:
	match t:
		TYPE_INT: return "int"
		TYPE_FLOAT: return "float"
		TYPE_STRING: return "string"
		TYPE_BOOL: return "bool"
	return "?"
