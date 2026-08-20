@tool
extends Node3D
## ODA 3D spike — the reusable room scene (Godot-native rebuild of the sealed ODA render).
##
## SOURCE OF TRUTH: tools/oda_render_rig/layers.html (+ desk-builders.js). Geometry comes in
## through art/oda3d/oda3d_room.glb, exported from that scene by docs/tools/oda3d/export_glb.html
## (a verbatim slice of layers.html — see docs/audits/AUDIT_2026-08-19_oda3d_source.md).
## Camera, lights and material values are read from art/oda3d/oda3d_source_scene.json (written by
## the same page) so nothing here is retyped by hand; the only authored things are the
## Three→Godot unit conversions and the Godot-only quality additions (GI, soft shadows, SSAO/SSIL/
## SSR, micro-material). Every conversion is stated next to the value it produces.
##
## Godot concept: an `@tool` script runs inside the editor too — the LightmapGI bake needs the
## materials, cast-shadow and GI flags applied while the editor holds the scene, so `_ready()`
## applies them in both editor and game.

const SOURCE_JSON := "res://art/oda3d/oda3d_source_scene.json"
const ROOM_SCENE := "res://art/oda3d/oda3d_room.glb"

## Three.js r0.184 uses physical light units without the π/π cancellation Godot's non-physical
## path has: Godot multiplies light energy by π and Lambert divides by π, so outgoing radiance
## for energy E is albedo·E·NdotL; Three's is albedo·(I/π)·NdotL. Hence E = I / π.
const THREE_TO_GODOT_ENERGY := 1.0 / PI

## Sealed light-logic reproduction (Erdem ruling A, 2026-08-19): the window wall segments do NOT
## cast the sun's shadow in the source (rseg meshes have castShadow=false; only the mullions cast).
## Godot's lightmapper ignores cast_shadow (issue #56870), so the same effect in the bake needs
## these four meshes excluded from the bake geometry: GI_MODE_DYNAMIC (they receive light probes
## instead of a lightmap and never occlude). Real-time: cast_shadow OFF lets the sun through.
const WALL_CHEAT_NODES: Array[String] = ["rw_below", "rw_above", "rw_back", "rw_front"]
## Source castShadow=false set (Three default false unless shadowed()): room shell + sky slab.
const NO_CAST_NODES: Array[String] = ["floor", "wall_back", "wall_left", "rw_below", "rw_above", "rw_back", "rw_front", "sky"]

var source: Dictionary = {}
var mode: String = "day"
## Emission energy of the window sky slab (source: unlit MeshBasicMaterial through ACES). Godot's
## ACES fit is hotter than three's; tuned by measurement so the window reads cream, not clipped.
@export var sky_emission_energy: float = 0.55
## Night sky slab (0x1e2638) is dim to begin with; the day value under-lights it (measured 0.71
## of sealed), so the night plate uses its own energy.
@export var sky_emission_energy_night: float = 1.0
## Micro-variation strength multiplier for plaster/wood/cork (1.0 = the built-in amplitudes).
@export var micro_strength: float = 1.0
## Multiplier on the hemisphere (sky/ground) ambient energy. three's HemisphereLight is
## UNOCCLUDED (every up-facing point gets the full sky); Godot's baked sky is occluded by the real
## walls, so matching the sealed shadow depth needs a little more sky. Measured, not guessed —
## see docs/audits/AUDIT_2026-08-19_oda3d_render_spike.md.
@export var ambient_scale: float = 0.7
## Exposure = source toneMappingExposure (1.05 day / 1.0 night) × these. Godot's ACES fit runs
## brighter than three's ACESFilmic at the same exposure; the factors were set from the region
## table (sun-lit desk → 1.0 of sealed), not by eye.
@export var exposure_scale_day: float = 0.90
@export var exposure_scale_night: float = 0.71
var materials: Dictionary = {}          # material name -> StandardMaterial3D (built once)
var _bulb_mat: StandardMaterial3D
var _sky_mat: StandardMaterial3D
var _screen_mat: StandardMaterial3D

