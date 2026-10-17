extends Node

# Save / load orchestration and slot management. SaveCodec translates state ⇄ JSON and owns
# no policy; this file owns the policy: when a save is legal, where the bytes go, how a slot
# is named, what an autosave costs, and what a load does to a live process.
#
# LOAD MUST DO WHAT AN OS RESTART DOES. GameState.initialize_run resets only its own fields;
# the registries, the event pipeline and the static systems keep their state across it. A load
# has to put a RUNNING PROCESS into a fresh state, so every owner of state is reset through
# reset_all_owners(). An owner missed there leaks the old run into the loaded one.
#
# The four sitting-scoped systems (VCPitchSystem, TermSheetTableSystem, SalesMeetingSystem,
# NegotiationSystem) are reset, never serialised: can_save() refuses while any of them
# is_active(), so a sitting is always idle at the moment a save is taken.

const SCHEMA_VERSION := 17

## GDD ÜRÜN rev 6.1 §22.5 — eski kayıt TAŞINMAZ. "Yükleyici eski sürümü görürse kullanıcıya
## AÇIK MESAJ verir, sessizce bozuk state üretmez." Düz özellik listesi hat durumlarına
## çevrilemez ve v9 olay bloğu v10 motorunun arklarını/latch'lerini taşımaz; çevirmeye
## çalışmak çalışıyor görünen ve yanlış olan bir koşu üretir. O yüzden kapı sürümdedir.
## v11-v17 alanlarının hepsi bildirilmiş varsayılan ya da göç taşıdığı için v10 hâlâ yüklenir.
const MIN_LOADABLE_VERSION := 10
const SAVE_DIR := "user://saves/"

# Slot ids are also filenames on disk, i.e. a compatibility surface: quick_<run>, auto_<run>_<n> and manual_<n>. The
# run-less quick and auto_<n> of older saves are read and never written.
const AUTO_SLOTS_PER_RUN := 3                              # [WORKING]
const MANUAL_SLOT_PREFIX := "manual_"

const SETTING_AUTOSAVE_FREQUENCY := "autosave_frequency"
const AUTOSAVE_FREQUENCIES: Array[String] = ["off", "weekly", "monthly"]

# Real-time floor between two autosaves, so fast play does not write every few seconds. A
# skipped write stays pending and lands at the next safe boundary: coalesced, never lost.
const AUTOSAVE_MIN_REAL_SECONDS := 10                      # [WORKING]

const RUN_START := Vector2i(1, TimeModel.WEEK_START_HOUR)

# The folder the slots live in; a harness points it at its own (_use_dir).
var _dir: String = SAVE_DIR
# Smoke, probe and screenshot harnesses drive hundreds of ticks in seconds; they must never
# write into the player's slots.
var _autosave_enabled: bool = true
var _autosave_pending: bool = false
var _last_autosave_msec: int = 0
# A decision answered since the last save: progress the clock does not show. Cleared by a save's capture and by a
# load.
var _dirty: bool = false
# The (day, hour) of the run's last save or load; a fresh run starts at RUN_START. A run standing anywhere else has
# unsaved progress.
var last_saved_at: Vector2i = RUN_START
# The autosave a worker is writing, -1 when none. Waited for exactly once, in _join_write.
var _write_task: int = -1


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	# day_tick_completed, NOT day_advanced: day_advanced fires before the daily slots run, so
	# a save hung off it would pair the new day number with yesterday's systems.
	EventBus.day_tick_completed.connect(_on_day_tick_completed)
	EventBus.month_ended.connect(_on_month_ended)
	EventBus.event_resolved.connect(func(_id: String, _choice: int) -> void:
		_dirty = true
		_retry_blocked_autosave())
	EventBus.event_set_aside.connect(_retry_blocked_autosave.unbind(1))
	for a in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		if _is_harness_arg(String(a)):
			_autosave_enabled = false


## get_tree().quit() frees this node before the engine waits for its workers: a write in flight lands first.
func _exit_tree() -> void:
	_join_write()


# ============================================================================
#  Queries
# ============================================================================

func can_save() -> bool:
	return cannot_save_reason_key() == ""


func cannot_save_reason_key() -> String:
	# Checked against the owners of mid-resolution state, not "is a modal on screen": the
	# Kaydet button itself lives inside a modal. The ACTIVE event only, not the queue: a
	# queued event is data and is serialised; a presented-but-unanswered choice is not.
	if not GameState.run_active:
		return "SAVE_ERR_NO_RUN"
	if EventGate.active_id() != "":
		return "SAVE_ERR_DECISION_WAITING"
	if VCPitchSystem.is_active() or TermSheetTableSystem.is_active() \
			or SalesMeetingSystem.is_active() or NegotiationSystem.is_active():
		return "SAVE_ERR_MODAL_OPEN"
	return ""


func has_unsaved_progress() -> bool:
	return GameState.run_active and (_dirty or last_saved_at != _now())


func _now() -> Vector2i:
	return Vector2i(GameState.day, GameState.current_hour)


func has_slot(slot_id: String) -> bool:
	return FileAccess.file_exists(_path_for(slot_id))


func next_manual_slot_id() -> String:
	var highest: int = 0
	for row in list_slots():
		var sid: String = String(row.get("slot_id", ""))
		if sid.begins_with(MANUAL_SLOT_PREFIX):
			highest = maxi(highest, sid.trim_prefix(MANUAL_SLOT_PREFIX).to_int())
	return "%s%d" % [MANUAL_SLOT_PREFIX, highest + 1]


func list_slots() -> Array:
	# Newest first. Unloadable rows still appear with their reason: a save that silently
	# vanishes from the list reads as the game having eaten it.
	_join_write()
	var rows: Array = []
	var dir := DirAccess.open(_dir)
	if dir == null:
		return rows
	for filename in dir.get_files():
		if filename.ends_with(".json"):
			rows.append(_slot_row(filename.trim_suffix(".json")))
	rows.sort_custom(func(a, b): return a.meta.saved_msec > b.meta.saved_msec \
		or a.meta.saved_msec == b.meta.saved_msec and a.meta.day > b.meta.day)
	return rows


## list_slots by run, the newest run first: {run_id, company_name, logo, newest_msec, slots, backups}, the
## backups being its autosaves. Saves from before run ids group by their company name.
func list_runs() -> Array:
	var runs: Dictionary = {}
	for row: Dictionary in list_slots():
		var key: String = row.meta.run_id if row.meta.run_id != "" else "|" + row.meta.company_name
		if not runs.has(key):
			runs[key] = {"run_id": row.meta.run_id, "company_name": row.meta.company_name,
				"logo": row.meta.logo, "newest_msec": row.meta.saved_msec, "slots": [], "backups": []}
		runs[key]["backups" if row.slot_id.begins_with("auto_") else "slots"].append(row)
	return runs.values()


# ============================================================================
#  Reads
# ============================================================================

