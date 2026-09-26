class_name DisplaySettings
extends RefCounted

# DisplaySettings — the live display engine (window mode / resolution / vsync /
# UI scale). All static; holds no state. Settings persists, DisplaySettings applies:
# the only write here is the UI-scale correction in apply_ui_scale.
#
# THE HARNESS RULE: the debug screenshot runners and the smoke suite OWN the window
# (the shot runners size it to 1920×1080 by hand so frames are comparable; smoke runs
# headless). is_inert() is that guard, and every DisplayServer/Window call sits behind it.

# Godot's WINDOW_MODE_FULLSCREEN is BORDERLESS windowed-fullscreen, while
# WINDOW_MODE_EXCLUSIVE_FULLSCREEN is real fullscreen. The ids map to what the words mean.
const MODE_FULLSCREEN := "fullscreen"     # Tam ekran   → EXCLUSIVE_FULLSCREEN
const MODE_BORDERLESS := "borderless"     # Kenarlıksız → FULLSCREEN (borderless windowed)
const MODE_WINDOWED := "windowed"         # Pencereli   → WINDOWED

# Dropdown order; index ↔ id for the OptionButton.
const MODE_ORDER: Array[String] = [MODE_FULLSCREEN, MODE_BORDERLESS, MODE_WINDOWED]
const MODE_KEYS: Array[String] = ["SET_WINDOW_FULLSCREEN", "SET_WINDOW_BORDERLESS", "SET_WINDOW_WINDOWED"]

# 1280×720 is the MINIMUM, so it is never filtered away. Real panel sizes (laptop
# 2880x1800 etc.) fit no fixed list; available_resolutions() adds the measured native.
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1680, 1050),   # 16:10
	Vector2i(1920, 1080),
	Vector2i(1920, 1200),   # 16:10
	Vector2i(2560, 1080),   # 21:9
	Vector2i(2560, 1440),
	Vector2i(2560, 1600),   # 16:10
	Vector2i(3440, 1440),   # 21:9
	Vector2i(3840, 1600),   # 21:9 UWQHD+
	Vector2i(3840, 2160),
	Vector2i(3840, 2400),   # 16:10
	Vector2i(5120, 1440),   # 32:9
]

## 16:9 (1.778) ile 16:10 (1.600) arasını ayıracak kadar dar, aynı ailedeki küçük
## yuvarlama farklarını (1366x768 = 1.779) yutacak kadar geniş.
const ASPECT_EPSILON := 0.05

# UI scale is applied through the root Window's content_scale_factor, which multiplies
# the project's canvas_items stretch (aspect "expand", base 1920×1080).
## Adımların TEK KAYNAĞI: is_step_allowed üyeliği buradan okur, yani listede olmayan
## bir değer (elle düzenlenmiş settings.json) uygulanamaz ve clamp_step onu merdivene
## çeker. Tavan %125: content_scale_factor mantıksal viewport'u KÜÇÜLTÜR ve 1080p'de
## daha büyük bir adımda SettingsModal'ın sabit yükseklikli paneli ekrana sığmaz.
const UI_SCALE_STEPS: Array[float] = [0.75, 0.90, 1.00, 1.10, 1.25]

## The readability floor, in PHYSICAL pixels, checked after BOTH multipliers:
## UiTokens.SIZE_MICRO is exactly 9, so the player must never shrink the smallest
## type below its authored size. At 1920×1080 the 75% and 90% steps are therefore
## disabled; 90% unlocks around 1200px of height, 75% at 1440p.
const MIN_READABLE_FONT_PX := 9

# 9 * 0.75 * (1440.0/1080.0) evaluates to 8.999999999999998 — the exact 1440p case the
# design intends to ALLOW would fail a naive `>=`.
const READABLE_EPSILON := 0.01

const BASE_VIEWPORT := Vector2(1920.0, 1080.0)

