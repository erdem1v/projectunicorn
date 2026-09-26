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

const SCHEMA_VERSION := 12

## GDD ÜRÜN rev 6.1 §22.5 — eski kayıt TAŞINMAZ. "Yükleyici eski sürümü görürse kullanıcıya
## AÇIK MESAJ verir, sessizce bozuk state üretmez." Düz özellik listesi hat durumlarına
## çevrilemez ve v9 olay bloğu v10 motorunun arklarını/latch'lerini taşımaz; çevirmeye
## çalışmak çalışıyor görünen ve yanlış olan bir koşu üretir. O yüzden kapı sürümdedir.
## v11/v12 alanlarının hepsi bildirilmiş varsayılan taşıdığı için v10 hâlâ yüklenir.
const MIN_LOADABLE_VERSION := 10
const SAVE_DIR := "user://saves/"

# Slot ids are also filenames on disk, i.e. a compatibility surface.
const QUICK_SLOT_ID := "quick"
const AUTO_SLOT_IDS: Array[String] = ["auto_1", "auto_2", "auto_3"]
const MANUAL_SLOT_PREFIX := "manual_"

# Settings key; values "off" | "daily" | "weekly" | "monthly".
const SETTING_AUTOSAVE_FREQUENCY := "autosave_frequency"
const AUTOSAVE_FREQUENCY_DEFAULT := "weekly"                       # [WORKING]
const AUTOSAVE_INTERVAL_DAYS := {"off": 0, "daily": 1, "weekly": 7, "monthly": 30}   # [WORKING]

# Real-time floor between two autosaves. At 3x a day is 3 real seconds, so "daily" would
# otherwise write ~20 full saves a minute. A skipped write stays pending and lands at the next
# safe boundary: coalesced, never lost.
const AUTOSAVE_MIN_REAL_SECONDS := 20                              # [WORKING]

# Smoke, probe and screenshot harnesses drive hundreds of ticks in seconds; they must never
# write into the player's slots.
var _autosave_enabled: bool = true
var _autosave_pending: bool = false
var _last_autosave_day: int = -1
var _last_autosave_msec: int = 0
# "Days have been played since the last save." Raised at the day-tick boundary, cleared by a
# successful save and by a load.
var _dirty: bool = false


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	# day_tick_completed, NOT day_advanced: day_advanced fires before the daily slots run, so
	# a save hung off it would pair the new day number with yesterday's systems.
	EventBus.day_tick_completed.connect(_on_day_tick_completed)
	for a in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		if _is_harness_arg(String(a)):
			_autosave_enabled = false


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
	if EventGate.active_id() != "" \
			or VCPitchSystem.is_active() or TermSheetTableSystem.is_active() \
			or SalesMeetingSystem.is_active() or NegotiationSystem.is_active():
		return "SAVE_ERR_MODAL_OPEN"
	return ""


func has_unsaved_progress() -> bool:
	return GameState.run_active and _dirty


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
	var rows: Array = []
	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		return rows
	for filename in dir.get_files():
		if filename.ends_with(".json"):
			rows.append(_slot_row(filename.trim_suffix(".json")))
	rows.sort_custom(func(a, b): return int(a.get("unix_time", 0)) > int(b.get("unix_time", 0)))
	return rows


# ============================================================================
#  Reads
# ============================================================================

func read_slot(slot_id: String) -> Dictionary:
	# Pure read + schema gate; mutates nothing, so the modal can show a file's error without
	# having touched the live run.
	var path: String = _path_for(slot_id)
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
	return {"ok": true, "error_key": "", "meta": meta, "state": state}


func _refused(error_key: String, meta: Dictionary = {}) -> Dictionary:
	return {"ok": false, "error_key": error_key, "meta": meta, "state": {}}


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
	# Everything the slot list renders, so listing never walks full state. Money stays a
	# plain int; formatting it here would freeze one locale into the file.
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
	# Takes the dict read_slot returned.
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

	TimeManager.set_suspended(false)
	_dirty = false
	_autosave_pending = false
	_last_autosave_day = GameState.day
	return true


