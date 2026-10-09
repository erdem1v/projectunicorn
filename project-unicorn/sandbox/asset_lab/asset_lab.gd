extends Node

# The asset lab: the shipped office, and the same office built from free packs, drawn by the game's own
# camera, light and ink, saved as PNGs. mevcut is the game's GLB; A the pack scene in the packs' own
# materials with no ink pass; B the pack scene through the game's toon material and ink.
#   --lab-shot=<mevcut|A|B|all>:<home|ishani|style>:<13|22|all>:<camera|all|sheet>
#                      sheet: the models of each recipe row on a grid, one PNG per row, as A whatever the variant
#   --lab-ref=<png>    calibration: the view takes the PNG's size, vignette 0 and no people, and LABCAL is
#                      printed against it
#   --lab-desks=1,2    desks lit by day (all by default; the night lights all of them)
#   --lab-loader=gltf  mevcut through GLTFDocument instead of the imported scene
#   --lab-gate         headless checks, LABGATE lines
# Flags go after the scene path, with no "--" separator. A headless run builds the scenes and prints the cameras
# but captures nothing.

const SCENE := preload("lab_scene.gd")
const PROBE := preload("res://scripts/debug/office_pan_probe.gd")
const LAB := "res://sandbox/asset_lab/"
const AUDIT := "res://docs/audits/asset_lab/"
const VARIANTS := ["mevcut", "A", "B"]
const CAPTIONS := ["mevcut", "A: paket malzemesi", "B: oyunun toon + ink"]
## The first hour of the night: every desk is lit and the people are in.
const NIGHT := 18
## Cameras per office: null frames the layout's opening shot, else [target, zoom over the fit zoom].
const CAMERAS := {
	"home": {"acilis": null, "yakin": [[8.0, 0.5, 7.2], 3.2]},
	"ishani": {"acilis": null, "acik_ofis": [[8.0, 0.9, 11.0], 3.4], "toplanti_mutfak": [[12.0, 0.4, 2.8], 3.0],
		"cephe": [[10.0, -3.3, 15.2], 1.5]},
}

var _sv: SubViewport
var _world: Node3D
var _cam: OfficeCamera
var _ink: MeshInstance3D
var _lighting: OfficeLighting
var _scene_root: Node3D
var _cast_root: Node3D
var _templates: Node3D
var _layout: OfficeLayout
var _lowest := 0.0
var _hour := 13
var _desks: Variant = null   # desk ids lit by day, null = all
var _gltf := false
var _ref: Image
var _cameras := {}
var _saved := 0


## Counts the engine's errors, to tell a gate that ran from one that ran clean.
class Errors extends Logger:
	var count := 0

	func _log_error(_function: String, _file: String, _line: int, _code: String, _rationale: String,
			_editor_notify: bool, _error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		count += 1


func _ready() -> void:
	# The project opens fullscreen.
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(640, 360))
	# Pauses the game clock, which runs by default; the root is process_mode always, so the lab keeps processing.
	EventBus.speed_change_requested.emit(0)
	AudioManager.get_node("MusicPlayer").stop()
	var size := Vector2i(1736, 976)   # the game's 3D view at a 1920x1080 window
	if _flag("lab-ref") != "":
		_ref = Image.load_from_file(_flag("lab-ref"))
		size = _ref.get_size()
	_gltf = _flag("lab-loader") == "gltf"
	if _flag("lab-desks", "all") != "all":
		_desks = Array(_flag("lab-desks").split(",", false)).map(func(d: String) -> int: return int(d))
	_templates = Node3D.new()
	_templates.visible = false
	add_child(_templates)
	_rig(size)
	if _ref:
		(_ink.material_override as ShaderMaterial).set_shader_parameter("vignette", 0.0)
	if "--lab-gate" in OS.get_cmdline_args():
		await _gate()
	else:
		await _shots(_flag("lab-shot").split(":"))
		print("LABDONE|saved=%d" % _saved)
	_clear()
	get_tree().quit()


func _process(_delta: float) -> void:
	if _layout:
		_lighting.apply(_hour * 60.0)


