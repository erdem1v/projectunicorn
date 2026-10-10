extends RefCounted

# GraphicsSettings — the 3D view's quality: four presets (data/graphics/presets.json) and the options
# under them. Settings persists, this applies: the renderer's global state here, the office view's own
# nodes through OfficeView.apply_graphics. All static.
#
# The stored preset is the base and `graphics` holds the options the player moved off it. With no
# stored preset the machine picks one (_detect) on every boot until the player chooses.
#
# The scene file is the medium preset, so a run DisplaySettings calls inert keeps that frame unless
# `--gfx=<preset>` forces one; the flag itself writes nothing to Settings.

# Preloads, not class names: Settings preloads this file, and an autoload that cannot resolve a class
# name from a stale script-class cache takes the whole game down.
const DisplaySettingsLib := preload("res://scripts/systems/display_settings.gd")
const OfficeCameraLib := preload("res://scripts/ui/office/office_camera.gd")

const DATA_PATH := "res://data/graphics/presets.json"
const ORDER: Array[String] = ["low", "medium", "high", "ultra"]
const CUSTOM := "custom"
const KEY_PRESET := "graphics_preset"
const KEY_OPTIONS := "graphics"
const FLAG := "--gfx="

## Internal pixels per logical pixel at "fsr", and the supersampling factor at "super". Only a whole
## factor stays still while the camera is dragged.
const FSR_SCALE := 0.67
const SUPER_SCALE := 2.0
## The large-screen line of a preset applies from this screen height up.
const LARGE_SCREEN_H := 2160
## Tilt-shift: a sharp band around the camera's target, which stands OfficeCamera.DISTANCE away.
const DOF_BAND := 3.0
const DOF_TRANSITION := 6.0
const DOF_AMOUNT := 0.12
## SSAO from a camera 120 m off: the engine's default fade (50 to 300 m) thins it out over the office.
const SSAO_FADE := Vector2(400.0, 800.0)

static var _table: Dictionary = {}
static var _detected := ""
## The command line's preset (CLI) or the editor run's (main_args), "" without one.
static var _flag := _read_flag()


static func _read_flag() -> String:
	var args := OS.get_cmdline_args()
	args.append_array(String(ProjectSettings.get_setting("application/run/main_args", "")).split(" ", false))
	for arg: String in args:
		if arg.begins_with(FLAG) and arg.trim_prefix(FLAG) in ORDER:
			return arg.trim_prefix(FLAG)
	return ""


static func _data() -> Dictionary:
	if _table.is_empty():
		_table = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	return _table


## Does anything apply? Off in harness runs unless --gfx= forces a preset.
static func active() -> bool:
	return _flag != "" or not DisplaySettingsLib.is_inert()


static func _preset() -> String:
	if _flag != "":
		return _flag
	if not Settings.has_stored(KEY_PRESET):
		return _detect()
	return Settings.get_choice(KEY_PRESET, ORDER)


## A preset's values on this screen. Every number is a whole one, and JSON brings them back as floats.
static func preset_values(id: String) -> Dictionary:
	var p: Dictionary = (_data().presets[id] as Dictionary).duplicate()
	var large: Dictionary = p.get("large_screen", {})
	p.erase("large_screen")
	if DisplaySettingsLib.native_resolution().y >= LARGE_SCREEN_H:
		p.merge(large, true)
	for key in p:
		if p[key] is float:
			p[key] = int(p[key])
	return p


## Every option's live value; the preset's value sets the type of a stored one.
static func options() -> Dictionary:
	var out := preset_values(_preset())
	if _flag == "":
		var moved: Dictionary = Settings.get_value(KEY_OPTIONS)
		for key in moved:
			if out.has(key):
				out[key] = type_convert(moved[key], typeof(out[key]))
	return out


## The preset the options match, else CUSTOM: the selector's row.
static func shown_preset() -> String:
	var now := options()
	for id in ORDER:
		if preset_values(id) == now:
			return id
	return CUSTOM


static func set_preset(id: String) -> void:
	Settings.set_value(KEY_PRESET, id)
	Settings.set_value(KEY_OPTIONS, {})
	apply()


static func set_option(key: String, v: Variant) -> void:
	var moved: Dictionary = (Settings.get_value(KEY_OPTIONS) as Dictionary).duplicate()
	if preset_values(_preset())[key] == v:
		moved.erase(key)
	else:
		moved[key] = v
	# Writing the preset too stops a detected one from changing under the player's own options.
	Settings.set_value(KEY_PRESET, _preset())
	Settings.set_value(KEY_OPTIONS, moved)
	apply()


