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
# below: eighteen owners, one entry point, ordered.
#
# RESET IS THE PRODUCT; SAVE IS THE RECEIPT.
#
# ============================================================================
#  WHY THE SITTING-SCOPED SYSTEMS ARE RESET AND NOT SERIALISED
# ============================================================================
# VCPitchSystem (11 statics), TermSheetTableSystem (11), SalesMeetingSystem (14) and
# NegotiationSystem (15) hold sitting-local state — conviction, beat, intel, the persuasion
# needle and the path played into it, patience, the working term copy, the hidden reserve.
# None of it is saved. (PitchSystem and B2BPitchMeeting were the two names here before
# Satış rev 6; the four-beat pitch and its view adapter are retired, §19.) That is not a carve-out, it is the same statement as can_save():
# saving is REFUSED while any of those four is_active(), so a sitting is provably idle at
# every point a save can be taken, and there is nothing mid-resolution for a schema to
# describe. One sitting, one sitting only — it does not survive closing the game.

const SCHEMA_VERSION := 11  # v2: ASCII sector ids · v3: prospect needs · v4: skill AREAS · v5: ATAMA alana geçti · v6: on trait sekize indi · v7: rev 11 — İŞ ataması, seviye, tek deneyim barı, yaz izni · v8: kurucu TEK CETVELE (0–10) · v9: Ürün rev 6.1 — HAT MODELİ (düz özellik listesi öldü) · v10: olay motoru — event_engine bloğu · v11: Satış rev 6 — yıldız, süre, kadran, koltuk fiyatı

## GDD ÜRÜN rev 6.1 §22.5 — ÜRÜN VERİSİNİN ŞEKLİ DEĞİŞTİ, ve eski kayıt TAŞINMAZ.
## "Eski kayıtlardaki düz özellik listesi hat durumlarına taşınmaz; demo öncesi kayıt
## uyumluluğu taahhüt edilmez. Yükleyici eski sürümü görürse kullanıcıya AÇIK MESAJ
## verir, sessizce bozuk state üretmez."
##
## Sessiz kısmi yükleme buradaki gerçek tehlikedir: 61 düz özellik kimliği hat
## durumlarına çevrilemez, çevrilmeye çalışılırsa ürün hatsız ama "shipped" doğar —
## çalışıyor görünen ve yanlış olan bir koşu. O yüzden kapı sürümdedir, alanda değil.
const MIN_LOADABLE_VERSION := 10
# v10 (2026-08-25, olay motoru): A DELIBERATE BREAK, taken knowingly. Every existing v9 save —
# including dev and test saves — is refused with SAVE_ERR_TOO_OLD. The alternative was a v9→v10
# migration, and it cannot produce a correct run: the old block is {queue, active_event_id,
# active_event, history:[{id,day,choice}], ambient_fired_day}, and the new engine has
# engine-owned latches, arc state with three invalidation policies, named scope slots and a
# readable history. `history[].id` maps to "one_shot consumed" and NOTHING ELSE maps at all.
# Arcs would restore as never-started while their opening cards restored as already-played —
# a run that looks like it works and is wrong, which is exactly what the comment block above
# calls the real danger. Same precedent, same reasoning, as Ürün rev 6.1 §22.5.
const SAVE_DIR := "user://saves/"
## v3→v4 migration: what a migrated character gets in an area the old model never stored.
## Low but never zero — see _migrate_character_areas.
const MIGRATE_AREA_FLOOR := 2
## v4→v5'in kendi EMEKLİ tabloları. Canlı HRConstants'tan okunmuyor ve okunmamalı:
## bunlar artık var olmayan bir vokabülerin şeklidir, migration'ın görevi de tam olarak
## o şekli tanıyıp bugünküne çevirmektir. Canlı sabite bağlanan bir migration, sabit bir
## daha değiştiğinde eski kayıtları sessizce yanlış yerlere taşır.
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
# paranoid: TimeManager.SECONDS_PER_DAY is [0, 12, 6, 3] REAL SECONDS PER IN-GAME DAY,
# so at 3x a day is 3 s and "Her gün" would try to write ~20 saves a minute — each one a
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
	if EventGate.active_id() != "":
		return false                          # an event modal is up, awaiting a choice
	if VCPitchSystem.is_active():
		return false
	if TermSheetTableSystem.is_active():
		return false
	if SalesMeetingSystem.is_active():
		return false
	if NegotiationSystem.is_active():
		return false
	return true