static func _flag(key: String, fallback := "") -> String:
	for a: String in OS.get_cmdline_args():
		if a.begins_with("--%s=" % key):
			return a.substr(key.length() + 3)
	return fallback


## The game's office view without its people and city, in a view of its own.
func _rig(size: Vector2i) -> void:
	var shipped: Control = (load("res://scenes/office/OfficeView.tscn") as PackedScene).instantiate()
	var src: SubViewport = shipped.get_node("Viewport3D/SubViewport")
	_world = src.get_node("World")
	_world.get_parent().remove_child(_world)
	_world.get_node("People").free()
	_world.get_node("City").free()
	_sv = SubViewport.new()
	_sv.own_world_3d = true
	_sv.size = size
	_sv.msaa_3d = src.msaa_3d
	_sv.screen_space_aa = src.screen_space_aa
	_sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	shipped.free()
	add_child(_sv)
	_sv.add_child(_world)
	_cast_root = Node3D.new()
	_world.add_child(_cast_root)
	_scene_root = _world.get_node("SceneRoot")
	_lighting = OfficeLighting.new(_world)
	_cam = _world.get_node("Camera3D")
	_ink = _world.get_node("InkPass")


func _stock(scene: String) -> Node3D:
	var path := "res://art/office3d/%s.glb" % scene
	return SCENE.load_node(ProjectSettings.globalize_path(path)) if _gltf else (load(path) as PackedScene).instantiate()


## What the last build put in the view. The headless renderer reads an instance's materials after its node has
## let them go, so they are let go of before the nodes are freed.
func _clear() -> void:
	for holder: Node in [_scene_root, _cast_root, _templates]:
		for mi: MeshInstance3D in holder.find_children("*", "MeshInstance3D", true, false):
			mi.material_override = null
			for i in mi.get_surface_override_material_count():
				mi.set_surface_override_material(i, null)
		for n in holder.get_children():
			n.free()
	_layout = null


## Builds `scene` as `variant` (and its recipe's people) in place of what the view shows.
## A `row` builds that row of the model sheet instead.
func _load(variant: String, scene: String, recipe: Dictionary, row := "") -> void:
	_clear()
	_ink.visible = variant != "A"
	_layout = OfficeLayout.load("ishani" if scene == "style" else scene)
	if variant == "mevcut":
		var stock := _stock(scene)
		_scene_root.add_child(stock)
		_lowest = SCENE.extent(stock).position.y
		_lighting.set_layout(_layout, stock, OfficeMaterials.convert_scene(stock, _layout),
			OfficeMaterials.stations(stock))
	else:
		# What the pack scene cannot supply; the camera, fog, spots and glows stay the game's.
		_layout.materials = PackedStringArray()
		_layout.hidden = PackedStringArray()
		_layout.panes.clear()
		var builder := SCENE.new(_templates)
		var built: Dictionary
		if row != "":
			built = builder.sheet(_scene_root, recipe, row)
		else:
			var props: Dictionary = {} if scene == "style" else SCENE.json(LAB + "out/props/%s_props.json" % scene)
			built = builder.build(_scene_root, recipe, props, variant == "B", _layout)
		if scene == "style" or row != "":
			var box := SCENE.extent(built.root)
			_layout.bounds = box
			_layout.glows = {}
			_layout.thumb_targets = {}
			_lowest = box.position.y
		else:
			# The same slab as the game's, so the shadow box is the same.
			var stock := _stock(scene)
			_scene_root.add_child(stock)
			_lowest = SCENE.extent(stock).position.y
			stock.free()
		_lighting.set_layout(_layout, built.root, built.mats, built.stations)
	if _ref == null and row == "":
		SCENE.cast(_cast_root, recipe, _layout.spots, variant != "mevcut")


## Day lights the desks of --lab-desks; the night lights them all and brings the people in, as the game's :full.
func _states(hour: int) -> void:
	_hour = hour
	var night := hour >= NIGHT
	var lit: Array = _desks if _desks != null and not night else range(_layout.max_n + 1)
	_lighting.anyone_in = night
	_lighting.founder_at_desk = night
	for d in _layout.max_n + 1:
		_lighting.set_station_state(d, d in lit)
	print("LABSTATE|hour=%d|lit=%s|anyone_in=%s" % [hour, lit, _lighting.anyone_in])


