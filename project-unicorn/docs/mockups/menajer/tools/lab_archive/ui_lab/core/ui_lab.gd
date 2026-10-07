extends Node

## UI LAB: the game's real shell (TopBar, LeftTabs, NewsTicker, the office, the Ekip and Satış
## windows, the event modal) instanced on a 1920x1080 stage whose theme is swapped live. The lab
## only watches: the clock is held, the stage takes no input, and it writes nothing but the frames
## under shots/ and the override map. README.md has the keys, the batch flag and the MCP calls.
## A plain Node, not a Control: the MCP surface needs set_theme(String), which a Control owns.

const STAGE := Vector2i(1920, 1080)
const THEMES := "res://sandbox/ui_lab/themes/"
const SHOTS := "res://sandbox/ui_lab/shots/"
const AUDIT_OUT := "res://docs/audits/UI_OVERRIDES.md"
const DIRECTIONS := ["evrak", "dosya", "gazete"]
## Screen -> the tab the shell opens; olay adds the event modal over the bare office.
const SCREENS := {"ekip": "hr", "satis": "sales", "olay": "", "bos": ""}
const SHOT_SCREENS := ["ekip", "satis", "olay"]
const DEFAULT_SCREEN := "ekip"
## Frank's cheque: scope-free, with a speaker, an effect chip and a locked row (--b2b-shot=angel).
const EVENT_CARD := "funding.frank_cheque"
const SCREEN_KEYS := {KEY_F1: "ekip", KEY_F2: "satis", KEY_F3: "olay", KEY_F4: "bos"}
const THEME_KEYS := {KEY_0: "mevcut", KEY_1: "evrak", KEY_2: "dosya", KEY_3: "gazete",
	KEY_KP_0: "mevcut", KEY_KP_1: "evrak", KEY_KP_2: "dosya", KEY_KP_3: "gazete"}
const WARM_FRAMES := 60
const SETTLE_TIMEOUT_MS := 10000

const OverrideAudit := preload("res://sandbox/ui_lab/core/override_audit.gd")
## The direction contract (11 shared names, glyph line) lives in the builder, the face rows in the
## style tile; a preload only compiles them.
const Builder := preload("res://sandbox/ui_lab/core/build_direction.gd")
const StyleTile := preload("res://sandbox/ui_lab/core/style_tile.gd")

@onready var _stage_box: SubViewportContainer = $StageBox
@onready var _stage: SubViewport = $StageBox/Stage
@onready var _theme_root: Control = $StageBox/Stage/ThemeRoot
@onready var _modal_host: Control = $StageBox/Stage/ThemeRoot/ModalHost
@onready var _tile_host: Control = $StageBox/Stage/ThemeRoot/TileHost
@onready var _hud: Label = $Hud/Box/Line

var _shell: Control
var _people: OfficePeople
var _office_vp: SubViewport
var _theme := "mevcut"
var _screen := ""
var _spec := ""                # --ui-lab-shot value; empty in an interactive run
var _queue: Array = []         # [kind, args...], run one at a time by _run_queue
var _running := false
var _mount_frame := 0
var _change_frame := 0
var _change_msec := 0
var _shown_scale := 1.0
var _last_path := ""
var _last_size := Vector2i.ZERO
var _last_error := ""
var _shots := 0
var _fails := 0
var _errors := 0