func cannot_save_reason_key() -> String:
	# "" when can_save(). Localisation keys only — never a hardcoded sentence.
	if not GameState.run_active:
		return "SAVE_ERR_NO_RUN"
	if EventGate.active_id() != "" \
			or VCPitchSystem.is_active() or TermSheetTableSystem.is_active() \
			or SalesMeetingSystem.is_active() or NegotiationSystem.is_active():
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
	if version < MIN_LOADABLE_VERSION:
		# §22.5 — LOUDLY, and before any migration runs. The row says why, and the run
		# the player had is left untouched rather than half-replaced.
		return {"ok": false, "error_key": "SAVE_ERR_TOO_OLD", "meta": data.get("meta", {}), "state": {}}
	# MIGRATION LADDER — v1→v8, and UNREACHABLE since the v9 gate above.
	# Left in place deliberately: these are Ekip / Satış history, not this module's to
	# delete, and the gate is one constant away from being relaxed if pre-demo saves are
	# ever promised again. Flagged for the director rather than swept.
	if version < 2:
		_migrate_sector_ids(data["state"])
	if version < 3:
		_migrate_prospect_needs(data["state"])
	if version < 4:
		_migrate_character_areas(data["state"])
	if version < 5:
		_migrate_assignments_to_areas(data["state"])
	if version < 6:
		_migrate_traits_to_eight(data["state"])
	if version < 7:
		_migrate_to_rev11(data["state"])
	if version < 8:
		_migrate_founder_to_ten(data["state"])
	if version < 11:
		_migrate_sales_rev6(data["state"])
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

	# A SAVE CAN CARRY A GHOST, and `create()` refusing new ones does nothing about it. Until
	# 2026-08-27 a `promise_create` effect could mint a promise whose feature_id was the empty
	# string, and one of those keeps `has_open_promise` true forever — the promise lever stays
	# locked for the rest of that run with a lock line naming a word nobody gave. This runs
	# after the registries are seated because it reads what they just restored. It is not a
	# migration: no schema field changed, and a save with no ghost is untouched.
	PromiseRegistry.drop_targetless()

	TimeManager.set_suspended(false)
	_dirty = false
	_autosave_pending = false
	_last_autosave_day = GameState.day
	if OS.is_debug_build():
		print("[SaveManager] loaded run: day %d, phase %d, seed %d"
			% [GameState.day, GameState.phase, GameState.run_seed])
	return true


func reset_all_owners() -> void:
	# THE eighteen owners, one entry point. Ordered against the autoload order
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
	EventGate.reset()
	EvSave.reset()

	# 4. Static systems. ProductSystem and FinanceSystem are the two whose own comments
	#    named this seam as future work. PhaseGateSystem used to be on this list to drop its
	#    cached Frank scene; it holds no state at all any more.
	ProductSystem.reset()
	RnDSystem.reset()               # Ar-Ge §8.5 — ağaç, ilerleme, rapor sayacı
	FinanceSystem.reset()
	HRSystem.reset()

	# 5. The four sitting-scoped systems — reset, never serialised (see the header).
	SalesMeetingSystem.reset()
	NegotiationSystem.reset()
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
		"rnd": RnDSystem.to_dict(),
		"finance": FinanceSystem.to_dict(),
		# ONE event block, not two. `"events"` was EventManager's key; when EventGate started
		# forwarding to the new engine it became a byte-identical second copy of
		# `event_engine`, written and read twice. A v10 save has never contained the old
		# engine's block, so nothing is lost by dropping the key rather than migrating it.
		EvSave.BLOCK_KEY: EvSave.to_dict(),
		"hr": HRSystem.to_dict(),
		"time": TimeManager.to_dict(),
		"rng": RngStreams.to_dict(),
	}


func _restore_systems(state: Dictionary) -> void:
	var sys: Dictionary = state.get("systems", {}) as Dictionary
	if sys.is_empty():
		return
	ProductSystem.from_dict(sys.get("product", {}) as Dictionary)
	# Ar-Ge §8.5 — ProductSystem SONRASI: gizli hatların yeniden kaydı
	# ProductState.subtype() okuyor, o da Ürün bloğu oturduktan sonra doğru.
	RnDSystem.from_dict(sys.get("rnd", {}) as Dictionary)
	FinanceSystem.from_dict(sys.get("finance", {}) as Dictionary)
	EvSave.from_dict(sys.get(EvSave.BLOCK_KEY, {}) as Dictionary)
	HRSystem.from_dict(sys.get("hr", {}) as Dictionary)
	TimeManager.from_dict(sys.get("time", {}) as Dictionary)
	# THE GATE CACHE IS GONE, and with it the load-time rebuild that used to sit here. The
	# scene stranding this call prevented — a loaded open gate that never prompts again,
	# because the ratchet stops conditions being re-evaluated and the reminder returned early
	# on a null cache — cannot happen to a card: `funding.gate_series_a` is re-proposed from
	# the catalogue every day the ratchet is set, and the catalogue is not part of the save.
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
		if _is_harness_arg(String(a)):
			return true
	return false


