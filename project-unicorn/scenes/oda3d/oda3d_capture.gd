extends Node
## ODA 3D — offline plate capture. Renders scenes/oda3d/oda3d.tscn inside a SubViewport of
## arbitrary size, waits for temporal effects to converge, and saves PNGs.
##
## A SubViewport's size is independent of the OS window (a 7680×4320 target renders fine behind a
## 960×540 window). Movie Maker (`--write-movie`) captures the WINDOW, which the OS clamps to the
## screen, so it cannot produce the plates.
##
## Run (windowed — a real GPU is required, never --headless):
##   godot --path <project> --windowed --resolution 960x540 \
##     res://scenes/oda3d/oda3d_capture.tscn -- --oda3d-mode=day --oda3d-size=7680x4320 \
##     --oda3d-scale=1.5 --oda3d-msaa=4 --oda3d-warmup=60 --oda3d-downscale=1
## Flags (all `--oda3d-<key>=<value>`, read from `args`):
##   mode=day|night  size=WxH  scale  msaa=0|2|4|8  taa=0|1  warmup=<frames>  downscale=1
##   out=res://path.png  preview=0|1  tonemap=aces|agx  gi=lightmap|sdfgi|none  exposure=<f>
##   sky=<f>  micro=<f>  lights=0|1  anchors-only=1 (print projected anchors and quit)
##   env=key:value,key:value (raw Environment property overrides)
##   layer=full|room|monitor|keyboard|lamp|mug|phone (see _apply_layer)

## ODA layer name -> GLB node. A prop is several meshes (the keyboard is 60+ keys), so the whole
## subtree is the target.
const LAYER_PROPS := {
	"monitor": "monitor",
	"keyboard": "keyboard",
	"lamp": "desk_lamp",
	"mug": "mug",
	"phone": "phone",
}

const CAMERA_LIGHT_JSON := "res://art/oda3d/oda3d_camera_light.json"
const BAKE_LOG_JSON := "res://art/oda3d/oda3d_bake_log.json"
const SHADOW_ATLAS := 16384

var args: Dictionary = {}
var mode: String = "day"

@onready var view: SubViewport = $View
@onready var oda: Node3D = $View/Oda3D
@onready var preview: TextureRect = $Preview


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--oda3d-"):
			var kv := a.substr(8).split("=", true, 1)
			args[kv[0]] = kv[1] if kv.size() == 2 else "1"
	mode = str(args.get("mode", "day"))
	# The default window mode is borderless fullscreen and swallows size assignments.
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_window().size = Vector2i(960, 540)
	get_window().title = "ODA 3D capture — %s" % mode

	# Render-quality settings that normally live in project settings; all have runtime seams.
	RenderingServer.directional_shadow_atlas_set_size(SHADOW_ATLAS, false)
	RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
	RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
	RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_ULTRA, false, 0.5, 2, 50.0, 300.0)
	RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_ULTRA, false, 0.5, 4, 50.0, 300.0)
	RenderingServer.environment_set_ssr_half_size(false)   # full-resolution SSR (project default is half)
	RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_128)
	RenderingServer.environment_set_sdfgi_frames_to_converge(RenderingServer.ENV_SDFGI_CONVERGE_IN_30_FRAMES)
	RenderingServer.environment_set_sdfgi_frames_to_update_light(RenderingServer.ENV_SDFGI_UPDATE_LIGHT_IN_1_FRAME)
	RenderingServer.environment_glow_set_use_bicubic_upscale(true)
	RenderingServer.screen_space_roughness_limiter_set_active(true, 0.25, 0.18)

	var wh := str(args.get("size", "1920x1080")).split("x")
	var vsize := Vector2i(int(wh[0]), int(wh[1])) if wh.size() == 2 else Vector2i(1920, 1080)
	view.size = vsize
	view.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	view.scaling_3d_scale = clampf(float(args.get("scale", 1.0)), 0.25, 2.0)
	var msaa := int(args.get("msaa", 4))
	view.msaa_3d = {0: Viewport.MSAA_DISABLED, 2: Viewport.MSAA_2X, 4: Viewport.MSAA_4X, 8: Viewport.MSAA_8X}.get(msaa, Viewport.MSAA_4X)
	view.use_taa = int(args.get("taa", 1)) == 1
	view.use_debanding = true
	# Positional shadows: the night ceiling omni casts the board's shadow onto the wall and in the
	# default atlas layout its cube faces stair-stepped at 8K. Measured dead ends: 32-bit at this
	# size → every positional shadow vanished; SUBDIV_1 → a CUBE omni needs TWO slots in one
	# quadrant, so it got none. Working layout: 16-bit, SUBDIV_4 everywhere (4096² slots).
	view.positional_shadow_atlas_size = SHADOW_ATLAS
	view.positional_shadow_atlas_16_bits = true
	for q in 4:
		view.set_positional_shadow_atlas_quadrant_subdiv(q, Viewport.SHADOW_ATLAS_QUADRANT_SUBDIV_4)
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	if int(args.get("preview", 1)) == 1:
		preview.texture = view.get_texture()

	if args.has("sky"):
		oda.sky_emission_energy = float(args["sky"])
	if args.has("micro"):
		oda.micro_strength = float(args["micro"])
		oda._build_materials()
		oda._apply_materials_and_flags()
	oda.set_mode(mode)
	var env: Environment = oda.world_env.environment
	var tm := str(args.get("tonemap", "aces"))
	env.tonemap_mode = Environment.TONE_MAPPER_AGX if tm == "agx" else Environment.TONE_MAPPER_ACES
	if args.has("exposure"):
		env.tonemap_exposure = float(args["exposure"])
	var gi := str(args.get("gi", "lightmap"))
	env.sdfgi_enabled = gi == "sdfgi"
	oda.lightmap_gi.visible = not (gi in ["sdfgi", "none"])
	if gi == "sdfgi":
		env.sdfgi_cascades = 4
		env.sdfgi_min_cell_size = 0.05
		env.sdfgi_use_occlusion = true
		env.sdfgi_bounce_feedback = 0.5
		env.sdfgi_read_sky_light = true
	if int(args.get("lights", 1)) == 0:
		oda.day_rig.visible = false
		oda.night_rig.visible = false
	if args.has("env"):
		for kv in str(args["env"]).split(","):
			var p := kv.split(":")
			if p.size() != 2 or not (p[0] in env):
				continue
			match typeof(env.get(p[0])):
				TYPE_BOOL: env.set(p[0], p[1] == "1" or p[1] == "true")
				TYPE_INT: env.set(p[0], int(p[1]))
				TYPE_FLOAT: env.set(p[0], float(p[1]))
				TYPE_COLOR: env.set(p[0], Color.html(p[1]))
				_: env.set(p[0], p[1])
			print("[Oda3D] env override %s = %s" % [p[0], str(env.get(p[0]))])

	var layer := str(args.get("layer", ""))
	if layer != "":
		_apply_layer(layer, env)
	var warmup := int(args.get("warmup", 60))
	var ld: LightmapGIData = oda.lightmap_gi.light_data
	print("[Oda3D] mode=%s size=%s scale=%.2f msaa=%d taa=%s tonemap=%s gi=%s warmup=%d lightmap=%s" % [mode, str(vsize), view.scaling_3d_scale, msaa, str(view.use_taa), tm, gi, warmup,
		"yes" if ld != null and ld.get_lightmap_textures().size() > 0 else "NONE"])
	_capture.call_deferred(warmup, vsize, gi, tm, layer)


