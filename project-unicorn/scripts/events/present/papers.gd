class_name EvPapers
extends RefCounted

# THE DESK (GDD §12). A paper is a decision somebody is waiting on, and every one of them has
# a clock.
#
# §12.1 IS THE WHOLE DESIGN IN ONE LINE: "Süresi olmayan şey kağıt değildir." A paper is
# something a person is waiting for an answer to. If nobody is waiting, it is not a decision —
# it is information, and information belongs on a tab or in the ticker. That rule is why the
# desk needs no capacity cap: papers leave on their own.
#
# EXPIRY IS NEVER SILENT (§12.4). on_expire runs, history records `expired`, and expire_note
# goes to the ticker with player-outcome priority. The lint rules are the teeth: class: paper
# without expires_days is an error, expires_days without on_expire is an error, on_expire
# without expire_note is an error (§17.7). A consequence the player cannot see did not happen.
#
# TWO THINGS THIS FILE HANDLES THAT THE GDD LEAVES OPEN
#
#   The desk has three slots, not infinity. §11.4 says the desk needs no cap, and the MODEL
#   here has none — but the sealed ODA art has exactly three paper positions
#   (oda_layout.gd:198) and oda_view.gd already renders a "+N" overflow chip past them. So
#   papers are uncapped and the VIEW shows three; which three is this file's decision, not the
#   view's.
#
#   Which means an overflow paper could run its clock down where the player cannot see it.
#   That is a consequence landing off-screen, and it is not acceptable (approved amendment A3).
#   So urgency wins a slot: any paper inside EXPIRY_URGENT_DAYS is promoted into the visible
#   three, displacing the least urgent. A paper cannot expire while hidden.

## event_id -> {context, expires_on, arc_id, class, opened_before, admitted_day}
static var _papers: Dictionary = {}


# --- Placing ---------------------------------------------------------------

static func place(event_id: String, context: Dictionary, expires_days: int,
		arc_id: String = "") -> void:
	_papers[event_id] = {
		"context": context.duplicate(true),
		# §12.5: stored as an ABSOLUTE day, never as "days remaining". A remaining-day counter
		# would have to be ticked, and a tick that does not happen — a save, a speed change, a
		# load on a later day — is a paper that never expires.
		"expires_on": GameState.day + maxi(1, expires_days),
		"arc_id": arc_id,
		"opened_before": false,
		"admitted_day": GameState.day,
	}


static func remove(event_id: String) -> void:
	_papers.erase(event_id)


static func drop_arc(arc_id: String) -> int:
	if arc_id == "":
		return 0
	var doomed: Array = []
	for event_id in _papers:
		if String((_papers[event_id] as Dictionary)["arc_id"]) == arc_id:
			doomed.append(event_id)
	for event_id in doomed:
		_papers.erase(event_id)
	return doomed.size()


static func mark_opened(event_id: String) -> void:
	if _papers.has(event_id):
		(_papers[event_id] as Dictionary)["opened_before"] = true


# --- Time ------------------------------------------------------------------

static func days_left(event_id: String) -> int:
	if not _papers.has(event_id):
		return -1
	return int((_papers[event_id] as Dictionary)["expires_on"]) - GameState.day


static func is_expiring_soon(event_id: String) -> bool:
	var left: int = days_left(event_id)
	return left >= 0 and left <= EvTuning.EXPIRY_URGENT_DAYS


## Papers whose day has come. §12.5: on load, a paper whose day passed while the game was shut
## resolves immediately rather than lingering — the clock ran whether the process did or not.
static func take_expired() -> Array:
	var expired: Array = []
	for event_id in _papers.keys():
		if int((_papers[event_id] as Dictionary)["expires_on"]) <= GameState.day:
			expired.append({"event_id": event_id, "entry": _papers[event_id]})
	for e in expired:
		_papers.erase(String((e as Dictionary)["event_id"]))
	return expired


## Papers one day from expiry, for §12.4's last-warning interrupt. §20 B11: the warning comes
## first and the expiry the day after; if the warning cannot fire, the expiry still does.
static func needing_last_warning() -> Array:
	var out: Array = []
	for event_id in _papers:
		if days_left(event_id) == 1:
			out.append(event_id)
	out.sort()
	return out


# --- What the desk shows ---------------------------------------------------

## Ordered for display: most urgent first, ties by admission day then id.
##
## The first `visible_slots` of this list are what the desk renders; the rest sit behind the
## overflow chip. Because the sort is urgency-first, a paper inside its last three days is
## always in the visible set — which is amendment A3's requirement, enforced by the ordering
## rather than by a special case that could be forgotten.
static func ordered() -> Array:
	var ids: Array = _papers.keys()
	ids.sort_custom(func(a, b):
		var la: int = days_left(a)
		var lb: int = days_left(b)
		if la != lb:
			return la < lb
		var da: int = int((_papers[a] as Dictionary)["admitted_day"])
		var db: int = int((_papers[b] as Dictionary)["admitted_day"])
		if da != db:
			return da < db
		return String(a) < String(b))
	return ids


static func visible(slots: int) -> Array:
	var all_ids: Array = ordered()
	return all_ids.slice(0, mini(slots, all_ids.size()))


static func overflow_count(slots: int) -> int:
	return maxi(0, _papers.size() - slots)


# --- Reading ---------------------------------------------------------------

static func has(event_id: String) -> bool:
	return _papers.has(event_id)


static func size() -> int:
	return _papers.size()


static func ids() -> Array:
	return ordered()


static func context_of(event_id: String) -> Dictionary:
	return (_papers.get(event_id, {}) as Dictionary).get("context", {})


static func arc_of(event_id: String) -> String:
	return String((_papers.get(event_id, {}) as Dictionary).get("arc_id", ""))


static func entry(event_id: String) -> Dictionary:
	return (_papers.get(event_id, {}) as Dictionary).duplicate(true)


## §13.6: the dead-time floor only fires when the desk is CLEAR. An unanswered paper means the
## player is deferring, not that the game has gone quiet, and filling a quiet stretch the
## player created themselves is how an engine starts nagging.
static func is_empty() -> bool:
	return _papers.is_empty()


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_papers.clear()


static func to_dict() -> Dictionary:
	return {"papers": _papers.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	reset()
	for event_id in (d.get("papers", {}) as Dictionary):
		if not EvCatalog.has_card(String(event_id)):
			push_error("[EvPapers] dropping paper '%s' — no such card" % event_id)
			continue
		_papers[event_id] = (d["papers"] as Dictionary)[event_id]