## One argument's verdict, split out so the smoke suite can assert the list without faking a
## command line. FLAGS ONLY: matching bare arguments would sweep in the project path, and a
## player who happens to install the game under a folder called "screenshots" would silently
## lose autosave with no message and no way to guess why.
## `run-log` joined the list 2026-08-19 (Calibration Round A §0): the RunProbe drives whole
## 180-730 day runs headless and its daily ticks reach day_tick_completed like any other, so
## it was autosaving fixture worlds into the player's slots every 20 real seconds.
static func _is_harness_arg(arg: String) -> bool:
	if not arg.begins_with("--"):
		return false
	var harness_flag: bool = arg.contains("smoke") or arg.contains("-shot") or arg.contains("audit")
	return harness_flag or arg.contains("spec") or arg.contains("run-log")


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
## GÖÇ SATIRLARININ TEK KAPISI (2026-08-21). ÖNCEDEN HER GÖÇ ÖLÜ YOLDAN OKUYORDU:
## `save_to_slot` kayıtları `state["registries"]["characters"]` altına yazıyor
## (SaveCodec.capture_registries), göçler ise `state["characters"]` okuyordu — yazılmış
## hiçbir kayıtta olmayan bir anahtar. Yani v3'ten beri KARAKTER GÖÇLERİNİN HEPSİ
## sessiz no-op'tu ve iki smoke vakası bunu yakalayamıyordu, çünkü fonksiyonu doğrudan,
## elde kurulmuş düz bir dict'le çağırıyorlardı.
##
## DÜZ hâli de kabul ediliyor: eski smoke fixture'ları ve elle kurulmuş yükler
## çalışmaya devam etsin. Gerçek kayıt her zaman iç teki.
func _rows(state: Dictionary, key: String) -> Array:
	var reg: Dictionary = state.get("registries", {}) as Dictionary
	if typeof(reg.get(key, null)) == TYPE_ARRAY:
		return reg[key] as Array
	if typeof(state.get(key, null)) == TYPE_ARRAY:
		return state[key] as Array
	return []


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



## v10 → v11: SATIŞ rev 6. Two records changed shape and neither can be left to its defaults.
##
## THE LEAD. `archetype` ("small" | "mid" | "enterprise") and a separate `scale` were two
## encodings of one ordinal and could disagree; rev 6 §2 makes the STAR the single one. A v10
## lead also has no expiry, because leads did not age — leaving `expires_on_day` at its 0
## default would drop every restored lead on the first sweep, which is a silent loss of the
## player's pipeline rather than a migration.
##
## THE ACCOUNT. `seat_price` is new (§5.4) and its 0 default means "no stamp", which
## `B2BSalesSystem.expand` reads as "use the caller's flat rate" — correct, and exactly the
## old behaviour. But an account whose MRR and seats are both known HAS a truthful price, and
## deriving it here is better than making the player's oldest accounts the only ones that
## still expand at a flat rate.
##
## RETIRED TABLES, LOCAL. `_LEGACY_SIZE_TO_STAR` is this migration's own copy on purpose. The
## live map lives in SalesFaucetSystem and will follow the game; a save written in August must
## keep being read the way August meant it.
const _LEGACY_SIZE_TO_STAR := {"small": 1, "mid": 2, "enterprise": 3}
const _LEGACY_LEAD_LIFE_DAYS := 7


func _migrate_sales_rev6(state: Dictionary) -> void:
	var reg: Dictionary = state.get("registries", {}) as Dictionary
	var day: int = int((state.get("game_state", {}) as Dictionary).get("day", 1))

	for row in (reg.get("prospects", []) as Array):
		var p: Dictionary = row as Dictionary
		if not p.has("star") or int(p.get("star", 0)) <= 0:
			p["star"] = int(_LEGACY_SIZE_TO_STAR.get(String(p.get("archetype", "small")), 1))
		if int(p.get("expires_on_day", 0)) <= 0:
			p["expires_on_day"] = day + _LEGACY_LEAD_LIFE_DAYS
		if String(p.get("archetype_id", "")) == "":
			p["archetype_id"] = "ops_cautious"
		# The retired fields are simply not read by the new model; SaveCodec ignores a key
		# with no declared property, so they are left in place rather than deleted. A
		# migration that edits more than it must is a migration that can break more than it
		# must.

	for crow in (reg.get("customers", []) as Array):
		var c: Dictionary = crow as Dictionary
		if String(c.get("market_type", "")) != "b2b":
			continue
		if int(c.get("seat_price", 0)) > 0:
			continue
		var seats: int = int(c.get("seats", 0))
		var mrr: int = int(c.get("mrr", 0))
		if seats > 0 and mrr > 0:
			c["seat_price"] = int(round(float(mrr) / float(seats)))

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
	"Ekip dağınık, tek bir yerde toplamak istiyorlar.",   # LOC-DATA legacy save value
	"Manuel süreçler zaman yiyor, otomasyon arıyorlar.",   # LOC-DATA legacy save value
	"Mevcut araçları pahalı ve şişkin, sade bir şey istiyorlar.",   # LOC-DATA legacy save value
	"Raporlama kâbus, yönetim net veri istiyor.",   # LOC-DATA legacy save value
]
const _LEGACY_REAL_NEEDS := [
	"Aslında derdi bütçe değil — patronuna 'modernleştik' diyebilmek.",   # LOC-DATA legacy save value
	"Asıl korkusu rakibin gerisinde kalmak.",   # LOC-DATA legacy save value
	"Geçen yıl yanlış araca para yatırdı, bu sefer garanti istiyor.",   # LOC-DATA legacy save value
]


