class_name OfficeActor
extends OfficePerson

# One of the office's staff: an OfficePerson's body and walk, plus who they are, where they sit,
# the icon over their head that says what they are doing (office-sim-v2.js ICON) and the floor
# rings. OfficePeople decides where they go and when; this node carries the person's day.

## Head icons by what the person is doing; a status missing here shows none.
const ICONS := {
	"code": preload("res://assets/art/office/icons/code.svg"),
	"test": preload("res://assets/art/office/icons/test.svg"),
	"research": preload("res://assets/art/office/icons/research.svg"),
	"plan": preload("res://assets/art/office/icons/research.svg"),
	"design": preload("res://assets/art/office/icons/design.svg"),
	"phone": preload("res://assets/art/office/icons/phone.svg"),
	"coffee": preload("res://assets/art/office/icons/coffee.svg"),
	"wc": preload("res://assets/art/office/icons/wc.svg"),
	"visit": preload("res://assets/art/office/icons/meeting.svg"),
	"meeting": preload("res://assets/art/office/icons/meeting.svg"),
	"food": preload("res://assets/art/office/icons/food.svg"),
}
## The design's icon sprite tint, and its opacity while walking: 3D scene colours, not UI tokens.
const ICON_TINT := Color("#d2d2d2")
const ICON_DIM := 0.6
## A call waiting blinks the phone over the head: its opacity swings down to this, this fast.
const CALL_BLINK := 0.35
const CALL_BLINK_RATE := 6.0
const ICON_PRIORITY := 10          # the design draws icons after everything else
const HEAD_ABOVE := 0.28           # an icon's floor above the head bone
## Floor rings (inner and outer radius) and how far above the floor each lies.
const FOUNDER_RING_SIZE := Vector2(0.42, 0.56)
const FOUNDER_RING_LIFT := 0.03
const SELECT_RING_SIZE := Vector2(0.6, 0.7)
const SELECT_RING_LIFT := 0.035
const RING_SEGMENTS := 40
## What a click or hover finds: a standing or seated body, or one lying along a bed (head behind
## the root, feet ahead).
const HIT_BOX := AABB(Vector3(-0.3, 0.0, -0.3), Vector3(0.6, 1.7, 0.6))
const LYING_BOX := AABB(Vector3(-0.35, -0.1, -0.75), Vector3(0.7, 0.5, 1.8))

static var _ring_looks := {}   # [radii, colour] -> [mesh, material]

var character: Character
var founder := false
## Set by OfficePeople: where this person works ({} = no place in this office), the desk whose
## lamp is theirs (-1 = none), what their job is at the desk, and what they are doing now.
var seat := {}
var desk_id := -1
var work := ""
var status := ""
var selected := false
var calling := false   # a call waits for them (MeetingInvite): the phone blinks over their head
var ghost := false     # gone from the company: walking out, then removed
## Today's draws, {day, late, early}: game minutes after the start they are due in and before
## their end they are gone. How the day is going: placed at the desk at the morning cut (the walk
## in did not fit), left seated for the night's cut (the walk out did not fit), the errand that
## takes them from the desk (a break's kind, "eat" or "meeting"; "" = none), still in its line,
## and the day they last had lunch.
var plan := {}
var cut_in := false
var cut := false
var errand := ""
var queued := false
var lunch_day := -1
var leave_at := -1.0   # the ambient second they set off for their turn at the door, -1 = none yet
## Ambient seconds: to the next break, left on the errand, to the next small idle at the desk and
## left of it.
var trip_in := 0.0
var stay := 0.0
var idle_in := 0.0
var idle_left := 0.0
var rng := RandomNumberGenerator.new()
## Metres from the entry to the seat, and from the seat to the bed at home.
var in_len := 0.0
var bed_len := 0.0

var _head: BoneAttachment3D
var _icon: Sprite3D
var _founder_ring: MeshInstance3D
var _select_ring: MeshInstance3D


## Builds `c`'s body and walk from their look, and the icon and rings.
func setup_actor(c: Character) -> void:
	character = c
	founder = c.category == "founder"
	rng.seed = SalesConstants.mix(c.id, SalesConstants.SALT_ACTOR)
	setup(c.look)
	_head = BoneAttachment3D.new()
	_head.bone_name = "Head"
	_skel.add_child(_head)
	_icon = Sprite3D.new()
	_icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_icon.no_depth_test = true
	_icon.render_priority = ICON_PRIORITY
	_icon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_icon.pixel_size = 1.0 / (ICONS.code as Texture2D).get_height()
	add_child(_icon)
	_founder_ring = _ring(FOUNDER_RING_SIZE, OfficeConstants.FOUNDER_RING, FOUNDER_RING_LIFT)
	_select_ring = _ring(SELECT_RING_SIZE, OfficeConstants.SELECT_RING, SELECT_RING_LIFT)


## The icon over the head and the rings for this frame; `icon_size` in world units.
func decorate(icon_size: float) -> void:
	var lying := phase in [Phase.LIE_DOWN, Phase.LYING, Phase.GET_UP]
	_founder_ring.visible = founder and not lying
	_select_ring.visible = selected and not lying
	var icon: Texture2D = ICONS.phone if calling else ICONS.get(status)
	_icon.visible = icon != null
	if icon:
		_icon.texture = icon
		var blink := lerpf(CALL_BLINK, 1.0, 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.001 * CALL_BLINK_RATE))
		_icon.modulate = Color(ICON_TINT, blink if calling else (ICON_DIM if is_walking() else 1.0))
		_icon.scale = Vector3.ONE * icon_size
		_icon.global_position = _head.global_position + Vector3.UP * (HEAD_ABOVE + icon_size * 0.55)


## Where the icon over the head is, in the world.
func marker() -> Vector3:
	return _icon.global_position


## Distance along the ray to this person's hit box, INF on a miss.
func hit(from: Vector3, dir: Vector3) -> float:
	var local := global_transform.affine_inverse()
	var box := LYING_BOX if phase == Phase.LYING else HIT_BOX
	var at: Variant = box.intersects_ray(local * from, local.basis * dir)
	return INF if at == null else from.distance_to(global_transform * (at as Vector3))


## The OFFICE_ACT_* key of what this person is doing.
func status_key() -> String:
	return "OFFICE_ACT_WALK" if is_walking() else "OFFICE_ACT_" + status.to_upper()


## RingGeometry(inner, outer, 40) laid on the floor under the body, unlit.
func _ring(radii: Vector2, color: Color, lift: float) -> MeshInstance3D:
	var key := [radii, color]
	if not _ring_looks.has(key):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in RING_SEGMENTS:
			var a := Vector3(cos(TAU * i / RING_SEGMENTS), 0.0, sin(TAU * i / RING_SEGMENTS))
			var b := Vector3(cos(TAU * (i + 1) / RING_SEGMENTS), 0.0, sin(TAU * (i + 1) / RING_SEGMENTS))
			for p: Vector3 in [a * radii.x, b * radii.y, a * radii.y, a * radii.x, b * radii.x, b * radii.y]:
				st.add_vertex(p)
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		m.albedo_color = color
		_ring_looks[key] = [st.commit(), m]
	var ring := MeshInstance3D.new()
	ring.mesh = _ring_looks[key][0]
	ring.material_override = _ring_looks[key][1]
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.position.y = lift
	# On the drawn body, so the ring glides with it between physics ticks.
	_body.add_child(ring)
	return ring
