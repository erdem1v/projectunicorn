extends RefCounted

# A recipe (data) into nodes. The props the design's office builds by name (stations, chairs, plants,
# cars ...) become pack models fitted to the box the design gave them (out/props/<office>_props.json);
# its boxes, floors and walls become primitives in palette colours. A builder serves one variant: it owns
# the model templates, and the toon pass changes their materials.
#
# Recipe keys:
#   packs   {key: {dir under packs/, ext, unit (metres per model unit), row (sheet group)}}
#   skip    [prop types left out]
#   types   {prop type: entry, or {by: index into the prop's args, "<value>": entry}}
#   items   {prop index: entry keys that replace the type's for that prop}
#   inline  [{ops: [...]}]
#   cast    [{look, pose: sit|lie|stand|walk, kind + i (a layout spot) or pos + face, act, lift}]
#   cameras {id: [[x, y, z], zoom over the fit]} (style only)
# Entry: model "pack/name"; front (yaw that turns the model's front to +Z); fit {h|w|d|len|fp: metres, or
# "bbox" for the prop's box} else the pack unit; yaw; lift; emit screen|lamp|street|window; desk (lighting
# desk of a screen or lamp part: a station's own is 0 if big, else its seed); taxi (the model of a car whose
# last arg is true); parts [{at, yaw, model ... or type: another entry}] in the prop's frame.
# Ops: B [x0,x1,y0,y1,z0,z1]; RB [w,h,d,x,y,z]; Cy [r,h,x,y,z] (RB, Cy: rx, ry, rz); floor {x, z, y};
# model {at, entry}; repeat {axis, from, to, at, entry}; wall and glass {axis, at, from, to, h, gaps}.
# B, RB, Cy and floor take `mat`, a palette name (recipes/palette.json); the street's names (ground, walk, road,
# grass, line) stay animated by the light. wall and glass use the palette names wall, cap, base, glass and frame.

const PACKS := "res://sandbox/asset_lab/packs/"
const PALETTE := "res://sandbox/asset_lab/recipes/palette.json"
## Parts smaller than this (m) cast no shadow: they only add speckle to it.
const SMALL := 0.45
## Thickness (m) of a wall piece.
const WALL_T := 0.18
const GLOW := {"screen": OfficeLighting.SCREEN_LIGHT, "lamp": OfficeLighting.DESK_LAMP,
	"street": Color("#ffd6a0"), "window": Color("#ffd6a0")}
## The material names OfficeLighting drives by itself; the stations take their own pairs.
const DRIVEN := {"street": "post", "window": "facade"}

var _holder: Node3D
var _palette := {}
var _recipe := {}
var _packs := {}
var _templates := {}   # model key -> its node under _holder
var _boxes := {}       # model key -> its AABB, in the template's frame
var _paints := {}
var _mats := {}
var _stations := {}
var _glow := {}        # material key -> the shared emissive material of a role
var _fits: Array = []  # [prop tag, model key, scale]
var _miss := {}
var _root: Node3D
var _tag := ""
var _desk := 0


func _init(holder: Node3D) -> void:
	_holder = holder
	var hex: Dictionary = json(PALETTE)
	for key: String in hex:
		_palette[key] = Color(hex[key])


static func json(path: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(path))


## A model file as a node tree: glTF, or FBX by its extension.
static func load_node(path: String) -> Node3D:
	var fbx := path.ends_with(".fbx")
	var doc: GLTFDocument = FBXDocument.new() if fbx else GLTFDocument.new()
	var state: GLTFState = FBXState.new() if fbx else GLTFState.new()
	doc.append_from_file(path, state, 0, path.get_base_dir())
	return doc.generate_scene(state)


