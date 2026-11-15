class_name PlayerPaths
extends RefCounted

# K2, the player's path: a case seeds a world the game can reach, mounts the real shell, drives it through the handler a
# click reaches and reads what the screen shows (a button's disabled state, a label's text). A rule tested only through an
# inner function can drift from the screen; here the screen is the witness. No pixels and no fixed waits: a case waits
# for its condition. `main` is the Main node, where the world seeds and the shell live.

const WAIT_FRAMES := 120
const MP_PARTS := preload("res://scripts/tabs/marketplace/mp_parts.gd")


static func run(main: Node, case_id: String) -> String:
	match case_id:
		"hr_raise_row_locked_in_cooldown":
			return await _hr_raise_row_locked_in_cooldown(main)
		"sales_gate_follows_clock":
			return await _sales_gate_follows_clock(main)
		"sprint_fit_gets_points":
			return await _sprint_fit_gets_points(main)
		"cs_renewal_request_reaches_player":
			return await _cs_renewal_request_reaches_player(main)
		"cs_request_rule_holds_second_ask":
			return await _cs_request_rule_holds_second_ask(main)
		"mp_policy_locks_after_apply":
			return await _mp_policy_locks_after_apply(main)
		"mp_assign_reads_first_week":
			return await _mp_assign_reads_first_week(main)
	return "unknown case"


## A raise in its cooldown: the Kadro row menu's Zam yap is shut and says why. A colleague's opens the raise and applying
## it raises the salary.
static func _hr_raise_row_locked_in_cooldown(main: Node) -> String:
	main._seed_run_reproducible()
	main._seed_hr_roster()
	var staff: Array[Character] = CharacterRegistry.get_employees()
	var raised: Character = staff[0]
	var fresh: Character = staff[1]
	raised.last_raise_day = GameState.day
	await main._mount_shot_shell()
	var page: Control = _open(main, "hr")
	var label: String = TranslationServer.translate("HR_CARD_RAISE")
	var item: Button = await _menu_item(main, page, raised, label)
	if item == null:
		return "%s's row menu has no %s" % [raised.character_name, label]
	var why: String = String(HRActions.preview_raise(raised, HRConstants.RAISE_MIN_PCT).reason)
	if not item.disabled or why == "" or _labels(item, why).is_empty():
		return "%s was raised today, yet %s reads %s" % [raised.character_name, label,
			"open" if not item.disabled else "shut with no reason"]
	item = await _menu_item(main, page, fresh, label)
	if item == null or item.disabled:
		return "%s's %s is shut or missing" % [fresh.character_name, label]
	var before: int = fresh.monthly_salary
	item.pressed.emit()
	if main._confirm_modal == null:
		return "%s opened no raise" % label
	main._confirm_modal._commit_btn.pressed.emit()
	if not await _until(main, func() -> bool: return fresh.monthly_salary > before):
		return "the raise applied, the salary stayed %d" % before
	return ""


## The Sales page follows the clock. Opened at 00:00 (a card at the rollover takes the player there), every lead's
## Görüşmeye git is shut on the workday not having started; the night runs to 08:00 and the same page opens them; at the
## workday's last hour they shut on the late reason.
static func _sales_gate_follows_clock(main: Node) -> String:
	main._seed_sales_world()
	for star in [1, 2, 3]:
		SalesFaucetSystem.spawn(star, "faucet")
	SalesSystem.reflect_mrr()
	await main._mount_shot_shell()
	GameState.set_current_hour(0)
	TimeManager.sync_to_current_hour()
	var page: Control = _open(main, "sales")
	for step: Array in [["00:00", "SITTING_BLOCK_EARLY"], ["08:00", ""], ["late", "SALES_BLOCK_TOO_LATE"]]:
		match step[0]:
			"08:00":
				TimeManager.skip_night()
			"late":
				TimeManager.advance_hours(WorkHoursSystem.end_hour_for(CharacterRegistry.get_founder()) - 1
					- GameState.current_hour)
		var want: String = "open" if step[1] == "" else "shut: " + TranslationServer.translate(step[1])
		if not await _until(main, func() -> bool: return _gate(page) == want):
			return "at %s (%02d:00) the leads read '%s', want '%s'" % [step[0], GameState.current_hour, _gate(page), want]
	return ""


