extends RefCounted

# The office's 3D image alone (the SubViewport texture, no UI) at pixel camera offsets: per frame the shadow box
# the engine fits to it, and the difference to the first frame of the same set and zoom. main.gd hands an
# --office-shot over after its extra. Quote flag values in a shell: they hold ; and |.
#   --pan=<step>;...  dx,dy[,zm]  pixels of the 3D view (+dx camera right, +dy up), zm scales the opening zoom
#                     sweep:<from>:<to>:<step>:<x|y>:<zm>  one step per value, only the first and last save
#                     fit[:zm]    drag:<dx>:<dy>[:<events>]  the same offset as synthetic mouse events
#   --pan-set=<set>|<set>...  knob lists "k=v,k=v": set 0 is the base, every other set adds to it
#   --pan-gpu=<A>/<B>[;<C>/<D>]  GPU and CPU time of the sub-viewport under two knob lists, ABAB, at the opening pose
# Knobs: the keys of PROPS, tf=1 (TopFill casts the shadow, not the Sun), vig, gk (glow level factor), lamps=0,
# topk (TopFill energy factor), atlas, soft (0 hard .. 5), min (minutes past midnight), native (the view at the
# screen's pixels: factor over the base, 1.3333 at 1440p), inkcode=1 and tooncode=1 (the ink or toon shader's code
# from the file PAN_INK_CODE or PAN_TOON_CODE names), inkw (ink width, px), ext=<variant> (a trial from the
# script PAN_EXT names). resid_* is -1 for a zoom group's first frame and fit steps, and SETDIFF when a set's view
# size differs from set 0's.

const SHADOWS := "rendering/lights_and_shadows/directional_shadow/"
const BIG := 8   # n8 counts the pixels where a channel differs by more than this (0..255)
const MARGIN := 6   # pixels left out at every edge of the area residual compares
## knob -> [node under the SubViewport ("." itself, "env" its Environment), property]
const PROPS := {
	"shadow": ["World/Sun", "shadow_enabled"], "sun": ["World/Sun", "visible"], "top": ["World/TopFill", "visible"],
	"bias": ["World/Sun", "shadow_bias"], "nbias": ["World/Sun", "shadow_normal_bias"],
	"blur": ["World/Sun", "shadow_blur"], "pancake": ["World/Sun", "directional_shadow_pancake_size"],
	"ink": ["World/InkPass", "visible"], "people": ["World/People", "visible"], "quads": ["World/Glows", "visible"],
	"fxaa": [".", "screen_space_aa"], "msaa": [".", "msaa_3d"], "glow": ["env", "glow_enabled"],
	"hs": ["env", "glow_hdr_scale"], "gt": ["env", "glow_hdr_threshold"], "gb": ["env", "glow_blend_mode"],
	"ssao": ["env", "ssao_enabled"], "lowest": ["World/Camera3D", "_lowest"],
	"scale": [".", "scaling_3d_scale"], "smode": [".", "scaling_3d_mode"], "aniso": [".", "anisotropic_filtering_level"],
	"mipbias": [".", "texture_mipmap_bias"], "taa": [".", "use_taa"], "deband": [".", "use_debanding"],
}

var _flag: Callable
var _tree: SceneTree
var _view: Control
var _cam: OfficeCamera
var _sub: SubViewport
var _world: Node
var _sun: DirectionalLight3D
var _top: DirectionalLight3D
var _env: Environment
var _ink: ShaderMaterial
var _stem: String
var _base: Vector3
var _z0: float
var _host0: Vector2   # the container's size at the opening pose: native multiplies it, never the current size
var _first0: Image   # set 0's first frame, which every other set's first frame is compared to
var _n: float   # the directional atlas size the shadow box is fitted to
var _undo: Array[Callable] = []   # replayed in reverse before every knob list


func _init(flag: Callable) -> void:
	_flag = flag


