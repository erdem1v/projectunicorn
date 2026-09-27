class_name OfficeLook
extends RefCounted

# How an office person looks: the design's character kit (office-sim-v12.js CHARS, charLook,
# headGeo, bodyLM and OUTFIT_FS) on the Mixamo Xbot. The design colours the body per pixel from
# its rest pose; here that outfit function runs once per vertex of the rest mesh and lands in the
# vertex colours of a copy of the mesh, so Godot's own skinning carries it. The colours are the
# design's 3D scene colours, data here and not UI tokens, and blend in linear light as in three.js.

const XBOT := preload("res://assets/art/office/xbot.glb")
const TOON := preload("res://scenes/office/shaders/office_toon.gdshader")
## Every body is scaled so its head bone rests this high (loadXbot's k).
const HEAD_HEIGHT := 1.58
const FINGER_TRACK := "Hand(Thumb|Index|Middle|Ring|Pinky)"

## The design's ten people. Their variants (charLook's k) take skin, hair unless grey, and
## trousers unless a skirt from the tables below.
const CHARS := [
	{"hs": "part", "skin": Color("#d9b28f"), "hair": Color("#2b2522"), "style": 3, "sleeve": 2,
		"inner": Color("#1d1f24"), "bot": Color("#22252c"), "shoe": Color("#f2f0ea"), "sole": Color("#ffffff"),
		"h": 1.03, "wd": 1.0},
	{"hs": "crop", "skin": Color("#e8c3a0"), "hair": Color("#5a3b26"), "style": 2, "sleeve": 2,
		"inner": Color("#e9e6df"), "bot": Color("#4a4f57"), "shoe": Color("#2e3238"), "sole": Color("#f0efe9"),
		"h": 1.01, "wd": 1.04},
	{"hs": "pony", "skin": Color("#d4a37f"), "hair": Color("#1c1c1c"), "style": 9, "sleeve": 2,
		"bot": Color("#1f2126"), "shoe": Color("#17181b"), "h": 0.96, "wd": 0.93},
	{"hs": "buzz", "skin": Color("#f0d2b6"), "hair": Color("#8b6a45"), "beard": 1, "style": 1, "sleeve": 2,
		"tie": Color("#2b2f3a"), "bot": Color("#2d3a55"), "shoe": Color("#5a3a24"), "sole": Color("#3a2618"),
		"h": 1.05, "wd": 1.08},
	{"hs": "bun", "skin": Color("#b07a55"), "hair": Color("#2b2522"), "style": 4, "sleeve": 2, "skirt": true,
		"bot": Color("#2f3137"), "legs": Color("#26262b"), "shoe": Color("#3a2a22"), "h": 0.95, "wd": 0.94},
	{"hs": "long", "skin": Color("#e2b995"), "hair": Color("#2b2522"), "beard": 1, "style": 0, "sleeve": 1,
		"bot": Color("#5c6146"), "shoe": Color("#8d9197"), "sole": Color("#f0efe9"), "h": 1.0, "wd": 1.03},
	{"hs": "wavy", "skin": Color("#f3dcc4"), "hair": Color("#b87434"), "style": 5, "sleeve": 2,
		"inner": Color("#f1eee8"), "bot": Color("#7a93b3"), "shoe": Color("#f2f0ea"), "sole": Color("#ffffff"),
		"h": 0.98, "wd": 0.94},
	{"hs": "curly", "skin": Color("#8a5a3b"), "hair": Color("#1c1c1c"), "glasses": true, "style": 6, "sleeve": 1,
		"bot": Color("#bfa983"), "shoe": Color("#5a3a24"), "sole": Color("#3a2618"), "h": 1.04, "wd": 1.0},
	{"hs": "bob", "skin": Color("#d9b28f"), "hair": Color("#6e3b22"), "style": 7, "sleeve": 1, "bare_legs": true,
		"bot": Color("#2a2a2e"), "shoe": Color("#2a2a2e"), "h": 0.97, "wd": 0.93},
	{"hs": "quiff", "skin": Color("#c79b78"), "hair": Color("#9a9a9a"), "beard": 2, "style": 8, "sleeve": 2,
		"inner": Color("#eef1f4"), "bot": Color("#55585e"), "shoe": Color("#1b1c1f"), "h": 1.02, "wd": 1.05},
]
const SKINS := [Color("#e8c3a0"), Color("#d4a37f"), Color("#b07a55"), Color("#8a5a3b"), Color("#f0d2b6"), Color("#c79b78")]
const HAIRS := [Color("#2b2522"), Color("#5a3b26"), Color("#8b6a45"), Color("#1c1c1c"), Color("#6e3b22"), Color("#a8793f")]
const BOTS := [Color("#22252c"), Color("#4a4f57"), Color("#2d3a55"), Color("#5c6146"), Color("#7a93b3"), Color("#3a3230")]
const VARIANTS := 6       # the tables' length: later variants repeat
const GREY_HAIR := Color("#9a9a9a")
## What a preset that names none wears, and the face's fixed parts.
const INNER := Color("#eeeeea")
const TIE := Color("#2b2f3a")
const EYES := Color("#1c1a1f")
const MOUTH := Color("#8e4f48")
const HAIR_TIE := Color("#2f2f35")
const FRAMES := Color("#16181c")