## What the sprint screen draws, the sprint does: the founder alone at 15 hours on the ERP plans Sprint 1 with the lead's plan. A card
## whose bar starts on the board's time axis inside week 1 (the second one starts on the first one's leftover) has work after
## week 1, and every card the board says finishes (the row's on-time tip) is done when the sprint closes. A sprint paper
## would stop a card on the player's answer, which no plan foresees, so the pinned world must stay without one.
static func _sprint_fit_gets_points(main: Node) -> String:
	main._seed_run_reproducible()
	main._seed_product_live("b2b_solo15")
	await main._mount_shot_shell()
	var page: Control = _open(main, "product")
	var cards: Array = SprintSystem.starting()
	var planned: Array = cards.map(func(c: Dictionary) -> String: return c.id)
	if not await _until(main, func() -> bool: return _board(page, planned).size() == planned.size()):
		return "the board draws %d of the plan's %d cards" % [_board(page, planned).size(), planned.size()]
	var rows: Array = _board(page, planned)
	var fits: Array = rows.filter(func(row: BoardRow) -> bool: return row.card.finishes).map(
		func(row: BoardRow) -> String: return row.card.id)
	var week_one: Array = rows.filter(func(row: BoardRow) -> bool: return row.card.stages.any(
		func(s: Dictionary) -> bool: return s.start >= 0.0 and s.start < 1.0)).map(func(row: BoardRow) -> String: return row.card.id)
	if fits.is_empty() or week_one.size() < 2:
		return "the board finishes %d and starts %d of the plan's %d cards in week 1; the case needs the card after the first" % [
			fits.size(), week_one.size(), planned.size()]
	if not main._press_button_labelled(page, TranslationServer.translate("PRODUCT_START_SPRINT")):
		return "no Sprinti başlat on the plan"
	var week := 0
	while SprintSystem.mode() == "active":
		GameState.advance_day()
		SprintSystem.daily_tick()
		week += 1
		if cards.any(func(c: Dictionary) -> bool: return c.decision):
			return "a sprint paper came; the plan can be judged only in a world without one"
		if week == 1:
			for c: Dictionary in cards.filter(func(c: Dictionary) -> bool: return c.id in week_one):
				if c.progress.all(func(done) -> bool: return float(done) <= 0.0):
					return "the board starts %s in week 1, the week did none of it" % SprintCatalog.card_name(c)
	for c: Dictionary in cards.filter(func(c: Dictionary) -> bool: return c.id in fits):
		if SprintSystem.phase(c) < SprintSystem.PHASE_DONE:
			return "the board said %s finishes, the sprint closed with %s of its work left" % [SprintCatalog.card_name(c),
				SprintUiShared.points(SprintSystem.remaining(c))]
	return ""


## A long-standing account calls about its renewal: the support desk escalates the open request (the desk's own step; the
## player's path starts where the paper waits), the paper waits on the desk through the workday and opens when the night
## begins, the renewal card in the inbox.
static func _cs_renewal_request_reaches_player(main: Node) -> String:
	main._seed_run_reproducible()
	main._seed_theme_book()
	var tenure: int = TimeModel.ticks(B2BConstants.RENEWAL_MIN_TENURE_WEEKS)
	GameState.day = maxi(GameState.day, tenure + 1)
	main._shot_customer("co_palmiye", main._pool_name("retail"), "retail", "active", 1200, 15, tenure, true)   # LOC-DATA debug seed / id
	var account: Customer = CustomerRegistry.get_customer("co_palmiye")
	CustomerRegistry.set_support_request(account.id, GameState.day - TimeModel.ticks(B2BConstants.CS_ESCALATE_AFTER_WEEKS))
	if CustomerRepSystem.pick_request_kind(account) != B2BConstants.CS_KIND_RENEWAL:
		return "fixture: %s does not call about its renewal" % account.company_name
	await main._mount_shot_shell()
	main._wire_modal_signals()
	GameState.set_current_hour(TimeModel.WEEK_START_HOUR)
	TimeManager.sync_to_current_hour()
	CustomerRepSystem._escalate(account)
	if account.support_request_since_day >= 0:
		return "the desk did not escalate %s's request" % account.company_name
	TimeManager.advance_hours(WorkHoursSystem.end_hour_for(CharacterRegistry.get_founder()) - GameState.current_hour)
	TimeManager.skip_night()
	var card: String = "customer.request_renewal"
	if not await _until(main, func() -> bool: return EventGate.active_id() == card):
		return "the night began and the renewal paper did not open (on screen: '%s')" % EventGate.active_id()
	var title: String = EventGate.active_card().title
	if not await _until(main, func() -> bool: return not _labels(main._shell, title).is_empty()):
		return "the renewal card is on, the inbox does not show '%s'" % title
	return ""


