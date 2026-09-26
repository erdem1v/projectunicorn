class_name EvLint
extends RefCounted

# THE CONTENT LINTER (GDD §17). Every rule class the spec names, plus three the build added.
#
#     godot --headless --path . --event-lint
#
# Exit 0 when clean or when every finding is baselined; exit 1 on a new E; exit 0 with a
# printed tally on W.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# WHY A LINTER IS THE LOAD-BEARING TOOL HERE
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# Four of the seven invariants were specified as lint-enforced. Two of those (I2, I6) were made
# structural during the build because lint could not cover them — `open_negotiation` returns an
# effect list that does not exist at build time, and a sign rule cannot be checked against a
# seam-derived amount. The rest genuinely belong here: I5 (a trigger never moves into GDScript)
# and I7 (no modifier line without a seam) are statements about CONTENT, and content is what
# this reads.
#
# The thing a linter buys that a runtime check cannot: it fails on the card nobody has played
# yet. §17.2's reachability rules exist because the expensive bug in an event system is not the
# card that misbehaves, it is the card that silently never fires — and that one has no runtime
# symptom at all.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# THE BASELINE (§17.10)
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# Known and accepted findings live in lint_baseline.json; only NEW findings break the build.
# §17.10 gives the reason in one sentence: otherwise the team learns to ignore the linter. The
# project already runs this pattern twice — `LOC_EVENT_EN_PENDING` was a ratchet that could only
# fall (endgame_smoke.gd:25-27), and `loc_residue.gd` takes per-line opt-outs that each carry a
# written reason. A baseline entry here is a fingerprint, not a rule suppression: change the
# card and the fingerprint changes and the finding comes back.

const BASELINE_PATH := "res://tools/lint_baseline.json"

const SEVERITY_ERROR := "E"
const SEVERITY_WARN := "W"

## §17.8: real trademarks are a RELEASE BLOCKER, not a style note. GDD v2 ch.14 §6 lists them
## under "Cut / never". Two sweeps have already run (company_catalog.gd:23-25,
## rival_catalog.gd:34-41); this stops the next one being needed.
const FORBIDDEN_TERMS := [
	"asana", "stripe", "slack", "product hunt", "producthunt", "notion", "figma",
	"jira", "trello", "salesforce", "hubspot", "zendesk", "intercom", "datadog",
	"github", "gitlab", "atlassian", "shopify", "twilio", "segment", "amplitude",
	"mixpanel", "airtable", "miro", "linear", "vercel", "netlify", "supabase",
	"y combinator", "techcrunch", "sequoia", "andreessen", "a16z",
]

## §17.8 bans the dash in card bodies. The reason is editorial: the em dash is the tic this
## project's prose falls into, and banning it forces the sentence to be rewritten rather than
## hinged.
const DASH_CHARS := ["—", "–"]

## §17.8: a daily-tick card may not assert a clock. Deterministic beats fire at the day
## boundary, so "· 13:05" on one of them is a lie the player can check against the TopBar —
## and exactly that once shipped on the first screen of the game.
const CLOCK_RE := "[0-2]?[0-9][:.][0-5][0-9]"

static var _findings: Array = []
static var _baseline: Dictionary = {}


# --- Entry point -----------------------------------------------------------

## Returns true when nothing new broke.
static func run(write_baseline: bool = false) -> bool:
	_findings.clear()
	_load_baseline()
	EvCatalog.reload()
	EvSeams.ensure_installed()

	for err in EvCatalog.load_errors():
		_add(SEVERITY_ERROR, "17.1", String((err as Dictionary)["path"]),
			String((err as Dictionary)["message"]))

	for id in EvCatalog.card_ids():
		_lint_card(id, EvCatalog.card(id))
	for arc_id in EvCatalog.arc_ids():
		_lint_arc(arc_id, EvCatalog.arc(arc_id))

	_lint_reachability()
	_lint_signals()
	_lint_gdscript_triggers()

	if write_baseline:
		_write_baseline()
		return true
	return _report()