## v3 → v4: the three employee axes and the five founder skills both became the six skill
## AREAS of §4 (the migration's target model; rev 2 called the same six §2).
##
## WHY A MIGRATION IS UNAVOIDABLE HERE, when neither sibling above needed one for characters:
## SaveCodec.res_from_dict REPLACES role_stats wholesale (`coerce_like`'s TYPE_DICTIONARY
## branch returns from_json(raw) and uses the declared default only as a type oracle). So an
## old save's three keys would land INTACT on a model that expects seven, and
## CharacterRegistry._validate_shape would then push_error on every single employee — a run
## that loads, looks fine, and reads 0 for every skill the formulas ask about.
##
## Same grammar as the two migrations above: raw state Dictionary before any Resource is
## built, rows mutated in place, unknown values left alone, debug-build-only count.
func _migrate_character_areas(state: Dictionary) -> void:
	var moved: int = 0
	for row in (_rows(state, "characters") as Array):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = row
		var stats: Dictionary = d.get("role_stats", {}) as Dictionary
		if typeof(stats) != TYPE_DICTIONARY or stats.is_empty():
			continue
		var category: String = String(d.get("category", ""))
		if category == "employee" and stats.has("expertise"):
			# UZMANLIK was "how good at your job" → the role's KEY area.
			# HIZ was "how fast" → the SECONDARY area; it is the only other number the old
			# model had, and dropping it outright would flatten every migrated employee.
			# UYUM is DROPPED: rev 2 §2 moved compatibility into traits, and its one
			# mechanical job (lead coordination) was handed to Liderlik.
			var role_id: String = String(d.get("role", ""))
			var key_area: String = HRConstants.role_key_area(role_id)
			var secondary: String = HRConstants.role_secondary_area(role_id)
			var expertise: int = int(stats.get("expertise", 5))
			var pace: int = int(stats.get("pace", 5))
			var rapport: int = int(stats.get("rapport", 5))
			var rebuilt: Dictionary = {}
			for area_key in HRConstants.AREAS:
				var a: String = String(area_key)
				if a == key_area:
					rebuilt[a] = expertise
				elif a == secondary:
					rebuilt[a] = pace
				else:
					# A floor, never 0: rev 2 §2 wants a one-person team to have no holes,
					# and a migrated save must not be strictly worse than a fresh one.
					rebuilt[a] = MIGRATE_AREA_FLOOR
			# UYUM was morale resilience AND the coordination multiplier, so it is the
			# closest thing the old model had to Liderlik — carried across rather than lost.
			rebuilt[HRConstants.SKILL_LEADERSHIP] = clampi(
				rapport / 2, HRConstants.AREA_MIN, HRConstants.AREA_MAX)
			d["role_stats"] = rebuilt
			# `experience` (one int) became `area_experience` (one counter per area).
			# The whole bar is credited to the key area, which is where a pre-migration
			# employee was in fact accruing it.
			var area_xp: Dictionary = {}
			for area_key2 in HRConstants.AREAS:
				area_xp[String(area_key2)] = 0
			if key_area != "":
				area_xp[key_area] = int(d.get("experience", 0))
			d["area_experience"] = area_xp
			d.erase("experience")
			if String(d.get("training_area", "")) == "" and int(d.get("training_days_left", 0)) > 0:
				d["training_area"] = key_area
			if not d.has("assigned_jobs") or (d["assigned_jobs"] as Array).is_empty():
				# LEGACY İŞ kimliği, canlı sabitten DEĞİL: v4 hedefi bir İŞ yazmaktı ve o
				# tablo emekli oldu. v5 adımı birazdan bunu alana çevirecek.
				var default_job: String = String(_LEGACY_ROLE_DEFAULT_JOB.get(role_id, ""))
				d["assigned_jobs"] = [default_job] if default_job != "" else []
			moved += 1
		elif category == "founder" and stats.has("tech"):
			# tech fed build speed, the quality average and the iteration ceilings; all three
			# are per-area reads now, so it lands on all four technical areas at once — the
			# founder behaves EXACTLY as he did before the migration.
			var tech: int = int(stats.get("tech", 0))
			var sales: int = int(stats.get("sales", 0))
			var rebuilt_f: Dictionary = {
				HRConstants.AREA_PRODUCT: tech,
				HRConstants.AREA_DESIGN: tech,
				HRConstants.AREA_ENGINEERING: tech,
				HRConstants.AREA_QA: tech,
				HRConstants.AREA_SALES: sales,
				HRConstants.AREA_CUSTOMER_SUCCESS: sales,
				HRConstants.SKILL_LEADERSHIP: int(stats.get("leadership", 0)),
				# influence -> charisma: Karizma came back under its own name (rev 2 §2).
				# `negotiation` is dropped; its one reader, the term-sheet dilution lever,
				# is bound to Karizma. See FounderConstants' SKILL-RENAME ledger.
				FounderConstants.SKILL_CHARISMA: int(stats.get("influence", 0)),
			}
			d["role_stats"] = rebuilt_f
			if not d.has("assigned_jobs") or (d["assigned_jobs"] as Array).is_empty():
				d["assigned_jobs"] = ["build"]   # LEGACY iş kimliği; v5 alana çevirir
			moved += 1
	if moved > 0 and OS.is_debug_build():
		print("[SaveManager] v3→v4: %d character(s) moved onto the skill areas" % moved)


