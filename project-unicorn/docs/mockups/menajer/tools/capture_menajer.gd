extends SceneTree

## Throwaway art capture for the Menajer Masası mockups (Faz A). Windowed -s driver, one Godot at a
## time, run through run_godot.sh. Modes from --menajer-shot=<plates|busts|portraits|heads|probe>
## (comma list allowed). Autoloads are reached through the tree; project classes are touched only
## inside menajer_studio.gd and through load(), which compile after the autoloads exist.
##
## plates    OfficeView in a stage, the camera fitted to the new shell's visible office region
##           (top bar 64, rail 184, ticker 40): ishani at 1920/1536/2560 logical widths, plus the
##           other offices, the meeting room and the city map at 1920. Reads the inner 3D viewport.
## busts     PersonBust (the game's studio) for the four funds' people, the two prospects' people
##           and the crowd40 roster; raw premultiplied images to RAW, the roster to data/crowd40.json.
## portraits menajer_studio half-body 4:5 portraits (Frank candidates, 11 founders) and the in-game
##           bust framing faces; raw to RAW, post_portraits.py makes the PNGs.
## heads     exploration sheet: every male head in grey hair and a suit.
## probe     prints bone heights for framing.

const ROOT := "C:/Users/erdem/Desktop/project steam/project-unicorn/docs/mockups/menajer/"
const ART := ROOT + "art/"
const DATA := ROOT + "data/"
const RAW := "C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/0e406678-a661-4d23-90af-2e43deb375cc/scratchpad/menajer_raw/"
const STUDIO := "res://docs/mockups/menajer/tools/menajer_studio.gd"
const TIMEOUT_MS := 30000
const STAGE := Vector2i(2560, 1080)
## The shell over the office: top bar, rail, ticker (logical px).
const TOP := 64
const RAIL := 184
const TICKER := 40
const MEET_FUND := "meridian"
const DOCK_SHARE := 0.34
const FUNDS := ["anchor", "nexus", "bosphorus", "meridian"]

## PersonBust's own camera (person_bust.gd) and the portrait frame (tunable by flags).
const BUST_FRAME := 0.5
const BUST_HEAD_TOP := 0.22
const BUST_TEXEL := 1.15
const TURN := 0.42
const RISE := 0.12
const IDLE := ["ual1/Idle", 0.4]

## Frank candidates (Faz A3). Male, late fifties: grey hair (hair palette 7), a jacket, calm.
const FRANK := {
	# a: full grey beard and hair (m_king), mid grey suit, burgundy tie, no glasses.
	"a": {"sex": "m", "head": "m_king", "body": "m_suit", "legs": "m_suit", "feet": "m_suit", "skin": 2, "hair": 7,
		"top": 2, "top2": 0, "tie": 0, "bottom": -1, "shoe": 1, "height": 3, "girth": 2, "glasses": false},
	# b: swept grey hair (m_suit), navy suit, pale blue shirt, navy tie, glasses.
	"b": {"sex": "m", "head": "m_suit", "body": "m_suit", "legs": "m_suit", "feet": "m_suit", "skin": 1, "hair": 7,
		"top": 0, "top2": 1, "tie": 1, "bottom": -1, "shoe": 1, "height": 2, "girth": 1, "glasses": true},
	# c: grey crew cut and moustache (m_worker), taupe suit, cream shirt, dark green tie, no glasses.
	"c": {"sex": "m", "head": "m_worker", "body": "m_suit", "legs": "m_suit", "feet": "m_suit", "skin": 2, "hair": 7,
		"top": 6, "top2": 3, "tie": 4, "bottom": -1, "shoe": 2, "height": 2, "girth": 2, "glasses": false},
	# d: long grey hair tied back (m_casual), sage suit, white shirt open at the collar, glasses, tall and lean.
	"d": {"sex": "m", "head": "m_casual", "body": "m_suit", "legs": "m_suit", "feet": "m_suit", "skin": 1, "hair": 7,
		"top": 7, "top2": 0, "tie": -1, "bottom": -1, "shoe": 1, "height": 4, "girth": 0, "glasses": true},
}