# --- Per-card rules --------------------------------------------------------

static func _lint_card(id: String, card: Dictionary) -> void:
	var where: String = String(card.get("_path", id))

	# §17.1 structure ------------------------------------------------------
	if not id.contains("."):
		_add(SEVERITY_WARN, "17.1", where,
			"id '%s' has no namespace; §3.1 wants category.name" % id)
	if String(card["class"]) not in ["interrupt", "paper", "info", "ambient"]:
		_add(SEVERITY_ERROR, "17.1", where, "unknown class '%s'" % card["class"])
	if String(card["tick"]) not in ["daily", "hourly", "scheduled", "signal", "request"]:
		_add(SEVERITY_ERROR, "17.1", where, "unknown tick '%s'" % card["tick"])
	if not EvTuning.CATEGORY_QUOTA_7D.has(String(card["category"])):
		_add(SEVERITY_WARN, "17.1", where,
			"category '%s' has no quota row; it will fall to the default" % card["category"])

	for tree in _trees_of(card):
		_lint_condition(where, tree as Dictionary)

	# §17.7 paper ----------------------------------------------------------
	var is_paper: bool = String(card["class"]) == "paper"
	# ONE definition, and it lives with the governor that applies it. This used to test only
	# the `critical` tag, which meant every arc-step interrupt was asked for an expiry trio for
	# a demotion §13.5 forbids the governor from performing on it.
	var demotable: bool = String(card["class"]) == "interrupt" \
		and not EvTempo.budget_exempt(card)
	if is_paper or demotable:
		# The GDD does not cover the second half of this. §13.2 demotes
		# interrupt → paper when the day's budget is spent; §3.1 says expires_days is
		# paper-only; §17.7 makes a paper without one an error. So the demotion path
		# manufactures a card the linter would have rejected. Any interrupt that CAN be
		# demoted must therefore carry the paper trio too.
		var why: String = "class: paper" if is_paper else "a demotable interrupt (§13.2)"
		if not card.has("expires_days"):
			_add(SEVERITY_ERROR, "17.7", where, "%s without expires_days" % why)
		if not card.has("on_expire"):
			_add(SEVERITY_ERROR, "17.7", where, "%s without on_expire" % why)
		if String(card.get("expire_note", "")) == "":
			_add(SEVERITY_ERROR, "17.7", where,
				"%s without expire_note — §12.4 forbids a silent expiry" % why)

	# An arc step that can expire must MOVE its arc, or a payoff
	# demoted to paper and left unanswered stalls the arc for the rest of the run — §10.10's
	# silent death arriving through a door §10 never closed.
	if card.has("arc") and card.has("on_expire"):
		if not _has_arc_verb(card.get("on_expire", {}).get("penalties", [])):
			_add(SEVERITY_ERROR, "17.6", where,
				"arc step '%s' can expire but its on_expire carries no arc verb " % id
				+ "(advance_arc / end_arc / abort_arc) — the arc would stall silently")

	# §17.6 an arc step may never sit in the pool -------------------------
	if card.has("arc") and not (card["tags"] as Array).has("critical"):
		# The catalogue excludes arc steps from the pool structurally too. Both, because a rule
		# enforced in one place is a rule with one place to forget.
		if String(card["tick"]) in ["daily", "hourly"] and not card.has("trigger"):
			_add(SEVERITY_WARN, "17.6", where,
				"arc step '%s' has a pool-shaped tick; it is excluded structurally, "
				% id + "but tag it critical so the intent is on the page")

	_lint_options(id, card, where)
	_lint_text(id, card, where)