## An account that asked four weeks ago does not ask again: its first request reaches the player at the week's end and is
## answered; the desk's next escalation, past the card's own two weeks but inside the request cards' rule about one account,
## keeps the request on the desk and opens no paper that night; once the rule's weeks have passed the account asks again.
static func _cs_request_rule_holds_second_ask(main: Node) -> String:
	main._seed_run_reproducible()
	main._seed_theme_book()
	main._shot_customer("co_palmiye", main._pool_name("retail"), "retail", "active", 1200, 15, 10, true)   # LOC-DATA debug seed / id
	var account: Customer = CustomerRegistry.get_customer("co_palmiye")
	await main._mount_shot_shell()
	main._wire_modal_signals()
	var first_day: int = GameState.day
	for ask in ["first", "held", "after the rule"]:
		EventBus.tab_changed.emit("")   # the player closes the window, a closed sprint's release note among them
		GameState.set_current_hour(TimeModel.WEEK_START_HOUR)
		TimeManager.sync_to_current_hour()
		CustomerRegistry.set_support_request(account.id, GameState.day - TimeModel.ticks(B2BConstants.CS_ESCALATE_AFTER_WEEKS))
		CustomerRepSystem._escalate(account)
		if ask == "held" and account.support_request_since_day < 0:
			return "the desk dropped %s's held request" % account.company_name
		TimeManager.advance_hours(WorkHoursSystem.end_hour_for(CharacterRegistry.get_founder()) - GameState.current_hour)
		TimeManager.skip_night()
		# The player answers what comes before the account's ask: Frank's cheque, the seed's company being at its bar.
		var asked: bool = await _until(main, func() -> bool:
			var shown: String = EventGate.active_id()
			if shown != "" and not shown.begins_with("customer.request_"):
				EventGate.resolve(shown, 0)
			return EventGate.active_id().begins_with("customer.request_"))
		if asked != (ask != "held"):
			return "%s: %s %s" % [ask, account.company_name, "asked again four weeks after its last request" if asked
				else "did not ask (week %d after its first request)" % (GameState.day - first_day)]
		if asked:
			EventGate.resolve(EventGate.active_id(), 0)
		var cooldown: int = int(EvCatalog.card("customer.request_feature").family_subject.cooldown_weeks)
		GameState.day = first_day + TimeModel.ticks(4 if ask == "first" else cooldown + 1)
	return ""


