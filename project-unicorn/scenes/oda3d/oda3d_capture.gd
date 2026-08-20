extends Node
## ODA 3D spike — offline plate capture. Renders scenes/oda3d/oda3d.tscn inside a SubViewport of
## arbitrary size (8K for the plates), waits for temporal effects to converge, and saves PNGs.
##
## Godot concept: a SubViewport is an off-screen render target with its own World3D; its size is
## independent of the OS window (a 7680×4320 target renders fine behind a 960×540 window), and
## `get_texture().get_image()` after `RenderingServer.frame_post_draw` returns the finished frame.
## Alternative considered: Movie Maker (`--write-movie`) — it captures the WINDOW at window size,
## which the OS clamps to the screen; the SubViewport route has no such limit.
##
## Run (windowed — a real GPU is required, never --headless):
##   Godot_v4.6.2-stable_win64_console.exe --path <project> --windowed --resolution 960x540 \
##     res://scenes/oda3d/oda3d_capture.tscn -- --oda3d-mode=day --oda3d-size=7680x4320 \
##     --oda3d-scale=1.5 --oda3d-msaa=4 --oda3d-warmup=60 --oda3d-downscale=1
## Optional: --oda3d-tonemap=aces|agx  --oda3d-gi=lightmap|sdfgi|none  --oda3d-out=res://path.png
##           --oda3d-env=key:value,key:value   (raw Environment property overrides for the fast loop)
##           --oda3d-exposure=1.05  --oda3d-anchors-only=1 (no PNG; print projected anchors and quit)
##           --oda3d-preview=1 (also copy the frame into the window)

const CAMERA_LIGHT_JSON := "res://art/oda3d/oda3d_camera_light.json"
const BAKE_LOG_JSON := "res://art/oda3d/oda3d_bake_log.json"

var args: Dictionary = {}
var mode: String = "day"

@onready var view: SubViewport = $View
@onready var oda: Node3D = $View/Oda3D
@onready var preview: TextureRect = $Preview