func _ready() -> void:
	TimeManager.hold_clock("ui_lab")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ui-lab-shot="):
			printerr("UI_LAB|ERROR|--ui-lab-shot arrived after '--': the run would not count as a harness run")
			get_tree().quit(2)
			return
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--ui-lab-shot="):
			_spec = arg.trim_prefix("--ui-lab-shot=")
	# The seed's names follow the locale, so it is set first; TranslationServer, not Localization,
	# which would write the player's settings.
	TranslationServer.set_locale("tr")
	var seeder = load("res://scripts/main/main.gd").new()
	seeder._seed_theme_surface()
	seeder.free()
	GameState.office_id = "ishani"
	GameState.set_current_hour(11)
	TimeManager.sync_to_current_hour()
	_shell = _instance("res://scenes/main/GameShell.tscn")
	if _shell == null:
		_finish()
		return
	_theme_root.add_child(_shell)
	_theme_root.move_child(_shell, 0)
	_shell.set_process_input(false)
	# Frozen at x=0 from its first frame, so every frame shows the same stretch of the stream.
	_shell.get_node("NewsTicker").set_process(false)
	var office: Node = _shell.get_node("MidRow/CenterViewport/OfficeView")
	_people = office.get_node("Viewport3D/SubViewport/World/People")
	_office_vp = office.get_node("Viewport3D/SubViewport")
	_mount_frame = Engine.get_process_frames()
	var router := KeyRouter.new()
	router.name = "KeyRouter"
	router.pressed.connect(_on_key)
	add_child(router)
	get_viewport().size_changed.connect(_fit_stage)
	_fit_stage()
	var keys: PackedStringArray = []
	for k in SCREEN_KEYS:
		keys.append("%s=%s" % [OS.get_keycode_string(k), SCREEN_KEYS[k]])
	for k in [KEY_0, KEY_1, KEY_2, KEY_3]:
		keys.append("%s=%s" % [OS.get_keycode_string(k), THEME_KEYS[k]])
	keys.append("%s=çek" % OS.get_keycode_string(KEY_F12))
	print("UI_LAB|KEYS|" + "|".join(keys))
	_enqueue(["audit"])
	for step in _plan(_spec):
		_enqueue(["shot", step[0], step[1]])


# --- MCP surface: String arguments or none, each call queues and returns ---

func set_screen(screen_name: String) -> void:
	_enqueue(["screen", screen_name])


func set_theme(theme_name: String) -> void:
	_enqueue(["theme", theme_name])


func shoot() -> void:
	_enqueue(["shot", "", ""])


func shoot_all() -> void:
	for step in _plan("all"):
		_enqueue(["shot", step[0], step[1]])


func status() -> Dictionary:
	return {"busy": _running or not _queue.is_empty(), "theme": _theme, "screen": _screen,
		"last_path": _last_path, "last_size": _last_size, "last_error": _last_error,
		"clock_held": TimeManager.is_clock_held(), "cb": UiTokens.is_colorblind()}


# --- Queue ---

func _enqueue(job: Array) -> void:
	_queue.append(job)
	if not _running:
		_run_queue()


func _run_queue() -> void:
	_running = true
	_refresh_hud()
	while not _queue.is_empty():
		var job: Array = _queue.pop_front()
		match job[0]:
			"audit":
				await _audit()
			"screen":
				if _apply_screen(job[1]):
					_note_settle(await _settle())
			"theme":
				if _apply_theme(job[1]):
					_note_settle(await _settle())
			"shot":
				await _shoot(job[1], job[2])
		_refresh_hud()
	_running = false
	_refresh_hud()
	if _spec != "":
		_finish()


## The batch's (theme, screen) steps. A direction without a theme.tres is skipped; named
## explicitly, its absence is an error.
func _plan(spec: String) -> Array:
	var themes: Array = []
	match spec:
		"", "audit":
			pass
		"baseline":
			themes = ["mevcut"]
		"all":
			themes = ["mevcut"]
			for d in DIRECTIONS:
				if FileAccess.file_exists(THEMES + d + "/theme.tres"):
					themes.append(d)
				else:
					print("UI_LAB|SKIP|%s|no theme.tres" % d)
		_:
			if FileAccess.file_exists(THEMES + spec + "/theme.tres"):
				themes = [spec]
			else:
				print("UI_LAB|SKIP|%s|no theme.tres" % spec)
				_errors += 1
	var steps: Array = []
	for t in themes:
		for s in SHOT_SCREENS + ([] if t == "mevcut" else ["style_tile"]):
			steps.append([t, s])
	return steps


func _finish() -> void:
	print("UI_LAB|DONE|shots=%d|fails=%d|errors=%d" % [_shots, _fails, _errors])
	get_tree().quit(1 if _fails + _errors > 0 else 0)


