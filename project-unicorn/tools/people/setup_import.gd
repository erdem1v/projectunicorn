extends SceneTree

# Writes the humanoid retarget settings into the .import files of the office people's bodies and
# clip packs, so every skeleton comes out as %GeneralSkeleton with SkeletonProfileHumanoid bone
# names and one clip plays on every body. Run once after the files first import, then --import:
#
#   godot --headless --path . -s res://tools/people/setup_import.gd
#   godot --headless --path . --import

const BODIES := "res://assets/art/people/q22/"
const CLIPS := "res://assets/art/people/anims/"

const FINGERS := ["Thumb", "Index", "Middle", "Ring", "Little"]
const JOINTS := ["Metacarpal", "Proximal", "Intermediate", "Distal"]

## Profile bone -> this source's bone. Fingers come from finger() below.
const Q22 := {
	"Root": "Root", "Hips": "Body", "Spine": "Abdomen", "Chest": "Torso", "UpperChest": "Chest",
	"Neck": "Neck", "Head": "Head",
	"LeftShoulder": "Shoulder.L", "LeftUpperArm": "UpperArm.L", "LeftLowerArm": "LowerArm.L", "LeftHand": "Wrist.L",
	"RightShoulder": "Shoulder.R", "RightUpperArm": "UpperArm.R", "RightLowerArm": "LowerArm.R", "RightHand": "Wrist.R",
	"LeftUpperLeg": "UpperLeg.L", "LeftLowerLeg": "LowerLeg.L", "LeftFoot": "Foot.L",
	"RightUpperLeg": "UpperLeg.R", "RightLowerLeg": "LowerLeg.R", "RightFoot": "Foot.R",
}
const UE := {
	"Root": "root", "Hips": "pelvis", "Spine": "spine_01", "Chest": "spine_02", "UpperChest": "spine_03",
	"Neck": "neck_01", "Head": "Head",
	"LeftShoulder": "clavicle_l", "LeftUpperArm": "upperarm_l", "LeftLowerArm": "lowerarm_l", "LeftHand": "hand_l",
	"RightShoulder": "clavicle_r", "RightUpperArm": "upperarm_r", "RightLowerArm": "lowerarm_r", "RightHand": "hand_r",
	"LeftUpperLeg": "thigh_l", "LeftLowerLeg": "calf_l", "LeftFoot": "foot_l", "LeftToes": "ball_l",
	"RightUpperLeg": "thigh_r", "RightLowerLeg": "calf_r", "RightFoot": "foot_r", "RightToes": "ball_r",
}


func _initialize() -> void:
	for f: String in DirAccess.get_files_at(BODIES):
		if f.ends_with(".glb"):
			_write(BODIES + f, "CharacterArmature/Skeleton3D", _map(Q22, _q22_finger), false)
	for f: String in DirAccess.get_files_at(CLIPS):
		if f.ends_with(".glb"):
			var ue := UE.duplicate()
			ue["Head"] = "head" if f.begins_with("m2m_") else "Head"
			_write(CLIPS + f, "Armature/Skeleton3D", _map(ue, _ue_finger), true)
	quit()


func _map(bones: Dictionary, finger: Callable) -> BoneMap:
	var bm := BoneMap.new()
	bm.profile = SkeletonProfileHumanoid.new()
	for profile_bone: String in bones:
		bm.set_skeleton_bone_name(StringName(profile_bone), StringName(bones[profile_bone]))
	for side in ["Left", "Right"]:
		for name in FINGERS:
			for j in JOINTS.size():
				var bone: String = finger.call(side, name, j)
				var slot := "%s%s%s" % [side, name, JOINTS[j]]
				if bone != "" and bm.profile.find_bone(StringName(slot)) >= 0:
					bm.set_skeleton_bone_name(StringName(slot), StringName(bone))
	return bm


## Q22: Thumb1-3 are metacarpal, proximal, distal; the other fingers' 1 is a metacarpal the profile
## does not have, so 2-4 are proximal, intermediate, distal.
func _q22_finger(side: String, name: String, j: int) -> String:
	var q := "Pinky" if name == "Little" else name
	var s := ".L" if side == "Left" else ".R"
	if name == "Thumb":
		return {0: "Thumb1", 1: "Thumb2", 3: "Thumb3"}.get(j, "") + ("" if j == 2 else s)
	return "" if j == 0 else "%s%d%s" % [q, j + 1, s]


func _ue_finger(side: String, name: String, j: int) -> String:
	var q := ("Pinky" if name == "Little" else name).to_lower()
	var s := "_l" if side == "Left" else "_r"
	if name == "Thumb":
		return {0: "thumb_01", 1: "thumb_02", 3: "thumb_03"}.get(j, "") + ("" if j == 2 else s)
	return "" if j == 0 else "%s_0%d%s" % [q, j, s]


func _write(path: String, skeleton: String, bone_map: BoneMap, clips: bool) -> void:
	var cfg := ConfigFile.new()
	if cfg.load(path + ".import") != OK:
		push_error("no .import for " + path)
		return
	var node := {
		"retarget/bone_map": bone_map,
		"retarget/bone_renamer/rename_bones": true,
		"retarget/bone_renamer/unique_node/make_unique": true,
		"retarget/bone_renamer/unique_node/skeleton_name": "GeneralSkeleton",
		# Godot 4.6 drops every rotation track when this runs together with another remover.
		"retarget/remove_tracks/except_bone_transform": false,
		"retarget/remove_tracks/unimportant_positions": true,
		"retarget/remove_tracks/unmapped_bones": true,
		"retarget/rest_fixer/apply_node_transforms": true,
		"retarget/rest_fixer/normalize_position_tracks": true,
		"retarget/rest_fixer/reset_all_bone_poses_after_import": true,
		"retarget/rest_fixer/retarget_method": 1,
		"retarget/rest_fixer/fix_silhouette/enable": false,
	}
	cfg.set_value("params", "_subresources", {"nodes": {"PATH:" + skeleton: node}})
	cfg.set_value("params", "meshes/generate_lods", false)
	cfg.set_value("params", "meshes/ensure_tangents", false)
	cfg.set_value("params", "animation/import", clips)
	if clips:
		cfg.set_value("remap", "importer", "animation_library")
		cfg.set_value("remap", "type", "AnimationLibrary")
	cfg.save(path + ".import")
	print("wrote ", path, ".import")
