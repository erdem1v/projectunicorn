class_name PlayerPaths
extends RefCounted

# K2, the player's path: a case seeds a world the game can reach, mounts the real shell, drives it through the handler a
# click reaches and reads what the screen shows (a button's disabled state, a label's text). A rule tested only through an
# inner function can drift from the screen; here the screen is the witness. No pixels and no fixed waits: a case waits
# for its condition. `main` is the Main node, where the world seeds and the shell live.

const WAIT_FRAMES := 120


static func run(main: Node, case_id: String) -> String:
	match case_id:
		"hr_raise_row_locked_in_cooldown":
			return await _hr_raise_row_locked_in_cooldown(main)
		"sales_gate_follows_clock":
			return await _sales_gate_follows_clock(main)
		"sprint_fit_gets_points":
			return await _sprint_fit_gets_points(main)
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


## What the sprint screen draws, the sprint does: the founder alone at 15 hours plans Sprint 1 with the lead's plan. A card
## whose bar starts on the board's time axis inside week 1 (the second one starts on the first one's leftover) has work after
## week 1, and every card the board says finishes (the row's on-time tip) is done when the sprint closes. A sprint paper
## would stop a card on the player's answer, which no plan foresees, so the pinned world must stay without one.
static func _sprint_fit_gets_points(main: Node) -> String:
	main._seed_run_reproducible()
	main._seed_product_live("solo15")
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
	var layer: Node = main._shell.get_node("PanelLayer")
	var item := func() -> Button:
		var open: Array = layer.find_children("*", "HRPopover", true, false).filter(
			func(pop: Node) -> bool: return not pop.is_queued_for_deletion())
		var hits: Array = [] if open.is_empty() else _buttons(open[-1], label)
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
