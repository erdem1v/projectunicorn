extends Node

# AudioManager — the live audio engine: the bus graph (Master → Music, SFX) and the
# looping background track. Settings persists, AudioManager applies: the values live
# in Settings under the DEFAULTS keys, and every setter applies AND writes back.
# Registered AFTER Settings, so settings.json is already loaded when _ready reads it.

# Müzik dosyasını değiştirmek için sadece bu path'i güncelle (dosyayı assets/audio
# altına koy + Godot'a import ettir). Loop kodda açılıyor, .import ayarı gerekmez.
const MUSIC_TRACK_PATH := "res://assets/audio/Döngü Modu.mp3"

const MUSIC_BUS_NAME := "Music"
const MASTER_BUS_IDX := 0          # Master is always bus 0 — the engine guarantees it

const KEY_ENABLED := "music_enabled"
const KEY_VOLUME := "music_volume"
const KEY_MASTER := "master_volume"
const KEY_SFX := "sfx_volume"
const KEY_MUTE_UNFOCUSED := "mute_unfocused"

var _player: AudioStreamPlayer
var _music_bus: int
var _sfx_bus: int
var _enabled: bool
var _volume: float                 # linear 0..1 (Music)
var _master: float                 # linear 0..1
var _sfx: float                    # linear 0..1
var _mute_unfocused: bool
# Focus-loss mute must not fight the player's own mute: remember what Master was
# doing before we touched it and restore exactly that on focus-in.
var _focus_muted: bool = false
var _pre_focus_mute: bool = false


func _ready() -> void:
	# Background music survives get_tree().paused (game pause, modal pause, speed 0);
	# only the music toggle silences it. The player child inherits ALWAYS.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# No default_bus_layout.tres ships, so the child buses are created at runtime.
	# The SFX bus has no players yet; it exists so the Efektler slider moves a real bus.
	_music_bus = _ensure_bus(MUSIC_BUS_NAME)
	_sfx_bus = _ensure_bus("SFX")

	_player = AudioStreamPlayer.new()
	_player.name = "MusicPlayer"
	_player.bus = MUSIC_BUS_NAME
	add_child(_player)

	var stream: AudioStream = load(MUSIC_TRACK_PATH)
	if stream == null:
		push_warning("[AudioManager] müzik yüklenemedi: %s (import edildi mi?)" % MUSIC_TRACK_PATH)
	else:
		if stream is AudioStreamMP3:
			(stream as AudioStreamMP3).loop = true
		_player.stream = stream
		_player.play()

	# After play(): play() unpauses, and the stored music toggle must win.
	apply_from_settings()


func _ensure_bus(bus_name: String) -> int:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		AudioServer.add_bus()
		idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, "Master")
	return idx


# ── Public API (SettingsModal drives these live) ──────────────────────────────

## Re-read every audio preference from Settings and apply it. Called at boot and
## by Settings.apply_all() after a reset-to-defaults.
func apply_from_settings() -> void:
	_enabled = bool(Settings.get_value(KEY_ENABLED))
	_volume = clampf(float(Settings.get_value(KEY_VOLUME)), 0.0, 1.0)
	_master = clampf(float(Settings.get_value(KEY_MASTER)), 0.0, 1.0)
	_sfx = clampf(float(Settings.get_value(KEY_SFX)), 0.0, 1.0)
	_mute_unfocused = bool(Settings.get_value(KEY_MUTE_UNFOCUSED))
	_focus_muted = false
	_apply_bus(MASTER_BUS_IDX, _master)
	_apply_bus(_music_bus, _volume)
	_apply_bus(_sfx_bus, _sfx)
	_apply_enabled()


func set_music_enabled(on: bool) -> void:
	_enabled = on
	_apply_enabled()
	Settings.set_value(KEY_ENABLED, on)
	EventBus.music_enabled_changed.emit(on)


func is_music_enabled() -> bool:
	return _enabled


func set_music_volume(v: float) -> void:      # v: linear 0..1
	_volume = clampf(v, 0.0, 1.0)
	_apply_bus(_music_bus, _volume)
	Settings.set_value(KEY_VOLUME, _volume)
	EventBus.music_volume_changed.emit(_volume)


func get_music_volume() -> float:
	return _volume


func set_master_volume(v: float) -> void:
	_master = clampf(v, 0.0, 1.0)
	_apply_bus(MASTER_BUS_IDX, _master)
	Settings.set_value(KEY_MASTER, _master)


func get_master_volume() -> float:
	return _master


func set_sfx_volume(v: float) -> void:
	_sfx = clampf(v, 0.0, 1.0)
	_apply_bus(_sfx_bus, _sfx)
	Settings.set_value(KEY_SFX, _sfx)


func get_sfx_volume() -> float:
	return _sfx


func set_mute_unfocused(on: bool) -> void:
	_mute_unfocused = on
	Settings.set_value(KEY_MUTE_UNFOCUSED, on)
	if not on:
		_restore_focus_mute()   # turning the option off mid-mute must not strand silence


func is_mute_unfocused() -> bool:
	return _mute_unfocused


# ── Focus-loss mute ───────────────────────────────────────────────────────────

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and _mute_unfocused and not _focus_muted:
		# Restore what WAS on focus-in, so a player who muted Master stays muted.
		_pre_focus_mute = AudioServer.is_bus_mute(MASTER_BUS_IDX)
		_focus_muted = true
		AudioServer.set_bus_mute(MASTER_BUS_IDX, true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_restore_focus_mute()


func _restore_focus_mute() -> void:
	if not _focus_muted:
		return
	_focus_muted = false
	AudioServer.set_bus_mute(MASTER_BUS_IDX, _pre_focus_mute)


# ── Internal apply ────────────────────────────────────────────────────────────

func _apply_enabled() -> void:
	# stream_paused (vs stop) keeps playback position so re-enabling is seamless.
	_player.stream_paused = not _enabled


## Linear 0..1 → bus dB, with a true mute at the bottom of the slider
## (linear_to_db(0) is -inf).
func _apply_bus(idx: int, linear: float) -> void:
	AudioServer.set_bus_mute(idx, linear <= 0.0)
	if linear > 0.0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(linear))
