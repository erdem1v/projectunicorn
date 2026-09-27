class_name OfficeActor
extends Node3D

# One person in the office: the design's makeBot and animBot (office-sim-v12.js) on the Mixamo
# Xbot, walking the design's paths (people-x.js mkPath and evalTLX) in real seconds. OfficePeople
# says where each person goes and what they do there; this node takes them there and draws them.

## Head icons by activity (office-sim-v2.js ICON); an activity missing here shows none.
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
	"food": preload("res://assets/art/office/icons/food.svg"),
}
## The design's icon sprite tint, and its opacity while walking: 3D scene colours, not UI tokens.
const ICON_TINT := Color("#d2d2d2")
const ICON_DIM := 0.6
const ICON_PRIORITY := 10          # the design draws icons after everything else
const WALK_SPEED := 2.4            # m/s in real time, whatever the game speed
const WALK_CLIP_PACE := 1.25       # m/s the walk clip covers at time scale 1 (animBot)
const BLEND_TIME := 0.25           # idle <-> walk crossfade, seconds (animBot eases at 10/s)
## A body's clip and bends run on one frame in POSE_EVERY, the bodies spread across them: every
## frame, seventy bodies took about 6 ms.
const POSE_EVERY := 2
const FOUNDER_TALL := 1.02         # the founder stands a little taller (makeBot)
const SEAT_Y := 0.56               # hip height of a seated body (animBot)
const HEAD_LIFT := 0.06            # the face sits this far up the head bone (makeBot)
const HEAD_ABOVE := 0.28           # an icon's floor above the head bone (animBot)
## Floor rings (inner and outer radius) and how far above the floor each lies.
const FOUNDER_RING_SIZE := Vector2(0.42, 0.56)
const FOUNDER_RING_LIFT := 0.03
const SELECT_RING_SIZE := Vector2(0.6, 0.7)
const SELECT_RING_LIFT := 0.035
const RING_SEGMENTS := 40
const HIT_BOX := AABB(Vector3(-0.3, 0.0, -0.3), Vector3(0.6, 1.7, 0.6))
const POSED_BONES := ["LeftUpLeg", "RightUpLeg", "LeftLeg", "RightLeg", "LeftArm", "RightArm",
	"LeftForeArm", "RightForeArm"]

static var _ring_looks := {}   # [radii, colour] -> [mesh, material]

var character: Character
var founder := false
## Set by OfficePeople: where this person works ({} = no place in this office), the desk whose
## lamp is theirs (-1 = none) and what they do there.
var seat := {}
var desk_id := -1
var work_act := ""
var selected := false
## The spot they are at, or walked away from, and what they are doing.
var spot := {}
var act := ""
var trip_in := 0.0    # real seconds at the desk before the next break
var stay := 0.0       # real seconds left at a break spot
var rng := RandomNumberGenerator.new()

var _lane := 0.0
var _drop := 0.0      # how far a seated body sinks for its hips to meet the seat
var _placed := ""     # the pose the transform and rings were last written for; "" = write next frame
var _pos := Vector3.ZERO
var _face := 0.0
var _goal := {}
var _path := PackedVector3Array()
var _cum := PackedFloat32Array()
var _dist := 0.0
var _speed := WALK_SPEED
var _vert := false
var _clock := 0.0
var _axis := Vector3.RIGHT   # animBot's bend axis (the body's left) in skeleton space
var _bones := PackedInt32Array()   # POSED_BONES' indices, in its order
var _player: AnimationPlayer
var _skeleton: Skeleton3D
var _pose_frame := 0
var _pose_delta := 0.0
var _head_bone: BoneAttachment3D
var _icon: Sprite3D
var _founder_ring: MeshInstance3D
var _select_ring: MeshInstance3D


