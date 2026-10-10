class_name OfficeLighting
extends RefCounted

# The design's day on the game clock (office-sim-v12.js: CS and csAt, colorScript, update, and
# each office file's tick), with `t` in minutes past midnight. The colours are the design's 3D
# scene colours, data here and not UI tokens; like three.js, every blend happens in linear light.

## three.js r155+ lights are physical: its Lambert divides by π, its intensities do not. The toon
## shader's light() is Godot's own Lambert, so a design intensity is an energy times 1/π.
const LIGHT_SCALE := 1.0 / PI

## [minute, sky top, sky bottom, sun, sun intensity, hemisphere sky, hemisphere ground, hemisphere intensity]
const CS := [
	[420.0, "#6f8fc7", "#f6c7a8", "#ffb38a", 0.9, "#8aa0d8", "#c9a18a", 0.9],
	[540.0, "#8cc3e8", "#f3e7d3", "#fff0d8", 2.1, "#9fc0e6", "#d8c3a5", 1.0],
	[780.0, "#79b8e6", "#e8f1ef", "#ffffff", 2.4, "#a9cbe8", "#d6c9b0", 1.05],
	[1050.0, "#7a9fd6", "#ffc98f", "#ffb46a", 2.3, "#9aa6d8", "#e0a47c", 0.95],
	[1150.0, "#4f5aa8", "#ff8f6b", "#ff7a4d", 1.1, "#7f78b8", "#c98a78", 0.8],
	[1200.0, "#1f2a5c", "#6a5a9a", "#9fb4ff", 0.35, "#5a6ad0", "#4a3f7a", 1.0],
	[1320.0, "#0c1026", "#26306a", "#8fa6ff", 0.45, "#4656c0", "#362c66", 0.9],
	[1440.0, "#0c1026", "#26306a", "#8fa6ff", 0.45, "#4656c0", "#362c66", 0.9],
]
## The design's clock runs from 07:00. Before that its night row holds, meeting the dawn row
## over the hour before 07:00.
const DAWN_FROM := 360.0
const AMBIENT := Color("#fff3e0")
const AMBIENT_DAY := 0.45                # the ambient's share of the hemisphere by day
const TOP_FILL := Color("#fff0dc")
const TOP_FILL_DAY := 0.3                # the top fill's intensity by day
## The top fill's intensity at night with people in. At the design's 1 this shadowless fill dominates the night
## frame: walls, furniture, street and facades glow.
const TOP_FILL_NIGHT := 0.5
const TOP_FILL_DIR := Vector3(3.0, 30.0, 4.0)
const DESK_LAMP := Color("#ffb468")     # intensity 3
const SCREEN_LIGHT := Color("#8fb8ff")  # intensity .9
## The street-level materials, name -> [night, day]; the blend follows the square of day_k.
const STREET := {
	"ground": [Color("#151a36"), Color("#a7b38f")],
	"walk": [Color("#232848"), Color("#d8ccb6")],
	"road": [Color("#151827"), Color("#6b6f78")],
	"grass": [Color("#121b2e"), Color("#9dbb7c")],
	"line": [Color("#2e3350"), Color("#efe9dd")],
}
## The design's glowTex radial gradient: [offset, colour].
const GLOW_STOPS := [[0.0, Color("#ffd6a0", 0.9)], [0.45, Color("#ffbe82", 0.35)], [1.0, Color("#ffaa6e", 0.0)]]
const GLOW_KINDS := ["pool", "street"]   # the sconce glows belong to a light mode the design leaves off
## Godot's ACES is three.js's fit with a 1.8 exposure bias and a divide by the fit at the white
## point; three.js scales by 1/0.6 and divides by nothing. This exposure, and the white where the
## fit reaches 1, make the two one curve, which office_ink's vignette round trip relies on.
const ACES_EXPOSURE := 1.0 / (0.6 * 1.8)
const ACES_WHITE := 25.6684 / 1.8
## The design's grade after its tonemap (ART.ink.g) and its bloom threshold.
const GRADE_CONTRAST := 1.05
const GRADE_SATURATION := 1.08
const BLOOM_THRESHOLD := 0.95

var _sun: DirectionalLight3D
var _top: DirectionalLight3D
var _lamps: Array[SpotLight3D] = []
var _screens: Array[OmniLight3D] = []
var _env: Environment
var _sky: ShaderMaterial
var _ink: ShaderMaterial
var _glow_root: Node3D
var _keys: Array[Dictionary] = []

