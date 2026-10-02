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

var viewport: SubViewport
var camera: Camera3D
## The ink pass and the light's environment; the portrait baker (tools/people/) tunes both.
var ink: ShaderMaterial
var environment: Environment
var _world: Node3D
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
	viewport = SubViewport.new()
	viewport.own_world_3d = true
	viewport.transparent_bg = true
	viewport.msaa_3d = Viewport.MSAA_4X
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	_world = Node3D.new()
	viewport.add_child(_world)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = FRAME
	_world.add_child(camera)
	var sky := _environment()
	environment = sky.environment
	_world.add_child(sky)
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
	var ink_pass := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(2, 2)
	ink_pass.mesh = quad
	ink_pass.extra_cull_margin = 16384.0
	ink_pass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ink = ShaderMaterial.new()
	ink.shader = preload("res://scenes/office/shaders/office_ink.gdshader")
	ink.render_priority = -128
	ink.set_shader_parameter("vignette", 0.0)
	ink.set_shader_parameter("cutout", true)
	ink_pass.material_override = ink
	_world.add_child(ink_pass)


func _process(_delta: float) -> void:
	if not _busy and not _queue.is_empty():
		_render(_queue.pop_front())


func _render(job: Array) -> void:
	_busy = true
	var tex: ImageTexture = job[0]
	viewport.size = Vector2i(tex.get_size())
	var body := OfficeBody.build(job[1])
	var look_at := pose(body) + Vector3.DOWN * HEAD_DROP
	camera.look_at_from_position(look_at + Vector3(sin(TURN), RISE, cos(TURN)) * 4.0, look_at)
	tex.set_image(await snap())
	body.queue_free()
	_busy = false


## Stands `body` in the studio in the busts' pose; where its head bone is.
func pose(body: Node3D) -> Vector3:
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
	return skel.global_transform * skel.get_bone_global_pose(skel.find_bone("Head")).origin


## The studio drawn once as it stands.
func snap() -> Image:
	await get_tree().process_frame
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	return viewport.get_texture().get_image()


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