## OUTFIT_FS's return values, in the order _palette lists them.
enum Slot { SKIN, TOP, TOP_80, INNER, INNER_80, TOP_92, TIE, TOP_72, TOP_55, TOP_110, INNER_110,
	TOP_78, TOP_84, BOT, BOT_80, LEGS, BELT, SHOE, SOLE }

## One vertex-coloured toon material for every body and head, made by rig().
static var material: ShaderMaterial
static var _rig := {}
static var _outfits := {}   # "preset|variant|top" -> [surface mesh, joints mesh]
static var _slots := {}     # outfit cut -> [surface slots, joints slots]
static var _heads := {}     # headGeo's key -> mesh


## The design's charLook: one of the ten people, as variant `variant` (0 = as drawn).
static func look_of(preset: int, variant: int) -> Dictionary:
	var look: Dictionary = CHARS[preset].duplicate()
	look.id = "%d|%d" % [preset, variant]
	if variant > 0:
		look.skin = SKINS[(preset + variant * 2) % SKINS.size()]
		if look.hair != GREY_HAIR:
			look.hair = HAIRS[(preset + variant) % HAIRS.size()]
		if not look.has("skirt"):
			look.bot = BOTS[(preset + variant * 3) % BOTS.size()]
	look.legs = look.skin if look.has("bare_legs") else look.get("legs", look.bot)
	return look


## The Xbot measured once from its rest pose: k (body scale), hip_y (hip height at that scale),
## flip (a turn when the toes point to -z), unit (the armature's own scale), and the rest mesh.
static func rig() -> Dictionary:
	if _rig.is_empty():
		_measure()
	return _rig


## The body's surface and joint meshes dressed as `look` with its top in `top`: vertex-coloured
## copies of the Xbot meshes that keep its skin and skeleton.
static func outfit(look: Dictionary, top: Color) -> Array:
	var key := "%s|%s" % [look.id, top.to_html()]
	if not _outfits.has(key):
		var sources: Array = rig().arrays
		var slots := _cut(look)
		var palette := _palette(look, top)
		var meshes := []
		for m in 2:
			var arrays: Array = sources[m].duplicate()
			var cut: PackedByteArray = slots[m]
			var colors := PackedColorArray()
			colors.resize(cut.size())
			for i in cut.size():
				colors[i] = palette[cut[i]]
			arrays[Mesh.ARRAY_COLOR] = colors
			# Every person holds a copy; the toon shader reads neither of these.
			arrays[Mesh.ARRAY_TANGENT] = null
			arrays[Mesh.ARRAY_TEX_UV] = null
			var mesh := ArrayMesh.new()
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			meshes.append(mesh)
		_outfits[key] = meshes
	return _outfits[key]


## headGeo: spheres (and the glasses' boxes) merged into one vertex-coloured mesh, in the head
## bone's frame at world scale.
static func head_mesh(look: Dictionary) -> ArrayMesh:
	var key := "%s|%s|%s|%d|%s" % [look.hs, look.hair.to_html(), look.skin.to_html(), look.get("beard", 0),
		look.has("glasses")]
	if not _heads.has(key):
		_heads[key] = _merge(_head_parts(look))
	return _heads[key]