var _fails := 0
var _stage: SubViewport
var _studio: Node
var _gs: Node
var _tm: Node
var _reg: Node
var _flags := {}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	_tm = root.get_node("/root/TimeManager")
	_tm.hold_clock("menajer")
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--") and "=" in arg:
			_flags[arg.get_slice("=", 0).trim_prefix("--")] = arg.get_slice("=", 1)
	var modes: PackedStringArray = String(_flags.get("menajer-shot", "probe")).split(",")
	print("MENAJER|START|modes=%s|display=%s|paused=%s" % [",".join(modes), DisplayServer.get_name(), paused])
	TranslationServer.set_locale("tr")
	var seeder = load("res://scripts/main/main.gd").new()
	seeder._seed_theme_surface()
	seeder.free()
	_gs = root.get_node("/root/GameState")
	_reg = root.get_node("/root/CharacterRegistry")
	# initialize_run draws the funds' people before main.gd pins run_seed 424242, so they change
	# every launch. Redraw them as a run seeded 424242 would at its start (only the founder around).
	var cs: Script = load("res://scripts/systems/counterpart_system.gd")
	var around := [_reg.get_founder().look]
	_gs.investor_people.clear()
	for inv: Dictionary in root.get_node("/root/InvestorRegistry").get_active():
		_gs.investor_people[inv.id] = cs._people_for(inv.id, cs.FUND_ROLES, around, inv.get("lead_sex", ""))
	print("MENAJER|FUNDS|run_seed=%d|%s" % [_gs.run_seed, ", ".join(_gs.investor_people.keys().map(
		func(k: String) -> String: return "%s:%s" % [k, " / ".join(_gs.investor_people[k].map(
			func(q: Dictionary) -> String: return q.name))]))])
	_gs.office_id = "ishani"
	_gs.set_current_hour(11)
	_tm.sync_to_current_hour()
	print("MENAJER|SEED|day=%s|hour=%s|day_minute=%s|office=%s|name_lang=%s" % [_gs.day, _gs.current_hour,
		_tm.day_minute(), _gs.office_id, _gs.name_lang])
	DirAccess.make_dir_recursive_absolute(RAW)
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
	_studio = (load(STUDIO) as Script).new()
	root.add_child(_studio)
	await process_frame
	await process_frame
	for m in modes:
		match m:
			"probe":
				_probe()
			"heads":
				await _heads()
			"plates":
				await _plates()
			"busts":
				await _busts()
			"portraits":
				await _portraits()
			_:
				_fail("mode", "unknown " + m)
	print("MENAJER|DONE|fails=%d" % _fails)
	quit(1 if _fails > 0 else 0)


# ---------------------------------------------------------------------------------------------
# Plates
# ---------------------------------------------------------------------------------------------

func _plates() -> void:
	var only: String = _flags.get("plate", "")
	var jobs := [
		["ishani", Vector2i(1920, 1080), "office_safe_1920", true],
		["ishani", Vector2i(1536, 864), "office_safe_1536", true],
		["ishani", Vector2i(2560, 1080), "office_safe_2560", true],
		["home", Vector2i(1920, 1080), "office_safe_1920_home", true],
		["plaza", Vector2i(1920, 1080), "office_safe_1920_plaza", true],
		["loft", Vector2i(1920, 1080), "office_safe_1920_loft", true],
		["meet", Vector2i(1920, 1080), "office_safe_1920_meet", false],
		["city", Vector2i(1920, 1080), "office_safe_1920_city", false],
	]
	for j in jobs:
		if only != "" and not (j[2] as String).ends_with(only) and j[0] != only:
			continue
		var screen: Vector2i = j[1]
		var size := Vector2i(screen.x - RAIL, screen.y - TOP - TICKER)
		await _plate(j[0], size, j[2], j[3])


