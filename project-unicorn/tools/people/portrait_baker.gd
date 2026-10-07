extends Node

# Bakes the people the interface shows as fixed portraits instead of live busts: Frank
# (LookSystem.FRANK_LOOK, never seen in the office) and the eleven founders (LookSystem.FOUNDER_LOOKS
# in FounderConstants.PORTRAIT_IDS order), in the bust's studio (PersonBust: the office's noon light,
# toon body and ink), onto the lit portrait ground. Each gets the sizes its places show (file names:
# FounderConstants.portrait_path). A file holds SCALE times its size; it is drawn at twice that and
# read down once. Writes assets/art/portraits/ and its README.
# Run by bake_portraits.gd; exits non-zero when the hair reaches the top of a render.

## A founder's sizes: the 4:5 master, a little over the biggest place it is shown (the
## onboarding's preview card), and its crops. Frank's: his mail's portrait well and his discs
## (the notice stack, the mail's header, the period summary, the Yatırım page's strip, his note in Finans).
const MASTER := Vector2i(260, 325)
const FOUNDER_SIZES := [MASTER, FounderConstants.PORTRAIT_CELL, FounderConstants.PORTRAIT_THUMB]
const FRANK_SIZES := [Vector2i(256, 320), Vector2i(24, 24), Vector2i(32, 32), Vector2i(40, 40), Vector2i(48, 48), Vector2i(64, 64)]
const SCALE := 2
## The camera: this far round from the face, raised as the bust's; the busts' Idle pose.
const TURN := 0.3
## The figure is measured on a render PROBE_FRAME metres tall, PROBE_PX high, the Head bone
## PROBE_HEAD metres below its top: room above the tallest hair.
const PROBE_FRAME := 0.66
const PROBE_HEAD := 0.36
const PROBE_PX := 1600
## Framing on the figure (top: the first row past half alpha; neck: the narrowest row between a
## quarter and 70 % of the figure; hh = neck - top): a card holds hh in CARD_HH of its height with
## the crown CARD_TOP of it below the top edge; a disc is hh / DISC_HH across, centred DISC_CY hh
## below the crown, so the head fills about 70 % of it. Centred across on the head's rows.
const CARD_HH := 0.53
const CARD_TOP := 0.06
const DISC_HH := 0.77
const DISC_CY := 0.55
## Ink this many metres wide, and never thinner on screen (px) than the live bust's (texel 1.15 at
## PersonBust.SUPERSAMPLE).
const INK_M := 0.0045
const INK_MIN := 1.15 / PersonBust.SUPERSAMPLE
## The noon light washes the palest skins (palette index) out: their exposure.
const EXPOSURE := {0: 0.7, 1: 0.75}
## Glasses bars at this share of their thickness; the office's frames read heavy this close.
const GLASSES_BAR := 0.5

var _studio: PersonBust
var _dir := Vector3(sin(TURN), PersonBust.RISE, cos(TURN))
var _rows := PackedStringArray()
var _failed := false


func _ready() -> void:
	_studio = PersonBust.new()
	add_child(_studio)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FounderConstants.PORTRAIT_DIR))
	await _bake(FounderConstants.MENTOR_PORTRAIT, LookSystem.FRANK_LOOK, FRANK_SIZES)
	for i in FounderConstants.PORTRAIT_IDS.size():
		await _bake(FounderConstants.PORTRAIT_IDS[i], LookSystem.FOUNDER_LOOKS[i], FOUNDER_SIZES)
	_write_readme()
	get_tree().quit(1 if _failed else 0)