# --- Stage state ---

func _apply_screen(screen_name: String) -> bool:
	if screen_name == "style_tile":
		if not _mount_tile():
			_note("stil kartı yok: %s" % _theme)
			return false
		UiFactory.clear(_modal_host)
		_shell.visible = false
	elif SCREENS.has(screen_name):
		UiFactory.clear(_tile_host)
		UiFactory.clear(_modal_host)
		_shell.visible = true
		EventBus.tab_changed.emit(SCREENS[screen_name])
		if screen_name == "olay" and not _mount_modal():
			return false
	else:
		_note("ekran yok: %s" % screen_name)
		return false
	_screen = screen_name
	_mark_change()
	return true


## The theme is loaded whole before it is assigned, then the game's own repaint broadcasts run:
## pages snapshot theme items and semantic colour while they build.
func _apply_theme(theme_name: String) -> bool:
	var th: Theme = null
	if theme_name != "mevcut":
		var path := THEMES + theme_name + "/theme.tres"
		if not FileAccess.file_exists(path):
			_note("tema yok: %s" % theme_name)
			return false
		# REPLACE: a theme rebuilt while the lab runs is read again, not served from the cache.
		th = ResourceLoader.load(path, "Theme", ResourceLoader.CACHE_MODE_REPLACE) as Theme
		if th == null:
			_note("tema yüklenemedi: %s" % theme_name)
			_errors += 1
			return false
	_theme_root.theme = th
	_theme = theme_name
	EventBus.palette_changed.emit(UiTokens.is_colorblind())
	EventBus.news_stream_changed.emit()
	match _screen:
		"olay":
			_mount_modal()
		"style_tile":
			if not _mount_tile():
				_apply_screen(DEFAULT_SCREEN)
	if th != null:
		_report_theme(theme_name, th)
	_mark_change()
	return true


func _mount_modal() -> bool:
	UiFactory.clear(_modal_host)
	var ev: GameEvent = EventGate.render(EVENT_CARD)
	var modal: Node = _instance("res://scenes/modals/EventModal.tscn") if ev != null else null
	if modal == null:
		_note("olay modalı kurulamadı")
		return false
	_modal_host.add_child(modal)
	modal.populate(ev)
	return true


## The direction's style tile carries its own theme; the shell is hidden behind it.
func _mount_tile() -> bool:
	UiFactory.clear(_tile_host)
	var path := THEMES + _theme + "/StyleTile.tscn"
	if not FileAccess.file_exists(path):
		return false
	var tile := _instance(path)
	if tile == null:
		return false
	_tile_host.add_child(tile)
	return true


func _instance(path: String) -> Node:
	var scene := load(path) as PackedScene
	var node: Node = scene.instantiate() if scene != null else null
	if node == null:
		print("UI_LAB|INSTANCE_FAIL|%s|yüklenemedi" % path)
		_errors += 1
	return node


func _report_theme(theme_name: String, th: Theme) -> void:
	var declared := Builder.CANON.keys().filter(func(t: String) -> bool: return th.get_type_variation_base(t) != &"")
	print("UI_LAB|THEME|%s|%d/%d" % [theme_name, declared.size(), Builder.CANON.size()])
	var ts := TextServerManager.get_primary_interface()
	# The title, body and data faces, as the style tile's face rows draw them.
	for face in StyleTile.FACES:
		var drawn: Font = th.get_font(&"font", face[1])
		var font := drawn
		while font is FontVariation:
			font = (font as FontVariation).base_font
		# Font.has_char counts fallbacks, and the import lets the OS fill gaps: ask the file itself.
		var file := font as FontFile
		var found := 0
		if file != null:
			var rid: RID = file.get_rids()[0]
			for i in Builder.GLYPHS.length():
				if ts.font_has_char(rid, Builder.GLYPHS.unicode_at(i)):
					found += 1
		print("UI_LAB|GLYPH|%s|%s|%s|%d/%d" % [theme_name, face[0],
			Builder.face_name(drawn) if file != null else "null", found, Builder.GLYPHS.length()])