## v4 → v5: ATAMA bİR İŞE değil BİR ALANA yapılıyor artık.
##
## rev 2 §4'ün aynı cümlesi iki kez okundu: ilk pass (18d27e3) tablonun başlığına bakıp
## YEDİ İŞ dedi, onaylı tasarım ise matrisi ALAN sütunlarıyla çizdi ve Build/Destek/Hesap/
## Maliyet'i emekli etti. Kayıtta duran değerler o yüzden taşınmak zorunda.
##
## Eşleme İLKELİ: "bu kişi o işi HANGİ ALANDAN yapıyordu". Build üç alanla besleniyordu,
## o yüzden kişinin o üçü içinde en güçlü olduğu alana iner — emekli area_for_job'ın
## yaptığının aynısı. Destek ve Hesap ikisi de Müşteri İlişkileri'ne katlanır, ki zaten
## ch. 06 §1.3'ün "covering head"i onları tek küme saydı. Tekrarlar tekilleştirilir:
## Destek+Hesap taşıyan biri tek bir alana iner ve AŞIRI YÜK'ten çıkar — doğru sonuç,
## çünkü artık gerçekten tek bir alanda çalışıyor.
func _migrate_assignments_to_areas(state: Dictionary) -> void:
	var moved: int = 0
	for row in (_rows(state, "characters") as Array):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = row
		var jobs: Array = d.get("assigned_jobs", []) as Array
		if typeof(jobs) != TYPE_ARRAY or jobs.is_empty():
			continue
		var stats: Dictionary = d.get("role_stats", {}) as Dictionary
		var out: Array = []
		for job_id in jobs:
			var area_id: String = _legacy_job_to_area(String(job_id), stats)
			if area_id != "" and not out.has(area_id):
				out.append(area_id)
		d["assigned_jobs"] = out
		moved += 1
	# LİDER KOLTUKLARI YENİDEN KURULMUYOR, SİLİNİYOR. §4.2 lideri YAPIM BAŞINA veriyor
	# (Ürün'ün seçtiği SORUMLU) ve lidersiz alanı kurucunun Liderlik'ine bağlıyor; alan
	# başına oturan koltuk rev 11'de yok.
	#
	# Bu blok ayrıca kayıt göçünün İKİNCİ adres hatasıydı ve hiç fark edilmemişti: `job_leads`
	# top-level `state`'ten OKUNUYOR ve `area_leads` top-level `state`'e YAZILIYORDU, oysa
	# GameState değişkenleri `state["game_state"]` altında saklanıyor (save_codec). Yani okuma
	# hiçbir zaman bir şey bulmadı ve yazma hiçbir zaman geri yüklenmedi. Vakası geçiyordu
	# çünkü elle DÜZ bir sözlük kuruyordu — tam olarak §10'un "bir göç, YAZANIN yazdığı şekli
	# okumalıdır" dersi.
	state.erase("job_leads")
	var gs_v5: Variant = state.get("game_state", null)
	if gs_v5 is Dictionary:
		(gs_v5 as Dictionary).erase("job_leads")
		(gs_v5 as Dictionary).erase("area_leads")
	if moved > 0 and OS.is_debug_build():
		print("[SaveManager] v4→v5: %d character(s) moved onto area assignments" % moved)


## Emekli iş kimliği → alan kimliği. `stats` boş verilirse çok-alanlı işler kendi ilk
## alanına düşer (lider koltuğu taşınırken kişiye bakmıyoruz).
## Ham state içinde bir karakter satırı bulur; yoksa boş döner (çözüm ilk alana düşer).
func _character_row(state: Dictionary, character_id: String) -> Dictionary:
	for row in (_rows(state, "characters") as Array):
		if typeof(row) == TYPE_DICTIONARY and String((row as Dictionary).get("id", "")) == character_id:
			return row
	return {}


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



