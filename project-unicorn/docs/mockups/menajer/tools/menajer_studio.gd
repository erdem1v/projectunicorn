extends "res://scripts/ui/office/person_bust.gd"

## Throwaway portrait studio for the Menajer Masası mockups (Faz A3). Loaded at run time by
## capture_menajer.gd, after the autoloads exist, so it may name project classes. It is the
## game's PersonBust studio (same noon light, toon body, ink quad with cutout) with the frame,
## size, ink texel, pose and camera turn opened up. Never writes to disk; returns raw images
## (alpha is near binary at render size, colour straight where alpha is full).

var _ink: ShaderMaterial
var _libs := {}


func _ready() -> void:
	super()
	for n in _world.get_children():
		if n is MeshInstance3D and (n as MeshInstance3D).material_override is ShaderMaterial:
			_ink = (n as MeshInstance3D).material_override
	for key: String in OfficePerson.LIBS:
		_libs[key] = load(OfficePerson.LIBS[key])


## `look` in a `size` px frame `frame_h` metres tall, the Head bone `head_from_top` metres below the
## frame's top edge, ink lines `texel` px, `pose` = [clip, second], the camera turned `turn`
## radians and raised `rise` (as PersonBust: 0.42 / 0.12). PersonBust's own framing is
## frame_h 0.5, head_from_top 0.22, texel 1.15, ["ual1/Idle", 0.4], centred on the head.
## `on_torso` centres the frame across on the mid point of the two upper arms instead, so a turned
## body sits in the middle of a half body frame.
func shoot(look: Dictionary, size: Vector2i, frame_h: float, head_from_top: float, texel: float,
		pose: Array, turn: float, rise: float, on_torso := false) -> Image:
	while _busy:
		await get_tree().process_frame
	_busy = true
	_viewport.size = size
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	_camera.size = frame_h
	_ink.set_shader_parameter("texel", texel)
	var body := OfficeBody.build(look)
	_world.add_child(body)
	var player := AnimationPlayer.new()
	body.add_child(player)
	player.root_node = NodePath("..")
	for key: String in _libs:
		player.add_animation_library(key, _libs[key])
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	player.play(pose[0])
	player.seek(pose[1], true)
	var skel: Skeleton3D = body.get_node("%GeneralSkeleton")
	skel.force_update_all_bone_transforms()
	var head := skel.global_transform * skel.get_bone_global_pose(skel.find_bone("Head")).origin
	var centre := head + Vector3.DOWN * (frame_h * 0.5 - head_from_top)
	if on_torso:
		var across := Vector3(cos(turn), 0.0, -sin(turn))
		var mid := 0.0
		for b in ["LeftUpperArm", "RightUpperArm"]:
			mid += (skel.global_transform * skel.get_bone_global_pose(skel.find_bone(b)).origin - head).dot(across) * 0.5
		centre += across * mid
	_camera.look_at_from_position(centre + Vector3(sin(turn), rise, cos(turn)) * 4.0, centre)
	await get_tree().process_frame
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	var img := _viewport.get_texture().get_image()
	body.queue_free()
	await get_tree().process_frame
	_busy = false
	return img


## Bone heights for framing checks: Head, Neck, Hips, LeftHand in world metres for `look` at `pose`.
func bones(look: Dictionary, pose: Array) -> Dictionary:
	var body := OfficeBody.build(look)
	_world.add_child(body)
	var player := AnimationPlayer.new()
	body.add_child(player)
	player.root_node = NodePath("..")
	for key: String in _libs:
		player.add_animation_library(key, _libs[key])
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	player.play(pose[0])
	player.seek(pose[1], true)
	var skel: Skeleton3D = body.get_node("%GeneralSkeleton")
	skel.force_update_all_bone_transforms()
	var out := {}
	for b in ["Head", "Neck", "Chest", "Hips", "LeftHand", "RightHand", "LeftShoulder", "RightShoulder"]:
		var i := skel.find_bone(b)
		if i >= 0:
			out[b] = skel.global_transform * skel.get_bone_global_pose(i).origin
	body.free()
	return out