func read_slot(slot_id: String) -> Dictionary:
	# Pure read + schema gate; mutates nothing, so the modal can show a file's error without
	# having touched the live run. A corrupt or missing target falls back to the slot's .bak
	# (the previous save), marked `from_backup`. NEWER and TOO_OLD are valid files with a
	# deliberate refusal and never fall back to an older state.
	_join_write()
	var path: String = _path_for(slot_id)
	var read: Dictionary = _read_file(path)
	if String(read.error_key) != "SAVE_ERR_CORRUPT":
		return read
	var backup: Dictionary = _read_file(path + ".bak")
	if not bool(backup.ok):
		return read
	backup["from_backup"] = true
	return backup


func _read_file(path: String) -> Dictionary:
	# file_exists first: open() on a missing path logs an engine error.
	var file := FileAccess.open(path, FileAccess.READ) if FileAccess.file_exists(path) else null
	if file == null:
		return _refused("SAVE_ERR_CORRUPT")
	# JSON.new().parse() rather than JSON.parse_string(): the shortcut push_errors on a
	# malformed file, and list_slots() parses every file each time the list is drawn.
	var json := JSON.new()
	var parse_err: int = json.parse(file.get_as_text())
	file.close()
	if parse_err != OK or typeof(json.data) != TYPE_DICTIONARY:
		return _refused("SAVE_ERR_CORRUPT")
	var data: Dictionary = json.data
	var meta: Dictionary = data.get("meta", {}) as Dictionary
	var version: int = int(data.get("schema_version", 0))
	# A newer schema refuses rather than loading the fields this build knows and silently
	# defaulting the rest. Forward-compat runs one way only.
	if version > SCHEMA_VERSION:
		return _refused("SAVE_ERR_NEWER", meta)
	if typeof(data.get("state", null)) != TYPE_DICTIONARY:
		return _refused("SAVE_ERR_CORRUPT", meta)
	if version < MIN_LOADABLE_VERSION:
		return _refused("SAVE_ERR_TOO_OLD", meta)
	var state: Dictionary = data["state"]
	if version < 11:
		_migrate_sales_rev6(state)
	if version < 13:
		_migrate_13(state)
	if version < 14:
		_migrate_14(state, meta)
	if version < 15:
		_migrate_15(state)
	if version < 16:
		_migrate_16(state)
	return {"ok": true, "error_key": "", "meta": meta, "state": state}


func _refused(error_key: String, meta: Dictionary = {}) -> Dictionary:
	return {"ok": false, "error_key": error_key, "meta": meta, "state": {}}


# ============================================================================
#  Writes
# ============================================================================

func save_to_slot(slot_id: String) -> bool:
	_join_write()
	if not can_save():
		push_warning("[SaveManager] save refused: %s" % cannot_save_reason_key())
		return false
	if not _write_atomic(_path_for(slot_id), _payload()):
		return false
	_dirty = false
	last_saved_at = _now()
	return true


func _payload() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"game_version": _game_version(),
		"meta": build_meta(),
		"state": {
			"game_state": SaveCodec.capture_game_state(),
			"registries": SaveCodec.capture_registries(),
			"systems": _capture_systems(),
		},
	}


func quick_slot_id() -> String:
	return "quick_" + GameState.run_id


## Leaving saves into the run's own autosave rotation, so the quicksave stays the point F9 goes back to.
func exit_slot_id() -> String:
	_join_write()
	return _next_auto_slot_id()


func delete_slot(slot_id: String) -> bool:
	_join_write()
	var ok: bool = true
	for path in [_path_for(slot_id), _path_for(slot_id) + ".bak"]:
		if FileAccess.file_exists(path) and DirAccess.remove_absolute(path) != OK:
			ok = false
	return ok


func build_meta() -> Dictionary:
	# Everything the slot list renders, so listing never walks full state. Money stays a
	# plain int; formatting it here would freeze one locale into the file.
	return {
		"company_name": GameState.company_name,
		"run_id": GameState.run_id,
		"logo": GameState.logo,
		"day": GameState.day,
		"phase": GameState.phase,
		"cash": GameState.cash,
		"mrr": GameState.mrr,
		"unix_time": int(Time.get_unix_time_from_system()),
		# unix_time has whole seconds; two saves within one still sort by this.
		"saved_msec": int(Time.get_unix_time_from_system() * 1000),
		"schema_version": SCHEMA_VERSION,
		"game_version": _game_version(),
	}


# ============================================================================
#  Load
# ============================================================================

func apply_loaded_state(payload: Dictionary) -> bool:
	# Takes the dict read_slot returned.
	_join_write()
	var state: Dictionary = payload.get("state", {}) as Dictionary
	if state.is_empty():
		push_error("[SaveManager] apply_loaded_state called with no state block")
		return false

	# The clock is suspended for the whole rebuild: nothing holds a pause while the shell is
	# gone, and one frame between "reset" and "restored" would tick a half-built world. Speed
	# 0 would not do; speed is player state this load restores.
	TimeManager.set_suspended(true)
	reset_all_owners()

	# One init path: initialize_run lays the fresh-run baseline and applies the save over it,
	# so a field the save does not carry falls back to its default.
	var gs_block: Dictionary = state.get("game_state", {}) as Dictionary
	GameState.initialize_run({"seed": int(gs_block.get("run_seed", 0)), "restore": state})

	# Registries before systems: systems restore into a world whose people and accounts exist.
	SaveCodec.restore_registries(state)
	_restore_systems(state)

	# A save can carry a promise with an empty feature_id, which would keep has_open_promise
	# true forever. Runs after the registries because it reads what they restored.
	PromiseRegistry.drop_targetless()
	# A save from the beta channel's days may hold cards waiting in beta.
	SprintSystem.finish_beta_cards()
	# A save written before people had looks gets them here, apart from the restored team; one
	# from before the funds had people gets those too.
	CharacterRegistry.fill_missing_looks()
	CounterpartSystem.fill_investor_people()

	TimeManager.set_suspended(false)
	_dirty = false
	# The loaded hour is where the player's progress was last kept.
	last_saved_at = _now()
	return true


func reset_all_owners() -> void:
	# Every owner of run state, in autoload/dependency order. EventBus holds no state;
	# GameState's reset is initialize_run.

	# Clock first, so nothing ticks into the inconsistent window below.
	TimeManager.reset()
	# A pending autosave belongs to the run being replaced.
	_autosave_pending = false

	# Registries, in SaveCodec's restore order. Direct clears, no signals: CustomerRegistry
	# must not emit customer_removed, which PromiseRegistry turns into promise drops.
	CharacterRegistry.reset()
	CustomerRegistry.reset()
	ProspectRegistry.reset()
	RivalRegistry.reset()          # re-seeds from RivalCatalog: an empty field is not valid state
	PromiseRegistry.reset()

	# Event pipeline, after the registries so nothing queued references a cleared record.
	EventGate.reset()
	EvSave.reset()

	ProductSystem.reset()
	RnDSystem.reset()
	FinanceSystem.reset()
	HRSystem.reset()

	# Sitting-scoped systems: reset, never serialised (see the header).
	SalesMeetingSystem.reset()
	NegotiationSystem.reset()
	VCPitchSystem.reset()
	TermSheetTableSystem.reset()

	# RNG last, so nothing above draws from a stream that is about to be re-keyed.
	RngStreams.reset()


