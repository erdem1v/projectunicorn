@tool
extends Node3D
## ODA 3D — the reusable room scene (Godot-native rebuild of the sealed ODA render).
##
## SOURCE OF TRUTH: tools/oda_render_rig/layers.html. Geometry comes in through
## art/oda3d/oda3d_room.glb (exported by tools/oda3d/export_glb.html, see tools/oda3d/README.md).
## Camera, lights and material values are read from art/oda3d/oda3d_source_scene.json (written by
## the same page) so nothing here is retyped by hand; the only authored things are the
## Three→Godot unit conversions and the Godot-only quality additions (GI, soft shadows, SSAO/SSIL/
## SSR, micro-material).
##
## `@tool`: the LightmapGI bake runs in the editor and needs the materials, cast-shadow and GI
## flags applied there too, so `_ready()` applies them in both editor and game.

const SOURCE_JSON := "res://art/oda3d/oda3d_source_scene.json"

## Three.js uses physical light units without the π/π cancellation Godot's non-physical
## path has: Godot multiplies light energy by π and Lambert divides by π, so outgoing radiance
## for energy E is albedo·E·NdotL; Three's is albedo·(I/π)·NdotL. Hence E = I / π.
const THREE_TO_GODOT_ENERGY := 1.0 / PI

## Sealed light logic: the window wall segments do NOT cast the sun's shadow in the source (only
## the mullions cast). Godot's lightmapper ignores cast_shadow (issue #56870), so the bake needs
## these meshes excluded from bake geometry: GI_MODE_DYNAMIC (light probes instead of a lightmap,
## never occlude). Real-time: cast_shadow OFF lets the sun through.
const WALL_CHEAT_NODES: Array[String] = ["rw_below", "rw_above", "rw_back", "rw_front"]
## Source castShadow=false set: room shell + sky slab.
const NO_CAST_NODES: Array[String] = ["floor", "wall_back", "wall_left", "rw_below", "rw_above", "rw_back", "rw_front", "sky"]

## Anchor key -> GLB node; same keys as the rig's anchors.json so the gate is a subtraction.
const ANCHOR_NODES := {
	"board_outer": "cork_board", "board_inner": "cork_panel",
	"frame_outer_0": "picture_frame", "frame_outer_1": "picture_frame2", "frame_outer_2": "picture_frame3",
	"window": "window_frame", "monitor": "monitor", "lamp": "desk_lamp",
	"mug": "mug", "phone": "phone", "desk_top": "desk_top",
}

var source: Dictionary = {}
var mode: String = "day"
## Emission energy of the window sky slab (source: unlit MeshBasicMaterial through ACES). Godot's
## ACES fit is hotter than three's; tuned by measurement so the window reads cream, not clipped.
@export var sky_emission_energy: float = 0.55
## Night sky slab (0x1e2638) is dim to begin with; the day value under-lights it, so the night
## plate uses its own energy.
@export var sky_emission_energy_night: float = 1.0
## Micro-variation strength multiplier for plaster/wood/cork (1.0 = the built-in amplitudes).
@export var micro_strength: float = 1.0
## Multiplier on the hemisphere (sky/ground) ambient energy. three's HemisphereLight is
## UNOCCLUDED; Godot's baked sky is occluded by the real walls, so matching the sealed shadow
## depth needs a little more sky. Measured, not guessed.
@export var ambient_scale: float = 0.7
## Exposure = source toneMappingExposure × these. Godot's ACES fit runs brighter than three's
## ACESFilmic at the same exposure; set from the region table (sun-lit desk → 1.0 of sealed).
@export var exposure_scale_day: float = 0.90
@export var exposure_scale_night: float = 0.71
var materials: Dictionary = {}          # material name -> StandardMaterial3D
## mode -> {sky, ground, energy, res}: the source HemisphereLight per rig.
var _hemi: Dictionary = {}
var _bulb_mat: StandardMaterial3D
var _sky_mat: StandardMaterial3D

@onready var camera: Camera3D = $Camera3D
@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var lightmap_gi: LightmapGI = $LightmapGI
@onready var day_rig: Node3D = $DayRig
@onready var night_rig: Node3D = $NightRig
@onready var room: Node3D = $Room


