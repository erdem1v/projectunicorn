class_name SalesStage
extends Control

# THE MEETING STAGE (§5.1.1, rev 6.1). The shell both acts of a sales meeting live on: the
# room behind, the counterpart's identity at the head of the dialogue column, and an empty
# content region under it that Perde 1 and Perde 2 take turns filling.
#
# WHY THIS IS ONE OBJECT AND NOT TWO SCENES. §5.1.1 seals "Perde 2 AYNI SAHNEDE kalır; sağ
# sütun cetvele, sabır kutularına ve onay şeridine döner." Owning the room, the scrim, the
# portrait and the header HERE means the act change cannot blink, cannot swap the background
# and cannot jump the header — not because the transition is animated carefully, but because
# none of those nodes are touched when the content region is refilled. The seamlessness is
# structural.
#
# THE LAYOUT IS THE VC PITCH SCENE'S, NUMBER FOR NUMBER (meeting_scene.gd + MeetingScene.tscn):
# room fallback under covered-aspect room art under a readability scrim, then a DialogueColumn
# panel anchored at 0.605 with a 28px inset, and the portrait card overhanging the column's top
# edge — the signature move of that composition. The director's ruling puts the identity
# block at the COLUMN HEAD rather than out on the room, which is what makes this a restaging
# of a proven composition instead of a new one.
#
# TERMINAL PANEL GRAMMAR IS BANNED HERE. §5.1.1: "o gramer Satış sekmesinindir." Nothing on
# this stage is a CardPanel; the column is the only frame, and the Dialogue* family dresses it.
#
# ZERO NEW THEME ITEMS. Every variation below already exists in build_theme.gd, so
# `UiTokens.THEME_STAMP` does not move.

## The room, in one line. §5.1.1 leaves the art to a later decision and this is the working
## choice: a warm wooden boardroom reads as the CUSTOMER's building. `room_anchor` was the
## alternative and it is the investor's grey glass tower — the wrong host for this meeting.
## Swapping in sales-specific art later is this constant and nothing else.
const ROOM_BG := "res://assets/art/rooms/room_bosphorus.webp"

const PORTRAIT_CARD := preload("res://scenes/ui/components/DialoguePortraitCard.tscn")

const COLUMN_ANCHOR_LEFT := 0.605      # VC parity — the column takes the right ~39.5%
const BODY_INSET := 24
const BODY_BOTTOM := 20


# TWO PLATES, ONE SLOT. §5.1.1 says "portre YA DA baş harf avatarı", and today it is always the
# avatar: no customer record carries a portrait. That distinction has to be built rather than
# faked — a `DialoguePortraitCard` with nothing in it is a bright empty photo frame at the top
# of every meeting, and it reads as missing art rather than as identity. So a portrait gets the
# 4:5 card (VC composition) and no portrait gets a circular initials plate (`_monogram` below —
# the employee-avatar pattern sized for this surface), which reads as a deliberate mark. The
# slot height is fixed across both so the header below never shifts.
const PORTRAIT_SIZE := Vector2(132, 165)
const AVATAR_D := 112
const PLATE_H := 168
const PLATE_TOP := 30                  # breathing room above the plate, inside the column
const PLATE_GAP := 16                  # plate bottom to body top

const STAR_GLYPH_PX := 15

var _plate_host: CenterContainer = null
var _name_label: Label = null
var _star_host: HBoxContainer = null
var _archetype_label: Label = null
var _badge_host: HBoxContainer = null
var _content: VBoxContainer = null


func _init() -> void:
	# Built in `_init` rather than `_ready` so a host can call `content_host()` immediately
	# after `add_child()` without depending on tree-entry order. The portrait card's own
	# `@onready` refs still resolve on tree entry, which is why `set_identity()` is the one
	# call that must wait until the stage is mounted.
	_build()


func _build() -> void:
	# ALWAYS, asserted here rather than inherited. The meeting runs at speed 0, which flips
	# `get_tree().paused`, and a node left on INHERIT is only interactive because whoever
	# mounts it is: `SalesMeetingScene` is ALWAYS, but `--negotiation-shot` mounts the stage
	# straight under Main. A contract that depends on the caller is not a contract.
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# IGNORE, not STOP: the stage is scenery. Its children still receive their own input, and
	# a scenery node that swallows clicks is the bug this line exists to prevent.
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var fallback := ColorRect.new()
	fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fallback.color = UiTokens.DIALOGUE_BG
	fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fallback)

	# EXPAND_IGNORE_SIZE + KEEP_ASPECT_COVERED: fills the frame at any window size without
	# letterboxing, which is what "full bleed to all four edges" means in practice.
	var room_art := TextureRect.new()
	room_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	room_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	room_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	room_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(room_art)
	# Missing art is not a crash: the charcoal fallback underneath stays visible and the
	# warning names the file.
	if ResourceLoader.exists(ROOM_BG):
		room_art.texture = load(ROOM_BG)
	if room_art.texture == null:
		push_warning("[SalesStage] room art missing, flat charcoal fallback: %s" % ROOM_BG)

	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = UiTokens.SCRIM_ROOM
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scrim)

	# THE COLUMN BLEEDS TO THREE EDGES, and this is where the restage leaves VC parity. The VC
	# scene insets the column 28px, which works there because its room art carries a wide cream
	# mat that the inset reveals as a frame. `room_bosphorus` carries a NARROWER mat, so the same
	# inset revealed three bright slivers instead of a frame.
	var column := Panel.new()
	column.theme_type_variation = &"DialogueColumn"
	column.anchor_left = COLUMN_ANCHOR_LEFT
	column.anchor_right = 1.0
	column.anchor_bottom = 1.0
	add_child(column)

	_plate_host = CenterContainer.new()
	_plate_host.anchor_right = 1.0
	_plate_host.offset_top = PLATE_TOP
	_plate_host.offset_bottom = PLATE_TOP + PLATE_H
	_plate_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_plate_host)

	var body := MarginContainer.new()
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	body.offset_left = BODY_INSET
	body.offset_right = -BODY_INSET
	body.offset_top = PLATE_TOP + PLATE_H + PLATE_GAP
	body.offset_bottom = -BODY_BOTTOM
	column.add_child(body)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", UiTokens.SPACE_S)
	body.add_child(stack)

	# --- the identity block, centred under the portrait (VC parity) --------------------
	_name_label = UiFactory.make_label("", &"DialogueName")
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(_name_label)

	# Ekip §4.1's row, and the reason it is the shared component: it ALWAYS draws five glyphs,
	# so the header keeps its width when a 1★ table follows a 3★ one.
	_star_host = HBoxContainer.new()
	_star_host.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_child(_star_host)

	_archetype_label = UiFactory.make_label("", &"DialogueRole", UiTokens.INK_MUTED)
	_archetype_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_archetype_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(_archetype_label)

	_badge_host = HBoxContainer.new()
	_badge_host.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_child(_badge_host)

	# CARD_BORDER, not SEPARATOR: the chrome hairline is a shade off the column's own fill and
	# vanishes into it. The card edge actually draws.
	stack.add_child(HRUiShared.hairline(UiTokens.CARD_BORDER))

	# --- the content region: Perde 1, then Perde 2, in the same box -------------------
	_content = VBoxContainer.new()
	_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", UiTokens.SPACE_M)
	stack.add_child(_content)