## Coroutine: every set over the step list, then the GPU pairs, then PANDONE.
func run(view: Control, stem: String) -> void:
	var t0 := Time.get_ticks_msec()
	_view = view
	_stem = stem
	_tree = view.get_tree()
	_cam = view.camera
	_sub = view.get_node("Viewport3D/SubViewport")
	_world = _sub.get_node("World")
	_sun = _world.get_node("Sun")
	_top = _world.get_node("TopFill")
	_env = (_world.get_node("WorldEnvironment") as WorldEnvironment).environment
	_ink = (_world.get_node("InkPass") as MeshInstance3D).material_override as ShaderMaterial
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	_apply("")
	# The shell mount, the fit and the --shot-scale refit change the pose and the view size until they settle.
	await _tree.create_timer(1.2).timeout
	await _settle(10)
	_base = _cam.target
	_z0 = _cam.zoom
	_host0 = (_sub.get_parent() as Control).size
	_report()
	var steps := _steps(_flag.call("--pan="))
	var sets: PackedStringArray = String(_flag.call("--pan-set=")).split("|")
	for j in sets.size():
		_apply(sets[0] if j == 0 else sets[0] + "," + sets[j])
		await _tree.create_timer(0.5).timeout
		await _settle(10)
		print("PANSET|%d|%s|video_mib=%.1f|sv=%dx%d" % [j, sets[j],
			Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0, _sub.size.x, _sub.size.y])
		var refs := {}
		for i in steps.size():
			await _step(steps[i], i, j, refs)
	var gpu_spec: String = _flag.call("--pan-gpu=")
	if gpu_spec != "":
		await _gpu(gpu_spec)
	# A frame_pre_draw handler still connected when the engine shuts down crashes it.
	_apply("")
	print("PANDONE|sets=%d|steps=%d|ms=%d" % [sets.size(), steps.size(), Time.get_ticks_msec() - t0])


## The two header lines: the render settings, and the pose, view and light the sets start from.
func _report() -> void:
	print("PANCFG|atlas=%d|bits16=%s|soft=%d|msaa=%d|fxaa=%d|vignette=%.3f|people=%s" % [_n, _shadow("16_bits"),
		_shadow("soft_shadow_filter_quality"), _sub.msaa_3d, _sub.screen_space_aa,
		RenderingServer.shader_get_parameter_default(_ink.shader.get_rid(), &"vignette"), _world.get_node("People").visible])
	var basis := _sun.global_transform.basis.orthonormalized()
	var present: Array = _view.lighting._present.keys()
	present.sort()
	print(("PANCAM|target=%.4v|zoom=%.4f|fit_zoom=%.4f|sv=%dx%d|near=%.3f|far=%.3f|lowest=%.3f|sun_x=%.4v|sun_y=%.4v"
		+ "|present=%s|anyone_in=%s|minute=%.1f") % [_base, _z0, _cam.fit_zoom, _sub.size.x, _sub.size.y, _cam.near,
		_cam.far, _cam._lowest, basis.x, basis.y, ",".join(present), _view.lighting.anyone_in, TimeManager.day_minute()])


## One step of one set: pose, capture, PNG, PAN line; the set's first frame also prints its SETDIFF.
func _step(s: Dictionary, i: int, j: int, refs: Dictionary) -> void:
	if s.kind == "drag":
		await _drag(s.dx, s.dy, s.events)
		return
	if s.kind == "fit":
		_cam.focus(_cam.fit_target, _cam.fit_zoom * s.zm, 0.0)
	else:
		_pose(s.dx, s.dy, s.zm)
	var img: Image = await _grab()
	var vp := Vector2(_sub.size)
	var box := _box(vp)
	var texel: float = 2.0 * box.r / _n
	var d := {"mean": -1.0, "max": -1, "n8": -1}
	if s.kind == "pan":
		var ref: Dictionary = refs.get_or_add(s.zm, {"img": img, "dx": s.dx, "dy": s.dy})
		if ref.img != img:
			d = residual(img, ref.img, Vector2i(roundi(ref.dx - s.dx), roundi(s.dy - ref.dy)))
	if s.save:
		var path := "user://%s_s%d_%d_%s_%s_3d.png" % [_stem, j, i, _num(s.dx).replace(".", "p"), _num(s.dy).replace(".", "p")]
		img.save_png(path)
		print("PANPNG|", ProjectSettings.globalize_path(path))
	print("PAN|%d|%s|%s|%.4f|%.4f|%.3f|%.3f|%.3f|%.3f|%.5f|%.4f|%d|%d|%.4f|%d|%d|%d|%d|%d" % [i, _num(s.dx), _num(s.dy),
		_cam.zoom, _cam.size, _cam.near, _cam.far, _cam.far - _cam.near, box.r, texel, texel * vp.y / _cam.size,
		box.w[0], box.w[1], d.mean, d.max, d.n8, j, box.e[0], box.e[1]])
	if refs.get_or_add("first", img) == img:
		if j == 0:
			_first0 = img
		else:
			var f := residual(img, _first0, Vector2i.ZERO) if img.get_size() == _first0.get_size() else d
			print("SETDIFF|%d|%.4f|%d|%d" % [j, f.mean, f.max, f.n8])


