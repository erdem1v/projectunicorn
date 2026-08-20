extends SceneTree
## ODA 3D spike — LightmapGI bake driver. Bakes scenes/oda3d/oda3d.tscn twice (day rig, night
## rig) into scenes/oda3d/oda3d_{day,night}.lmbake without a human clicking in the editor.
##
## Why this shape (verified against the 4.6 branch, 2026-08-19):
##  * `LightmapGI.bake()` is C++-only (its ClassDB binding is commented out) — the only script-
##    reachable entry is the editor plugin's `_bake()`, which lives in the EDITOR process.
##  * `--script` accepts only MainLoop/SceneTree subclasses (never EditorScript), but combined with
##    `-e` Godot still builds EditorNode into this very SceneTree — so a SceneTree script IS the way
##    to run code inside the editor from the command line.
##  * With `light_data` pre-assigned to an EXTERNAL `.lmbake` file the plugin bakes straight to that
##    path (no file dialog). The plugin bakes from the LightmapGI's PARENT (the scene root here).
##  * The lightmapper needs a real RenderingDevice → run WINDOWED, never --headless.
##
## Run:  Godot_v4.6.2-stable_win64_console.exe -e --path <project> -s res://scenes/oda3d/oda3d_bake_driver.gd
## Output: the two .lmbake (+ .exr/.png atlases + .import) beside the scene, and
##         art/oda3d/oda3d_bake_log.json (per-mode wall time, atlas sizes, errors).

const SCENE := "res://scenes/oda3d/oda3d.tscn"
const LOG_PATH := "res://art/oda3d/oda3d_bake_log.json"
const MODES: Array[String] = ["day", "night"]

var _step := 0
var _wait := 0
var _mode_idx := 0
var _busy := false
var _root: Node = null
var _lm: LightmapGI = null
var _log := {}
var _bake_callable := Callable()


func _initialize() -> void:
	print("[BakeDriver] initialize; editor_hint=%s" % str(Engine.is_editor_hint()))
	process_frame.connect(_tick)


func _tick() -> void:
	if _busy:
		return
	_busy = true
	_step_machine()
	_busy = false


