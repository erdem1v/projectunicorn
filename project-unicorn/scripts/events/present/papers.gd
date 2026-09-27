class_name EvPapers
extends RefCounted

# THE DESK (GDD §12). A paper is a decision somebody is waiting on, and every one has a clock.
# "Süresi olmayan şey kağıt değildir" (§12.1) — which is why the model needs no capacity cap:
# papers leave on their own.
#
# EXPIRY IS NEVER SILENT (§12.4): on_expire runs, history records `expired`, and expire_note goes
# to the ticker with player-outcome priority. Lint enforces the trio (§17.7).
#
# The office's notice stack shows the first few papers and a "+N" badge past them. Which come
# first is decided here: ordered() sorts by urgency, so a paper inside its last
# EXPIRY_URGENT_DAYS leads the stack and cannot run its clock down behind the badge.
#
# Papers are keyed by EvLatches.key_of. The key is also the desk's id for the paper, so a click
# on its row opens the instance it shows.

## key -> {event_id, context, expires_on, arc_id, opened_before, admitted_day}
static var _papers: Dictionary = {}


static func place(event_id: String, context: Dictionary, expires_days: int,
		arc_id: String = "") -> void:
	_papers[EvLatches.key_of(event_id, context)] = {
		"event_id": event_id,
		"context": context.duplicate(true),
		# §12.5: an ABSOLUTE day, never "days remaining" — a counter that misses a tick (save,
		# speed change, load on a later day) is a paper that never expires.
		"expires_on": GameState.day + maxi(1, expires_days),
		"arc_id": arc_id,
		"opened_before": false,
		"admitted_day": GameState.day,
	}


static func remove(key: String) -> void:
	_papers.erase(key)


static func drop_arc(arc_id: String) -> void:
	if arc_id == "":
		return
	for key in _papers.keys():
		if String((_papers[key] as Dictionary)["arc_id"]) == arc_id:
			_papers.erase(key)


static func mark_opened(key: String) -> void:
	if _papers.has(key):
		(_papers[key] as Dictionary)["opened_before"] = true


# --- Time ------------------------------------------------------------------

static func days_left(key: String) -> int:
	if not _papers.has(key):
		return -1
	return int((_papers[key] as Dictionary)["expires_on"]) - GameState.day


static func is_expiring_soon(key: String) -> bool:
	var left: int = days_left(key)
	return left >= 0 and left <= EvTuning.EXPIRY_URGENT_DAYS


## Papers whose day has come, as their entries. §12.5: a paper whose day passed while the game
## was shut resolves on load — the clock ran whether the process did or not.
static func take_expired() -> Array:
	var expired: Array = []
	for key in _papers.keys():
		if int((_papers[key] as Dictionary)["expires_on"]) <= GameState.day:
			expired.append(_papers[key])
			_papers.erase(key)
	return expired


## Keys of the papers one day from expiry, for §12.4's last-warning interrupt. §20 B11: the
## warning comes first and the expiry the day after; if the warning cannot fire, the expiry
## still does.
static func needing_last_warning() -> Array:
	var out: Array = []
	for key in _papers:
		if days_left(key) == 1:
			out.append(key)
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


# --- Reading ---------------------------------------------------------------

static func has(key: String) -> bool:
	return _papers.has(key)


## The keys of the card's papers, one per subject.
static func keys_of(event_id: String) -> Array:
	return _papers.keys().filter(func(key): return event_id_of(key) == event_id)


static func event_id_of(key: String) -> String:
	return String((_papers.get(key, {}) as Dictionary).get("event_id", ""))


static func context_of(key: String) -> Dictionary:
	return (_papers.get(key, {}) as Dictionary).get("context", {})


static func arc_of(key: String) -> String:
	return String((_papers.get(key, {}) as Dictionary).get("arc_id", ""))


## §13.6: the dead-time floor only fires when the desk is CLEAR. An unanswered paper means the
## player is deferring, and filling a quiet stretch they created is how an engine starts nagging.
static func is_empty() -> bool:
	return _papers.is_empty()


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_papers.clear()


static func to_dict() -> Dictionary:
	return {"papers": _papers.duplicate(true)}


## A save that keyed its desk by card id, with no `event_id` in the entry, loads too: the key is
## rebuilt from the card and its context either way.
static func from_dict(d: Dictionary) -> void:
	reset()
	var saved: Dictionary = d.get("papers", {})
	for saved_key in saved:
		var entry: Dictionary = saved[saved_key]
		var event_id: String = String(entry.get("event_id", saved_key))
		if not EvCatalog.has_card(event_id):
			push_error("[EvPapers] dropping paper '%s' — no such card" % event_id)
			continue
		entry["event_id"] = event_id
		_papers[EvLatches.key_of(event_id, entry.get("context", {}))] = entry
