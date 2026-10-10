extends SceneTree

# Until main.gd carries the flag, the entry to the plausibility ledger is this SceneTree script:
#
#   godot --headless --path . -s res://scripts/events/tools/plausibility_main.gd \
#         -- --event-plausibility-probe=seeds=1-1:weeks=16:variant=early
#
# TWO THINGS THIS ENTRY HAS TO WORK AROUND, both because a -s script boots before the engine
# has finished mounting the project:
#   1. The tool is LOADED, never preloaded — an autoload's name becomes a resolvable identifier
#      only once Main has added the autoload nodes, so a preload of anything naming GameState
#      fails to compile.
#   2. The run waits for the first frame — _initialize() is called before the autoloads are in
#      the tree and before their _ready, so TimeManager.reset() would find get_tree() null.
#
# The spec rides on a `-probe` user argument because SaveManager reads the command line to
# decide whether a harness is driving it (_is_harness_arg): a probe must never write into the
# player's slots, and this entry mounts no main scene to tell it so.
#
# RunProbe's sim mode plays the whole run inside run(), so one frame is the whole process.

const TOOL_PATH := "res://scripts/events/tools/plausibility.gd"
const ARG := "--event-plausibility-probe="

var _spec: String = ""


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if String(arg).begins_with(ARG):
			_spec = String(arg).trim_prefix(ARG)


func _process(_delta: float) -> bool:
	if _spec == "":
		print("PLAUS ERROR no spec; want %s<spec> after the -- separator" % ARG)
		quit(2)
		return true
	quit(0 if load(TOOL_PATH).run(_spec) else 1)
	return true
