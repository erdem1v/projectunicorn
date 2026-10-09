class_name OfficeMaterials
extends RefCounted

# Puts an imported office GLB into the design's ink look (office-sim-v12.js toonify). Lit
# surfaces move onto the toon shader. The design's unlit surfaces (KHR_materials_unlit, and the
# towers the exporter marks `unlit` in extras) stay StandardMaterial3D, as do the see-through lit
# ones, which take Godot's own toon diffuse. Named materials come back by name for lighting.

const TOON := preload("res://scenes/office/shaders/office_toon.gdshader")
## The design keeps these out of its ink pass (userData.noEdge); the flag rides in roughness.
const NO_EDGE := ["ground", "walk", "road", "grass", "line", "water"]
const STATION := "^station_(\\d+|f)_(lamp|screen)(_\\d+)?$"
## The design's floor slab, told by its colour: its outer faces lie in the facade skin's plane, so the skin
## and the slab trade the depth test in a band along the facade as the camera moves. The slab steps back.
const SLAB := "7d746a"
const SLAB_INSET := 0.01


## Converts every surface under root and hides the layout's hidden nodes. Returns material name
## -> Array[Material] for the names the layout lists; one entry per imported material.
static func convert_scene(root: Node3D, layout: OfficeLayout) -> Dictionary:
	var done := {}
	var named := {}
	for name: String in layout.materials:
		var list: Array[Material] = []
		named[name] = list
	for mi: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if mi.get_meta("extras", {}).get("noCast", false):
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for i in mi.mesh.get_surface_count():
			var src: BaseMaterial3D = mi.mesh.surface_get_material(i)
			if not done.has(src):
				done[src] = _convert(src)
				if named.has(src.resource_name):
					named[src.resource_name].append(done[src])
			mi.set_surface_override_material(i, done[src])
	for node_name in layout.hidden:
		root.find_child(node_name, true, false).visible = false
	return named


## Desk id (0 = founder, i = spots.desk[i]) -> {lamp, screen: Material; lamp_at, screen_at:
## Vector3}: each station's own emissive pair, which lighting switches on only while its desk is
## taken, and the world centres of the lamp head and a screen, where the after-hours lights go.
## The centres come from the meshes, not the side JSON: the design mirrors İş hanı's anchors in
## x after placing its stations. `root` must be in the tree.
static func stations(root: Node3D) -> Dictionary:
	var re := RegEx.create_from_string(STATION)
	var out := {}
	for mi: MeshInstance3D in root.find_children("station_*", "MeshInstance3D", true, false):
		var m := re.search(mi.name)
		if m == null:
			continue
		var desk := 0 if m.get_string(1) == "f" else int(m.get_string(1)) + 1
		if not out.has(desk):
			out[desk] = {}
		out[desk][m.get_string(2)] = mi.get_surface_override_material(0)
		out[desk][m.get_string(2) + "_at"] = mi.global_transform * mi.get_aabb().get_center()
	return out


static func _convert(src: BaseMaterial3D) -> Material:
	var extras: Dictionary = src.get_meta("extras", {})
	if extras.get("unlit", false):
		src.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if src.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
		if src.resource_name in NO_EDGE:
			src.roughness = 0.0
		return src
	if src.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
		src.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		src.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		return src
	var toon := ShaderMaterial.new()
	toon.shader = TOON
	toon.resource_name = src.resource_name
	toon.set_shader_parameter("albedo", src.albedo_color)
	toon.set_shader_parameter("albedo_texture", src.albedo_texture)
	var uv_scale := Vector2(src.uv1_scale.x, src.uv1_scale.y)
	var uv_offset := Vector2(src.uv1_offset.x, src.uv1_offset.y)
	toon.set_shader_parameter("uv1_scale", uv_scale)
	toon.set_shader_parameter("uv1_offset", uv_offset)
	if src.emission_enabled:
		toon.set_shader_parameter("emission", src.emission)
		toon.set_shader_parameter("emission_energy", src.emission_energy_multiplier)
		toon.set_shader_parameter("emission_texture", src.emission_texture)
	var own_uv: Dictionary = extras.get("emissiveUv", {})
	if own_uv:
		uv_scale = Vector2(own_uv.scale[0], own_uv.scale[1])
		uv_offset = Vector2(own_uv.offset[0], own_uv.offset[1])
	toon.set_shader_parameter("emission_uv_scale", uv_scale)
	toon.set_shader_parameter("emission_uv_offset", uv_offset)
	toon.set_shader_parameter("no_edge", src.resource_name in NO_EDGE)
	if src.albedo_color.to_html(false) == SLAB:
		toon.set_shader_parameter("inset", SLAB_INSET)
	return toon