## v6 → v7: rev 11. Beş yeni şey taşınır ve HİÇBİRİ eskisini bozmaz — §12.0'ın İŞ ataması
## `assigned_job_ids`e YAZILIR, eski `assigned_jobs` ALAN listesi OLDUĞU GİBİ BIRAKILIR.
## Sebep R8: sekiz yer o diziyi doğrudan alan olarak okuyor ve anlamını yerinde değiştirmek
## onları derlenmeye devam ederken ÇALIŞMAZ hâle getirirdi. Ayna Faz 2a'da türetilmeye
## başlar, eski dizi Faz 7'de silinir.
##
## ATAMA DÜŞÜRME KURALI (Erdem 2026-08-23). Eşleme yetmez: §4.4 iki ikincil alanı kaldırdı
## (sales_rep → customer_success, customer_rep → sales), yani eski bir kayıt rev 11'de
## GEÇERSİZ olan bir atama taşıyabilir. Her eşlenen iş yeni ROLE_AREAS'a karşı yeniden
## doğrulanır; rolün artık taşıyamadığı iş DÜŞÜRÜLÜR ve liste boşalırsa kişi BOŞTA kalır.
## Sessiz taşıma yok, sessiz onarım yok, "en yakın geçerli iş" yok — Boşta okunabilir ve
## oyuncunun düzeltebileceği bir durumdur, uydurulmuş bir atama değildir. Her düşürme
## SAYILIR: hiçbir şey değiştirmemiş bir göçle her şeyi değiştirmiş bir göç dışarıdan
## aynı görünür, ayıran tek şey sayaçtır.
func _migrate_to_rev11(state: Dictionary) -> void:
	var moved: int = 0
	var dropped: int = 0
	var drop_detail: Dictionary = {}
	for row in (_rows(state, "characters") as Array):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = row
		var role_id: String = String(d.get("role", ""))
		var category: String = String(d.get("category", ""))

		# --- §3 seviye: maaş bandından türetilir (bantlar örtüşür, en yükseği kazanır) ---
		if not d.has("level"):
			d["level"] = HRConstants.level_for_salary(role_id, int(d.get("monthly_salary", 0)))
		# --- §9.1 maaş tabanı: bugünkü maaş zaten "sahip olunan en yüksek"tir ---
		if not d.has("salary_floor"):
			d["salary_floor"] = int(d.get("monthly_salary", 0))
		if not d.has("last_raise_day"):
			d["last_raise_day"] = 0
		if not d.has("last_promotion_day"):
			d["last_promotion_day"] = 0

		# --- §5.1 tek deneyim barı: alan başına sayaçların EN YÜKSEĞİ taşınır ---
		# En yüksek, toplam değil: barı dolmaya en yakın olan çalışan göçten sonra da
		# dolmaya en yakın kalmalı. Toplam almak iki yarım alanı bir tam bara çevirirdi.
		if not d.has("experience_raw"):
			var best: int = 0
			var per_area: Dictionary = d.get("area_experience", {}) as Dictionary
			if typeof(per_area) == TYPE_DICTIONARY:
				for k in per_area.keys():
					best = maxi(best, int(per_area[k]))
			d["experience_raw"] = best
		if not d.has("experience_threshold"):
			var total: int = 0
			var stats: Dictionary = d.get("role_stats", {}) as Dictionary
			if typeof(stats) == TYPE_DICTIONARY:
				for area_key in HRConstants.AREAS:
					total += int(stats.get(String(area_key), 0))
				total += int(stats.get(HRConstants.SKILL_LEADERSHIP, 0))
			d["experience_threshold"] = HRConstants.experience_threshold(total)

		# --- §8.1 kişisel saat istisnası: göç eden hiç kimsede yok, hepsi devralır ---
		if not d.has("work_hours_override"):
			d["work_hours_override"] = 0
		# --- §7 moral hedefi: bugünkü moralden tohumlanır, yoksa ilk tik sıçrardı ---
		if not d.has("morale_target"):
			d["morale_target"] = float(d.get("morale", 50))
		if not d.has("employment_history"):
			d["employment_history"] = []

		# --- §11.4 yaz izni: ay tabanlı model hafta indeksine çevrilir ---
		# Eski leave_month 1-12'ydi ve yılın herhangi bir ayına düşebiliyordu. Yeni pencere
		# Haziran-Ağustos, o yüzden ay KORUNAMAZ; dağıtıcı adım yeniden uygulanır ve kişi
		# yaz penceresi içinde deterministik bir haftaya oturur.
		if not d.has("leave_week"):
			var ordinal: int = maxi(int(d.get("leave_month", 1)) - 1, 0)
			d["leave_week"] = HRConstants.leave_week_for(ordinal)
		if not d.has("leave_deferrals"):
			d["leave_deferrals"] = 0

		# --- §12.0 ALAN → İŞ, doğrulanarak ---
		if not d.has("assigned_job_ids"):
			var jobs: Array = []
			for area_id in (d.get("assigned_jobs", []) as Array):
				var job_id: String = _legacy_area_to_job(String(area_id))
				if job_id == "" or jobs.has(job_id):
					continue   # research düşer (§12.0), tekrar eden iş tekilleşir
				if not HRConstants.can_hold_job(role_id, job_id, category):
					dropped += 1
					var key: String = "%s/%s" % [role_id, job_id]
					drop_detail[key] = int(drop_detail.get(key, 0)) + 1
					continue
				if jobs.size() >= HRConstants.MAX_JOBS_PER_PERSON:
					dropped += 1
					var over: String = "%s/%s(tavan)" % [role_id, job_id]
					drop_detail[over] = int(drop_detail.get(over, 0)) + 1
					continue
				jobs.append(job_id)
			d["assigned_job_ids"] = jobs
			moved += 1

	# --- şirket kapsamı: göç eden kayıtta yok, tabana oturur ---
	var gs: Dictionary = state.get("game_state", {}) as Dictionary
	# BOŞ BİR game_state BLOĞU DA TOHUMLANIR. Kapı `not gs.is_empty()` diyordu ve bu, hiç
	# GameState yazmamış bir v6 kaydını saatler alanı NULL olarak yüklüyordu — sonra
	# WorkHoursSystem bir tamsayı yerine null okuyordu. Boş sözlük "alan yok" demektir,
	# "tohumlama" değil.
	if typeof(gs) == TYPE_DICTIONARY:
		if not gs.has("company_start_hour"):
			gs["company_start_hour"] = HRConstants.START_HOUR_DEFAULT
		if not gs.has("company_work_hours"):
			gs["company_work_hours"] = HRConstants.WORK_HOURS_DEFAULT
		if not gs.has("group_work_hours_override"):
			gs["group_work_hours_override"] = {}
		# §4.2: alan başına lider koltuğu rev 11'de yok — üretimde hiçbir yazıcısı da yoktu.
		gs.erase("area_leads")

	if OS.is_debug_build():
		print("[SaveManager] v6→v7: %d karakter iş atamasına taşındı, %d atama DÜŞÜRÜLDÜ %s" % [
			moved, dropped, str(drop_detail)])


