extends Node

# Settings (TECH_SPEC §6.1) — persisted player preferences: display, audio,
# game, language, accessibility. The store is generic (string key → JSON value)
# so every preference shares one file; DEFAULTS below is the SCHEMA on top of it.
#
# Persistence = JSON via FileAccess (TECH_SPEC §2, LOCKED convention). Settings
# live in user://settings.json, INDEPENDENT of game saves — they persist across
# runs regardless of which save slot (or none) is loaded.
#
# OWNERSHIP (the split AudioManager's header already documents, now generalized):
# Settings PERSISTS, the domain system APPLIES. This node never talks to the
# AudioServer or the DisplayServer itself — it holds the values, and apply_all()
# hands each one to its owner (DisplaySettings for the window, AudioManager for
# the buses, UiTokens for the semantic palette).

const SETTINGS_PATH := "user://settings.json"
const SCHEMA_VERSION := 1

# Global class names are resolved from Godot's script-class cache, which a fresh
# CLI run may not have rebuilt yet. An AUTOLOAD that fails to resolve an identifier
# takes the whole game down, so the display helper is reached through preload —
# always correct, cache or no cache. (display_settings.gd still declares
# `class_name DisplaySettings` for every non-autoload caller.)
const DisplaySettingsLib := preload("res://scripts/systems/display_settings.gd")

# ============================================================================
# DEFAULTS — the settings SCHEMA. Every key the settings screen writes is
# declared here with its first-run value and (by its literal's type) its type.
# ============================================================================
# An old settings.json missing a key needs no migration: get_value() takes a
# default, and DEFAULTS is where that default comes from. Adding a key here is
# therefore the whole migration.
#
# Deliberately NOT here: `language` (Localization owns its own default and the
# reset copy promises saves+language are untouched) and `oda_intro_seen`
# (tutorial progress, not a setting). reset_to_defaults() only clears the keys
# in this table, so both survive a reset — see that function.
const DEFAULTS := {
	# --- Görüntü (DisplaySettings applies) ---
	"window_mode": "borderless",        # "fullscreen" | "borderless" | "windowed"
	# Bu ikisi yalnız HEADLESS/inert yedeğidir. Gerçek varsayılan ÖLÇÜLÜR:
	# DisplaySettings.default_resolution() monitörün native boyutunu okur ve
	# görev çubuğunu düşer. Tabloda kalmalarının sebebi reset_to_defaults'un
	# yalnız buradaki anahtarları silmesi — silinince tespit yeniden koşar.
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
	# --- Oyun (SaveManager reads this lazily; this task only persists it) ---
	"autosave_frequency": "weekly",     # "off" | "daily" | "weekly" | "monthly"
	# --- Erişilebilirlik (UiTokens applies) ---
	"colorblind_palette": false,
}

# Writing the file on every set_value turns one volume-slider drag into a few
# hundred disk writes. Mark dirty instead and flush once the value settles; the
# hard exits (window close, focus loss, tree exit) force-flush so nothing that
# reached _data can be lost to the debounce window.
const SAVE_DEBOUNCE_SEC := 0.5

var _data: Dictionary = {}
var _dirty: bool = false
var _flush_timer: Timer


func _ready() -> void:
	# The debounce timer must keep counting while the tree is paused — the settings
	# panel itself runs paused (process_mode = ALWAYS), so a PAUSABLE timer would
	# never fire for the exact control that needs it most.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_flush_timer = Timer.new()
	_flush_timer.name = "FlushTimer"
	_flush_timer.one_shot = true
	_flush_timer.wait_time = SAVE_DEBOUNCE_SEC
	_flush_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	_flush_timer.timeout.connect(flush)
	add_child(_flush_timer)
	_load()
	apply_all()


# Generic accessors. Value types round-trip through JSON (bool/float/int/String);
# callers pass a default so a missing/first-run key returns a sane value. Keys in
# DEFAULTS should pass get_default(key) rather than re-typing the literal.
func get_value(key: String, default_value: Variant) -> Variant:
	return _data.get(key, default_value)