## The run ends without leaving the process: a write in flight lands, every owner of run state resets and nothing
## is left to save. TimeManager.reset unpauses the tree at speed 1, so stopping the clock comes last.
func end_run() -> void:
	_join_write()
	reset_all_owners()
	GameState.set_run_active(false)
	_dirty = false
	last_saved_at = RUN_START
	EventBus.speed_change_requested.emit(0)


# ============================================================================
#  System routing (each owner serialises itself; this only orders the calls)
# ============================================================================

func _capture_systems() -> Dictionary:
	return {
		"product": ProductSystem.to_dict(),
		"rnd": RnDSystem.to_dict(),
		"finance": FinanceSystem.to_dict(),
		EvSave.BLOCK_KEY: EvSave.to_dict(),
		"hr": HRSystem.to_dict(),
		"time": TimeManager.to_dict(),
		"rng": RngStreams.to_dict(),
	}


func _restore_systems(state: Dictionary) -> void:
	var sys: Dictionary = state.get("systems", {}) as Dictionary
	# Before the empty-block return: every load comes back paused.
	TimeManager.from_dict(sys.get("time", {}) as Dictionary)
	if sys.is_empty():
		return
	ProductSystem.from_dict(sys.get("product", {}) as Dictionary)
	# Ar-Ge §8.5 — ProductSystem SONRASI: gizli hatların yeniden kaydı
	# ProductState.subtype() okuyor, o da Ürün bloğu oturduktan sonra doğru.
	RnDSystem.from_dict(sys.get("rnd", {}) as Dictionary)
	FinanceSystem.from_dict(sys.get("finance", {}) as Dictionary)
	EvSave.from_dict(sys.get(EvSave.BLOCK_KEY, {}) as Dictionary)
	HRSystem.from_dict(sys.get("hr", {}) as Dictionary)
	# Overwrites the keys initialize_run's RngStreams.reseed(run_seed) laid down, so the load
	# resumes the saved sequences.
	RngStreams.from_dict(sys.get("rng", {}) as Dictionary)


# ============================================================================
#  Autosave
# ============================================================================

func _on_day_tick_completed(_day: int) -> void:
	if _autosave_frequency() == "weekly":
		_autosave_pending = true
	_try_autosave()


func _on_month_ended(_close: Dictionary) -> void:
	if _autosave_frequency() == "monthly":
		_autosave_pending = true


# An autosave a card blocked lands once nothing is pending, not a week later: after an answer,
# or after the opened paper goes back on the desk.
func _retry_blocked_autosave() -> void:
	if not EventGate.has_pending():
		_try_autosave()


# Read at use, never in _ready: Settings is autoloaded after SaveManager.
func _autosave_frequency() -> String:
	return Settings.get_choice(SETTING_AUTOSAVE_FREQUENCY, AUTOSAVE_FREQUENCIES)


func _try_autosave() -> void:
	# A pending autosave that cannot be taken now waits for the next safe boundary.
	if not _autosave_enabled or not _autosave_pending or _autosave_frequency() == "off" \
			or not can_save() or _write_task != -1:
		return
	if Time.get_ticks_msec() - _last_autosave_msec < AUTOSAVE_MIN_REAL_SECONDS * 1000:
		return
	_save_in_background(_next_auto_slot_id())
	_autosave_pending = false
	_last_autosave_msec = Time.get_ticks_msec()


## Captured on this thread, written by a worker. The run keeps changing while the worker reads and a
## to_dict may hand out live containers, so the worker gets a deep copy and touches only the slot's files.
func _save_in_background(slot_id: String) -> void:
	var payload: Dictionary = _payload().duplicate(true)
	var path: String = _path_for(slot_id)
	var at: Vector2i = _now()
	# The payload holds every decision up to here; one answered while the worker writes stays unsaved.
	_dirty = false
	_write_task = WorkerThreadPool.add_task(func() -> void:
		_on_write_done.call_deferred(_write_atomic(path, payload), at))


## Back on the main thread. Hours played since the capture keep the run unsaved; a failed write waits
## for the next boundary like a skipped one, its decisions unsaved again.
func _on_write_done(ok: bool, at: Vector2i) -> void:
	_join_write()
	if not ok:
		_autosave_pending = true
		_dirty = true
		return
	last_saved_at = at


## Mid-write a slot's file is briefly missing (rolled to .bak) and a second writer would share its
## .tmp, so whatever reads or writes the save folder lets the write in flight land first.
func _join_write() -> void:
	if _write_task != -1:
		WorkerThreadPool.wait_for_task_completion(_write_task)
		_write_task = -1


## Rolling AUTO_SLOTS_PER_RUN per run: a missing slot first, else this run's oldest by saved_msec (a file's mtime has
## whole seconds). Another run's autosaves are never overwritten.
func _next_auto_slot_id() -> String:
	var oldest_id: String = ""
	var oldest_msec: int = 1 << 62
	for n in range(1, AUTO_SLOTS_PER_RUN + 1):
		var sid: String = "auto_%s_%d" % [GameState.run_id, n]
		if not FileAccess.file_exists(_path_for(sid)):
			return sid
		var msec: int = _slot_row(sid).meta.saved_msec
		if msec < oldest_msec:
			oldest_msec = msec
			oldest_id = sid
	return oldest_id


## THE harness-flag test; DisplaySettings.is_inert reads it too. Flags only, matched by
## substring so a new harness flag inherits the exclusion. Bare arguments are ignored: matching
## them would catch an install path such as ".../screenshots/". --display-check matches
## nothing on purpose: it must drive the real window.
static func _is_harness_arg(arg: String) -> bool:
	if not arg.begins_with("--"):
		return false
	for part in ["smoke", "-shot", "audit", "probe", "run-log", "plausibility"]:
		if arg.contains(part):
			return true
	return false


# ============================================================================
#  Files
# ============================================================================

func _path_for(slot_id: String) -> String:
	return "%s%s.json" % [_dir, slot_id]


## Debug seam: the slots live in `path` until it is pointed back at SAVE_DIR.
func _use_dir(path: String) -> void:
	_dir = path
	DirAccess.make_dir_recursive_absolute(path)