## v7 → v8: KURUCU TEK CETVELE. §2.4 kurucuyu HR veri modelinin tam vatandaşı yapıyor,
## §4.1 cetveli 0–10 diye tanımlıyor ve §5.3 tavanı 5,0 yıldıza koyuyor — kurucu 0–5'te
## kaldığı sürece Kişisel kartındaki yıldız satırı yapısal olarak 5 üzerinden 2,5'te
## tavanlıydı ve oyuncuya asla ulaşamayacağı bir tavan vaat ediyordu.
##
## YALNIZ KURUCU. Çalışanlar zaten 0–10'da; onlara dokunmak her kaydı bozardı.
##
## İDEMPOTANS AÇIK BİR NÖBETÇİYLE. Bu dosyadaki diğer göçler `if not d.has(alan)` ile
## kendiliğinden yeniden-koşulabilir; bir İKİYE KATLAMANIN böyle doğal bekçisi YOKTUR —
## ikinci koşuda kareye çıkardı. Nöbetçi ham sözlükte yaşıyor ve Character'a hiç ulaşmıyor
## (SaveCodec.res_from_dict tanımadığı anahtarı düşürür), yani bir alan eklemiyor; tek işi
## bu fonksiyonun iki kez çağrılmasını zararsız kılmak.
const FOUNDER_RULER_TAG := "founder_ruler"


func _migrate_founder_to_ten(state: Dictionary) -> void:
	var moved: int = 0
	for row in (_rows(state, "characters") as Array):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = row
		if String(d.get("category", "")) != "founder":
			continue
		if int(d.get(FOUNDER_RULER_TAG, 0)) >= HRConstants.AREA_MAX:
			continue   # zaten taşınmış — ikinci çağrı no-op
		var stats: Dictionary = d.get("role_stats", {}) as Dictionary
		if typeof(stats) != TYPE_DICTIONARY:
			continue
		for skill_key in stats.keys():
			stats[String(skill_key)] = clampi(
				int(stats[skill_key]) * FounderConstants.RULER_SCALE,
				HRConstants.AREA_MIN, HRConstants.AREA_MAX)
		d["role_stats"] = stats
		d[FOUNDER_RULER_TAG] = HRConstants.AREA_MAX
		# EŞİK AYNI ADIMDA YENİDEN HESAPLANIR. `experience_threshold` toplam gelişmişlikten
		# türüyor (§5.1) ve onu v6→v7 yazmıştı; puanlar ikiye katlanınca o eşik bayatlar ve
		# kurucunun deneyim barı yanlış ölçekte kalırdı.
		var total: int = 0
		for area_key in HRConstants.AREAS:
			total += int(stats.get(String(area_key), 0))
		total += int(stats.get(HRConstants.SKILL_LEADERSHIP, 0))
		d["experience_threshold"] = HRConstants.experience_threshold(total)
		moved += 1
	if OS.is_debug_build():
		print("[SaveManager] v7→v8: %d kurucu kaydı 0–10 cetveline taşındı" % moved)


## Emekli ALAN id'si → §12.0 İŞ id'si. `research` bilerek "" döner: §12.0 Araştırma'yı
## atama hedefi olmaktan çıkardı ve o sütunun zaten hiçbir tüketicisi yoktu.
func _legacy_area_to_job(area_id: String) -> String:
	match area_id:
		"product", "design", "engineering":
			return HRConstants.JOB_BUILD
		"qa":
			return HRConstants.JOB_TEST
		"customer_success":
			return HRConstants.JOB_ACCOUNTS
		"sales":
			# EMEKLİ ALAN, EMEKLİ İŞ → DÜŞER. Bir süre burada JOB_ACCOUNTS döndürdüm ve bu
			# YANLIŞTI: bu tablo bilerek DONMUŞTUR (bkz. dosya başı) ve artık var olmayan bir
			# vokabülerin ŞEKLİDİR — canlı bir sabiti izlemesi tam olarak yasaklanan şeydir.
			# Görünür sonucu da vardı: emekli Satış alanını taşıyan bir Müşteri Temsilcisi
			# işi DÜŞÜRMEK yerine hesap sahipliği olarak SAKLIYORDU, ki `save_migration_v6_
			# to_v7_drops` tam olarak bunun olmamasını ölçüyor.
			return ""
		_:
			return ""

