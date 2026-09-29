class_name PersonBust
extends Node

# Head-and-shoulders portraits of people for the interface's avatars. One off-screen studio (a
# SubViewport with its own world, noon light, the office's toon look and ink) renders a look's body
# once per size, on a clear background, into an ImageTexture that is handed out at once and filled
# when drawn, so a card shows the face as soon as it is ready. One portrait a frame; the cache is by
# look and size, so a changed look is a new portrait. No studio without a display.

## A portrait is drawn at this many times the size it is shown and read down by the filter.
const SUPERSAMPLE := 2
## The camera: orthographic, this many metres tall, looking at the head from ahead and a little
## to the side and above.
const FRAME := 0.5
const TURN := 0.42
const RISE := 0.12
const HEAD_DROP := 0.03        # the frame's centre sits this far below the head bone
const POSE := ["ual1/Idle", 0.4]
## The office's light at noon (OfficeLighting.CS), key from the camera's left.
const NOON := 780.0
const KEY_DIR := Vector3(-0.6, -0.55, -0.6)

static var _studio: PersonBust
static var _cache := {}

var _viewport: SubViewport
var _world: Node3D
var _camera: Camera3D
var _queue := []
var _busy := false


## The portrait of `look` for showing `px` pixels across, empty until drawn; null without a look
## or a display (headless runs).
static func texture(look: Dictionary, px: int) -> ImageTexture:
	if look.is_empty() or DisplayServer.get_name() == "headless":
		return null
	var key := "%s@%d" % [LookSystem.signature(look), px]
	if not _cache.has(key):
		var n := px * SUPERSAMPLE
		_cache[key] = ImageTexture.create_from_image(Image.create_empty(n, n, false, Image.FORMAT_RGBA8))
		if _studio == null:
			_studio = PersonBust.new()
			(Engine.get_main_loop() as SceneTree).root.add_child.call_deferred(_studio)
		_studio._queue.append([_cache[key], look])
	return _cache[key]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_viewport = SubViewport.new()
	_viewport.own_world_3d = true
	_viewport.transparent_bg = true
	_viewport.msaa_3d = Viewport.MSAA_4X
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_viewport)
	_world = Node3D.new()
	_viewport.add_child(_world)
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = FRAME
	_world.add_child(_camera)
	_world.add_child(_environment())
	var key := DirectionalLight3D.new()
	key.light_specular = 0.0
	key.basis = Basis.looking_at(KEY_DIR.normalized())
	var row := _noon_row()
	key.light_color = Color(row[3])
	key.light_energy = row[4] * OfficeLighting.LIGHT_SCALE
	_world.add_child(key)
	var fill := DirectionalLight3D.new()
	fill.light_specular = 0.0
	fill.basis = Basis.looking_at(-OfficeLighting.TOP_FILL_DIR.normalized(), Vector3.FORWARD)
	fill.light_color = OfficeLighting.TOP_FILL
	fill.light_energy = OfficeLighting.TOP_FILL_DAY * OfficeLighting.LIGHT_SCALE
	_world.add_child(fill)
	var ink := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(2, 2)
	ink.mesh = quad
	ink.extra_cull_margin = 16384.0
	ink.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var ink_mat := ShaderMaterial.new()
	ink_mat.shader = preload("res://scenes/office/shaders/office_ink.gdshader")
	ink_mat.render_priority = -128
	ink_mat.set_shader_parameter("vignette", 0.0)
	ink_mat.set_shader_parameter("cutout", true)
	ink.material_override = ink_mat
	_world.add_child(ink)


func _process(_delta: float) -> void:
	if not _busy and not _queue.is_empty():
		_render(_queue.pop_front())


func _render(job: Array) -> void:
	_busy = true
	var tex: ImageTexture = job[0]
	_viewport.size = Vector2i(tex.get_size())
	var body := OfficeBody.build(job[1])
	_world.add_child(body)
	var player := AnimationPlayer.new()
	body.add_child(player)
	player.root_node = NodePath("..")
	player.add_animation_library("ual1", load(OfficePerson.LIBS.ual1))
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	player.play(POSE[0])
	player.seek(POSE[1], true)
	var skel: Skeleton3D = body.get_node("%GeneralSkeleton")
	skel.force_update_all_bone_transforms()
	var head := skel.global_transform * skel.get_bone_global_pose(skel.find_bone("Head")).origin
	var look_at := head + Vector3.DOWN * HEAD_DROP
	_camera.look_at_from_position(look_at + Vector3(sin(TURN), RISE, cos(TURN)) * 4.0, look_at)
	await get_tree().process_frame
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	tex.set_image(_viewport.get_texture().get_image())
	body.queue_free()
	_busy = false


func _environment() -> WorldEnvironment:
	var row := _noon_row()
	var ambient := OfficeLighting.AMBIENT.srgb_to_linear() * OfficeLighting.AMBIENT_DAY
	var sky_mat := ShaderMaterial.new()
	sky_mat.shader = preload("res://scenes/office/shaders/office_sky.gdshader")
	var hi: float = row[7]
	var hs := Color(row[5]).srgb_to_linear() * hi + ambient
	var hg := Color(row[6]).srgb_to_linear() * hi + ambient
	sky_mat.set_shader_parameter("hemi_sky", OfficeLighting.rgb(hs * OfficeLighting.LIGHT_SCALE))
	sky_mat.set_shader_parameter("hemi_ground", OfficeLighting.rgb(hg * OfficeLighting.LIGHT_SCALE))
	var sky := Sky.new()
	sky.sky_material = sky_mat
	var env := Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = OfficeLighting.ACES_EXPOSURE
	env.tonemap_white = OfficeLighting.ACES_WHITE
	env.adjustment_enabled = true
	env.adjustment_contrast = OfficeLighting.GRADE_CONTRAST
	env.adjustment_saturation = OfficeLighting.GRADE_SATURATION
	var node := WorldEnvironment.new()
	node.environment = env
	return node


static func _noon_row() -> Array:
	return OfficeLighting.CS.filter(func(r: Array) -> bool: return r[0] == NOON)[0]