## Builds the body for `c`: a look drawn from its id, the role's colour on the top.
func setup(c: Character) -> void:
	character = c
	founder = c.category == "founder"
	rng.seed = c.id.hash()
	_lane = (rng.randi_range(0, 8) - 4) * 0.08
	_clock = rng.randf_range(0.0, 100.0)
	var look := OfficeLook.look_of(0, 0) if founder \
		else OfficeLook.look_of(rng.randi_range(0, OfficeLook.CHARS.size() - 1), rng.randi_range(0, OfficeLook.VARIANTS - 1))
	var rig := OfficeLook.rig()
	var tall: float = look.h * (FOUNDER_TALL if founder else 1.0)
	var size: float = rig.k * tall
	_drop = rig.hip_y * tall - SEAT_Y
	var holder := Node3D.new()
	holder.rotation.y = rig.flip
	holder.scale = Vector3(size * look.wd, size, size * look.wd)
	add_child(holder)
	var body: Node3D = OfficeLook.XBOT.instantiate()
	holder.add_child(body)
	_skeleton = body.get_node("Armature/Skeleton3D")
	var meshes := OfficeLook.outfit(look, OfficeConstants.ROLE_COLORS[OfficeConstants.ROLE_KEYS[c.role]])
	for i in 2:
		var part: MeshInstance3D = _skeleton.get_node(["Beta_Surface", "Beta_Joints"][i])
		part.mesh = meshes[i]
		part.material_override = OfficeLook.material
	_head_bone = BoneAttachment3D.new()
	_head_bone.bone_name = "mixamorig_Head"
	_skeleton.add_child(_head_bone)
	# The face is modelled in world units: undo the bone's own scale (makeBot).
	var bone_scale: float = size * rig.unit
	var head := MeshInstance3D.new()
	head.mesh = OfficeLook.head_mesh(look)
	head.material_override = OfficeLook.material
	head.scale = Vector3.ONE / bone_scale
	head.position = Vector3.UP * HEAD_LIFT / bone_scale
	_head_bone.add_child(head)
	for bone: String in POSED_BONES:
		_bones.append(_skeleton.find_bone("mixamorig_" + bone))
	_axis = ((holder.basis * (body.get_node("Armature") as Node3D).basis).inverse() * Vector3.RIGHT).normalized()
	var poser := Poser.new()
	poser.actor = self
	_skeleton.add_child(poser)
	_skeleton.modifier_callback_mode_process = Skeleton3D.MODIFIER_CALLBACK_MODE_PROCESS_MANUAL
	_player = body.get_node("AnimationPlayer")
	_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	_pose_frame = rng.randi_range(0, POSE_EVERY - 1)
	# No two people breathe in step.
	_player.play(&"idle")
	_player.seek(rng.randf() * _player.current_animation_length, true)

	_icon = Sprite3D.new()
	_icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_icon.no_depth_test = true
	_icon.render_priority = ICON_PRIORITY
	_icon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_icon.pixel_size = 1.0 / (ICONS.code as Texture2D).get_height()
	add_child(_icon)
	_founder_ring = _ring(FOUNDER_RING_SIZE, OfficeConstants.FOUNDER_RING)
	_select_ring = _ring(SELECT_RING_SIZE, OfficeConstants.SELECT_RING)


func is_walking() -> bool:
	return not _goal.is_empty()


## The spot this person is at, or on the way to.
func destination() -> Dictionary:
	return _goal if is_walking() else spot


## Puts this person at `at` doing `what`; the design's "out" spots are off the map.
func stand(at: Dictionary, what: String) -> void:
	spot = at
	act = what
	_goal = {}
	_pos = at.pos
	_face = at.face
	_vert = false
	_placed = ""
	visible = at.pose != "out"


## Walks to `to` (mkPath: out along this spot's chain, in along the other's, in this person's
## lane), showing `what` on the way. A walk given `within` seconds speeds up to fit; one that
## crosses zones (the design's street and flat share no path) is not walked.
func walk(to: Dictionary, what: String, within := INF) -> void:
	var back: Array = Array(to.chain)
	back.reverse()
	var points := PackedVector3Array([spot.pos])
	for p: Vector3 in Array(spot.chain) + back:
		var q := p + Vector3(0, 0, _lane)
		if q.distance_to(points[-1]) > 0.01:
			points.append(q)
	if to.pos.distance_to(points[-1]) > 0.01:
		points.append(to.pos)
	_cum = PackedFloat32Array([0.0])
	for i in range(1, points.size()):
		_cum.append(_cum[-1] + points[i].distance_to(points[i - 1]))
	_speed = maxf(WALK_SPEED, _cum[-1] / within)
	if to.zone != spot.zone or _cum[-1] < 0.01:
		stand(to, what)
		return
	_path = points
	_dist = 0.0
	_goal = to
	act = what
	visible = true


## Moves along the path (evalTLX): straight segments, facing the way; a vertical one is a ride.
func advance(delta: float) -> void:
	_dist = minf(_dist + _speed * delta, _cum[-1])
	var i := clampi(_cum.bsearch(_dist) - 1, 0, _cum.size() - 2)
	var a := _path[i]
	var b := _path[i + 1]
	_pos = a.lerp(b, (_dist - _cum[i]) / maxf(_cum[i + 1] - _cum[i], 1e-6))
	_vert = absf(b.y - a.y) > 0.01 and Vector2(b.x - a.x, b.z - a.z).length() < 0.05
	_face = 0.0 if _vert else atan2(b.x - a.x, b.z - a.z)
	if _dist >= _cum[-1]:
		stand(_goal, act)


