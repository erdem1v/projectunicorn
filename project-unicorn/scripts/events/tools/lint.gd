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
# §17.10 gives the reason in one sentence: otherwise the team learns to ignore the linter. A
# baseline entry is a fingerprint, not a rule suppression: change the card and the fingerprint
# changes and the finding comes back.

const BASELINE_PATH := "res://tools/lint_baseline.json"
const FROZEN_PATH := "res://tools/lint_v3_frozen.json"

const SEVERITY_ERROR := "E"
const SEVERITY_WARN := "W"

## §17.8: real trademarks are a RELEASE BLOCKER, not a style note. GDD v2 ch.14 §6 lists them
## under "Cut / never".
const FORBIDDEN_TERMS := [
	"asana", "stripe", "slack", "product hunt", "producthunt", "notion", "figma",
	"jira", "trello", "salesforce", "hubspot", "zendesk", "intercom", "datadog",
	"github", "gitlab", "atlassian", "shopify", "twilio", "segment", "amplitude",
	"mixpanel", "airtable", "miro", "linear", "vercel", "netlify", "supabase",
	"y combinator", "techcrunch", "sequoia", "andreessen", "a16z",
]

## §17.8 bans the dash in everything a card shows the player (title, subtitle, option labels, lock reasons,
## expire notes, every body variant). The reason is editorial: the em dash is the tic this project's prose
## falls into, and banning it forces the sentence to be rewritten rather than hinged.
const DASH_CHARS := ["—", "–"]

## The sprint paper's contract: who may speak (a character role), at which phase of the card they work (the sprint
## roles of `roles` in sprint.json) and the groups the pool is counted in.
const PAPER_SPEAKERS := [HRConstants.ROLE_PRODUCT_MANAGER, HRConstants.ROLE_DESIGNER, HRConstants.ROLE_DEVELOPER,
	HRConstants.ROLE_TESTER, HRConstants.ROLE_FOUNDER]
const PAPER_STAGES := ["any", "design", "dev", "test"]
const PAPER_GROUPS := ["pm", "designer", "developer", "tester", "no_tester", "solo", "system"]

## §17.8: a daily-tick card may not assert a clock. Deterministic beats fire at the day
## boundary, so "· 13:05" on one of them is a lie the player can check against the TopBar.
static var _clock_re: RegEx = RegEx.create_from_string("[0-2]?[0-9][:.][0-5][0-9]")
## A verb, a history form, a seam name: a value that is a name rather than prose.
static var _identifier_re: RegEx = RegEx.create_from_string("^[a-z0-9_.]+$")

static var _findings: Array = []
static var _baseline: Dictionary = {}
## Card ids on the frozen list, as a set.
static var _frozen: Dictionary = {}


# --- Entry point -----------------------------------------------------------