func _bake(id: String, look: Dictionary, sizes: Array) -> void:
	_studio.environment.tonemap_exposure = OfficeLighting.ACES_EXPOSURE * EXPOSURE.get(look.skin, 1.0)
	var body := OfficeBody.build(look)
	if look.glasses:
		_thin_glasses(body.get_node("%GeneralSkeleton/Body"))
	var centre := _studio.pose(body) + Vector3.DOWN * (PROBE_FRAME * 0.5 - PROBE_HEAD)
	var probe_px := Vector2i(PROBE_PX * 4 / 5, PROBE_PX)
	var fig := _figure(await _shoot(centre, PROBE_FRAME, probe_px, INK_M * PROBE_PX / PROBE_FRAME))
	if fig.top == 0:
		_fail(id, "the hair reaches the probe's top")
	# Camera plane coordinates, metres from the probe's centre: u across, v up.
	var m := PROBE_FRAME / PROBE_PX
	var hh: float = (fig.neck - fig.top) * m
	var top_v: float = (PROBE_PX * 0.5 - fig.top) * m
	var cx_u: float = (fig.cx - probe_px.x * 0.5) * m
	var basis := Basis.looking_at(-_dir)
	for size: Vector2i in sizes:
		var disc := size.x == size.y
		var frame := hh / DISC_HH if disc else hh / CARD_HH
		var v := top_v - DISC_CY * hh if disc else top_v + CARD_TOP * frame - frame * 0.5
		var px := size * SCALE * 2
		var img := await _shoot(centre + basis.x * cx_u + basis.y * v, frame, px,
			maxf(INK_M * px.y / frame, INK_MIN * SCALE * 2))
		if not disc and _figure(img).top == 0:
			_fail(id, "the hair reaches the top of %s" % size)
		_on_ground(img, disc)
		img.shrink_x2()
		if disc:
			_cut_disc(img)
		var path := FounderConstants.portrait_path(id, Vector2i.ZERO if size == MASTER else size)
		img.save_png(ProjectSettings.globalize_path(path))
		_rows.append("| `%s` | %d×%d | `%s` | `tools/people/bake_portraits.gd` | `%s` |" % [path.get_file(),
			img.get_width(), img.get_height(), LookSystem.signature(look).replace("|", "\\|"), FileAccess.get_sha256(path)])
		print("PORTRAIT|%s|%dx%d" % [path.get_file(), img.get_width(), img.get_height()])
	body.queue_free()


## The glasses are the last vertices of the body (OfficeBody._shape), boxes of 24: each bar is
## drawn thinner across its two short sides.
func _thin_glasses(mi: MeshInstance3D) -> void:
	var arrays := mi.mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var glasses: int = (OfficeBody._glasses(PackedVector3Array())[0] as PackedVector3Array).size()
	for i in range(verts.size() - glasses, verts.size(), 24):
		var box := AABB(verts[i], Vector3.ZERO)
		for k in 24:
			box = box.expand(verts[i + k])
		var keep := Vector3.ONE * GLASSES_BAR
		keep[box.get_longest_axis_index()] = 1.0
		for k in 24:
			verts[i + k] = box.get_center() + (verts[i + k] - box.get_center()) * keep
	arrays[Mesh.ARRAY_VERTEX] = verts
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mi.mesh = mesh


func _shoot(centre: Vector3, frame: float, px: Vector2i, texel: float) -> Image:
	_studio.viewport.size = px
	_studio.camera.size = frame
	_studio.camera.look_at_from_position(centre + _dir * 4.0, centre)
	_studio.ink.set_shader_parameter("texel", texel)
	var img: Image = await _studio.snap()
	img.convert(Image.FORMAT_RGBA8)
	return img


## The figure on a render: `top` (0 when it touches the top edge), `neck` and `cx`, in pixels.
func _figure(img: Image) -> Dictionary:
	var w := img.get_width()
	var data := img.get_data()
	var rows := []
	for y in img.get_height():
		var first := -1
		var last := -1
		for x in range(0, w, 2):
			if data[(y * w + x) * 4 + 3] > 128:
				if first < 0:
					first = x
				last = x
		rows.append([first, last])
	var lit := range(rows.size()).filter(func(y: int) -> bool: return rows[y][0] >= 0)
	var top: int = lit[0]
	var span: int = lit[-1] - top
	var neck: int = range(top + int(0.25 * span), top + int(0.7 * span)).reduce(func(best: int, y: int) -> int:
		return y if rows[y][0] >= 0 and rows[y][1] - rows[y][0] < rows[best][1] - rows[best][0] else best,
		top + int(0.25 * span))
	var mids := range(top + int(0.3 * (neck - top)), top + int(0.85 * (neck - top))).map(
		func(y: int) -> float: return (rows[y][0] + rows[y][1] + 1) * 0.5)
	return {"top": top, "neck": neck, "cx": mids.reduce(func(s: float, x: float) -> float: return s + x, 0.0) / mids.size()}


