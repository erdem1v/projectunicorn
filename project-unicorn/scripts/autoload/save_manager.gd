extends Node

# Save / load orchestration and slot management (TECH_SPEC §6.1, §10).
#
# Division of labour: SaveCodec translates state ⇄ JSON and owns no policy; this file owns
# the policy — when a save is legal, where the bytes go, how a slot is named, what an
# autosave costs, and what a load does to a live process.
#
# ============================================================================
#  THE HARD HALF: LOAD MUST DO WHAT AN OS RESTART USED TO DO
# ============================================================================
# GameState.initialize_run touches ~70 fields and deliberately touches NOTHING else — not
# EventManager, not the customer/prospect/rival registries, not ProductSystem.active_build,
# not FinanceSystem's statics, not PhaseGateSystem's cached gate scene, not the four
# meeting-local static sets. That was never a bug while "TEKRAR DENE" meant relaunching the
# process; several of those files SAY SO in their own comments ("static var reset'i süreç
# relaunch'una dayanır ... in-place seam SaveManager'ın işi"). The 2026-08-06 audit's Group 9
# calls the whole pattern reset-and-persistence debt.
#
# Loading turns that debt due, because a load has to put a RUNNING PROCESS into a state only
# a restart could previously produce. Every owner missed leaks the old run into the new one
# and surfaces days later as an impossible bug — a build nobody committed, a churn counter
# for a company that never signed, one-shot beats already consumed. Hence reset_all_owners()
# below: seventeen owners, one entry point, ordered.
#
# RESET IS THE PRODUCT; SAVE IS THE RECEIPT.
#
# ============================================================================
#  WHY THE SITTING-SCOPED SYSTEMS ARE RESET AND NOT SERIALISED
# ============================================================================
# VCPitchSystem (11 statics), TermSheetTableSystem (11), PitchSystem (7) and B2BPitchMeeting
# (4) hold meeting-local state — conviction, beat, intel, patience, the working term copy.
# None of it is saved. That is not a carve-out, it is the same statement as can_save():
# saving is REFUSED while any of those four is_active(), so a sitting is provably idle at
# every point a save can be taken, and there is nothing mid-resolution for a schema to
# describe. One sitting, one sitting only — it does not survive closing the game.

const SCHEMA_VERSION := 3   # v2: ASCII sector ids · v3: prospect need lines became indices
const SAVE_DIR := "user://saves/"

# Slot ids are also FILENAMES on disk, i.e. a compatibility surface. Named once so a rename
# is one edit rather than a hunt through string literals in three files.
const QUICK_SLOT_ID := "quick"
const AUTO_SLOT_IDS: Array[String] = ["auto_1", "auto_2", "auto_3"]
const MANUAL_SLOT_PREFIX := "manual_"

# Settings key owned by the Settings agent; values "off" | "daily" | "weekly" | "monthly".
const SETTING_AUTOSAVE_FREQUENCY := "autosave_frequency"
const AUTOSAVE_FREQUENCY_DEFAULT := "weekly"                       # [WORKING]
const AUTOSAVE_INTERVAL_DAYS := {"off": 0, "daily": 1, "weekly": 7, "monthly": 30}   # [WORKING]

# Real-time floor between two autosaves. THE SPEED LADDER MAKES THIS NECESSARY, not
# paranoid: TimeManager.SECONDS_PER_DAY is [0, 12, 6, 3, 1.5] REAL SECONDS PER IN-GAME DAY,
# so at 4x a day is 1.5 s and "Her gün" would try to write ~40 saves a minute — each one a
# full state walk plus three file operations. Skipped writes become pending and land at the
# next safe boundary, so nothing is lost, only coalesced.
const AUTOSAVE_MIN_REAL_SECONDS := 20                              # [WORKING]

# Public: the lead's debug harnesses can switch autosave off explicitly. Defaults from a
# command-line sniff so the smoke suite and the screenshot harnesses — which drive hundreds
# of daily ticks in seconds — never write save files as a side effect of a test.
var autosave_enabled: bool = true