func _plate(which: String, size: Vector2i, stem: String, staffed: bool) -> void:
	_gs.office_id = which if staffed else "ishani"
	var host := Control.new()
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.size = Vector2(size)
	_stage.add_child(host)
	var office: Control = (load("res://scenes/office/OfficeView.tscn") as PackedScene).instantiate()
	host.add_child(office)
	var people: Node = office.get_node("Viewport3D/SubViewport/World/People")
	var vp: SubViewport = office.get_node("Viewport3D/SubViewport")
	var start := Time.get_ticks_msec()
	if staffed:
		while not people._placed:
			if Time.get_ticks_msec() - start > TIMEOUT_MS:
				_fail(stem, "people never placed")
				host.queue_free()
				return
			await process_frame
		print("MENAJER|PLACED|%s|after_ms=%d|actors=%d" % [stem, Time.get_ticks_msec() - start, people._actors.size()])
	else:
		for i in 10:
			await process_frame
		if which == "meet":
			office.load_layout("meet")
			var side: Array = _gs.investor_people.get(MEET_FUND, [])
			office.cast.stage(side.map(func(q: Dictionary) -> Dictionary: return q.look),
				_reg.get_founder().look, true)
			_meeting_posts(office.cast)
		elif which == "city":
			office.load_layout("city")
		await create_timer(1.5, true).timeout
	for i in 60:
		await process_frame
	await RenderingServer.frame_post_draw
	var img := vp.get_texture().get_image()
	_save(img, ART + stem + ".png", size)
	print("MENAJER|PLATE|%s|size=%dx%d|office_size=%s|view=%s" % [stem, img.get_width(), img.get_height(),
		office.size, vp.size])
	if staffed:
		_anchors(office, people, ART + stem + "_heads.json")
		# The same frame without the head icons, for redrawn icons over it.
		people.set_process(false)
		for a in people._actors.values():
			a._icon.visible = false
		for i in 10:
			await process_frame
		await RenderingServer.frame_post_draw
		_save(vp.get_texture().get_image(), ART + stem + "_noicons.png", size)
	if which == "meet":
		office.cast.frame_table(size.x * DOCK_SHARE)
		for i in 30:
			await process_frame
		await RenderingServer.frame_post_draw
		_save(vp.get_texture().get_image(), ART + stem + "_dock.png", size)
	if which == "city":
		_city_chips(office, ART + stem + "_chips.json")
	host.queue_free()
	await process_frame
	await process_frame


## The meeting shots' table at rest (main.gd _shot_meeting_posts).
func _meeting_posts(cast: Node) -> void:
	cast.post(0, {"arms": "table"})
	cast.post(1, {"arms": "table", "lean": 0.05})
	cast.post(2, {"arms": "rest", "lean": -0.1})
	cast.post(3, {"write": true})
	for who in range(1, cast.count()):
		cast.look(who, 0)
	cast.look(0, 1)


## Where each visible person's head icon and head sit on the plate, and what the icon says.
func _anchors(office: Control, people: Node, path: String) -> void:
	var cam: Camera3D = office.camera
	var out := []
	for a in people._actors.values():
		if not a.visible:
			continue
		var icon_at: Vector2 = cam.unproject_position(a.marker())
		var head_at: Vector2 = cam.unproject_position(a._head.global_position)
		var feet_at: Vector2 = cam.unproject_position(a.global_position)
		out.append({"id": a.character.id, "name": a.character.character_name, "status": a.status,
			"icon_visible": a._icon.visible, "founder": a.founder,
			"icon_xy": [roundi(icon_at.x), roundi(icon_at.y)], "head_xy": [roundi(head_at.x), roundi(head_at.y)],
			"feet_xy": [roundi(feet_at.x), roundi(feet_at.y)],
			"icon_px": roundi(_icon_px(cam, a))})
	_write_json(path, {"note": "Plate pixel coordinates (plate origin top left). Icons are the 3D head sprites.",
		"people": out})


func _icon_px(cam: Camera3D, a: Node) -> float:
	var p: Vector3 = a.marker()
	var s: float = (a._icon as Sprite3D).scale.x
	return cam.unproject_position(p + cam.global_basis.y * s * 0.5).distance_to(
		cam.unproject_position(p - cam.global_basis.y * s * 0.5))


func _city_chips(office: Control, path: String) -> void:
	var city: Node = office.get_node("Viewport3D/SubViewport/World/City")
	var out := []
	for c: Array in city._chips:
		var chip: Control = c[1]
		var texts := []
		for l in chip.find_children("*", "Label", true, false):
			texts.append((l as Label).text)
		out.append({"office": (c[0] as Dictionary).get("office", ""), "texts": texts, "visible": chip.visible,
			"xy": [roundi(chip.position.x), roundi(chip.position.y)], "size": [roundi(chip.size.x), roundi(chip.size.y)]})
	_write_json(path, {"note": "The map's 2D chips (drawn in the Overlay, not in the plate), plate coordinates.",
		"chips": out})