var _layout: OfficeLayout
var _mats := {}
var _stations := {}          # desk id -> {lamp, screen, lamp_at, screen_at} (OfficeMaterials.stations)
var _station_energy := {}    # desk id -> Vector2(lamp, screen) last written
var _panes: Array[Dictionary] = []
var _haze: Array[Array] = []    # [material, linear base colour]
var _towers: Array[Array] = []  # [material, day map, night map, night map shown]
var _ferry: Node3D
var _glow_mats := {}

## People in the office after hours bring the night interior light on.
var anyone_in := false
## The founder at their desk lights the floor lamp in the evening.
var founder_at_desk := false
## How much the investors' tower's crown on the city map glows, 0..1, over its own glow at night.
var crown_glow := 0.0
var _present := {}


func _init(world: Node3D) -> void:
	_sun = world.get_node("Sun")
	_top = world.get_node("TopFill")
	_lamps.assign([world.get_node("Lamp0"), world.get_node("Lamp1")])
	_screens.assign([world.get_node("Screen0"), world.get_node("Screen1")])
	_env = (world.get_node("WorldEnvironment") as WorldEnvironment).environment
	_sky = _env.sky.sky_material
	_ink = (world.get_node("InkPass") as MeshInstance3D).material_override
	_glow_root = world.get_node("Glows")
	_env.tonemap_exposure = ACES_EXPOSURE
	_env.tonemap_white = ACES_WHITE
	_env.adjustment_contrast = GRADE_CONTRAST
	_env.adjustment_saturation = GRADE_SATURATION
	_env.glow_hdr_threshold = BLOOM_THRESHOLD
	_top.basis = Basis.looking_at(-TOP_FILL_DIR.normalized(), Vector3.FORWARD)
	_top.light_color = TOP_FILL
	for k in 2:
		_lamps[k].rotation.x = -PI / 2.0   # straight down, at the design's target 1 below
		_lamps[k].light_color = DESK_LAMP
		_lamps[k].light_energy = 3.0 * LIGHT_SCALE
		_screens[k].light_color = SCREEN_LIGHT
		_screens[k].light_energy = 0.9 * LIGHT_SCALE
	var night: Array = CS[-1]
	for row: Array in [[0.0] + night.slice(1), [DAWN_FROM] + night.slice(1)] + CS:
		_keys.append({"t": row[0], "top": Color(row[1]).srgb_to_linear(), "bot": Color(row[2]).srgb_to_linear(),
			"sun": Color(row[3]).srgb_to_linear(), "si": row[4], "hs": Color(row[5]).srgb_to_linear(),
			"hg": Color(row[6]).srgb_to_linear(), "hi": row[7]})
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array(GLOW_STOPS.map(func(s: Array) -> float: return s[0]))
	gradient.colors = PackedColorArray(GLOW_STOPS.map(func(s: Array) -> Color: return s[1]))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	for kind: String in GLOW_KINDS:
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		m.disable_fog = true
		m.albedo_texture = texture
		_glow_mats[kind] = m


func set_layout(layout: OfficeLayout, scene: Node3D, materials: Dictionary, stations: Dictionary) -> void:
	_layout = layout
	_mats = materials
	_stations = stations
	anyone_in = false
	founder_at_desk = false
	crown_glow = 0.0
	_present.clear()
	_station_energy.clear()
	_env.fog_enabled = not layout.fog.is_empty()
	if _env.fog_enabled:
		_env.fog_depth_begin = layout.fog.near
		_env.fog_depth_end = layout.fog.far
	var by_name := {}
	for mi: MeshInstance3D in scene.find_children("pane_*", "MeshInstance3D", true, false):
		by_name[mi.name] = mi
	_panes.clear()
	for p: Dictionary in layout.panes:
		_panes.append({"mesh": by_name[p.node], "on": p.on, "off": p.off, "all_night": p.all_night, "lit": false})
	_haze.clear()
	for m: StandardMaterial3D in _mats.get("haze", []):
		_haze.append([m, Color(m.get_meta("extras").base).srgb_to_linear()])
	_towers.clear()
	for m: StandardMaterial3D in _mats.get("tower", []):
		_towers.append([m, m.albedo_texture, m.emission_texture, false])
	_ferry = scene.find_child("ferry", true, false) if layout.id == "loft" else null
	for child in _glow_root.get_children():
		child.free()
	for kind: String in GLOW_KINDS:
		for g: Dictionary in layout.glows.get(kind, []):
			_glow_root.add_child(_glow_quad(g, _glow_mats[kind]))