@onready var camera: Camera3D = $Camera3D
@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var lightmap_gi: LightmapGI = $LightmapGI
@onready var day_rig: Node3D = $DayRig
@onready var night_rig: Node3D = $NightRig
@onready var room: Node3D = $Room


func _ready() -> void:
	source = _load_source()
	if source.is_empty():
		push_error("oda3d: source JSON missing: %s" % SOURCE_JSON)
		return
	_setup_camera()
	_build_materials()
	_apply_materials_and_flags()
	_setup_lights()
	set_mode(mode)


func _load_source() -> Dictionary:
	if not FileAccess.file_exists(SOURCE_JSON):
		return {}
	var txt: String = FileAccess.get_file_as_string(SOURCE_JSON)
	var parsed: Variant = JSON.parse_string(txt)
	return parsed if parsed is Dictionary else {}


# ---------------------------------------------------------------------------
# Camera — the pinned solve, applied exactly as layers.html applyCam(): position from
# cam[0..2], look-at at the DERIVED target (camTarget), vertical fov cam[5], near/far as source.
# Godot's Camera3D fov is vertical when keep_aspect = KEEP_HEIGHT (default) — same axis as
# three.PerspectiveCamera.fov. Both look down -Z with +Y up, so look_at is convention-identical.
# ---------------------------------------------------------------------------
func _setup_camera() -> void:
	var cam: Dictionary = source.get("camera", {})
	var p: Array = cam.get("position", [0.298, 1.35, 1.56])
	var t: Array = cam.get("target", [0.30463, 1.31667, 0.56058])
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	camera.fov = float(cam.get("fov_deg", 44.0))
	camera.near = float(cam.get("near", 0.05))
	camera.far = float(cam.get("far", 40.0))
	camera.look_at_from_position(Vector3(p[0], p[1], p[2]), Vector3(t[0], t[1], t[2]), Vector3.UP)


# ---------------------------------------------------------------------------
# Materials — one StandardMaterial3D per glTF material name. Base values are the source's
# (albedo/roughness/metallic/emissive from oda3d_source_scene.json.materials); the Godot-only
# additions are subtle procedural micro-variation (NoiseTexture2D, triplanar) so lit surfaces
# don't read as flat vinyl. Amplitudes are kept small on purpose: the mean albedo must stay the
# source's so the room keeps its tint and the plate-vs-plate exposure comparison stays honest.
# ---------------------------------------------------------------------------
func _build_materials() -> void:
	materials.clear()
	var src_mats: Dictionary = source.get("materials", {})
	for mname in src_mats.keys():
		var s: Dictionary = src_mats[mname]
		var m := StandardMaterial3D.new()
		m.resource_name = mname
		m.albedo_color = Color.html(s.get("color", "#ffffff"))
		m.roughness = float(s.get("roughness", 1.0))
		m.metallic = float(s.get("metallic", 0.0))
		m.metallic_specular = 0.5
		if s.has("emissive") and s.get("emissive", "#000000") != "#000000":
			m.emission_enabled = true
			m.emission = Color.html(s["emissive"])
			m.emission_energy_multiplier = float(s.get("emissiveIntensity", 1.0))
		match mname:
			"plaster", "plaster_r":
				_add_micro(m, 0.02 * micro_strength, 0.05, Vector3(3.0, 3.0, 3.0), 0.9, 0.18 * micro_strength)
			"desk_wood", "desk_wood_dark", "oak_wood", "oak_wood_dark", "mullion":
				# anisotropic triplanar scale = grain streaks along X/Z (desk length runs along X)
				_add_micro(m, 0.05 * micro_strength, 0.10, Vector3(1.2, 9.0, 9.0), 0.8, 0.2 * micro_strength)
			"cork":
				_add_micro(m, 0.05 * micro_strength, 0.08, Vector3(14.0, 14.0, 14.0), 0.9, 0.4 * micro_strength)
			"paper":
				_add_micro(m, 0.015, 0.05, Vector3(20.0, 20.0, 20.0), 0.9, 0.15)
			"floor":
				_add_micro(m, 0.05, 0.08, Vector3(1.0, 6.0, 6.0), 0.8, 0.3)
			"sky":
				# Unlit in the source (MeshBasicMaterial). In Godot an unshaded material does not
				# emit into the bake, so: black albedo + emission = the sky colour. Reads identically
				# on screen (no light response) and lights the room in the lightmap.
				m.albedo_color = Color.BLACK
				m.roughness = 1.0
				m.emission_enabled = true
				m.emission = Color.html(source["setMode"].get("sky_day", "#ffedc8"))
				m.emission_energy_multiplier = sky_emission_energy
				_sky_mat = m
			"screen_glass":
				# Sealed contract: DARK GLASS in both modes (the game paints the glass). setMode()
				# in the source forces roughness 0.15 and zero emissive. SSR + reflection probe give
				# it real reflections here instead of a flat #141117.
				m.roughness = float(source["setMode"].get("screen_roughness", 0.15))
				m.emission_enabled = false
				m.clearcoat_enabled = true
				m.clearcoat = 0.6
				m.clearcoat_roughness = 0.05
				_screen_mat = m
			"warm_bulb":
				_bulb_mat = m
		materials[mname] = m