func _write_atomic(path: String, payload: Dictionary) -> bool:
	# Keys keep their order: a sorted save would hand the product's ledgers back in another order.
	var text: String = JSON.stringify(payload, "\t", false)
	# A crash mid-save, or a write that did not land whole, must never cost both the new save
	# and the old one.
	#   1. write .tmp, read it back — a failed or short write loses only the .tmp
	#   2. delete stale .bak        — required on Windows: rename over an existing file fails
	#   3. rename target → .bak     — the previous save is safe under a second name
	#   4. rename .tmp → target     — target no longer exists, so this cannot collide; a failure
	#                                 puts the .bak back under the target's name
	# The target is never parsed, so a good save can overwrite a corrupt one; read_slot reads
	# the .bak when the target is corrupt.
	var tmp: String = path + ".tmp"
	var bak: String = path + ".bak"
	if not _write_complete(tmp, text):
		DirAccess.remove_absolute(tmp)
		return false
	if FileAccess.file_exists(bak):
		DirAccess.remove_absolute(bak)
	if FileAccess.file_exists(path) and DirAccess.rename_absolute(path, bak) != OK:
		push_error("[SaveManager] could not roll %s to .bak" % path)
		DirAccess.remove_absolute(tmp)
		return false
	if DirAccess.rename_absolute(tmp, path) != OK:
		push_error("[SaveManager] could not move %s into place" % tmp)
		if FileAccess.file_exists(bak):
			DirAccess.rename_absolute(bak, path)
		DirAccess.remove_absolute(tmp)
		return false
	return true


