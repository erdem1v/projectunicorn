class_name RngStreams
extends RefCounted

# Named RNG streams, resumable from a save. Godot cannot read the global RNG's position, so a
# save could never resume it; separate streams also keep one system's draws from displacing
# another's.
#
# Each stream is a RandomNumberGenerator seeded `run_seed ^ <name>.hash()` and serialised as
# {seed, state}; `state` makes a load resume the SEQUENCE rather than restart it.
#
# Draw sites (a new site joins a stream, it does not open a bare randf()):
#   skill     — SkillCheck.roll_against / SkillCheck.resolve.
#   hr_morale — HRMoraleSystem's resignation roll.
#
# Seed/state are stored as STRINGS: both are 64-bit, and JSON numbers are doubles, so anything
# past 2^53 would come back rounded. str()/to_int() round-trips the full bit pattern.

const STREAM_SKILL := "skill"
const STREAM_HR_MORALE := "hr_morale"
const STREAM_IDS: Array[String] = [STREAM_SKILL, STREAM_HR_MORALE]

static var _streams: Dictionary = {}   # id (String) -> RandomNumberGenerator
static var _seeded_for: int = -1       # run_seed the streams are currently keyed to


## Self-seeding: a draw before initialize_run, or after a re-key, still lands on a generator
## keyed to the CURRENT run_seed.
static func get_stream(id: String) -> RandomNumberGenerator:
	if _seeded_for != GameState.run_seed or _streams.size() != STREAM_IDS.size():
		reseed(GameState.run_seed)
	return _streams[id]


## Assigning `seed` also resets the generator's state, so a run_seed always replays from birth.
static func reseed(run_seed: int) -> void:
	for id in STREAM_IDS:
		_stream_for(id).seed = run_seed ^ id.hash()
	_seeded_for = run_seed


## Run-boundary reset (SaveManager.reset_all_owners). Dropping the generators lets the next
## get_stream() key them off whatever run_seed is live by then (the SAVED seed on a load).
static func reset() -> void:
	_streams.clear()
	_seeded_for = -1


static func _stream_for(id: String) -> RandomNumberGenerator:
	if not _streams.has(id):
		_streams[id] = RandomNumberGenerator.new()
	return _streams[id]


# --- Serialization ---

## {id: {seed, state}}. Does not self-seed: a stream that never drew has nothing to resume,
## and restoring without it seeds from run_seed, which is the same sequence.
static func to_dict() -> Dictionary:
	var out: Dictionary = {}
	for id in STREAM_IDS:
		var rng: RandomNumberGenerator = _streams.get(id, null)
		if rng != null:
			out[id] = {"seed": str(rng.seed), "state": str(rng.state)}
	return out


## Streams absent from the payload are keyed off the restored run_seed on first draw.
static func from_dict(d: Dictionary) -> void:
	for id in STREAM_IDS:
		var entry: Variant = d.get(id, null)
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var rng: RandomNumberGenerator = _stream_for(id)
		# `seed` resets `state`, so state is written second.
		rng.seed = String((entry as Dictionary).get("seed", "0")).to_int()
		rng.state = String((entry as Dictionary).get("state", "0")).to_int()
	_seeded_for = GameState.run_seed