func _ready() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SOURCE_JSON)) if FileAccess.file_exists(SOURCE_JSON) else null
	source = parsed if parsed is Dictionary else {}
	if source.is_empty():
		push_error("oda3d: source JSON missing: %s" % SOURCE_JSON)
		return
	_setup_camera()
	_build_materials()
	_apply_materials_and_flags()
	_setup_lights()
	set_mode(mode)


static func _vec(a: Array) -> Vector3:
	return Vector3(a[0], a[1], a[2])


# Camera — layers.html applyCam(): position, look-at at the derived target, vertical fov.
# Camera3D fov is vertical under KEEP_HEIGHT, same axis as three.PerspectiveCamera.fov; both look
# down -Z with +Y up, so look_at is convention-identical.
func _setup_camera() -> void:
	var cam: Dictionary = source.get("camera", {})
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	camera.fov = float(cam.get("fov_deg", 44.0))
	camera.near = float(cam.get("near", 0.05))
	camera.far = float(cam.get("far", 40.0))
	camera.look_at_from_position(_vec(cam.get("position", [0.298, 1.35, 1.56])),
		_vec(cam.get("target", [0.30463, 1.31667, 0.56058])), Vector3.UP)


# Materials — one StandardMaterial3D per glTF material name with the source's base values, plus
# subtle procedural micro-variation so lit surfaces don't read as flat vinyl. Amplitudes stay
# small on purpose: the mean albedo must stay the source's so the room keeps its tint.
func _build_materials() -> void:
	materials.clear()
	var sm: Dictionary = source.get("setMode", {})
	var src_mats: Dictionary = source.get("materials", {})
	for mname in src_mats:
		var s: Dictionary = src_mats[mname]
		var m := StandardMaterial3D.new()
		m.resource_name = mname
		m.albedo_color = Color.html(s.get("color", "#ffffff"))
		m.roughness = float(s.get("roughness", 1.0))
		m.metallic = float(s.get("metallic", 0.0))
		m.metallic_specular = 0.5
		if s.get("emissive", "#000000") != "#000000":
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
				# Unlit in the source. An unshaded material does not emit into the bake, so: black
				# albedo + emission = the sky colour. Same on screen, and it lights the lightmap.
				m.albedo_color = Color.BLACK
				m.roughness = 1.0
				m.emission_enabled = true
				m.emission = Color.html(sm.get("sky_day", "#ffedc8"))
				m.emission_energy_multiplier = sky_emission_energy
				_sky_mat = m
			"screen_glass":
				# Sealed contract: DARK GLASS in both modes (the game paints the glass); source
				# setMode() forces roughness 0.15 and zero emissive. SSR + reflection probe reflect.
				m.roughness = float(sm.get("screen_roughness", 0.15))
				m.emission_enabled = false
				m.clearcoat_enabled = true
				m.clearcoat = 0.6
				m.clearcoat_roughness = 0.05
			"warm_bulb":
				_bulb_mat = m
		materials[mname] = m


## A NoiseTexture2D drives albedo (multiplicative ramp [1 - amp, 1]), roughness (± rough_amp) and
## a faint normal map (bump depth `bump` × 2, strength `normal_strength`), all sampled world-space
## triplanar so the glTF's box UVs never show a seam.
func _add_micro(m: StandardMaterial3D, albedo_amp: float, rough_amp: float, uv_scale: Vector3, bump: float, normal_strength: float) -> void:
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.02
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.55
	noise.seed = int(hash(m.resource_name)) % 100000
	m.albedo_texture = _noise_tex(noise, 1.0 - albedo_amp)
	# The roughness texture MULTIPLIES the roughness value, so the ramp sits around 1.0.
	m.roughness_texture = _noise_tex(noise, clampf(1.0 - rough_amp / maxf(m.roughness, 0.05), 0.0, 1.0))
	m.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	var nrm := _noise_tex(noise, -1.0)
	nrm.as_normal_map = true
	nrm.bump_strength = 2.0 * bump
	m.normal_enabled = true
	m.normal_texture = nrm
	m.normal_scale = normal_strength
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = uv_scale
	m.uv1_triplanar_sharpness = 4.0