## Kabuğun HAYATTA KALDIĞI en küçük mantıksal viewport (TopBar'ın yoğunluk kademesi
## dar viewport'ta hiçbir sayı ya da kontrol kaybetmez; ölçülen taban 1280×720).
## 1920 pencere → %125 (1536×864) yasal.
const MIN_CHROME_VIEWPORT := Vector2(1280.0, 720.0)

const KEY_WINDOW_MODE := "window_mode"
const KEY_RES_W := "resolution_w"
const KEY_RES_H := "resolution_h"
const KEY_VSYNC := "vsync"
const KEY_UI_SCALE := "ui_scale"


# ============================================================================
# Harness guard
# ============================================================================

## True when something other than the player owns the window: the headless
## DisplayServer (smoke suite, theme generator) or any debug screenshot /
## instrumentation run. Every apply_* below no-ops in this state.
static func is_inert() -> bool:
	if DisplayServer.get_name() == "headless":
		return true
	for arg in OS.get_cmdline_args():
		if _is_harness_arg(String(arg)):
			return true
	# The MCP editor-run path passes --endgame-smoke through run/main_args.
	var configured: String = String(ProjectSettings.get_setting("application/run/main_args", ""))
	return configured.contains("--endgame-smoke")


static func _is_harness_arg(s: String) -> bool:
	if not s.begins_with("--"):
		return false
	# Every screenshot runner is spelled "--<something>-shot[=kind]"; match the family.
	if s.contains("-shot"):
		return true
	for prefix in ["--endgame-smoke", "--font-spec", "--theme-audit", "--tempo-probe", "--render-probe"]:
		if s.begins_with(prefix):
			return true
	return false


static func _root() -> Window:
	var tree := Engine.get_main_loop() as SceneTree
	return tree.root if tree != null else null


# ============================================================================
# Apply
# ============================================================================

## Push every persisted display value at the engine (boot and after a reset).
static func apply_all() -> void:
	if is_inert():
		return
	apply_window_mode(get_window_mode())
	apply_vsync(get_vsync())
	apply_ui_scale(get_ui_scale())


static func get_window_mode() -> String:
	var mode: String = String(Settings.get_value(KEY_WINDOW_MODE))
	return mode if mode in MODE_ORDER else MODE_BORDERLESS


static func set_window_mode(mode: String) -> void:
	if mode not in MODE_ORDER:
		push_warning("[DisplaySettings] unknown window mode: %s" % mode)
		return
	Settings.set_value(KEY_WINDOW_MODE, mode)
	apply_window_mode(mode)
	# The window size changes with the mode, which can make the UI-scale step illegal.
	apply_ui_scale(get_ui_scale())


static func apply_window_mode(mode: String) -> void:
	if is_inert():
		return
	match mode:
		MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		MODE_BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	if mode == MODE_WINDOWED:
		apply_resolution(get_resolution())


# --- Ekran tespiti ----------------------------------------------------------
# `allow_hidpi` Godot 4'te varsayılan olarak açık, yani screen_get_size GERÇEK fiziksel
# pikseli döndürür — Windows'ta %150 ölçeklenmiş bir 4K panel 3840x2160 der.

## Pencerenin bulunduğu monitörün native boyutu (birincil ekran değil).
static func native_resolution() -> Vector2i:
	if is_inert():
		return Vector2i(BASE_VIEWPORT)
	return DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())


## Görev çubuğu düşülmüş kullanılabilir alan — pencereli modun gerçek tavanı.
static func usable_size() -> Vector2i:
	if is_inert():
		return native_resolution()
	return DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen()).size