var _autosave_pending: bool = false
var _last_autosave_day: int = -1
var _last_autosave_msec: int = 0
# "Days have been played since the last save." Set by the day-tick boundary, cleared by any
# successful save and by a load (right after a load, nothing new has been played yet).
var _dirty: bool = false


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	# day_tick_completed, NOT day_advanced. day_advanced fires inside GameState.advance_day()
	# BEFORE TimeManager dispatches the twelve daily slots, so an autosave hung off it would
	# snapshot the new day number against yesterday's product, finance, sales and event
	# state — a save that is wrong about the very day it claims to be.
	EventBus.day_tick_completed.connect(_on_day_tick_completed)
	autosave_enabled = not _is_harness_run()


# ============================================================================
#  Queries
# ============================================================================

func can_save() -> bool:
	# Checked against WHAT ACTUALLY HOLDS UNSERIALISABLE STATE, not against "is a modal on
	# screen". The obvious implementation — refuse when GameShell/ModalLayer has children —
	# would make the feature permanently dead, because the Kaydet button lives inside the ESC
	# system menu, which is itself a ModalLayer child.
	#
	# No scene lookups anywhere in this function (TECH_SPEC §6.2: singletons never reference
	# scene nodes). Each condition names a real owner of mid-resolution state:
	if not GameState.run_active:
		return false                          # no run, or a terminal already fired
	# The ACTIVE event only — deliberately NOT has_pending(), which is
	# `_active_event_id != "" or not _queue.is_empty()`. Gating on the queue as well
	# looks safer and is in fact self-defeating: EventManager.to_dict serialises the
	# queue (event_manager.gd:272), so refusing to save whenever the queue is non-empty
	# guarantees every save on disk carries an EMPTY queue and makes that serialisation
	# unreachable code. Worse, it silently drops queued beats — a scheduled scene the
	# player has not seen yet would vanish across a save/load.
	# What the rule actually protects is mid-RESOLUTION state: a choice presented and
	# not yet answered. That is exactly `_active_event_id`. A queued event is data, and
	# data is what a save is for.
	if EventManager._active_event_id != "":
		return false                          # an event modal is up, awaiting a choice
	if VCPitchSystem.is_active():
		return false
	if TermSheetTableSystem.is_active():
		return false
	if PitchSystem.is_active():
		return false
	if B2BPitchMeeting.is_active():
		return false
	return true


func cannot_save_reason_key() -> String:
	# "" when can_save(). Localisation keys only — never a hardcoded sentence.
	if not GameState.run_active:
		return "SAVE_ERR_NO_RUN"
	if EventManager._active_event_id != "" \
			or VCPitchSystem.is_active() or TermSheetTableSystem.is_active() \
			or PitchSystem.is_active() or B2BPitchMeeting.is_active():
		return "SAVE_ERR_MODAL_OPEN"
	return ""


func has_unsaved_progress() -> bool:
	# Drives the quit / load confirms. Day-granular by construction: _dirty is raised at the
	# day-tick boundary, which is also the only boundary a save can be taken at.
	return GameState.run_active and _dirty


func next_manual_slot_id() -> String:
	var highest: int = 0
	for row in list_slots():
		var sid: String = String(row.get("slot_id", ""))
		if sid.begins_with(MANUAL_SLOT_PREFIX):
			highest = maxi(highest, sid.trim_prefix(MANUAL_SLOT_PREFIX).to_int())
	return "%s%d" % [MANUAL_SLOT_PREFIX, highest + 1]


func list_slots() -> Array:
	# Newest first. UNLOADABLE ROWS STILL APPEAR, with their reason: a save that silently
	# vanishes from the list is worse than one that says it is broken — the player would
	# conclude the game ate it rather than that one file needs replacing.
	var rows: Array = []
	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		return rows
	dir.list_dir_begin()
	var filename: String = dir.get_next()
	while filename != "":
		if not dir.current_is_dir() and filename.ends_with(".json"):
			rows.append(_slot_row(filename.trim_suffix(".json")))
		filename = dir.get_next()
	dir.list_dir_end()
	rows.sort_custom(func(a, b): return int(a.get("unix_time", 0)) > int(b.get("unix_time", 0)))
	return rows


# ============================================================================
#  Reads
# ============================================================================