func _mark_change() -> void:
	_change_frame = Engine.get_process_frames()
	_change_msec = Time.get_ticks_msec()
	_last_error = ""


# --- Settle and capture ---

## Waits until the stage stops changing. Returns "" when it has, else the condition still unmet
## at the timeout.
func _settle() -> String:
	var start := Time.get_ticks_msec()
	var last_sum := 0
	var stable := -1
	var unmet := ""
	while Time.get_ticks_msec() - start <= SETTLE_TIMEOUT_MS:
		unmet = _unmet()
		if unmet.is_empty():
			var sum := _rect_sum()
			stable = stable + 1 if stable >= 0 and sum == last_sum else 0
			last_sum = sum
			if stable >= 2:
				return ""
			unmet = "dikdörtgenler oturmadı"
		else:
			stable = -1
		await get_tree().process_frame
	return unmet


func _unmet() -> String:
	var frames := Engine.get_process_frames()
	if not _people._placed:
		return "kişiler yerleşmedi"
	if frames - _mount_frame < WARM_FRAMES:
		return "ısınma kareleri"
	if frames - _change_frame < 3:
		return "değişiklikten beri 3 kare"
	if Time.get_ticks_msec() - _change_msec < 400:
		return "değişiklikten beri 0,4 sn"
	# A looping tween never ends: it holds the capture until the timeout names it.
	for t in get_tree().get_processed_tweens():
		if t.is_running():
			return "süren tween"
	# Avatars are drawn one a frame by PersonBust's studio after the row asking for them.
	var studio := PersonBust._studio
	if studio != null and (studio._busy or not studio._queue.is_empty()):
		return "portreler"
	return ""


func _rect_sum() -> int:
	var acc := PackedFloat32Array()
	for c: Control in _theme_root.find_children("*", "Control", true, false):
		if c.is_visible_in_tree():
			var r := c.get_global_rect()
			acc.append_array([r.position.x, r.position.y, r.size.x, r.size.y])
	return hash(acc)


func _shoot(theme_name: String, screen_name: String) -> void:
	var target_theme := theme_name if theme_name != "" else _theme
	var target_screen := screen_name if screen_name != "" else _screen
	var label := "%s/%s" % [target_theme, target_screen]
	if target_theme != _theme and not _apply_theme(target_theme):
		_shot_fail(label, "tema kurulamadı")
		return
	if target_screen == "style_tile" and not FileAccess.file_exists(THEMES + _theme + "/StyleTile.tscn"):
		print("UI_LAB|SKIP|%s|no StyleTile.tscn" % label)
		return
	if target_screen != _screen and not _apply_screen(target_screen):
		_shot_fail(label, "ekran kurulamadı")
		return
	var unmet := await _settle()
	if not unmet.is_empty():
		_shot_fail(label, "bekleme: " + unmet)
		return
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED:
		_shot_fail(label, "pencere küçültülmüş, kare çizilmiyor")
		return
	await RenderingServer.frame_post_draw
	var img := _stage.get_texture().get_image()
	if img.get_size() != STAGE:
		_shot_fail(label, "boyut %dx%d" % [img.get_width(), img.get_height()])
		return
	var flat := Image.create_empty(img.get_width(), img.get_height(), false, img.get_format())
	flat.fill(img.get_pixel(0, 0))
	if float(img.compute_image_metrics(flat, false)["max"]) == 0.0:
		_shot_fail(label, "tek renk")
		return
	var folder := "baseline" if target_theme == "mevcut" else target_theme
	var path := "%s%s/%s.png" % [SHOTS, folder, target_screen]
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var err := img.save_png(path)
	if err != OK:
		_shot_fail(label, "yazılamadı: %s" % error_string(err))
		return
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA1)
	ctx.update(_office_vp.get_texture().get_image().get_data())
	print("UI_LAB|SHOT|%s|sha256=%s|office_hash=%s|data_fp=%s|cb=%d|theme=%s|screen=%s" % [path,
		FileAccess.get_sha256(path), ctx.finish().hex_encode(), _data_fp(),
		int(UiTokens.is_colorblind()), target_theme, target_screen])
	_shots += 1
	_last_path = path
	_last_size = img.get_size()
	_last_error = ""


