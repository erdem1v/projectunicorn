class_name OfficeLayout
extends RefCounted

# One office's side JSON (art/office3d/<id>.json, written by tools/office3d/export_office.js):
# where people sit and walk, which nodes light up when, and what the camera frames. The GLB next
# to it carries the geometry; nodes are bound by the names listed here. Two layouts are no office:
# the city map and the meeting room on the investors' tower (`meet`).

## Layouts the staff never work in.
const AWAY := ["city", "meet"]

var id: String
var bounds: AABB                  ## the design's fitView box
var fog: Dictionary               ## {near, far}, empty when the office has no fog
var max_n: int                    ## desks for employees
## kind -> Array[Dictionary] {pos: Vector3, face: float, pose: String, chain: PackedVector3Array,
## zone: String}. desk[0] is the founder's, desk[i] employee desk i.
var spots: Dictionary
## Each meeting room's seats: the spots meet_<room>, or an office's one room of kind meet.
var meet_rooms: Array[Array]
var elev_near: AABB               ## lift proximity box (y spans everything), zero-size when none
var elev_panels: Array[Dictionary]  ## {node, p0: float, d: float, rot: bool, ax: String}
var panes: Array[Dictionary]      ## {node, on: float, off: float, all_night: bool}, game minutes
var hidden: PackedStringArray     ## nodes glTF cannot mark invisible
var glows: Dictionary             ## pool|street|sconce -> Array[Dictionary] {pos: Vector3, size: Vector2, normal: Vector3}
var map_hits: Array[Dictionary]   ## city: {id, office, box: AABB, anchor: Vector3}
var meet_hit: Dictionary          ## city: the meetings' tower {box: AABB, anchor: Vector3}, else empty
## meet: the table's middle, and where the pen lies once put down {pos: Vector3, rot: Vector3
## (Euler XYZ)}.
var table: Vector3
var pen: Dictionary
var lanes: Array[Dictionary]      ## city cars: {a: Vector2, b: Vector2, v, ph, ry, car_node}
var thumb_targets: Dictionary     ## {target: Vector3 or null, zoom}, empty in the city
var materials: PackedStringArray  ## the named materials in the GLB


static func load(office_id: String) -> OfficeLayout:
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/office3d/%s.json" % office_id))
	var l := OfficeLayout.new()
	l.id = raw.id
	l.bounds = _box(raw.bounds)
	l.fog = raw.fog if raw.fog != null else {}
	l.max_n = int(raw.maxN)
	for kind: String in raw.spots:
		var list: Array[Dictionary] = []
		for s: Dictionary in raw.spots[kind]:
			var chain := PackedVector3Array()
			for p: Array in s.chain:
				chain.append(_v3(p))
			list.append({"pos": _v3(s.pos), "face": float(s.face), "pose": s.pose, "chain": chain, "zone": s.zone})
		l.spots[kind] = list
	for room: String in raw.meetRooms:
		l.meet_rooms.append(l.spots["meet_" + room])
	if l.spots.has("meet"):
		l.meet_rooms.append(l.spots.meet)
	if raw.elevNear != null:
		var half := _v3(raw.elevNear.half)
		l.elev_near = AABB(_v3(raw.elevNear.center) - half, half * 2.0)
	for e: Dictionary in raw.elevPanels:
		l.elev_panels.append({"node": e.node, "p0": float(e.p0), "d": float(e.d), "rot": e.rot, "ax": e.ax})
	for p: Dictionary in raw.panes:
		l.panes.append({"node": p.node, "on": float(p.sched.on), "off": float(p.sched.off),
			"all_night": p.sched.allNight})
	l.hidden = PackedStringArray(raw.hidden)
	for kind: String in raw.glows:
		var list: Array[Dictionary] = []
		for g: Dictionary in raw.glows[kind]:
			list.append({"pos": _v3(g.pos), "size": Vector2(g.size[0], g.size[1]), "normal": _v3(g.normal)})
		l.glows[kind] = list
	for h: Dictionary in raw.mapHits:
		l.map_hits.append({"id": h.id, "office": h.office, "box": _box(h.box), "anchor": _v3(h.anchor)})
	if raw.get("meetHit") != null:
		l.meet_hit = {"box": _box(raw.meetHit.box), "anchor": _v3(raw.meetHit.anchor)}
	if raw.get("table") != null:
		l.table = _v3(raw.table)
	if raw.get("pen") != null:
		l.pen = {"pos": _v3(raw.pen.pos), "rot": _v3(raw.pen.rot)}
	for c: Dictionary in raw.lanes:
		l.lanes.append({"a": Vector2(c.a[0], c.a[1]), "b": Vector2(c.b[0], c.b[1]), "v": float(c.v),
			"ph": float(c.ph), "ry": float(c.ry), "car_node": c.carNode})
	if raw.thumbTargets != null:
		var t: Dictionary = raw.thumbTargets
		l.thumb_targets = {"target": _v3(t.target) if t.target != null else null, "zoom": float(t.zoom)}
	l.materials = PackedStringArray(raw.materials)
	return l


## Somewhere the staff work: not the map, not the meeting room.
func staffed() -> bool:
	return id not in AWAY


static func _v3(a: Array) -> Vector3:
	return Vector3(a[0], a[1], a[2])


static func _box(b: Dictionary) -> AABB:
	var lo := _v3(b.min)
	return AABB(lo, _v3(b.max) - lo)