## Pencereli modun ÖLÇÜLEN varsayılanı: kullanılabilir alana sığan en büyük boyut.
## EN-BOY, ALANDAN ÖNCE GELİR: 2560x1440 bir panele alanı daha büyük diye 2560x1080
## (21:9) seçmek oyuncuya sebepsiz mektup kutusu bir pencere verirdi. Önce panelin
## oranına uyan en büyük aday; hiç uymuyorsa sığan en büyüğe düşülür.
static func default_resolution() -> Vector2i:
	var fits: Vector2i = usable_size()
	var native: Vector2i = native_resolution()
	var want: float = float(native.x) / maxf(1.0, float(native.y))
	var best_match: Vector2i = Vector2i.ZERO
	var best_any: Vector2i = RESOLUTIONS[0]
	for r in available_resolutions():
		if r.x > fits.x or r.y > fits.y:
			continue
		if r.x * r.y > best_any.x * best_any.y:
			best_any = r
		if absf(float(r.x) / maxf(1.0, float(r.y)) - want) <= ASPECT_EPSILON \
				and r.x * r.y > best_match.x * best_match.y:
			best_match = r
	return best_match if best_match != Vector2i.ZERO else best_any


## RESOLUTIONS filtered to what this screen can show, PLUS the screen's own native
## mode, sorted by area. The minimum always survives so the dropdown is never empty.
static func available_resolutions() -> Array[Vector2i]:
	var screen: Vector2i = native_resolution()
	var out: Array[Vector2i] = []
	for r in RESOLUTIONS:
		if r.x <= screen.x and r.y <= screen.y:
			out.append(r)
	if not out.has(screen) and screen.x > 0 and screen.y > 0:
		out.append(screen)
	if out.is_empty():
		out.append(RESOLUTIONS[0])
	out.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x * a.y < b.x * b.y)
	return out


## Saklanmış bir değer YOKSA varsayılan ÖLÇÜLÜR (DEFAULTS'taki literal yalnız headless
## yedeğidir). Sıfırlama anahtarı siler, burası yeniden tespit eder.
static func get_resolution() -> Vector2i:
	if not (Settings.has_stored(KEY_RES_W) and Settings.has_stored(KEY_RES_H)):
		return default_resolution()
	return Vector2i(int(Settings.get_value(KEY_RES_W)), int(Settings.get_value(KEY_RES_H)))


static func set_resolution(res: Vector2i) -> void:
	Settings.set_value(KEY_RES_W, res.x)
	Settings.set_value(KEY_RES_H, res.y)
	apply_resolution(res)
	apply_ui_scale(get_ui_scale())   # the new size can invalidate the current step


## Resolution is a WINDOWED-mode concept: in either fullscreen mode the window fills
## the screen and the canvas_items stretch does the fitting.
static func apply_resolution(res: Vector2i) -> void:
	if is_inert() or get_window_mode() != MODE_WINDOWED:
		return
	DisplayServer.window_set_size(res)
	# Re-center: a resize anchors at the top-left and can push the title bar off
	# the top of the screen on the larger steps.
	var screen_idx: int = DisplayServer.window_get_current_screen()
	var origin: Vector2i = DisplayServer.screen_get_position(screen_idx)
	DisplayServer.window_set_position(origin + (DisplayServer.screen_get_size(screen_idx) - res) / 2)


static func is_resolution_editable() -> bool:
	return get_window_mode() == MODE_WINDOWED


## Ekranda GERÇEKTEN geçerli olan çözünürlük: tam-ekran modlarında saklanan pencereli
## tercih değil, pencerenin kapladığı monitörün native boyutu.
static func effective_resolution() -> Vector2i:
	return get_resolution() if is_resolution_editable() else native_resolution()


# --- VSync ------------------------------------------------------------------

static func get_vsync() -> bool:
	return bool(Settings.get_value(KEY_VSYNC))


static func set_vsync(on: bool) -> void:
	Settings.set_value(KEY_VSYNC, on)
	apply_vsync(on)


static func apply_vsync(on: bool) -> void:
	if is_inert():
		return
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if on else DisplayServer.VSYNC_DISABLED)


# --- UI scale ---------------------------------------------------------------

## Physical pixels the SMALLEST type step lands on at `step` for a window of `win`:
## the canvas_items stretch (min of the two axes, since aspect="expand" letterboxes
## on the tighter one) times the player's content_scale_factor.
static func effective_micro_px(step: float, win: Vector2i) -> float:
	var stretch: float = minf(float(win.x) / BASE_VIEWPORT.x, float(win.y) / BASE_VIEWPORT.y)
	return float(UiTokens.SIZE_MICRO) * step * stretch


