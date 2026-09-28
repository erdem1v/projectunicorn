class_name OfficeGesture
extends SkeletonModifier3D

# Bends laid over a person's animated pose, eased in and out by OfficePerson: a lean of the
# spine (over the keyboard, back in a meeting chair) and a tilt of the head. It runs before the
# hands' IK, so the hands reach from where the shoulders now are.

const SPINE := [&"Spine", &"Chest", &"UpperChest"]

## Radians; positive leans forward, tilts the head down and turns it to the body's left. The lean
## is shared over the spine.
var lean := 0.0
var nod := 0.0
var turn := 0.0

var _bones := {}


func _process_modification_with_delta(_delta: float) -> void:
	var skel := get_skeleton()
	if _bones.is_empty():
		for bone: StringName in SPINE + [&"Neck"]:
			_bones[bone] = skel.find_bone(bone)
	for bone: StringName in SPINE:
		_bend(skel, _bones[bone], lean / SPINE.size())
	_bend(skel, _bones[&"Neck"], nod)
	if turn != 0.0:
		var neck: int = _bones[&"Neck"]
		skel.set_bone_pose_rotation(neck, Quaternion(Vector3.UP, turn) * skel.get_bone_pose_rotation(neck))


func _bend(skel: Skeleton3D, bone: int, angle: float) -> void:
	if angle != 0.0:
		skel.set_bone_pose_rotation(bone, skel.get_bone_pose_rotation(bone) * Quaternion(Vector3.RIGHT, angle))
