p = "scripts/debug/endgame_smoke.gd"
s = open(p, encoding="utf-8", newline="").read()

anchor = '\t\t"deal_prompt_is_inert":            fail = _case_deal_prompt_is_inert()'
assert s.count(anchor) == 1
s = s.replace(anchor, anchor + '\n\t\t"paid_tier_fires_day_after_launch": fail = _case_paid_tier_fires_day_after_launch()')

case = '''

## Surface 7's new trigger, and the primitive under it. The card used to fire on
## `audience_above 15`, which is why its copy claimed "birkaç yüz kişi" while the live value
## was typically sixteen. The document moved it to "one day after the product goes live", which
## needed a condition the vocabulary did not have: `days_since_flag`, generic over any stored
## day-flag (the hire nudge is day-plus-two, the negotiation window three, the answer counter
## thirty - the same question keeps being asked).
##
## Both halves are asserted. Firing on the launch day itself would be just as wrong as never
## firing, and only the negative half can catch an off-by-one in the comparison.
static func _case_paid_tier_fires_day_after_launch() -> String:
	const CARD := "ev_ps_b2c_paid_tier"
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2c")
	GameState.set_flag("mvp_launch_day", GameState.day)   # shipped today
	# Audience deliberately left at 0: under the old gate the card could not fire at all, so a
	# pass here also proves the trigger really did move off `audience_above`.
	_sim_day()   # launch day + 1 → the card is due
	if _instances_of(CARD) == 0:
		return "the paid-tier card did not fire the day after launch"
	_drain_all_modals()
	# The negative half, from a clean latch: on the launch day itself it must NOT be due.
	EventManager.reset()
	GameState.set_flag("mvp_launch_day", GameState.day + 1)   # ships tomorrow
	_sim_day()
	if _instances_of(CARD) != 0:
		return "the card fired on (or before) the launch day itself"
	# And an absent flag is FALSE, never day 0 - a run with no product must not satisfy
	# "one day after it shipped".
	EventManager.reset()
	GameState.flags.erase("mvp_launch_day")
	_sim_day()
	if _instances_of(CARD) != 0:
		return "the card fired with no launch day stamped at all"
	return ""
'''
s = s.rstrip("\n") + "\n" + case
open(p, "w", encoding="utf-8", newline="").write(s)
print("case added")