## Subtle micro-variation: a NoiseTexture2D drives albedo (multiplicative, mean ≈ 1 - amp/2),
## roughness (± rough_amp) and a faint normal map, all sampled triplanar in world space so the
## glTF's box UVs never show a seam. `contrast` narrows the noise ramp; `normal_strength` is the
## bump depth (kept far below 1.0).
func _add_micro(m: StandardMaterial3D, albedo_amp: float, rough_amp: float, scale: Vector3, contrast: float, normal_strength: float) -> void:
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.02
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.55
	noise.seed = int(hash(m.resource_name)) % 100000
	# albedo modulation ramp: [1 - amp, 1] in gray
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.0 - albedo_amp, 1.0 - albedo_amp, 1.0 - albedo_amp))
	ramp.set_color(1, Color(1, 1, 1))
	var alb := NoiseTexture2D.new()
	alb.width = 512; alb.height = 512
	alb.seamless = true
	alb.noise = noise
	alb.color_ramp = ramp
	alb.generate_mipmaps = true
	m.albedo_texture = alb
	# roughness: same noise, mapped to [rough - amp, rough + amp] via texture channel; the
	# StandardMaterial3D roughness texture MULTIPLIES the roughness value, so build a ramp
	# around 1.0.
	var rramp := Gradient.new()
	var lo: float = clampf(1.0 - rough_amp / maxf(m.roughness, 0.05), 0.0, 1.0)
	rramp.set_color(0, Color(lo, lo, lo))
	rramp.set_color(1, Color(1, 1, 1))
	var rough := NoiseTexture2D.new()
	rough.width = 512; rough.height = 512
	rough.seamless = true
	rough.noise = noise
	rough.color_ramp = rramp
	m.roughness_texture = rough
	m.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	# normal map from the same noise
	var nrm := NoiseTexture2D.new()
	nrm.width = 512; nrm.height = 512
	nrm.seamless = true
	nrm.noise = noise
	nrm.as_normal_map = true
	nrm.bump_strength = 2.0 * contrast
	m.normal_enabled = true
	m.normal_texture = nrm
	m.normal_scale = normal_strength
	# world-space triplanar so UV layout of the boxes is irrelevant
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = scale
	m.uv1_triplanar_sharpness = 4.0