func _frame(scene: String, id: String, spec: Variant) -> void:
	_cam.fit(_layout.bounds, _lowest)
	if spec == null:
		_cam.frame(_layout.thumb_targets)
	else:
		_cam.focus(Vector3(spec[0][0], spec[0][1], spec[0][2]), _cam.fit_zoom * spec[1], 0.0)
	var sv := _sv.size
	print("LABCAM|%s|%s|target=%s|zoom=%.4f|fit_zoom=%.4f|sv=%dx%d|near=%.3f|far=%.3f|lowest=%.3f" % [
		scene, id, _cam.target, _cam.zoom, _cam.fit_zoom, sv.x, sv.y, _cam.near, _cam.far, _lowest])
	_cameras["%s/%s" % [scene, id]] = {"id": id, "scene": scene,
		"target": [_cam.target.x, _cam.target.y, _cam.target.z], "zoom": _cam.zoom, "fit_zoom": _cam.fit_zoom,
		"size": _cam.size, "near": _cam.near, "far": _cam.far, "sv": [sv.x, sv.y], "yaw": 45, "pitch": 35}


func _shots(spec: PackedStringArray) -> void:
	var scene := spec[1]
	var recipe: Dictionary = SCENE.json(LAB + "recipes/%s.json" % scene)
	if spec[3] == "sheet":
		for row: String in SCENE.rows(recipe):
			_load("A", scene, recipe, row)
			_states(13)
			_frame(scene, "sheet", null)
			var img := await _grab()
			if img:
				_save(img, LAB + "out/sheet_%s.png" % row)
		return
	var variants: Array = VARIANTS.duplicate() if spec[0] == "all" else [spec[0]]
	if scene == "style":
		variants.erase("mevcut")
	var hours: Array = ([13] if scene == "style" else [13, 22]) if spec[2] == "all" else [int(spec[2])]
	var cams: Dictionary = recipe.get("cameras", {}) if scene == "style" else CAMERAS[scene]
	var ids: Array = cams.keys() if spec[3] == "all" else [spec[3]]
	var halves := {}
	for variant: String in variants:
		_load(variant, scene, recipe)
		for hour: int in hours:
			_states(hour)
			for id: String in ids:
				_frame(scene, id, cams[id])
				var img := await _grab()
				if img == null:
					continue
				var stem := "stil_" + id
				if scene != "style":
					stem = "%s_%s_%s" % ["ev" if scene == "home" else scene, id, "gunduz" if hour < NIGHT else "gece"]
				_save(img, AUDIT + "%s_%s%s.png" % [stem, variant, "_gltf" if _gltf and variant == "mevcut" else ""])
				if _ref:
					await _calibrate(img, scene, hour)
				halves.get_or_add(stem, {})[variant] = _half(img)
	for stem: String in halves:
		if halves[stem].size() == VARIANTS.size():
			await _side_by_side(VARIANTS.map(func(v: String) -> Image: return halves[stem][v]), CAPTIONS,
				AUDIT + stem + "_yanyana.png")
	# Every run adds its cameras to the same file.
	var file := ProjectSettings.globalize_path(LAB + "out/cameras.json")
	var all: Dictionary = SCENE.json(file) if FileAccess.file_exists(file) else {}
	all.merge(_cameras, true)
	FileAccess.open(file, FileAccess.WRITE).store_string(JSON.stringify(all, "\t"))


## The view once the light and camera have settled and the frame is drawn; null without a display.
func _grab() -> Image:
	for i in 12:
		await get_tree().process_frame
	if DisplayServer.get_name() == "headless":
		return null
	await RenderingServer.frame_post_draw
	return _sv.get_texture().get_image()


func _save(img: Image, path: String) -> void:
	var file := ProjectSettings.globalize_path(path)
	if img.save_png(file) == OK:
		_saved += 1
		print("LAB|saved|", file)