static func _lint_options(id: String, card: Dictionary, where: String) -> void:
	var options: Array = card.get("options", [])
	if options.is_empty():
		# What this costs at runtime: a modal that can
		# never be resolved, which blocks the queue permanently AND disables saving.
		_add(SEVERITY_ERROR, "17.1", where, "no options — the modal could never be dismissed")
		return

	var seen: Dictionary = {}
	for o in options:
		if typeof(o) != TYPE_DICTIONARY:
			_add(SEVERITY_ERROR, "17.1", where, "an option is not an object")
			continue
		var opt: Dictionary = o
		var opt_id: String = String(opt.get("id", ""))
		if opt_id == "":
			_add(SEVERITY_ERROR, "17.1", where, "an option has no id")
			continue
		if seen.has(opt_id):
			_add(SEVERITY_ERROR, "17.1", where, "duplicate option id '%s'" % opt_id)
		seen[opt_id] = true

		if opt.has("requires"):
			_lint_condition(where, opt["requires"] as Dictionary)
			# §17.8: a lockable option must be able to say WHY it is locked. §3.3 is emphatic
			# that a locked option is shown greyed with its reason, never hidden — so a lock
			# with no reason line renders a dead row the player cannot interpret.
			if not _text_has(card, "locked_reasons", opt_id):
				_add(SEVERITY_ERROR, "17.8", where,
					"option '%s' can lock but has no locked_reasons entry" % opt_id)

		_lint_effects(where, opt.get("effects", []), "option", card)

		# §17.11 / I7 — the dice ------------------------------------------
		if opt.has("check"):
			var check: Dictionary = opt["check"]
			var odds_seam: String = String(check.get("odds_seam", ""))
			if odds_seam == "":
				_add(SEVERITY_ERROR, "17.5", where, "option '%s' has a check with no odds_seam" % opt_id)
			elif not EvSeams.has(odds_seam):
				_add(SEVERITY_ERROR, "17.1", where, "unknown odds_seam '%s'" % odds_seam)
			if not _text_block(card, "tr").has("modifier_lines"):
				_add(SEVERITY_ERROR, "17.11", where,
					"option '%s' rolls a check but the card declares no modifier_lines — " % opt_id
					+ "I7: no seam, no modifier, and a naked percentage is a blind decision")
			_lint_effects(where, check.get("on_pass", []), "check", card)
			_lint_effects(where, check.get("on_fail", []), "check", card)

	if card.has("on_expire"):
		_lint_effects(where, card.get("on_expire", {}).get("penalties", []), "expire", card)