## Returns true when nothing new broke.
static func run(write_baseline: bool = false) -> bool:
	_findings.clear()
	_baseline = _load_id_set(BASELINE_PATH, "accepted")
	_frozen = _load_id_set(FROZEN_PATH, "cards")
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
	if card.has("sender") and String(card["sender"]) not in EvPresenter.SENDERS:
		_add(SEVERITY_ERROR, "17.1", where, "unknown sender '%s'" % card["sender"])
	if not EvTuning.CATEGORY_QUOTA_WEEK.has(String(card["category"])):
		_add(SEVERITY_WARN, "17.1", where,
			"category '%s' has no quota row; it will fall to the default" % card["category"])
	_lint_day_names(where, card)

	for tree in _trees_of(card):
		_lint_condition(where, tree as Dictionary)
	_lint_where(where, card)
	_lint_speaker(where, card)

	# §17.7 paper ----------------------------------------------------------
	var is_paper: bool = String(card["class"]) == "paper"
	# Every card that can wait carries its own wait, chosen for its situation; §12.2's table by
	# stakes is only the engine's fallback.
	if (is_paper or String(card["class"]) == "interrupt") and not card.has("expires_weeks"):
		_add(SEVERITY_ERROR, "17.7", where, "class: %s without expires_weeks" % card["class"])
	# Demotable is the governor's own definition, so an exempt interrupt is never asked for a
	# trio it can never need.
	var demotable: bool = String(card["class"]) == "interrupt" \
		and not EvTempo.budget_exempt(card)
	if is_paper or demotable:
		# §13.2 demotes interrupt → paper when the tick's budget is spent and §17.7 makes a
		# paper without the trio an error, so an interrupt that CAN be demoted carries it too.
		var why: String = "class: paper" if is_paper else "a demotable interrupt (§13.2)"
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
	_lint_v3(id, card, where)


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

		if not _engine_knows(verb):
			_add(SEVERITY_ERROR, "17.1", where, "unknown effect verb '%s'" % verb)
			continue

		var economic: bool = EvEffects.ECONOMIC_VERBS.has(verb)
		var terminal: bool = EvEffects.TERMINAL_VERBS.has(verb)

		match context:
			"expire":
				# A seam yields a magnitude, so its multiplier carries the sign.
				var figure: float = float(effect.get("amount", effect.get("delta", -1)))
				if effect.has("amount_seam"):
					figure = float(effect.get("amount_mult", 1.0))
				if economic and figure > 0.0:
					_add(SEVERITY_ERROR, "17.3", where,
						"I2: on_expire applies a POSITIVE '%s' — an expiry is a cost" % verb)
				if verb == "marketing_push":
					_add(SEVERITY_ERROR, "17.3", where,
						"I2: on_expire buys a marketing push — an expiry is a cost, not a purchase")
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
		if verb == "productivity_mod" and int(effect.get("pct", 0)) == 0:
			_add(SEVERITY_ERROR, "17.1", where, "productivity_mod names no pct; a pace row must move the pace")
		if effect.has("amount_seam") and (not EvSeams.has(String(effect["amount_seam"]))
				or EvSeams.kind_of(String(effect["amount_seam"])) != EvSeams.Kind.GLOBAL):
			_add(SEVERITY_ERROR, "17.1", where, "amount_seam '%s' is not a registered global seam"
				% effect["amount_seam"])
		if verb == "trust_delta":
			_lint_trust_delta(where, effect)
		if verb == "morale_crew" and String(effect.get("crew", "")) not in MORALE_CREWS:
			_add(SEVERITY_ERROR, "17.1", where, "morale_crew crew '%s' is not one of %s"
				% [effect.get("crew", ""), str(MORALE_CREWS)])
		# A card's cash is a line in the month's books and the transactions list, so it names a
		# label Finance can print.
		if verb == "add_cash" and not FinanceSystem.ONE_TIME_LABELS.has(String(effect.get("label", ""))):
			_add(SEVERITY_ERROR, "17.1", where,
				"add_cash has no known label ('%s'); FinanceSystem.ONE_TIME_LABELS lists them"
				% effect.get("label", ""))


## A `trust_delta` names whose ledger it writes, and a standing cost names its end.
static func _lint_trust_delta(where: String, effect: Dictionary) -> void:
	if String(effect.get("accounts", "slot")) not in TRUST_ACCOUNTS:
		_add(SEVERITY_ERROR, "17.1", where, "trust_delta accounts '%s' is not one of %s"
			% [effect.get("accounts", ""), str(TRUST_ACCOUNTS)])
	var until: Variant = effect.get("until")
	if effect.has("per_sprint") != (until != null):
		_add(SEVERITY_ERROR, "17.1", where, "trust_delta per_sprint and until come together")
	elif until != null and not (until is Dictionary and until.size() == 1
			and (until.has("line_cleared") or until.has("step_live"))):
		_add(SEVERITY_ERROR, "17.1", where, "trust_delta until is {line_cleared: line} or {step_live: step}")


# --- §17.13-17.15 schema v3 ------------------------------------------------
#
# Three rule families over a MIGRATED card: the plausibility block (§17.13), the effect
# vocabulary (§17.14) and the options (§17.15). A card with no `schema` gets P2 and nothing
# else — every other rule would be asking a v2 card about fields v2 never had.
#
# Content that never ships is exempt: a fixture exists to break a rule on purpose, and a retired
# card is kept only so an old save can read its own history.

## Which §17 subsection a rule belongs to, by its initial.
const RULE_FAMILY := {"P": "17.13", "C": "17.14", "V": "17.14", "O": "17.15", "T": "17.15"}

## Advisory for every card: a window the demo never reaches, and a claim the engine reads as
## neither true nor false because nothing evaluates it.
const V3_WARN_RULES := ["P3"]

## Rules the migration could not satisfy card by card. A warning on the frozen list, an error on
## anything written since.
const FROZEN_SOFT_RULES := ["O2", "O4", "O5", "T2", "T3"]

## What a `trust_delta` accounts and a `morale_crew` crew may name (EvEffects.trust_accounts, crew_of).
const TRUST_ACCOUNTS := ["slot", "decision_line", "promise", "second"]
const MORALE_CREWS := ["incident_crew", "card_crew", "promise_crew", "sprint_crew", "speaker"]