static func _half(img: Image) -> Image:
	var half := img.duplicate() as Image
	half.resize(img.get_width() >> 1, img.get_height() >> 1, Image.INTERPOLATE_LANCZOS)
	return half


## The lab's frame against the game's, from the same pose.
func _calibrate(img: Image, scene: String, hour: int) -> void:
	var d: Dictionary = PROBE.residual(_ref, img, Vector2i.ZERO)
	print("LABCAL|%.4f|%d|%d|%dx%d" % [d.mean, d.max, d.n8, img.get_width(), img.get_height()])
	await _side_by_side([_half(_ref), _half(img)], ["oyun", "lab"],
		AUDIT + "kalibrasyon_%s_%d%s.png" % [scene, hour, "_gltf" if _gltf else ""])


## The images side by side at their own size, each with a caption.
func _side_by_side(imgs: Array, captions: Array, path: String) -> void:
	var w: int = imgs[0].get_width()
	var sv := SubViewport.new()
	sv.size = Vector2i(w * imgs.size(), imgs[0].get_height())
	sv.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(sv)
	for i in imgs.size():
		var tex := TextureRect.new()
		tex.texture = ImageTexture.create_from_image(imgs[i])
		tex.position = Vector2(i * w, 0)
		sv.add_child(tex)
		var label := Label.new()
		label.text = captions[i]
		label.position = tex.position + Vector2(8, 4)
		label.add_theme_font_size_override("font_size", 28)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 6)
		sv.add_child(label)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_save(sv.get_texture().get_image(), path)
	sv.queue_free()


func _gate() -> void:
	var errors := Errors.new()
	OS.add_logger(errors)
	var kit := ProjectSettings.globalize_path(LAB + "packs/kenney-building-kit/Models/")
	var glb := SCENE.load_node(kit + "GLB format/wall.glb")
	_templates.add_child(glb)
	var tex: Texture2D = null
	for mi: MeshInstance3D in glb.find_children("*", "MeshInstance3D", true, false):
		tex = (mi.mesh.surface_get_material(0) as BaseMaterial3D).albedo_texture
	_gate_line(0, tex != null, "colormap %s" % [tex.get_size() if tex else "missing"])
	var before := errors.count
	SCENE.cast(_cast_root, {"cast": [
		{"look": 1, "pose": "sit", "pos": [0, 0, 0], "face": 0.0, "act": "type"},
		{"look": 2, "pose": "lie", "pos": [2, 0, 0], "face": 1.5708, "act": "idle"},
		{"look": 3, "pose": "walk", "pos": [4, 0, 0], "face": 0.0},
		{"look": 4, "pose": "stand", "pos": [6, 0, 0], "face": 0.0, "act": "idle"}]}, {}, true)
	for i in 10:
		await get_tree().process_frame
	var heads := _cast_root.get_children().filter(func(n: Node) -> bool: return n is OfficePerson).map(
		func(p: OfficePerson) -> float: return snappedf(p.head_position().y, 0.01))
	_gate_line(1, errors.count == before and heads[1] < heads[0] and heads[0] < heads[2],
		"head heights sit, lie, stand %s, walk built, 10 frames, %d errors" % [heads, errors.count - before])
	# The engine logs a texture it cannot import from this folder; the FBX loader then reads the file itself.
	var fbx := SCENE.load_node(kit + "FBX format/wall.fbx")
	_templates.add_child(fbx)
	var box := SCENE.extent(fbx)
	_gate_line(2, absf(box.size.y - 2.4) < 0.1, "fbx wall %s" % [box.size])
	_load("mevcut", "ishani", {})
	before = errors.count
	var sun: DirectionalLight3D = _world.get_node("Sun")
	var energies := []
	for row: Array in OfficeLighting.CS:
		_lighting.apply(row[0])
		energies.append("%d=%.3f" % [row[0], sun.light_energy])
	_gate_line(3, errors.count == before, "sun energy %s, %d errors" % [" ".join(energies), errors.count - before])
	OS.remove_logger(errors)
	print("LABGATEDONE")


func _gate_line(n: int, ok: bool, detail: String) -> void:
	print("LABGATE|G%d|%s|%s" % [n, "ok" if ok else "FAIL", detail])