func _capture(warmup: int, vsize: Vector2i, gi: String, tm: String, layer: String) -> void:
	for i in maxi(warmup, 2):
		await RenderingServer.frame_post_draw
	var anchors: Dictionary = oda.project_anchors()
	print("ODA3D_ANCHORS " + JSON.stringify(anchors))
	if int(args.get("anchors-only", 0)) == 1:
		get_tree().quit(0)
		return

	var img: Image = view.get_texture().get_image()
	if img == null or img.is_empty():
		push_error("[Oda3D] empty capture")
		get_tree().quit(2)
		return
	# Prop layers are RGBA (ODA's rim shader reads the sprite's alpha); the room layer is RGB.
	if LAYER_PROPS.has(layer):
		img.convert(Image.FORMAT_RGBA8)
	elif layer == "room":
		img.convert(Image.FORMAT_RGB8)
	var label := "8k" if vsize.y >= 4320 else ("4k" if vsize.y >= 2160 else ("1080p" if vsize.y >= 1080 else "%dp" % vsize.y))
	var out := str(args.get("out", "res://art/oda3d/plates/oda_%s_%s.png" % [mode, label]))
	var err := img.save_png(out)
	print("[Oda3D] saved %s (%dx%d) err=%d" % [ProjectSettings.globalize_path(out), img.get_width(), img.get_height(), err])
	if int(args.get("downscale", 0)) == 1 and vsize.y >= 4320:
		for pair in [[3840, 2160, "4k"], [1920, 1080, "1080p"]]:
			var d: Image = img.duplicate()
			d.resize(pair[0], pair[1], Image.INTERPOLATE_LANCZOS)
			d.save_png(out.replace("_%s.png" % label, "_%s.png" % pair[2]))
	# The camera/light record documents plates, not layer passes.
	if layer == "":
		_write_json(anchors, vsize, gi, tm, out)
	print("ODA3D_OK")
	get_tree().quit(0)


static func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


