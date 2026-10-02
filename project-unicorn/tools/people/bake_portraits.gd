extends SceneTree

# Bakes the fixed portraits of Frank and the founders (portrait_baker.gd). An -s script compiles
# before the autoloads exist and the project's classes name them, so the work loads once they do.
# Windowed (the bust studio draws nothing headless), one Godot at a time, from project-unicorn/:
#
#   "$GODOT" --path . -s res://tools/people/bake_portraits.gd
#   "$GODOT" --headless --path . --import


func _initialize() -> void:
	_start.call_deferred()


func _start() -> void:
	root.add_child(load("res://tools/people/portrait_baker.gd").new())
