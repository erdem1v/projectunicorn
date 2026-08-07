class_name DisplaySettings
extends RefCounted

# ============================================================================
# DisplaySettings — the live display engine (window mode / resolution / vsync /
# UI scale). All static; holds no state of its own.
# ============================================================================
# OWNERSHIP mirrors the split AudioManager's header documents: **Settings
# persists, DisplaySettings applies.** Every function here reads the value from
# the Settings autoload and pushes it at the DisplayServer / the root Window.
# Nothing here writes a preference except the one place the engine must correct
# the player (an illegal UI-scale step after a resolution change — see
# apply_ui_scale), and that correction goes back through Settings.set_value.
#
# THE HARNESS RULE (non-negotiable): the debug screenshot runners and the smoke
# suite OWN the window. --tab-shot/--modal-shot/--oda-shot/… all set
# `get_window().size = Vector2i(1920, 1080)` by hand so their frames are
# comparable, and --endgame-smoke runs headless. If this file resized or
# fullscreened the window at boot, it would silently invalidate 14 screenshot
# runners and the whole smoke suite. is_inert() is that guard, and every
# DisplayServer/Window call in this file sits behind it.
# ============================================================================

# --- Window mode ------------------------------------------------------------
# Godot's naming is a trap worth spelling out: WINDOW_MODE_FULLSCREEN is the
# BORDERLESS windowed-fullscreen mode (alt-tab friendly, no mode switch), while
# WINDOW_MODE_EXCLUSIVE_FULLSCREEN is real exclusive fullscreen. The player-facing
# TR labels map to the modes the words actually mean, not to the enum spelling.
const MODE_FULLSCREEN := "fullscreen"     # Tam ekran   → EXCLUSIVE_FULLSCREEN
const MODE_BORDERLESS := "borderless"     # Kenarlıksız → FULLSCREEN (borderless windowed)
const MODE_WINDOWED := "windowed"         # Pencereli   → WINDOWED

# Display order in the dropdown; index ↔ id conversion for the OptionButton.
const MODE_ORDER: Array[String] = [MODE_FULLSCREEN, MODE_BORDERLESS, MODE_WINDOWED]
const MODE_KEYS: Array[String] = ["SET_WINDOW_FULLSCREEN", "SET_WINDOW_BORDERLESS", "SET_WINDOW_WINDOWED"]

# --- Resolutions ------------------------------------------------------------
# docs/TECH_SPEC.md §14.1's supported list, in order. 1280×720 is the documented
# MINIMUM, so it is never filtered away even on a smaller-than-expected screen.
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1080),
	Vector2i(2560, 1440),
	Vector2i(3440, 1440),
	Vector2i(3840, 2160),
]

# --- UI scale ---------------------------------------------------------------
# Applied through the root Window's content_scale_factor, which multiplies the
# canvas_items stretch the project already runs (project.godot: stretch mode
# "canvas_items", aspect "expand", base 1920×1080).
const UI_SCALE_STEPS: Array[float] = [0.75, 0.90, 1.00, 1.10, 1.25, 1.50]

## The readability floor, in PHYSICAL pixels. This is a decided design point:
## a 9px badge that the stretch has already shrunk is 9px on glass no matter what
## the layout thinks it is, so the check has to happen after BOTH multipliers.
## UiTokens.SIZE_MICRO is the smallest step in the type scale and is exactly 9,
## so the floor is "the PLAYER must never shrink the smallest type below its
## authored size". Consequence, deliberately: at 1920×1080 the 75% and 90% steps
## are DISABLED; 90% unlocks around 1200px of height, 75% at 1440p.
## It gates the reduction steps only — see is_step_allowed for why 100%+ is exempt.
const MIN_READABLE_FONT_PX := 9

# Float comparison guard. 9 * 0.75 * (1440.0/1080.0) evaluates to 8.999999999999998,
# i.e. the exact 1440p case the design intends to ALLOW would fail a naive `>=`.
const READABLE_EPSILON := 0.01

const BASE_VIEWPORT := Vector2(1920.0, 1080.0)

# Settings keys this file reads (declared in Settings.DEFAULTS).
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
	# The MCP editor-run path passes --endgame-smoke through run/main_args rather
	# than the command line (the same dual source main.gd reads).
	var configured: String = String(ProjectSettings.get_setting("application/run/main_args", ""))
	return configured.contains("--endgame-smoke")


static func _is_harness_arg(s: String) -> bool:
	if not s.begins_with("--"):
		return false
	# Every screenshot runner in main.gd is spelled "--<something>-shot[=kind]"
	# (--tab-shot, --modal-shot, --onboard-shot, --probe-shot, --oda-shot,
	# --hr-shot, --finance-shot, --product-shot, --ending-shot, --pitch-shot …),
	# so match the family rather than a list that will fall behind.
	if s.contains("-shot"):
		return true
	return s.begins_with("--endgame-smoke") or s.begins_with("--font-spec") \
		or s.begins_with("--theme-audit") or s.begins_with("--tempo-probe")