func _write_json(anchors: Dictionary, vsize: Vector2i, gi: String, tm: String, out: String) -> void:
	var all := _read_json(CAMERA_LIGHT_JSON)
	var vi := Engine.get_version_info()
	var entry: Dictionary = oda.describe()
	entry["engine_version"] = "%d.%d.%d.%s.%s" % [vi.major, vi.minor, vi.patch, vi.status, vi.build]
	entry["renderer"] = {"method": RenderingServer.get_current_rendering_method(), "driver": RenderingServer.get_current_rendering_driver_name(), "gpu": RenderingServer.get_video_adapter_name(), "physical_light_units": ProjectSettings.get_setting("rendering/lights_and_shadows/use_physical_light_units", false)}
	match gi:
		"sdfgi": entry["gi_method"] = "SDFGI (real-time, 30-frame convergence)"
		"lightmap" when entry["lightmap_gi"]["has_light_data"]: entry["gi_method"] = "LightmapGI (baked; direct light real-time, indirect baked)"
		_: entry["gi_method"] = "none (direct + ambient + SSAO/SSIL only)"
	entry["tonemap_requested"] = tm
	entry["viewport"] = {"size": [vsize.x, vsize.y], "scaling_3d_scale": view.scaling_3d_scale, "internal_size": [int(vsize.x * view.scaling_3d_scale), int(vsize.y * view.scaling_3d_scale)], "msaa_3d": view.msaa_3d, "taa": view.use_taa, "debanding": view.use_debanding, "positional_shadow_atlas": view.positional_shadow_atlas_size, "positional_shadow_quadrants": "subdiv 4 (2x2 slots per quadrant), 16-bit", "directional_shadow_atlas": SHADOW_ATLAS, "warmup_frames": int(args.get("warmup", 60))}
	entry["anchors_norm"] = anchors
	entry["output"] = out
	entry["captured_at"] = Time.get_datetime_string_from_system()
	entry["bake"] = _read_json(BAKE_LOG_JSON).get(mode, {})
	all[mode] = entry
	all["_about"] = "ODA 3D — camera/light/environment record per plate. Source of truth for geometry/camera: art/oda3d/oda3d_source_scene.json (exported from tools/oda_render_rig/layers.html)."
	var f := FileAccess.open(CAMERA_LIGHT_JSON, FileAccess.WRITE)
	if f == null:
		push_error("[Oda3D] cannot write %s" % CAMERA_LIGHT_JSON)
		return
	f.store_string(JSON.stringify(all, "  "))


## ODA layer passes:
##   full   : nothing hidden, opaque — reference frame the stacked layers are compared against.
##   room   : the props leave the colour pass but stay in the shadow map (SHADOWS_ONLY). The sun is
##            a REAL-TIME DirectionalLight (the lightmap bakes only indirect light), so hiding a
##            prop would take its contact shadow with it; SHADOWS_ONLY keeps the shadow on the
##            background and it is not drawn twice once the layer goes back on top. Opaque.
##   <prop> : only that subtree visible, TRANSPARENT viewport. ODA's rim shader reads the
##            sprite's alpha (oda_rim_glow.gdshader), so an opaque plate would kill the hover glow.
## Visibility is written only to MeshInstance3Ds: visibility is hierarchical, and hiding an
## intermediate Node3D would take sibling subtrees with it.
func _apply_layer(layer: String, env: Environment) -> void:
	var meshes: Array[Node] = oda.room.find_children("*", "MeshInstance3D", true, false)
	if meshes.is_empty():
		_abort("layer: no MeshInstance3D under Room")
		return
	if layer == "full":
		return
	if layer == "room":
		var props: Array[Node] = []
		for k in LAYER_PROPS:
			var n: Node = oda.find_prop(LAYER_PROPS[k])
			if n == null:
				_abort("layer: node not found: %s" % LAYER_PROPS[k])
				return
			props.append(n)
		var shadowed := 0
		for mi: MeshInstance3D in meshes:
			if props.any(func(r: Node) -> bool: return r == mi or r.is_ancestor_of(mi)):
				mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
				shadowed += 1
		print("[Oda3D] layer=room props -> SHADOWS_ONLY (%d/%d meshes)" % [shadowed, meshes.size()])
		return
	if not LAYER_PROPS.has(layer):
		_abort("unknown layer: %s (full|room|%s)" % [layer, "|".join(LAYER_PROPS.keys())])
		return
	var target: Node = oda.find_prop(LAYER_PROPS[layer])
	if target == null:
		_abort("layer: node not found: %s" % LAYER_PROPS[layer])
		return
	var shown := 0
	for mi: MeshInstance3D in meshes:
		mi.visible = mi == target or target.is_ancestor_of(mi)
		if mi.visible:
			shown += 1
	if shown == 0:
		_abort("layer %s isolated 0 meshes" % layer)
		return
	# Transparent background needs all three: viewport, Environment, default clear colour. Ambient
	# stays: ambient_light_source is SKY and independent of background_mode.
	view.transparent_bg = true
	env.background_mode = Environment.BG_CLEAR_COLOR
	RenderingServer.set_default_clear_color(Color(0.0, 0.0, 0.0, 0.0))
	# TAA resolves into its history buffer opaque, so with TAA on the transparent frame came back
	# fully opaque. MSAA + supersampling (--oda3d-scale) cover the spatial AA; forced off here.
	view.use_taa = false
	print("[Oda3D] layer=%s isolated (%d/%d meshes), transparent bg, TAA off" % [layer, shown, meshes.size()])


func _abort(msg: String) -> void:
	push_error("[Oda3D] " + msg)
	get_tree().quit(3)