## §17.3 (I2), §17.4 (I3), §17.5 (I6) — the same walk, judged by where the list lives.
static func _lint_effects(where: String, effects: Array, context: String, card: Dictionary) -> void:
	for e in effects:
		if typeof(e) != TYPE_DICTIONARY:
			_add(SEVERITY_ERROR, "17.1", where, "an effect is not an object")
			continue
		var effect: Dictionary = e
		var verb: String = String(effect.get("verb", ""))

		if not (EvEffects.NEUTRAL_VERBS.has(verb) or EvEffects.ECONOMIC_VERBS.has(verb)
				or EvEffects.TERMINAL_VERBS.has(verb)):
			_add(SEVERITY_ERROR, "17.1", where, "unknown effect verb '%s'" % verb)
			continue

		var economic: bool = EvEffects.ECONOMIC_VERBS.has(verb)
		var terminal: bool = EvEffects.TERMINAL_VERBS.has(verb)

		match context:
			"expire":
				if economic and float(effect.get("amount", effect.get("delta", -1))) > 0.0:
					_add(SEVERITY_ERROR, "17.3", where,
						"I2: on_expire applies a POSITIVE '%s' — an expiry is a cost" % verb)
				if terminal:
					_add(SEVERITY_ERROR, "17.4", where, "I3: an expiry may not end the run")
			"check":
				if terminal:
					_add(SEVERITY_ERROR, "17.5", where,
						"I6: a check branch may not end the run")
			"ambient":
				if economic:
					_add(SEVERITY_ERROR, "17.3", where,
						"I2: '%s' needs a played decision, not an ambient context" % verb)

		# §17.3's third clause: a quiet-pool card may carry no economic weight at all. The
		# floor exists to fill dead air, and dead air that pays is not dead air.
		if economic and (card.get("tags", []) as Array).has("quiet"):
			_add(SEVERITY_ERROR, "17.3", where,
				"a tag:quiet card carries '%s'; the quiet pool has no economy" % verb)

		# AND ITS FOURTH, which only a linter can see. The executor's origin tables are the
		# wall for I2, but they are keyed on WHERE the effect list came from — an option's
		# effects always run as `played`, whatever the card's class. An `ambient` card is a
		# ticker line: the player never answers it, so an option on one is never played, so a
		# payment on that option is money with no decision upstream. The executor cannot tell;
		# it sees an option list like any other. This is the one half of I2 that has to be lint.
		if economic and String(card["class"]) == "ambient":
			_add(SEVERITY_ERROR, "17.3", where,
				"I2: a class:ambient card carries '%s' — an ambient card is a ticker " % verb
				+ "line, so its options are never played and its money has no decision")

		# §17.4 — the telegraph must exist AND be nameable.
		if terminal or bool(effect.get("is_loss_risk", false)):
			var telegraph: String = String(effect.get("requires_telegraph", ""))
			if telegraph == "":
				_add(SEVERITY_ERROR, "17.4", where,
					"I3: '%s' declares no requires_telegraph" % verb)
			elif not EvCatalog.has_card(telegraph) and not telegraph.begins_with("flag:"):
				_add(SEVERITY_WARN, "17.4", where,
					"telegraph '%s' is neither a card id nor a flag: reference" % telegraph)

		# §17.1 — a referenced id must exist.
		if verb == "schedule_event" and not EvCatalog.has_card(String(effect.get("event_id", ""))):
			_add(SEVERITY_ERROR, "17.1", where,
				"schedule_event names unknown card '%s'" % effect.get("event_id", ""))
		if verb in ["start_arc", "advance_arc", "end_arc", "abort_arc", "set_arc_var"]:
			if not EvCatalog.has_arc(String(effect.get("arc_id", ""))):
				_add(SEVERITY_ERROR, "17.1", where,
					"%s names unknown arc '%s'" % [verb, effect.get("arc_id", "")])


# --- §17.8 text ------------------------------------------------------------