func reset_all_owners() -> void:
	# Every owner of run state, in autoload/dependency order. EventBus holds no state;
	# GameState's reset is initialize_run.

	# Clock first, so nothing ticks into the inconsistent window below.
	TimeManager.reset()

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
	# RNG last: HRSystem.reset() inside initialize_run re-keys hr_morale to the start of its
	# sequence, so the saved positions must be written over it after everything else.
	RngStreams.from_dict(sys.get("rng", {}) as Dictionary)


# ============================================================================
#  Autosave
# ============================================================================

func _on_day_tick_completed(_day: int) -> void:
	_dirty = true
	if not _autosave_enabled:
		return
	var freq: String = String(Settings.get_value(SETTING_AUTOSAVE_FREQUENCY, AUTOSAVE_FREQUENCY_DEFAULT))
	var interval: int = int(AUTOSAVE_INTERVAL_DAYS.get(freq, AUTOSAVE_INTERVAL_DAYS[AUTOSAVE_FREQUENCY_DEFAULT]))
	if interval <= 0:
		return                                   # "off"
	if _last_autosave_day < 0:
		_last_autosave_day = GameState.day       # first tick of a run arms the clock
		return
	if GameState.day - _last_autosave_day >= interval:
		_autosave_pending = true
	# A pending autosave that cannot be taken now waits for the next safe day boundary.
	if not _autosave_pending or not can_save():
		return
	if Time.get_ticks_msec() - _last_autosave_msec < AUTOSAVE_MIN_REAL_SECONDS * 1000:
		return
	if save_to_slot(_next_auto_slot_id()):
		_autosave_pending = false
		_last_autosave_day = GameState.day
		_last_autosave_msec = Time.get_ticks_msec()


func _next_auto_slot_id() -> String:
	# Rolling three: overwrite the oldest (a missing file counts as oldest).
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


## Flags only, matched by substring so a new harness flag inherits the exclusion. Bare
## arguments are ignored: matching them would catch an install path such as ".../screenshots/".
static func _is_harness_arg(arg: String) -> bool:
	if not arg.begins_with("--"):
		return false
	for part in ["smoke", "-shot", "audit", "spec", "run-log"]:
		if arg.contains(part):
			return true
	return false


# ============================================================================
#  Files
# ============================================================================

func _path_for(slot_id: String) -> String:
	return "%s%s.json" % [SAVE_DIR, slot_id]


func _write_atomic(path: String, text: String) -> bool:
	# A crash mid-save must never cost both the new save and the old one.
	#   1. write .tmp            — a crash here loses only the .tmp
	#   2. delete stale .bak     — required on Windows: rename over an existing file fails
	#   3. rename target → .bak  — the previous save is safe under a second name
	#   4. rename .tmp → target  — target no longer exists, so this cannot collide
	# The target is never parsed, so a good save can overwrite a corrupt one.
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
	if FileAccess.file_exists(path) and DirAccess.rename_absolute(path, bak) != OK:
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
		# An unreadable file still needs a sort key.
		unix_time = int(FileAccess.get_modified_time(_path_for(slot_id)))
	return {
		"slot_id": slot_id,
		"label": _label_for(slot_id),
		"loadable": bool(read.get("ok", false)),
		"error_key": String(read.get("error_key", "")),
		"unix_time": unix_time,
		"meta": {
			"day": int(meta.get("day", 0)),
			"phase_name": String(meta.get("phase_name", "")),
			"cash": int(meta.get("cash", 0)),
			"mrr": int(meta.get("mrr", 0)),
		},
	}


func _label_for(slot_id: String) -> String:
	if slot_id == QUICK_SLOT_ID:
		return tr("SAVE_QUICK_SLOT")
	if slot_id in AUTO_SLOT_IDS:
		return tr("SAVE_AUTO_SLOT").format({"n": AUTO_SLOT_IDS.find(slot_id) + 1})
	return tr("SAVE_MANUAL_SLOT").format({"n": slot_id.trim_prefix(MANUAL_SLOT_PREFIX).to_int()})


func _game_version() -> String:
	# project.godot has no version key yet; stored anyway so saves gain it without a schema bump.
	return String(ProjectSettings.get_setting("application/config/version", "0.0.0-dev"))  # [WORKING]


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
				if job_id == "" or jobs.has(job_id):
					continue
				if not HRConstants.can_hold_job(role_id, job_id, category):
					continue
				if jobs.size() >= HRConstants.MAX_JOBS_PER_PERSON:
					continue
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