func _step_machine() -> void:
	match _step:
		0:
			# Wait for the editor to exist and finish its filesystem scan.
			if not Engine.is_editor_hint():
				return
			var bc: Control = EditorInterface.get_base_control()
			if bc == null:
				return
			var fs := EditorInterface.get_resource_filesystem()
			if fs == null or fs.is_scanning():
				return
			_wait += 1
			if _wait < 30:
				return
			_wait = 0
			print("[BakeDriver] editor ready; opening %s" % SCENE)
			EditorInterface.open_scene_from_path(SCENE)
			# NOTE (2026-08-19): a custom Sky as bake environment needs its radiance cubemap rendered
			# first; forcing the editor 3D viewport to render from here produced RD errors and an
			# all-zero bake. The scene therefore bakes with ENVIRONMENT_MODE_CUSTOM_COLOR (robust).
			_step = 1
		1:
			var r := EditorInterface.get_edited_scene_root()
			if r == null or r.scene_file_path != SCENE:
				return
			_wait += 1
			if _wait < 30:
				return
			_wait = 0
			_root = r
			_lm = _root.get_node_or_null("LightmapGI") as LightmapGI
			if _lm == null:
				_fail("no LightmapGI node in scene root")
				return
			_bake_callable = _find_bake_callable()
			if not _bake_callable.is_valid():
				# Selecting the LightmapGI makes the plugin's button visible; the callable exists
				# regardless, but retry a few frames in case the plugin registers late.
				EditorInterface.get_selection().clear()
				EditorInterface.get_selection().add_node(_lm)
				_wait = 0
				_step = 11
				return
			_step = 2
		11:
			_wait += 1
			_bake_callable = _find_bake_callable()
			if _bake_callable.is_valid():
				_step = 2
			elif _wait > 120:
				_fail("could not find LightmapGIEditorPlugin._bake connection on any Button")
		2:
			if _mode_idx >= MODES.size():
				_step = 3
				return
			var mode: String = MODES[_mode_idx]
			print("[BakeDriver] === bake %s ===" % mode)
			_root.call("set_mode", mode)
			var lm_path := "res://scenes/oda3d/oda3d_%s.lmbake" % mode
			if not ResourceLoader.exists(lm_path):
				var empty := LightmapGIData.new()
				var err := ResourceSaver.save(empty, lm_path)
				print("[BakeDriver] created empty %s (err=%d)" % [lm_path, err])
				EditorInterface.get_resource_filesystem().update_file(lm_path)
			var data: LightmapGIData = ResourceLoader.load(lm_path, "LightmapGIData", ResourceLoader.CACHE_MODE_REPLACE)
			_lm.light_data = data
			EditorInterface.get_selection().clear()
			EditorInterface.get_selection().add_node(_lm)
			_wait = 0
			_step = 21
		21:
			_wait += 1
			if _wait < 45:
				return
			var mode: String = MODES[_mode_idx]
			var t0 := Time.get_ticks_msec()
			print("[BakeDriver] pressing bake for %s (light_data path=%s)" % [mode, _lm.light_data.resource_path if _lm.light_data else "<null>"])
			_bake_callable.call()
			var secs := (Time.get_ticks_msec() - t0) / 1000.0
			var ok := _lm.light_data != null and _lm.light_data.get_lightmap_textures().size() > 0
			var entry := {
				"mode": mode, "seconds": secs, "ok": ok,
				"quality": _lm.quality, "bounces": _lm.bounces, "supersampling": _lm.supersampling, "supersampling_factor": _lm.supersampling_factor,
				"directional": _lm.directional, "denoiser": _lm.use_denoiser, "texel_scale": _lm.texel_scale, "max_texture_size": _lm.max_texture_size,
				"light_data_path": _lm.light_data.resource_path if _lm.light_data else "",
				"atlas_count": _lm.light_data.get_lightmap_textures().size() if _lm.light_data else 0,
				"engine": Engine.get_version_info().string,
				"errors": _collect_dialog_text(),
			}
			if ok:
				var tex: TextureLayered = _lm.light_data.get_lightmap_textures()[0]
				entry["atlas_size"] = [tex.get_width(), tex.get_height(), tex.get_layers()]
			_log[mode] = entry
			print("[BakeDriver] %s bake %s in %.1fs; %s" % [mode, "OK" if ok else "FAILED", secs, JSON.stringify(entry)])
			_mode_idx += 1
			_step = 2
		3:
			# Do NOT save the scene: the spawned lights are owned in the editor (so the baker sees
			# them) and a save would persist them into the .tscn; the .tscn stays data-only and
			# oda3d.gd re-spawns lights from the source JSON on every load.
			_root.call("set_mode", "day")
			print("[BakeDriver] not saving scene (by design)")
			var f := FileAccess.open(LOG_PATH, FileAccess.WRITE)
			if f:
				f.store_string(JSON.stringify(_log, "  "))
				f.close()
			print("[BakeDriver] wrote %s" % ProjectSettings.globalize_path(LOG_PATH))
			print("BAKE_DRIVER_DONE")
			_step = 4
			_wait = 0
		4:
			_wait += 1
			if _wait > 5:
				quit(0)


## The plugin adds a Button to the spatial editor menu and connects its `pressed` to its own
## `_bake` (ClassDB-bound). The editor UI is localised (this machine's editor runs in Turkish),
## so the button is found by that connection, not by its text.
func _find_bake_callable() -> Callable:
	var bc: Control = EditorInterface.get_base_control()
	if bc == null:
		return Callable()
	var stack: Array[Node] = [bc]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is BaseButton:
			for c in n.get_signal_connection_list("pressed"):
				var cal: Callable = c["callable"]
				var obj: Object = cal.get_object()
				if obj and obj.get_class() == "LightmapGIEditorPlugin" and String(cal.get_method()) == "_bake":
					print("[BakeDriver] found bake button '%s' -> %s._bake" % [n.name, obj.get_class()])
					return cal
		for ch in n.get_children():
			stack.push_back(ch)
	return Callable()


func _collect_dialog_text() -> Array:
	var out: Array = []
	var bc: Control = EditorInterface.get_base_control()
	if bc == null:
		return out
	var stack: Array[Node] = [bc]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is AcceptDialog and (n as Window).visible:
			out.append((n as AcceptDialog).dialog_text)
			(n as AcceptDialog).hide()
		for ch in n.get_children():
			stack.push_back(ch)
	return out


func _fail(msg: String) -> void:
	push_error("[BakeDriver] " + msg)
	_log["error"] = msg
	var f := FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_log, "  "))
		f.close()
	print("BAKE_DRIVER_FAILED " + msg)
	quit(1)