## Legality of one ladder step. `win` defaults to the live window (ZERO is the sentinel).
##
## Membership comes first: the geometric gates alone would accept a stale off-ladder
## value (e.g. 1.5) from settings.json that the dropdown can no longer show.
##
## 100% IS ALWAYS LEGAL. Below 1080p the stretch is the engine's answer to a small
## window, not the player's choice, and at the minimum window (1280×720, stretch 0.667)
## every enlargement step fails the chrome gate — gating 100% too would leave a clamp
## that cannot satisfy its own gate. The floor guards only the player choosing to
## shrink type BELOW the authored design.
static func is_step_allowed(step: float, win: Vector2i = Vector2i.ZERO) -> bool:
	if not _is_ladder_step(step):
		return false
	var w: Vector2i = _root().size if win == Vector2i.ZERO else win
	if step > 1.0:
		return _fits_chrome(step, w)
	if step == 1.0:
		return true
	return effective_micro_px(step, w) >= float(MIN_READABLE_FONT_PX) - READABLE_EPSILON


## Epsilon karşılaştırması, `Array.has` DEĞİL: değer JSON'dan geçip geliyor.
static func _is_ladder_step(step: float) -> bool:
	for s in UI_SCALE_STEPS:
		if is_equal_approx(s, step):
			return true
	return false


## The UPPER gate: content_scale_factor > 1 SHRINKS the logical viewport, and a
## viewport under MIN_CHROME_VIEWPORT crops the TopBar (company name, speed buttons).
static func _fits_chrome(step: float, win: Vector2i) -> bool:
	if win.x <= 0 or win.y <= 0:
		return true   # boyut henüz bilinmiyor (headless/erken boot) — kapıyı kapatma
	var logical := Vector2(win) / step
	return logical.x >= MIN_CHROME_VIEWPORT.x - 0.5 and logical.y >= MIN_CHROME_VIEWPORT.y - 0.5


## The disabled row's explanation. TranslationServer, not tr(): statics have no Object
## to translate through. The two gates have opposite reasons (readability floor vs
## chrome width), so each has its own text.
static func step_blocked_note(step: float) -> String:
	var key: String = "SET_UI_SCALE_TOO_LARGE" if step > 1.0 else "SET_UI_SCALE_TOO_SMALL"
	return TranslationServer.translate(key).format({"pct": int(round(step * 100.0))})


## Nearest LEGAL step, moving TOWARD 100% — each gate has only one safe escape
## (a blocked reduction must grow, a blocked enlargement must shrink). 100% is legal
## at every size, so this never returns an illegal value.
static func clamp_step(step: float, win: Vector2i = Vector2i.ZERO) -> float:
	var w: Vector2i = _root().size if win == Vector2i.ZERO else win
	if is_step_allowed(step, w):
		return step
	if step < 1.0:
		for s in UI_SCALE_STEPS:                       # artan sırada: ilk yasal olan
			if s > step and is_step_allowed(s, w):
				return s
	else:
		for i in range(UI_SCALE_STEPS.size() - 1, -1, -1):   # azalan sırada
			var s: float = UI_SCALE_STEPS[i]
			if s < step and is_step_allowed(s, w):
				return s
	return 1.0


static func get_ui_scale() -> float:
	return float(Settings.get_value(KEY_UI_SCALE))


static func set_ui_scale(step: float) -> void:
	Settings.set_value(KEY_UI_SCALE, step)
	apply_ui_scale(step)


## Apply the step after clamping. A correction is written back through Settings so
## the dropdown never shows a step the window can no longer render.
static func apply_ui_scale(step: float) -> void:
	if is_inert():
		return
	var win: Window = _root()
	var legal: float = clamp_step(step, win.size)
	if not is_equal_approx(legal, step):
		Settings.set_value(KEY_UI_SCALE, legal)
	win.content_scale_factor = legal
