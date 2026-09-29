extends SceneTree

# Bakes where the office people can walk: art/office3d/<id>_nav.tres from the office GLB, keeping
# the floor reachable from the founder's desk. Where a spot's path in the design (its chain) climbs
# more than a step or squeezes through a gap narrower than a person, the bake cannot connect the
# floors on either side: each stretch that joins two floors becomes a link, saved on the mesh as
# meta "links" ([{a, b, path}]) for NavigationLink3D, walked along `path`. Headless, once per export:
#
#   godot --headless --path . -s res://tools/office3d/bake_nav.gd [-- <office id> ...]
#
# Exits non-zero when the bake is empty or a spot's way in (its chain's first point, outside the
# chair or counter) lies off the walkable floor.

const OFFICES := ["home", "ishani", "plaza", "loft", "meet"]
## One cell is 5 cm: the agent's 0.28 m radius and 0.2 m step survive Recast's rounding to cells.
## The agent is the people's own (OfficePerson).
const CELL := 0.05
const AGENT_CLIMB := 0.2
const AGENT_SLOPE := 40.0
## How far above the highest spot and below the lowest the bake looks, metres.
const HEADROOM := 2.5
const FOOTROOM := 0.6
## Floor pieces smaller than this that hold no one's way in (a tribune row, a stair landing) are
## left out: the design's paths cross them as part of a link or a spot's own last metres.
const MIN_PIECE := 30
## Seats reached by their own chain from the floor (the tribune), not by the walkable mesh.
const CHAIN_SEATS := ["trib", "present"]
## A spot's way in may sit this far (horizontally) off the walkable floor; farther, the person
## walks the spot's own chain from the floor to it.
const APPROACH_TOL := 0.3

var _failed := false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var ids: Array = OS.get_cmdline_user_args()
	for id: String in (ids if not ids.is_empty() else OFFICES):
		await _bake(id)
	quit(1 if _failed else 0)