static func _measure() -> void:
	var body: Node3D = XBOT.instantiate()
	var skeleton: Skeleton3D = body.get_node("Armature/Skeleton3D")
	var to_body: Transform3D = (body.get_node("Armature") as Node3D).transform * skeleton.transform
	var rest := func(bone: String) -> Vector3:
		return to_body * skeleton.get_bone_global_rest(skeleton.find_bone("mixamorig_" + bone)).origin
	var k: float = HEAD_HEIGHT / rest.call("Head").y
	_rig.k = k
	_rig.hip_y = rest.call("Hips").y * k
	_rig.flip = 0.0 if rest.call("LeftToeBase").z >= rest.call("LeftFoot").z else PI
	_rig.unit = to_body.basis.get_scale().x
	# A hand is a few pixels across even at the closest zoom, and the finger tracks were two
	# thirds of each clip's tracks. Every body shares these clips, so this happens once.
	var clips: AnimationPlayer = body.get_node("AnimationPlayer")
	var finger := RegEx.create_from_string(FINGER_TRACK)
	for clip: StringName in [&"idle", &"walk"]:
		var anim := clips.get_animation(clip)
		for i in range(anim.get_track_count() - 1, -1, -1):
			if finger.search(String(anim.track_get_path(i))):
				anim.remove_track(i)

	# bodyLM: the landmarks come from where the skin binds each bone in the surface mesh's space.
	var surface: MeshInstance3D = skeleton.get_node("Beta_Surface")
	var at := {}
	for i in surface.skin.get_bind_count():
		at[String(surface.skin.get_bind_name(i)).trim_prefix("mixamorig_")] = surface.skin.get_bind_pose(i).affine_inverse().origin
	var up: Vector3 = (at.Neck - at.Hips).normalized()
	var across: Vector3 = at.LeftHand - at.RightHand
	across = (across - up * across.dot(up)).normalized()
	var front := across.cross(up).normalized()
	if (at.LeftToeBase - at.LeftFoot).dot(front) < 0.0:
		front = -front
	_rig.arrays = [surface.mesh.surface_get_arrays(0),
		(skeleton.get_node("Beta_Joints") as MeshInstance3D).mesh.surface_get_arrays(0)]
	var low := INF
	var high := -INF
	for v: Vector3 in _rig.arrays[0][Mesh.ARRAY_VERTEX]:
		low = minf(low, v.dot(up))
		high = maxf(high, v.dot(up))
	var origin: Vector3 = at.Hips + up * (low - at.Hips.dot(up))
	var y := func(v: Vector3) -> float: return (v - origin).dot(up)
	var x := func(v: Vector3) -> float: return absf((v - origin).dot(across))
	_rig.lm = {"h": high - low, "neck": y.call(at.Neck), "sh": y.call(at.LeftArm), "chest": y.call(at.Spine2),
		"waist": y.call(at.Hips) * 0.4 + y.call(at.Spine) * 0.6, "hip": y.call(at.LeftUpLeg),
		"knee": y.call(at.LeftLeg), "ank": y.call(at.LeftFoot), "xsh": x.call(at.LeftArm),
		"xel": x.call(at.LeftForeArm), "xwr": x.call(at.LeftHand), "hwr": y.call(at.LeftHand)}
	# Each vertex's height, distance from the midline and side (front or back) never change.
	_rig.frames = []
	for arrays: Array in _rig.arrays:
		var ys := PackedFloat32Array()
		var xs := PackedFloat32Array()
		var fronts := PackedByteArray()
		for v: Vector3 in arrays[Mesh.ARRAY_VERTEX]:
			var p := v - origin
			ys.append(p.dot(up))
			xs.append(absf(p.dot(across)))
			fronts.append(int(p.dot(front) > 0.0))
		_rig.frames.append([ys, xs, fronts])
	body.free()
	material = ShaderMaterial.new()
	material.shader = TOON
	material.set_shader_parameter("use_vertex_color", true)