static func _lint_text(id: String, card: Dictionary, where: String) -> void:
	var text: Dictionary = card.get("text", {})
	for locale in ["tr", "en"]:
		if not text.has(locale):
			_add(SEVERITY_ERROR, "17.8", where, "no '%s' text block" % locale)
	if not (text.has("tr") and text.has("en")):
		return

	var tr_block: Dictionary = text["tr"]
	var en_block: Dictionary = text["en"]

	# Language parity. The two blocks must carry the SAME id sets, or a locale switch mid-run
	# turns an option into a blank row — and §3.2 explicitly allows a mid-run switch.
	for key in ["options", "locked_reasons", "modifier_lines", "outcome_lines"]:
		var a: Array = (tr_block.get(key, {}) as Dictionary).keys()
		var b: Array = (en_block.get(key, {}) as Dictionary).keys()
		a.sort()
		b.sort()
		if a != b:
			_add(SEVERITY_ERROR, "17.8", where,
				"'%s' id sets differ between tr and en: %s vs %s" % [key, str(a), str(b)])

	# I7 both ways: a modifier label must name a registered seam, and the check that renders it
	# must actually contribute that seam. The second half cannot be checked here — contributions
	# are runtime — so the linter does the half it can and the runtime drops unlabelled ones.
	for seam_name in (tr_block.get("modifier_lines", {}) as Dictionary):
		if not EvSeams.has(String(seam_name)):
			_add(SEVERITY_ERROR, "17.11", where,
				"modifier_lines names '%s', which is not a registered seam. " % seam_name
				+ "I7: no seam, no modifier — open the seam first, which is a design decision")
	if (tr_block.get("modifier_lines", {}) as Dictionary).size() > 4:
		_add(SEVERITY_WARN, "17.11", where,
			"more than four modifier_lines; §9.6 shows four and folds the rest")

	for locale in ["tr", "en"]:
		var block: Dictionary = text[locale]
		# A BODY MAY BE A VARIANT SET, and this line used to assume it never was.
		# `String(dict)` has no constructor in Godot 4, so a {by_seam, variants} body threw
		# "Nonexistent 'String' constructor" and ABORTED _lint_text — which means the dash
		# ban and the trademark check silently stopped running for exactly the cards that
		# carry the most text. funding.gate_series_a has been in that hole since variant
		# bodies landed. _body_strings flattens both shapes, so every arm is checked.
		var body: String = " ".join(PackedStringArray(_body_strings(block)))
		for dash in DASH_CHARS:
			if body.contains(dash):
				_add(SEVERITY_ERROR, "17.8", where, "[%s] body contains a dash" % locale)
				break

		var lowered: String = (body + " " + String(block.get("title", ""))).to_lower()
		for term in FORBIDDEN_TERMS:
			if lowered.contains(term):
				_add(SEVERITY_ERROR, "17.8", where,
					"[%s] names the real trademark '%s' — RELEASE BLOCKER" % [locale, term])

		# §17.8 / D7: a daily beat fires at the day boundary, so a clock on one is a claim the
		# TopBar contradicts 40 pixels away.
		if String(card["tick"]) == "daily":
			var subtitle: String = String(block.get("subtitle", ""))
			var re := RegEx.new()
			re.compile(CLOCK_RE)
			if re.search(subtitle) != null or re.search(body) != null:
				_add(SEVERITY_ERROR, "17.8", where,
					"[%s] a tick:daily card asserts a clock; daily beats fire at hour 0" % locale)

		if body.length() > 900:
			_add(SEVERITY_WARN, "17.8", where,
				"[%s] body is %d chars; the card panel is 780x420" % [locale, body.length()])


# --- §17.6 arcs ------------------------------------------------------------

static func _lint_arc(arc_id: String, arc: Dictionary) -> void:
	var where: String = String(arc.get("_path", arc_id))
	var arc_type: String = String(arc.get("type", ""))
	if arc_type not in [EvArcs.TYPE_PROMISE, EvArcs.TYPE_CHARACTER, EvArcs.TYPE_WORLD,
			EvArcs.TYPE_ASSIGNMENT]:
		_add(SEVERITY_ERROR, "17.6", where, "unknown arc type '%s'" % arc_type)

	var on_inv: Dictionary = arc.get("on_invalidate", {})
	var policy: String = String(on_inv.get("policy", ""))

	if arc_type == EvArcs.TYPE_PROMISE:
		# §10.6 / I-ARK. The reasoning is the thesis itself: if something promised evaporates
		# quietly the player reads it as a bug, and the trust the arc was built to earn goes
		# with it.
		if policy == EvArcs.POLICY_FADE:
			_add(SEVERITY_ERROR, "17.6", where,
				"a promise arc may not fade — §10.6")
		if (on_inv.get("penalties", []) as Array).is_empty():
			_add(SEVERITY_ERROR, "17.6", where,
				"a promise arc may not carry empty on_invalidate penalties — §10.6")

	if policy == EvArcs.POLICY_REASSIGN:
		# The 14-day timeout falls to close, and close fires a DIFFERENT card from the reassign
		# prompt. Declaring only one of them leaves the timeout with nothing to show.
		if String(on_inv.get("reassign_event", "")) == "":
			_add(SEVERITY_ERROR, "17.6", where, "policy reassign without a reassign_event")
		if String(on_inv.get("close_event", "")) == "":
			_add(SEVERITY_ERROR, "17.6", where,
				"policy reassign without a close_event — the 14-day timeout falls to close "
				+ "and would have nothing to fire")

	var steps: Array = arc.get("steps", [])
	if steps.is_empty():
		_add(SEVERITY_ERROR, "17.6", where, "an arc with no steps")
	for step in steps:
		var step_id: String = String((step as Dictionary).get("event_id", ""))
		if not EvCatalog.has_card(step_id):
			_add(SEVERITY_ERROR, "17.1", where, "step names unknown card '%s'" % step_id)
		elif String((EvCatalog.card(step_id) as Dictionary).get("arc", "")) != arc_id:
			_add(SEVERITY_WARN, "17.6", where,
				"card '%s' is a step of this arc but does not name it back" % step_id)

	# §10.4: an arc with a subject must say what happens when the subject leaves. An empty
	# invalidate_when is not "never invalidates" — it is "nobody thought about it".
	var has_subject_step: bool = false
	for step in steps:
		var sid: String = String((step as Dictionary).get("event_id", ""))
		if EvCatalog.has_card(sid) and not (EvCatalog.card(sid).get("scope", {}) as Dictionary).is_empty():
			has_subject_step = true
	if has_subject_step and (arc.get("invalidate_when", []) as Array).is_empty():
		_add(SEVERITY_ERROR, "17.6", where,
			"this arc has subject-scoped steps but declares no invalidate_when — §10.4")

	if int(arc.get("nesting_depth", 1)) > EvTuning.ARC_MAX_NESTING:
		_add(SEVERITY_ERROR, "17.6", where, "nesting deeper than %d" % EvTuning.ARC_MAX_NESTING)


