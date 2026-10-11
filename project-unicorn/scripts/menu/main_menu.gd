extends Control

## Where no run is: Continue (the newest save that opens), New game, Load (while any save exists), Settings, Credits
## and Quit to desktop in one wrapping focus chain, the pointer taking the focus along. The windows it opens stand on
## its own ModalLayer; when the last one closes the focus returns to the item that opened it.

signal new_game_requested
signal load_requested(slot_id: String)

const CREDITS := preload("res://scenes/menu/Credits.tscn")
const CREDITS_SCRIPT := preload("res://scripts/menu/credits.gd")
const MENU_COVER_S := 0.2   # [WORKING] the boot's ground lifting off the menu
const MENU_OFFICE := "city"   # [WORKING] the evening city behind the menu
const MENU_MINUTE := 1170.0   # [WORKING] 19:30
# The column and the version line read over the city: the ground's colour this strong at the left edge and at the
# bottom, fading out over the gradients' stops.
const SIDE_FADE := 0.85
const FOOT_FADE := 0.6
const LOCKUP_AUTHORED_S := 128.0   # lockup.svg's square, in the file's own pixels
# The layout of a screen 1080 tall, then of a shorter one: column origin, lock-up S, the gap under it, the version's
# distance from the left and the bottom edges.
const COLUMN := [Vector2(112, 236), Vector2(88, 112)]
const LOCKUP_S := [96, 76]
const LIST_GAP := [48, 40]
const VERSION_INSET := [Vector2(112, 32), Vector2(88, 24)]

## Focus order; an item is in the chain while it is visible.
@onready var items := {"CONTINUE": %Continue, "NEW": %NewGame, "LOAD": %Load, "SETTINGS": %Settings,
	"CREDITS": %Credits, "QUIT": %Quit}
var _opener: Control


func _ready() -> void:
	%MenuBackdrop.start(MENU_OFFICE, MENU_MINUTE)
	%SideFade.texture.gradient.colors = [Color(UiTokens.D_SURFACE_0, SIDE_FADE), Color(UiTokens.D_SURFACE_0, 0.0)]
	%FootFade.texture.gradient.colors = [Color(UiTokens.D_SURFACE_0, 0.0), Color(UiTokens.D_SURFACE_0, FOOT_FADE)]
	# Settings over the menu changes the UI scale, and with it the logical height the layout is chosen by.
	_apply_layout()
	get_viewport().size_changed.connect(_apply_layout)
	%Version.text = CREDITS_SCRIPT.version_line()

	var slots: Array = SaveManager.list_slots()
	var newest: Array = slots.filter(func(row: Dictionary) -> bool: return row.loadable)
	%Continue.visible = not newest.is_empty()
	%CardGap.visible = %Continue.visible
	if %Continue.visible:
		%Continue.show_slot(newest[0])
	%Load.visible = not slots.is_empty()
	# Without a Continue card New game is the primary item, the one amber on the screen.
	%NewGame.theme_type_variation = &"MainMenuItem" if %Continue.visible else &"MainMenuItemPrimary"
	%NewRule.visible = not %Continue.visible

	%Continue.pressed.connect(func() -> void: load_requested.emit(%Continue.slot_id))
	%NewGame.pressed.connect(new_game_requested.emit)
	%Load.pressed.connect(EventBus.save_load_requested.emit.bind("load"))
	%Settings.pressed.connect(EventBus.settings_requested.emit)
	%Credits.pressed.connect(func() -> void: %ModalLayer.add_child(CREDITS.instantiate()))
	%Quit.pressed.connect(get_tree().quit)
	var chain: Array = items.values().filter(func(item: Control) -> bool: return item.visible)
	for i in chain.size():
		var item: Control = chain[i]
		item.focus_neighbor_bottom = item.get_path_to(chain[(i + 1) % chain.size()])
		item.focus_neighbor_top = item.get_path_to(chain[i - 1])
		item.mouse_entered.connect(item.grab_focus)
		item.pressed.connect(func() -> void: _opener = item)
	%ModalLayer.child_exiting_tree.connect(_on_window_closing)
	_opener = chain[0]
	_opener.grab_focus()

	%Cover.color = UiTokens.D_SURFACE_0
	# Lifted only once drawn: the frame that mounts the menu can outlast MENU_COVER_S.
	RenderingServer.frame_post_draw.connect(_lift_cover, CONNECT_ONE_SHOT)


func _lift_cover() -> void:
	var lift := create_tween()
	lift.tween_property(%Cover, "modulate:a", 0.0, MENU_COVER_S).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	lift.tween_callback(%Cover.queue_free)


func _apply_layout() -> void:
	var short := int(get_viewport_rect().size.y < 1080)
	%Column.position = COLUMN[short]
	%Lockup.custom_minimum_size = %Lockup.texture.get_size() * LOCKUP_S[short] / LOCKUP_AUTHORED_S
	%ListGap.custom_minimum_size.y = LIST_GAP[short]
	%Version.offset_left = VERSION_INSET[short].x
	%Version.offset_top = -VERSION_INSET[short].y
	%Version.offset_bottom = -VERSION_INSET[short].y


## The id of the item that holds the focus, "" while a window has it.
func focused_id() -> String:
	var id: Variant = items.find_key(get_viewport().gui_get_focus_owner())
	return id if id != null else ""


## A load from the Load window frees the menu with its windows: nothing gets the focus back then.
func _on_window_closing(_window: Node) -> void:
	if %ModalLayer.get_child_count() == 1 and not is_queued_for_deletion():
		_opener.grab_focus.call_deferred()
