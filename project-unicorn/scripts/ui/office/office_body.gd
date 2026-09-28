class_name OfficeBody
extends RefCounted

# An office person's body: the sex's retargeted Quaternius skeleton (%GeneralSkeleton, humanoid
# bone names, so every clip pack plays on it) wearing four parts, one per PeopleParts.KINDS, merged
# into a single skinned surface. Each source surface lands in the vertex colours as its role's
# colour from the person's look, so one toon material draws everyone and a person is one draw.
# The merged shape is cached by parts, its coloured mesh by parts and colours (height and girth are
# the holder's scale), and the bust renders the same mesh.

const PARTS := "res://assets/art/people/q22/%s.glb"
const TOON := preload("res://scenes/office/shaders/office_toon.gdshader")
## The sex's skeleton comes from these files; every part of a sex is bound to the same pose.
const BASE := {"m": "m_suit", "w": "w_suit"}
## Height and width steps a look picks from (holder scale).
const HEIGHTS := [0.95, 0.975, 1.0, 1.025, 1.05]
const GIRTHS := [0.95, 1.0, 1.06]
## Derived tones: how much darker a shade, a brow and a beard are than what they follow.
const SHADE := 0.82
const BROW := 0.6
const BEARD := 0.85
## Vertices closer than 1 / WELD metres share a smoothed normal.
const WELD := 10000.0
## Glasses are built round the head's eyes: each rim this much wider and taller than its eye (at
## least the minimum), this far in front of it, of bars this thick; the arms reach this far back.
const RIM_MARGIN := Vector2(0.012, 0.01)
const RIM_MIN := Vector2(0.022, 0.016)
const RIM_FRONT := 0.012
const RIM_BAR := 0.005
const ARM_BACK := 0.1

static var material: ShaderMaterial
static var _sources := {}   # part -> {mesh, skin}
static var _bases := {}     # sex -> PackedScene
static var _skins := {}     # sex -> Skin
static var _shapes := {}    # sex, parts, glasses -> [mesh arrays without colours, [[vertex count, role], ...]]
static var _meshes := {}    # the same and the colour indices -> ArrayMesh
static var _blocks := {}    # size and colour -> ArrayMesh


## A new body for `look`, rooted at the feet and facing +Z, its AnimationPlayer's root set.
static func build(look: Dictionary) -> Node3D:
	if material == null:
		material = ShaderMaterial.new()
		material.shader = TOON
		material.set_shader_parameter("use_vertex_color", true)
		material.set_shader_parameter("outline_only", true)
	var sex: String = look.sex
	if not _bases.has(sex):
		_bases[sex] = load(PARTS % BASE[sex])
	var body: Node3D = (_bases[sex] as PackedScene).instantiate()
	var skel: Skeleton3D = body.get_node("%GeneralSkeleton")
	for old in skel.get_children():
		if old is MeshInstance3D:
			old.free()
	var mi := MeshInstance3D.new()
	mi.name = "Body"
	mi.mesh = mesh_of(look)
	mi.skin = _skin(sex)
	mi.material_override = material
	skel.add_child(mi)
	mi.skeleton = NodePath("..")
	var w: float = GIRTHS[look.get("girth", 1)]
	body.scale = Vector3(w, HEIGHTS[look.get("height", 2)], w)
	return body


static func mesh_of(look: Dictionary) -> ArrayMesh:
	var shape_key := "%s|%s|%s|%s|%s|%s" % [look.sex, look.head, look.body, look.legs, look.feet, look.get("glasses", false)]
	var key := "%s|%d|%d|%d|%d|%d|%d|%d" % [shape_key, look.skin, look.hair, look.top, look.top2, look.tie, look.bottom, look.shoe]
	if _meshes.has(key):
		return _meshes[key]
	if not _shapes.has(shape_key):
		_shapes[shape_key] = _shape(look)
	var shape: Array = _shapes[shape_key]
	var colors := _colors(look)
	var cols := PackedColorArray()
	for run: Array in shape[1]:
		var start := cols.size()
		cols.resize(start + run[0])
		for i in run[0]:
			cols[start + i] = colors[run[1]]
	var arrays: Array = (shape[0] as Array).duplicate()
	arrays[Mesh.ARRAY_COLOR] = cols
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	_meshes[key] = mesh
	return mesh


