extends Node

# --tick-probe's watch (main.gd seeds the tempo world and mounts the shell, headless): WEEKS weeks on
# the real clock, every frame timed from one process_frame to the next and classed by what was
# emitted inside it: the night batch (night_skipped), an hour step (hour_changed outside it), the
# frame after either, and the run's first hour step and first night. The decision gate is not wired
# (shot shell), so a card does not stop the clock: the bot answers it once the frame after an hour or a
# night is timed. A stop (the release note's hold) is cleared as a player would clear it. A step that
# ended stopped is printed apart (TICK|stopped, with its week); the frames the probe acts in are not
# counted. Prints TICK lines.

const WEEKS := 5
const OVER_MS := 16.7
## Frames left uncounted after the probe acts: its own, and the next one that rebuilds what it opened.
const AFTER_ACT := 2

var _hour := false
var _night := false
var _saved := false
var _async := false
var _save_mark := 0          # SaveManager._last_autosave_msec when the frame began


func run(speed: int, win: String) -> void:
	EventBus.hour_changed.connect(func(_h: int) -> void: _hour = true)
	EventBus.night_skipped.connect(func() -> void: _night = true)
	# Connected after SaveManager's own handler: the boundary's autosave has just been taken, or not.
	EventBus.day_tick_completed.connect(_on_day_done)
	var top: Node = get_tree().get_first_node_in_group(&"top_bar")
	var hours: Array[float] = []
	var nights: Array[float] = []
	var each: Array[String] = []
	var after_hour := 0.0
	var after_night := 0.0
	var first_hour := -1.0
	var first_night := -1.0
	var stopped_each: Array[String] = []
	var per_night := 0
	var save_ms := -1.0
	var save_async := true
	var over := 0
	var seen := 0
	var after := ""
	var skip := AFTER_ACT
	var refreshes: int = top.refresh_count
	print("TICK START speed=%d win=%s udir=%s" % [speed, win, OS.get_user_data_dir()])
	EventBus.speed_change_requested.emit(speed)
	var t := Time.get_ticks_usec()
	while seen < WEEKS or after != "":
		_hour = false
		_night = false
		_saved = false
		_save_mark = SaveManager._last_autosave_msec
		await get_tree().process_frame
		var now := Time.get_ticks_usec()
		var ms := (now - t) / 1000.0
		t = now
		var refreshed: int = top.refresh_count - refreshes
		refreshes = top.refresh_count
		if _night:
			seen += 1
		var stopped: bool = TimeManager.current_speed == 0
		if skip > 0 or stopped:
			if skip == 0 and (_hour or _night):
				stopped_each.append("%d:%.1f" % [GameState.day, ms])
				over += int(ms > OVER_MS)
			skip = maxi(skip - 1, 0)
			after = ""
		else:
			var cls := "night" if _night else ("hour" if _hour else "")
			match after:
				"hour": after_hour = maxf(after_hour, ms)
				"night": after_night = maxf(after_night, ms)
			match cls:
				"night":
					nights.append(ms)
					each.append("%d:%.1f" % [GameState.day, ms])
					per_night = maxi(per_night, refreshed)
					if first_night < 0.0:
						first_night = ms
				"hour":
					if first_hour < 0.0:
						first_hour = ms
					else:
						hours.append(ms)
			if _saved:
				save_ms = maxf(save_ms, ms)
				save_async = save_async and _async
			if ms > OVER_MS:
				over += 1
			after = cls
		if stopped:
			if not _clear_stop(speed, win):
				return
			skip = AFTER_ACT
		elif EventGate.active_id() != "" and after == "":
			RunProbe._drain_modals()
			skip = AFTER_ACT
	hours.sort()
	print("TICK|hour|n=%d|p50=%.2f|p95=%.2f|max=%.2f" % [hours.size(), hours[int(hours.size() * 0.5)],
		hours[int(hours.size() * 0.95)], hours[-1]])
	print("TICK|after_hour|max=%.2f" % after_hour)
	print("TICK|night|n=%d|max=%.2f|each=%s" % [nights.size(), nights.max(), ";".join(each)])
	print("TICK|after_night|max=%.2f" % after_night)
	print("TICK|first_hour=%.2f" % first_hour)
	print("TICK|first_night=%.2f" % first_night)
	print("TICK|stopped|n=%d|each=%s" % [stopped_each.size(), ";".join(stopped_each)])
	print("TICK|refresh|topbar_per_night=%d" % per_night)
	print("TICK|save|frame_ms=%.2f|async=%d" % [save_ms, int(save_async and save_ms >= 0.0)])
	print("TICK|over16|n=%d" % over)
	print("TICK END")


func _on_day_done(_day: int) -> void:
	_saved = SaveManager._last_autosave_msec != _save_mark
	var task = SaveManager.get("_write_task")
	_async = _saved and task != null and task != -1


## What a player does about a stop: closes the window that holds the clock, sets the speed again and
## opens the window again; a hold that stays, or a sprint waiting in planning, is started the way the
## Product page starts it. False when the clock still does not run (TICK|stall says what holds it).
func _clear_stop(speed: int, win: String) -> bool:
	EventBus.tab_changed.emit("")
	if TimeManager.is_clock_held() or SprintSystem.mode() == "plan":
		SprintSystem.apply_lead()
		SprintSystem.start()
	EventBus.speed_change_requested.emit(speed)
	if win != "":
		EventBus.tab_changed.emit(win)
	if TimeManager.current_speed == speed:
		return true
	print("TICK|stall hold=%s" % ",".join(TimeManager._holds.keys()))
	return false