# ---------------------------------------------------------------------------------------------
# Busts (the game's PersonBust studio)
# ---------------------------------------------------------------------------------------------

func _busts() -> void:
	var pb: Script = load("res://scripts/ui/office/person_bust.gd")
	var jobs := []   # [stem, tex, px]
	var people := {"funds": {}, "prospects": []}
	for vc: String in FUNDS:
		var side: Array = _gs.investor_people.get(vc, [])
		if side.size() != 3:
			_fail("fund " + vc, "people %d" % side.size())
		var list := []
		for i in side.size():
			var q: Dictionary = side[i]
			var stem := "%s_%d_%s" % [vc, i, q.role]
			list.append({"role": q.role, "name": q.name, "title": _counterpart_title(q, vc), "look": q.look,
				"bust512": "art/busts/vc/bust_%s.png" % stem, "bust192": "art/busts/vc/bust192_%s.png" % stem,
				"bust64": "art/busts/vc/bust64_%s.png" % stem})
			jobs.append(["vc/bust_" + stem, pb.texture(q.look, 256), 512])
			jobs.append(["vc/bust192_" + stem, pb.texture(q.look, 96), 192])
			jobs.append(["vc/bust64_" + stem, pb.texture(q.look, 32), 64])
		var inv: Dictionary = root.get_node("/root/InvestorRegistry").get_investor(vc)
		people.funds[vc] = {"display_name": inv.get("display_name", ""), "people": list}
	var cs: Script = load("res://scripts/systems/counterpart_system.gd")
	for p in root.get_node("/root/ProspectRegistry").get_all():
		var side: Array = cs.prospect_people(p)
		var list := []
		for i in side.size():
			var q: Dictionary = side[i]
			var stem := "%s_%d_%s" % [p.id, i, q.role]
			list.append({"role": q.role, "name": q.name, "title": _counterpart_title(q, ""), "look": q.look,
				"bust512": "art/busts/prospect/bust_%s.png" % stem, "bust192": "art/busts/prospect/bust192_%s.png" % stem,
				"bust64": "art/busts/prospect/bust64_%s.png" % stem})
			jobs.append(["prospect/bust_" + stem, pb.texture(q.look, 256), 512])
			jobs.append(["prospect/bust192_" + stem, pb.texture(q.look, 96), 192])
			jobs.append(["prospect/bust64_" + stem, pb.texture(q.look, 32), 64])
		people.prospects.append({"id": p.id, "company": p.company_name, "star": p.star, "industry": p.industry,
			"people": list})
	_write_json(ART + "busts/counterparts.json", people)
	await _drain(pb, "busts")
	for j in jobs:
		_save_raw((j[1] as ImageTexture).get_image(), "busts/" + j[0] + ".png", Vector2i(j[2], j[2]))
	# The crowd40 roster: forty with the fixture's five and the founder (main.gd --office-shot crowd40).
	load("res://scripts/debug/office_crowd_probe.gd").seed_staff(34)
	var roster := [_reg.get_founder()]
	roster.append_array(_reg.get_employees())
	var rows := []
	var cjobs := []
	var hr: Script = load("res://scripts/systems/hr_constants.gd")
	for i in roster.size():
		var c: Object = roster[i]
		var stem := "%02d_%s" % [i, c.id]
		var row := _character_row(c, hr)
		row["index"] = i
		row["bust64"] = "art/busts/crowd40/bust64_%s.png" % stem
		rows.append(row)
		cjobs.append(["crowd40/bust64_" + stem, pb.texture(c.look, 32), 64])
	print("MENAJER|CROWD|roster=%d" % roster.size())
	if roster.size() != 40:
		_fail("crowd40", "roster %d" % roster.size())
	_write_json(DATA + "crowd40.json", {"source": "main.gd _seed_theme_surface (run_seed 424242, week 14) then OfficeCrowdProbe.seed_staff(34), as --office-shot=<office>:<hour>:crowd40; order = founder, then CharacterRegistry.get_employees()",
		"count": rows.size(), "people": rows})
	await _drain(pb, "crowd")
	for j in cjobs:
		_save_raw((j[1] as ImageTexture).get_image(), "busts/" + j[0] + ".png", Vector2i(j[2], j[2]))