func _ready() -> void:
	args = _parse_args()
	mode = str(args.get("mode", "day"))
	# Same window discipline as main.gd's _shot_window(): the default window mode is borderless
	# fullscreen and swallows size assignments, so force WINDOWED first.
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_window().size = Vector2i(960, 540)
	get_window().title = "ODA 3D capture — %s" % mode

	# ---- render-quality settings that live in project settings normally; all have runtime seams ----
	RenderingServer.directional_shadow_atlas_set_size(16384, false)
	RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
	RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
	RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_ULTRA, false, 0.5, 2, 50.0, 300.0)
	RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_ULTRA, false, 0.5, 4, 50.0, 300.0)
	RenderingServer.environment_set_ssr_half_size(false)   # 4.6: full-resolution SSR (project default is half)
	RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_128)
	RenderingServer.environment_set_sdfgi_frames_to_converge(RenderingServer.ENV_SDFGI_CONVERGE_IN_30_FRAMES)
	RenderingServer.environment_set_sdfgi_frames_to_update_light(RenderingServer.ENV_SDFGI_UPDATE_LIGHT_IN_1_FRAME)
	RenderingServer.environment_glow_set_use_bicubic_upscale(true)
	RenderingServer.screen_space_roughness_limiter_set_active(true, 0.25, 0.18)

	# ---- viewport ----
	var size_str := str(args.get("size", "1920x1080"))
	var wh := size_str.split("x")
	var vsize := Vector2i(int(wh[0]), int(wh[1])) if wh.size() == 2 else Vector2i(1920, 1080)
	view.size = vsize
	view.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	view.scaling_3d_scale = clampf(float(args.get("scale", 1.0)), 0.25, 2.0)
	var msaa := int(args.get("msaa", 4))
	view.msaa_3d = {0: Viewport.MSAA_DISABLED, 2: Viewport.MSAA_2X, 4: Viewport.MSAA_4X, 8: Viewport.MSAA_8X}.get(msaa, Viewport.MSAA_4X)
	view.use_taa = int(args.get("taa", 1)) == 1
	view.use_debanding = true
	# Positional shadows: the night ceiling omni casts the board's shadow onto the wall; in the
	# default atlas layout its cube faces were too small and the edge stair-stepped at 8K.
	# Measured dead ends: 16384 × 32-bit (1 GB) → every positional shadow vanished; SUBDIV_1 per
	# quadrant → a CUBE omni needs TWO slots in one quadrant, so it got none. Working layout:
	# 16384 × 16-bit, subdiv 2 everywhere (4096² slots, ~2× the default face resolution).
	view.positional_shadow_atlas_size = 16384
	view.positional_shadow_atlas_16_bits = true
	view.positional_shadow_atlas_quad_0 = Viewport.SHADOW_ATLAS_QUADRANT_SUBDIV_4
	view.positional_shadow_atlas_quad_1 = Viewport.SHADOW_ATLAS_QUADRANT_SUBDIV_4
	view.positional_shadow_atlas_quad_2 = Viewport.SHADOW_ATLAS_QUADRANT_SUBDIV_4
	view.positional_shadow_atlas_quad_3 = Viewport.SHADOW_ATLAS_QUADRANT_SUBDIV_4
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	if int(args.get("preview", 1)) == 1:
		preview.texture = view.get_texture()

	# ---- scene ----
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
	if gi == "sdfgi":
		env.sdfgi_enabled = true
		env.sdfgi_cascades = 4
		env.sdfgi_min_cell_size = 0.05
		env.sdfgi_use_occlusion = true
		env.sdfgi_bounce_feedback = 0.5
		env.sdfgi_read_sky_light = true
		oda.lightmap_gi.visible = false
	elif gi == "none":
		env.sdfgi_enabled = false
		oda.lightmap_gi.visible = false
	else:
		env.sdfgi_enabled = false
		oda.lightmap_gi.visible = true
	if int(args.get("lights", 1)) == 0:
		oda.day_rig.visible = false
		oda.night_rig.visible = false
		print("[Oda3D] rigs hidden (lightmap/emissive only)")
	if args.has("env"):
		for kv in str(args["env"]).split(","):
			var p := kv.split(":")
			if p.size() == 2 and _has_prop(env, p[0]):
				var cur: Variant = env.get(p[0])
				match typeof(cur):
					TYPE_BOOL: env.set(p[0], p[1] == "1" or p[1] == "true")
					TYPE_INT: env.set(p[0], int(p[1]))
					TYPE_FLOAT: env.set(p[0], float(p[1]))
					TYPE_COLOR: env.set(p[0], Color.html(p[1]))
					_: env.set(p[0], p[1])
				print("[Oda3D] env override %s = %s" % [p[0], str(env.get(p[0]))])

	var warmup := int(args.get("warmup", 60))
	print("[Oda3D] mode=%s size=%s scale=%.2f msaa=%d taa=%s tonemap=%s gi=%s warmup=%d" % [mode, str(vsize), view.scaling_3d_scale, msaa, str(view.use_taa), tm, gi, warmup])
	print("[Oda3D] lightmap data: %s" % ("yes" if (oda.lightmap_gi.light_data != null and oda.lightmap_gi.light_data.get_lightmap_textures().size() > 0) else "NONE"))
	call_deferred("_capture", warmup, vsize, gi, tm)


