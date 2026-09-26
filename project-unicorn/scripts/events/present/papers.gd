class_name EvPapers
extends RefCounted

# THE DESK (GDD §12). A paper is a decision somebody is waiting on, and every one has a clock.
# "Süresi olmayan şey kağıt değildir" (§12.1) — which is why the model needs no capacity cap:
# papers leave on their own.
#
# EXPIRY IS NEVER SILENT (§12.4): on_expire runs, history records `expired`, and expire_note goes
# to the ticker with player-outcome priority. Lint enforces the trio (§17.7).
#
# The ODA art has three paper positions and the view shows a "+N" chip past them. Which three
# is decided here: ordered() sorts by urgency, so a paper inside its last EXPIRY_URGENT_DAYS is
# always visible and cannot run its clock down behind the chip.

## event_id -> {context, expires_on, arc_id, opened_before, admitted_day}
static var _papers: Dictionary = {}


static func place(event_id: String, context: Dictionary, expires_days: int,
		arc_id: String = "") -> void:
	_papers[event_id] = {
		"context": context.duplicate(true),
		# §12.5: an ABSOLUTE day, never "days remaining" — a counter that misses a tick (save,
		# speed change, load on a later day) is a paper that never expires.
		"expires_on": GameState.day + maxi(1, expires_days),
		"arc_id": arc_id,
		"opened_before": false,
		"admitted_day": GameState.day,
	}


static func remove(event_id: String) -> void:
	_papers.erase(event_id)


static func drop_arc(arc_id: String) -> void:
	if arc_id == "":
		return
	for event_id in _papers.keys():
		if String((_papers[event_id] as Dictionary)["arc_id"]) == arc_id:
			_papers.erase(event_id)


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


## Papers whose day has come. §12.5: a paper whose day passed while the game was shut resolves
## on load — the clock ran whether the process did or not.
static func take_expired() -> Array:
	var expired: Array = []
	for event_id in _papers.keys():
		if int((_papers[event_id] as Dictionary)["expires_on"]) <= GameState.day:
			expired.append({"event_id": event_id, "entry": _papers[event_id]})
			_papers.erase(event_id)
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

## Most urgent first, ties by admission day then id.
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
	return ordered().slice(0, slots)


static func overflow_count(slots: int) -> int:
	return maxi(0, _papers.size() - slots)


# --- Reading ---------------------------------------------------------------

static func has(event_id: String) -> bool:
	return _papers.has(event_id)


static func ids() -> Array:
	return ordered()


static func context_of(event_id: String) -> Dictionary:
	return (_papers.get(event_id, {}) as Dictionary).get("context", {})


static func arc_of(event_id: String) -> String:
	return String((_papers.get(event_id, {}) as Dictionary).get("arc_id", ""))


## §13.6: the dead-time floor only fires when the desk is CLEAR. An unanswered paper means the
## player is deferring, and filling a quiet stretch they created is how an engine starts nagging.
static func is_empty() -> bool:
	return _papers.is_empty()


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_papers.clear()


static func to_dict() -> Dictionary:
	return {"papers": _papers.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	reset()
	var saved: Dictionary = d.get("papers", {})
	for event_id in saved:
		if not EvCatalog.has_card(String(event_id)):
			push_error("[EvPapers] dropping paper '%s' — no such card" % event_id)
			continue
		_papers[event_id] = saved[event_id]