## The camera `dx`, `dy` pixels from the base pose at `zm` times the opening zoom. The sum is parenthesised
## as in OfficeCamera.handle_input, so one drag event lands on the same bits.
func _pose(dx: float, dy: float, zm: float) -> void:
	var z := _z0 * zm
	var upx := _cam.units_per_px(z)
	_cam.focus(_base + (_cam.global_basis.x * (dx * upx) + _cam.global_basis.y * (dy * upx)), z, 0.0)


## The 3D image of the pose just set, once it has been drawn.
func _grab() -> Image:
	await _settle(3)
	return _sub.get_texture().get_image()


## Frames for a change to reach the screen, then the draw of the last one.
func _settle(frames: int) -> void:
	for _i in frames:
		await _tree.process_frame
	await RenderingServer.frame_post_draw


## A drag of the camera by (dx, dy) pixels against a jump to the same pose. The mouse moves opposite to the
## camera in x (the content follows it); a shorter drag than CLICK_SLOP would be a click on a person.
func _drag(dx: float, dy: float, events: int) -> void:
	if Vector2(dx, dy).length() < OfficeCamera.CLICK_SLOP:
		push_error("[PanProbe] a drag under CLICK_SLOP is a click")
		return
	_pose(0.0, 0.0, 1.0)
	var at := Vector2(_sub.size) * 0.5
	var move := Vector2(-dx, dy) / events
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = at
	_cam.handle_input(click)
	var motion := InputEventMouseMotion.new()
	for k in range(1, events + 1):
		motion.position = at + move * k
		_cam.handle_input(motion)
	click.pressed = false
	click.position = at + move * events
	_cam.handle_input(click)
	var dragged: Image = await _grab()
	var reached := _cam.target
	_pose(dx, dy, 1.0)
	var d := residual(dragged, await _grab(), Vector2i.ZERO)
	print("DRAG|%s|%s|%d|%.6f|%.4f|%d|%d" % [_num(dx), _num(dy), events, reached.distance_to(_cam.target), d.mean, d.max, d.n8])