func read_slot(slot_id: String) -> Dictionary:
	# PURE READ + SCHEMA GATE. MUTATES NOTHING — that split is the whole point: the modal
	# must be able to validate a file and show its error without having already half
	# destroyed the live run to find out.
	var path: String = _path_for(slot_id)
	if not FileAccess.file_exists(path):
		return {"ok": false, "error_key": "SAVE_ERR_CORRUPT", "meta": {}, "state": {}}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "error_key": "SAVE_ERR_CORRUPT", "meta": {}, "state": {}}
	# JSON.new().parse() rather than the JSON.parse_string() shortcut: the shortcut
	# push_errors on a malformed file, so a player with one corrupt save would get red
	# engine errors in the log every time the slot list is drawn — and list_slots() parses
	# every file it finds. A corrupt save is a HANDLED condition here, not an engine fault;
	# it comes back as SAVE_ERR_CORRUPT and says so on the row.
	var json := JSON.new()
	var parse_err: int = json.parse(file.get_as_text())
	file.close()
	if parse_err != OK or typeof(json.data) != TYPE_DICTIONARY:
		return {"ok": false, "error_key": "SAVE_ERR_CORRUPT", "meta": {}, "state": {}}
	var data: Dictionary = json.data as Dictionary
	var version: int = int(data.get("schema_version", 0))
	if version > SCHEMA_VERSION:
		# A NEWER schema refuses GRACEFULLY. Never a crash, and never the worse failure —
		# a silent partial load, where the fields this build understands come back and the
		# ones it does not are quietly left at defaults, producing a run that looks fine and
		# is wrong. Forward-compat runs one way only: older saves into newer builds.
		return {"ok": false, "error_key": "SAVE_ERR_NEWER", "meta": data.get("meta", {}), "state": {}}
	if typeof(data.get("state", null)) != TYPE_DICTIONARY:
		return {"ok": false, "error_key": "SAVE_ERR_CORRUPT", "meta": data.get("meta", {}), "state": {}}
	if version < 2:
		_migrate_sector_ids(data["state"])
	if version < 3:
		_migrate_prospect_needs(data["state"])
	return {
		"ok": true,
		"error_key": "",
		"meta": data.get("meta", {}) as Dictionary,
		"state": data.get("state", {}) as Dictionary,
	}


# ============================================================================
#  Writes
# ============================================================================

func save_to_slot(slot_id: String) -> bool:
	if not can_save():
		push_warning("[SaveManager] save refused: %s" % cannot_save_reason_key())
		return false
	var payload := {
		"schema_version": SCHEMA_VERSION,
		"game_version": _game_version(),
		"meta": build_meta(),
		"state": {
			"game_state": SaveCodec.capture_game_state(),
			"registries": SaveCodec.capture_registries(),
			"systems": _capture_systems(),
		},
	}
	if not _write_atomic(_path_for(slot_id), JSON.stringify(payload, "\t")):
		return false
	_dirty = false
	if OS.is_debug_build():
		print("[SaveManager] saved '%s' (day %d)" % [slot_id, GameState.day])
	return true


func quicksave() -> bool:
	return save_to_slot(QUICK_SLOT_ID)


func delete_slot(slot_id: String) -> bool:
	var ok: bool = true
	for path in [_path_for(slot_id), _path_for(slot_id) + ".bak"]:
		if FileAccess.file_exists(path) and DirAccess.remove_absolute(path) != OK:
			ok = false
	return ok


func build_meta() -> Dictionary:
	# Everything the slot list renders, so listing N saves costs N small parses and never a
	# full state walk. cash/mrr stay plain ints — main.gd runs them through
	# UiTokens.format_money() itself, and a pre-formatted string would freeze one locale's
	# money format into the file.
	return {
		"company_name": GameState.company_name,
		"day": GameState.day,
		"phase": GameState.phase,
		"phase_name": GameState.phase_display_name(GameState.phase),
		"cash": GameState.cash,
		"mrr": GameState.mrr,
		"unix_time": int(Time.get_unix_time_from_system()),
		"schema_version": SCHEMA_VERSION,
		"game_version": _game_version(),
	}


# ============================================================================
#  Load
# ============================================================================