## V1: the verbs an author may write. Each has a working arm in EvEffects._apply AND a chip in
## EvChips, so what the option promises is what the player is shown and what lands.
const WRITER_VERBS := [
	"add_cash", "add_brand", "add_reputation", "customer_mrr_delta", "seats", "churn_customer",
	"audience_delta", "add_prospect", "employee_leaves", "b2b_retain_discount", "b2b_expand",
	"change_morale", "morale_all", "morale_crew", "satisfaction_delta", "trust_delta", "promise_create", "sprint_hours",
	"sprint_card_effort", "sprint_card_progress", "sprint_card_carry",
	"b2b_retain_delay", "b2b_retain_ignore", "b2b_expand_decline", "set_flag", "stamp_day",
	"schedule_event", "cancel_scheduled", "productivity_mod", "investor_strain", "marketing_push",
	"send_on_leave", "work_hours",
	"damage_product", "line_harden", "sprint_card_test", "sprint_fix_first",
	"sprint_card_trim", "sprint_card_outlook", "sprint_card_first", "b2b_month_discount",
]

## V2: reserved for a system card. Each moves the run itself — a phase, a table, an arc, an
## ending — so a story card reaching for one would be deciding the run instead of colouring it.
const SYSTEM_VERBS := [
	"advance_phase", "phase_gate_decline", "angel_accept", "open_term_table", "open_seed_table",
	"decline_offer", "decline_buyout", "trigger_ending", "mentor_advisory", "goto_tab",
	"unlock_content", "spend_budget", "set_game_flag", "start_arc", "advance_arc", "end_arc",
	"abort_arc", "set_arc_var", "incident", "promise_extend", "promise_break",
]

## O2: a chip whose CONSEQUENCE is the cost — the sprint carries the card over, the account is
## left waiting, the promise becomes a debt. Read here rather than off the chip, so a polarity
## edit cannot move the rule.
const CONSEQUENCE_VERBS := ["sprint_card_carry", "b2b_retain_delay", "b2b_retain_ignore",
	"b2b_expand_decline", "promise_create", "sprint_card_trim", "sprint_card_outlook", "sprint_card_first",
	"sprint_fix_first"]

## O4: the verbs that land on a subject, and the slot type each lands on.
const SUBJECT_VERBS := {
	"change_morale": "employee", "morale_crew": "employee", "productivity_mod": "employee", "employee_leaves": "employee",
	"send_on_leave": "employee", "work_hours": "employee",
	"satisfaction_delta": "customer", "trust_delta": "customer", "customer_mrr_delta": "customer", "seats": "customer",
	"churn_customer": "customer", "promise_create": "customer", "b2b_retain_discount": "customer",
	"b2b_retain_delay": "customer", "b2b_retain_ignore": "customer", "b2b_expand": "customer",
	"b2b_expand_decline": "customer",
}

## O5: a verb that spends a module the build may not have opened.
const MODULE_VERBS := {"marketing_push": "marketing"}

## P3: the demo's window in weeks. A card that cannot arrive inside it is content nobody plays.
const DEMO_WINDOW_WEEKS := 130

## T2: weeks before the same family may name the same person again.
const SUBJECT_FAMILY_COOLDOWN_WEEKS := 26

## T3: the newest hire still has to have been here this long to be worth a card.
const NEWEST_HIRE_TENURE_WEEKS := 8


static func _lint_v3(id: String, card: Dictionary, where: String) -> void:
	if String(card.get("version_scope", "demo")) in ["fixture", "retired"]:
		return
	if int(card.get("schema", 0)) != EvCatalog.SCHEMA_PLAUSIBILITY:
		_v3(id, "P2", where, "no schema field, so §3.1's plausibility block is missing")
		return
	_lint_v3_block(id, card, where)
	_lint_v3_verbs(id, card, where)
	_lint_v3_options(id, card, where)
	_lint_v3_repeats(id, card, where)


