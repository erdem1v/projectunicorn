extends SceneTree
## ODA 3D — LightmapGI bake driver. Bakes scenes/oda3d/oda3d.tscn twice (day rig, night rig)
## into scenes/oda3d/oda3d_{day,night}.lmbake without a human clicking in the editor.
##
## Why this shape (Godot 4.6):
##  * `LightmapGI.bake()` is C++-only — the only script-reachable entry is the editor plugin's
##    `_bake()`, which lives in the EDITOR process.
##  * `--script` accepts only MainLoop/SceneTree subclasses (never EditorScript), but combined with
##    `-e` Godot still builds EditorNode into this very SceneTree — so a SceneTree script IS the way
##    to run code inside the editor from the command line.
##  * With `light_data` pre-assigned to an EXTERNAL `.lmbake` file the plugin bakes straight to that
##    path (no file dialog). The plugin bakes from the LightmapGI's PARENT (the scene root here).
##  * The lightmapper needs a real RenderingDevice → run WINDOWED, never --headless.
##
## Run:  godot -e --path <project> --windowed -s res://scenes/oda3d/oda3d_bake_driver.gd
## Output: the two .lmbake (+ .exr atlases) beside the scene, and art/oda3d/oda3d_bake_log.json
##         (per-mode wall time, atlas sizes, errors).

const SCENE := "res://scenes/oda3d/oda3d.tscn"
const LOG_PATH := "res://art/oda3d/oda3d_bake_log.json"
const MODES: Array[String] = ["day", "night"]

enum Step { WAIT_EDITOR, WAIT_SCENE, FIND_BAKE, PREPARE, BAKE, FINISH, QUIT }

var _step := Step.WAIT_EDITOR
var _wait := 0
var _mode_idx := 0
var _busy := false
var _root: Node = null
var _lm: LightmapGI = null
var _log := {}
var _bake_callable := Callable()


func _initialize() -> void:
	process_frame.connect(_tick)


## The bake pumps editor frames while it runs; the guard keeps process_frame from re-entering.
func _tick() -> void:
	if _busy:
		return
	_busy = true
	_step_machine()
	_busy = false


## Counts frames; true once `frames` have passed (and resets for the next wait).
func _waited(frames: int) -> bool:
	_wait += 1
	if _wait < frames:
		return false
	_wait = 0
	return true


func _step_machine() -> void:
	match _step:
		Step.WAIT_EDITOR:
			# Editor must exist and have finished its filesystem scan.
			if not Engine.is_editor_hint() or EditorInterface.get_base_control() == null:
				return
			var fs := EditorInterface.get_resource_filesystem()
			if fs == null or fs.is_scanning() or not _waited(30):
				return
			EditorInterface.open_scene_from_path(SCENE)
			_step = Step.WAIT_SCENE
		Step.WAIT_SCENE:
			var r := EditorInterface.get_edited_scene_root()
			if r == null or r.scene_file_path != SCENE or not _waited(30):
				return
			_root = r
			_lm = _root.get_node_or_null("LightmapGI") as LightmapGI
			if _lm == null:
				_fail("no LightmapGI node in scene root")
				return
			# Selecting the LightmapGI makes the plugin's button live; retry a while in case the
			# plugin registers late.
			_select_lm()
			_step = Step.FIND_BAKE
		Step.FIND_BAKE:
			_bake_callable = _find_bake_callable()
			if _bake_callable.is_valid():
				_wait = 0
				_step = Step.PREPARE
			elif _waited(120):
				_fail("could not find LightmapGIEditorPlugin._bake connection on any Button")
		Step.PREPARE:
			if _mode_idx >= MODES.size():
				_step = Step.FINISH
				return
			var mode: String = MODES[_mode_idx]
			_root.call("set_mode", mode)
			var lm_path := "res://scenes/oda3d/oda3d_%s.lmbake" % mode
			if not ResourceLoader.exists(lm_path):
				ResourceSaver.save(LightmapGIData.new(), lm_path)
				EditorInterface.get_resource_filesystem().update_file(lm_path)
			_lm.light_data = ResourceLoader.load(lm_path, "LightmapGIData", ResourceLoader.CACHE_MODE_REPLACE)
			_select_lm()
			_step = Step.BAKE
		Step.BAKE:
			if not _waited(45):
				return
			var mode: String = MODES[_mode_idx]
			var t0 := Time.get_ticks_msec()
			_bake_callable.call()
			var data := _lm.light_data
			var atlases: Array = data.get_lightmap_textures() if data else []
			var entry := {
				"mode": mode, "seconds": (Time.get_ticks_msec() - t0) / 1000.0, "ok": not atlases.is_empty(),
				"quality": _lm.quality, "bounces": _lm.bounces, "supersampling": _lm.supersampling, "supersampling_factor": _lm.supersampling_factor,
				"directional": _lm.directional, "denoiser": _lm.use_denoiser, "texel_scale": _lm.texel_scale, "max_texture_size": _lm.max_texture_size,
				"light_data_path": data.resource_path if data else "",
				"atlas_count": atlases.size(),
				"engine": Engine.get_version_info().string,
				"errors": _collect_dialog_text(),
			}
			if not atlases.is_empty():
				var tex: TextureLayered = atlases[0]
				entry["atlas_size"] = [tex.get_width(), tex.get_height(), tex.get_layers()]
			_log[mode] = entry
			print("[BakeDriver] %s bake %s: %s" % [mode, "OK" if entry["ok"] else "FAILED", JSON.stringify(entry)])
			_mode_idx += 1
			_step = Step.PREPARE
		Step.FINISH:
			# Do NOT save the scene: the spawned lights are owned in the editor (so the baker sees
			# them) and a save would persist them into the .tscn; oda3d.gd re-spawns them from the
			# source JSON on every load.
			_root.call("set_mode", "day")
			_write_log()
			print("BAKE_DRIVER_DONE")
			_step = Step.QUIT
		Step.QUIT:
			if _waited(5):
				quit(0)


func _select_lm() -> void:
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(_lm)


## Every node under the editor's base control.
func _editor_nodes() -> Array[Node]:
	var out: Array[Node] = []
	var bc: Control = EditorInterface.get_base_control()
	if bc:
		out.append(bc)
		out.append_array(bc.find_children("*", "", true, false))
	return out


## The plugin adds a Button to the spatial editor menu and connects its `pressed` to its own
## `_bake`. The editor UI is localised, so the button is found by that connection, not its text.
func _find_bake_callable() -> Callable:
	for n in _editor_nodes():
		if not (n is BaseButton):
			continue
		for c in n.get_signal_connection_list("pressed"):
			var cal: Callable = c["callable"]
			var obj: Object = cal.get_object()
			if obj and obj.get_class() == "LightmapGIEditorPlugin" and String(cal.get_method()) == "_bake":
				return cal
	return Callable()


## Texts of visible editor dialogs (bake errors), which are dismissed so the next bake can run.
func _collect_dialog_text() -> Array:
	var out: Array = []
	for n in _editor_nodes():
		if n is AcceptDialog and n.visible:
			out.append(n.dialog_text)
			n.hide()
	return out


func _write_log() -> void:
	var f := FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_log, "  "))


func _fail(msg: String) -> void:
	push_error("[BakeDriver] " + msg)
	_log["error"] = msg
	_write_log()
	print("BAKE_DRIVER_FAILED " + msg)
	quit(1)