## The four parts (and glasses) merged onto the sex's skin, each run of vertices tagged with its
## colour role.
static func _shape(look: Dictionary) -> Array:
	var canon := _skin(look.sex)
	var binds := _binds(canon)
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var bones := PackedInt32Array()
	var weights := PackedFloat32Array()
	var index := PackedInt32Array()
	var runs := []
	var eyes := PackedVector3Array()
	for kind: String in PeopleParts.KINDS:
		var part := "%s/%s" % [look[kind.to_lower()], kind]
		var src := _source(part)
		var remap := _remap(src.skin, binds)
		var roles: Dictionary = PeopleParts.SURFACES[part]
		for s in src.mesh.get_surface_count():
			var role: String = roles[src.mesh.surface_get_material(s).resource_name]
			if role == "drop":
				continue
			var a: Array = src.mesh.surface_get_arrays(s)
			if role == "eye":
				eyes.append_array(a[Mesh.ARRAY_VERTEX])
			var base := verts.size()
			verts.append_array(a[Mesh.ARRAY_VERTEX])
			normals.append_array(a[Mesh.ARRAY_NORMAL])
			var b: PackedInt32Array = a[Mesh.ARRAY_BONES]
			for i in b.size():
				b[i] = remap[b[i]]
			bones.append_array(b)
			weights.append_array(a[Mesh.ARRAY_WEIGHTS])
			runs.append([verts.size() - base, role])
			for i: int in a[Mesh.ARRAY_INDEX]:
				index.append(base + i)
	if look.get("glasses", false):
		var head: int = binds[&"Head"]
		var frame := _glasses(eyes)
		var base := verts.size()
		verts.append_array(frame[0])
		normals.append_array(frame[1])
		for i in verts.size() - base:
			bones.append_array([head, 0, 0, 0])
			weights.append_array([1.0, 0.0, 0.0, 0.0])
		runs.append([verts.size() - base, "glasses"])
		for i: int in frame[2]:
			index.append(base + i)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = _smooth(verts, normals)
	arrays[Mesh.ARRAY_BONES] = bones
	arrays[Mesh.ARRAY_WEIGHTS] = weights
	arrays[Mesh.ARRAY_INDEX] = index
	return [arrays, runs]


## The parts are flat shaded, and the ink pass outlines every facet of a flat-shaded body: each
## vertex takes the mean of the normals at its position instead.
static func _smooth(verts: PackedVector3Array, normals: PackedVector3Array) -> PackedVector3Array:
	var sums := {}
	for i in verts.size():
		var key := (verts[i] * WELD).round()
		sums[key] = sums.get(key, Vector3.ZERO) + normals[i]
	var out := PackedVector3Array()
	out.resize(verts.size())
	for i in verts.size():
		out[i] = (sums[(verts[i] * WELD).round()] as Vector3).normalized()
	return out


## Role -> linear colour for a look; the palettes are sRGB like the design's.
static func _colors(look: Dictionary) -> Dictionary:
	var pick := func(palette: String, i: int) -> Color: return Color(PeopleParts.PALETTES[palette][i]).srgb_to_linear()
	var skin: Color = pick.call("skin", look.skin)
	var hair: Color = pick.call("hair", look.hair)
	var top: Color = pick.call(PeopleParts.top_palette(look.body, "top"), look.top)
	var bottom: Color = top if PeopleParts.bottom_is_top(look) else pick.call("bottom", look.bottom)
	var shoe: Color = pick.call("shoe", look.shoe)
	var top2: Color = pick.call(PeopleParts.top_palette(look.body, "top2"), look.top2)
	return {
		"skin": skin, "skin_shade": skin * SHADE, "hair": hair, "hair_shade": hair * SHADE,
		"brow": hair * BROW, "beard": hair * BEARD, "eye": Color(PeopleParts.EYE).srgb_to_linear(),
		"top": top, "top_shade": top * SHADE, "top2": top2,
		"tie": top2 if look.tie < 0 else pick.call("tie", look.tie), "belt": Color(PeopleParts.BELT).srgb_to_linear(),
		"bottom": bottom, "bottom_shade": bottom * SHADE, "shoe": shoe, "shoe_shade": shoe * SHADE,
		"sole": Color(PeopleParts.SOLE).srgb_to_linear(), "glasses": Color(PeopleParts.GLASSES).srgb_to_linear(),
	}


