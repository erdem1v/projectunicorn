extends SceneTree

## Throwaway capture for the HTML mockups: the ishani office plate at 11:00 (today's 1836x992
## framing and a full 1920x1080 framing) and the seeded people's busts. Writes only under OUT.
## Autoloads are reached through the tree: an -s script compiles before they exist.
## Mode from --mockup-shot=<all|game|full|busts> (default all).

const OUT := "C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/0e406678-a661-4d23-90af-2e43deb375cc/scratchpad/mockups/art/"
const REF_HASH := "bd3e56ba9d0ff5bca7ba31aa52900373be5d7229"
const STAGE := Vector2i(1920, 1080)
const GAME_RECT := Rect2(84, 54, 1836, 992)
const BUSTS := [["char_emp_shot_0", "elif"], ["char_emp_shot_1", "deniz"], ["char_emp_shot_2", "mert"],
	["char_emp_shot_3", "selin"], ["char_emp_shot_4", "burak"], ["founder", "kurucu"]]
const TIMEOUT_MS := 30000

var _fails := 0
var _stage: SubViewport


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var tm: Node = root.get_node("/root/TimeManager")
	tm.hold_clock("mockup")
	var mode := "all"
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--mockup-shot="):
			mode = arg.trim_prefix("--mockup-shot=")
	print("MOCKCAP|START|mode=%s|display=%s|paused=%s" % [mode, DisplayServer.get_name(), paused])
	TranslationServer.set_locale("tr")
	var seeder = load("res://scripts/main/main.gd").new()
	seeder._seed_theme_surface()
	seeder.free()
	var gs: Node = root.get_node("/root/GameState")
	gs.office_id = "ishani"
	gs.set_current_hour(11)
	tm.sync_to_current_hour()
	print("MOCKCAP|SEED|day=%s|hour=%s|day_minute=%s|office=%s" % [gs.day, gs.current_hour,
		tm.day_minute(), gs.office_id])

	var box := SubViewportContainer.new()
	box.process_mode = Node.PROCESS_MODE_ALWAYS
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(box)
	_stage = SubViewport.new()
	_stage.size = STAGE
	_stage.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_stage.gui_disable_input = true
	_stage.handle_input_locally = false
	box.add_child(_stage)

	if mode in ["all", "game"]:
		await _plate(GAME_RECT, "office_game.png", true)
	if mode in ["all", "full"]:
		await _plate(Rect2(Vector2.ZERO, Vector2(STAGE)), "office_full.png", false)
	if mode in ["all", "busts"]:
		await _busts()
	print("MOCKCAP|DONE|fails=%d" % _fails)
	quit(1 if _fails > 0 else 0)


## One OfficeView inside a host Control of `rect` on the stage; the camera fits on the first size,
## so each framing is its own instance. The inner 3D SubViewport is read, never the Overlay.
func _plate(rect: Rect2, file: String, parity: bool) -> void:
	var host := Control.new()
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.position = rect.position
	host.size = rect.size
	_stage.add_child(host)
	var office: Control = (load("res://scenes/office/OfficeView.tscn") as PackedScene).instantiate()
	host.add_child(office)
	var people: Node = office.get_node("Viewport3D/SubViewport/World/People")
	var vp: SubViewport = office.get_node("Viewport3D/SubViewport")
	var start := Time.get_ticks_msec()
	while not people._placed:
		if Time.get_ticks_msec() - start > TIMEOUT_MS:
			_fail(file, "people never placed")
			host.queue_free()
			return
		await process_frame
	print("MOCKCAP|PLACED|%s|after_ms=%d|actors=%d" % [file, Time.get_ticks_msec() - start,
		people._actors.size()])
	for i in 60:
		await process_frame
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED:
		_fail(file, "window minimized")
	await RenderingServer.frame_post_draw
	var img := vp.get_texture().get_image()
	var h1 := _sha1(img)
	_check_and_save(img, file, Vector2i(rect.size))
	print("MOCKCAP|PLATE|%s|size=%dx%d|sha1=%s|office_size=%s" % [file, img.get_width(),
		img.get_height(), h1, office.size])
	if parity:
		print("MOCKCAP|PARITY|%s|%s|ref=%s|got=%s" % [file, "EQUAL" if h1 == REF_HASH else "DIFFERENT",
			REF_HASH, h1])
	# Stability: the same frame again after more frames and wall time.
	for i in 60:
		await process_frame
	await create_timer(1.0, true).timeout
	await RenderingServer.frame_post_draw
	var h2 := _sha1(vp.get_texture().get_image())
	print("MOCKCAP|STABLE|%s|later_sha1=%s|same=%s" % [file, h2, h1 == h2])
	host.queue_free()
	await process_frame
	await process_frame