## The renderer's global state (shadow atlas and filter, SSAO quality, frame cap), then every office view
## on screen. Boot and reset reach it through Settings.apply_all, before any scene exists.
static func apply() -> void:
	if active():
		var o := options()
		RenderingServer.directional_shadow_atlas_set_size(o.shadow_size, true)
		RenderingServer.directional_soft_shadow_filter_set_quality(
			RenderingServer.SHADOW_QUALITY_SOFT_HIGH if o.soft_shadows else RenderingServer.SHADOW_QUALITY_HARD)
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, false,
			ProjectSettings.get_setting("rendering/environment/ssao/adaptive_target"),
			ProjectSettings.get_setting("rendering/environment/ssao/blur_passes"), SSAO_FADE.x, SSAO_FADE.y)
		Engine.max_fps = o.fps_cap
	(Engine.get_main_loop() as SceneTree).call_group(&"office_view", &"apply_graphics")


## Physical pixels per logical pixel of the 3D image: its texture size over its logical size.
static func density(window: Window, o: Dictionary) -> float:
	return window.get_final_transform().get_scale().x if active() and o.resolution != "logical" else 1.0


## The office view's own nodes at `o` (options()); `scene` holds the loaded layout.
static func apply_view(sub: SubViewport, world: Node3D, scene: Node3D, o: Dictionary, dens: float) -> void:
	if not active():
		return
	var scale := 1.0
	match o.resolution:
		"fsr":
			scale = FSR_SCALE / dens
		"super":
			scale = SUPER_SCALE
	sub.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR if o.resolution == "fsr" else Viewport.SCALING_3D_MODE_BILINEAR
	sub.scaling_3d_scale = scale
	sub.msaa_3d = int(o.msaa) as Viewport.MSAA
	sub.screen_space_aa = int(o.aa) as Viewport.ScreenSpaceAA
	sub.use_debanding = o.deband
	sub.positional_shadow_atlas_size = 4096 if o.lamp_shadows else 0
	for lamp in ["Lamp0", "Lamp1", "Screen0", "Screen1"]:
		(world.get_node(lamp) as Light3D).shadow_enabled = o.lamp_shadows
	var env := (world.get_node("WorldEnvironment") as WorldEnvironment).environment
	env.glow_enabled = o.glow
	env.ssao_enabled = o.ssao
	# The scene's line weight, in logical pixels, kept as the image's pixel density changes.
	var ink := (world.get_node("InkPass") as MeshInstance3D).material_override as ShaderMaterial
	var texel: float = RenderingServer.shader_get_parameter_default(ink.shader.get_rid(), &"texel")
	ink.set_shader_parameter("texel", texel * dens * scale)
	ink.set_shader_parameter("vignette", null if o.vignette else 0.0)
	var camera := world.get_node("Camera3D") as Camera3D
	if o.tilt_shift != (camera.attributes != null):
		camera.attributes = _tilt_shift() if o.tilt_shift else null
	# The design leaves parts under 0.45 m out of the Sun's shadow; the option lets the opaque ones cast.
	for mi: MeshInstance3D in scene.find_children("*", "MeshInstance3D", true, false):
		var m := mi.get_active_material(0)
		if mi.get_meta("extras", {}).get("noCast", false) \
				and not (m is BaseMaterial3D and (m as BaseMaterial3D).transparency != BaseMaterial3D.TRANSPARENCY_DISABLED):
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if o.small_shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


static func _tilt_shift() -> CameraAttributesPractical:
	var a := CameraAttributesPractical.new()
	a.dof_blur_far_enabled = true
	a.dof_blur_far_distance = OfficeCameraLib.DISTANCE + DOF_BAND
	a.dof_blur_far_transition = DOF_TRANSITION
	a.dof_blur_near_enabled = true
	a.dof_blur_near_distance = OfficeCameraLib.DISTANCE - DOF_BAND
	a.dof_blur_near_transition = DOF_TRANSITION
	a.dof_blur_amount = DOF_AMOUNT
	return a


## First launch: the adapter's name against the JSON's lists, then its type. Unknown is medium, and
## nothing lands on ultra by itself.
static func _detect() -> String:
	if _detected != "":
		return _detected
	_detected = "medium"
	if DisplaySettingsLib.is_inert():
		return _detected
	var adapter := RenderingServer.get_video_adapter_name()
	var rules: Dictionary = _data().detect
	for id in ["low", "medium"]:
		if RegEx.create_from_string(rules[id]).search(adapter) != null:
			_detected = id
			return _detected
	match RenderingServer.get_video_adapter_type():
		RenderingDevice.DEVICE_TYPE_INTEGRATED_GPU, RenderingDevice.DEVICE_TYPE_CPU:
			_detected = "low"
		RenderingDevice.DEVICE_TYPE_DISCRETE_GPU:
			_detected = "high"
	return _detected
