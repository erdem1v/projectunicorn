class_name EvSeamsProduct
extends RefCounted

# The `urun.` and `arge.` namespaces. Almost every row binds a query the Ürün and Ar-Ge read
# surfaces already name (ProductRead.X is the GDD's urun.X); a renamed query is a broken
# contract on their side and lint reports it.

static func install() -> void:
	_install_product()
	_install_papers()
	_install_paper_asks()
	_install_rnd()


static func _install_product() -> void:
	var G := EvSeams.Kind.GLOBAL

	EvSeams.register("urun.is_live", G, TYPE_BOOL,
		func() -> bool: return ProductState.is_live(),
		"Product", "something has shipped")
	EvSeams.register("urun.version", G, TYPE_INT,
		func() -> int: return ProductState.version(),
		"Product", "shipped version number")
	EvSeams.register("urun.version_age", G, TYPE_INT,
		func() -> int: return ProductRead.version_age(),
		"Product", "weeks since THIS VERSION shipped, not since the product was born")
	EvSeams.register("urun.market_type", G, TYPE_STRING,
		func() -> String: return ProductState.market_type(),
		"Product", "b2b | b2c; empty until the product type is chosen")
	EvSeams.register("urun.subtype", G, TYPE_STRING,
		func() -> String: return ProductState.subtype(),
		"Product", "one of the sub-product ids")

	# Sprint. A card cannot be a scope slot, so a decision card's text names the card it is
	# about through urun.decision_card.
	EvSeams.register("urun.sprint_number", G, TYPE_INT,
		func() -> int: return SprintSystem.sprint_number(),
		"Product", "the open sprint; 0 before the product type is chosen")
	EvSeams.register("urun.sprint_week", G, TYPE_INT,
		func() -> int: return SprintSystem.week(),
		"Product", "1 or 2 inside a running sprint")
	EvSeams.register("urun.sprint_last_week", G, TYPE_BOOL,
		func() -> bool: return SprintSystem.week() == SprintSystem.sprint_weeks(),
		"Product", "a running sprint is in its last week, week 2")
	EvSeams.register("urun.sprint_running", G, TYPE_BOOL,
		func() -> bool: return SprintSystem.mode() == "active",
		"Product", "a sprint is under way: not planning, not the release note")
	EvSeams.register("urun.decision_card", G, TYPE_STRING,
		func() -> String: return _decision_card(),
		"Product", "name of the card a sprint decision waits on; empty when none")
	EvSeams.register("urun.decision_card_late", G, TYPE_BOOL,
		func() -> bool: return SprintSystem.card_late(SprintSystem.decision_card().get("id", "")),
		"Product", "at the team's pace the decision card will not finish this sprint; false when none waits")
	EvSeams.register("urun.decision_card_effort", G, TYPE_INT,
		func() -> int:
			var card: Dictionary = SprintSystem.decision_card()
			return 0 if card.is_empty() else roundi(SprintSystem.total(card)),
		"Product", "the decision card's effort in points; 0 when none waits")
	EvSeams.register("urun.sprint_single_card", G, TYPE_BOOL,
		func() -> bool: return SprintSystem.sprint_card_count() == 1,
		"Product", "the open sprint holds one card; carried over, it leaves the sprint nothing to work on")
	EvSeams.register("urun.crunch_finishes", G, TYPE_BOOL,
		func() -> bool: return SprintSystem.crunch_finishes(SprintSystem.decision_card().get("id", "")),
		"Product", "the crunch's hours finish the decision card this sprint; false when none waits")
	EvSeams.register("urun.promise_card", G, TYPE_STRING,
		func() -> String: return SprintSystem.promise_name(),
		"Product", "name of the card the latest promise event is about; a history row reads the latest event's")
	EvSeams.register("urun.promise_open", G, TYPE_INT,
		func() -> int: return SprintSystem.event_promises().size(),
		"Product", "promises the latest promise event is about that are still open")
	EvSeams.register("urun.promise_extended", G, TYPE_BOOL,
		func() -> bool: return SprintSystem.event_promises().any(func(word: Promise) -> bool: return word.extended),
		"Product", "one of those promises has already moved a sprint; a word moves once")
	EvSeams.register("urun.promise_cut_finishes", G, TYPE_BOOL,
		func() -> bool: return SprintSystem.cut_test_finishes(SprintSystem.promise_event().get("card", ""), true),
		"Product", "the promise card is in testing and cutting its test in half gets its testing done this sprint, which sends it")
	EvSeams.register("urun.promise_crunch_finishes", G, TYPE_BOOL,
		func() -> bool:
			return not SprintSystem.promise_crew().is_empty() \
				and SprintSystem.crunch_finishes(SprintSystem.promise_event().get("card", ""), true),
		"Product", "employees work the promise card and the crunch's hours get its testing done this sprint, which sends it")
	EvSeams.register("urun.paid_plan_set", G, TYPE_BOOL,
		func() -> bool:
			var p: Dictionary = GameState.product
			return SprintCatalog.tier(SprintCatalog.PAID_PLAN) > 0 or ("plan:" + SprintCatalog.PAID_PLAN) in \
				p.get("sprint", {}).get("cards", []) + p.get("next", {}).get("cards", []),
		"Product", "the paid plan is open, or its card is in the running or the planned sprint")

	# The B2C floor ladder (ProductRead.worst_floor): the worst area's state and name, and the Trust and Scale level the
	# launch-day cards read.
	EvSeams.register("urun.floor_state", G, TYPE_STRING,
		func() -> String: return ProductRead.worst_floor().state,
		"Product", "'' | warning | crossed: the state of the worst area; '' in B2B and while no area is below the warning ratio")
	EvSeams.register("urun.floor_area", G, TYPE_STRING,
		func() -> String:
			var area: String = ProductRead.worst_floor().area
			return SprintCatalog.area_short_key(area) if area != "" else "",
		"Product", "localization key (PRODUCT_AREA_*_SHORT) of the worst area's name, '' without one; a card body prints it translated")
	EvSeams.register("urun.trust_level", G, TYPE_FLOAT,
		func() -> float: return SprintCatalog.area_level("trust"),
		"Product", "Trust and Scale as the product page shows it, 0-3 in halves; 0 until a line of the area is built")

	EvSeams.register("urun.open_bugs", G, TYPE_INT,
		func() -> int: return ProductRead.open_bugs(), "Product", "open bugs across every line")
	EvSeams.register("urun.worst_line_bugs", G, TYPE_INT,
		func() -> int: return ProductRead.worst_line_bugs(), "Product", "open bugs on the line with the most")
	EvSeams.register("urun.bugs_unconfirmed", G, TYPE_INT,
		func() -> int: return ProductRead.unconfirmed(), "Product", "incoming, unvalidated reports")
	EvSeams.register("urun.interest", G, TYPE_FLOAT,
		func() -> float: return ProductRead.interest(),
		"Product", "0-100, refreshed on publish, decays by a half-life counted in weeks")
	EvSeams.register("urun.usage", G, TYPE_FLOAT,
		func() -> float: return ProductRead.usage(), "Product", "load multiplier")
	EvSeams.register("urun.capacity_tier", G, TYPE_INT,
		func() -> int: return ProductRead.capacity_tier(), "Product", "provisioned infra units")
	EvSeams.register("urun.capacity_state", G, TYPE_STRING,
		func() -> String: return InfraSystem.capacity_state(),
		"Product", "normal | amber | over | unprovisioned")
	EvSeams.register("urun.enterprise_trust", G, TYPE_BOOL,
		func() -> bool: return InfraSystem.meets_enterprise_trust(),
		"Product", "Enterprise servers or the security_cert research: the trust bar the security and leak cards read")
	EvSeams.register("urun.support_staffed", G, TYPE_BOOL,
		func() -> bool: return ProductRead.support_staffed(),
		"Product", "the module's central pressure reads from this one boolean")
	EvSeams.register("urun.lines_open", G, TYPE_INT,
		func() -> int: return ProductRead.lines_open(), "Product", "0-9 feature lines opened")
	EvSeams.register("urun.steps_shipped", G, TYPE_INT,
		func() -> int: return ProductRead.steps_shipped(), "Product", "feature steps live")

	# Tech debt is a BOOLEAN in the demo, not a level (Ürün §20): a card may ask whether it
	# exists, not how much.
	EvSeams.register("urun.tech_debt", G, TYPE_BOOL,
		func() -> bool: return bool(GameState.get_flag("tech_debt_birikti", false)),
		"Product", "WRAPPER over a flag; boolean by design in the demo")


