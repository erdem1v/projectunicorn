class_name MeetingCast
extends Node3D

# The people of a meeting in the room on the investors' tower (OfficeView's `meet` layout): the
# other side sat at the table from the start, lead in the middle, and the founder, who walks in
# from the lift and sits across from them. The meeting says whom each one looks at, how they sit,
# who speaks and what they do; this moves the bodies and the pen on the table, and lights the
# founder's place. The people move at 1× whatever the
# clock does: the meeting holds it, stopped, and the office view runs through a paused tree.
#
# People by index: 0 is the founder, 1.. the other side in the order staged.

signal founder_seated    # the founder sat down at the table
signal founder_out       # the founder went out through the lift

## The camera over the table: this much closer than the room's fit.
const TABLE_ZOOM := 1.35
## A gesture's length when the meeting gives none, seconds.
const GESTURE_S := 1.6
## The pen falls from the note-taker's hand to the table over this long (seconds), lifting this
## far on the way.
const PEN_DROP_S := 0.3
const PEN_ARC := 0.03
## The one who sits at the pen's place (guest seat 2) and takes notes on the table's pad.
const PEN_PERSON := 3
## A post's arms, each a seated act of the same name.
const POST_ARMS := ["table", "rest"]

var _layout: OfficeLayout
var _view: Node
var _people: Array[OfficePerson] = []
var _posts: Array[String] = []    # each one's seated act when not speaking
var _walk_in := false             # the founder walks in once the room's floor is on the map
var _seated_told := false
var _out_told := true
var _pen: Node3D
var _pen_from: Transform3D        # the note-taker's pen as it leaves the hand
var _pen_dropped: Transform3D     # on the table
var _pen_t := -1.0                # seconds into the fall, -1 when not falling


## Takes the loaded layout; anything but the meeting room clears the table.
func set_layout(layout: OfficeLayout, view: Node) -> void:
	_layout = layout
	_view = view
	_clear()
	_pen = null
	if layout.id != "meet":
		return
	_pen = view.find_child("pen", true, false)
	_pen_dropped = _pen.get_parent().global_transform \
		* Transform3D(Basis.from_euler(layout.pen.rot, EULER_ORDER_XYZ), layout.pen.pos)


## Seats `looks` (the other side, lead first) at the table and puts the founder at the lift, or
## in their chair when `seated`. Frames the table.
func stage(looks: Array, founder_look: Dictionary, seated := false) -> void:
	_clear()
	var founder := _person(founder_look)
	founder.place(_layout.spots.desk[0] if seated else _layout.spots.out[0], "idle")
	var seats: Array = _layout.spots.guest
	for i in mini(looks.size(), seats.size()):
		_person(looks[i]).place(seats[i], "idle")
	_seated_told = seated
	_out_told = true
	_pen.global_transform = _pen_dropped
	_pen.visible = true
	var cam: OfficeCamera = _view.camera
	cam.focus(_layout.table, cam.fit_zoom * TABLE_ZOOM, 0.0)


## The founder walks from the lift to their chair; founder_seated says they sat down.
func walk_in() -> void:
	_walk_in = true
	_seated_told = false


## The founder gets up and goes out through the lift; founder_out says they are through.
func walk_out() -> void:
	_walk_in = false
	_out_told = false
	_people[0].look_at = null
	_people[0].go_to(_layout.spots.out[0], "idle")


## `who` turns their head to `at` (a person's index), or ahead when `at` is -1.
func look(who: int, at: int) -> void:
	_people[who].look_at = _people[at] if at >= 0 else null


## How `who` sits: arms on the table or in the lap ("table", "rest"), writing (the pen seat's own
## pad), a lean and a head tilt (radians, forward and down).
func post(who: int, p: Dictionary) -> void:
	var person := _people[who]
	var arms: String = p.get("arms", "")
	_posts[who] = "write" if p.get("write", false) else (arms if arms in POST_ARMS else "idle")
	person.lean_bias = p.get("lean", 0.0)
	person.head_bias = p.get("head", 0.0)
	if person.act != "talk":
		person.go_to(person.spot, _posts[who])
	if who == PEN_PERSON:
		_pen.visible = _posts[who] != "write"


## `who` speaks (the seated talk), everyone else keeps their post; -1 hushes the table.
func speak(who: int) -> void:
	for i in _people.size():
		var person := _people[i]
		if not person.is_walking():
			person.go_to(person.spot, "talk" if i == who else _posts[i])


## A gesture of `name` for `seconds` (OfficePerson.gesture). "pen" also puts the pen down: the
## note-taker stops writing, leans back and the pen falls from the hand to the table.
func gesture(who: int, gesture_name: String, seconds := GESTURE_S) -> void:
	var person := _people[who]
	person.gesture(gesture_name, seconds)
	if gesture_name == "pen" and _posts[who] == "write":
		if who == PEN_PERSON:
			_pen_from = person.prop("pen").global_transform
			_pen.global_transform = _pen_from
			_pen_t = 0.0
		post(who, {"arms": "table", "lean": -0.24})


func count() -> int:
	return _people.size()


func _process(delta: float) -> void:
	if _people.is_empty():
		return
	var founder := _people[0]
	var from := OfficePerson.way_in(_layout.spots.out[0])
	if _walk_in and OfficePerson.floor_ready(_view.nav_region, from, OfficePerson.way_in(_layout.spots.desk[0])):
		_walk_in = false
		founder.go_to(_layout.spots.desk[0], _posts[0])
	var at_table := founder.phase == OfficePerson.Phase.SEATED and is_same(founder.spot, _layout.spots.desk[0])
	if at_table and not _seated_told:
		_seated_told = true
		founder_seated.emit()
	if not _out_told and not founder.visible:
		_out_told = true
		founder_out.emit()
	var lighting: OfficeLighting = _view.lighting
	lighting.set_station_state(0, at_table)
	lighting.founder_at_desk = at_table
	lighting.anyone_in = true
	if _pen_t >= 0.0:
		_pen_t = minf(_pen_t + delta, PEN_DROP_S)
		var e := pow(_pen_t / PEN_DROP_S, 2.0)
		var t := _pen_from.interpolate_with(_pen_dropped, e)
		t.origin.y += sin(_pen_t / PEN_DROP_S * PI) * PEN_ARC
		_pen.global_transform = t
		if _pen_t == PEN_DROP_S:
			_pen_t = -1.0


func _person(look: Dictionary) -> OfficePerson:
	var p := OfficePerson.new()
	add_child(p)
	p.setup(look)
	p.full_rate = true
	_people.append(p)
	_posts.append("idle")
	return p


func _clear() -> void:
	for p: OfficePerson in _people:
		p.queue_free()
	_people.clear()
	_posts.clear()
	_walk_in = false
	_pen_t = -1.0