## P1, P3 — the block itself, and the chain it claims to hang from.
static func _lint_v3_block(id: String, card: Dictionary, where: String) -> void:
	var p: Dictionary = card.get("plausibility", {})
	var system: bool = bool(card.get("system", false))

	for field in ["phase_band", "headcount", "product", "modules", "min_week"]:
		if not p.has(field):
			_v3(id, "P1", where, "plausibility declares no '%s'" % field)
	if p.has("headcount") and (p["headcount"] as Array).size() != 2:
		_v3(id, "P1", where, "headcount is not [min, max]")
	if p.has("phase_band") and (p["phase_band"] as Array).is_empty():
		_v3(id, "P1", where, "phase_band is empty; a card lives in at least one band")
	for band in (p.get("phase_band", []) as Array):
		if EvCatalog.band_leaves(String(band)).is_empty():
			_v3(id, "P1", where, "unknown phase_band '%s'" % band)
	for module in (p.get("modules", []) as Array):
		if not UiTokens.TABS.any(func(row): return String(row.id) == String(module)):
			_v3(id, "P1", where, "modules names '%s', which is not a module page" % module)
	if String(card.get("family", "")) == "":
		_v3(id, "P1", where, "no family, so the family brake has nothing to hold")
	var product: String = String(p.get("product", "any"))
	if product != "any" and not EvCatalog.PRODUCT_LIVE.has(product):
		_v3(id, "P1", where, "unknown plausibility.product '%s'" % product)
	# Under "any" the compiler writes no urun.is_live leaf at all, so a guard beside it locks the
	# card where the block says it is free, whichever way the guard points.
	if (card["guards"] as Dictionary).has("product_live") \
			and (product == "any" or bool(card["guards"]["product_live"]) != (product == "live")):
		_v3(id, "P1", where, "plausibility.product is '%s' and guards.product_live is %s"
			% [product, card["guards"]["product_live"]])
	# A system card is handed its week and its subject, so neither the delay window nor the
	# seniority floor is asked of it (§3.1).
	if not system:
		if not card.has("delay_weeks"):
			_v3(id, "P1", where, "no delay_weeks; a story card arrives inside a window, "
				+ "not on the week its condition first held")
		elif int(card["delay_weeks"][0]) == 0 and int(card["delay_weeks"][1]) == 0 \
				and String(card.get("delay_reason", "")) == "":
			_v3(id, "P1", where, "delay_weeks [0,0] with no delay_reason")
		for slot in (card["scope"] as Dictionary):
			var spec: Dictionary = card["scope"][slot]
			if not spec.has("select") \
					or not EvCatalog.TENURE_SEAMS.has(String(spec.get("type", ""))):
				continue
			if not (p.has("subject_tenure_weeks")
					or (p.get("subject_tenure_by_slot", {}) as Dictionary).has(slot)):
				_v3(id, "P1", where, "slot '%s' picks its own subject but no subject_tenure_weeks "
					% slot + "says how long that subject has been here")
			elif EvCatalog.tenure_floor(card, slot) == 0 \
					and String(p.get("fresh_reason", "")) == "":
				_v3(id, "P1", where, "slot '%s' admits a brand new subject and no fresh_reason "
					% slot + "says why that is plausible")

	if int(p.get("min_week", 0)) > DEMO_WINDOW_WEEKS:
		_v3(id, "P3", where, "min_week %d is past the demo's %d weeks"
			% [int(p.get("min_week", 0)), DEMO_WINDOW_WEEKS])
	var trigger: Dictionary = card.get("trigger", {})
	if typeof(trigger.get("condition", null)) == TYPE_DICTIONARY \
			and not (trigger["condition"] as Dictionary).is_empty():
		_v3(id, "P3", where, "trigger.condition is never evaluated; the gate reads condition")

	if card.has("follows"):
		var parent: String = String(card["follows"])
		if not EvCatalog.has_card(parent):
			_v3(id, "P1", where, "follows names unknown card '%s'" % parent)
		elif not _is_chained(parent, id, card):
			_v3(id, "P1", where, "follows '%s', but that card never schedules this one and "
				% parent + "this card never reads its history")


## Is `parent` really upstream: does it schedule this card, or does this card read its history?
static func _is_chained(parent: String, id: String, card: Dictionary) -> bool:
	for o in (EvCatalog.card(parent).get("options", []) as Array):
		for e in ((o as Dictionary).get("effects", []) as Array):
			var effect: Dictionary = e
			if String(effect.get("verb", "")) == "schedule_event" \
					and String(effect.get("event_id", "")) == id:
				return true
	return not EvCondition.leaves_named(card.get("condition", {}), "event", parent).is_empty()


## C1, V1-V3 — who may say what.
static func _lint_v3_verbs(id: String, card: Dictionary, where: String) -> void:
	var system: bool = bool(card.get("system", false))
	var tags: Array = card["tags"]
	if tags.has("critical") and not system and not tags.has("terminal_warning"):
		_v3(id, "C1", where, "tag critical on a card that is neither system nor terminal_warning")

	for e in _card_effects(card):
		var verb: String = String((e as Dictionary).get("verb", ""))
		# An unrecognised verb is §17.1's finding; saying it twice helps nobody.
		if not _engine_knows(verb):
			continue
		if not WRITER_VERBS.has(verb) and not SYSTEM_VERBS.has(verb):
			_v3(id, "V1", where, "'%s' has no working arm or no chip, so it may not be written" % verb)
		elif SYSTEM_VERBS.has(verb) and not system:
			_v3(id, "V2", where, "'%s' is reserved for a system card" % verb)
		if verb.begins_with("sprint_card_") and String(card["tick"]) != "request":
			_v3(id, "V3", where, "'%s' belongs to a tick:request sprint decision" % verb)


