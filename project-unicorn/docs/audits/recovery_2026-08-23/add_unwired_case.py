p = "scripts/debug/endgame_smoke.gd"
s = open(p, encoding="utf-8", newline="").read()

anchor = '\t\t"paid_tier_fires_day_after_launch": fail = _case_paid_tier_fires_day_after_launch()'
assert s.count(anchor) == 1
s = s.replace(anchor, anchor + '\n\t\t"unwired_dir_is_never_pooled":     fail = _case_unwired_dir_is_never_pooled()')

case = '''

## The other half of the inertness proof (Frank v6). `loc_event_en_coverage` shows the loader's
## sibling directory IS audited for both locales; this shows the loader itself never reads it.
##
## Directly, not by inference: read every id sitting in data/events/unwired/ off disk, then
## assert none of them is in the live pool. If someone ever adds `unwired/` to the scan, or
## moves a card without giving it a trigger, this goes red instead of the card appearing in
## front of a player on day 1.
static func _case_unwired_dir_is_never_pooled() -> String:
	const BASE := "res://data/events/unwired"
	var dir := DirAccess.open(BASE)
	if dir == null:
		return "cannot open " + BASE + " — the held-back text is not where it is documented to be"
	var ids: Array[String] = []
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if entry.ends_with(".json"):
			var f := FileAccess.open(BASE + "/" + entry, FileAccess.READ)
			if f == null:
				return "%s unreadable" % entry
			var parsed: Variant = JSON.parse_string(f.get_as_text())
			if typeof(parsed) != TYPE_DICTIONARY:
				return "%s is not a JSON object" % entry
			ids.append(String((parsed as Dictionary).get("id", "")))
		entry = dir.get_next()
	dir.list_dir_end()
	if ids.is_empty():
		return "no held-back cards found — the scan is not looking where it thinks"
	for id in ids:
		if EventManager._all_events.has(id):
			return "%s is IN THE LIVE POOL — the unwired directory is being loaded" % id
	# And it stays out across a full month of ticks, not just at boot.
	_seed_b2c()
	for i in 30:
		_sim_day()
		for id in ids:
			if _instances_of(id) != 0:
				return "%s reached the queue on day %d" % [id, GameState.day]
	return ""
'''
s = s.rstrip("\n") + "\n" + case
open(p, "w", encoding="utf-8", newline="").write(s)
print("case added")