func _busts() -> void:
	var pb: Script = load("res://scripts/ui/office/person_bust.gd")
	var reg: Node = root.get_node("/root/CharacterRegistry")
	var jobs := []
	for b in BUSTS:
		var c: Object = reg.get_founder() if b[0] == "founder" else reg.get_character(b[0])
		if c == null or (c.look as Dictionary).is_empty():
			_fail(b[1], "no character or empty look")
			continue
		print("MOCKCAP|LOOK|%s|%s|%s|%s" % [b[0], b[1], c.character_name, JSON.stringify(c.look)])
		jobs.append([b[1], pb.texture(c.look, 256), pb.texture(c.look, 32)])
	var start := Time.get_ticks_msec()
	while true:
		var studio = pb._studio
		if studio != null and studio.is_inside_tree() and not studio._busy and studio._queue.is_empty():
			break
		if Time.get_ticks_msec() - start > TIMEOUT_MS:
			_fail("busts", "studio never idle")
			return
		await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT + "raw")
	for j in jobs:
		for pair in [[j[1], "bust_%s.png" % j[0], 512], [j[2], "bust64_%s.png" % j[0], 64]]:
			var img: Image = (pair[0] as ImageTexture).get_image()
			img.save_png(OUT + "raw/" + pair[1])
			var fixed := _unpremultiply(img, pair[1])
			_check_and_save(fixed, pair[1], Vector2i(pair[2], pair[2]))


## A transparent viewport's pixels carry colour already multiplied by alpha; divide it back out.
func _unpremultiply(img: Image, label: String) -> Image:
	img.convert(Image.FORMAT_RGBA8)
	var d := img.get_data()
	var over := 0
	var partial := 0
	var opaque := 0
	for i in range(0, d.size(), 4):
		var a := d[i + 3]
		if a == 255:
			opaque += 1
		elif a > 0:
			partial += 1
			for k in 3:
				if d[i + k] > a:
					over += 1
				d[i + k] = mini(255, roundi(d[i + k] * 255.0 / a))
	print("MOCKCAP|ALPHA|%s|opaque=%d|partial=%d|rgb_gt_a=%d" % [label, opaque, partial, over])
	return Image.create_from_data(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8, d)


func _check_and_save(img: Image, file: String, want: Vector2i) -> void:
	if img.get_size() != want:
		_fail(file, "size %dx%d, want %dx%d" % [img.get_width(), img.get_height(), want.x, want.y])
	var flat := Image.create_empty(img.get_width(), img.get_height(), false, img.get_format())
	flat.fill(img.get_pixel(0, 0))
	if float(img.compute_image_metrics(flat, false)["max"]) == 0.0:
		_fail(file, "single colour")
	var err := img.save_png(OUT + file)
	if err != OK:
		_fail(file, "save: %s" % error_string(err))
	else:
		print("MOCKCAP|SAVED|%s%s" % [OUT, file])


func _sha1(img: Image) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA1)
	ctx.update(img.get_data())
	return ctx.finish().hex_encode()


func _fail(what: String, why: String) -> void:
	_fails += 1
	print("MOCKCAP|FAIL|%s|%s" % [what, why])