## What a sprint paper reads: the card it is about, its line, and the prices its options quote (`sprint.json` `paper`).
static func _install_papers() -> void:
	var G := EvSeams.Kind.GLOBAL
	EvSeams.register("urun.decision_kind", G, TYPE_STRING,
		func() -> String: return String(_decision_field("kind", "")),
		"Product", "feature | request | fix | research: what the decision card is; empty when none waits")
	EvSeams.register("urun.decision_line", G, TYPE_STRING,
		func() -> String: return String(_decision_field("line", "")).get_slice("@", 0),
		"Product", "id of the line the decision card is on, a shared line by its base id; empty when none waits")
	EvSeams.register("urun.decision_line_name", G, TYPE_STRING,
		func() -> String:
			var line: String = String(_decision_field("line", ""))
			return "" if ProductLines.line(line).is_empty() else SprintCatalog.cap_name(line),
		"Product", "the name of that line, for a paper's text; empty when none waits")
	EvSeams.register("urun.decision_tier", G, TYPE_INT,
		func() -> int: return int(_decision_field("target_tier", 0)),
		"Product", "the tier the decision card takes its line to; 0 when none waits")
	EvSeams.register("urun.decision_card_done", G, TYPE_INT,
		func() -> int: return SprintSystem.decision_done(),
		"Product", "points already worked on the decision card; 0 when none waits")
	EvSeams.register("urun.decision_line_bugs", G, TYPE_INT,
		func() -> int: return ProductState.line_bugs(String(_decision_field("line", ""))),
		"Product", "open bugs on the decision card's line")
	EvSeams.register("urun.decision_line_accounts", G, TYPE_INT,
		func() -> int: return SprintCatalog.line_accounts(String(_decision_field("line", ""))).size(),
		"Product", "B2B accounts that use the decision card's line")
	EvSeams.register("urun.decision_root_bugs", G, TYPE_INT,
		func() -> int: return int(_decision_field("bugs", 0)) if _decision_field("kind", "") == "fix" else 0,
		"Product", "open bugs the decision card, a fix card, closes; 0 for any other card")
	EvSeams.register("urun.decision_root_cause", G, TYPE_BOOL,
		func() -> bool:
			return int(_decision_field("bugs", 0)) >= int(SprintCatalog.cfg("paper.root_min")) \
				and _decision_field("kind", "") == "fix",
		"Product", "the decision card is a fix card with enough bugs on one line to share a root")
	EvSeams.register("urun.decision_line_first_version", G, TYPE_BOOL,
		func() -> bool: return SprintSystem.line_in_first_version(String(_decision_field("line", ""))),
		"Product", "the decision card's line was opened by the first version (the sprints before v1.0 and v1.0 itself)")
	EvSeams.register("urun.decision_promised", G, TYPE_BOOL,
		func() -> bool:
			var step: String = String(_decision_field("step", ""))
			return PromiseRegistry.get_all().any(
				func(p: Promise) -> bool: return p.status == "open" and p.feature_id == step),
		"Product", "an account was promised the decision card's step and the promise is still open")
	EvSeams.register("urun.decision_by_founder", G, TYPE_BOOL,
		func() -> bool:
			var speaker: Character = CharacterRegistry.get_character(
				String(GameState.product.get("decision", {}).get("speaker", "")))
			return speaker != null and speaker.category == "founder",
		"Product", "the founder speaks the pending paper (works the card's phase), not an employee")
	EvSeams.register("urun.decision_test_untouched", G, TYPE_BOOL,
		func() -> bool:
			var card: Dictionary = SprintSystem.decision_card()
			return not card.is_empty() and SprintSystem.phase(card) == SprintSystem.TEST_PHASE \
				and float(card.progress[SprintSystem.TEST_PHASE]) < SprintSystem.EPS,
		"Product", "the decision card has reached testing and nobody has tested it yet")
	EvSeams.register("urun.sprint_has_tester", G, TYPE_BOOL,
		func() -> bool:
			return SprintSystem.team().any(func(t: Dictionary) -> bool:
				return not t.founder and CharacterRegistry.get_character(t.id).role == HRConstants.ROLE_TESTER),
		"Product", "a tester works in the sprint's team (the Test job); the founder testing is not one")
	EvSeams.register("urun.durability_tier", G, TYPE_INT,
		func() -> int: return ProductState.line_tier(SprintCatalog.in_product("line_shared_durability")),
		"Product", "the tier the Durability line has reached; 1 is autosave and nothing more")
	EvSeams.register("urun.security_tier", G, TYPE_INT,
		func() -> int: return ProductState.line_tier(SprintCatalog.in_product("line_shared_security")),
		"Product", "the tier the Security and Access line has reached; 0 before it is built")
	EvSeams.register("urun.security_bugs", G, TYPE_INT,
		func() -> int: return ProductState.line_bugs(SprintCatalog.in_product("line_shared_security")),
		"Product", "open bugs on the Security and Access line")
	EvSeams.register("urun.security_fix_planned", G, TYPE_BOOL,
		func() -> bool:
			var fix: String = "fix:" + SprintCatalog.in_product("line_shared_security")
			return fix in GameState.product.get("sprint", {}).get("cards", []),
		"Product", "the Security and Access fix card is in the running sprint")
	# One seam per line, a shared line by the base id cards write, so a card can ask how far a line has come.
	var lines: Array = []
	for subtype in ProductLines.subtypes():
		for line_id: String in ProductLines.line_ids(subtype):
			if line_id.get_slice("@", 0) not in lines:
				lines.append(line_id.get_slice("@", 0))
	for line_id: String in lines:
		EvSeams.register("urun.line_tier." + line_id, G, TYPE_INT,   # LOC-DATA seam namespace, not copy
			func() -> int: return ProductState.line_tier(SprintCatalog.in_product(line_id)),
			"Product", "the tier the %s line has reached; 0 before it is built" % line_id)
		# The rule `queue_card` opens an account's request by, so a card offers that only where it lands.
		EvSeams.register("musteri.can_request." + line_id, EvSeams.Kind.ENTITY, TYPE_BOOL,   # LOC-DATA seam namespace, not copy
			func(id: String) -> bool: return not SprintBridges.request_step(id, line_id).is_empty(),
			"Sales", "a request for the %s line's next tier can be opened for the account" % line_id)
	EvSeams.register("urun.weeks_to_month_end", G, TYPE_INT,
		func() -> int:
			var weeks: int = 1
			while int(GameState.get_date_dict(GameState.day + weeks).month) == int(GameState.get_date_dict().month):
				weeks += 1
			return weeks,
		"Product", "ticks until the calendar month turns; 1 on the month's last tick")
	EvSeams.register("urun.paper_server_bill", G, TYPE_INT,
		func() -> int: return InfraSystem.monthly_bill(),
		"Product", "this month's server bill, in dollars")
	EvSeams.register("urun.paper_loss_small", G, TYPE_INT,
		func() -> int: return roundi(SalesSystem.b2c_audience() * float(SprintCatalog.cfg("paper.b2c_loss.small"))),
		"Product", "the audience a small annoyance costs, in people")
	EvSeams.register("urun.paper_loss_mid", G, TYPE_INT,
		func() -> int: return roundi(SalesSystem.b2c_audience() * float(SprintCatalog.cfg("paper.b2c_loss.mid"))),
		"Product", "the audience a real annoyance costs, in people")
	EvSeams.register("urun.paper_signup_loss", G, TYPE_INT,
		func() -> int: return roundi(SalesSystem.weekly_new_users() * float(SprintCatalog.cfg("paper.signup_loss"))),
		"Product", "the sign ups a week of a broken sign up code costs, in people")