## Politikalar: every rule shows its own options; Mağaza kabulü, whose tier the launch week has not built, writes that tier and
## its options are shut. A choice on another option opens its results under the row in the order of the rule's list (shipping,
## return shipping, then the return window: one choice at a time, so one Uygula) with the return chip's reason in its tip; the
## choice is framed in all three states the pointer can put it in; a press on the option in force takes it back. Uygula writes
## the rule and the row stands locked: the lock row writes four weeks, its options are shut, the option in force loses its fill
## and a press on them changes nothing; the other rules stay open.
## FALSIFICATION: Uygula not calling `set_policy` (the rule stays 7 days) → FAIL; the locked row's options open (`_row` giving
## `_options` `open` alone) → FAIL; Mağaza kabulü's need check dropped (`open` true in `_row`) → FAIL; the option in force not
## connected while a choice waits → FAIL; a rule's chip missing or out of order → FAIL; the return chip's tip without its reason
## → FAIL; `mark_pending` or `restyle_segments` not called → FAIL; the frame on `normal` alone (lost under the pointer) → FAIL;
## the closed pick's option in force left filled → FAIL; the lock row one week off → FAIL.
static func _mp_policy_locks_after_apply(main: Node) -> String:
	if not main._seed_marketplace_world(main._MP_WORLDS.mp_launch):
		return "fixture: the marketplace world did not reach its launch"
	if MarketplaceModel.policy_open(MarketplaceSystem.world(), "admission") or MarketplaceSystem.policy_value("return_window") != "d7":
		return "fixture: Kullanıcı Koruması is built or the return window is not at 7 days"
	await main._mount_shot_shell()
	var page: Control = _open(main, "sales")
	if not main._press_button_labelled(page, Fmt.upper(TranslationServer.translate("MP_TAB_POLICIES"))):
		return "no Politikalar on the strip"
	var options: Dictionary = MarketplaceModel.cfg("rules.options")
	for rule: String in options:
		for option: String in options[rule]:
			var found: int = _option_keys(page, rule, option).size()
			if found != 1:
				return "Politikalar has %d keys for %s %s" % [found, rule, option]
	var need: String = TranslationServer.translate("MP_NEEDS_TIER").format(
		{"tier": TranslationServer.translate("PROD_STEP_MARKETPLACE_REVIEWS_K2")})
	if _labels(page, need).is_empty():
		return "Mağaza kabulü does not say '%s'" % need
	for option: String in options.admission:
		var shut: Button = _option_keys(page, "admission", option)[0]
		shut.pressed.emit()
		if not shut.disabled or MarketplaceSystem.policy_value("admission") != "open" or not _chips(page).is_empty():
			return "Mağaza kabulü %s is open to a press before its tier ships" % option
	var apply: String = TranslationServer.translate("MP_APPLY")
	_option_keys(page, "shipping", "store_pays")[0].pressed.emit()
	var fail := _chip_fail(page, "shipping", ["MP_CHIP_ORDERS", "MP_CHIP_STORE_EARNINGS", "MP_CHIP_REVENUE"])
	if fail != "":
		return fail
	_option_keys(page, "return_shipping", "we_pay")[0].pressed.emit()
	fail = _chip_fail(page, "return_shipping", ["MP_CHIP_STORE_SAT", "MP_CHIP_RETURN_RATE", "MP_CHIP_COST"])
	if fail != "":
		return fail
	_option_keys(page, "return_window", "d30")[0].pressed.emit()
	fail = _chip_fail(page, "return_window", ["MP_CHIP_RETURNING", "MP_CHIP_RETURN_RATE", "MP_CHIP_STORE_SAT", "MP_CHIP_REVENUE"])
	if fail != "":
		return fail
	if _buttons(page, apply).size() != 1:
		return "a choice on a second rule left %d Uygula, one expected" % _buttons(page, apply).size()
	var thirty: Button = _option_keys(page, "return_window", "d30")[0]
	var seven: Button = _option_keys(page, "return_window", "d7")[0]
	if not thirty.has_meta(&"pending") or not await _until(main, func() -> bool:
			return [&"normal", &"hover", &"pressed"].all(func(st: StringName) -> bool: return thirty.has_theme_stylebox_override(st))):
		return "the pending 30 days is not framed in every state the pointer can put it in"
	var tip: Control = _chips(page)[3].build.call()
	var tipped: bool = not _labels(tip, TranslationServer.translate("MP_TIP_NO_COMMISSION_ON_RETURN")).is_empty()
	tip.free()
	if not tipped:
		return "the return window's Aylık gelir chip does not say why a return pays no commission"
	seven.pressed.emit()
	if not _chips(page).is_empty() or not _buttons(page, apply).is_empty():
		return "a press on the option in force left the choice standing"
	_option_keys(page, "return_window", "d30")[0].pressed.emit()
	_buttons(page, apply)[0].pressed.emit()
	if MarketplaceSystem.policy_value("return_window") != "d30":
		return "Uygula left the return window at %s" % MarketplaceSystem.policy_value("return_window")
	var lock: String = TranslationServer.translate("MP_LOCK_FOR").format({"weeks": Fmt.weeks(4)})
	if not await _until(main, func() -> bool: return not _labels(page, lock).is_empty() and _chips(page).is_empty()):
		return "the applied rule does not stand locked for four weeks ('%s') with its choice closed" % lock
	if not await _until(main, func() -> bool:
			return _option_keys(page, "return_window", "d30")[0].has_theme_stylebox_override(&"disabled")):
		return "the locked return window's 30 days keeps the fill of an open choice"
	for option: String in options.return_window:
		var key: Button = _option_keys(page, "return_window", option)[0]
		key.pressed.emit()
		if not key.disabled or MarketplaceSystem.policy_value("return_window") != "d30" or not _chips(page).is_empty():
			return "the locked return window's %s is open to a press" % option
	if _option_keys(page, "shipping", "user_pays")[0].disabled:
		return "the lock on the return window shut the shipping fee's options"
	return ""


## The keys of a rule's option on the Politikalar page.
static func _option_keys(page: Control, rule: String, option: String) -> Array:
	return _buttons(page, TranslationServer.translate("MP_OPT_%s_%s" % [rule.to_upper(), option.to_upper()]))


## The result chips on screen.
static func _chips(page: Control) -> Array:
	return page.find_children("*", "PanelContainer", true, false).filter(
		func(c: PanelContainer) -> bool: return c.theme_type_variation == &"FxChip" and c.is_visible_in_tree())


