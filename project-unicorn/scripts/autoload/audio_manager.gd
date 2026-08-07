extends Node

# AudioManager — the game's audio engine (TECH_SPEC §8.3). Owns the bus graph
# (Master → Music, SFX) and the single AudioStreamPlayer for the looping
# background track.
#
# Preference OWNERSHIP is split on purpose: this node is the live audio engine
# and public API; the persisted values live in the Settings autoload (§6.1) under
# the keys declared in Settings.DEFAULTS. On boot we read them from Settings; on
# every change we apply the audio AND write back through Settings. Autoload order
# matters — AudioManager is registered AFTER Settings so Settings._ready() has
# already loaded settings.json before we read it here.

# ── DEĞİŞTİRİLEBİLİR TEK SATIR ────────────────────────────────────────────────
# Müzik dosyasını değiştirmek için sadece bu path'i güncelle (dosyayı assets/audio
# altına koy + Godot'a import ettir). Loop kodda açılıyor, .import ayarı gerekmez.
const MUSIC_TRACK_PATH := "res://assets/audio/Döngü Modu.mp3"
# ──────────────────────────────────────────────────────────────────────────────

const MUSIC_BUS_NAME := "Music"
const SFX_BUS_NAME := "SFX"
const MASTER_BUS_IDX := 0          # Master is always bus 0 — the engine guarantees it

const KEY_ENABLED := "music_enabled"
const KEY_VOLUME := "music_volume"
const KEY_MASTER := "master_volume"
const KEY_SFX := "sfx_volume"
const KEY_MUTE_UNFOCUSED := "mute_unfocused"

var _player: AudioStreamPlayer
var _bus_idx: int = -1             # Music
var _sfx_bus_idx: int = -1
var _enabled: bool = true
var _volume: float = 0.35          # linear 0..1 (Music)
var _master: float = 1.0           # linear 0..1
var _sfx: float = 0.7              # linear 0..1
var _mute_unfocused: bool = true
# Focus-loss mute must not fight the player's own mute: remember what Master was
# doing before we touched it and restore exactly that on focus-in.
var _focus_muted: bool = false
var _pre_focus_mute: bool = false


func _ready() -> void:
	# Music must survive get_tree().paused (game pause, modal pause, speed 0) —
	# background music is not part of game flow. ALWAYS keeps the player running
	# while the rest of the tree is frozen. Toggling music off still silences it
	# (via stream_paused in _apply_enabled), pausing the GAME no longer does.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_ensure_buses()

	_player = AudioStreamPlayer.new()
	_player.name = "MusicPlayer"
	_player.bus = MUSIC_BUS_NAME
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_player)

	var stream: AudioStream = load(MUSIC_TRACK_PATH)
	if stream == null:
		push_warning("[AudioManager] müzik yüklenemedi: %s (import edildi mi?)" % MUSIC_TRACK_PATH)
	else:
		if stream is AudioStreamMP3:
			(stream as AudioStreamMP3).loop = true   # seamless loop niyeti
		_player.stream = stream

	# Restore saved prefs (or the Settings.DEFAULTS values on first run).
	apply_from_settings()

	if _player.stream != null:
		_player.play()
	_apply_enabled()

	print("[AudioManager] ready — music=%d sfx=%d enabled=%s master=%.2f music=%.2f sfx=%.2f stream=%s" % [
		_bus_idx, _sfx_bus_idx, str(_enabled), _master, _volume, _sfx, str(_player.stream != null)])