## Every vertex's Slot for one cut of clothes; the colours come later, per person.
static func _cut(look: Dictionary) -> Array:
	var key := "%d|%d|%s|%s" % [look.style, look.sleeve, look.has("skirt"), look.has("tie")]
	if not _slots.has(key):
		var lm: Dictionary = _rig.lm
		var out := []
		for frame: Array in _rig.frames:
			var ys: PackedFloat32Array = frame[0]
			var xs: PackedFloat32Array = frame[1]
			var fronts: PackedByteArray = frame[2]
			var cut := PackedByteArray()
			cut.resize(ys.size())
			for i in ys.size():
				cut[i] = _slot(lm, look, ys[i], xs[i], fronts[i] == 1)
			out.append(cut)
		_slots[key] = out
	return _slots[key]


## OUTFIT_FS for one point of the rest mesh: `y` its height above the soles, `ax` its distance
## from the midline, `fr` whether it faces front.
static func _slot(lm: Dictionary, look: Dictionary, y: float, ax: float, fr: bool) -> int:
	var h: float = lm.h
	var st: int = look.style
	var sleeve: int = look.sleeve
	if ax > lm.xsh * 1.02 and y > minf(lm.hwr, lm.sh) - 0.08 * h:
		var end: float = lm.xsh * 1.06 if sleeve == 0 else (lerpf(lm.xsh, lm.xel, 0.6) if sleeve == 1 else lm.xwr - 0.012 * h)
		if ax >= end:
			return Slot.SKIN
		if sleeve == 2 and ax > end - 0.016 * h:
			return Slot.INNER_80 if st == 8 else Slot.TOP_80
		return Slot.INNER if st == 8 else Slot.TOP
	if y > lm.neck - 0.008 * h:
		return Slot.TOP_92 if st == 4 and y < lm.neck + 0.03 * h else Slot.SKIN
	var ny: float = lm.neck - 0.03 * h
	if y > lm.waist:
		match st:
			3, 5:
				var vy: float = lm.chest - 0.015 * h
				var vw := (y - vy) * 0.42
				if fr and y > vy and ax < vw:
					if look.has("tie") and ax < 0.011 * h and y < ny:
						return Slot.TIE
					return Slot.SKIN if y > ny - 0.01 * h and ax < 0.022 * h else Slot.INNER
				if st == 3 and fr and y > vy - 0.02 * h and ax < vw + 0.014 * h:
					return Slot.TOP_72
				if st == 5 and fr and ax < 0.005 * h and fmod(y, 0.05 * h) < 0.014 * h:
					return Slot.TOP_55
				return Slot.TOP
			1, 6, 8:
				if y > ny - 0.014 * h and ax < 0.055 * h:
					return Slot.INNER_110 if st == 8 else Slot.TOP_110
				if st == 8 and fr and y > lm.chest - 0.03 * h and ax < (y - (lm.chest - 0.03 * h)) * 0.45:
					return Slot.INNER
				if fr and ax < 0.0045 * h and (st != 6 or y > ny - 0.07 * h):
					return Slot.TOP_78
				if st == 1 and look.has("tie") and fr and y > lm.waist + 0.05 * h \
						and ax < lerpf(0.017, 0.009, clampf((y - lm.waist) / (ny - lm.waist), 0.0, 1.0)) * h:
					return Slot.TIE
				return Slot.TOP
			2:
				if fr and y > lm.waist + 0.05 * h and y < lm.waist + 0.15 * h and ax < 0.075 * h:
					return Slot.TOP_84
				if fr and ax > 0.016 * h and ax < 0.022 * h and y > ny - 0.11 * h and y < ny:
					return Slot.INNER
				if not fr and y > ny - 0.03 * h:
					return Slot.TOP_80
				return Slot.TOP_84 if y < lm.waist + 0.03 * h else Slot.TOP
		if st != 4 and fr and y > ny - 0.01 * h + pow(ax / (0.06 * h), 2.0) * 0.03 * h:
			return Slot.SKIN
		return Slot.TOP
	if st == 7:
		if y > lm.knee + 0.025 * h:
			return Slot.TOP_80 if y > lm.waist - 0.012 * h else Slot.TOP
		if y > lm.ank + 0.012 * h:
			return Slot.LEGS
	else:
		if st == 3 and y > lm.hip + 0.02 * h:
			return Slot.TOP
		if look.has("skirt"):
			if y > lm.knee + 0.03 * h:
				return Slot.BOT_80 if y > lm.waist - 0.014 * h else Slot.BOT
			if y > lm.ank + 0.012 * h:
				return Slot.LEGS
		else:
			if st != 2 and y > lm.waist - 0.022 * h:
				return Slot.BELT
			if y > lm.ank + 0.012 * h:
				return Slot.BOT
	return Slot.SHOE if y > 0.014 * h else Slot.SOLE