## "" when the page shows exactly `keys`' chips in that order, else what it shows.
static func _chip_fail(page: Control, rule: String, keys: Array) -> String:
	var shown: Array = _chips(page).map(func(c: PanelContainer) -> String: return c.tooltip_text)
	var want: Array = keys.map(func(k: String) -> String: return TranslationServer.translate(k).get_slice("{", 0))
	if shown.size() != want.size() or range(want.size()).any(func(i: int) -> bool: return not (shown[i] as String).begins_with(want[i])):
		return "a choice on %s shows %s, its list is %s" % [rule, shown, want]
	return ""


## The store acquisition is the player's to place. On Moda's panel the free slot opens a picker with its one line about the first
## week, the founder (on Moda already) shut on that reason and a rep with the stores they would bring a week; the rep, whose Sales
## job the player had ticked off in Ekip, is picked: the row says "next week" and the rep holds the Sales job again; after a close
## the row reads the week's stores. Change on that row puts a second rep in the first one's place: the first leaves Moda, keeps the
## Sales job a rep is hired with and waits for a category.
##
## FALSIFICATION: make `MarketplaceModel.crew` return `live` true always → the "next week" line FAILs; write 0 for the picker's
## weekly stores in `_option` → the candidate's line FAILs; delete the `assign_job` call in `MarketplaceSystem.assign` → the
## founder's line FAILs (his assignment came without the job and drops at the first job change); delete `unassign(replaced)` in
## `_assign` → the Change line FAILs; drop the role condition in `MarketplaceSystem.unassign` or the category condition in
## `HRSystem.job_waiting_key` → the waiting rep's line FAILs; delete the first-week line in `_open_picker` → the picker line FAILs.
static func _mp_assign_reads_first_week(main: Node) -> String:
	if not main._seed_marketplace_world(main._MP_WORLDS.mp_launch):
		return "the marketplace world did not reach its launch"
	GameState.set_cash(1_000_000)   # the world's weeks never reach the shutter
	var ana: Character = main._mp_hire(HRConstants.ROLE_SALES_REP, HRConstants.LEVEL_MID)
	var bora: Character = main._mp_hire(HRConstants.ROLE_SALES_REP, HRConstants.LEVEL_MID)
	CharacterRegistry.unassign_job(ana.id, HRConstants.JOB_SALES)
	await main._mount_shot_shell()
	var page: Control = _open(main, "sales")
	if not main._press_button_labelled(page, Fmt.upper(TranslationServer.translate("MP_TAB_CATEGORIES"))):
		return "no Kategoriler on the strip"
	# The page's own words for what a person brings Moda a week.
	var week := func(person: Character) -> String:
		var stores: float = MarketplaceModel.acquisition_of(MarketplaceSystem.read_state(), MarketplaceSystem.world(), "fashion",
			int(MarketplaceSystem.sales_stars(person)))
		return TranslationServer.translate(Fmt.count_key("MP_ACQ_PER_WEEK", 1 if is_equal_approx(stores, 1.0) else 0)).format(
			{"n": MP_PARTS.count(stores)})
	var says := func(person: Character, text: String) -> bool:
		var row: Node = page.find_child(person.id, true, false)
		return row != null and not _labels(row, text).is_empty()
	if not await _until(main, func() -> bool: return page.find_child("AssignSlot", true, false) != null):
		return "Moda's panel has no free slot"
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	var slot: Control = page.find_child("AssignSlot", true, false)
	slot.gui_input.emit(click)
	var pop: Node = _picker(main)
	if pop == null or _labels(pop, TranslationServer.translate("MP_ACQ_FIRST_WEEK")).is_empty():
		return "the free slot's picker does not open with its first-week line"
	var founder: Character = CharacterRegistry.get_founder()
	var here: Array = _buttons(pop, founder.character_name)
	if here.size() != 1 or not here[0].disabled or _labels(here[0], TranslationServer.translate("MP_ACQ_HERE")).is_empty():
		return "the founder, on Moda already, is not shut with the reason in the picker"
	var pick: Array = _buttons(pop, ana.character_name)
	if pick.size() != 1 or pick[0].disabled or _labels(pick[0], week.call(ana)).is_empty():
		return "%s's picker row is not open with '%s'" % [ana.character_name, week.call(ana)]
	pick[0].pressed.emit()
	if MarketplaceSystem.read_state().assign.get(ana.id, {}).get("cat", "") != "fashion":
		return "the pick did not put %s on Moda" % ana.character_name
	if HRConstants.JOB_SALES not in ana.assigned_job_ids:
		return "%s is on Moda without the Sales job" % ana.character_name
	var next_week: String = TranslationServer.translate("MP_ACQ_NEXT_WEEK")
	if not await _until(main, func() -> bool: return says.call(ana, next_week)):
		return "%s's row does not say '%s' in the week of the pick" % [ana.character_name, next_week]
	GameState.advance_day()
	MarketplaceSystem.daily_tick()
	if not await _until(main, func() -> bool: return says.call(ana, week.call(ana))):
		return "after a close %s's row does not read '%s'" % [ana.character_name, week.call(ana)]
	var change: Array = _buttons(page.find_child(ana.id, true, false), TranslationServer.translate("MP_ACQ_CHANGE"))
	if change.size() != 1:
		return "%s's row has no Change" % ana.character_name
	change[0].pressed.emit()
	pop = _picker(main)
	pick = [] if pop == null else _buttons(pop, bora.character_name)
	if pick.size() != 1 or pick[0].disabled:
		return "%s is not open in Change's picker" % bora.character_name
	pick[0].pressed.emit()
	var assigned: Dictionary = MarketplaceSystem.read_state().assign
	if assigned.has(ana.id) or assigned.get(bora.id, {}).get("cat", "") != "fashion":
		return "Change left %s on Moda or did not put %s there" % [ana.character_name, bora.character_name]
	if HRConstants.JOB_SALES not in ana.assigned_job_ids or not HRSystem.is_waiting(ana):
		return "%s left Moda and is not a rep with the Sales job waiting for a category" % ana.character_name
	var swapped := func() -> bool: return page.find_child(ana.id, true, false) == null and page.find_child(bora.id, true, false) != null
	if not await _until(main, swapped):
		return "the panel still shows %s on Moda or does not show %s" % [ana.character_name, bora.character_name]
	return ""