func _apply_materials_and_flags() -> void:
	if room == null:
		return
	for n in room.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		var mesh: Mesh = mi.mesh
		if mesh == null:
			continue
		for s in range(mesh.get_surface_count()):
			var src_mat: Material = mesh.surface_get_material(s)
			var mname: String = src_mat.resource_name if src_mat else ""
			if materials.has(mname):
				mi.set_surface_override_material(s, materials[mname])
		# Shadow-casting flags as in the source (Three castShadow); GI mode per the wall-cheat.
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if NO_CAST_NODES.has(mi.name) else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		mi.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC if WALL_CHEAT_NODES.has(mi.name) else GeometryInstance3D.GI_MODE_STATIC


# ---------------------------------------------------------------------------
# Lights — positions/colours/targets from the source rigs (layers.html:150-199), energies
# converted (I/π), ranges/decays carried over. Godot adds shadow softness (light_size /
# angular_distance) and bake_mode DYNAMIC (indirect baked, direct real-time with shadows).
# ---------------------------------------------------------------------------
func _setup_lights() -> void:
	# Lights are rebuilt from the source JSON on every load (the JSON stays the single source of
	# truth). free() rather than queue_free() so a re-run cannot collide on node names.
	# OWNERSHIP MATTERS FOR THE BAKE: LightmapGI._find_meshes_and_lights() skips every child that
	# has no owner ("maybe a helper"). Unowned lights = a bake with no lights in it — measured
	# 2026-08-19: six bakes whose atlas held only the window slab's emission. So in the editor the
	# spawned lights are owned by the scene root; at runtime ownership is irrelevant.
	for c in day_rig.get_children():
		c.free()
	for c in night_rig.get_children():
		c.free()
	var day: Array = source["lights"]["day"]
	var night: Array = source["lights"]["night"]
	for l in day:
		_spawn_light(day_rig, l, "day")
	for l in night:
		_spawn_light(night_rig, l, "night")


func _spawn_light(parent: Node3D, l: Dictionary, which: String) -> void:
	var col := Color.html(l.get("color", "#ffffff"))
	var inten := float(l.get("intensity", 1.0))
	match l.get("type", ""):
		"HemisphereLight":
			# Sky/ground ambient → Environment ambient colour, applied in set_mode() (needs the
			# per-mode env), and the LightmapGI environment for the bake. Stored on the rig node.
			parent.set_meta("hemi_sky", col)
			parent.set_meta("hemi_ground", Color.html(l.get("groundColor", "#000000")))
			parent.set_meta("hemi_energy", inten * THREE_TO_GODOT_ENERGY * ambient_scale)
		"DirectionalLight":
			var d := DirectionalLight3D.new()
			d.name = "Sun" if bool(l.get("castShadow", false)) else "Fill"
			d.light_color = col
			d.light_energy = inten * THREE_TO_GODOT_ENERGY
			var p: Array = l["position"]
			var t: Array = l.get("target", [0, 0, 0])
			d.look_at_from_position(Vector3(p[0], p[1], p[2]), Vector3(t[0], t[1], t[2]), Vector3.UP)
			d.shadow_enabled = bool(l.get("castShadow", false))
			d.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
			d.directional_shadow_max_distance = 12.0
			d.directional_shadow_blend_splits = false
			d.light_angular_distance = 0.5      # real sun ≈ 0.53° → PCSS penumbra instead of PCF
			d.shadow_bias = 0.02
			d.shadow_normal_bias = 1.0
			d.light_bake_mode = Light3D.BAKE_DYNAMIC
			d.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY   # no sun disc in the hemisphere sky
			d.light_volumetric_fog_energy = 1.0 if d.shadow_enabled else 0.0
			parent.add_child(d)
			_own(d)
		"PointLight":
			var o := OmniLight3D.new()
			o.name = "Ceiling" if inten > 1.0 else "MouthGlow"
			o.light_color = col
			o.light_energy = inten * THREE_TO_GODOT_ENERGY
			o.omni_range = float(l.get("distance", 5.0))
			o.omni_attenuation = float(l.get("decay", 2.0))
			var p: Array = l["position"]
			o.position = Vector3(p[0], p[1], p[2])
			o.shadow_enabled = bool(l.get("castShadow", false))
			o.omni_shadow_mode = OmniLight3D.SHADOW_CUBE   # default dual-paraboloid stair-steps on the board edge (seen at 1080p)
			o.light_size = 0.06 if o.shadow_enabled else 0.0
			o.shadow_bias = 0.02
			o.shadow_normal_bias = 1.5
			o.shadow_blur = 2.0   # kills the residual 1-px serration on the board's shadow edge at 8K
			o.light_bake_mode = Light3D.BAKE_DYNAMIC
			parent.add_child(o)
			_own(o)
		"SpotLight":
			var s := SpotLight3D.new()
			s.name = "LampSpot"
			s.light_color = col
			s.light_energy = inten * THREE_TO_GODOT_ENERGY
			s.spot_range = float(l.get("distance", 2.0))
			s.spot_attenuation = float(l.get("decay", 2.0))
			s.spot_angle = rad_to_deg(float(l.get("angle", 0.5)))
			# Three penumbra p: full intensity inside angle·(1-p), smoothstep to 0 at angle.
			# Godot spot_angle_attenuation is a power on the rim; ~1 gives a comparable soft rim.
			s.spot_angle_attenuation = 1.0
			var p: Array = l["position"]
			var t: Array = l.get("target", [0, 0, 0])
			s.look_at_from_position(Vector3(p[0], p[1], p[2]), Vector3(t[0], t[1], t[2]), Vector3.UP)
			s.shadow_enabled = bool(l.get("castShadow", false))
			s.light_size = 0.02
			s.shadow_bias = 0.03
			s.shadow_normal_bias = 1.0
			s.light_bake_mode = Light3D.BAKE_DYNAMIC
			parent.add_child(s)
			_own(s)


