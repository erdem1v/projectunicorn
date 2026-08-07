class_name RngStreams
extends RefCounted

# Named RNG streams — the resumable replacement for the one global seed (TECH_SPEC §10.4).
#
# WHY THIS EXISTS. Determinism used to mean "GameState.initialize_run calls seed(run_seed)
# once and every draw site shares that one stream". That gives replay from BIRTH but it can
# never give replay from a SAVE, because Godot exposes no way to read the global RNG's
# position: a save could store the initial seed and still not know how many draws had been
# spent. Sharing also coupled unrelated systems — HRMoraleSystem's header already records
# that it grew its own generator precisely so a resignation roll could not displace an event
# roll and silently flip a long-horizon smoke case.
#
# Each stream is a RandomNumberGenerator seeded `run_seed ^ <name>.hash()` and serialised as
# {seed, state}. `state` is what makes a load resume the SEQUENCE rather than restart it.
#
# STREAMS AND THEIR SITES (the complete list — a new draw site joins a stream, it does not
# open a bare randf()):
#   events    — EventManager: per-priority group shuffle, the "random" trigger condition,
#               and the ambient hourly roll.
#   skill     — SkillCheck.roll_against / SkillCheck.resolve (every founder skill check,
#               including the Term Sheet table's externally-composed odds).
#   hr_morale — HRMoraleSystem's resignation roll (this module absorbed the private _rng
#               that file used to own; the salt is unchanged in spirit, see RNG_SALT there).
#
# SEED/STATE ARE STORED AS STRINGS. Both are uint64 on the engine side, and JSON numbers are
# IEEE doubles — anything past 2^53 would come back rounded, i.e. a stream that resumes one
# draw away from where it stopped. str()/to_int() round-trips the full int64 bit pattern.

const STREAM_EVENTS := "events"
const STREAM_SKILL := "skill"
const STREAM_HR_MORALE := "hr_morale"
const STREAM_IDS: Array[String] = [STREAM_EVENTS, STREAM_SKILL, STREAM_HR_MORALE]

static var _streams: Dictionary = {}   # id (String) -> RandomNumberGenerator
static var _seeded_for: int = -1       # run_seed the streams are currently keyed to


# --- Access ---

static func get_stream(id: String) -> RandomNumberGenerator:
	# THE accessor. Self-seeding (same belt-and-braces shape HRMoraleSystem._ensure_seeded
	# used): a draw that happens before initialize_run — or after a re-key — still lands on a
	# generator keyed to the CURRENT run_seed rather than the previous run's.
	_ensure_seeded()
	var rng: RandomNumberGenerator = _streams.get(id, null)
	if rng == null:
		push_error("[RngStreams] unknown stream '%s' — see STREAM_IDS" % id)
		rng = _streams[STREAM_EVENTS]
	return rng


static func shuffle(id: String, arr: Array) -> void:
	# Array.shuffle() draws from the GLOBAL generator, which is exactly the coupling this
	# module exists to remove — so the shuffle is rebuilt here on the named stream.
	# Fisher-Yates, in place, identical distribution.
	var rng: RandomNumberGenerator = get_stream(id)
	for i in range(arr.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		if j != i:
			var tmp: Variant = arr[i]
			arr[i] = arr[j]
			arr[j] = tmp


# --- Lifecycle ---

static func reseed(run_seed: int) -> void:
	# Re-key every stream from a run seed. Assigning `seed` also RESETS the generator's
	# state, so the same run_seed always replays the same sequence from birth.
	for id in STREAM_IDS:
		var rng: RandomNumberGenerator = _streams.get(id, null)
		if rng == null:
			rng = RandomNumberGenerator.new()
			_streams[id] = rng
		rng.seed = run_seed ^ id.hash()
	_seeded_for = run_seed


static func reset() -> void:
	# Run-boundary reset (SaveManager.reset_all_owners). Drops the generators entirely rather
	# than re-keying them, so the next get_stream() rebuilds from whatever run_seed is live by
	# then — which on the load path is the SAVED seed, assigned by initialize_run before any
	# system draws.
	_streams.clear()
	_seeded_for = -1


static func _ensure_seeded() -> void:
	if _seeded_for == GameState.run_seed and _streams.size() == STREAM_IDS.size():
		return
	reseed(GameState.run_seed)


# --- Serialization ---

static func to_dict() -> Dictionary:
	# {id: {seed: "<int64>", state: "<int64>"}}. Called at save time; _ensure_seeded is NOT
	# invoked here on purpose — if nothing has drawn yet there is nothing to resume, and an
	# empty payload restores as "seed from run_seed", which is the same sequence.
	var out: Dictionary = {}
	for id in STREAM_IDS:
		var rng: RandomNumberGenerator = _streams.get(id, null)
		if rng == null:
			continue
		out[id] = {"seed": str(rng.seed), "state": str(rng.state)}
	return out


static func from_dict(d: Dictionary) -> void:
	# Restore position. Streams absent from the payload (older save, or a stream that never
	# drew) are left to _ensure_seeded, which keys them off the restored run_seed.
	for id in STREAM_IDS:
		var entry: Variant = d.get(id, null)
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var rng: RandomNumberGenerator = _streams.get(id, null)
		if rng == null:
			rng = RandomNumberGenerator.new()
			_streams[id] = rng
		# Order matters: `seed` resets `state`, so state must be written second.
		rng.seed = String((entry as Dictionary).get("seed", "0")).to_int()
		rng.state = String((entry as Dictionary).get("state", "0")).to_int()
	_seeded_for = GameState.run_seed