## "Bu anahtar diske gerçekten YAZILDI mı?" — get_value ile ayırt edilemez, çünkü
## o, saklanmış bir değerle varsayılanı aynı şekilde döndürür. DisplaySettings buna
## ihtiyaç duyuyor: çözünürlüğün varsayılanı artık sabit bir literal değil, ÖLÇÜLEN
## monitör değeri; yani "kullanıcı seçmedi" ile "kullanıcı 1920x1080 seçti" ayrımı
## gerçek bir ayrım hâline geldi. Sıfırlama sonrası da doğru çalışır: reset_to_defaults
## anahtarı SİLER, dolayısıyla tespit yeniden koşar.
func has_stored(key: String) -> bool:
	return _data.has(key)


func set_value(key: String, value: Variant) -> void:
	if _data.get(key, null) == value:
		return   # no-op writes must not restart the debounce window
	_data[key] = value
	_mark_dirty()


## The DEFAULTS-declared fallback for a key. Callers read
## `Settings.get_value(KEY, Settings.get_default(KEY))` so the literal lives in
## exactly one place — this table.
func get_default(key: String) -> Variant:
	if not DEFAULTS.has(key):
		push_warning("[Settings] get_default on undeclared key: %s" % key)
		return null
	return DEFAULTS[key]


## Reset the settings SCHEMA only. Keys outside DEFAULTS — `oda_intro_seen`,
## `language`, anything a future system parks here — survive untouched: resetting
## settings must never replay the tutorial or flip the player's language, and the
## confirm copy (SET_RESET_CONFIRM_BODY) promises exactly that.
## Erase rather than overwrite: a key that is absent falls through to the same
## DEFAULTS value on read, so the file returns to its honest first-run shape.
func reset_to_defaults() -> void:
	for key in DEFAULTS.keys():
		_data.erase(key)
	_mark_dirty()
	flush()        # a reset is a deliberate act — don't leave it in the debounce window
	apply_all()


## Push every persisted value at the system that owns its live state. Called after
## _load() at boot and again after reset_to_defaults().
func apply_all() -> void:
	DisplaySettingsLib.apply_all()
	# ui_tokens.gd hard-references the GameState autoload (net_runway_parts), and the
	# theme generator is loaded with `-s` BEFORE autoloads exist — so in that one run
	# ui_tokens lands in a failed-compile state and its statics are unreachable
	# (`Nonexistent function 'set_colorblind' in base 'GDScript'`). The generator paints
	# nothing, so skip the palette there rather than spam its log. Measured, not assumed:
	# a normal boot and the headless smoke both compile it fine.
	if not _is_theme_generator_run():
		UiTokens.set_colorblind(bool(get_value("colorblind_palette", DEFAULTS["colorblind_palette"])))
	# AudioManager is registered AFTER Settings, so at boot the node does not exist
	# yet and applies its own values in its _ready(). On a later reset it IS there,
	# and this is what makes the sliders snap back. get_node_or_null, not the
	# `AudioManager` global: that identifier is null during our own _ready().
	var audio: Node = get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method("apply_from_settings"):
		audio.apply_from_settings()


func _is_theme_generator_run() -> bool:
	return "res://scripts/theme/build_theme.gd" in OS.get_cmdline_args()


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
	# Alt-tabbing away, closing the window, or a get_tree().quit() teardown — every
	# path that ends the process or hands the machine to another app lands the
	# pending write first, so nothing is lost to the debounce window.
	if what == NOTIFICATION_WM_CLOSE_REQUEST \
			or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT \
			or what == NOTIFICATION_APPLICATION_FOCUS_OUT \
			or what == NOTIFICATION_EXIT_TREE:
		flush()


func _load() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if f == null:
		push_warning("[Settings] could not open %s for read" % SETTINGS_PATH)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		var values: Variant = (parsed as Dictionary).get("values", {})
		if typeof(values) == TYPE_DICTIONARY:
			_data = values


func _save() -> void:
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("[Settings] could not open %s for write" % SETTINGS_PATH)
		return
	f.store_string(JSON.stringify({
		"schema_version": SCHEMA_VERSION,
		"values": _data,
	}, "\t"))