## True when all of `text` is on disk: the write's error state is clean and the file is as
## long as the text. Every handle is released before this returns, because Windows will not
## rename an open file.
func _write_complete(path: String, text: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("[SaveManager] cannot open %s for write (err %d)" % [path, FileAccess.get_open_error()])
		return false
	file.store_string(text)
	var clean: bool = file.get_error() == OK
	file.close()
	var check := FileAccess.open(path, FileAccess.READ) if clean else null
	if check == null or check.get_length() != text.to_utf8_buffer().size():
		push_error("[SaveManager] %s was not written in full" % path)
		return false
	return true


func _slot_row(slot_id: String) -> Dictionary:
	var read: Dictionary = read_slot(slot_id)
	var meta: Dictionary = read.get("meta", {}) as Dictionary
	var company := String(meta.get("company_name", ""))
	var logo: Dictionary = meta.get("logo", {})
	var unix_time: int = int(meta.get("unix_time", 0))
	if unix_time == 0:
		# An unreadable file still needs a sort key.
		unix_time = int(FileAccess.get_modified_time(_path_for(slot_id)))
	return {
		"slot_id": slot_id,
		"label": label_for(slot_id),
		"loadable": bool(read.get("ok", false)),
		"error_key": String(read.get("error_key", "")),
		"unix_time": unix_time,
		"from_backup": bool(read.get("from_backup", false)),
		"meta": {
			"company_name": company,
			"run_id": String(meta.get("run_id", "")),
			"logo": logo if not logo.is_empty() else LogoEmblem.from_legacy(String(meta.get("logo_style", "")), company),
			"saved_msec": int(meta.get("saved_msec", unix_time * 1000)),
			"day": int(meta.get("day", 0)),
			"phase": int(meta.get("phase", 1)),
			"cash": int(meta.get("cash", 0)),
			"mrr": int(meta.get("mrr", 0)),
		},
	}


## An id's kind is its first part and its number its last: quick[_<run>], auto[_<run>]_<n>, manual_<n>.
func label_for(slot_id: String) -> String:
	var parts: PackedStringArray = slot_id.split("_")
	match parts[0]:
		"quick":
			return tr("SAVE_QUICK_SLOT")
		"auto":
			return tr("SAVE_AUTO_SLOT").format({"n": parts[-1].to_int()})
	return tr("SAVE_MANUAL_SLOT").format({"n": parts[-1].to_int()})


func _game_version() -> String:
	return String(ProjectSettings.get_setting("application/config/version"))


# ============================================================================
#  Migration
# ============================================================================

## v10 → v11: SATIŞ rev 6. The lead's size became a star (§2) and leads gained an expiry;
## leaving `expires_on_day` at 0 would drop every restored lead on the first sweep. An
## account whose MRR and seats are both known gets its truthful `seat_price` (§5.4) instead
## of the 0 "no stamp" default. Retired keys are left in place: the codec ignores them.
## The size table is this migration's own copy so the live map can move on without
## changing how an old save is read.
const _LEGACY_SIZE_TO_STAR := {"small": 1, "mid": 2, "enterprise": 3}
const _LEGACY_LEAD_LIFE_DAYS := 7


func _migrate_sales_rev6(state: Dictionary) -> void:
	var reg: Dictionary = state.get("registries", {}) as Dictionary
	var day: int = int((state.get("game_state", {}) as Dictionary).get("day", 1))

	for row in (reg.get("prospects", []) as Array):
		var p: Dictionary = row as Dictionary
		if int(p.get("star", 0)) <= 0:
			p["star"] = int(_LEGACY_SIZE_TO_STAR.get(String(p.get("archetype", "small")), 1))
		if int(p.get("expires_on_day", 0)) <= 0:
			p["expires_on_day"] = day + _LEGACY_LEAD_LIFE_DAYS
		if String(p.get("archetype_id", "")) == "":
			p["archetype_id"] = "ops_cautious"

	for crow in (reg.get("customers", []) as Array):
		var c: Dictionary = crow as Dictionary
		if String(c.get("market_type", "")) != "b2b" or int(c.get("seat_price", 0)) > 0:
			continue
		var seats: int = int(c.get("seats", 0))
		var mrr: int = int(c.get("mrr", 0))
		if seats > 0 and mrr > 0:
			c["seat_price"] = int(round(float(mrr) / float(seats)))


## v12 → v13: the office. A run that took Frank's cheque has outgrown the flat, so it lands in
## the business block; any other run is at home. The move fields and Frank's latched line load
## as their declared defaults.
func _migrate_13(state: Dictionary) -> void:
	var gs: Dictionary = state.get("game_state", {}) as Dictionary
	gs["office_id"] = "ishani" if int(gs.get("run_angel_amount", 0)) > 0 else "home"


## v13 → v14: the weekly time model. One tick is a week, so every day stamp becomes a week stamp,
## a countdown rounds up, a streak rounds down and a fractional count divides. A renamed key is
## written under its v14 name. Pure and cheap: list_slots reads every slot through here.
func _migrate_14(state: Dictionary, meta: Dictionary) -> void:
	var gs: Dictionary = state.get("game_state", {}) as Dictionary
	var flags: Dictionary = gs.get("flags", {}) as Dictionary
	var reg: Dictionary = state.get("registries", {}) as Dictionary
	var sys: Dictionary = state.get("systems", {}) as Dictionary
	var ev: Dictionary = sys.get(EvSave.BLOCK_KEY, {}) as Dictionary
	var today: int = int(gs.get("day", 1))
	var ceil_weeks := func(n: Variant) -> int:
		return int(n) if int(n) <= 0 else ceili(float(n) / TimeModel.DAYS_PER_TICK)
	var floor_weeks := func(n: Variant) -> int: return int(n) / TimeModel.DAYS_PER_TICK

	_stamp_keys(meta, ["day"], today)

	_stamp_keys(gs, ["day", "brand_low_since_day", "seed_door_open_day", "seed_closed_day",
		"acq_road_over_day", "bootstrap_milestone_day", "office_move_day"], today)
	# A same-tick latch only ever meant "not again today".
	gs["vc_meeting_cancel_day"] = _week_stamp(today, today) \
		if int(gs.get("vc_meeting_cancel_day", -1)) == today else -1
	_convert(gs, "shutter_days_left", "shutter_weeks_left", ceil_weeks)
	for key in ["transactions", "sales_log", "sales_loss_log"]:
		_stamp_each(gs.get(key, []), ["day"], today)
	# One cash sample per tick: each week keeps its last day's.
	var weekly: Dictionary = {}
	for row in gs.get("cash_history", []):
		_stamp_keys(row, ["day"], today)
		weekly[row["day"]] = row
	gs["cash_history"] = weekly.values()
	gs["cs_escalation_days"] = (gs.get("cs_escalation_days", []) as Array).map(
		func(d: Variant) -> int: return _week_stamp(d, today))
	_stamp_each(gs.get("sales_account_memory", {}), ["loss_day", "insult_day"], today)
	var locks: Dictionary = gs.get("sales_return_locks", {}) as Dictionary
	_stamp_keys(locks, locks.keys(), today)
	_stamp_each((gs.get("active_sheets", []) as Array) + [gs.get("seed_sheet")],
		["granted_day", "expires_day"], today)
	_stamp_keys(gs.get("pending_meeting", {}), ["day"], today)
	var search: Dictionary = gs.get("hr_search", {}) as Dictionary
	search.erase("started_day")
	_stamp_keys(search, ["arrival_day"], today)
	var feed: Dictionary = gs.get("news_feed", {}) as Dictionary
	_stamp_each(feed.get("stream", []), ["day"], today)
	var rivals: Dictionary = feed.get("recent_rivals", {}) as Dictionary
	_stamp_keys(rivals, rivals.keys(), today)
	for row in gs.get("month_history", []):
		_stamp_keys(row, ["start_day", "end_day"], today)
		_convert(row, "red_days", "red_weeks", ceil_weeks)
	# The summary period opens where the month did; the month ledger keeps only its own keys.
	var month: Dictionary = gs.get("month_ledger", {}) as Dictionary
	_stamp_keys(month, ["start_day"], today)
	_convert(month, "red_days", "red_weeks", ceil_weeks)
	var period: Dictionary = {"start_day": int(month.get("start_day", 1)), "cash": int(month.get("cash", 0))}
	for key in ["mrr", "employees", "brand"]:
		period[key] = int(month.get(key, 0))
		month.erase(key)
	gs["summary_ledger"] = period
	# Seeded where runway already is, so the load announces nothing.
	var daily_net: int = int(round(float(gs.get("mrr", 0)) / TimeModel.DAYS_PER_MONTH)) \
		- int(gs.get("daily_burn", 0))
	gs["runway_warn_band"] = FinanceSystem.runway_band(
		GameState.runway_months_for(int(gs.get("cash", 0)), daily_net))
	# The week opens at 08:00: an earlier start moves up and keeps its length.
	gs["company_start_hour"] = maxi(int(gs.get("company_start_hour", HRConstants.START_HOUR_DEFAULT)),
		HRConstants.START_HOUR_MIN)

	_stamp_keys(flags, ["mvp_launch_day", "mvp_version_launch_day", "sales_weekly_anchor_day",
		"angel_seed_accepted_day", "finance_runway_warn_snooze_until_day"], today)
	_stamp_each(flags.get("mvp_version_history", []), ["day"], today)
	for key in ["sales_meeting_active", "sales_meeting_used_day", "sales_weekly_closes"]:
		flags.erase(key)

	for c in reg.get("characters", []):
		_stamp_keys(c, ["last_raise_day", "last_promotion_day", "hire_day", "leave_until_day"], today)
		_stamp_each(c.get("employment_history", []), ["day"], today)
		_convert(c, "flight_risk_days", "flight_risk_weeks", floor_weeks)
		_convert(c, "training_days_left", "training_weeks_left", ceil_weeks)
	for c in reg.get("customers", []):
		_stamp_keys(c, ["acquired_on_day", "onboarding_until", "last_risk_exit_day",
			"last_expansion_day", "support_request_since_day"], today)
		c["churn_countdown"] = ceil_weeks.call(c.get("churn_countdown", -1))
		c["risk_streak"] = floor_weeks.call(c.get("risk_streak", 0))
		c["cs_request_phase"] = floor_weeks.call(c.get("cs_request_phase", 0)) \
			% TimeModel.ticks(B2BConstants.CS_REQUEST_INTERVAL_WEEKS)
	for p in reg.get("prospects", []):
		_stamp_keys(p, ["spawned_on_day", "expires_on_day", "work_started_day"], today)
		p.erase("work_due_day")
	_stamp_each(reg.get("promises", []), ["deadline_day"], today)

	_stamp_keys(sys.get("rnd", {}), ["note_last_day"], today)

	_stamp_each(ev.get("flags", {}), ["set_day"], today)
	_stamp_each(ev.get("timed_flags", {}), ["expires_on", "set_day"], today)
	_stamp_each(ev.get("stamps", {}), ["day"], today)
	_stamp_each(ev.get("latches", {}), ["last_day"], today)
	_stamp_each(ev.get("held", []), ["day"], today)
	# A scope slot {type, id, bound_day} rides in every context and in a history row's entities.
	for row in ev.get("rows", []):
		_stamp_keys(row, ["day"], today)
		_stamp_each(row.get("entities", {}), ["bound_day"], today)
	for e in (ev.get("queue", []) as Array) + (ev.get("schedule", []) as Array) \
			+ (ev.get("papers", {}) as Dictionary).values():
		_stamp_keys(e, ["admitted_day", "fire_on_day", "expires_on"], today)
		_stamp_each(e.get("context", {}), ["bound_day"], today)
	for arc in (ev.get("arcs", {}) as Dictionary).values():
		_stamp_keys(arc, ["started_day", "awaiting_since"], today)
		_stamp_keys(arc.get("subject", {}), ["bound_day"], today)
		for f in arc.get("frozen_schedule", []):
			_convert(f, "remaining_days", "remaining_weeks", ceil_weeks)
			_stamp_each(f.get("context", {}), ["bound_day"], today)
	# Seven days folded into one week would fill this week's interrupt count.
	ev["tempo_window"] = []


## A v13 day as a week stamp. A past day maps to its week, W(d) = (d − 1) / 7 + 1; a due date
## maps to today's week plus the weeks it had left, rounded up, so nothing falls due early. −1,
## 0 and NO_EXPIRY_DAY are sentinels and stay.
static func _week_stamp(d: Variant, today: int) -> int:
	var day: int = int(d)
	if day <= 0 or day == SeedConstants.NO_EXPIRY_DAY:
		return day
	if day > today:
		return _week_stamp(today, today) + ceili(float(day - today) / TimeModel.DAYS_PER_TICK)
	return (day - 1) / TimeModel.DAYS_PER_TICK + 1


## Rewrites `keys` of a dictionary as week stamps. Anything else (a null resource, a context's
## scalar value) is left alone.
static func _stamp_keys(d: Variant, keys: Array, today: int) -> void:
	if d is Dictionary:
		for key in keys:
			if d.has(key):
				d[key] = _week_stamp(d[key], today)


## _stamp_keys over every row of an array or every value of a dictionary.
static func _stamp_each(rows: Variant, keys: Array, today: int) -> void:
	for row in (rows.values() if rows is Dictionary else rows):
		_stamp_keys(row, keys, today)


static func _convert(d: Dictionary, from: String, to: String, f: Callable) -> void:
	if d.has(from):
		d[to] = f.call(d[from])
		d.erase(from)


## v14 → v15: the sprint engine replaces the build. A build in progress becomes Sprint 1's plan, one
## feature card per planned step with its design done and its development as far along as the build
## was; the build and its flags go. A line's polish is read from the stamp its current step shipped
## with. Confirmed bugs stay counted for v16 to spread over the live lines, so the ticket ledger
## starts empty. A typed product opens in Sprint 1 planning; an untyped
## run keeps the empty state the type picker starts from. Pure and cheap: list_slots reads every slot
## through here.
const _POLISH_HALF_STAMP := 1.0     # above the one-turn baseline: a second design turn or a gate bonus
const _POLISH_FULL_STAMP := 1.11    # three design turns
const _BUILD_FLAG_PREFIXES := ["creation_draft", "cancelled_build_prefill", "product_path_frank_seen", "mvp_sprint_",
	"mvp_bug_sprint_", "bug_count_at_bugfix_start_", "mvp_bug_count_at_launch"]


func _migrate_15(state: Dictionary) -> void:
	var gs: Dictionary = state.get("game_state", {}) as Dictionary
	var flags: Dictionary = gs.get("flags", {}) as Dictionary
	var sys: Dictionary = state.get("systems", {}) as Dictionary
	var build: Variant = (sys.get("product", {}) as Dictionary).get("active_build")
	(sys.get("product", {}) as Dictionary).erase("active_build")
	for key in flags.keys():
		if _BUILD_FLAG_PREFIXES.any(func(p: String) -> bool: return String(key).begins_with(p)):
			flags.erase(key)
	var subtype: String = String(flags.get("mvp_sub_product_type_id", ""))
	if subtype == "":
		return
	# The build wrote the market and the name only at launch; a typed product carries both.
	if not flags.has("mvp_market_type"):
		flags["mvp_market_type"] = ProductCatalog.get_market_type(subtype)
	if build is Dictionary and not flags.has("mvp_product_name"):
		flags["mvp_product_name"] = String(build.get("product_name", ""))
	var today: int = int(gs.get("day", 1))

	# A step id is the line's base id plus `_k<tier>`, then the line's `@subtype` suffix. Parsed, not
	# looked up: a hidden line is registered only after the load restores Ar-Ge.
	var tiers: Dictionary = flags.get("mvp_line_tiers", {}) as Dictionary
	var stamps: Dictionary = flags.get("mvp_step_realization", {}) as Dictionary
	var polish: Dictionary = {}
	for line: String in tiers:
		var base: String = line.get_slice("@", 0)
		var stamp: float = float(stamps.get("%s_k%d%s" % [base, int(tiers[line]), line.trim_prefix(base)], 1.0))
		if stamp > _POLISH_HALF_STAMP:
			polish[line] = SprintCatalog.cfg("polish_max" if stamp >= _POLISH_FULL_STAMP else "polish_step")

	var cards: Dictionary = {}
	if build is Dictionary:
		var total: float = float(build.get("total_efor", 0.0))
		var done: float = clampf(float(build.get("efor_spent", 0.0)) / total, 0.0, 1.0) if total > 0.0 else 0.0
		# Ar-Ge is read from the save: the run in memory is not the one being read.
		var lighter: bool = ((sys.get("rnd", {}) as Dictionary).get("states", {}) as Dictionary).get(
			"design_system") == RnDSystem.STATE_DONE
		var areas: Array = SprintCatalog.areas_for(subtype, String(flags["mvp_market_type"]))
		for raw in build.get("planned_step_ids", []):
			var step: String = String(raw)
			var base: String = step.get_slice("@", 0)
			var line_base: String = base.left(-3)
			var line: String = line_base + step.trim_prefix(base)
			var tier: int = base.right(1).to_int()
			var area: Dictionary = areas.filter(func(a: Dictionary) -> bool:
				return (a.get("identity", false) and line == line_base) or line_base in a.lines)[0]
			var effort: int = int(SprintCatalog.cfg("effort.k%d" % tier))
			if lighter and ProductLines.axis_of(line) == "experience":
				effort = maxi(1, roundi(effort * ProductLines.RND_EXPERIENCE_EFFORT_MULT))
			var card: Dictionary = SprintCatalog.new_card("feat:" + step, "feature", area.id, effort, line, step, tier)
			# Progress is in points: a phase is full at effort × its share.
			card.progress = [effort * card.shares[0], effort * card.shares[1] * done, 0.0]
			card.state = "planned"
			# The old build charged the licence when it committed; the sprint start must not again.
			card.paid = true
			cards[card.id] = card

	# The version history becomes the release list Geçmiş reads. A release from before sprints
	# has no sprint and no cards: -1 is the release record's "unknown".
	var releases: Array = (flags.get("mvp_version_history", []) as Array).map(func(v: Dictionary) -> Dictionary:
		var n: int = int(v.version)
		return {"number": n, "sprint": -1, "shipped": [], "carried": [], "velocity": {"done": 0, "total": 0},
			"expected": {}, "actual": {}, "press": {}, "day": int(v.day), "changed_areas": [],
			"alerts_cleared": []})

	var product: Dictionary = SprintSystem.new_state(today)
	product.sprint.cards = cards.keys()
	product.merge({"cards": cards, "releases": releases, "polish": polish}, true)
	gs["product"] = product


## v15 → v16: the ticket ledger and the confirmed-bug counter become one store of open bugs per line. The
## counter is the total and the ledger only follows it once a week: a ticket counts on its own line, the newest
## ones when the counter fell below the ledger (as the daily sync kept them), and confirmed bugs the ledger had
## not caught up with go one by one over the live lines in id order. A fix card keeps the count it showed as a number
## (a shipped one left its line clear, so its release row reads "n → 0"), the release notes' result sentences take the
## bug keys, the bugs of faulty cards waiting for v1.0 change their name, and what earlier changes removed leaves the
## save: the fix run's and the support week's flags, the live bug counter and its history, the days the voices were
## last read, and the rows of the card that left the event engine. A product fund's pending callback on open bugs
## becomes the customer-loss callback, its window opening at the save's own day. Pure and cheap: list_slots reads
## every slot through here.
const _REMOVED_FLAGS := ["mvp_bugs_confirmed", "mvp_fix_run_active", "mvp_fix_run_fixed", "mvp_fix_run_progress",
	"mvp_reports_week_net", "mvp_live_bug_count", "mvp_live_bug_progress", "mvp_bug_history"]
const _REMOVED_CARD := "product.bug_pile"


func _migrate_16(state: Dictionary) -> void:
	var gs: Dictionary = state.get("game_state", {}) as Dictionary
	var flags: Dictionary = gs.get("flags", {}) as Dictionary
	var product: Dictionary = gs.get("product", {}) as Dictionary
	var confirmed: int = int(flags.get("mvp_bugs_confirmed", 0))
	var tickets: Array = product.get("tickets", []) as Array
	var lines: Array = tickets.slice(maxi(0, tickets.size() - confirmed)).map(
		func(ticket: Dictionary) -> String: return ticket.line)
	var live: Array = ProductState.live_lines(flags.get("mvp_line_tiers", {}) as Dictionary)
	if not live.is_empty():
		for i in confirmed - lines.size():
			lines.append(live[i % live.size()])
	var bugs: Dictionary = {}
	for line in lines:
		bugs[line] = int(bugs.get(line, 0)) + 1
	flags["mvp_open_bugs"] = bugs
	flags["mvp_open_bugs_prev"] = bugs.duplicate()
	for key in _REMOVED_FLAGS:
		flags.erase(key)

	if product.has("sprint"):
		product["pending_faulty"] = product.get("gate_faulty", product.get("pending_faulty", []))
		for key in ["tickets", "ticket_seq", "gate_faulty", "voices_seen"]:
			product.erase(key)
		var cards: Array = product.cards.values() + product.release.get("shipped", [])
		for record: Dictionary in product.releases:
			cards.append_array(record.shipped)
		for card: Dictionary in cards:
			if card.has("tickets"):
				card["bugs"] = (card["tickets"] as Array).size()
				card["bugs_after"] = 0
				card.erase("tickets")
		for record: Dictionary in product.releases + [product.release]:
			for said: Dictionary in [record.get("expected", {}), record.get("actual", {})]:
				if said.has("key"):
					said["key"] = String(said["key"]).replace("RESULT_TICKETS_", "RESULT_BUGS_")

	var b2b: bool = flags.get("mvp_market_type", "") == "b2b"
	var accounts: int = _rows(state, "customers").filter(func(c: Dictionary) -> bool:
		return c.get("market_type", "") == "b2b" and c.get("status", "active") == "active").size()
	for fund: Dictionary in (gs.get("vc_states", {}) as Dictionary).values():
		var old_callback: Dictionary = fund.get("callback", {}) as Dictionary
		if old_callback.get("type", "") == "bugs_under":
			var callback: Dictionary = VCPitchSystem.churn_callback(b2b, int(gs.get("day", 1)),
				float(accounts) if b2b else float(flags.get("b2c_audience", 0.0)),
				float(gs.get("run_customers_lost", 0)) if b2b else 0.0)
			callback["met"] = old_callback.get("met", false)
			fund["callback"] = callback

	var ev: Dictionary = (state.get("systems", {}) as Dictionary).get(EvSave.BLOCK_KEY, {}) as Dictionary
	for key in ["queue", "schedule", "rows"]:
		if ev.has(key):
			ev[key] = (ev[key] as Array).filter(func(e: Dictionary) -> bool: return e.event_id != _REMOVED_CARD)
	if ev.get("active_event_id", "") == _REMOVED_CARD:
		ev["active_event_id"] = ""
		ev["active_context"] = {}
	var papers: Dictionary = ev.get("papers", {}) as Dictionary
	for key in papers.keys():
		if papers[key].get("event_id", key) == _REMOVED_CARD:
			papers.erase(key)


# ----------------------------------------------------------------------------
#  Pre-v10 migrations. Unreachable through read_slot (MIN_LOADABLE_VERSION refuses those
#  saves first); kept because smoke cases pin their behaviour. The tables are frozen copies
#  of a retired vocabulary on purpose: a migration bound to live constants would silently
#  move old saves elsewhere the next time those constants change.
# ----------------------------------------------------------------------------

## What a migrated character gets in an area the old model never stored: low, never zero.
const MIGRATE_AREA_FLOOR := 2
const _LEGACY_JOB_AREAS := {
	"build": ["product", "design", "engineering"],
	"test": ["qa"],
	"support": ["customer_success"],
	"accounts": ["customer_success"],
	"sales": ["sales"],
	"research": ["research"],
	"cost": ["engineering"],
}
const _LEGACY_ROLE_DEFAULT_JOB := {
	"product_manager": "build",
	"designer": "build",
	"developer": "build",
	"tester": "test",
	"sales_rep": "sales",
	"customer_rep": "accounts",
}


## Registry rows as the writer stores them (`state.registries.<key>`); the flat
## `state.<key>` shape is accepted for hand-built fixtures.
func _rows(state: Dictionary, key: String) -> Array:
	var reg: Dictionary = state.get("registries", {}) as Dictionary
	if typeof(reg.get(key, null)) == TYPE_ARRAY:
		return reg[key]
	if typeof(state.get(key, null)) == TYPE_ARRAY:
		return state[key]
	return []


## v1 → v2: `industry` became an ASCII sector id. Unknown values are left alone: more likely
## a future sector than corruption.
func _migrate_sector_ids(state: Dictionary) -> void:
	for bucket in ["customers", "prospects"]:
		for row in _rows(state, bucket):
			if typeof(row) != TYPE_DICTIONARY:
				continue
			var old_id: String = String(row.get("industry", ""))
			if B2BConstants.LEGACY_SECTOR_IDS.has(old_id):
				row["industry"] = String(B2BConstants.LEGACY_SECTOR_IDS[old_id])


## v3 → v4: three employee axes and five founder skills became the skill AREAS. Needed
## because the codec replaces role_stats wholesale, so the old keys would land intact on a
## model that reads areas and every skill would read 0.
func _migrate_character_areas(state: Dictionary) -> void:
	for row in _rows(state, "characters"):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = row
		var stats: Dictionary = d.get("role_stats", {}) as Dictionary
		if stats.is_empty():
			continue
		var category: String = String(d.get("category", ""))
		if category == "employee" and stats.has("expertise"):
			# UZMANLIK → the role's key area, HIZ → its secondary area. UYUM (morale
			# resilience and coordination) is the nearest thing the old model had to Liderlik.
			var role_id: String = String(d.get("role", ""))
			var key_area: String = HRConstants.role_key_area(role_id)
			var secondary: String = HRConstants.role_secondary_area(role_id)
			var rebuilt: Dictionary = {}
			var area_xp: Dictionary = {}
			for area_key in HRConstants.AREAS:
				var a: String = String(area_key)
				area_xp[a] = 0
				if a == key_area:
					rebuilt[a] = int(stats.get("expertise", 5))
				elif a == secondary:
					rebuilt[a] = int(stats.get("pace", 5))
				else:
					rebuilt[a] = MIGRATE_AREA_FLOOR
			rebuilt[HRConstants.SKILL_LEADERSHIP] = clampi(
				int(stats.get("rapport", 5)) / 2, HRConstants.AREA_MIN, HRConstants.AREA_MAX)
			d["role_stats"] = rebuilt
			# The single experience bar is credited to the key area, where it was accruing.
			if key_area != "":
				area_xp[key_area] = int(d.get("experience", 0))
			d["area_experience"] = area_xp
			d.erase("experience")
			if String(d.get("training_area", "")) == "" and int(d.get("training_days_left", 0)) > 0:
				d["training_area"] = key_area
			if (d.get("assigned_jobs", []) as Array).is_empty():
				var default_job: String = String(_LEGACY_ROLE_DEFAULT_JOB.get(role_id, ""))
				d["assigned_jobs"] = [default_job] if default_job != "" else []
		elif category == "founder" and stats.has("tech"):
			# tech lands on all four technical areas, so the founder behaves exactly as before.
			var tech: int = int(stats.get("tech", 0))
			var sales: int = int(stats.get("sales", 0))
			d["role_stats"] = {
				HRConstants.AREA_PRODUCT: tech,
				HRConstants.AREA_DESIGN: tech,
				HRConstants.AREA_ENGINEERING: tech,
				HRConstants.AREA_QA: tech,
				HRConstants.AREA_SALES: sales,
				HRConstants.AREA_CUSTOMER_SUCCESS: sales,
				HRConstants.SKILL_LEADERSHIP: int(stats.get("leadership", 0)),
				FounderConstants.SKILL_CHARISMA: int(stats.get("influence", 0)),
			}
			if (d.get("assigned_jobs", []) as Array).is_empty():
				d["assigned_jobs"] = ["build"]


## v4 → v5: ATAMA bir İŞE değil bir ALANA yapılır. Çok alanlı iş, kişinin o alanlar içinde
## en güçlü olduğuna iner; tekrarlar tekilleşir. Alan başına lider koltuğu yok (§4.2):
## eski `job_leads` / `area_leads` silinir.
func _migrate_assignments_to_areas(state: Dictionary) -> void:
	for row in _rows(state, "characters"):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = row
		var jobs: Array = d.get("assigned_jobs", []) as Array
		if jobs.is_empty():
			continue
		var stats: Dictionary = d.get("role_stats", {}) as Dictionary
		var out: Array = []
		for job_id in jobs:
			var area_id: String = _legacy_job_to_area(String(job_id), stats)
			if area_id != "" and not out.has(area_id):
				out.append(area_id)
		d["assigned_jobs"] = out
	state.erase("job_leads")
	var gs: Variant = state.get("game_state", null)
	if gs is Dictionary:
		gs.erase("job_leads")
		gs.erase("area_leads")


func _legacy_job_to_area(job_id: String, stats: Dictionary) -> String:
	var areas: Array = _LEGACY_JOB_AREAS.get(job_id, []) as Array
	if areas.is_empty():
		return ""
	var best: String = String(areas[0])
	var best_v: int = -1
	for area_key in areas:
		var v: int = int(stats.get(String(area_key), 0))
		if v > best_v:
			best_v = v
			best = String(area_key)
	return best


## v6 → v7: rev 11. §12.0'ın İŞ ataması `assigned_job_ids`e yazılır; eski `assigned_jobs`
## alan listesi olduğu gibi kalır. Eşlenen her iş yeni ROLE_AREAS'a karşı doğrulanır: rolün
## artık taşıyamadığı iş DÜŞER, liste boşalırsa kişi BOŞTA kalır. "En yakın geçerli iş"
## uydurulmaz; Boşta oyuncunun görüp düzeltebileceği bir durumdur.
func _migrate_to_rev11(state: Dictionary) -> void:
	for row in _rows(state, "characters"):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = row
		var role_id: String = String(d.get("role", ""))
		var category: String = String(d.get("category", ""))
		var salary: int = int(d.get("monthly_salary", 0))

		# §3 seviye maaş bandından; §9.1 bugünkü maaş zaten "sahip olunan en yüksek"tir.
		if not d.has("level"):
			d["level"] = HRConstants.level_for_salary(role_id, salary)
		if not d.has("salary_floor"):
			d["salary_floor"] = salary
		if not d.has("last_raise_day"):
			d["last_raise_day"] = 0
		if not d.has("last_promotion_day"):
			d["last_promotion_day"] = 0

		# §5.1 tek deneyim barı: alan sayaçlarının EN YÜKSEĞİ taşınır, toplamı değil; iki
		# yarım alan bir tam bara dönmemeli.
		if not d.has("experience_raw"):
			var best: int = 0
			for v in (d.get("area_experience", {}) as Dictionary).values():
				best = maxi(best, int(v))
			d["experience_raw"] = best
		if not d.has("experience_threshold"):
			var stats: Dictionary = d.get("role_stats", {}) as Dictionary
			var total: int = int(stats.get(HRConstants.SKILL_LEADERSHIP, 0))
			for area_key in HRConstants.AREAS:
				total += int(stats.get(String(area_key), 0))
			d["experience_threshold"] = HRConstants.experience_threshold(total)

		if not d.has("work_hours_override"):
			d["work_hours_override"] = 0
		# §7 moral hedefi bugünkü moralden tohumlanır; yoksa ilk tik sıçrardı.
		if not d.has("morale_target"):
			d["morale_target"] = float(d.get("morale", 50))
		if not d.has("employment_history"):
			d["employment_history"] = []

		# §11.4 yaz izni: eski ay (1-12) Haziran-Ağustos penceresinde korunamaz; dağıtıcı
		# adım yeniden uygulanır.
		if not d.has("leave_week"):
			d["leave_week"] = HRConstants.leave_week_for(maxi(int(d.get("leave_month", 1)) - 1, 0))
		if not d.has("leave_deferrals"):
			d["leave_deferrals"] = 0

		# §12.0 ALAN → İŞ, doğrulanarak.
		if not d.has("assigned_job_ids"):
			var jobs: Array = []
			for area_id in (d.get("assigned_jobs", []) as Array):
				var job_id: String = _legacy_area_to_job(String(area_id))
				if job_id != "" and not jobs.has(job_id) and jobs.size() < HRConstants.MAX_JOBS_PER_PERSON \
						and HRConstants.can_hold_job(role_id, job_id, category):
					jobs.append(job_id)
			d["assigned_job_ids"] = jobs

	# Şirket kapsamı; boş bir game_state bloğu da tohumlanır (boş sözlük "alan yok" demektir).
	var gs: Variant = state.get("game_state", {})
	if gs is Dictionary:
		if not gs.has("company_start_hour"):
			gs["company_start_hour"] = HRConstants.START_HOUR_DEFAULT
		if not gs.has("company_work_hours"):
			gs["company_work_hours"] = HRConstants.WORK_HOURS_DEFAULT
		if not gs.has("group_work_hours_override"):
			gs["group_work_hours_override"] = {}
		gs.erase("area_leads")


## Eski ALAN → §12.0 İŞ. `research` ve `sales` bilerek "" döner ve atama düşer: §12.0
## Araştırma'yı hedef olmaktan çıkardı, satış alanının karşılığı olan iş de yok.
func _legacy_area_to_job(area_id: String) -> String:
	match area_id:
		"product", "design", "engineering":
			return HRConstants.JOB_BUILD
		"qa":
			return HRConstants.JOB_TEST
		"customer_success":
			return HRConstants.JOB_ACCOUNTS
		_:
			return ""