## The --pan text as step dictionaries {kind, dx, dy, zm, save, events}.
func _steps(spec: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for tok in spec.split(";", false):
		var f := tok.split(":")
		match f[0]:
			"fit":
				out.append({"kind": "fit", "dx": 0.0, "dy": 0.0, "zm": f[1].to_float() if f.size() > 1 else 1.0, "save": true})
			"drag":
				out.append({"kind": "drag", "dx": f[1].to_float(), "dy": f[2].to_float(), "events": f[3].to_int() if f.size() > 3 else 20})
			"sweep":
				var n := floori((f[2].to_float() - f[1].to_float()) / f[3].to_float() + 0.000001)
				for k in n + 1:
					var v := f[1].to_float() + k * f[3].to_float()
					out.append({"kind": "pan", "dx": v if f[4] == "x" else 0.0, "dy": v if f[4] == "y" else 0.0,
						"zm": f[5].to_float(), "save": k == 0 or k == n})
			_:
				var p := tok.split(",")
				out.append({"kind": "pan", "dx": p[0].to_float(), "dy": p[1].to_float(),
					"zm": p[2].to_float() if p.size() > 2 else 1.0, "save": true})
	return out


## Puts back what the last knob list changed, resets the global shadow state to the project's, applies `spec`.
func _apply(spec: String) -> void:
	_undo.reverse()
	for undo in _undo:
		undo.call()
	_undo.clear()
	_n = float(_shadow("size"))
	RenderingServer.directional_shadow_atlas_set_size(int(_n), _shadow("16_bits"))
	RenderingServer.directional_soft_shadow_filter_set_quality(_shadow("soft_shadow_filter_quality"))
	for kv in spec.split(",", false):
		var p := kv.split("=")
		_knob(p[0], p[1].to_float())


func _knob(key: String, v: float) -> void:
	if PROPS.has(key):
		var p: Array = PROPS[key]
		_put(_env if p[0] == "env" else _sub.get_node(p[0]), p[1], v)
		return
	match key:
		"tf":
			# The Sun's shadow settings go with it: the fill light's own are four cascade splits.
			for p in ["shadow_blur", "shadow_bias", "shadow_normal_bias", "directional_shadow_fade_start"]:
				_put(_top, p, _sun.get(p))
			_put(_top, "directional_shadow_mode", 0)
			_put(_top, "shadow_enabled", true)
			_put(_sun, "shadow_enabled", false)
		"vig":
			# Null puts the shader's own default back.
			_undo.append(Callable(_ink, "set_shader_parameter").bind("vignette", null))
			_ink.set_shader_parameter("vignette", v)
		"gk":
			# Levels 2 to 4 as the Environment inspector counts: the ones its default curve fills.
			for level in [2, 3, 4]:
				var p := "glow_levels/%d" % level
				_put(_env, p, float(_env.get(p)) * v)
		"topk":
			# OfficeLighting writes the fill's energy every frame: scale it after that, before the draw.
			var scale := func() -> void: _top.light_energy *= v
			RenderingServer.frame_pre_draw.connect(scale)
			_undo.append(func() -> void: RenderingServer.frame_pre_draw.disconnect(scale))
		"native":
			# The container stops stretching the view to its own size, so the view can take the screen's pixels.
			# Unstretched it grows to the view, so the undo shrinks it back last. Past 4K the view's buffers, times
			# the MSAA samples, can exhaust video memory and stall the driver.
			if v > 2.0:
				push_error("[PanProbe] native=%s is past 4K" % v)
				return
			var host := _sub.get_parent() as SubViewportContainer
			_undo.append(func() -> void: host.size = _host0)
			_put(host, "stretch", false)
			_put(_sub, "size", _host0 * v)
		"inkw":
			# The ink cross in pixels: a view at more pixels than the base needs a wider one for the same line.
			_undo.append(Callable(_ink, "set_shader_parameter").bind("texel", null))
			_ink.set_shader_parameter("texel", v)
		"inkcode":
			# A trial shader replaces the shared resource's code for this run only; the game's file stays as it is.
			_put(_ink.shader, "code", FileAccess.get_file_as_string(OS.get_environment("PAN_INK_CODE")))
		"tooncode":
			_put(OfficeMaterials.TOON, "code", FileAccess.get_file_as_string(OS.get_environment("PAN_TOON_CODE")))
		"ext":
			# A trial that needs nodes or resources: the script PAN_EXT names gets the variant and this probe, and
			# changes the view through _put and _undo.
			load(OS.get_environment("PAN_EXT")).new().apply(int(v), self)
		"lamps":
			# OfficeLighting switches these lights every frame, but never their energy.
			if v == 0.0:
				for lamp in ["Lamp0", "Lamp1", "Screen0", "Screen1"]:
					_put(_world.get_node(lamp), "light_energy", 0.0)
		"atlas":
			_n = v
			RenderingServer.directional_shadow_atlas_set_size(int(v), _shadow("16_bits"))
		"soft":
			RenderingServer.directional_soft_shadow_filter_set_quality(int(v) as RenderingServer.ShadowQuality)
		"min":
			_put(TimeManager, "_in_game_hours", v / 60.0)
		_:
			push_error("[PanProbe] unknown knob: %s" % key)


## Sets a property from a knob value, converted to the property's own type, and remembers the old one.
func _put(obj: Object, prop: String, v: Variant) -> void:
	var old: Variant = obj.get(prop)
	_undo.append(Callable(obj, "set").bind(prop, old))
	obj.set(prop, type_convert(v, typeof(old)))


## The engine's directional shadow box for the camera's frame, replicated: the radius, and along the x and y axes
## of the light that casts (the Sun; TopFill under tf=1) the box width and its edge in grid units (the grid is
## fixed in the world).
func _box(vp: Vector2) -> Dictionary:
	var hh := _cam.size * 0.5
	var hw := hh * vp.x / vp.y
	var pts := range(8).map(func(k: int) -> Vector3:
		return _cam.global_transform * Vector3(hw if k & 1 else -hw, hh if k & 2 else -hh, -(_cam.far if k & 4 else _cam.near)))
	var center: Vector3 = pts.reduce(func(a: Vector3, b: Vector3) -> Vector3: return a + b) / 8.0
	var r: float = pts.map(func(p: Vector3) -> float: return center.distance_to(p)).max() * _n / (_n - 2.0)
	var unit := r * 4.0 / _n
	var basis := (_top if _top.shadow_enabled else _sun).global_transform.basis.orthonormalized()
	var w: Array[int] = []
	var e: Array[int] = []
	for axis: Vector3 in [basis.x, basis.y]:
		var lo := snappedf(axis.dot(center) - r, unit)
		w.append(roundi((snappedf(axis.dot(center) + r, unit) - lo) / unit))
		e.append(roundi(lo / unit))
	return {"r": r, "w": w, "e": e}


## ABAB blocks of two knob lists per pair: GPU and CPU time of the sub-viewport (ms) and the video memory.
func _gpu(spec: String) -> void:
	var rid := _sub.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(rid, true)
	for pair in spec.split(";", false):
		var arms := pair.split("/")
		var gpu := [[], []]
		var cpu := [[], []]
		var mem := [0.0, 0.0]
		for b in 8:
			var a := b % 2
			_apply(arms[a])
			# Posing re-places the camera, which re-reads lowest; every arm measures at the opening pose.
			_pose(0.0, 0.0, 1.0)
			await _tree.create_timer(0.5).timeout
			await _settle(10)
			for f in 120:
				await RenderingServer.frame_post_draw
				if f >= 30:
					gpu[a].append(RenderingServer.viewport_get_measured_render_time_gpu(rid))
					cpu[a].append(RenderingServer.viewport_get_measured_render_time_cpu(rid))
			mem[a] = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0
		if (gpu[0] + gpu[1]).max() == 0.0:
			print("GPU|n/a")
		for a in 2:
			var row := "GPU|%s|%d" % [arms[a], gpu[a].size()]
			for series: Array in [gpu[a], cpu[a]]:
				series.sort()
				row += "|%.3f|%.3f" % [series[int(series.size() * 0.5)], series[int(series.size() * 0.95)]]
			print(row)
			print("MEM|%s|%.1f" % [arms[a], mem[a]])


## Difference of `a`, the image after a camera move, to `b`, the reference, over the area both show (inside
## MARGIN). a(p + shift) shows what b(p) shows: a camera move of (dx, dy) pixels is a shift of (-dx, dy).
## mean is the average RGB difference (0..255), max the largest channel difference, n8 the pixels over BIG.
static func residual(a: Image, b: Image, shift: Vector2i) -> Dictionary:
	var size := b.get_size() - Vector2i(absi(shift.x), absi(shift.y)) - Vector2i(MARGIN, MARGIN) * 2
	var at := Vector2i(MARGIN + maxi(0, -shift.x), MARGIN + maxi(0, -shift.y))
	var ca := a.get_region(Rect2i(at + shift, size))
	var cb := b.get_region(Rect2i(at, size))
	ca.convert(Image.FORMAT_RGBA8)
	cb.convert(Image.FORMAT_RGBA8)
	var pa := ca.get_data()
	var pb := cb.get_data()
	if pa == pb:
		return {"mean": 0.0, "max": 0, "n8": 0}
	var ia := pa.to_int32_array()
	var ib := pb.to_int32_array()
	var sum := 0
	var peak := 0
	var n8 := 0
	for k in ia.size():
		var x := ia[k]
		var y := ib[k]
		if x != y:
			var dr := absi((x & 255) - (y & 255))
			var dg := absi(((x >> 8) & 255) - ((y >> 8) & 255))
			var db := absi(((x >> 16) & 255) - ((y >> 16) & 255))
			var big := maxi(dr, maxi(dg, db))
			sum += dr + dg + db
			peak = maxi(peak, big)
			if big > BIG:
				n8 += 1
	return {"mean": sum / (3.0 * size.x * size.y), "max": peak, "n8": n8}


static func _shadow(key: String) -> Variant:
	return ProjectSettings.get_setting(SHADOWS + key)


## Whole numbers as integers; for a file name the caller turns the '.' of a fraction into 'p'.
static func _num(v: float) -> String:
	return "%d" % roundi(v) if is_equal_approx(v, roundf(v)) else "%.3f" % v