## 512² seamless noise; `ramp_lo` >= 0 maps it to a gray ramp [ramp_lo, 1].
static func _noise_tex(noise: FastNoiseLite, ramp_lo: float) -> NoiseTexture2D:
	var t := NoiseTexture2D.new()
	t.width = 512
	t.height = 512
	t.seamless = true
	t.noise = noise
	if ramp_lo >= 0.0:
		var ramp := Gradient.new()
		ramp.set_color(0, Color(ramp_lo, ramp_lo, ramp_lo))
		ramp.set_color(1, Color.WHITE)
		t.color_ramp = ramp
	return t


func _apply_materials_and_flags() -> void:
	for mi: MeshInstance3D in room.find_children("*", "MeshInstance3D", true, false):
		var mesh: Mesh = mi.mesh
		if mesh == null:
			continue
		for s in mesh.get_surface_count():
			var src_mat: Material = mesh.surface_get_material(s)
			if src_mat and materials.has(src_mat.resource_name):
				mi.set_surface_override_material(s, materials[src_mat.resource_name])
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if NO_CAST_NODES.has(mi.name) else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		mi.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC if WALL_CHEAT_NODES.has(mi.name) else GeometryInstance3D.GI_MODE_STATIC


# Lights — positions/colours/targets from the source rigs, energies converted (I/π), ranges and
# decays carried over. Godot adds shadow softness and bake_mode DYNAMIC (indirect baked, direct
# real-time with shadows).
func _setup_lights() -> void:
	# Rebuilt from the JSON on every load; free() (not queue_free) so a re-run cannot collide on
	# node names.
	for which in ["day", "night"]:
		var rig := _rig(which)
		for c in rig.get_children():
			c.free()
		for l in source["lights"][which]:
			_spawn_light(rig, l, which)


func _rig(which: String) -> Node3D:
	return day_rig if which == "day" else night_rig


func _spawn_light(parent: Node3D, l: Dictionary, which: String) -> void:
	var col := Color.html(l.get("color", "#ffffff"))
	var inten := float(l.get("intensity", 1.0))
	var casts := bool(l.get("castShadow", false))
	var light: Light3D
	match l.get("type", ""):
		"HemisphereLight":
			# Sky/ground ambient → Environment ambient + the LightmapGI bake environment (set_mode).
			_hemi[which] = {"sky": col, "ground": Color.html(l.get("groundColor", "#000000")),
				"energy": inten * THREE_TO_GODOT_ENERGY * ambient_scale, "res": null}
			return
		"DirectionalLight":
			var d := DirectionalLight3D.new()
			d.name = "Sun" if casts else "Fill"
			d.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
			d.directional_shadow_max_distance = 12.0
			d.directional_shadow_blend_splits = false
			d.light_angular_distance = 0.5      # real sun ≈ 0.53° → PCSS penumbra instead of PCF
			d.shadow_normal_bias = 1.0
			d.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY   # no sun disc in the hemisphere sky
			d.light_volumetric_fog_energy = 1.0 if casts else 0.0
			light = d
		"PointLight":
			var o := OmniLight3D.new()
			o.name = "Ceiling" if inten > 1.0 else "MouthGlow"
			o.omni_range = float(l.get("distance", 5.0))
			o.omni_attenuation = float(l.get("decay", 2.0))
			o.omni_shadow_mode = OmniLight3D.SHADOW_CUBE   # dual-paraboloid stair-steps on the board edge
			o.light_size = 0.06 if casts else 0.0
			o.shadow_normal_bias = 1.5
			o.shadow_blur = 2.0   # kills the residual 1-px serration on the board's shadow edge at 8K
			light = o
		"SpotLight":
			var s := SpotLight3D.new()
			s.name = "LampSpot"
			s.spot_range = float(l.get("distance", 2.0))
			s.spot_attenuation = float(l.get("decay", 2.0))
			s.spot_angle = rad_to_deg(float(l.get("angle", 0.5)))
			# Three penumbra p: full intensity inside angle·(1-p), smoothstep to 0 at angle.
			# Godot's spot_angle_attenuation is a power on the rim; ~1 gives a comparable soft rim.
			s.spot_angle_attenuation = 1.0
			s.light_size = 0.02
			s.shadow_bias = 0.03
			s.shadow_normal_bias = 1.0
			light = s
		_:
			return
	light.light_color = col
	light.light_energy = inten * THREE_TO_GODOT_ENERGY
	light.shadow_enabled = casts
	light.light_bake_mode = Light3D.BAKE_DYNAMIC
	if not (light is SpotLight3D):
		light.shadow_bias = 0.02
	var p := _vec(l["position"])
	if light is OmniLight3D:
		light.position = p
	else:
		light.look_at_from_position(p, _vec(l.get("target", [0, 0, 0])), Vector3.UP)
	parent.add_child(light)
	# LightmapGI skips every unowned child ("maybe a helper"): unowned lights bake an atlas with
	# only the window slab's emission. In the editor they are owned by the scene root.
	if Engine.is_editor_hint():
		light.owner = owner if owner else self