# --- §17.2 reachability ----------------------------------------------------

static func _lint_reachability() -> void:
	# The expensive bug in an event system is the card that silently never fires. It has no
	# runtime symptom at all, so this is the only place it can be caught.
	var referenced: Dictionary = {}
	for arc_id in EvCatalog.arc_ids():
		for step in (EvCatalog.arc(arc_id).get("steps", []) as Array):
			referenced[String((step as Dictionary).get("event_id", ""))] = true
		var inv: Dictionary = EvCatalog.arc(arc_id).get("on_invalidate", {})
		referenced[String(inv.get("reassign_event", ""))] = true
		referenced[String(inv.get("close_event", ""))] = true
	for id in EvCatalog.card_ids():
		for tree in _trees_of(EvCatalog.card(id)):
			pass
		for o in (EvCatalog.card(id).get("options", []) as Array):
			for e in ((o as Dictionary).get("effects", []) as Array):
				if typeof(e) == TYPE_DICTIONARY and String((e as Dictionary).get("verb", "")) == "schedule_event":
					referenced[String((e as Dictionary).get("event_id", ""))] = true

	for id in EvCatalog.card_ids():
		var card: Dictionary = EvCatalog.card(id)
		var has_trigger: bool = card.has("trigger") or card.has("condition")
		var is_pool: bool = not card.has("arc") and not (card["tags"] as Array).has("critical")
		# A `tick: request` card is reached by a SYSTEM naming its id — that is its whole
		# contract. Reachability for it is therefore a question about the code, and the same
		# static scan that finds the deleted admission API can answer it. A request card that
		# nothing names IS unreachable, and this still says so.
		if String(card["tick"]) == "request" and not _grep_scripts('"%s"' % id).is_empty():
			continue
		if not has_trigger and not is_pool and not referenced.has(id):
			_add(SEVERITY_WARN, "17.2", String(card.get("_path", id)),
				"'%s' has no trigger, is not in the pool, and nothing references it — "
				% id + "it can never fire")

	# An arc nobody starts.
	var started: Dictionary = {}
	for id in EvCatalog.card_ids():
		for o in (EvCatalog.card(id).get("options", []) as Array):
			for e in ((o as Dictionary).get("effects", []) as Array):
				if typeof(e) == TYPE_DICTIONARY and String((e as Dictionary).get("verb", "")) == "start_arc":
					started[String((e as Dictionary).get("arc_id", ""))] = true
	for arc_id in EvCatalog.arc_ids():
		if not started.has(arc_id):
			_add(SEVERITY_WARN, "17.2", String(EvCatalog.arc(arc_id).get("_path", arc_id)),
				"arc '%s' is never started by any card" % arc_id)