func apply_loaded_state(payload: Dictionary) -> bool:
	# Accepts the WHOLE dict read_slot returned (ok / error_key / meta / state), and also
	# tolerates a bare state block, so a caller cannot get it subtly wrong in a way that
	# loads a run with every field at its default.
	var state: Dictionary = payload
	if payload.has("state") and typeof(payload["state"]) == TYPE_DICTIONARY:
		state = payload["state"] as Dictionary
	if state.is_empty():
		push_error("[SaveManager] apply_loaded_state called with no state block")
		return false

	# The clock is stopped for the whole rebuild. main.gd has just freed the shell, so
	# NOTHING is holding a pause, and TimeManager._process is still live — a single frame
	# landing between "registries reset" and "registries restored" would tick a day against
	# a half-built world. Speed 0 would not do: speed is player state this load restores.
	TimeManager.set_suspended(true)

	reset_all_owners()

	# ONE init path, not two. initialize_run lays down the fresh-run baseline and then
	# applies the save over it, which is what makes a field the save does not carry fall
	# back to a sane default instead of null — the forward-compat story, with no migration
	# code. It runs with no shell in the tree, exactly as onboarding does, so its "direct
	# writes, no listeners exist" assumption is preserved rather than worked around.
	var gs_block: Dictionary = state.get("game_state", {}) as Dictionary
	GameState.initialize_run({
		"seed": int(gs_block.get("run_seed", 0)),
		"restore": state,
	})

	# Registries before systems: ProductSystem/EventManager restore into a world whose
	# people and accounts already exist, and PhaseGateSystem's rebuild reads GameState.
	SaveCodec.restore_registries(state)
	_restore_systems(state)

	TimeManager.set_suspended(false)
	_dirty = false
	_autosave_pending = false
	_last_autosave_day = GameState.day
	if OS.is_debug_build():
		print("[SaveManager] loaded run: day %d, phase %d, seed %d"
			% [GameState.day, GameState.phase, GameState.run_seed])
	return true


func reset_all_owners() -> void:
	# THE seventeen owners, one entry point. Ordered against the autoload order
	# (EventBus → GameState → registries → EventManager → TimeManager) with the RefCounted
	# static systems folded in where their dependencies sit.
	#
	# EventBus itself is not reset: it is a signal hub with no state. GameState is not reset
	# here either — initialize_run is its reset, and calling both would just do the work twice.

	# 1. Clock first. Everything below leaves the world briefly inconsistent, and a
	#    suspended, speed-1, hour-9 TimeManager cannot tick into the middle of it.
	TimeManager.reset()

	# 2. Registries, in the order SaveCodec restores them. Each is a direct clear with no
	#    signals — the shell is not in the tree, and CustomerRegistry in particular must not
	#    emit customer_removed, which PromiseRegistry turns into promise drops.
	CharacterRegistry.reset()
	CustomerRegistry.reset()
	ProspectRegistry.reset()
	RivalRegistry.reset()          # re-seeds from RivalCatalog: an empty field is not valid state
	PromiseRegistry.reset()

	# 3. Event pipeline. After the registries so nothing queued can reference a record that
	#    is about to be cleared.
	EventManager.reset()

	# 4. Static systems. ProductSystem and FinanceSystem are the two whose own comments
	#    named this seam as future work; PhaseGateSystem drops its cached Frank scene.
	ProductSystem.reset()
	FinanceSystem.reset()
	PhaseGateSystem.reset()
	HRSystem.reset()               # → HRMoraleSystem (_pending + RNG key) + HROvertimeSystem

	# 5. The four sitting-scoped systems — reset, never serialised (see the header).
	PitchSystem.reset()
	B2BPitchMeeting.reset()
	VCPitchSystem.reset()
	TermSheetTableSystem.reset()

	# 6. RNG last, so nothing above can draw from a stream that is about to be re-keyed.
	RngStreams.reset()


# ============================================================================
#  System routing (each owner serialises itself; this only orders the calls)
# ============================================================================