func _counterpart_title(q: Dictionary, vc: String) -> String:
	var cs: Script = load("res://scripts/systems/counterpart_system.gd")
	return cs.title(q, vc)


func _character_row(c: Object, hr: Script) -> Dictionary:
	var row := {}
	for p in c.get_property_list():
		if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and p.usage & PROPERTY_USAGE_STORAGE:
			var v: Variant = c.get(p.name)
			row[p.name] = v
	row["role_label"] = hr.role_label(c.role) if c.category == "employee" else tr("HR_ROLE_FOUNDER")
	var tl := []
	var te := []
	for t: String in c.traits:
		if c.category == "founder":
			tl.append(tr("TRAIT_%s_NAME" % t.to_upper()))
			te.append(tr("TRAIT_%s_EFFECT" % t.to_upper()))
		else:
			tl.append(hr.trait_label(t))
			te.append(hr.trait_effect_text(t))
	row["trait_labels"] = tl
	row["trait_effects"] = te
	var jl := []
	for j: String in c.assigned_job_ids:
		jl.append(hr.job_label(j) if hr.is_job(j) else j)
	row["job_labels"] = jl
	row["level_label"] = hr.level_label(c.level)
	return row


func _drain(pb: Script, what: String) -> void:
	var start := Time.get_ticks_msec()
	while true:
		var s = pb._studio
		if s != null and s.is_inside_tree() and not s._busy and s._queue.is_empty():
			break
		if Time.get_ticks_msec() - start > TIMEOUT_MS * 4:
			_fail(what, "studio never idle")
			return
		await process_frame
	await process_frame
	await RenderingServer.frame_post_draw


# ---------------------------------------------------------------------------------------------
# Portraits (menajer_studio)
# ---------------------------------------------------------------------------------------------

func _portraits() -> void:
	var w := int(_flags.get("pf-w", "1280"))
	var h := int(_flags.get("pf-h", "1600"))
	var frame_h := float(_flags.get("pf-frame", "0.66"))
	var head_top := float(_flags.get("pf-headtop", "0.29"))
	var texel := float(_flags.get("pf-texel", "10.9"))
	var turn := float(_flags.get("pf-turn", "0.3"))
	var pose := [String(_flags.get("pf-pose", IDLE[0])), float(_flags.get("pf-at", str(IDLE[1])))]
	var which: String = _flags.get("pf-which", "frank,founders")
	var tag: String = _flags.get("pf-tag", "")
	var on_torso: bool = _flags.get("pf-centre", "torso") == "torso"
	var meta := {"render": [w, h], "frame_h": frame_h, "head_from_top": head_top, "texel": texel, "turn": turn,
		"rise": RISE, "pose": pose, "centre": "torso" if on_torso else "head", "face": {"render": [128, 128], "frame_h": BUST_FRAME, "head_from_top": BUST_HEAD_TOP,
		"texel": BUST_TEXEL, "turn": TURN, "rise": RISE, "pose": IDLE}, "looks": {}}
	var jobs := []
	if "frank" in which:
		for k: String in FRANK:
			jobs.append(["frank_cand_" + k, FRANK[k]])
	if "founders" in which:
		var ls: Script = load("res://scripts/systems/look_system.gd")
		for i in (ls.FOUNDER_LOOKS as Array).size():
			jobs.append(["founder_%02d" % (i + 1), (ls.FOUNDER_LOOKS[i] as Dictionary).duplicate()])
	if "extra" in which:
		for k: String in _extra_looks():
			jobs.append([k, _extra_looks()[k]])
	for j in jobs:
		var look: Dictionary = j[1]
		var big: Image = await _studio.shoot(look, Vector2i(w, h), frame_h, head_top, texel, pose, turn, RISE, on_torso)
		_save_raw(big, "portraits/%s%s.png" % [j[0], tag], Vector2i(w, h))
		var face: Image = await _studio.shoot(look, Vector2i(128, 128), BUST_FRAME, BUST_HEAD_TOP, BUST_TEXEL, IDLE, TURN, RISE)
		_save_raw(face, "portraits/%s%s_face128.png" % [j[0], tag], Vector2i(128, 128))
		var face32: Image = await _studio.shoot(look, Vector2i(64, 64), BUST_FRAME, BUST_HEAD_TOP, BUST_TEXEL, IDLE, TURN, RISE)
		_save_raw(face32, "portraits/%s%s_face64r.png" % [j[0], tag], Vector2i(64, 64))
		meta.looks[j[0]] = look
		print("MENAJER|PORTRAIT|%s|sig=%s" % [j[0], load("res://scripts/systems/look_system.gd").signature(look)])
	_write_json(RAW + "portraits/meta%s.json" % tag, meta)