func _own(n: Node) -> void:
	if Engine.is_editor_hint():
		n.owner = owner if owner else self


# ---------------------------------------------------------------------------
# Mode switch — mirrors layers.html setMode(): rig visibility, sky colour, exposure, bulb
# emissive; screens stay dark glass. Also swaps the baked lightmap for the mode.
# ---------------------------------------------------------------------------
func set_mode(m: String) -> void:
	mode = "night" if m == "night" else "day"
	var day := mode == "day"
	var sm: Dictionary = source.get("setMode", {})
	if day_rig:
		day_rig.visible = day
	if night_rig:
		night_rig.visible = not day
	if _sky_mat:
		_sky_mat.emission = Color.html(sm.get("sky_day" if day else "sky_night", "#ffedc8"))
		_sky_mat.emission_energy_multiplier = sky_emission_energy if day else sky_emission_energy_night
	if _bulb_mat:
		_bulb_mat.emission = Color.html(sm.get("bulb_emissive_day" if day else "bulb_emissive_night", "#ffdda0"))
		_bulb_mat.emission_energy_multiplier = float(sm.get("bulb_emissiveIntensity_day" if day else "bulb_emissiveIntensity_night", 0.15))
	var rig: Node3D = day_rig if day else night_rig
	var sky: Sky = _hemisphere_sky(rig)
	if world_env and world_env.environment:
		var env := world_env.environment
		env.tonemap_exposure = float(source.get("renderer", {}).get("toneMappingExposure_day" if day else "toneMappingExposure_night", 1.0)) * (exposure_scale_day if day else exposure_scale_night)
		if sky:
			# Real-time ambient (only matters for non-lightmapped surfaces: the four GI_MODE_DYNAMIC
			# wall-cheat segments before probes kick in) from the same two-tone sky.
			env.sky = sky
			env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
			env.ambient_light_sky_contribution = 1.0
			env.ambient_light_energy = 1.0
			env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
			env.background_mode = Environment.BG_COLOR
			env.background_color = rig.get_meta("hemi_sky")
			env.background_energy_multiplier = float(rig.get_meta("hemi_energy"))
	if lightmap_gi and rig and rig.has_meta("hemi_sky"):
		# Bake environment = uniform sky colour × I/π (three's HemisphereLight sky term). The ground
		# term is NOT emulated with a colour: in the bake the floor's real bounce plays that role
		# (three's 0x8a6f4d is a stand-in for exactly that). A custom two-tone Sky was tried and
		# abandoned: sky_bake_panorama() needs the Sky's radiance cubemap rendered by a viewport
		# first, which the headless-ish bake driver cannot guarantee (an all-zero bake resulted).
		lightmap_gi.environment_mode = LightmapGI.ENVIRONMENT_MODE_CUSTOM_COLOR
		lightmap_gi.environment_custom_color = rig.get_meta("hemi_sky")
		lightmap_gi.environment_custom_energy = float(rig.get_meta("hemi_energy"))
		lightmap_gi.environment_custom_sky = null
		var lm_path := "res://scenes/oda3d/oda3d_%s.lmbake" % mode
		if ResourceLoader.exists(lm_path):
			var data: LightmapGIData = load(lm_path)
			if data and data.get_lightmap_textures().size() > 0:
				lightmap_gi.light_data = data