## O1-O5 — every option is a real move, and it costs the subject something.
static func _lint_v3_options(id: String, card: Dictionary, where: String) -> void:
	var options: Array = card["options"]
	var slots: Dictionary = card["scope"]
	# O4 is asked of the slots a verb can reach and of no others: an investor or a prospect slot
	# has no subject verb at all, so the rule there would read "do not use that slot".
	var subject_types: Array = SUBJECT_VERBS.values()
	var subject_slots: Dictionary = {}
	for slot in slots:
		if subject_types.has(String((slots[slot] as Dictionary).get("type", ""))):
			subject_slots[slot] = slots[slot]
	# A system card is the run speaking, so it owes the player no price. A note owes none either,
	# and needs no clause here: its one option carries nothing, so it is O1's branch (C R5).
	var system: bool = bool(card.get("system", false))
	# One person's card: the founder alone, or a single named employee. Either way the team's
	# hours and the team's morale are not theirs to spend. A system card names a sender or an account to
	# speak with, not a subject it is about.
	var one_person: bool = not system and (String(card["category"]) == "founder"
		or _slots_of_type(slots, "employee").size() == 1)
	var scope: String = String(card.get("version_scope", "demo"))

	for o in options:
		var opt: Dictionary = o
		var opt_id: String = String(opt.get("id", ""))
		var effects: Array = _option_effects(opt)
		# An option with no effects and no dice is O1's finding, never O2's: it is not a free exit,
		# it is standing still.
		if (opt.get("effects", []) as Array).is_empty() and not opt.has("check"):
			if not system and options.size() > 1 \
					and String(opt.get("status_quo_reason", "")) == "":
				_v3(id, "O1", where, "option '%s' changes nothing and no status_quo_reason "
					% opt_id + "says why standing still is a move")
		elif not system and not _has_cost(effects):
			_v3(id, "O2", where, "option '%s' costs nothing; a free exit is not a choice" % opt_id)

		for e in effects:
			var effect: Dictionary = e
			var verb: String = String(effect.get("verb", ""))
			if one_person and (verb == "sprint_hours" or (verb in ["morale_all", "morale_crew"]
					and String(effect.get("crew", "")) != "speaker"
					and int(effect.get("amount", effect.get("delta", effect.get("value", 0)))) < 0)):
				_v3(id, "O3", where, "option '%s' spends the team's '%s' on a card about "
					% [opt_id, verb] + "one person")
			var module: String = String(MODULE_VERBS.get(verb, ""))
			if module == "":
				continue
			if scope == "demo":
				_v3(id, "O5", where, "option '%s' spends %s, which the demo never opens"
					% [opt_id, module])
			elif EvCondition.leaves_named(opt.get("requires", {}), "seam",
					"build.module_unlocked." + module).is_empty():
				_v3(id, "O5", where, "option '%s' spends %s without requiring the module to be open"
					% [opt_id, module])

		# A sprint paper names its speaker and the account it is about; its subject is the sprint card, which its
		# options land on, so the slots are not asked to be hit.
		if not system and not card.has("speaker_role") and not subject_slots.is_empty() \
				and _touched_slots(effects, subject_slots).is_empty():
			_v3(id, "O4", where, "option '%s' drops nothing on the subject the card is about" % opt_id)


## T1-T3 — the same card may not arrive at every hire, every week or on a stranger.
static func _lint_v3_repeats(id: String, card: Dictionary, where: String) -> void:
	if String((card.get("trigger", {}) as Dictionary).get("signal", "")) == "employee_hired":
		if bool((card["latch"] as Dictionary).get("one_shot", false)) \
				and String(card["latch_key"]) != EvLatches.KEY_ENTITY:
			_v3(id, "T1", where, "a run-scoped one_shot on employee_hired fires at the first "
				+ "hire and is silent at every hire after it")
		if EvCondition.leaves_named(card.get("condition", {}), "seam", "hr.run_hires").is_empty():
			_v3(id, "T1", where, "a card on employee_hired reads no hr.run_hires leaf, so it "
				+ "arrives at the tenth hire exactly as it did at the first")

	if not _slots_of_type(card["scope"], "employee").is_empty():
		var repeat: Dictionary = card.get("family_subject", {})
		if not bool(repeat.get("once", false)) \
				and int(repeat.get("cooldown_weeks", 0)) < SUBJECT_FAMILY_COOLDOWN_WEEKS:
			_v3(id, "T2", where, "a card about an employee needs family_subject once or a "
				+ "cooldown of at least %d weeks" % SUBJECT_FAMILY_COOLDOWN_WEEKS)

	for slot in (card["scope"] as Dictionary):
		if String((card["scope"][slot] as Dictionary).get("select", "")) != "newest_hire":
			continue
		var floor_weeks: int = EvCatalog.tenure_floor(card, slot)
		if floor_weeks < NEWEST_HIRE_TENURE_WEEKS:
			_v3(id, "T3", where, "slot '%s' picks the newest hire with a floor of %d weeks"
				% [slot, floor_weeks])