static func _root() -> Window:
	var loop: MainLoop = Engine.get_main_loop()
	var tree := loop as SceneTree
	return tree.root if tree != null else null


## Current window size in physical pixels (the number the readability floor and
## the stretch factor are both computed from). Falls back to the project's base
## viewport when there is no window to ask.
static func window_size() -> Vector2i:
	var win: Window = _root()
	if win == null:
		return Vector2i(int(BASE_VIEWPORT.x), int(BASE_VIEWPORT.y))
	return win.size


# ============================================================================
# Apply
# ============================================================================

## Push every persisted display value at the engine. Settings.apply_all() calls
## this at boot and after a reset.
static func apply_all() -> void:
	if is_inert():
		return
	apply_window_mode(get_window_mode())
	apply_vsync(get_vsync())
	apply_ui_scale(get_ui_scale())


static func get_window_mode() -> String:
	var mode: String = String(Settings.get_value(KEY_WINDOW_MODE, Settings.get_default(KEY_WINDOW_MODE)))
	return mode if mode in MODE_ORDER else MODE_BORDERLESS


static func set_window_mode(mode: String) -> void:
	if mode not in MODE_ORDER:
		push_warning("[DisplaySettings] unknown window mode: %s" % mode)
		return
	Settings.set_value(KEY_WINDOW_MODE, mode)
	apply_window_mode(mode)
	# Leaving Pencereli (or entering it) changes the window size, which can make
	# the current UI-scale step illegal. Re-run the gate against the new size.
	apply_ui_scale(get_ui_scale())


static func apply_window_mode(mode: String) -> void:
	if is_inert():
		return
	match mode:
		MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		MODE_BORDERLESS:
			# Godot's "fullscreen" IS borderless-windowed — no exclusive mode switch.
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			apply_resolution(get_resolution())


# --- Resolution -------------------------------------------------------------

## The §14.1 list filtered to what this screen can actually show. The minimum
## (1280×720) always survives so the dropdown is never empty.
static func available_resolutions() -> Array[Vector2i]:
	var screen: Vector2i = Vector2i(int(BASE_VIEWPORT.x), int(BASE_VIEWPORT.y))
	if not is_inert():
		screen = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	var out: Array[Vector2i] = []
	for r in RESOLUTIONS:
		if r.x <= screen.x and r.y <= screen.y:
			out.append(r)
	if out.is_empty():
		out.append(RESOLUTIONS[0])
	return out


static func get_resolution() -> Vector2i:
	return Vector2i(
		int(Settings.get_value(KEY_RES_W, Settings.get_default(KEY_RES_W))),
		int(Settings.get_value(KEY_RES_H, Settings.get_default(KEY_RES_H))))


static func set_resolution(res: Vector2i) -> void:
	Settings.set_value(KEY_RES_W, res.x)
	Settings.set_value(KEY_RES_H, res.y)
	apply_resolution(res)
	apply_ui_scale(get_ui_scale())   # the new size can invalidate the current step


## Resolution is a WINDOWED-mode concept: in either fullscreen mode the window
## already fills the screen and the canvas_items stretch does the fitting, so the
## dropdown row is disabled there (SET_RESOLUTION_LOCKED explains why).
static func apply_resolution(res: Vector2i) -> void:
	if is_inert() or get_window_mode() != MODE_WINDOWED:
		return
	DisplayServer.window_set_size(res)
	# Re-center: a resize anchors at the top-left and can push the title bar off
	# the top of the screen on the larger steps.
	var screen: Vector2i = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	var origin: Vector2i = DisplayServer.screen_get_position(DisplayServer.window_get_current_screen())
	DisplayServer.window_set_position(origin + (screen - res) / 2)


static func is_resolution_editable() -> bool:
	return get_window_mode() == MODE_WINDOWED


# --- VSync ------------------------------------------------------------------

static func get_vsync() -> bool:
	return bool(Settings.get_value(KEY_VSYNC, Settings.get_default(KEY_VSYNC)))


static func set_vsync(on: bool) -> void:
	Settings.set_value(KEY_VSYNC, on)
	apply_vsync(on)


static func apply_vsync(on: bool) -> void:
	if is_inert():
		return
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if on else DisplayServer.VSYNC_DISABLED)


# --- UI scale ---------------------------------------------------------------

## Physical pixels the SMALLEST type step lands on at `step`, for a window of
## `win`. Both multipliers are in play: the project's canvas_items stretch
## (window ÷ 1920×1080, min of the two axes because aspect="expand" letterboxes
## on the tighter one) and the player's chosen content_scale_factor.
static func effective_micro_px(step: float, win: Vector2i) -> float:
	var stretch: float = minf(float(win.x) / BASE_VIEWPORT.x, float(win.y) / BASE_VIEWPORT.y)
	return float(UiTokens.SIZE_MICRO) * step * stretch