## The open popover of the shell's panel layer (a picker, a row menu), or null.
static func _picker(main: Node) -> Node:
	var open: Array = main._shell.get_node("PanelLayer").find_children("*", "HRPopover", true, false).filter(
		func(pop: Node) -> bool: return not pop.is_queued_for_deletion())
	return null if open.is_empty() else open[-1]


## Opens `tab` the way the rail does; the window layer mounts its page at once.
static func _open(main: Node, tab: String) -> Control:
	EventBus.tab_changed.emit(tab)
	return main._shell.find_child("CenterViewport", true, false).get_current_page_body()


## Clicks `emp`'s Kadro row as the player does and returns the row menu's item that reads `label`, or null.
static func _menu_item(main: Node, page: Control, emp: Character, label: String) -> Button:
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	(page._rows[emp.id] as Control).gui_input.emit(click)
	var item := func() -> Button:
		var pop: Node = _picker(main)
		var hits: Array = [] if pop == null else _buttons(pop, label)
		return null if hits.is_empty() else hits[0]
	await _until(main, func() -> bool: return item.call() != null)
	return item.call()


## The leads' Görüşmeye git as one reading: "open", "shut: <the reason every lead shows>" or what is mixed.
static func _gate(page: Control) -> String:
	var meet: Array = _buttons(page, TranslationServer.translate("SALES_ACTION_MEET"))
	if meet.is_empty():
		return "no lead"
	if meet.all(func(b: Button) -> bool: return not b.disabled):
		return "open"
	if meet.any(func(b: Button) -> bool: return not b.disabled):
		return "mixed"
	for reason in ["SITTING_BLOCK_EARLY", "SALES_BLOCK_TOO_LATE"]:
		var text: String = TranslationServer.translate(reason)
		if meet.all(func(b: Button) -> bool: return b.tooltip_text == text):
			return "shut: " + text
	return "shut, reason not on every lead"


## The board's rows of the sprint's own cards.
static func _board(page: Control, ids: Array) -> Array:
	return page.find_children("*", "BoardRow", true, false).filter(func(row: BoardRow) -> bool: return row.card.id in ids)


static func _buttons(root: Node, text: String) -> Array:
	return root.find_children("*", "Button", true, false).filter(func(b: Button) -> bool:
		return b.text == text or not _labels(b, text).is_empty())


static func _labels(root: Node, text: String) -> Array:
	return root.find_children("*", "Label", true, false).filter(func(l: Label) -> bool: return l.text == text)


## Awaits frames until `cond` holds; false once WAIT_FRAMES pass without it.
static func _until(main: Node, cond: Callable) -> bool:
	for _i in WAIT_FRAMES:
		if cond.call():
			return true
		await main.get_tree().process_frame
	return bool(cond.call())