## What a sprint paper asks of its card and its account before it comes, and the prices its options quote (`sprint.json`
## `paper`): the card trimmed, held up by a phone screen, saved for a renewal; the colours' two arrivals; the B2C losses.
static func _install_paper_asks() -> void:
	var G := EvSeams.Kind.GLOBAL
	EvSeams.register("urun.decision_second_account", G, TYPE_STRING,
		func() -> String:
			var second: Customer = SprintCatalog.second_account(SprintSystem.decision_card())
			return "" if second == null else second.display_name(),
		"Product", "the other account that asked for the decision card's step; empty when only one did (open requests carry one account per step)")
	EvSeams.register("urun.decision_request_votes", G, TYPE_INT,
		func() -> int: return 0,
		"Product", "B2C: the people who asked for the decision card's step; 0 until the consumer request data exists")
	EvSeams.register("urun.decision_step", G, TYPE_STRING,
		func() -> String: return String(_decision_field("step", "")).get_slice("@", 0),
		"Product", "id of the step the decision card takes its line to, a shared line's step by its base id; empty when none waits")
	EvSeams.register("urun.decision_phase", G, TYPE_INT,
		func() -> int:
			var card: Dictionary = SprintSystem.decision_card()
			return 0 if card.is_empty() else SprintSystem.phase(card),
		"Product", "the phase the decision card is in: 0 design, 1 development, 2 testing, 3 done; 0 when none waits")
	EvSeams.register("urun.cut_test_finishes", G, TYPE_BOOL,
		func() -> bool: return SprintSystem.cut_test_finishes(SprintSystem.decision_card().get("id", "")),
		"Product", "the decision card is in testing and cutting its test in half finishes it this sprint")
	EvSeams.register("urun.decision_test_half", G, TYPE_INT,
		func() -> int: return SprintSystem.decision_test_half(),
		"Product", "half of the decision card's testing left, in points; the work a developer helping with the test does")
	EvSeams.register("urun.decision_trim_finishes", G, TYPE_BOOL,
		func() -> bool:
			return SprintSystem.finishes_with(SprintSystem.decision_card().get("id", ""),
				-SprintSystem.trim_points(float(SprintCatalog.cfg("paper.trim_share")))),
		"Product", "taking the trim share off the decision card finishes it this sprint")
	EvSeams.register("urun.paper_phone_points", G, TYPE_INT,
		func() -> int: return int(SprintCatalog.cfg("paper.phone_points")),
		"Product", "the work a phone layout adds to a card, in points")
	EvSeams.register("urun.decision_phone_late", G, TYPE_BOOL,
		func() -> bool:
			return SprintSystem.late_with(SprintSystem.decision_card().get("id", ""), int(SprintCatalog.cfg("paper.phone_points"))),
		"Product", "the phone layout's points added, the decision card would not finish this sprint")
	EvSeams.register("urun.responsive_shipped", G, TYPE_BOOL,
		func() -> bool: return ProductState.is_feature_live(SprintCatalog.in_product("line_shared_mobile_k1")),
		"Product", "the Responsive Interface step is live")
	EvSeams.register("urun.decision_renewal_saved", G, TYPE_BOOL,
		func() -> bool: return SprintSystem.decision_renewal_saved(),
		"Product", "the account's renewal falls after this sprint and before the next, and standing the card first ships it this sprint")
	EvSeams.register("urun.design_late", G, TYPE_BOOL,
		func() -> bool: return SprintSystem.design_late(SprintSystem.decision_card().get("id", "")),
		"Product", "the decision card is still in design after this week's work and a developer waits on it")
	EvSeams.register("urun.paid_plan_open", G, TYPE_BOOL,
		func() -> bool: return SprintCatalog.tier(SprintCatalog.PAID_PLAN) > 0,
		"Product", "the paid plan is open")
	EvSeams.register("urun.colors_again", G, TYPE_BOOL,
		func() -> bool: return EvFlags.has("colors_by_hand"),
		"Product", "the colours were changed by hand once, so the account asks for its colours on the pages added since")
	EvSeams.register("urun.colors_first", G, TYPE_INT,
		func() -> int: return 0 if EvFlags.has("colors_by_hand") else 1,
		"Product", "1 the first time an account asks for its colours, 0 the second time")
	EvSeams.register("urun.colors_hand", G, TYPE_INT,
		func() -> int: return _colors_points("hand"),
		"Product", "the points of changing the colours by hand; five more for each page added since the first change")
	EvSeams.register("urun.colors_central", G, TYPE_INT,
		func() -> int: return _colors_points("central"),
		"Product", "the points of pulling every colour into one file; five more for each page added since the first change")
	EvSeams.register("urun.paper_ask_silent", G, TYPE_INT,
		func() -> int: return int(EvSeams.read("urun.decision_request_votes")) * int(SprintCatalog.cfg("paper.ask_silent_mult")),
		"Product", "the audience that goes quiet when a request is not met: the people who asked, times the quiet ones behind each")
	EvSeams.register("urun.paper_test_phones", G, TYPE_INT,
		func() -> int: return int(SprintCatalog.cfg("paper.test_phones")),
		"Product", "what a few phones to test on cost, in dollars, once")
	EvSeams.register("urun.paper_first_screen_loss", G, TYPE_INT,
		func() -> int:
			var loss: Dictionary = SprintCatalog.cfg("paper.first_screen_loss")
			return roundi(SalesSystem.weekly_new_users() * float(loss.share) * int(loss.weeks)),
		"Product", "the sign ups a sign up screen with three questions loses over its weeks, in people")
	EvSeams.register("urun.paper_coupon_loss", G, TYPE_INT,
		func() -> int: return roundi(SalesSystem.b2c_audience() * float(SprintCatalog.cfg("paper.coupon_share"))),
		"Product", "the audience that would have come in on a coupon, in people")