## The render over the lit ground (UiTokens.D_PORTRAIT_LIT to D_PORTRAIT_EDGE), opaque: the
## interface draws only the rim round a portrait, so the light is baked in. The studio's colour
## comes premultiplied, a few rim pixels straight.
func _on_ground(img: Image, disc: bool) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var data := img.get_data()
	for y in h:
		for x in w:
			var p := Vector2((x + 0.5) / w - 0.5, (y + 0.5) / h)
			# A disc: a circle at 36 % down, the edge colour at 74 % of the farthest corner; a card:
			# an ellipse 78 % by 60 % of the frame at 32 % down.
			var t := (p - Vector2(0, 0.36)).length() / (0.74 * Vector2(0.5, 0.64).length()) if disc \
				else Vector2(p.x / 0.78, (p.y - 0.32) / 0.6).length()
			var ground := UiTokens.D_PORTRAIT_LIT.lerp(UiTokens.D_PORTRAIT_EDGE, minf(t, 1.0))
			var i := (y * w + x) * 4
			var a := data[i + 3] / 255.0
			var straight: bool = maxi(data[i], maxi(data[i + 1], data[i + 2])) > data[i + 3]
			for c in 3:
				var fg := data[i + c] / 255.0 * (a if straight else 1.0)
				data[i + c] = clampi(roundi((fg + ground[c] * (1.0 - a)) * 255.0), 0, 255)
			data[i + 3] = 255
	img.set_data(w, h, false, Image.FORMAT_RGBA8, data)


## Straight alpha cut to the inscribed circle, its rim antialiased.
func _cut_disc(img: Image) -> void:
	var r := img.get_width() * 0.5
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			c.a = clampf(r - Vector2(x + 0.5 - r, y + 0.5 - r).length() + 0.5, 0.0, 1.0)
			img.set_pixel(x, y, c)


func _write_readme() -> void:
	var lines := PackedStringArray([
		"# Portreler",
		"",
		"Frank'in ve on bir kurucunun önceden render edilmiş portreleri: ofisin 3B karakterleri, büst stüdyosunda",
		"(`PersonBust`), ışıklı portre zemininde. Görünüşler `LookSystem.FRANK_LOOK` ve `LookSystem.FOUNDER_LOOKS`.",
		"Kurucunun `<id>.png`'si 4:5 ana görüntüdür (260×325 için kesilir); `<id>_<boy>.png` daha küçük yerler için",
		"kırpımdır, adındaki boy kesildiği mantıksal boydur ve yerler onu yakın bir boyda gösterir. Frank'in ana görüntüsü",
		"yoktur: maillerinin portre kuyusu (256×320) ve diskleri vardır. Dosya mantıksal boyun iki katıdır ve çizimde",
		"doğrusal süzgeçle iner (mipmap yok). Kare kırpımlar",
		"daireye kesilmiş disklerdir, kenarları düz (premultiply edilmemiş) alfadır; kartlar opaktır.",
		"",
		"Bu dosyayı ve görüntüleri `tools/people/bake_portraits.gd` yazar (`project-unicorn/`'dan, pencereli, tek Godot):",
		"",
		"    \"$GODOT\" --path . -s res://tools/people/bake_portraits.gd",
		"    \"$GODOT\" --headless --path . --import",
		"",
		"Gövdeler Quaternius Ultimate Modular Men/Women 2022, poz Universal Animation Library'dendir: CC0 1.0",
		"(`../people/LICENSES/`), atıf gerekmez.",
		"",
		"| Dosya | Piksel | Görünüş imzası | Araç | sha256 |",
		"|---|---|---|---|---|",
	])
	lines.append_array(_rows)
	var f := FileAccess.open(FounderConstants.PORTRAIT_DIR + "README.md", FileAccess.WRITE)
	f.store_string("\n".join(lines) + "\n")


func _fail(id: String, why: String) -> void:
	_failed = true
	print("PORTRAIT|FAIL|%s|%s" % [id, why])