## A taken desk (0 = founder, i = spots.desk[i]) lights its lamp and screens.
func set_station_state(desk_id: int, present: bool) -> void:
	if present:
		_present[desk_id] = true
	else:
		_present.erase(desk_id)


func apply(t: float) -> void:
	var v := _cs_at(t)
	var f := 0.0 if t < 425.0 or t > 1165.0 else sin(PI * (t - 425.0) / 740.0)
	var inter_day := smoothstep(440.0, 470.0, t) * (1.0 - smoothstep(1142.0, 1160.0, t))
	var night_in := 1.0 if t > 1100.0 and anyone_in else 0.0
	var inter := maxf(inter_day, night_in * 0.55)
	var day_k := smoothstep(425.0, 540.0, t) * (1.0 - smoothstep(1100.0, 1200.0, t))
	var post_on := 1.0 if t > 1120.0 or t < 440.0 else 0.0
	var lamp_hour := t > 1080.0 and founder_at_desk

	var ambient: Color = AMBIENT.srgb_to_linear() * (AMBIENT_DAY * inter_day + 0.12 * night_in)
	_sky.set_shader_parameter("top_color", rgb(v.top.linear_to_srgb()))
	_sky.set_shader_parameter("bottom_color", rgb(v.bot.linear_to_srgb()))
	_sky.set_shader_parameter("hemi_sky", rgb((v.hs * v.hi + ambient) * LIGHT_SCALE))
	_sky.set_shader_parameter("hemi_ground", rgb((v.hg * v.hi + ambient) * LIGHT_SCALE))
	_env.fog_light_color = v.bot.linear_to_srgb()
	_env.glow_intensity = 0.2 + 0.3 * (1.0 - sqrt(f))
	_ink.set_shader_parameter("light_line", day_k)

	_sun.light_color = v.sun.linear_to_srgb()
	_sun.light_energy = v.si * LIGHT_SCALE
	# The Sun is the moon at night: it swings there over the minutes its colour blends to the moon's
	# (CS rows 1150 and 1200), so no shadow turns in one frame.
	var moon_k := smoothstep(1150.0, 1200.0, t)
	var u := clampf((t - 425.0) / 740.0, 0.0, 1.0)
	var el := deg_to_rad(lerpf(10.0 + 48.0 * sin(PI * u), 55.0, moon_k))
	var az := PI / 4.0 + (lerpf(u, 0.35, moon_k) - 0.5) * 2.0
	_sun.basis = Basis.looking_at(-Vector3(sin(az) * cos(el), sin(el), cos(az) * cos(el)))
	_top.light_energy = lerpf(night_in * TOP_FILL_NIGHT, TOP_FILL_DAY, inter_day) * LIGHT_SCALE

	var dk2 := day_k * day_k
	for material_name: String in STREET:
		var pair: Array = STREET[material_name]
		_albedo(material_name, (pair[0] as Color).srgb_to_linear().lerp((pair[1] as Color).srgb_to_linear(), dk2))
	_albedo("pane_dark", v.top.lerp(v.bot, 0.4) * (0.55 + 0.25 * day_k))
	for m: StandardMaterial3D in _mats.get("fade", []):
		m.albedo_color = Color(v.bot.linear_to_srgb(), 0.22)
	for h: Array in _haze:
		var base: Color = h[1]
		h[0].albedo_color = (base.lerp(v.bot, 0.3 + 0.5 * (1.0 - day_k)) * (0.1 + 0.9 * day_k)).linear_to_srgb()

	var night_windows := t > 1110.0 or t < 450.0
	var tower_grey := 1.0 if night_windows else 0.55 + 0.45 * day_k
	for tw: Array in _towers:
		var m: StandardMaterial3D = tw[0]
		if tw[3] != night_windows:
			tw[3] = night_windows
			m.albedo_texture = tw[2] if night_windows else tw[1]
		m.albedo_color = Color(tower_grey, tower_grey, tower_grey).linear_to_srgb()
	for pn: Dictionary in _panes:
		var lit: bool = (t > pn.on and t < (1440.0 if pn.all_night else pn.off)) and f < 0.6
		if lit != pn.lit:
			pn.lit = lit
			(pn.mesh as MeshInstance3D).set_surface_override_material(0, _mats.pane_lit[0] if lit else _mats.pane_dark[0])

	_energy("post", post_on * 2.0)
	_energy("car_head", post_on * 1.4)
	_energy("car_tail", post_on * 1.2)
	_energy("flamp", 2.0 if lamp_hour else 0.0)
	_energy("facade", (1.0 - day_k) * 1.25)
	_energy("crown", maxf(crown_glow * 1.7, (1.0 - day_k) * 0.75))
	_energy("ferry_win", 1.4 if (day_k < 0.5 if _layout.id == "city" else night_windows) else 0.0)
	_scaled("taxi", post_on)
	# On by day and while anyone is in, at full strength: inter dims the night to .55.
	_scaled("device", maxf(inter_day, night_in))
	# The map's water runs on OfficeCity's own clock.
	if _layout.id != "city":
		for m: ShaderMaterial in _mats.get("water", []):
			m.set_shader_parameter("uv1_offset", Vector2(fmod(t * 0.0015, 1.0), sin(t * 0.02) * 0.02))
	if _ferry:
		_ferry.position.x = -80.0 + fmod(t * 0.45, 200.0)
	_glow_mats.pool.albedo_color = Color(1, 1, 1, (0.35 if anyone_in else 0.75) if lamp_hour else 0.0)
	_glow_mats.street.albedo_color = Color(1, 1, 1, 0.55 * post_on)
	_apply_stations(t > 1050.0 or f < 0.35, 0.6 if inter > 0.5 and f > 0.3 else 1.5, t > 1100.0)