# --- §17.13-17.15 helpers --------------------------------------------------

static func _v3(card_id: String, rule: String, where: String, message: String) -> void:
	var warn: bool = V3_WARN_RULES.has(rule) \
		or (FROZEN_SOFT_RULES.has(rule) and _frozen.has(card_id))
	_add(SEVERITY_WARN if warn else SEVERITY_ERROR,
		String(RULE_FAMILY[rule.substr(0, 1)]), where, "%s: %s" % [rule, message])


## Every verb the executor dispatches, whatever origin may reach it.
static func _engine_knows(verb: String) -> bool:
	return EvEffects.NEUTRAL_VERBS.has(verb) or EvEffects.ECONOMIC_VERBS.has(verb) \
		or EvEffects.TERMINAL_VERBS.has(verb)


## Everything one option can run: the played list and both dice branches.
static func _option_effects(opt: Dictionary) -> Array:
	var out: Array = (opt.get("effects", []) as Array).duplicate()
	var check: Dictionary = opt.get("check", {})
	out.append_array(check.get("on_pass", []))
	out.append_array(check.get("on_fail", []))
	return out


## Every effect list a card carries, for the rules that ask about vocabulary rather than choice.
static func _card_effects(card: Dictionary) -> Array:
	var expiry: Dictionary = card.get("on_expire", {})
	var out: Array = (expiry.get("penalties", []) as Array).duplicate()
	for o in (card["options"] as Array):
		out.append_array(_option_effects(o as Dictionary))
	return out


## Does any of these effects cost the player something? EvChips owns polarity, so the rule reads
## the same part the card will draw — as a delta, because a linter has no run: that arm reads the
## figures the effect itself writes instead of asking the live sprint, HR and finance systems what
## they would land today.
static func _has_cost(effects: Array) -> bool:
	for e in effects:
		var effect: Dictionary = e
		if CONSEQUENCE_VERBS.has(String(effect.get("verb", ""))):
			return true
		if effect.has("amount_seam"):
			# A linter has no run to read the seam in: its multiplier's sign is the polarity.
			effect = effect.duplicate()
			effect["amount"] = int(signf(float(effect.get("amount_mult", 1.0))))
			effect.erase("amount_seam")
		for part in EvChips.describe(effect, {}, {}, true):
			if String((part as Dictionary)["polarity"]) in ["cost", "danger"]:
				return true
	return false


## The card's slot names of one type, in declaration order.
static func _slots_of_type(slots: Dictionary, type_id: String) -> Array:
	var out: Array = []
	for name in slots:
		if String((slots[name] as Dictionary).get("type", "")) == type_id:
			out.append(String(name))
	return out


## §17.7: a sprint paper that names its speaker (`speaker_role`, the character's role or a list of them) says at which
## phase of its card the speaker works (`stage`) and which pool group it counts in (`pool_group`). The engine binds the speaker to
## the card's employee slot (the founder's own note to its founder slot), so a name it does not know or a card without
## the slot is a paper that never reaches the player, and nothing at runtime shows it.
static func _lint_speaker(where: String, card: Dictionary) -> void:
	if not card.has("speaker_role"):
		return
	var roles: Array = card["speaker_role"] if card["speaker_role"] is Array else [card["speaker_role"]]
	for role in roles:
		if role not in PAPER_SPEAKERS:
			_add(SEVERITY_ERROR, "17.7", where, "speaker_role '%s' is none of %s" % [role, PAPER_SPEAKERS])
		elif _slots_of_type(card["scope"], EvScope.TYPE_FOUNDER if role == HRConstants.ROLE_FOUNDER
				else EvScope.TYPE_EMPLOYEE).is_empty():
			_add(SEVERITY_ERROR, "17.7", where, "speaker_role '%s' needs a scope slot of the speaker's kind" % role)
	if String(card.get("stage", "any")) not in PAPER_STAGES:
		_add(SEVERITY_ERROR, "17.7", where, "stage '%s' is none of %s" % [card.get("stage"), PAPER_STAGES])
	if String(card.get("pool_group", "")) not in PAPER_GROUPS:
		_add(SEVERITY_ERROR, "17.7", where, "pool_group '%s' is none of %s" % [card.get("pool_group", ""), PAPER_GROUPS])


