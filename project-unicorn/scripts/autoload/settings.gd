extends Node

# Settings — persisted player preferences (display, audio, game, language,
# accessibility) in user://settings.json, independent of game saves.
#
# Settings PERSISTS, the domain system APPLIES: this node never talks to the
# AudioServer or DisplayServer; apply_all() hands each value to its owner
# (DisplaySettings, AudioManager, UiTokens).

const SETTINGS_PATH := "user://settings.json"
const SCHEMA_VERSION := 1

# Preload, not the DisplaySettings class name: a fresh CLI run may not have rebuilt
# the script-class cache, and an autoload that fails to resolve an identifier takes
# the whole game down.
const DisplaySettingsLib := preload("res://scripts/systems/display_settings.gd")

# The settings SCHEMA: every key the settings screen writes, with its first-run value.
# A missing key reads its default from here, so adding a key is the whole migration.
#
# Deliberately NOT here: `language` (Localization owns its default) and
# `oda_intro_seen` (tutorial progress). reset_to_defaults() only clears these keys,
# so both survive a reset.
const DEFAULTS := {
	# --- Görüntü (DisplaySettings applies) ---
	"window_mode": "borderless",        # "fullscreen" | "borderless" | "windowed"
	# Bu ikisi yalnız HEADLESS/inert yedeğidir; gerçek varsayılan
	# DisplaySettings.default_resolution() ile ÖLÇÜLÜR. Tabloda kalmalarının sebebi
	# reset_to_defaults'un yalnız buradaki anahtarları silmesi — silinince tespit yeniden koşar.
	"resolution_w": 1920,
	"resolution_h": 1080,
	"vsync": true,
	"ui_scale": 1.0,                    # one of DisplaySettings.UI_SCALE_STEPS
	# --- Ses (AudioManager applies; linear 0..1, mute at ≤0) ---
	"master_volume": 1.0,
	"music_enabled": true,
	"music_volume": 0.35,
	"sfx_volume": 0.7,
	"mute_unfocused": true,
	# --- Oyun (SaveManager reads this lazily) ---
	"autosave_frequency": "weekly",     # "off" | "daily" | "weekly" | "monthly"
	# --- Erişilebilirlik (UiTokens applies) ---
	"colorblind_palette": false,
}

# One volume-slider drag is a few hundred set_value calls: mark dirty and flush once
# the value settles. The hard exits in _notification force-flush.
const SAVE_DEBOUNCE_SEC := 0.5

var _data: Dictionary = {}
var _dirty: bool = false
var _flush_timer: Timer


func _ready() -> void:
	# The settings panel runs while the tree is paused, so the debounce timer must too.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_flush_timer = Timer.new()
	_flush_timer.name = "FlushTimer"
	_flush_timer.one_shot = true
	_flush_timer.wait_time = SAVE_DEBOUNCE_SEC
	_flush_timer.timeout.connect(flush)
	add_child(_flush_timer)
	_load()
	apply_all()


## Stored value, else `default_value`, else the DEFAULTS entry. Values round-trip
## through JSON (bool/float/int/String).
func get_value(key: String, default_value: Variant = null) -> Variant:
	return _data.get(key, DEFAULTS.get(key) if default_value == null else default_value)


## Was this key ever written? get_value cannot tell "stored 1920x1080" from
## "defaulted"; DisplaySettings needs that line because its resolution default is measured.
func has_stored(key: String) -> bool:
	return _data.has(key)


func set_value(key: String, value: Variant) -> void:
	if _data.get(key, null) == value:
		return   # no-op writes must not restart the debounce window
	_data[key] = value
	_mark_dirty()


## Reset the SCHEMA only; keys outside DEFAULTS survive (the confirm copy
## SET_RESET_CONFIRM_BODY promises language and tutorial progress are untouched).
## Erase rather than overwrite, so the file returns to its first-run shape.
func reset_to_defaults() -> void:
	for key in DEFAULTS.keys():
		_data.erase(key)
	_mark_dirty()
	flush()        # a reset is a deliberate act — don't leave it in the debounce window
	apply_all()


## Push every persisted value at the system that owns its live state.
func apply_all() -> void:
	DisplaySettingsLib.apply_all()
	# The theme generator runs with `-s` before autoloads exist, so ui_tokens.gd
	# (which references GameState) fails to compile there and its statics are
	# unreachable. The generator paints nothing; skip the palette.
	if not "res://scripts/theme/build_theme.gd" in OS.get_cmdline_args():
		UiTokens.set_colorblind(bool(get_value("colorblind_palette")))
	# AudioManager is registered AFTER Settings: at boot its node may exist but is not
	# ready yet (no buses, no player) and applies its own values in _ready(); after a
	# reset this call is what makes the sliders snap back. get_node_or_null, not the
	# `AudioManager` global, which is null during our own _ready().
	var audio: Node = get_node_or_null("/root/AudioManager")
	if audio != null and audio.is_node_ready():
		audio.apply_from_settings()


# --- Persistence -------------------------------------------------------------

func _mark_dirty() -> void:
	_dirty = true
	if is_instance_valid(_flush_timer):
		_flush_timer.start(SAVE_DEBOUNCE_SEC)   # restart = debounce, not throttle


## Write now if anything is pending. Safe to call when clean (no-op).
func flush() -> void:
	if not _dirty:
		return
	_dirty = false
	if is_instance_valid(_flush_timer):
		_flush_timer.stop()
	_save()


func _notification(what: int) -> void:
	# Every path that ends the process or hands the machine to another app lands the
	# pending write first.
	if what in [NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_WINDOW_FOCUS_OUT,
			NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_EXIT_TREE]:
		flush()


func _load() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if f == null:
		push_warning("[Settings] could not open %s for read" % SETTINGS_PATH)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary and parsed.get("values") is Dictionary:
		_data = parsed["values"]


func _save() -> void:
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("[Settings] could not open %s for write" % SETTINGS_PATH)
		return
	f.store_string(JSON.stringify({
		"schema_version": SCHEMA_VERSION,
		"values": _data,
	}, "\t"))