func _shot_fail(label: String, reason: String) -> void:
	print("UI_LAB|SHOT_FAIL|%s|%s" % [label, reason])
	_fails += 1
	_last_error = "%s: %s" % [label, reason]


## The world every frame shows; equal across frames means the same data was on screen.
func _data_fp() -> String:
	var parts := [GameState.run_seed, GameState.day, GameState.current_hour, GameState.office_id,
		GameState.cash, GameState.mrr]
	for list in [CharacterRegistry.get_all(), CustomerRegistry.get_all(), ProspectRegistry.get_all()]:
		var ids := PackedStringArray(list.map(func(x: Object) -> String: return String(x.get("id"))))
		ids.sort()
		parts.append(",".join(ids))
	return "|".join(PackedStringArray(parts.map(func(p: Variant) -> String: return str(p)))).sha1_text()


# --- Override audit: every screen once under the current theme, before anything else ---

func _audit() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var audit := OverrideAudit.new()
	for screen_name in SCREENS:
		_apply_screen(screen_name)
		var unmet := await _settle()
		if not unmet.is_empty():
			print("UI_LAB|AUDIT_FAIL|%s|bekleme: %s" % [screen_name, unmet])
			_errors += 1
		audit.walk(_shell, screen_name)
		for modal in _modal_host.get_children():
			audit.walk(modal, screen_name)
	if not audit.write(AUDIT_OUT):
		_errors += 1
	_apply_screen(DEFAULT_SCREEN)
	_note_settle(await _settle())


# --- Keys, HUD, display ---

func _on_key(keycode: Key) -> void:
	if SCREEN_KEYS.has(keycode):
		set_screen(SCREEN_KEYS[keycode])
	elif THEME_KEYS.has(keycode):
		set_theme(THEME_KEYS[keycode])
	elif keycode == KEY_F12:
		shoot()


func _note(message: String) -> void:
	_last_error = message
	_refresh_hud()


func _note_settle(unmet: String) -> void:
	if not unmet.is_empty():
		_note("oturmadı: " + unmet)


func _refresh_hud() -> void:
	var state := "hazır"
	if _running or not _queue.is_empty():
		state = "meşgul"
	elif not _last_error.is_empty():
		state = "uyarı: " + _last_error
	elif not _last_path.is_empty():
		state = "son kare: " + _last_path.trim_prefix(SHOTS)
	_hud.text = "tema %s · ekran %s · palet %s · ölçek %%%d · %s" % [_theme, _screen,
		"renk körü" if UiTokens.is_colorblind() else "standart", roundi(_shown_scale * 100.0), state]


## Shows the stage at one stage pixel per screen pixel, smaller only when the window cannot hold it.
## The root's canvas_items stretch is divided out; the window itself is never touched.
func _fit_stage() -> void:
	var win := Vector2(get_window().size)
	var logical := get_viewport().get_visible_rect().size
	if win.x <= 0.0 or logical.x <= 0.0:
		return
	var stretch := win.x / logical.x
	_shown_scale = minf(1.0, minf(win.x / STAGE.x, win.y / STAGE.y))
	_stage_box.scale = Vector2.ONE * _shown_scale / stretch
	_stage_box.position = ((win - Vector2(STAGE) * _shown_scale) / 2.0).floor() / stretch
	_refresh_hud()


## Last child of the lab, so it sees every key and click before the stage does and swallows them
## all: no game handler (debug F-keys, 1-4 speed, F5 quicksave, a click that resolves a card) runs.
class KeyRouter extends Node:
	signal pressed(keycode: Key)

	func _input(event: InputEvent) -> void:
		if not (event is InputEventKey or event is InputEventMouseButton):
			return
		get_viewport().set_input_as_handled()
		var key := event as InputEventKey
		if key != null and key.pressed and not key.echo:
			pressed.emit(key.keycode)