func _capture_systems() -> Dictionary:
	return {
		"product": ProductSystem.to_dict(),
		"finance": FinanceSystem.to_dict(),
		"events": EventManager.to_dict(),
		"hr": HRSystem.to_dict(),
		"time": TimeManager.to_dict(),
		"rng": RngStreams.to_dict(),
	}


func _restore_systems(state: Dictionary) -> void:
	var sys: Dictionary = state.get("systems", {}) as Dictionary
	if sys.is_empty():
		return
	ProductSystem.from_dict(sys.get("product", {}) as Dictionary)
	FinanceSystem.from_dict(sys.get("finance", {}) as Dictionary)
	EventManager.from_dict(sys.get("events", {}) as Dictionary)
	HRSystem.from_dict(sys.get("hr", {}) as Dictionary)
	TimeManager.from_dict(sys.get("time", {}) as Dictionary)
	# REBUILT, NOT RESTORED. The Frank gate scene is a pure function of the GATES table plus
	# GameState (phase + the gate_declines flag), both already in the save, so rebuilding
	# beats storing a copy that goes stale the moment the copy is edited. Skipping it strands
	# a loaded open gate FOREVER — see PhaseGateSystem.restore_gate_cache for why.
	PhaseGateSystem.restore_gate_cache()
	# RNG last. HRSystem.reset() (inside initialize_run) re-keys the hr_morale stream back to
	# the START of its sequence, which is right for a fresh run and wrong for a load — so the
	# saved positions have to be written over it, after everything else has settled.
	RngStreams.from_dict(sys.get("rng", {}) as Dictionary)


# ============================================================================
#  Autosave
# ============================================================================

func _on_day_tick_completed(_day: int) -> void:
	_dirty = true
	if not autosave_enabled:
		return
	var interval: int = _autosave_interval_days()
	if interval <= 0:
		return                                   # "off"
	if _last_autosave_day < 0:
		_last_autosave_day = GameState.day       # first tick of a run arms the clock
		return
	if GameState.day - _last_autosave_day >= interval:
		_autosave_pending = true
	if not _autosave_pending:
		return
	# Skip cleanly rather than refusing: a pending autosave lands at the next safe day
	# boundary, so an evening of back-to-back decisions costs a delay, never a lost save.
	if not can_save():
		return
	if Time.get_ticks_msec() - _last_autosave_msec < AUTOSAVE_MIN_REAL_SECONDS * 1000:
		return                                   # thrash guard; still pending
	if save_to_slot(_next_auto_slot_id()):
		_autosave_pending = false
		_last_autosave_day = GameState.day
		_last_autosave_msec = Time.get_ticks_msec()


func _autosave_interval_days() -> int:
	# Read LAZILY, never in _ready: SaveManager is autoload #11 and Settings is #12, so
	# Settings is not constructed yet when this node becomes ready. The guard also covers
	# Settings failing to instantiate at all, in which case Godot leaves either a bare Node
	# or nil under the global name — both would otherwise crash on the call.
	var freq: String = AUTOSAVE_FREQUENCY_DEFAULT
	if Settings != null and Settings.has_method("get_value"):
		freq = String(Settings.get_value(SETTING_AUTOSAVE_FREQUENCY, AUTOSAVE_FREQUENCY_DEFAULT))
	return int(AUTOSAVE_INTERVAL_DAYS.get(freq, AUTOSAVE_INTERVAL_DAYS[AUTOSAVE_FREQUENCY_DEFAULT]))


func _next_auto_slot_id() -> String:
	# Rolling three. Overwrite the OLDEST (a missing file counts as oldest), so the three
	# autosaves are always the three most recent and one bad day cannot wipe the lot.
	var oldest_id: String = AUTO_SLOT_IDS[0]
	var oldest_time: int = 1 << 62
	for sid in AUTO_SLOT_IDS:
		var path: String = _path_for(sid)
		if not FileAccess.file_exists(path):
			return sid
		var t: int = int(FileAccess.get_modified_time(path))
		if t < oldest_time:
			oldest_time = t
			oldest_id = sid
	return oldest_id