## three.js HemisphereLight(sky, ground, I) as a Godot Sky: irradiance on a surface of normal n is
## mix(ground, sky, 0.5·n.y+0.5)·I/π in three; a two-tone sky with the same colours and energy I/π
## integrates to the same value (a vertical surface sees half of each). Sun discs are disabled by
## giving the directional lights sky_mode LIGHT_ONLY (see _spawn_light).
func _hemisphere_sky(rig: Node3D) -> Sky:
	if rig == null or not rig.has_meta("hemi_sky"):
		return null
	if rig.has_meta("hemi_sky_res"):
		return rig.get_meta("hemi_sky_res")
	var mat := ProceduralSkyMaterial.new()
	var e: float = float(rig.get_meta("hemi_energy"))
	var top: Color = rig.get_meta("hemi_sky")
	var ground: Color = rig.get_meta("hemi_ground")
	mat.sky_top_color = top
	mat.sky_horizon_color = top
	mat.sky_curve = 1.0
	mat.sky_energy_multiplier = e
	mat.ground_bottom_color = ground
	mat.ground_horizon_color = ground
	mat.ground_curve = 1.0
	mat.ground_energy_multiplier = e
	mat.sun_angle_max = 0.0
	mat.sun_curve = 0.0
	mat.use_debanding = false
	var sky := Sky.new()
	sky.sky_material = mat
	sky.radiance_size = Sky.RADIANCE_SIZE_64
	sky.process_mode = Sky.PROCESS_MODE_QUALITY
	rig.set_meta("hemi_sky_res", sky)
	return sky


# ---------------------------------------------------------------------------
# Composition proof — port of layers.html projectObject()/anchorsNorm(): the 8 corners of every
# mesh's local AABB → world → camera.unproject_position → normalized to the camera's viewport.
# Returned rects use the same 11 keys as the rig's anchors.json, so the gate is a subtraction.
# ---------------------------------------------------------------------------
func project_anchors() -> Dictionary:
	var vp_size: Vector2 = camera.get_viewport().get_visible_rect().size
	var out := {}
	out["board_outer"] = _proj_norm(_find("cork_board"), vp_size)
	out["board_inner"] = _proj_norm(_find("cork_panel"), vp_size)
	var f0 := _proj_norm(_find("picture_frame"), vp_size)
	var f1 := _proj_norm(_find("picture_frame2"), vp_size)
	var f2 := _proj_norm(_find("picture_frame3"), vp_size)
	out["frame_outer_0"] = f0
	out["frame_outer_1"] = f1
	out["frame_outer_2"] = f2
	if f0.size() == 4 and f1.size() == 4 and f2.size() == 4:
		var x0: float = min(f0[0], f1[0], f2[0])
		var y0: float = min(f0[1], f1[1], f2[1])
		var x1: float = max(f0[0] + f0[2], f1[0] + f1[2], f2[0] + f2[2])
		var y1: float = max(f0[1] + f0[3], f1[1] + f1[3], f2[1] + f2[3])
		out["frames_band"] = [x0, y0, x1 - x0, y1 - y0]
	out["window"] = _proj_norm(_find("window_frame"), vp_size)
	out["monitor"] = _proj_norm(_find("monitor"), vp_size)
	out["lamp"] = _proj_norm(_find("desk_lamp"), vp_size)
	out["mug"] = _proj_norm(_find("mug"), vp_size)
	out["phone"] = _proj_norm(_find("phone"), vp_size)
	out["desk_top"] = _proj_norm(_find("desk_top"), vp_size)
	return out