func _apply_stations(lamp_on: bool, screen: float, late: bool) -> void:
	for desk: int in _stations:
		var on: bool = _present.has(desk)
		var energy := Vector2(1.6 if on and lamp_on else 0.0, screen if on else 0.0)
		if _station_energy.get(desk) != energy:
			_station_energy[desk] = energy
			_stations[desk].lamp.set_shader_parameter("emission_energy", energy.x)
			_stations[desk].screen.set_shader_parameter("emission_energy", energy.y)
	# The design parks its two desk-lamp spots and screen glows at the first two late desks.
	var desks: Array = _present.keys() if late else []
	desks.sort()
	for k in 2:
		var lit := k < desks.size() and _stations.has(desks[k])
		_lamps[k].visible = lit
		_screens[k].visible = lit
		if lit:
			_lamps[k].global_position = _stations[desks[k]].lamp_at
			_screens[k].global_position = _stations[desks[k]].screen_at


func _cs_at(t: float) -> Dictionary:
	var i := 0
	while i < _keys.size() - 2 and _keys[i + 1].t <= t:
		i += 1
	var a := _keys[i]
	var b := _keys[i + 1]
	var k := smoothstep(0.0, 1.0, (t - a.t) / (b.t - a.t))
	return {"top": a.top.lerp(b.top, k), "bot": a.bot.lerp(b.bot, k), "sun": a.sun.lerp(b.sun, k),
		"si": lerpf(a.si, b.si, k), "hs": a.hs.lerp(b.hs, k), "hg": a.hg.lerp(b.hg, k), "hi": lerpf(a.hi, b.hi, k)}


func _albedo(material_name: String, linear: Color) -> void:
	for m: StandardMaterial3D in _mats.get(material_name, []):
		m.albedo_color = linear.linear_to_srgb()


func _energy(material_name: String, value: float) -> void:
	for m: ShaderMaterial in _mats.get(material_name, []):
		m.set_shader_parameter("emission_energy", value)


## Emission at k times the strength the design gave the material (OfficeMaterials.EMITTERS).
func _scaled(material_name: String, k: float) -> void:
	for m: ShaderMaterial in _mats.get(material_name, []):
		m.set_shader_parameter("emission_energy", m.get_meta("emission_energy") * k)


func _glow_quad(g: Dictionary, material: Material) -> MeshInstance3D:
	var quad := QuadMesh.new()
	quad.size = g.size
	var mi := MeshInstance3D.new()
	mi.mesh = quad
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# The quad faces its normal with its width along x, as the design's decal planes.
	var z: Vector3 = g.normal
	var x := (Vector3.RIGHT if absf(z.x) < 0.9 else Vector3.BACK).slide(z).normalized()
	mi.transform = Transform3D(Basis(x, z.cross(x), z), g.pos)
	return mi


static func rgb(c: Color) -> Vector3:
	return Vector3(c.r, c.g, c.b)