func _is_harness_run() -> bool:
	# The smoke suite and the screenshot harnesses drive hundreds of daily ticks in seconds.
	# Autosaving through them would be slow, would pollute user://saves with fixture runs,
	# and would make one test's leftovers visible in another's slot list.
	# Substring match rather than an exact flag list on purpose: a new harness flag should
	# inherit the exclusion, not silently start writing saves.
	var args: Array = OS.get_cmdline_args() + OS.get_cmdline_user_args()
	for a in args:
		var arg: String = String(a)
		# FLAGS ONLY. Matching bare arguments would sweep in the project path, and a player
		# who happens to install the game under a folder called "screenshots" would silently
		# lose autosave with no message and no way to guess why.
		if not arg.begins_with("--"):
			continue
		if arg.contains("smoke") or arg.contains("-shot") or arg.contains("audit") or arg.contains("spec"):
			return true
	return false


# ============================================================================
#  Files
# ============================================================================

func _path_for(slot_id: String) -> String:
	return "%s%s.json" % [SAVE_DIR, slot_id]


func _write_atomic(path: String, text: String) -> bool:
	# ATOMIC-ENOUGH WRITE. The rule it protects: a crash mid-save must never cost both the
	# new save and the old one.
	#   1. write .tmp            — a crash here loses only the .tmp
	#   2. delete stale .bak     — REQUIRED ON WINDOWS: DirAccess.rename over an existing
	#                              file fails there, so the target slot for step 3 has to be
	#                              empty first. This is why the order is not negotiable.
	#   3. rename target → .bak  — the previous save is now safe under a second name
	#   4. rename .tmp → target  — target does not exist after step 3, so this cannot collide
	# At every instant between 1 and 4 at least one complete file exists.
	var tmp: String = path + ".tmp"
	var bak: String = path + ".bak"
	var file := FileAccess.open(tmp, FileAccess.WRITE)
	if file == null:
		push_error("[SaveManager] cannot open %s for write (err %d)" % [tmp, FileAccess.get_open_error()])
		return false
	file.store_string(text)
	file.close()
	if FileAccess.file_exists(bak):
		DirAccess.remove_absolute(bak)
	if FileAccess.file_exists(path):
		# NOTE this never parses the file it is replacing, which is what lets a good save
		# overwrite a CORRUPT one — the most direct way for the player to reclaim a slot.
		if DirAccess.rename_absolute(path, bak) != OK:
			push_error("[SaveManager] could not roll %s to .bak" % path)
			return false
	if DirAccess.rename_absolute(tmp, path) != OK:
		push_error("[SaveManager] could not move %s into place" % tmp)
		return false
	return true


func _slot_row(slot_id: String) -> Dictionary:
	var read: Dictionary = read_slot(slot_id)
	var meta: Dictionary = read.get("meta", {}) as Dictionary
	var unix_time: int = int(meta.get("unix_time", 0))
	if unix_time == 0:
		# A file whose meta cannot be read still needs a sort key, or every broken save
		# would pile up at the bottom of the list in arbitrary order.
		unix_time = int(FileAccess.get_modified_time(_path_for(slot_id)))
	return {
		"slot_id": slot_id,
		"kind": _kind_of(slot_id),
		"label": _label_for(slot_id),
		"loadable": bool(read.get("ok", false)),
		"error_key": String(read.get("error_key", "")),
		"unix_time": unix_time,
		"meta": {
			"company_name": String(meta.get("company_name", "")),
			"day": int(meta.get("day", 0)),
			"phase": int(meta.get("phase", 1)),
			"phase_name": String(meta.get("phase_name", "")),
			"cash": int(meta.get("cash", 0)),
			"mrr": int(meta.get("mrr", 0)),
		},
	}


func _kind_of(slot_id: String) -> String:
	if slot_id == QUICK_SLOT_ID:
		return "quick"
	if slot_id in AUTO_SLOT_IDS:
		return "auto"
	return "manual"


func _label_for(slot_id: String) -> String:
	# Localised HERE so the modal renders a row verbatim (Bilingual Birth: no player-facing
	# string is composed from a literal at the call site).
	match _kind_of(slot_id):
		"quick":
			return tr("SAVE_QUICK_SLOT")
		"auto":
			return tr("SAVE_AUTO_SLOT").format({"n": AUTO_SLOT_IDS.find(slot_id) + 1})
		_:
			return tr("SAVE_MANUAL_SLOT").format({"n": slot_id.trim_prefix(MANUAL_SLOT_PREFIX).to_int()})