func _bake(id: String) -> void:
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/office3d/%s.json" % id))
	var scene: Node3D = (load("res://art/office3d/%s.glb" % id) as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	var skip := {}
	for p: Dictionary in raw.elevPanels:
		skip[p.node] = true
	for h: String in raw.hidden:
		skip[h] = true
	var lo := INF
	var hi := -INF
	for kind: String in raw.spots:
		for s: Dictionary in raw.spots[kind]:
			if s.zone != "street":
				lo = minf(lo, s.pos[1])
				hi = maxf(hi, s.pos[1])
	var bounds: Dictionary = raw.bounds
	var box := AABB(Vector3(bounds.min[0], lo - FOOTROOM, bounds.min[2]),
		Vector3(bounds.max[0] - bounds.min[0], hi - lo + FOOTROOM + HEADROOM, bounds.max[2] - bounds.min[2]))

	var src := NavigationMeshSourceGeometryData3D.new()
	var faces := 0
	for mi: MeshInstance3D in scene.find_children("*", "MeshInstance3D", true, false):
		if skip.has(String(mi.name)) or not mi.is_visible_in_tree():
			continue
		# Glass walls stop people too; the design leaves their doorways open and swings the doors wide.
		src.add_mesh(mi.mesh, mi.global_transform)
		faces += 1
	var nm := NavigationMesh.new()
	nm.cell_size = CELL
	nm.cell_height = CELL
	nm.agent_radius = OfficePerson.RADIUS
	nm.agent_height = OfficePerson.BODY_HEIGHT
	nm.agent_max_climb = AGENT_CLIMB
	nm.agent_max_slope = AGENT_SLOPE
	nm.filter_baking_aabb = box
	NavigationServer3D.bake_from_source_geometry_data(nm, src)
	scene.queue_free()
	if nm.get_polygon_count() == 0:
		_fail("%s: empty bake (%d source surfaces)" % [id, faces])
		return

	var comp := _components(nm)
	var links := _links(nm, raw, comp)
	var kept := _reachable(nm, _v3(raw.spots.desk[0].chain[0]), links, comp)
	var out: NavigationMesh = nm.duplicate()
	out.clear_polygons()
	for p in kept:
		out.add_polygon(nm.get_polygon(p))
	out.set_meta("links", links)
	var tails := 0
	var misses := 0
	for kind: String in raw.spots:
		for i in raw.spots[kind].size():
			# The home's street is outside: the founder leaves it through the stairwell.
			if raw.spots[kind][i].zone == "street":
				continue
			var pts := _path_of(raw.spots[kind][i])
			if _off_mesh(out, _way_in(pts)) <= APPROACH_TOL:
				continue
			# Off the floor: the chain must come back onto it before it ends.
			if pts.slice(1).any(func(p: Vector3) -> bool: return _off_mesh(out, p) <= APPROACH_TOL):
				tails += 1
			else:
				misses += 1
				_fail("%s: %s[%d] never reaches the floor" % [id, kind, i])
	if misses == 0:
		ResourceSaver.save(out, "res://art/office3d/%s_nav.tres" % id)
	print("%s: %d polygons kept of %d, %d links, %d spots reached by their own chain, %d misses" % [id, kept.size(),
		nm.get_polygon_count(), links.size(), tails, misses])


## A spot's design path: where it stands, then its chain out to the corridor. Some chains repeat
## a point; a path keeps it once.
func _path_of(spot: Dictionary) -> Array:
	var out := [_v3(spot.pos)]
	for p: Array in spot.chain:
		if _v3(p).distance_to(out[-1]) > 0.01:
			out.append(_v3(p))
	return out


## Where a spot's path leaves the floor for its own last metres: its second point, if any.
func _way_in(pts: Array) -> Vector3:
	return pts[mini(1, pts.size() - 1)]


## Stretches of the design's paths between two kept parts of the floor the bake left apart: a
## stair, a step or a doorway narrower than a person, with whatever small pieces lie between.
func _links(nm: NavigationMesh, raw: Dictionary, comp: PackedInt32Array) -> Array:
	var kept := _kept_pieces(nm, raw, comp)
	var out := []
	var seen := {}
	for kind: String in raw.spots:
		for spot: Dictionary in raw.spots[kind]:
			var pts := _path_of(spot)
			var last := -1
			var last_c := -1
			for i in pts.size():
				if _off_mesh(nm, pts[i]) > APPROACH_TOL:
					continue
				var c: int = comp[_nearest_polygon(nm, pts[i])]
				if not kept.has(c):
					continue
				if last >= 0 and c != last_c:
					var key := "%d-%d" % [mini(c, last_c), maxi(c, last_c)]
					if not seen.has(key):
						seen[key] = true
						out.append({"a": pts[last], "b": pts[i], "path": PackedVector3Array(pts.slice(last, i + 1))})
				last = i
				last_c = c
	return out


## Components worth walking: big ones, and any holding a way in the people walk to.
func _kept_pieces(nm: NavigationMesh, raw: Dictionary, comp: PackedInt32Array) -> Dictionary:
	var size := {}
	for p in nm.get_polygon_count():
		size[comp[p]] = int(size.get(comp[p], 0)) + 1
	var kept := {}
	for c: int in size:
		if size[c] >= MIN_PIECE:
			kept[c] = true
	for kind: String in raw.spots:
		if kind in CHAIN_SEATS:
			continue
		for spot: Dictionary in raw.spots[kind]:
			var at := _way_in(_path_of(spot))
			if _off_mesh(nm, at) <= APPROACH_TOL:
				kept[comp[_nearest_polygon(nm, at)]] = true
	return kept


## Polygon -> connected component id (polygons sharing a vertex are connected).
func _components(nm: NavigationMesh) -> PackedInt32Array:
	var by_vertex := {}
	for p in nm.get_polygon_count():
		for v: int in nm.get_polygon(p):
			if not by_vertex.has(v):
				by_vertex[v] = []
			by_vertex[v].append(p)
	var comp := PackedInt32Array()
	comp.resize(nm.get_polygon_count())
	comp.fill(-1)
	var next := 0
	for start in nm.get_polygon_count():
		if comp[start] >= 0:
			continue
		comp[start] = next
		var todo := [start]
		while not todo.is_empty():
			var p: int = todo.pop_back()
			for v: int in nm.get_polygon(p):
				for q: int in by_vertex[v]:
					if comp[q] < 0:
						comp[q] = next
						todo.append(q)
		next += 1
	return comp


## Polygons in the component under `from` or joined to it by links.
func _reachable(nm: NavigationMesh, from: Vector3, links: Array, comp: PackedInt32Array) -> Array:
	var keep := {comp[_nearest_polygon(nm, from)]: true}
	var grew := true
	while grew:
		grew = false
		for l: Dictionary in links:
			var ca: int = comp[_nearest_polygon(nm, l.a)]
			var cb: int = comp[_nearest_polygon(nm, l.b)]
			if keep.has(ca) != keep.has(cb):
				keep[ca] = true
				keep[cb] = true
				grew = true
	var out := []
	for p in nm.get_polygon_count():
		if keep.has(comp[p]):
			out.append(p)
	return out


func _nearest_polygon(nm: NavigationMesh, at: Vector3) -> int:
	var best := 0
	var best_d := INF
	for p in nm.get_polygon_count():
		var d := _polygon_distance(nm, p, at)
		if d < best_d:
			best_d = d
			best = p
	return best


## Horizontal distance from `at` to the nearest polygon at its level (OfficePerson.FLOOR_RISE).
func _off_mesh(nm: NavigationMesh, at: Vector3) -> float:
	return _polygon_distance(nm, _nearest_polygon(nm, at), at)


func _polygon_distance(nm: NavigationMesh, p: int, at: Vector3) -> float:
	var poly := nm.get_polygon(p)
	var verts := nm.vertices
	var pts := PackedVector2Array()
	var y := 0.0
	for v: int in poly:
		pts.append(Vector2(verts[v].x, verts[v].z))
		y += verts[v].y
	y /= poly.size()
	if absf(y - at.y) > OfficePerson.FLOOR_RISE:
		return INF
	var q := Vector2(at.x, at.z)
	if Geometry2D.is_point_in_polygon(q, pts):
		return 0.0
	var d := INF
	for i in pts.size():
		d = minf(d, q.distance_to(Geometry2D.get_closest_point_to_segment(q, pts[i], pts[(i + 1) % pts.size()])))
	return d


func _v3(a: Array) -> Vector3:
	return Vector3(a[0], a[1], a[2])


func _fail(msg: String) -> void:
	_failed = true
	print("FAIL " + msg)