# The project ships no default_bus_layout.tres (only the implicit Master bus), so
# both child buses are created at runtime. If a layout is later added in the
# editor, get_bus_index finds them and we skip creation — no conflict.
#
# The SFX bus deliberately ships with NO players attached: the UI/SFX layer is a
# later task. It exists now so that layer has a route to be born into, and so the
# "Efektler" slider honestly moves a real bus instead of pretending.
func _ensure_buses() -> void:
	_bus_idx = _ensure_bus(MUSIC_BUS_NAME)
	_sfx_bus_idx = _ensure_bus(SFX_BUS_NAME)


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
	_enabled = bool(Settings.get_value(KEY_ENABLED, Settings.get_default(KEY_ENABLED)))
	_volume = clampf(float(Settings.get_value(KEY_VOLUME, Settings.get_default(KEY_VOLUME))), 0.0, 1.0)
	_master = clampf(float(Settings.get_value(KEY_MASTER, Settings.get_default(KEY_MASTER))), 0.0, 1.0)
	_sfx = clampf(float(Settings.get_value(KEY_SFX, Settings.get_default(KEY_SFX))), 0.0, 1.0)
	_mute_unfocused = bool(Settings.get_value(KEY_MUTE_UNFOCUSED, Settings.get_default(KEY_MUTE_UNFOCUSED)))
	_focus_muted = false
	_apply_master()
	_apply_volume()
	_apply_sfx()
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
	_apply_volume()
	Settings.set_value(KEY_VOLUME, _volume)
	EventBus.music_volume_changed.emit(_volume)


func get_music_volume() -> float:
	return _volume


## Ana ses — bus 0 (Master). No signal: nothing outside the settings panel reflects
## it today, and the panel reads the getter. (EventBus.music_* already fire into
## the void; two more unheard signals would be dead weight — audit S3-5.)
func set_master_volume(v: float) -> void:
	_master = clampf(v, 0.0, 1.0)
	_apply_master()
	Settings.set_value(KEY_MASTER, _master)


func get_master_volume() -> float:
	return _master


func set_sfx_volume(v: float) -> void:
	_sfx = clampf(v, 0.0, 1.0)
	_apply_sfx()
	Settings.set_value(KEY_SFX, _sfx)


func get_sfx_volume() -> float:
	return _sfx


func set_mute_unfocused(on: bool) -> void:
	_mute_unfocused = on
	Settings.set_value(KEY_MUTE_UNFOCUSED, on)
	if not on and _focus_muted:
		_restore_focus_mute()   # turning the option off mid-mute must not strand silence


func is_mute_unfocused() -> bool:
	return _mute_unfocused


# ── Focus-loss mute ───────────────────────────────────────────────────────────

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_enter_focus_mute()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_restore_focus_mute()


func _enter_focus_mute() -> void:
	if not _mute_unfocused or _focus_muted:
		return
	# Remember the pre-mute state so a player who muted Master themselves stays
	# muted when they come back — we restore what WAS, not what we assume.
	_pre_focus_mute = AudioServer.is_bus_mute(MASTER_BUS_IDX)
	_focus_muted = true
	AudioServer.set_bus_mute(MASTER_BUS_IDX, true)


func _restore_focus_mute() -> void:
	if not _focus_muted:
		return
	_focus_muted = false
	AudioServer.set_bus_mute(MASTER_BUS_IDX, _pre_focus_mute)


# ── Internal apply ────────────────────────────────────────────────────────────

func _apply_enabled() -> void:
	# stream_paused (vs stop) keeps playback position so re-enabling is seamless.
	if _player != null:
		_player.stream_paused = not _enabled


func _apply_master() -> void:
	_apply_bus(MASTER_BUS_IDX, _master)


func _apply_volume() -> void:
	_apply_bus(_bus_idx, _volume)


func _apply_sfx() -> void:
	_apply_bus(_sfx_bus_idx, _sfx)


## Linear 0..1 → bus dB, with a true mute at the bottom of the slider
## (linear_to_db(0) is -inf, and a mute flag is the honest way to say silence).
func _apply_bus(idx: int, linear: float) -> void:
	if idx < 0:
		return
	if linear <= 0.0:
		AudioServer.set_bus_mute(idx, true)
	else:
		AudioServer.set_bus_mute(idx, false)
		AudioServer.set_bus_volume_db(idx, linear_to_db(linear))