func _migrate_prospect_needs(state: Dictionary) -> void:
	var mapped: int = 0
	var dropped: int = 0
	for row in (_rows(state, "prospects") as Array):
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


## EMEKLİ ON TRAIT → ONAYLI SEKİZ (2026-08-21). Bir id'yi yeniden adlandırmak bir
## YENİDEN ADLANDIRMA DEĞİL, bir VERİ GÖÇÜDÜR: kayıttaki dizge bugünün tablosunda
## yoksa `validate_employee_traits` düşer ve o karakter trait'sız kalır — sessizce
## yanlış bir kayıt, bir kayıt sisteminin verebileceği en kötü sonuç.
##
## EŞLEME EKSENİ KORUR, ADI DEĞİL: `wont_jump_ship` → `loyal` aynı istifa çarpanını
## taşır; ekseni tamamen emekli olanlar (`works_alone`, `needs_direction`) en yakın
## davranışa iner. İki eski id aynı yeniye düşebilir — on'dan sekize inen bir sette bu
## kaçınılmaz ve kayıp bilerek GÖRÜNÜR (aşağıdaki tabloda yan yana duruyorlar).
##
## Tablo YEREL ve EMEKLİ: canlı HRConstants'tan okumuyor, çünkü bir sonraki set
## değişikliği bu göçü sessizce bozmamalı (kardeş göçlerin _LEGACY_* konvansiyonu).
const _LEGACY_TRAIT_MAP := {
	"wont_jump_ship": "loyal",              # aynı eksen, aynı büyüklük (0.6)
	"one_foot_out": "bag_packed",           # aynı eksen, aynı büyüklük (1.6)
	"sours_the_room": "mood_buster",        # aynı yön: ekibin moralini eritir
	"glass_heart": "mood_buster",           # ↑ ile BİRLEŞİR — ekseni kalmadı
	"pressure_proof": "last_one_out",       # moral-düşüş çarpanı → mesai-moral çarpanı
	"natural_leader": "takes_them_under",   # lider ekseninin tek devamı
	"mentors_peers": "takes_them_under",    # ↑ ile BİRLEŞİR
	"warms_up_fast": "picks_it_up_fast",    # "hızlı adapte" → "hızlı öğrenir"
	"works_alone": "double_checker",        # ekseni emekli; en yakını "yavaş ama temiz"
	"needs_direction": "double_checker",    # ↑ ile BİRLEŞİR
}


func _migrate_traits_to_eight(state: Dictionary) -> void:
	var moved: int = 0
	var dropped: int = 0
	for row in (_rows(state, "characters") as Array):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = row
		if typeof(d.get("traits", null)) != TYPE_ARRAY:
			continue
		# KURUCUYA DOKUNULMAZ: onun trait'leri FounderConstants'tan gelir ve bu tur
		# kapsam dışı. Ayrı katalog, ayrı vokabüler, ayrı göç.
		if String(d.get("category", "")) != "employee":
			continue
		var out: Array = []
		for t in (d["traits"] as Array):
			var tid: String = String(t)
			if HRConstants.TRAITS.has(tid):
				if not out.has(tid):
					out.append(tid)
				continue
			if _LEGACY_TRAIT_MAP.has(tid):
				var mapped: String = String(_LEGACY_TRAIT_MAP[tid])
				if not out.has(mapped):
					out.append(mapped)
				moved += 1
				continue
			# EŞLENEMEYEN BİR ID SESSİZCE DÜŞMEZ. Boş trait listesi
			# `validate_employee_traits`'i düşürür, yani "sessizce yanlış" yerine
			# "gürültülü yanlış" oluruz ve karakter yine de bir trait taşır.
			# Seçim DETERMİNİSTİK (id'nin hash'i): aynı kayıt iki kez yüklenirse aynı
			# trait'i alır, yoksa parmak izi testi kendi kendine dalgalanırdı.
			push_error("[SaveManager] v5→v6: unmapped trait '%s' on '%s'" % [
				tid, String(d.get("id", "?"))])
			dropped += 1
		if out.is_empty():
			var pool: Array = HRConstants.free_trait_ids()
			if not pool.is_empty():
				out.append(String(pool[absi(hash(String(d.get("id", "")))) % pool.size()]))
		# TEK TRAIT (HRConstants.TRAIT_COUNT): iki eski id aynı yeniye düştüyse zaten
		# tekilleşti; iki FARKLI yeniye düştüyse ilki kalır.
		if out.size() > HRConstants.TRAIT_COUNT:
			out = out.slice(0, HRConstants.TRAIT_COUNT)
		d["traits"] = out
	if (moved > 0 or dropped > 0) and OS.is_debug_build():
		print("[SaveManager] v5→v6: %d trait(s) remapped, %d unmapped" % [moved, dropped])