static func _lint_condition(where: String, tree: Dictionary) -> void:
	if tree.is_empty():
		return
	# §17.2: an unreachable condition. all:[flag X, flag_unset X] can never be true, and the
	# card it gates is dead content that looks alive.
	var set_flags: Dictionary = {}
	var unset_flags: Dictionary = {}
	for leaf in EvCondition.leaves(tree):
		var d: Dictionary = leaf
		if d.has("flag"):
			set_flags[String(d["flag"])] = true
		if d.has("flag_unset"):
			unset_flags[String(d["flag_unset"])] = true
		if d.has("seam") and not EvSeams.has(String(d["seam"])):
			_add(SEVERITY_ERROR, "17.1", where, "unknown seam '%s'" % d["seam"])
		if d.has("entity_seam") and not EvSeams.has(String(d["entity_seam"])):
			_add(SEVERITY_ERROR, "17.1", where, "unknown entity_seam '%s'" % d["entity_seam"])
		if d.has("history") and d.has("event") and not EvCatalog.has_card(String(d["event"])):
			_add(SEVERITY_ERROR, "17.1", where,
				"a history leaf names unknown card '%s'" % d["event"])
		if d.has("arc") and not EvCatalog.has_arc(String(d.get("id", ""))):
			_add(SEVERITY_ERROR, "17.1", where, "an arc leaf names unknown arc '%s'" % d.get("id", ""))
	for f in set_flags:
		if unset_flags.has(f):
			_add(SEVERITY_ERROR, "17.2", where,
				"unreachable: the tree requires flag '%s' to be both set and unset" % f)


# --- §17.1 / §15.2 signals -------------------------------------------------

static func _lint_signals() -> void:
	for id in EvCatalog.card_ids():
		var trigger: Dictionary = EvCatalog.card(id).get("trigger", {})
		var signal_name: String = String(trigger.get("signal", ""))
		if signal_name == "":
			continue
		if not EventBus.has_signal(signal_name):
			_add(SEVERITY_ERROR, "17.1", String(EvCatalog.card(id).get("_path", id)),
				"trigger names signal '%s', which EventBus does not declare" % signal_name)


# --- §17.1 / I5 the static scan --------------------------------------------

static func _lint_gdscript_triggers() -> void:
	# I5 in its enforceable form. "A hardcoded trigger" has no syntactic signature, so this
	# cannot find one in general — but it CAN find the shape that produces them: a system
	# reaching into the engine to fire a card itself. After the migration there is exactly one
	# legal admission verb, and any other call is the violation.
	var offenders: Array = _grep_scripts("EventManager.enqueue")
	for site in offenders:
		_add(SEVERITY_ERROR, "17.9", String(site),
			"enqueue() is a deleted API — the single gate is EvGate.propose (§4.2)")


static func _grep_scripts(needle: String) -> Array:
	var hits: Array = []
	_walk_scripts("res://scripts", needle, hits)
	return hits


static func _walk_scripts(dir_path: String, needle: String, hits: Array) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		var full: String = dir_path.path_join(name)
		if dir.current_is_dir():
			if not name.begins_with("."):
				_walk_scripts(full, needle, hits)
		elif name.ends_with(".gd"):
			# The tools directory is where the needle is DEFINED. Scanning it would make the
			# rule report its own source line and nothing else — a linter that fails on a
			# clean tree is one nobody reads (§17.10).
			if full.begins_with("res://scripts/events/tools/"):
				name = dir.get_next()
				continue
			var f := FileAccess.open(full, FileAccess.READ)
			if f != null:
				var line_no: int = 0
				while not f.eof_reached():
					line_no += 1
					var line: String = f.get_line()
					if line.strip_edges().begins_with("#"):
						continue
					if line.contains(needle):
						hits.append("%s:%d" % [full, line_no])
		name = dir.get_next()
	dir.list_dir_end()