# Mode switch — mirrors layers.html setMode(): rig visibility, sky colour, exposure, bulb
# emissive; screens stay dark glass. Also swaps the baked lightmap for the mode.
func set_mode(m: String) -> void:
	mode = "night" if m == "night" else "day"
	var day := mode == "day"
	var sm: Dictionary = source.get("setMode", {})
	day_rig.visible = day
	night_rig.visible = not day
	if _sky_mat:
		_sky_mat.emission = Color.html(sm.get("sky_day" if day else "sky_night", "#ffedc8"))
		_sky_mat.emission_energy_multiplier = sky_emission_energy if day else sky_emission_energy_night
	if _bulb_mat:
		_bulb_mat.emission = Color.html(sm.get("bulb_emissive_day" if day else "bulb_emissive_night", "#ffdda0"))
		_bulb_mat.emission_energy_multiplier = float(sm.get("bulb_emissiveIntensity_day" if day else "bulb_emissiveIntensity_night", 0.15))
	var env := world_env.environment
	env.tonemap_exposure = float(source.get("renderer", {}).get("toneMappingExposure_day" if day else "toneMappingExposure_night", 1.0)) * (exposure_scale_day if day else exposure_scale_night)
	var h: Dictionary = _hemi.get(mode, {})
	if h.is_empty():
		return
	# Real-time ambient (only matters for non-lightmapped surfaces: the GI_MODE_DYNAMIC
	# wall-cheat segments before probes kick in) from the same two-tone sky.
	env.sky = _hemisphere_sky(h)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_sky_contribution = 1.0
	env.ambient_light_energy = 1.0
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	env.background_mode = Environment.BG_COLOR
	env.background_color = h["sky"]
	env.background_energy_multiplier = h["energy"]
	# Bake environment = uniform sky colour × I/π. The ground term is NOT emulated: in the bake the
	# floor's real bounce plays that role. A two-tone custom Sky cannot be the bake environment:
	# sky_bake_panorama() needs its radiance cubemap rendered by a viewport first, which the bake
	# driver cannot guarantee (an all-zero bake resulted).
	lightmap_gi.environment_mode = LightmapGI.ENVIRONMENT_MODE_CUSTOM_COLOR
	lightmap_gi.environment_custom_color = h["sky"]
	lightmap_gi.environment_custom_energy = h["energy"]
	lightmap_gi.environment_custom_sky = null
	var lm_path := "res://scenes/oda3d/oda3d_%s.lmbake" % mode
	if ResourceLoader.exists(lm_path):
		var data: LightmapGIData = load(lm_path)
		if data and data.get_lightmap_textures().size() > 0:
			lightmap_gi.light_data = data


## three.js HemisphereLight(sky, ground, I) as a Godot Sky: irradiance on a surface of normal n is
## mix(ground, sky, 0.5·n.y+0.5)·I/π in three; a two-tone sky with the same colours and energy I/π
## integrates to the same value. Sun discs are off via the directional lights' SKY_MODE_LIGHT_ONLY.
func _hemisphere_sky(h: Dictionary) -> Sky:
	if h["res"]:
		return h["res"]
	var mat := ProceduralSkyMaterial.new()
	mat.sky_top_color = h["sky"]
	mat.sky_horizon_color = h["sky"]
	mat.sky_curve = 1.0
	mat.sky_energy_multiplier = h["energy"]
	mat.ground_bottom_color = h["ground"]
	mat.ground_horizon_color = h["ground"]
	mat.ground_curve = 1.0
	mat.ground_energy_multiplier = h["energy"]
	mat.sun_angle_max = 0.0
	mat.sun_curve = 0.0
	mat.use_debanding = false
	var sky := Sky.new()
	sky.sky_material = mat
	sky.radiance_size = Sky.RADIANCE_SIZE_64
	sky.process_mode = Sky.PROCESS_MODE_QUALITY
	h["res"] = sky
	return sky