## A frame of boxes round the two eyes (split by side): two rims, a bridge and two arms back to
## the ears. [vertices, normals, indices].
static func _glasses(eyes: PackedVector3Array) -> Array:
	var out := [PackedVector3Array(), PackedVector3Array(), PackedInt32Array()]
	var rims := []
	for side: float in [1.0, -1.0]:
		var box := AABB()
		var first := true
		for v in eyes:
			if signf(v.x) == side:
				box = AABB(v, Vector3.ZERO) if first else box.expand(v)
				first = false
		var half := Vector2(maxf(box.size.x * 0.5 + RIM_MARGIN.x, RIM_MIN.x), maxf(box.size.y * 0.5 + RIM_MARGIN.y, RIM_MIN.y))
		var c := box.get_center() + Vector3(0.0, 0.0, box.size.z * 0.5 + RIM_FRONT)
		rims.append([c, half])
		for y: float in [half.y, -half.y]:
			_box(out, c + Vector3(0.0, y, 0.0), Vector3(half.x, RIM_BAR, RIM_BAR))
		for x: float in [half.x, -half.x]:
			_box(out, c + Vector3(x, 0.0, 0.0), Vector3(RIM_BAR, half.y, RIM_BAR))
		var outer: Vector3 = c + Vector3(side * half.x, half.y * 0.6, -ARM_BACK * 0.5)
		_box(out, outer, Vector3(RIM_BAR, RIM_BAR, ARM_BACK * 0.5))
	var inner_l: Vector3 = rims[0][0] - Vector3(rims[0][1].x, 0.0, 0.0)
	var inner_r: Vector3 = rims[1][0] + Vector3(rims[1][1].x, 0.0, 0.0)
	_box(out, (inner_l + inner_r) * 0.5 + Vector3.UP * rims[0][1].y * 0.3, Vector3(absf(inner_l.x - inner_r.x) * 0.5, RIM_BAR, RIM_BAR))
	return out


## A plain block of `size` in one colour, drawn with the people's material: the props.
static func block(size: Vector3, color: Color) -> ArrayMesh:
	var key := "%s|%s" % [size, color]
	if not _blocks.has(key):
		var out := [PackedVector3Array(), PackedVector3Array(), PackedInt32Array()]
		_box(out, Vector3.ZERO, size * 0.5)
		var cols := PackedColorArray()
		cols.resize((out[0] as PackedVector3Array).size())
		cols.fill(color.srgb_to_linear())
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = out[0]
		arrays[Mesh.ARRAY_NORMAL] = out[1]
		arrays[Mesh.ARRAY_COLOR] = cols
		arrays[Mesh.ARRAY_INDEX] = out[2]
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		_blocks[key] = mesh
	return _blocks[key]


## A box of `half` extents at `c`, one quad per face.
static func _box(out: Array, c: Vector3, half: Vector3) -> void:
	for axis in 3:
		for sgn: float in [1.0, -1.0]:
			var n := Vector3.ZERO
			n[axis] = sgn
			var u := Vector3.ZERO
			u[(axis + 1) % 3] = 1.0
			var v := n.cross(u)
			var base: int = (out[0] as PackedVector3Array).size()
			for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
				out[0].append(c + (n + u * corner.x + v * corner.y) * half)
				out[1].append(n)
			for i: int in [0, 2, 1, 0, 3, 2]:
				out[2].append(base + i)


static func _source(part: String) -> Dictionary:
	if not _sources.has(part):
		var file_kind := part.split("/")
		var scene: Node = (load(PARTS % file_kind[0]) as PackedScene).instantiate()
		var mi: MeshInstance3D = scene.find_child("Part_" + file_kind[1], true, false)
		_sources[part] = {"mesh": mi.mesh, "skin": mi.skin}
		scene.free()
	return _sources[part]


static func _skin(sex: String) -> Skin:
	if not _skins.has(sex):
		_skins[sex] = _source("%s/Body" % BASE[sex]).skin
	return _skins[sex]


## Bone name -> its bind index in `canon`.
static func _binds(canon: Skin) -> Dictionary:
	var at := {}
	for i in canon.get_bind_count():
		at[canon.get_bind_name(i)] = i
	return at


## Bind index in `skin` -> the same bone's bind index in the canonical skin (`binds`, _binds()).
static func _remap(skin: Skin, binds: Dictionary) -> PackedInt32Array:
	var out := PackedInt32Array()
	for i in skin.get_bind_count():
		out.append(binds[skin.get_bind_name(i)])
	return out