## Slot -> linear colour for one person.
static func _palette(look: Dictionary, top_srgb: Color) -> PackedColorArray:
	var skin: Color = look.skin.srgb_to_linear()
	var top := top_srgb.srgb_to_linear()
	var inner: Color = look.get("inner", INNER).srgb_to_linear()
	var bot: Color = look.bot.srgb_to_linear()
	var shoe: Color = look.shoe.srgb_to_linear()
	return PackedColorArray([skin, top, _times(top, 0.8), inner, _times(inner, 0.8), _times(top, 0.92),
		look.get("tie", TIE).srgb_to_linear(), _times(top, 0.72), _times(top, 0.55), _times(top, 1.1),
		_times(inner, 1.1), _times(top, 0.78), _times(top, 0.84), bot, _times(bot, 0.8),
		look.legs.srgb_to_linear(), Color(shoe.r * 0.8 + 0.02, shoe.g * 0.8 + 0.02, shoe.b * 0.8 + 0.02),
		shoe, look.get("sole", look.shoe).srgb_to_linear()])


static func _times(c: Color, k: float) -> Color:
	return Color(c.r * k, c.g * k, c.b * k)


## headGeo's parts for `look`: [linear colour, scale, centre, x turn, z turn, box].
static func _head_parts(look: Dictionary) -> Array:
	var skin: Color = look.skin.srgb_to_linear()
	var hair: Color = look.hair.srgb_to_linear()
	var parts := [_part(skin, Vector3(0.105, 0.12, 0.11), Vector3(0, 0.12, 0.01)),
		_part(_times(skin, 0.86), Vector3(0.014, 0.02, 0.018), Vector3(0, 0.102, 0.116)),
		_part(MOUTH.srgb_to_linear(), Vector3(0.02, 0.0045, 0.006), Vector3(0, 0.072, 0.107))]
	for s in [-1.0, 1.0]:
		parts.append(_part(skin, Vector3(0.02, 0.032, 0.014), Vector3(s * 0.103, 0.115, 0.012)))
		parts.append(_part(EYES.srgb_to_linear(), Vector3(0.011, 0.013, 0.007), Vector3(s * 0.036, 0.127, 0.107)))
		parts.append(_part(hair, Vector3(0.024, 0.0055, 0.01), Vector3(s * 0.037, 0.149, 0.106), 0.0, s * -0.12))
	var low := 0.005 if look.hs in ["pony", "bun"] else 0.0
	if look.hs not in ["buzz", "curly"]:
		parts.append(_part(hair, Vector3(0.113, 0.07, 0.118), Vector3(0, 0.185 - low, 0)))
		parts.append(_part(hair, Vector3(0.109, 0.095, 0.1), Vector3(0, 0.145, -0.035)))
	match look.hs:
		"crop", "part":
			if look.hs == "part":
				parts.append(_part(hair, Vector3(0.08, 0.035, 0.1), Vector3(0.03, 0.235, 0.02), 0.0, -0.25))
			for s in [-1.0, 1.0]:
				parts.append(_part(hair, Vector3(0.012, 0.03, 0.02), Vector3(s * 0.1, 0.118, 0.03)))
		"quiff":
			parts.append(_part(hair, Vector3(0.065, 0.05, 0.07), Vector3(0, 0.24, 0.06), -0.45))
		"buzz":
			parts.append(_part(hair, Vector3(0.108, 0.072, 0.113), Vector3(0, 0.165, -0.006)))
			parts.append(_part(hair, Vector3(0.1, 0.08, 0.09), Vector3(0, 0.12, -0.04)))
		"long":
			parts.append(_part(hair, Vector3(0.105, 0.15, 0.055), Vector3(0, 0.06, -0.075)))
			for s in [-1.0, 1.0]:
				parts.append(_part(hair, Vector3(0.032, 0.11, 0.06), Vector3(s * 0.09, 0.075, 0.03)))
		"wavy":
			parts.append(_part(hair, Vector3(0.108, 0.16, 0.06), Vector3(0, 0.05, -0.075)))
			parts.append(_part(hair, Vector3(0.05, 0.05, 0.05), Vector3(0, -0.03, -0.08)))
			for s in [-1.0, 1.0]:
				parts.append(_part(hair, Vector3(0.036, 0.12, 0.065), Vector3(s * 0.09, 0.07, 0.025)))
				parts.append(_part(hair, Vector3(0.045, 0.05, 0.045), Vector3(s * 0.085, 0, -0.02)))
		"pony":
			parts.append(_part(hair, Vector3(0.035, 0.1, 0.035), Vector3(0, 0.09, -0.14), 0.35))
			parts.append(_part(HAIR_TIE.srgb_to_linear(), Vector3(0.022, 0.014, 0.022), Vector3(0, 0.165, -0.125)))
		"bun":
			parts.append(_part(hair, Vector3(0.05, 0.045, 0.05), Vector3(0, 0.245, -0.05)))
		"bob":
			parts.append(_part(hair, Vector3(0.12, 0.09, 0.118), Vector3(0, 0.1, -0.02)))
			parts.append(_part(hair, Vector3(0.085, 0.03, 0.03), Vector3(0, 0.19, 0.095)))
		"curly":
			parts.append(_part(hair, Vector3(0.11, 0.08, 0.115), Vector3(0, 0.17, -0.01)))
			for j in 11:
				var a := TAU * j / 11.0
				var e := 0.55 if j % 2 else 0.95
				parts.append(_part(hair, Vector3(0.052, 0.05, 0.052),
					Vector3(cos(a) * 0.085 * e, 0.19 + (0.04 if j % 2 else 0.0), sin(a) * 0.09 * e - 0.01)))
	match look.get("beard", 0):
		1:
			parts.append(_part(hair, Vector3(0.088, 0.06, 0.07), Vector3(0, 0.055, 0.052)))
			parts.append(_part(hair, Vector3(0.035, 0.009, 0.012), Vector3(0, 0.087, 0.113)))
		2:
			parts.append(_part(hair.lerp(skin, 0.45), Vector3(0.09, 0.052, 0.066), Vector3(0, 0.062, 0.052)))
	if look.has("glasses"):
		var frames := FRAMES.srgb_to_linear()
		for s in [-1.0, 1.0]:
			parts.append(_part(frames, Vector3(0.048, 0.03, 0.006), Vector3(s * 0.037, 0.128, 0.118), 0.0, 0.0, true))
			parts.append(_part(frames, Vector3(0.005, 0.005, 0.1), Vector3(s * 0.075, 0.13, 0.07), 0.0, 0.0, true))
		parts.append(_part(frames, Vector3(0.022, 0.005, 0.006), Vector3(0, 0.132, 0.12), 0.0, 0.0, true))
	return parts