## One frame of the body: the walk blend, the seat drop, the icon over the head and the floor
## rings. `running` is false while the game is paused: the body idles where it is.
func animate(delta: float, running: bool, icon_size: float) -> void:
	if not visible:
		return
	_clock += delta
	var walking := is_walking()
	var stride := walking and running and not _vert
	var clip := &"walk" if stride else &"idle"
	if _player.current_animation != clip:
		_player.play(clip, BLEND_TIME)
	_player.speed_scale = maxf(0.6, _speed / WALK_CLIP_PACE) if stride else 1.0
	var pose: String = "walk" if walking else spot.pose
	if walking or pose != _placed:
		_placed = pose
		var drop := _drop if pose == "sit" else 0.0
		position = _pos + Vector3.DOWN * drop
		rotation = Vector3(-PI / 2.0 if pose == "lie" else 0.0, _face, 0.0)
		_founder_ring.visible = founder and pose != "lie"
		_founder_ring.position.y = drop + FOUNDER_RING_LIFT
		_select_ring.position.y = drop + SELECT_RING_LIFT
	_select_ring.visible = selected and pose != "lie"
	var icon: Texture2D = ICONS.get(act)
	_icon.visible = icon != null
	if icon:
		_icon.texture = icon
		_icon.modulate = Color(ICON_TINT, ICON_DIM if walking else 1.0)
	_pose_delta += delta
	if Engine.get_process_frames() % POSE_EVERY == _pose_frame:
		_player.advance(_pose_delta)
		_skeleton.advance(_pose_delta)
		_pose_delta = 0.0
		_icon.scale = Vector3.ONE * icon_size
		_icon.position.y = _head_bone.global_position.y - global_position.y + HEAD_ABOVE + icon_size * 0.55


## Distance along the ray to this person's hit box, INF on a miss.
func hit(from: Vector3, dir: Vector3) -> float:
	var local := global_transform.affine_inverse()
	var at: Variant = HIT_BOX.intersects_ray(local * from, local.basis * dir)
	return INF if at == null else from.distance_to(global_transform * (at as Vector3))


## The OFFICE_ACT_* key of what this person is doing.
func status_key() -> String:
	return "OFFICE_ACT_WALK" if is_walking() else "OFFICE_ACT_" + act.to_upper()


## animBot's bends: seated legs, and arms by activity; standing, only the coffee cup. Each bend
## turns a bone about the body's left axis on top of its animated pose (rotW). A turn about that
## axis leaves the axis where it was, so every bone's axis is read in its parent's frame before
## the first turn and the skeleton updates once.
func _pose() -> void:
	if is_walking() or not visible:
		return
	var angles := _bends()
	var axes := PackedVector3Array()
	axes.resize(angles.size())
	for k in angles.size():
		if angles[k] != 0.0:
			var parent := _skeleton.get_bone_parent(_bones[k])
			axes[k] = (_skeleton.get_bone_global_pose(parent).basis.inverse() * _axis).normalized()
	for k in angles.size():
		if angles[k] != 0.0:
			var i := _bones[k]
			_skeleton.set_bone_pose_rotation(i, Quaternion(axes[k], angles[k]) * _skeleton.get_bone_pose_rotation(i))


## The angle for each of POSED_BONES in the current pose; 0 leaves a bone as animated.
func _bends() -> PackedFloat32Array:
	var t := _clock
	var legs := 0.0
	var arms := Vector4.ZERO   # left, right, left fore, right fore
	if spot.pose == "sit":
		legs = PI / 2.0
		match act:
			"code", "test", "design":
				arms = Vector4(-0.5, -0.5, -1.0 + sin(t * 13.0) * 0.08, -1.0 + sin(t * 13.0 + 1.9) * 0.08)
			"research", "plan":
				arms = Vector4(-0.4, -0.4, -1.1, -1.1 - maxf(0.0, sin(t * 0.7)) * 0.4)
			"phone":
				arms = Vector4(-0.4, -0.35, -1.1, -2.5)
			"food":
				arms = Vector4(-0.4, -0.4, -1.0, -1.1 - maxf(0.0, sin(t * 2.2)))
	elif act == "coffee":
		arms = Vector4(0.0, -0.25, 0.0, -1.3 - maxf(0.0, sin(t * 1.1)) * 0.7)
	return PackedFloat32Array([-legs, -legs, legs, legs, arms.x, arms.y, arms.z, arms.w])


## RingGeometry(inner, outer, 40) laid on the floor, unlit.
func _ring(radii: Vector2, color: Color) -> MeshInstance3D:
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
	add_child(ring)
	return ring


## Bends the animated body into its pose after each animation step.
class Poser extends SkeletonModifier3D:
	var actor: OfficeActor

	func _process_modification_with_delta(_delta: float) -> void:
		actor._pose()
