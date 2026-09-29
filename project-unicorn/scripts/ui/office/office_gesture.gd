class_name OfficeGesture
extends SkeletonModifier3D

# Bends laid over a person's animated pose, eased in and out by OfficePerson: a lean of the
# spine (over the keyboard, back in a meeting chair), a tilt of the head, and where the head
# looks. It runs before the hands' IK, so the hands reach from where the shoulders now are.

const SPINE := [&"Spine", &"Chest", &"UpperChest"]
## A look's share taken by the neck, down and to the side; the head takes the rest.
const NECK_PITCH := 0.35
const NECK_YAW := 0.4

## Radians; positive leans forward, tilts the head down and turns it to the body's left. The lean
## is shared over the spine; nod and turn bend the neck.
var lean := 0.0
var nod := 0.0
var turn := 0.0
## Where the head looks, radians down and to the body's left, shared by neck and head.
var look_pitch := 0.0
var look_yaw := 0.0

var _bones := {}


func _process_modification_with_delta(_delta: float) -> void:
	var skel := get_skeleton()
	if _bones.is_empty():
		for bone: StringName in SPINE + [&"Neck", &"Head"]:
			_bones[bone] = skel.find_bone(bone)
	for bone: StringName in SPINE:
		_bend(skel, _bones[bone], lean / SPINE.size())
	_bend(skel, _bones[&"Neck"], nod + look_pitch * NECK_PITCH)
	_bend(skel, _bones[&"Head"], look_pitch * (1.0 - NECK_PITCH))
	_turn(skel, _bones[&"Neck"], turn + look_yaw * NECK_YAW)
	_turn(skel, _bones[&"Head"], look_yaw * (1.0 - NECK_YAW))


func _bend(skel: Skeleton3D, bone: int, angle: float) -> void:
	if angle != 0.0:
		skel.set_bone_pose_rotation(bone, skel.get_bone_pose_rotation(bone) * Quaternion(Vector3.RIGHT, angle))


func _turn(skel: Skeleton3D, bone: int, angle: float) -> void:
	if angle != 0.0:
		skel.set_bone_pose_rotation(bone, Quaternion(Vector3.UP, angle) * skel.get_bone_pose_rotation(bone))