func _extra_looks() -> Dictionary:
	return {}


# ---------------------------------------------------------------------------------------------
# Exploration
# ---------------------------------------------------------------------------------------------

func _heads() -> void:
	var heads := ["m_suit", "m_casual", "m_hoodie", "m_beach", "m_adventurer", "m_king", "m_worker", "m_farmer"]
	for hd: String in heads:
		for hair in [7, 0]:
			var look := {"sex": "m", "head": hd, "body": "m_suit", "legs": "m_suit", "feet": "m_suit", "skin": 1,
				"hair": hair, "top": 1, "top2": 0, "tie": 0, "bottom": -1, "shoe": 1, "height": 2, "girth": 1, "glasses": false}
			var img: Image = await _studio.shoot(look, Vector2i(320, 320), BUST_FRAME, BUST_HEAD_TOP, 2.0, IDLE, TURN, RISE)
			_save_raw(img, "heads/%s_h%d.png" % [hd, hair], Vector2i(320, 320))
	for pose in [["ual1/Idle", 0.4], ["ual2/Idle_FoldArms", 0.5], ["m2m/Idle_Subtle", 0.5], ["m2m/Idle Listening", 0.5]]:
		var img: Image = await _studio.shoot(FRANK.b, Vector2i(400, 500), 0.9, 0.2, 2.0, pose, TURN, RISE)
		_save_raw(img, "heads/pose_%s.png" % (pose[0] as String).replace("/", "_").replace(" ", "_"), Vector2i(400, 500))


func _probe() -> void:
	var ls: Script = load("res://scripts/systems/look_system.gd")
	for look in [FRANK.b, ls.FOUNDER_LOOKS[0], ls.FOUNDER_LOOKS[1]]:
		var b: Dictionary = _studio.bones(look, IDLE)
		var line := []
		for k in b:
			line.append("%s=%.3f,%.3f,%.3f" % [k, b[k].x, b[k].y, b[k].z])
		print("MENAJER|BONES|%s|%s" % [look.head, " ".join(line)])


# ---------------------------------------------------------------------------------------------
# Files
# ---------------------------------------------------------------------------------------------

func _save(img: Image, path: String, want: Vector2i) -> void:
	if img.get_size() != want:
		_fail(path, "size %dx%d, want %dx%d" % [img.get_width(), img.get_height(), want.x, want.y])
	var flat := Image.create_empty(img.get_width(), img.get_height(), false, img.get_format())
	flat.fill(img.get_pixel(0, 0))
	if float(img.compute_image_metrics(flat, false)["max"]) == 0.0:
		_fail(path, "single colour")
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var err := img.save_png(path)
	if err != OK:
		_fail(path, "save: %s" % error_string(err))
	else:
		print("MENAJER|SAVED|%s" % path)


func _save_raw(img: Image, rel: String, want: Vector2i) -> void:
	img.convert(Image.FORMAT_RGBA8)
	_save(img, RAW + rel, want)


func _write_json(path: String, data: Variant) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		_fail(path, "open")
		return
	f.store_string(JSON.stringify(data, "  ", false))
	f.close()
	print("MENAJER|JSON|%s" % path)


func _fail(what: String, why: String) -> void:
	_fails += 1
	print("MENAJER|FAIL|%s|%s" % [what, why])
