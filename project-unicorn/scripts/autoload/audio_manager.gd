extends Node

# AudioManager — the game's audio engine (TECH_SPEC §8.3, previously empty).
# Owns the Music bus + a single AudioStreamPlayer for the looping background
# track. This turn = music only; the SFX/UI-sound layer is intentionally absent
# (SettingsModal reserves a hidden slot for it).
#
# Preference OWNERSHIP is split on purpose: this node is the live audio engine
# and public API; the persisted values (on/off + volume) live in the Settings
# autoload (§6.1). On boot we read them from Settings; on every change we apply
# the audio AND write back through Settings. Autoload order matters —
# AudioManager is registered AFTER Settings so Settings._ready() has already
# loaded settings.json before we read it here.

# ── DEĞİŞTİRİLEBİLİR TEK SATIR ────────────────────────────────────────────────
# Müzik dosyasını değiştirmek için sadece bu path'i güncelle (dosyayı assets/audio
# altına koy + Godot'a import ettir). Loop kodda açılıyor, .import ayarı gerekmez.
const MUSIC_TRACK_PATH := "res://assets/audio/Döngü Modu.mp3"
# ──────────────────────────────────────────────────────────────────────────────

const MUSIC_BUS_NAME := "Music"
const DEFAULT_VOLUME := 0.35   # linear 0..1
const DEFAULT_ENABLED := true

const KEY_ENABLED := "music_enabled"
const KEY_VOLUME := "music_volume"

var _player: AudioStreamPlayer
var _bus_idx: int = -1
var _enabled: bool = DEFAULT_ENABLED
var _volume: float = DEFAULT_VOLUME   # linear 0..1


func _ready() -> void:
	# Music must survive get_tree().paused (game pause, modal pause, speed 0) —
	# background music is not part of game flow. ALWAYS keeps the player running
	# while the rest of the tree is frozen. Toggling music off still silences it
	# (via stream_paused in _apply_enabled), pausing the GAME no longer does.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_ensure_music_bus()

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

	# Restore saved prefs (or defaults on first run).
	_enabled = bool(Settings.get_value(KEY_ENABLED, DEFAULT_ENABLED))
	_volume = float(Settings.get_value(KEY_VOLUME, DEFAULT_VOLUME))
	_apply_volume()

	if _player.stream != null:
		_player.play()
	_apply_enabled()

	print("[AudioManager] ready — bus=%d enabled=%s volume=%.2f stream=%s" % [
		_bus_idx, str(_enabled), _volume, str(_player.stream != null)])


# The project ships no default_bus_layout.tres (only the implicit Master bus),
# so we create the Music bus at runtime. If a layout is later added in the
# editor, get_bus_index finds it and we skip creation — no conflict.
func _ensure_music_bus() -> void:
	_bus_idx = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	if _bus_idx == -1:
		AudioServer.add_bus()
		_bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_bus_idx, MUSIC_BUS_NAME)
		AudioServer.set_bus_send(_bus_idx, "Master")


# ── Public API (SettingsModal drives these live) ──────────────────────────────

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


# ── Internal apply ────────────────────────────────────────────────────────────

func _apply_enabled() -> void:
	# stream_paused (vs stop) keeps playback position so re-enabling is seamless.
	if _player != null:
		_player.stream_paused = not _enabled


func _apply_volume() -> void:
	if _bus_idx < 0:
		return
	if _volume <= 0.0:
		AudioServer.set_bus_mute(_bus_idx, true)
	else:
		AudioServer.set_bus_mute(_bus_idx, false)
		AudioServer.set_bus_volume_db(_bus_idx, linear_to_db(_volume))