# --- Helpers ---------------------------------------------------------------

static func _trees_of(card: Dictionary) -> Array:
	var out: Array = []
	if typeof(card.get("condition", null)) == TYPE_DICTIONARY:
		out.append(card["condition"])
	var trigger: Dictionary = card.get("trigger", {})
	if typeof(trigger.get("condition", null)) == TYPE_DICTIONARY:
		out.append(trigger["condition"])
	return out


## Every body string a locale block can carry: the plain one, or every arm of a variant
## set. A key is returned as its key — the dash and trademark bans are about AUTHORED
## prose, and a CSV key is checked by the localization gates instead.
static func _body_strings(block: Dictionary) -> Array:
	var body: Variant = block.get("body", "")
	if typeof(body) == TYPE_DICTIONARY:
		var out: Array = []
		for v in (body as Dictionary).get("variants", {}).values():
			out.append(String(v))
		return out
	return [String(body)]


static func _text_block(card: Dictionary, locale: String) -> Dictionary:
	return (card.get("text", {}) as Dictionary).get(locale, {})


static func _text_has(card: Dictionary, group: String, key: String) -> bool:
	return (_text_block(card, "tr").get(group, {}) as Dictionary).has(key)


static func _has_arc_verb(effects: Array) -> bool:
	for e in effects:
		if typeof(e) == TYPE_DICTIONARY \
				and String((e as Dictionary).get("verb", "")) in ["advance_arc", "end_arc", "abort_arc"]:
			return true
	return false


static func _add(severity: String, rule: String, where: String, message: String) -> void:
	_findings.append({"severity": severity, "rule": rule, "where": where, "message": message})


static func _fingerprint(f: Dictionary) -> String:
	return "%s|%s|%s" % [f["rule"], f["where"], f["message"]]


# --- Baseline and reporting ------------------------------------------------

static func _load_baseline() -> void:
	_baseline = {}
	var f := FileAccess.open(BASELINE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		for fp in ((parsed as Dictionary).get("accepted", []) as Array):
			_baseline[String(fp)] = true


static func _write_baseline() -> void:
	var accepted: Array = []
	for f in _findings:
		accepted.append(_fingerprint(f as Dictionary))
	var payload: Dictionary = {
		"_comment": "Accepted lint findings, by fingerprint. A finding here does NOT suppress "
			+ "its rule: change the card and the fingerprint changes and it comes back. "
			+ "Regenerate with --event-lint-baseline. Every addition should be defensible.",
		"generated_day": Time.get_date_string_from_system(),
		"accepted": accepted,
	}
	var out := FileAccess.open(BASELINE_PATH, FileAccess.WRITE)
	out.store_string(JSON.stringify(payload, "\t"))
	out.close()
	print("[EvLint] baseline written: %d accepted finding(s)" % accepted.size())


static func _report() -> bool:
	var new_errors: Array = []
	var new_warns: Array = []
	var baselined: int = 0
	for f in _findings:
		var finding: Dictionary = f
		if _baseline.has(_fingerprint(finding)):
			baselined += 1
			continue
		if String(finding["severity"]) == SEVERITY_ERROR:
			new_errors.append(finding)
		else:
			new_warns.append(finding)

	for f in new_errors:
		print("  E  §%s  %s\n       %s" % [f["rule"], f["where"], f["message"]])
	for f in new_warns:
		print("  W  §%s  %s\n       %s" % [f["rule"], f["where"], f["message"]])

	print("LINT %s  %d error(s), %d warning(s), %d baselined, %d card(s), %d arc(s)"
		% ["FAIL" if not new_errors.is_empty() else "PASS",
			new_errors.size(), new_warns.size(), baselined,
			EvCatalog.card_ids().size(), EvCatalog.arc_ids().size()])
	return new_errors.is_empty()