## The points of a colour change: its sprint.json base, one more when the colours were changed by hand before.
static func _colors_points(kind: String) -> int:
	var colors: Dictionary = SprintCatalog.cfg("paper.colors")
	return int(colors[kind]) + (int(colors.again_extra) if EvFlags.has("colors_by_hand") else 0)


## The pending decision card's `field`, `fallback` when none waits.
static func _decision_field(field: String, fallback: Variant) -> Variant:
	return SprintSystem.decision_card().get(field, fallback)


static func _decision_card() -> String:
	var card: Dictionary = SprintSystem.decision_card()
	return "" if card.is_empty() else SprintCatalog.card_name(card)


static func _install_rnd() -> void:
	var G := EvSeams.Kind.GLOBAL

	EvSeams.register("arge.tree_open", G, TYPE_BOOL,
		func() -> bool: return RnDSystem.tree_open(), "R&D", "the tab is reachable")
	EvSeams.register("arge.active", G, TYPE_STRING,
		func() -> String: return RnDSystem.active(),
		"R&D", "the running node id, or empty; exactly one at a time")
	EvSeams.register("arge.completed_count", G, TYPE_INT,
		func() -> int: return RnDSystem.completed_count(), "R&D", "0-20")
	EvSeams.register("arge.is_frozen", G, TYPE_BOOL,
		func() -> bool: return RnDSystem.is_frozen(),
		"R&D", "research with nobody assigned; progress is preserved, not lost")
	EvSeams.register("arge.note_pending", G, TYPE_BOOL,
		func() -> bool: return RnDSystem.note_pending(),
		"R&D", "an unread monthly product note is waiting")
	EvSeams.register("arge.attention_count", G, TYPE_INT,
		func() -> int: return RnDSystem.attention_count(), "R&D", "what the rail badge counts")