# ============================================================================
#  Public surface
# ============================================================================

## §5.1.1's identity block: portrait or initials avatar, name, star row, the archetype in ONE
## line, and the whale condition badge when there is one. Callable at any time; the header is
## repainted in place, which is what keeps it still across the act change.
##
## MUST be called after the stage is in the tree — `DialoguePortraitCard` resolves its own
## refs with `@onready`.
func set_identity(d: Dictionary) -> void:
	var display_name: String = String(d.get("name", ""))
	_render_plate(String(d.get("portrait_path", "")), display_name)
	_name_label.text = UiTokens.tr_upper(display_name)

	for c in _star_host.get_children():
		c.queue_free()
	_star_host.add_child(StarRating.make_stars(float(d.get("star", 0)), STAR_GLYPH_PX))

	var archetype_line: String = String(d.get("archetype_line", ""))
	_archetype_label.text = archetype_line
	_archetype_label.visible = archetype_line != ""

	for c in _badge_host.get_children():
		c.queue_free()
	# §8 — the whale's condition was already telegraphed on the pipeline card. Repeating it at
	# the table is not noise: it is the thing this meeting is about.
	var condition: String = String(d.get("whale_condition", ""))
	_badge_host.visible = condition != ""
	if condition != "":
		_badge_host.add_child(UiFactory.make_badge(
			tr("SALES_WHALE_" + condition.to_upper()), &"attention"))


## The plate is rebuilt rather than toggled: the two shapes have nothing in common but their
## slot, and keeping a dormant portrait card alive so it can be hidden is how a scene ends up
## with a bright empty frame flashing for one frame on some path nobody tested.
func _render_plate(portrait_path: String, display_name: String) -> void:
	for c in _plate_host.get_children():
		_plate_host.remove_child(c)
		c.queue_free()
	if portrait_path != "" and ResourceLoader.exists(portrait_path):
		var card: DialoguePortraitCard = PORTRAIT_CARD.instantiate()
		card.custom_minimum_size = PORTRAIT_SIZE
		_plate_host.add_child(card)      # add first — the card resolves its refs with @onready
		card.set_portrait(portrait_path, UiFactory.initials_of(display_name))
		return
	_plate_host.add_child(_monogram(UiFactory.initials_of(display_name)))


## THE INITIALS PLATE, built here rather than through `UiFactory.make_avatar`. That helper's
## `Avatar` variation is tuned for a 24px chip sitting on a card; blown up to 112px on the
## dialogue column it dissolves into the panel. Same idea, sized for this surface, and built as
## a code-side `StyleBoxFlat` so no theme item is added and `THEME_STAMP` does not move.
func _monogram(initials: String) -> Control:
	var plate := Panel.new()
	plate.custom_minimum_size = Vector2(AVATAR_D, AVATAR_D)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.SURFACE_PRESSED
	sb.set_corner_radius_all(int(AVATAR_D / 2))
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.border_color = UiTokens.BORDER_STEPPER_OWN
	plate.add_theme_stylebox_override("panel", sb)
	var label := UiFactory.make_label(initials, &"DialogueName", UiTokens.INK)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(label)
	return plate


## The region under the identity block. Perde 1 builds into it; Perde 2 replaces what is in it.
func content_host() -> Control:
	return _content


## Empties the content region without touching the room, the scrim or the header. `queue_free`
## alone is not enough here: the freed children survive until the end of the frame, so the next
## act would be added UNDER them. Removing first makes the swap immediate.
func clear_content() -> void:
	for c in _content.get_children():
		_content.remove_child(c)
		c.queue_free()


# ============================================================================
#  Column content kit — shared by Perde 1 and Perde 2
# ============================================================================

## An empty control that eats leftover column height; two of them centre what sits between.
static func make_flex() -> Control:
	var c := Control.new()
	c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


static func make_button(text: String, cb: Callable, variation: StringName) -> Button:
	var b := Button.new()
	b.text = text
	b.theme_type_variation = variation
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(cb)
	return b