func _find(n: String) -> Node:
	if room == null:
		return null
	if room.name == n:
		return room
	return room.find_child(n, true, false)


func _proj_norm(n: Node, vp_size: Vector2) -> Array:
	if n == null:
		return []
	var minx := INF; var miny := INF; var maxx := -INF; var maxy := -INF
	var found := false
	var meshes: Array[Node] = []
	if n is MeshInstance3D:
		meshes.append(n)
	meshes.append_array(n.find_children("*", "MeshInstance3D", true, false))
	for m in meshes:
		var mi := m as MeshInstance3D
		if mi.mesh == null:
			continue
		var aabb: AABB = mi.mesh.get_aabb()
		for i in range(8):
			var corner: Vector3 = aabb.get_endpoint(i)
			var wp: Vector3 = mi.global_transform * corner
			var sp: Vector2 = camera.unproject_position(wp)
			minx = minf(minx, sp.x); maxx = maxf(maxx, sp.x)
			miny = minf(miny, sp.y); maxy = maxf(maxy, sp.y)
			found = true
	if not found:
		return []
	return [minx / vp_size.x, miny / vp_size.y, (maxx - minx) / vp_size.x, (maxy - miny) / vp_size.y]


## Everything the plate JSON needs about this scene, for oda3d_camera_light.json.
func describe() -> Dictionary:
	var lights := []
	for rig in [day_rig, night_rig]:
		if rig == null:
			continue
		for l in rig.get_children():
			if l is Light3D:
				var d := {
					"rig": rig.name, "name": l.name, "type": l.get_class(),
					"transform": _xf(l.global_transform), "color": l.light_color.to_html(false),
					"energy": l.light_energy, "shadow": l.shadow_enabled, "bake_mode": l.light_bake_mode,
					"shadow_bias": l.shadow_bias, "shadow_normal_bias": l.shadow_normal_bias,
				}
				if l is OmniLight3D:
					d["range"] = l.omni_range; d["attenuation"] = l.omni_attenuation; d["light_size"] = l.light_size
				if l is SpotLight3D:
					d["range"] = l.spot_range; d["attenuation"] = l.spot_attenuation; d["angle_deg"] = l.spot_angle; d["angle_attenuation"] = l.spot_angle_attenuation; d["light_size"] = l.light_size
				if l is DirectionalLight3D:
					d["angular_distance_deg"] = l.light_angular_distance; d["shadow_mode"] = l.directional_shadow_mode; d["shadow_max_distance"] = l.directional_shadow_max_distance
				lights.append(d)
		if rig.has_meta("hemi_sky"):
			lights.append({"rig": rig.name, "name": "HemisphereAmbient", "type": "Environment.ambient", "color": (rig.get_meta("hemi_sky") as Color).to_html(false), "energy": rig.get_meta("hemi_energy")})
	var env := world_env.environment if world_env else null
	var envd := {}
	if env:
		envd = {
			"tonemap_mode": env.tonemap_mode, "tonemap_exposure": env.tonemap_exposure, "tonemap_white": env.tonemap_white,
			"agx_white": env.tonemap_agx_white, "agx_contrast": env.tonemap_agx_contrast,
			"ambient_source": env.ambient_light_source, "ambient_color": env.ambient_light_color.to_html(false), "ambient_energy": env.ambient_light_energy,
			"ssao": {"enabled": env.ssao_enabled, "radius": env.ssao_radius, "intensity": env.ssao_intensity, "power": env.ssao_power, "detail": env.ssao_detail, "horizon": env.ssao_horizon, "sharpness": env.ssao_sharpness, "light_affect": env.ssao_light_affect},
			"ssil": {"enabled": env.ssil_enabled, "radius": env.ssil_radius, "intensity": env.ssil_intensity, "sharpness": env.ssil_sharpness, "normal_rejection": env.ssil_normal_rejection},
			"ssr": {"enabled": env.ssr_enabled, "max_steps": env.ssr_max_steps, "fade_in": env.ssr_fade_in, "fade_out": env.ssr_fade_out, "depth_tolerance": env.ssr_depth_tolerance},
			"sdfgi": {"enabled": env.sdfgi_enabled, "cascades": env.sdfgi_cascades, "min_cell_size": env.sdfgi_min_cell_size, "use_occlusion": env.sdfgi_use_occlusion, "bounce_feedback": env.sdfgi_bounce_feedback, "energy": env.sdfgi_energy},
			"glow": {"enabled": env.glow_enabled, "intensity": env.glow_intensity, "strength": env.glow_strength, "bloom": env.glow_bloom, "hdr_threshold": env.glow_hdr_threshold, "blend_mode": env.glow_blend_mode},
			"volumetric_fog": {"enabled": env.volumetric_fog_enabled, "density": env.volumetric_fog_density, "albedo": env.volumetric_fog_albedo.to_html(false), "anisotropy": env.volumetric_fog_anisotropy, "gi_inject": env.volumetric_fog_gi_inject},
			"background_mode": env.background_mode, "background_color": env.background_color.to_html(false),
		}
	var lm := {}
	if lightmap_gi:
		lm = {"quality": lightmap_gi.quality, "bounces": lightmap_gi.bounces, "directional": lightmap_gi.directional, "denoiser": lightmap_gi.use_denoiser,
			"supersampling": lightmap_gi.supersampling, "supersampling_factor": lightmap_gi.supersampling_factor, "max_texture_size": lightmap_gi.max_texture_size, "texel_scale": lightmap_gi.texel_scale,
			"environment_mode": lightmap_gi.environment_mode, "env_custom_sky": "ProceduralSkyMaterial two-tone (three HemisphereLight: sky/ground × I/π)" if lightmap_gi.environment_custom_sky else "", "env_energy": lightmap_gi.environment_custom_energy,
			"has_light_data": lightmap_gi.light_data != null and lightmap_gi.light_data.get_lightmap_textures().size() > 0,
			"light_data_path": lightmap_gi.light_data.resource_path if lightmap_gi.light_data else ""}
	return {
		"mode": mode,
		"camera": {"transform": _xf(camera.global_transform), "position": _v(camera.global_position), "fov_deg": camera.fov, "keep_aspect": camera.keep_aspect, "near": camera.near, "far": camera.far, "projection": camera.projection},
		"lights": lights, "environment": envd, "lightmap_gi": lm,
		"energy_conversion": "godot_energy = three_intensity / PI (non-physical light units; Godot ×π cancels Lambert /π)",
	}


static func _v(v: Vector3) -> Array:
	return [v.x, v.y, v.z]

static func _xf(t: Transform3D) -> Dictionary:
	return {"origin": _v(t.origin), "basis_x": _v(t.basis.x), "basis_y": _v(t.basis.y), "basis_z": _v(t.basis.z)}
