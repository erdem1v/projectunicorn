class_name OfficeVenue
extends RefCounted

# The office's shared places and who holds them: every break and meeting spot is one person's at a
# time, and the coffee counter (a kettle at home) and the restrooms keep a line. A line's places run
# back from the first service spot's way in, QUEUE_STEP apart, only where the floor is; the one at
# its head takes the next spot that frees. OfficePeople asks and releases.

## Where a person waits in a line: this far out from the one ahead.
const QUEUE_STEP := 0.75                   # [WORKING]
const QUEUE_MAX := 3                       # [WORKING] people in a line; one more puts off the break
const QUEUE_FLOOR := 0.15                  # a place further than this from the floor is skipped

var _held := {}     # spot position -> the OfficeActor who holds it or is on the way
var _lines := {}    # kind -> Array[OfficeActor], head first
var _places := {}   # kind -> Array[Dictionary]: the line's places as spots


## `lines`: kind -> the service spots a line forms at (none when empty).
func _init(lines: Dictionary, map: RID) -> void:
	for kind: String in lines:
		if not (lines[kind] as Array).is_empty():
			_lines[kind] = []
			_places[kind] = _line_places(lines[kind][0], map)


## A free spot of `spots` for `a`, now held by them, which ends any wait in a line; {} when all
## are held.
func take(a: OfficeActor, spots: Array) -> Dictionary:
	for s: Dictionary in spots:
		if not _held.has(s.pos):
			_held[s.pos] = a
			for line: Array in _lines.values():
				line.erase(a)
			return s
	return {}


func is_free(s: Dictionary) -> bool:
	return not _held.has(s.pos)


## Lets go of whatever `a` holds or waits for.
func release(a: OfficeActor) -> void:
	for at: Vector3 in _held.keys():
		if _held[at] == a:
			_held.erase(at)
	for line: Array in _lines.values():
		line.erase(a)


func has_line(kind: String) -> bool:
	return _lines.has(kind)


## `a` joins `kind`'s line: their place in it, or {} when it is full.
func join(a: OfficeActor, kind: String) -> Dictionary:
	var line: Array = _lines[kind]
	if line.size() >= (_places[kind] as Array).size():
		return {}
	line.append(a)
	return _places[kind][line.size() - 1]


## The one at the head of `kind`'s line, or null.
func head(kind: String) -> OfficeActor:
	return _lines[kind][0] if not (_lines[kind] as Array).is_empty() else null


## Where each one in `kind`'s line stands now, head first.
func places(kind: String) -> Array:
	return (_places[kind] as Array).slice(0, (_lines[kind] as Array).size())


func line(kind: String) -> Array:
	return _lines[kind]


## The line's places behind `first`: back along its way in, facing it.
static func _line_places(first: Dictionary, map: RID) -> Array:
	var way := OfficePerson.way_in(first)
	var back := Vector3(way.x - first.pos.x, 0.0, way.z - first.pos.z).normalized()
	if back == Vector3.ZERO:
		back = Vector3(-sin(first.face), 0.0, -cos(first.face))
	var out := []
	var at := way
	for i in QUEUE_MAX * 3:
		at += back * QUEUE_STEP
		if OfficePerson.floor_near(map, at, QUEUE_FLOOR) == Vector3.INF:
			continue
		out.append({"pos": Vector3(at.x, way.y, at.z), "face": atan2(-back.x, -back.z), "pose": "stand",
			"chain": PackedVector3Array(), "zone": first.zone})
		if out.size() == QUEUE_MAX:
			break
	return out