## Readability gate for one dropdown row. `win` defaults to the live window
## (ZERO is the sentinel — a default argument must not depend on call-time state).
##
## 100% AND ABOVE ARE ALWAYS LEGAL, and that exemption is load-bearing rather than
## a softening of the floor. The canvas_items stretch below 1080p is the ENGINE's
## designed answer to a small window, not a preference the player picked; 100% is
## by definition the authored baseline. Gating it produces an actively worse
## outcome than the small type it was meant to prevent: at the enforced minimum
## window (1280×720, main.gd:65) the stretch is 0.667, so a floor applied to 100%
## rejects it and clamps UP to 150% — and 1.5 × 0.667 = 1.0 renders the full
## 1920×1080 layout at native size inside a 720p window, so a third of it falls off
## the edge. Worse, `clamp_step` is one-directional, so that 150% would persist
## after the player moved back to a large display.
## So the floor guards only what it was written to guard: the player choosing to
## shrink the type BELOW the authored design. 75% and 90% stay gated by physical
## pixels exactly as specified.
static func is_step_allowed(step: float, win: Vector2i = Vector2i.ZERO) -> bool:
	var w: Vector2i = window_size() if win == Vector2i.ZERO else win
	if step > 1.0:
		return _fits_design_width(step, w)
	if step == 1.0:
		return true
	return effective_micro_px(step, w) >= float(MIN_READABLE_FONT_PX) - READABLE_EPSILON


## The UPPER gate, and the mirror image of the readability floor.
##
## content_scale_factor > 1 does not magnify into a bigger window — it SHRINKS the
## logical viewport (measured: a 1920×1080 window at 150% reports a 1280×720 viewport
## and a 1280-wide TopBar). Everything in this project is authored against the 1920
## design width, and TECH_SPEC §14.4's compact-mode breakpoints were never built, so a
## logical viewport under 1920 overflows its chrome: at 150% on a 1080p screen the
## TopBar loses the company name off the left edge and the 3x/4x speed buttons off the
## right. Speed control disappearing is a functional loss, not a cosmetic one.
##
## So an enlargement step is legal only where the logical viewport still covers the
## design: 1920 window → 100% only; 2560 → up to 125%; 3840 → the whole ladder.
## This is a HARDWARE gate, not a permanent ceiling — it lifts on its own the day
## §14.4 responsive breakpoints land, with no change to this file.
static func _fits_design_width(step: float, win: Vector2i) -> bool:
	if win.x <= 0 or win.y <= 0:
		return true   # boyut henüz bilinmiyor (headless/erken boot) — kapıyı kapatma
	var logical := Vector2(float(win.x) / step, float(win.y) / step)
	return logical.x >= BASE_VIEWPORT.x - 0.5 and logical.y >= BASE_VIEWPORT.y - 0.5


## The disabled row's explanation, already formatted ("%d%% bu pencere boyutunda…").
## TranslationServer, not tr(): statics have no Object to translate through — the
## same reason UiTokens.net_runway_parts reaches for it.
static func step_blocked_note(step: float) -> String:
	return TranslationServer.translate("SET_UI_SCALE_TOO_SMALL") % int(round(step * 100.0))


## Nearest LEGAL step, moving TOWARD 100%. The direction is not a preference — each
## gate has only one safe escape:
##   • a reduction step blocked by the readability floor must grow (shrinking further
##     is exactly what the floor forbids);
##   • an enlargement step blocked by the design-width gate must shrink (growing
##     further crops more chrome).
## 100% is legal at every window size, so both walks terminate there at worst and the
## function can never return an illegal value.
static func clamp_step(step: float, win: Vector2i = Vector2i.ZERO) -> float:
	var w: Vector2i = window_size() if win == Vector2i.ZERO else win
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
	return float(Settings.get_value(KEY_UI_SCALE, Settings.get_default(KEY_UI_SCALE)))


static func set_ui_scale(step: float) -> void:
	Settings.set_value(KEY_UI_SCALE, step)
	apply_ui_scale(step)


## Apply the step, clamping upward first. When the clamp fires it writes the
## corrected value back through Settings — the dropdown must not keep showing a
## step the window can no longer render.
static func apply_ui_scale(step: float) -> void:
	if is_inert():
		return
	var win: Window = _root()
	if win == null:
		return
	var legal: float = clamp_step(step, win.size)
	if not is_equal_approx(legal, step):
		print("[DisplaySettings] UI ölçeği %d%% → %d%% (pencere %dx%d, %dpx okunabilirlik tabanı)" % [
			int(round(step * 100.0)), int(round(legal * 100.0)),
			win.size.x, win.size.y, MIN_READABLE_FONT_PX])
		Settings.set_value(KEY_UI_SCALE, legal)
	win.content_scale_factor = legal