## Which of the card's slots these effects land on. An effect names its slot in `scope`; one that
## does not falls to the first slot of its verb's type, the way EvEffects resolves it.
static func _touched_slots(effects: Array, slots: Dictionary) -> Array:
	var out: Array = []
	for e in effects:
		var effect: Dictionary = e
		var type_id: String = String(SUBJECT_VERBS.get(String(effect.get("verb", "")), ""))
		# A crew or a decision line's accounts are no slot: only the speaker and the slot's account are.
		if type_id == "" or String(effect.get("crew", "speaker")) != "speaker" \
				or String(effect.get("accounts", "slot")) != "slot":
			continue
		var slot: String = String(effect.get("scope", ""))
		if slot == "":
			var of_type: Array = _slots_of_type(slots, type_id)
			if of_type.is_empty():
				continue
			slot = String(of_type[0])
		if slots.has(slot) and not out.has(slot):
			out.append(slot)
	return out


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

	# §8.4: a {seam:} token the presenter cannot read prints nothing ("inside  weeks"), so every
	# token is parsed with the presenter's own pattern and its seam must be registered.
	for s in _strings_in(text):
		var found: Array = EvPresenter.SEAM_RE.search_all(String(s))
		if found.size() != String(s).count("{seam:"):
			_add(SEVERITY_ERROR, "17.1", where, "a {seam:} token the presenter cannot parse in '%s'" % s)
		for m in found:
			if not EvSeams.has((m as RegExMatch).get_string(1)):
				_add(SEVERITY_ERROR, "17.1", where,
					"text reads unknown seam '%s'" % (m as RegExMatch).get_string(1))

	for locale in ["tr", "en"]:
		var block: Dictionary = text[locale]
		_lint_variant_keys(where, locale, block)
		# A body may be a variant set; every arm is checked, and the panel holds one of them at a time.
		var arms: Array = body_strings(block)
		var body: String = " ".join(PackedStringArray(arms))
		var shown: String = " ".join(PackedStringArray(_strings_in(block)))
		for dash in DASH_CHARS:
			if shown.contains(dash):
				_add(SEVERITY_ERROR, "17.8", where, "[%s] text contains a dash" % locale)
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
			if _clock_re.search(subtitle) != null or _clock_re.search(body) != null:
				_add(SEVERITY_ERROR, "17.8", where,
					"[%s] a tick:daily card asserts a clock; daily beats fire at hour 0" % locale)

		var longest: int = 0
		for arm in arms:
			longest = maxi(longest, String(arm).length())
		if longest > 900:
			_add(SEVERITY_WARN, "17.8", where,
				"[%s] body is %d chars; the card panel is 780x420" % [locale, longest])


## EvPresenter picks a variant by a seam's INTEGER value, so a key that is not an integer
## ("default", "high") can never be chosen.
static func _lint_variant_keys(where: String, locale: String, value: Variant) -> void:
	if typeof(value) != TYPE_DICTIONARY:
		return
	for k in (value as Dictionary).get("variants", {}):
		if not String(k).is_valid_int():
			_add(SEVERITY_ERROR, "17.8", where,
				"[%s] variant key '%s' is not an integer; variants are picked by a seam's value"
				% [locale, k])
	for v in (value as Dictionary).values():
		_lint_variant_keys(where, locale, v)


# --- §17.6 arcs ------------------------------------------------------------