func _capture(warmup: int, vsize: Vector2i, gi: String, tm: String) -> void:
	for i in range(maxi(warmup, 2)):
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
	var label := "8k" if vsize.y >= 4320 else ("4k" if vsize.y >= 2160 else ("1080p" if vsize.y >= 1080 else "%dp" % vsize.y))
	var out := str(args.get("out", "res://art/oda3d/plates/oda_%s_%s.png" % [mode, label]))
	var t0 := Time.get_ticks_msec()
	var err := img.save_png(out)
	print("[Oda3D] saved %s (%dx%d) err=%d in %d ms" % [ProjectSettings.globalize_path(out), img.get_width(), img.get_height(), err, Time.get_ticks_msec() - t0])
	if int(args.get("downscale", 0)) == 1 and vsize.y >= 4320:
		for pair in [[3840, 2160, "4k"], [1920, 1080, "1080p"]]:
			var d: Image = img.duplicate()
			d.resize(pair[0], pair[1], Image.INTERPOLATE_LANCZOS)
			var p := out.replace("_%s.png" % label, "_%s.png" % pair[2])
			d.save_png(p)
			print("[Oda3D] saved %s" % ProjectSettings.globalize_path(p))
	_write_json(anchors, vsize, gi, tm, out)
	print("ODA3D_OK")
	get_tree().quit(0)


func _write_json(anchors: Dictionary, vsize: Vector2i, gi: String, tm: String, out: String) -> void:
	var all := {}
	if FileAccess.file_exists(CAMERA_LIGHT_JSON):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CAMERA_LIGHT_JSON))
		if parsed is Dictionary:
			all = parsed
	var bake := {}
	if FileAccess.file_exists(BAKE_LOG_JSON):
		var parsed2: Variant = JSON.parse_string(FileAccess.get_file_as_string(BAKE_LOG_JSON))
		if parsed2 is Dictionary:
			bake = parsed2
	var vi := Engine.get_version_info()
	var entry: Dictionary = oda.describe()
	entry["engine_version"] = "%d.%d.%d.%s.%s" % [vi.major, vi.minor, vi.patch, vi.status, vi.build]
	entry["renderer"] = {"method": RenderingServer.get_current_rendering_method(), "driver": RenderingServer.get_current_rendering_driver_name(), "gpu": RenderingServer.get_video_adapter_name(), "physical_light_units": ProjectSettings.get_setting("rendering/lights_and_shadows/use_physical_light_units", false)}
	entry["gi_method"] = "LightmapGI (baked; direct light real-time, indirect baked)" if (gi == "lightmap" and entry.get("lightmap_gi", {}).get("has_light_data", false)) else ("SDFGI (real-time, %d-frame convergence)" % 30 if gi == "sdfgi" else "none (direct + ambient + SSAO/SSIL only)")
	entry["tonemap_requested"] = tm
	entry["viewport"] = {"size": [vsize.x, vsize.y], "scaling_3d_scale": view.scaling_3d_scale, "internal_size": [int(vsize.x * view.scaling_3d_scale), int(vsize.y * view.scaling_3d_scale)], "msaa_3d": view.msaa_3d, "taa": view.use_taa, "debanding": view.use_debanding, "positional_shadow_atlas": view.positional_shadow_atlas_size, "positional_shadow_quadrants": "subdiv 4 (2x2 slots per quadrant), 16-bit", "directional_shadow_atlas": 16384, "warmup_frames": int(args.get("warmup", 60))}
	entry["anchors_norm"] = anchors
	entry["output"] = out
	entry["captured_at"] = Time.get_datetime_string_from_system()
	entry["bake"] = bake.get(mode, {})
	all[mode] = entry
	all["_about"] = "ODA 3D spike — camera/light/environment record per plate. Source of truth for geometry/camera: art/oda3d/oda3d_source_scene.json (exported from tools/oda_render_rig/layers.html)."
	var f := FileAccess.open(CAMERA_LIGHT_JSON, FileAccess.WRITE)
	f.store_string(JSON.stringify(all, "  "))
	f.close()
	print("[Oda3D] wrote %s" % ProjectSettings.globalize_path(CAMERA_LIGHT_JSON))


static func _has_prop(o: Object, prop: String) -> bool:
	for pi in o.get_property_list():
		if pi.name == prop:
			return true
	return false


func _parse_args() -> Dictionary:
	var out := {}
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--oda3d-"):
			var kv := a.substr(8).split("=", true, 1)
			out[kv[0]] = kv[1] if kv.size() == 2 else "1"
	return out