func _game_version() -> String:
	# project.godot carries no application/config/version key today, so this reads the
	# fallback. Stored anyway: the day a version is set, every save written from then on
	# records it, and the meta block does not need a schema bump to gain the field.
	return String(ProjectSettings.get_setting("application/config/version", "0.0.0-dev"))  # [WORKING]


## v1 → v2: `industry` stopped being a Turkish display name and became an ASCII id.
##
## WHY A MIGRATION AT ALL: `industry` is a persisted @export on Customer and Prospect, so
## every save written before the localization sweep carries "İnşaat" where the code now
## expects "construction". Without this the sector tag on a loaded customer would render
## through the fallback and the sector-affinity pools would stop matching — a save that
## looks fine and is quietly wrong, which is the failure mode this file's own header
## refuses to ship. The mapping is data and lives with the sector knowledge
## (B2BConstants.LEGACY_SECTOR_IDS), not here.
##
## Unknown values are LEFT ALONE rather than blanked: a value this table does not know is
## more likely a future sector than corruption, and dropping it would lose information the
## next build might understand.
func _migrate_sector_ids(state: Dictionary) -> void:
	var moved: int = 0
	for bucket in ["customers", "prospects"]:
		var rows: Array = state.get(bucket, []) as Array
		for row in rows:
			if typeof(row) != TYPE_DICTIONARY:
				continue
			var d: Dictionary = row
			var old_id: String = String(d.get("industry", ""))
			if old_id == "" or not B2BConstants.LEGACY_SECTOR_IDS.has(old_id):
				continue
			d["industry"] = String(B2BConstants.LEGACY_SECTOR_IDS[old_id])
			moved += 1
	if moved > 0 and OS.is_debug_build():
		print("[SaveManager] v1→v2: remapped %d legacy sector id(s)" % moved)


## v2 → v3: prospect need lines were finished Turkish sentences living in @export Strings,
## so every save carried prose that no language switch could reach. They are indices now.
##
## The mapping is done by REVERSE LOOKUP against the shipped Turkish, which is exact for the
## seven pool rows — the same seven strings this build now serves as PITCH_NEED_* and
## PITCH_REAL_NEED_*. A value that matches none of them is a pain-phrase (those came from a
## feature id, and `pain_feature_id` is already in the save, so `display_need()` rebuilds it
## with no help from here) or a string from a build we do not know. Either way the field is
## simply dropped rather than guessed at: -1 renders as empty, never as the wrong sentence.
const _LEGACY_NEEDS := [
	"Ekip dağınık, tek bir yerde toplamak istiyorlar.",
	"Manuel süreçler zaman yiyor, otomasyon arıyorlar.",
	"Mevcut araçları pahalı ve şişkin, sade bir şey istiyorlar.",
	"Raporlama kâbus, yönetim net veri istiyor.",
]
const _LEGACY_REAL_NEEDS := [
	"Aslında derdi bütçe değil — patronuna 'modernleştik' diyebilmek.",
	"Asıl korkusu rakibin gerisinde kalmak.",
	"Geçen yıl yanlış araca para yatırdı, bu sefer garanti istiyor.",
]


func _migrate_prospect_needs(state: Dictionary) -> void:
	var mapped: int = 0
	var dropped: int = 0
	for row in (state.get("prospects", []) as Array):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = row
		for pair in [["need_summary", "need_index", _LEGACY_NEEDS],
				["real_need", "real_need_index", _LEGACY_REAL_NEEDS]]:
			var old_field: String = String(pair[0])
			if not d.has(old_field):
				continue
			var text: String = String(d[old_field])
			d.erase(old_field)
			var idx: int = (pair[2] as Array).find(text)
			d[String(pair[1])] = idx
			if idx >= 0:
				mapped += 1
			elif text != "":
				dropped += 1
	if (mapped > 0 or dropped > 0) and OS.is_debug_build():
		print("[SaveManager] v2→v3: %d need line(s) mapped to indices, %d not in the pool" % [
			mapped, dropped])