## The world box of every mesh under `root`; the lowest y of it is the camera's `lowest`.
static func extent(root: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for mi: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var b := mi.global_transform * mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box


## The models a recipe uses, by sheet row.
static func rows(recipe: Dictionary) -> Dictionary:
	var keys := {}
	_models(recipe, keys)
	var out := {}
	for key: String in keys:
		var pack: String = key.get_slice("/", 0)
		out.get_or_add(recipe.packs[pack].get("row", pack), []).append(key)
	return out


static func _models(node: Variant, out: Dictionary) -> void:
	if node is Dictionary:
		for k: String in node:
			if k in ["model", "taxi"] and node[k] is String:
				out[node[k]] = true
			else:
				_models(node[k], out)
	elif node is Array:
		for v: Variant in node:
			_models(v, out)


## The recipe's office under `parent`: props, then inline blocks; `toon` puts the game's toon material
## on it. Returns {root, mats, stations} for OfficeLighting.set_layout.
func build(parent: Node3D, recipe: Dictionary, props: Dictionary, toon: bool, layout: OfficeLayout) -> Dictionary:
	_start(parent, recipe)
	for it: Dictionary in props.get("items", []):
		if it.type not in recipe.get("skip", []):
			_item(it)
	for block: Dictionary in recipe.get("inline", []):
		for op: Dictionary in block.ops:
			_op(op)
	if toon:
		# Convert reads the mesh's own material, which a bare surface lacks.
		for mi: MeshInstance3D in _root.find_children("*", "MeshInstance3D", true, false):
			for i in mi.mesh.get_surface_count():
				if mi.mesh.surface_get_material(i) == null:
					mi.mesh.surface_set_material(i, StandardMaterial3D.new())
		OfficeMaterials.convert_scene(_root, layout)
	for type: String in _miss:
		print("LABMISS|%s|%d" % [type, _miss[type]])
	_report()
	return {"root": _root, "mats": _mats, "stations": _stations}


## The models of one row on a grid, each at its own orientation with its name, size and a +Z arrow.
func sheet(parent: Node3D, recipe: Dictionary, row: String) -> Dictionary:
	_start(parent, recipe)
	var models: Array = rows(recipe)[row]
	var sizes: Array[Vector3] = []
	var step := 1.0
	for key: String in models:
		sizes.append(_ext({"model": key}) * _packs[key.get_slice("/", 0)].unit)
		step = maxf(step, maxf(sizes[-1].x, sizes[-1].z) + 1.0)
	var red := StandardMaterial3D.new()
	red.albedo_color = Color.RED
	red.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in models.size():
		var at := Vector3(i % 3, 0.0, floori(i / 3.0)) * step
		_model(_root, {"model": models[i]}, at, 0.0, Vector3.ZERO)
		var label := Label3D.new()
		label.text = "%s\n%.2f x %.2f x %.2f m" % [models[i].get_slice("/", 1), sizes[i].x, sizes[i].y, sizes[i].z]
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		label.pixel_size = 0.005
		label.font_size = 40
		label.position = at + Vector3(0.0, sizes[i].y + 0.4, 0.0)
		_root.add_child(label)
		var arrow := BoxMesh.new()
		arrow.size = Vector3(0.06, 0.06, sizes[i].z / 2.0 + 0.6)
		arrow.material = red
		var mi := MeshInstance3D.new()
		mi.mesh = arrow
		mi.position = at + Vector3(0.0, 0.08, arrow.size.z / 2.0)
		_root.add_child(mi)
	return {"root": _root, "mats": {}, "stations": {}}


## The recipe's people under `parent`. Sitting and lying go through OfficePerson, held still; walking is
## a clip frozen on a bare body. `lifted` raises them by their `lift` (pack chairs sit at another height).
static func cast(parent: Node3D, recipe: Dictionary, spots: Dictionary, lifted: bool) -> void:
	for c: Dictionary in recipe.get("cast", []):
		var look: Dictionary = LookSystem.FOUNDER_LOOKS[int(c.look)]
		var at: Dictionary = (spots[c.kind][int(c.i)] as Dictionary).duplicate() if c.has("kind") else {
			"pos": _v3(c.pos), "face": float(c.face)}
		at.pos += Vector3.UP * float(c.get("lift", 0.0)) if lifted else Vector3.ZERO
		at.pose = c.pose
		if c.pose == "walk":
			var body := OfficeBody.build(look)
			parent.add_child(body)
			body.position = at.pos
			body.rotation.y = at.face
			var player := AnimationPlayer.new()
			body.add_child(player)
			player.root_node = NodePath("..")
			player.add_animation_library("ual1", load(OfficePerson.LIBS.ual1))
			player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
			player.play("ual1/Walk")
			player.seek(0.0, true)
			(body.get_node("%GeneralSkeleton") as Skeleton3D).force_update_all_bone_transforms()
			continue
		var person := OfficePerson.new()
		parent.add_child(person)
		person.setup(look)
		person.full_rate = true
		person.place(at, c.get("act", "idle"))
		person.k = 0.0


func _start(parent: Node3D, recipe: Dictionary) -> void:
	_recipe = recipe
	_packs = recipe.packs
	_root = Node3D.new()
	_root.name = "Built"
	parent.add_child(_root)


static func _v3(a: Array) -> Vector3:
	return Vector3(a[0], a[1], a[2])


## The entry of a prop: its type's (through `by`), with the item's own keys over it.
func _entry(it: Dictionary) -> Dictionary:
	var e: Dictionary = _recipe.types.get(it.type, {})
	if e.has("by"):
		e = e.get(str(int(it.args[int(e.by)])), {})
	e = e.merged(_recipe.get("items", {}).get(str(int(it.i)), {}), true)
	if e.has("taxi") and it.args.size() > 5 and it.args[5]:
		e.model = e.taxi
	return e


func _item(it: Dictionary) -> void:
	var e := _entry(it)
	if e.is_empty():
		_miss[it.type] = _miss.get(it.type, 0) + 1
		return
	_tag = "%s|%d" % [it.type, it.i]
	var pose: Variant = it.pose
	var box: Variant = it.bboxWorld
	# A mirrored prop's pose is already in world space; what the design placed inside it is not.
	var flip := -1.0 if pose != null and pose.mirrored else 1.0
	var pos := _v3(pose.pos) if pose != null else Vector3(
		(box.min[0] + box.max[0]) / 2.0, box.min[1], (box.min[2] + box.max[2]) / 2.0)
	pos.y += float(e.get("lift", 0.0))
	var yaw: float = (pose.yaw if pose != null else 0.0) + flip * float(e.get("yaw", 0.0))
	var size := _v3(box.size) if box != null else Vector3.ZERO
	if absf(sin(yaw)) > 0.7:
		size = Vector3(size.z, size.y, size.x)
	_desk = int(e.get("desk", (0 if it.args[4] else it.args[5]) if it.type == "station" else 0))
	if not e.has("parts"):
		_model(_root, e, pos, yaw, size)
		return
	var slot := Node3D.new()
	_root.add_child(slot)
	slot.position = pos
	slot.rotation.y = yaw
	for p: Dictionary in e.parts:
		var at := _v3(p.at)
		_model(slot, _recipe.types[p.type].merged(p, true) if p.has("type") else p,
			Vector3(at.x * flip, at.y, at.z), float(p.get("yaw", 0.0)) * flip, size)


func _op(op: Dictionary) -> void:
	var a: Array = op.get("a", [])
	match op.op:
		"B":
			_box(a[0], a[1], a[2], a[3], a[4], a[5], op.mat)
		"RB":
			var size := _v3(a)
			_prim(_cube(size), op.mat, Vector3(a[3], a[4], a[5]), _rot(op), size[size.max_axis_index()])
		"Cy":
			var cyl := CylinderMesh.new()
			cyl.top_radius = a[0]
			cyl.bottom_radius = a[0]
			cyl.height = a[1]
			_prim(cyl, op.mat, Vector3(a[2], a[3], a[4]), _rot(op), maxf(a[0] * 2.0, a[1]))
		"floor":
			var plane := PlaneMesh.new()
			plane.size = Vector2(op.x[1] - op.x[0], op.z[1] - op.z[0])
			_prim(plane, op.mat, Vector3((op.x[0] + op.x[1]) / 2.0, op.y, (op.z[0] + op.z[1]) / 2.0), Vector3.ZERO, 0.0)
		"model":
			_tag = "inline|-"
			_desk = int(op.get("desk", 0))
			_model(_root, op, _v3(op.at), float(op.get("yaw", 0.0)), Vector3.ZERO)
		"repeat":
			_tag = "inline|-"
			_desk = int(op.get("desk", 0))
			var ext := _ext(op)
			var module: float = ext.x * _scale(op, ext, Vector3.ZERO)
			var count := maxi(1, roundi((op.to - op.from) / module))
			var seen := _fits.size()
			for i in count:
				var p := _v3(op.at)
				var along: float = op.from + (i + 0.5) * (op.to - op.from) / count
				if op.axis == "x":
					p.x = along
				else:
					p.z = along
				_model(_root, op, p, float(op.get("yaw", 0.0)), Vector3.ZERO)
			# The modules of a run share one scale: one fit entry per run, not per module.
			_fits.resize(mini(_fits.size(), seen + 1))
		"wall", "glass":
			_wall(op)


## The design's wallX/wallZ and glassX/glassZ: pieces along an axis between the gaps, with their cap
## and base (wall) or rails and posts (glass).
func _wall(op: Dictionary) -> void:
	var c: float = op.at
	var h: float = op.h
	for s: Array in _segs(op.from, op.to, op.get("gaps", [])):
		if op.op == "wall":
			_strip(op.axis, s[0], s[1], 0.0, h, c - WALL_T / 2.0, c + WALL_T / 2.0, "wall")
			_strip(op.axis, s[0], s[1], h, h + 0.03, c - WALL_T / 2.0, c + WALL_T / 2.0, "cap", false)
			_strip(op.axis, s[0], s[1], 0.0, 0.08, c - WALL_T / 2.0 - 0.012, c + WALL_T / 2.0 + 0.012, "base", false)
			continue
		_strip(op.axis, s[0], s[1], 0.05, h, c - 0.012, c + 0.012, "glass", false)
		_strip(op.axis, s[0], s[1], 0.0, 0.05, c - 0.03, c + 0.03, "frame")
		_strip(op.axis, s[0], s[1], h, h + 0.05, c - 0.03, c + 0.03, "frame")
		var n := maxi(1, roundi((s[1] - s[0]) / 1.2))
		for i in n + 1:
			var p: float = s[0] + (s[1] - s[0]) * i / n
			_strip(op.axis, p - 0.025, p + 0.025, 0.0, h, c - 0.03, c + 0.03, "frame")


static func _segs(a0: float, a1: float, gaps: Array) -> Array:
	var out := []
	var cur := a0
	for g: Array in gaps:
		out.append([cur, g[0]])
		cur = g[1]
	out.append([cur, a1])
	return out.filter(func(s: Array) -> bool: return s[1] - s[0] > 0.01)


## A box running from a0 to a1 along `axis` and across c0..c1.
func _strip(axis: String, a0: float, a1: float, y0: float, y1: float, c0: float, c1: float, mat: String,
		shadow := true) -> void:
	if axis == "x":
		_box(a0, a1, y0, y1, c0, c1, mat, shadow)
	else:
		_box(c0, c1, y0, y1, a0, a1, mat, shadow)


func _box(x0: float, x1: float, y0: float, y1: float, z0: float, z1: float, mat: String, shadow := true) -> void:
	var size := Vector3(maxf(0.001, x1 - x0), maxf(0.001, y1 - y0), maxf(0.001, z1 - z0))
	_prim(_cube(size), mat, Vector3(x0 + x1, y0 + y1, z0 + z1) / 2.0, Vector3.ZERO,
		size[size.max_axis_index()] if shadow else 0.0)


static func _cube(size: Vector3) -> BoxMesh:
	var cube := BoxMesh.new()
	cube.size = size
	return cube


static func _rot(op: Dictionary) -> Vector3:
	return Vector3(op.get("rx", 0.0), op.get("ry", 0.0), op.get("rz", 0.0))


## A primitive in palette colour `mat`; `big`, its largest dimension, decides whether it casts a shadow.
func _prim(mesh: PrimitiveMesh, mat: String, at: Vector3, rot: Vector3, big: float) -> void:
	mesh.material = _paint(mat)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	if big < SMALL:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_root.add_child(mi)
	mi.position = at
	mi.rotation = rot


func _paint(key: String) -> StandardMaterial3D:
	if not _paints.has(key):
		var m := StandardMaterial3D.new()
		m.resource_name = key
		if OfficeLighting.STREET.has(key):
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			m.albedo_color = OfficeLighting.STREET[key][1]
			_mats.get_or_add(key, []).append(m)
		else:
			m.albedo_color = _palette[key]
		if key == "glass":
			m.albedo_color.a = 0.18
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			m.roughness = 0.05
		_paints[key] = m
	return _paints[key]


## The model `key` from its pack: loaded once, kept under the holder, its box in `_boxes`.
func _template(key: String) -> Node3D:
	if not _templates.has(key):
		var pack: Dictionary = _packs[key.get_slice("/", 0)]
		var tpl := load_node(ProjectSettings.globalize_path(
			PACKS + "%s/%s.%s" % [pack.dir, key.get_slice("/", 1), pack.ext]))
		# The office sky gives the lab no reflection, so any metallic share draws dark (the Nature Kit, exported at
		# metallic 1, drew its trees black); the packs are flat-colour art.
		for mi: MeshInstance3D in tpl.find_children("*", "MeshInstance3D", true, false):
			for i in mi.mesh.get_surface_count():
				var m := mi.mesh.surface_get_material(i) as BaseMaterial3D
				if m:
					m.metallic = 0.0
		_holder.add_child(tpl)
		_templates[key] = tpl
		_boxes[key] = extent(tpl)
	return _templates[key]


## The model's extent after its front is turned to +Z.
func _ext(e: Dictionary) -> Vector3:
	_template(e.model)
	return (Basis(Vector3.UP, e.get("front", 0.0)) * _boxes[e.model].size).abs()


## Scale for `e.fit` on a model of extent `ext`; "bbox" is the prop's box `size` seen from the model.
func _scale(e: Dictionary, ext: Vector3, size: Vector3) -> float:
	var s: float = _packs[e.model.get_slice("/", 0)].unit
	var f: Dictionary = e.get("fit", {})
	for k: String in f:
		match k:
			"h":
				s = (size.y if f[k] is String else float(f[k])) / ext.y
			"w":
				s = (size.x if f[k] is String else float(f[k])) / ext.x
			"d":
				s = (size.z if f[k] is String else float(f[k])) / ext.z
			"len":
				s = (maxf(size.x, size.z) if f[k] is String else float(f[k])) / maxf(ext.x, ext.z)
			"fp":
				var fp: Array = [size.x, size.z] if f[k] is String else f[k]
				s = minf(fp[0] / ext.x, fp[1] / ext.z)
			_:
				push_error("[Lab] unknown fit key: " + k)
	return s


## Model `e.model` fitted by `e` into `parent`: its bottom centre at `pos`, facing `yaw`.
func _model(parent: Node3D, e: Dictionary, pos: Vector3, yaw: float, size: Vector3) -> void:
	var ext := _ext(e)
	var s := _scale(e, ext, size)
	var inst: Node3D = _template(e.model).duplicate()
	var a: AABB = _boxes[e.model]
	var holder := Node3D.new()
	parent.add_child(holder)
	holder.position = pos
	holder.rotation.y = yaw
	holder.add_child(inst)
	inst.basis = Basis(Vector3.UP, e.get("front", 0.0)).scaled(Vector3.ONE * s)
	inst.position = -(inst.basis * Vector3(a.get_center().x, a.position.y, a.get_center().z))
	var meshes := inst.find_children("*", "MeshInstance3D", true, false)
	if ext[ext.max_axis_index()] * s < SMALL:
		for mi: MeshInstance3D in meshes:
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if e.has("fit"):
		_fits.append([_tag, e.model, s])
	if e.has("emit"):
		_emit(inst, e.emit)


## A role-tagged part: one emissive toon material per role (per desk for a station), so the light
## switches every part of it together. Stations get their lamp and screen pair and where they glow from.
func _emit(part: Node3D, role: String) -> void:
	var station := role == "screen" or role == "lamp"
	var key := "%d/%s" % [_desk, role] if station else role
	var meshes := part.find_children("*", "MeshInstance3D", true, false)
	if not _glow.has(key):
		var src := (meshes[0] as MeshInstance3D).mesh.surface_get_material(0) as BaseMaterial3D
		var m := ShaderMaterial.new()
		m.shader = OfficeMaterials.TOON
		if src:
			m.set_shader_parameter("albedo", src.albedo_color)
			m.set_shader_parameter("albedo_texture", src.albedo_texture)
		m.set_shader_parameter("emission", GLOW[role])
		_glow[key] = m
		if station:
			var at := extent(part).get_center()
			# _apply_stations drives both materials of every desk, so the one a desk lacks stays a placeholder.
			var st: Dictionary = _stations.get_or_add(_desk, {
				"lamp": ShaderMaterial.new(), "screen": ShaderMaterial.new(), "lamp_at": at, "screen_at": at})
			st[role] = m
			st[role + "_at"] = at
		else:
			_mats.get_or_add(DRIVEN[role], []).append(m)
	for mi: MeshInstance3D in meshes:
		mi.material_override = _glow[key]


func _report() -> void:
	var by_pack := {}
	for f: Array in _fits:
		by_pack.get_or_add(f[1].get_slice("/", 0), []).append(f[2])
	var median := {}
	for pack: String in by_pack:
		var v: Array = by_pack[pack]
		v.sort()
		median[pack] = v[floori(v.size() / 2.0)]
		print("LABPACK|%s|median=%.4f|min=%.4f|max=%.4f|n=%d|unit=%s" % [
			pack, median[pack], v[0], v[-1], v.size(), _packs[pack].unit])
	for f: Array in _fits:
		var m: float = median[f[1].get_slice("/", 0)]
		print("LABFIT|%s|%s|%.4f|%s" % [f[0], f[1], f[2], "outlier" if absf(f[2] / m - 1.0) > 0.2 else "ok"])