static func _lint_arc(arc_id: String, arc: Dictionary) -> void:
	var where: String = String(arc.get("_path", arc_id))
	_lint_day_names(where, arc)
	var arc_type: String = String(arc.get("type", ""))
	if arc_type not in [EvArcs.TYPE_PROMISE, EvArcs.TYPE_CHARACTER, EvArcs.TYPE_WORLD,
			EvArcs.TYPE_ASSIGNMENT]:
		_add(SEVERITY_ERROR, "17.6", where, "unknown arc type '%s'" % arc_type)

	var on_inv: Dictionary = arc.get("on_invalidate", {})
	var policy: String = String(on_inv.get("policy", ""))
	# on_invalidate runs ambient, with no card: a pace row is keyed and titled by the card it came from.
	for e in on_inv.get("penalties", []):
		if typeof(e) == TYPE_DICTIONARY and String(e.get("verb", "")) == "productivity_mod":
			_add(SEVERITY_ERROR, "17.1", where, "productivity_mod in on_invalidate: a pace row needs its card")

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
		# The awaiting timeout falls to close, and close fires a DIFFERENT card from the reassign
		# prompt. Declaring only one of them leaves the timeout with nothing to show.
		if String(on_inv.get("reassign_event", "")) == "":
			_add(SEVERITY_ERROR, "17.6", where, "policy reassign without a reassign_event")
		if String(on_inv.get("close_event", "")) == "":
			_add(SEVERITY_ERROR, "17.6", where,
				"policy reassign without a close_event — the awaiting timeout falls to close "
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


## A slot's `where` filters the slot's candidates one at a time, so every leaf reads that
## candidate: an entity_seam naming the slot, with a seam of the slot's type.
static func _lint_where(path: String, card: Dictionary) -> void:
	var slots: Dictionary = card.get("scope", {})
	for slot in slots:
		var spec: Dictionary = slots[slot]
		if not spec.has("where"):
			continue
		if typeof(spec["where"]) != TYPE_DICTIONARY or (spec["where"] as Dictionary).is_empty():
			_add(SEVERITY_ERROR, "17.1", path, "slot '%s': where is not a condition tree" % slot)
			continue
		_lint_condition(path, spec["where"])
		for leaf in EvCondition.leaves(spec["where"]):
			var d: Dictionary = leaf
			var seam: String = String(d.get("entity_seam", ""))
			# An unknown seam is _lint_condition's finding; its namespace would only say it twice.
			var other_type: bool = EvSeams.has(seam) and EvScope._type_for_seam(seam) != String(spec.get("type", ""))
			if seam == "" or String(d.get("scope", "")) != slot or other_type:
				_add(SEVERITY_ERROR, "17.1", path,
					"slot '%s': a where leaf must be an entity_seam of this slot and its type, not %s" % [slot, str(d)])


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

## §17.1: durations are weeks. A day-named key has no reader left and every reader falls back to
## its default in silence (a 0 cooldown becomes the default cooldown, a `days_since_flag` leaf
## is unrecognised and FALSE), so it is an error wherever it sits. Identifier values count too: a
## history form or a verb is a name as much as a key is.
static func _lint_day_names(where: String, value: Variant) -> void:
	match typeof(value):
		TYPE_DICTIONARY:
			for key in (value as Dictionary):
				if _is_day_name(String(key)):
					_add(SEVERITY_ERROR, "17.1", where, "day-named key '%s'; durations are weeks" % key)
				_lint_day_names(where, (value as Dictionary)[key])
		TYPE_ARRAY:
			for v in (value as Array):
				_lint_day_names(where, v)
		TYPE_STRING:
			if _identifier_re.search(String(value)) != null and _is_day_name(String(value)):
				_add(SEVERITY_ERROR, "17.1", where, "day-named '%s'; durations are weeks" % value)


static func _is_day_name(s: String) -> bool:
	return s == "days" or s.contains("_days") or s.contains("days_since")


## Every string under a value, depth-first.
static func _strings_in(value: Variant) -> Array:
	match typeof(value):
		TYPE_STRING:
			return [value]
		TYPE_DICTIONARY:
			return _strings_in((value as Dictionary).values())
		TYPE_ARRAY:
			var out: Array = []
			for v in (value as Array):
				out.append_array(_strings_in(v))
			return out
	return []


static func _trees_of(card: Dictionary) -> Array:
	var out: Array = []
	if typeof(card.get("condition", null)) == TYPE_DICTIONARY:
		out.append(card["condition"])
	var trigger: Dictionary = card.get("trigger", {})
	if typeof(trigger.get("condition", null)) == TYPE_DICTIONARY:
		out.append(trigger["condition"])
	return out


## Every body string a locale block can carry: the plain one, or every arm of a variant
## set (an arm may itself be a variant set). A key is returned as its key — the dash and
## trademark bans are about AUTHORED prose, and a CSV key is checked by the localization gates instead.
static func body_strings(block: Dictionary) -> Array:
	return _arms(block.get("body", ""))


static func _arms(value: Variant) -> Array:
	if typeof(value) != TYPE_DICTIONARY:
		return [String(value)]
	var out: Array = []
	for arm in (value as Dictionary).get("variants", {}).values():
		out.append_array(_arms(arm))
	return out


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

## The strings listed under `key`, as a set; empty when the file is not there.
static func _load_id_set(path: String, key: String) -> Dictionary:
	var out: Dictionary = {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return out
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		for id in ((parsed as Dictionary).get(key, []) as Array):
			out[String(id)] = true
	return out


static func _write_baseline() -> void:
	var accepted: Array = []
	for f in _findings:
		accepted.append(_fingerprint(f as Dictionary))
	var payload: Dictionary = {
		"_comment": "Accepted lint findings, by fingerprint. A finding here does NOT suppress "
			+ "its rule: change the card and the fingerprint changes and it comes back. "
			+ "Regenerate with --event-lint=baseline. Every addition should be defensible.",
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