static func _part(color: Color, scale: Vector3, centre: Vector3, turn_x := 0.0, turn_z := 0.0, box := false) -> Array:
	return [color, scale, centre, turn_x, turn_z, box]


## Unit spheres (the design's SphereGeometry(1, 14, 10)) and unit boxes, each scaled, turned
## and moved as its part says, in one surface.
static func _merge(parts: Array) -> ArrayMesh:
	var sphere := SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	sphere.radial_segments = 14
	sphere.rings = 10
	var units := [sphere.get_mesh_arrays(), BoxMesh.new().get_mesh_arrays()]
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var index := PackedInt32Array()
	for part: Array in parts:
		var unit: Array = units[int(part[5])]
		var basis := Basis(Vector3.BACK, part[4]) * Basis(Vector3.RIGHT, part[3]) * Basis.from_scale(part[1])
		var normal_basis := basis.inverse().transposed()
		var base := verts.size()
		for v: Vector3 in unit[Mesh.ARRAY_VERTEX]:
			verts.append(basis * v + part[2])
			colors.append(part[0])
		for n: Vector3 in unit[Mesh.ARRAY_NORMAL]:
			normals.append((normal_basis * n).normalized())
		for i: int in unit[Mesh.ARRAY_INDEX]:
			index.append(base + i)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = index
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