# Composition proof — port of layers.html projectObject()/anchorsNorm(): the 8 corners of every
# mesh's local AABB → world → camera.unproject_position → normalized to the viewport.
func project_anchors() -> Dictionary:
	var vp_size: Vector2 = camera.get_viewport().get_visible_rect().size
	var out := {}
	for key in ANCHOR_NODES:
		out[key] = _proj_norm(find_prop(ANCHOR_NODES[key]), vp_size)
	var frames: Array = [out["frame_outer_0"], out["frame_outer_1"], out["frame_outer_2"]]
	if frames.all(func(f: Array) -> bool: return f.size() == 4):
		var x0: float = frames.map(func(f: Array) -> float: return f[0]).min()
		var y0: float = frames.map(func(f: Array) -> float: return f[1]).min()
		var x1: float = frames.map(func(f: Array) -> float: return f[0] + f[2]).max()
		var y1: float = frames.map(func(f: Array) -> float: return f[1] + f[3]).max()
		out["frames_band"] = [x0, y0, x1 - x0, y1 - y0]
	return out


## GLB node by name anywhere under Room.
func find_prop(n: String) -> Node:
	return room.find_child(n, true, false)


func _proj_norm(n: Node, vp_size: Vector2) -> Array:
	if n == null:
		return []
	var meshes: Array[Node] = n.find_children("*", "MeshInstance3D", true, false)
	if n is MeshInstance3D:
		meshes.append(n)
	var r := Rect2()
	var found := false
	for mi: MeshInstance3D in meshes:
		if mi.mesh == null:
			continue
		var aabb: AABB = mi.mesh.get_aabb()
		for i in 8:
			var sp: Vector2 = camera.unproject_position(mi.global_transform * aabb.get_endpoint(i))
			r = r.expand(sp) if found else Rect2(sp, Vector2.ZERO)
			found = true
	if not found:
		return []
	return [r.position.x / vp_size.x, r.position.y / vp_size.y, r.size.x / vp_size.x, r.size.y / vp_size.y]


## Everything the plate record (oda3d_camera_light.json) needs about this scene.
func describe() -> Dictionary:
	var lights := []
	for which in ["day", "night"]:
		var rig := _rig(which)
		for l in rig.get_children():
			if not (l is Light3D):
				continue
			var d := {
				"rig": rig.name, "name": l.name, "type": l.get_class(),
				"transform": _xf(l.global_transform), "color": l.light_color.to_html(false),
				"energy": l.light_energy, "shadow": l.shadow_enabled, "bake_mode": l.light_bake_mode,
				"shadow_bias": l.shadow_bias, "shadow_normal_bias": l.shadow_normal_bias,
			}
			if l is OmniLight3D:
				d.merge({"range": l.omni_range, "attenuation": l.omni_attenuation, "light_size": l.light_size})
			elif l is SpotLight3D:
				d.merge({"range": l.spot_range, "attenuation": l.spot_attenuation, "angle_deg": l.spot_angle, "angle_attenuation": l.spot_angle_attenuation, "light_size": l.light_size})
			elif l is DirectionalLight3D:
				d.merge({"angular_distance_deg": l.light_angular_distance, "shadow_mode": l.directional_shadow_mode, "shadow_max_distance": l.directional_shadow_max_distance})
			lights.append(d)
		if _hemi.has(which):
			lights.append({"rig": rig.name, "name": "HemisphereAmbient", "type": "Environment.ambient", "color": (_hemi[which]["sky"] as Color).to_html(false), "energy": _hemi[which]["energy"]})
	var env := world_env.environment
	var envd := {
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
	var ld := lightmap_gi.light_data
	var lm := {"quality": lightmap_gi.quality, "bounces": lightmap_gi.bounces, "directional": lightmap_gi.directional, "denoiser": lightmap_gi.use_denoiser,
		"supersampling": lightmap_gi.supersampling, "supersampling_factor": lightmap_gi.supersampling_factor, "max_texture_size": lightmap_gi.max_texture_size, "texel_scale": lightmap_gi.texel_scale,
		"environment_mode": lightmap_gi.environment_mode, "env_energy": lightmap_gi.environment_custom_energy,
		"has_light_data": ld != null and ld.get_lightmap_textures().size() > 0,
		"light_data_path": ld.resource_path if ld else ""}
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
