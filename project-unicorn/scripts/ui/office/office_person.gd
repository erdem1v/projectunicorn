class_name OfficePerson
extends Node3D

# One person in the office, on a Quaternius body (OfficeBody). OfficePeople says where they go and
# what they do there; this node gets them there without a jump: it walks the baked floor with a
# NavigationAgent3D (avoiding the others), steps over the bake's links and a spot's own last metres
# along the design's path, turns to the spot, and sits, stands or lies through the clips.
#
# The contract: setup() once, then place() before anything else, in the same frame as add_child.
# place() is a cut (a scene's first frame, a load, a skip under black); go_to() never jumps. `k` is
# the visual speed: in the office OfficePeople sets it every frame to the game's tempo; a meeting's
# people keep 1. At 0 the person holds still in whatever pose they are in, and carries on from it.
# Up to OfficeConstants.AVOID_MAX_K the agent's avoidance steers walkers round each other; faster,
# its steps are too long for it, and they walk their paths straight, through each other.

const LIBS := {
	"ual1": "res://assets/art/people/anims/ual1.glb",
	"ual2": "res://assets/art/people/anims/ual2.glb",
	"m2m": "res://assets/art/people/anims/m2m_addon.glb",
}
## Clips that loop though their files do not say so.
const LOOPED := ["m2m/Walk_Backwards", "m2m/Strafe_left", "m2m/Strafe_right", "m2m/Walk_Female",
	"m2m/Sleeping", "m2m/Idle_Subtle", "ual2/Consume", "m2m/Head Nod"]
## Forward walks by gait; the others share back and side steps. The first ANY_GAITS are anyone's,
## the rest a woman's.
const GAITS := ["ual1/Walk", "ual1/Walk_Formal", "m2m/Walk_Female"]
const ANY_GAITS := 2
## Standing idle is Mesh2Motion's: UAL's stands with one foot far back, which reads as mid-stride.
## Acts with a clip of their own; any other act plays the idle ("" and unknown acts too).
const STAND_ACTS := {"idle": "m2m/Idle_Subtle", "talk": "ual1/Idle_Talking", "phone": "ual2/Idle_TalkingPhone",
	"drink": "ual2/Consume", "wait": "ual2/Idle_FoldArms", "nod": "m2m/Head Nod", "listen": "m2m/Idle Listening"}
const SEAT_ACTS := {"idle": "ual1/Sitting_Idle", "talk": "ual1/Sitting_Talking"}
## Acts done by hand over the idle clip, seated and standing. Per act: each hand's target in the
## body's frame (x left, y up, z forward, metres from the root, which a seated body has on the
## floor under the seat), or none to leave that hand to the clip; how far the spine leans in
## (radians, back if negative), the head bows, the head turns side to side, a seated body slides
## to the chair's front edge (m), the motion the hands make, what the person holds or has in
## front of them, and where the elbows point (POLES unless given). The seated clip leans back and these arms are short, so typing leans in and
## slides; the keyboard is where the design's desk has it (office-sim-v12.js station).
const SEAT_HANDS := {
	"type": {"left": Vector3(0.18, 0.78, 0.65), "right": Vector3(-0.06, 0.78, 0.65), "lean": 0.35, "nod": 0.1,
		"slide": 0.2, "motion": "tap"},
	"notes": {"left": Vector3(0.3, 0.78, 0.6), "right": Vector3(0.08, 0.79, 0.62), "lean": 0.35, "nod": 0.3,
		"slide": 0.2, "motion": "write", "props": ["notebook", "pen"]},
	"read": {"left": Vector3(0.1, 0.92, 0.4), "right": Vector3(-0.1, 0.92, 0.4), "lean": 0.1, "nod": 0.35,
		"slide": 0.1, "props": ["paper"]},
	"lean_back": {"left": Vector3(0.12, 1.22, -0.36), "right": Vector3(-0.12, 1.22, -0.36), "lean": -0.15, "nod": -0.1,
		"poles": [Vector3(0.7, 1.3, -0.3), Vector3(-0.7, 1.3, -0.3)]},
	"look": {"turn": 0.5},
	"phone": {"right": Vector3(-0.1, 1.12, -0.2), "nod": 0.05, "props": ["phone"]},
	"drink": {"right": Vector3(-0.06, 1.02, -0.12), "nod": 0.1, "props": ["cup"],
		"poles": [Vector3(0.45, 0.6, -0.2), Vector3(-0.25, 0.4, 0.1)]},
	"nod": {"motion": "nod"},
	"listen": {"lean": 0.15, "nod": 0.05},
	"stretch": {"left": Vector3(0.15, 1.75, -0.2), "right": Vector3(-0.15, 1.75, -0.2), "lean": -0.12, "nod": -0.2},
	"yawn": {"right": Vector3(-0.02, 1.1, -0.12), "nod": -0.25},
	# Round a meeting table: forearms on it, hands in the lap, or notes on the table's own pad.
	"table": {"left": Vector3(0.16, 0.79, 0.5), "right": Vector3(-0.16, 0.79, 0.5), "lean": 0.2, "slide": 0.15},
	"rest": {"left": Vector3(0.14, 0.58, 0.38), "right": Vector3(-0.14, 0.58, 0.38), "lean": -0.05},
	"write": {"left": Vector3(0.22, 0.785, 0.55), "right": Vector3(-0.04, 0.79, 0.62), "lean": 0.35, "nod": 0.3,
		"slide": 0.2, "motion": "write", "props": ["pen"]},
}
## A meeting's gestures that move a hand, over the seated act while they run: a look at the watch,
## and notes written on the table from any post, as the pen seat writes.
const GESTURE_HANDS := {
	"watch": {"left": Vector3(0.06, 0.9, 0.4)},
	"notes": SEAT_HANDS["write"],
}
const STAND_HANDS := {
	"phone": {"props": ["phone"]},
	"drink": {"props": ["cup"]},
	"stretch": {"left": Vector3(0.15, 2.1, 0.0), "right": Vector3(-0.15, 2.1, 0.0), "lean": -0.12, "nod": -0.2},
	"yawn": {"right": Vector3(-0.02, 1.5, 0.12), "nod": -0.25},
}
## What people hold or set down: a block of this size and colour (sRGB), on a hand bone at an
## offset in its frame, or in the body's frame like the hand targets.
const PROPS := {
	"cup": {"size": Vector3(0.07, 0.09, 0.07), "color": "#ece8df", "bone": &"RightHand", "at": Vector3(-0.03, 0.08, 0.03)},
	"phone": {"size": Vector3(0.07, 0.14, 0.01), "color": "#1f1d1c", "bone": &"RightHand", "at": Vector3(0.0, 0.08, 0.02)},
	"pen": {"size": Vector3(0.008, 0.13, 0.008), "color": "#26272b", "bone": &"RightHand", "at": Vector3(0.0, 0.07, 0.03)},
	"paper": {"size": Vector3(0.21, 0.28, 0.004), "color": "#f3f1ea", "at": Vector3(0.0, 0.98, 0.43), "tilt": -0.9},
	"notebook": {"size": Vector3(0.17, 0.012, 0.23), "color": "#3a4a5c", "at": Vector3(0.2, 0.765, 0.62)},
}
const POLES := [Vector3(0.45, 0.6, -0.2), Vector3(-0.45, 0.6, -0.2)]
const HAND_TAP := 0.012        # typing: how high a finger lifts, and how often
const HAND_TAP_RATE := 7.0
const HAND_WRITE := 0.012      # writing: the circle the pen hand draws
const HAND_WRITE_RATE := 5.0
const HAND_NOD := 0.12         # a seated nod's depth, radians, and rate
const HAND_NOD_RATE := 5.0
const HAND_LOOK_RATE := 0.6
const HAND_EASE := 4.0         # how fast hands, lean and slide come and go, per second
const HAND_MOVE := 1.5         # how fast a hand moves between two acts' places, m/s
const WALK_SPEED := 2.4        # [WORKING] m/s at k = 1
const CLIP_PACE := 1.3         # m/s the forward walks cover at their own speed
const RADIUS := 0.28
## A seat is sat into from this far behind it, the stretch the sit-down and stand-up clips cover.
const SEAT_BACK := 0.55
## The seated clips put the hips behind the body's root; this far forward they meet the chair's
## middle, within reach of the desk.
const SEAT_FORWARD := 0.12
const FACE_S := 0.3            # seconds to turn to a spot before sitting or acting
## A bed is got into as a person does: sat on at its end, then lain back along it; getting up
## runs the other way. Sat, the root is this far below the bed's top (the seated clips' hips are
## 0.55 up, so they sink a little) and this far out from the design's spot, so the lower legs hang
## past the end. Lying, the root is this far below the top, this far back from the spot and this
## far to one side, the head on one pillow.
const BED_SIT_DROP := 0.6
const BED_END := 0.3
const BED_SINK := 0.05
const BED_HEAD := 0.85
const BED_SIDE := 0.35
const LIE_S := 1.4             # seconds to lie back and slide up, or slide down and sit up
const LIE_XFADE := 0.9         # of which the pose changes over this long: lying back comes first,
                               # sitting up last
const XFADE := 0.25            # also how long a walker takes to reach full speed
const TURN_RATE := 10.0        # yaw easing per second while walking
## The baked floor lies this far above the drawn one (the voxel's top). A walker is eased back onto
## it, never faster than it walks (up or down at least FLOOR_EASE a tick).
const NAV_LIFT := 0.1
const FLOOR_EASE := 0.02
## A point is on the floor within this height of the drawn floor under the baked one (a stair's
## landing is not the floor below it).
const FLOOR_RISE := 0.6
## A walk that ends further than this from where it was going did not get there.
const UNREACHED := 0.5
## A walker that gets less than STALL_GAIN closer in STALL_S (ambient seconds, and STALL_MIN_S real
## ones at the least, so the avoidance gets its ticks at any k) is jammed: within JAM_NEAR of the way
## in it takes the last metres straight; held up by someone standing at a spot in the way (a visitor
## in an aisle), it squeezes past them for SQUEEZE_S; otherwise it asks for a new path.
const STALL_S := 1.0
const STALL_MIN_S := 0.25      # [WORKING]
const STALL_GAIN := 0.1
const JAM_NEAR := 0.8
const SQUEEZE_S := 1.5
## Straight steps (a spot's last metres, a walk out) wait while someone stands this close ahead,
## at most this long; into a door, where the one ahead goes through, at most DOOR_WAIT.
const FOLLOW_CLEAR := 0.56
const FOLLOW_WAIT := 1.5
const DOOR_WAIT := 6.0
## Pose updates thin out with size on screen: [min pixel height, every nth frame]. A seated body
## that is not easing in or out counts as small; one off screen still poses, every OFF_SCREEN
## frames, so it follows each clip change as it comes.
const LOD := [[90.0, 1], [45.0, 2], [0.0, 3]]
const OFF_SCREEN := 6
const BODY_HEIGHT := 1.8
## A meeting's head: how far it turns to the one it looks at, to the side and up or down
## (radians), and how fast it gets there, per second. A gesture rises and falls over this share of
## its length.
const LOOK_YAW := 1.25
const LOOK_PITCH := 0.35
const LOOK_EASE := 5.0
const GESTURE_EDGE := 0.18

enum Phase { STILL, WALK, FOLLOW, TURN, SIT_DOWN, SEATED, STAND_UP, LIE_DOWN, LYING, GET_UP, WAIT_LINK }
## Phases off the feet (no avoidance, no one's way blocked) and on the move (the walk space blends).
const DOWN := [Phase.SEATED, Phase.SIT_DOWN, Phase.LYING, Phase.LIE_DOWN]
const MOVING := [Phase.WALK, Phase.FOLLOW, Phase.WAIT_LINK]
## The looped states' own speed, under the state machine's.
const LOOP_PACES := [&"parameters/stand/pace/scale", &"parameters/seated/pace/scale", &"parameters/sleep/pace/scale"]
## The agent takes a path's next point from this close; a straight walker cuts a corner by at most
## this much.
const PATH_NEAR := 0.3
## Walkers give way to everyone else: people standing, stepping along a path or getting up
## hold their line (avoidance_priority).
const PRIORITY_WALK := 0.5
const PRIORITY_HOLD := 1.0
## Someone waiting for a link busy the other way steps this far back from its mouth, the next one
## a body behind them; the one ahead on a link must be this far in before the next follows.
const LANE_BACK := 0.9
const LANE_GAP := 0.9

static var _tree_root: AnimationNodeStateMachine
static var _libs := {}
static var _sit_s := 0.0
static var _stand_s := 0.0
## The office's baked links: RID -> {path} (a to b); set once per office with set_links().
static var _links := {}
## A link is one lane at a time: link RID -> {entry, dir, people, held}. People going the same way
## follow each other in; the other way waits, and once someone waits there no one else goes in.
static var _lanes := {}
## link RID -> the people waiting to go in against the lane, in the order they came.
static var _waiting := {}
## Everyone in the office, for the straight steps' look ahead.
static var _people: Array[OfficePerson] = []

var k := 1.0
var spot := {}                 # where this person is, or is heading
var act := "idle"
var phase := Phase.STILL
## A meeting's overlays on the seated pose (MeetingCast): whom the head turns to (their head), a
## lean and a head tilt added to the act's (the tilt only while looking at no one), and every
## frame posed however small on screen.
var look_at: OfficePerson = null
var lean_bias := 0.0
var head_bias := 0.0
var full_rate := false

var _body: Node3D
var _skel: Skeleton3D
var _tree: AnimationTree
var _playback: AnimationNodeStateMachinePlayback
var _walk_param: StringName
var _agent: NavigationAgent3D
var _follow := PackedVector3Array()   # points walked straight, off the baked floor
var _after_follow := Phase.STILL
var _turn_from := 0.0
var _turn_to := 0.0
var _t := 0.0
var _from := Vector3.ZERO
var _velocity := Vector3.ZERO
var _accel := 0.0                # a walker's share of full speed, 0 when setting off
var _hold := 0.0                 # how long this stretch of straight steps has waited for others
var _stall := 0.0
var _stall_best := INF
var _squeeze := 0.0              # seconds left walking past others without steering round them
var _here := {}                  # the spot the body is in, or last reached
var _goal := {}                  # the spot the walk under way heads for
var _to := Vector3.ZERO          # where sitting ends
var _exit := Vector3.ZERO        # where standing or getting up ends
var _out := PackedVector3Array() # from there back onto the floor
var _lane := RID()               # the link this person is on or waiting for
var _link_path := PackedVector3Array()   # the way through the link this person is at
var _wait_at := Vector3.ZERO             # where they wait while it is busy
var _pose_dt := 0.0
var _blend := Vector2.ZERO               # where the walk space is: x sideways, y forward
var _prev_pos := Vector3.ZERO            # the root at the last physics tick, drawn between ticks
var _prev_yaw := 0.0
var _gesture: OfficeGesture
var _iks: Array[TwoBoneIK3D] = []        # left, right
var _hands: Array[Node3D] = []           # their targets
var _poles: Array[Node3D] = []           # where their elbows point
var _hand_w := PackedFloat32Array([0.0, 0.0])
var _hand_at := PackedVector3Array([Vector3.ZERO, Vector3.ZERO])   # where each hand is held
var _lean := 0.0
var _nod := 0.0
var _slide := 0.0
var _turn := 0.0
var _clock := 0.0                        # the hands' motions and the head's turns
var _loop := 0.0                         # the looped states' pace, as last set
var _props := {}                         # name -> the prop's node, made at first use
var _pose_slot := 0                      # which frame of six this body poses on (tiers: 1, 2, 3)
var _idle_offset := 0.0                  # how far into its idles this body starts
var _head_bone := -1
var _look := Vector2.ZERO                # the head's eased look: to the side, down
var _lean_eased := 0.0                   # lean_bias, eased
var _gesture_name := ""
var _gesture_len := 0.0
var _gesture_left := 0.0                 # ambient seconds


## Builds the body for `look`, and its gait; place() puts it somewhere before go_to() may walk it.
func setup(look: Dictionary) -> void:
	# From the signature, not the dictionary: a look read back from a save has its keys reordered.
	var h := LookSystem.signature(look).hash()
	var gait := posmod(h, GAITS.size() if look.sex == "w" else ANY_GAITS)
	_body = OfficeBody.build(look)
	add_child(_body)
	var player := AnimationPlayer.new()
	_body.add_child(player)
	player.root_node = NodePath("..")
	for key: String in _libraries():
		player.add_animation_library(key, _libs[key])
	_tree = AnimationTree.new()
	_body.add_child(_tree)
	_tree.anim_player = _tree.get_path_to(player)
	_tree.tree_root = _state_machine()
	# UAL's forward walks carry their stride on the Root bone. Taken off as root motion, which
	# nothing reads (the agent moves the root), the body walks in place over the root.
	_tree.root_motion_track = NodePath("%GeneralSkeleton:Root")
	_tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	_tree.active = true
	_tree.set("parameters/move/gait/transition_request", "g%d" % gait)
	_walk_param = StringName("parameters/move/walk_%d/blend_position" % gait)
	_playback = _tree.get("parameters/playback")
	_pose_slot = posmod(gait + h, 6)
	_idle_offset = posmod(h, 997) / 997.0 * 2.0
	_skel = _body.get_node("%GeneralSkeleton")
	_head_bone = _skel.find_bone("Head")
	_skel.modifier_callback_mode_process = Skeleton3D.MODIFIER_CALLBACK_MODE_PROCESS_MANUAL
	_gesture = OfficeGesture.new()
	_skel.add_child(_gesture)
	for side in 2:
		var pre: String = ["Left", "Right"][side]
		var ik := TwoBoneIK3D.new()
		_skel.add_child(ik)
		ik.set_setting_count(1)
		var hand := Node3D.new()
		add_child(hand)
		var pole := Node3D.new()
		add_child(pole)
		pole.position = POLES[side]
		_poles.append(pole)
		ik.set_root_bone_name(0, pre + "UpperArm")
		ik.set_middle_bone_name(0, pre + "LowerArm")
		ik.set_end_bone_name(0, pre + "Hand")
		ik.set_target_node(0, ik.get_path_to(hand))
		ik.set_pole_node(0, ik.get_path_to(pole))
		ik.influence = 0.0
		ik.active = false
		_iks.append(ik)
		_hands.append(hand)
	_agent = NavigationAgent3D.new()
	add_child(_agent)
	_agent.radius = RADIUS
	_agent.max_neighbors = 6
	_agent.path_desired_distance = PATH_NEAR
	_agent.target_desired_distance = 0.1
	_agent.path_height_offset = NAV_LIFT
	_agent.avoidance_enabled = true
	_agent.velocity_computed.connect(_on_safe_velocity)
	_agent.link_reached.connect(_on_link_reached)


## The office's baked links, [{rid, path}], for everyone in it; a new office starts with no lanes.
static func set_links(links: Array) -> void:
	_links.clear()
	_lanes.clear()
	_waiting.clear()
	for l: Dictionary in links:
		_links[l.rid] = l


func _enter_tree() -> void:
	_people.append(self)


func _exit_tree() -> void:
	_people.erase(self)
	_stop_waiting()
	_leave_lane()


## Puts this person at `at` in its pose, doing `what`, with no walk: whatever they were doing ends.
func place(at: Dictionary, what: String) -> void:
	_stop_waiting()
	_leave_lane()
	spot = at
	_here = at
	_goal = at
	act = what
	_follow.clear()
	_velocity = Vector3.ZERO
	_blend = Vector2.ZERO
	visible = at.pose != "out"
	position = _seat(at) if at.pose == "sit" else (_bed(at) if at.pose == "lie" else at.pos)
	_to = position
	rotation.y = at.face
	_prev_pos = position
	_prev_yaw = rotation.y
	_agent.target_position = position
	_agent.set_velocity_forced(Vector3.ZERO)
	match at.pose:
		"sit":
			_playback.start(&"seated")
			phase = Phase.SEATED
		"lie":
			_playback.start(&"sleep")
			phase = Phase.LYING
		_:
			_playback.start(&"stand" if at.pose == "stand" else &"move")
			phase = Phase.STILL
	_set_act(what)
	_ease_hands(INF)
	# Posed before it is first drawn, and a room placed at once does not idle in step.
	_pose(_idle_offset * maxf(1.0, k / OfficeConstants.ANIM_LOOP_MAX))


## Walks to `to` and does `what` there, up from a seat or bed first. Sent to the spot they are in
## or already heading for, they only change what they do. A sit, lie, turn or step along a path
## under way ends first; then the body heads on.
func go_to(to: Dictionary, what: String) -> void:
	if is_same(to, spot):
		act = what
		if not is_walking():
			_set_act(what)
		return
	spot = to
	act = what
	visible = true
	match phase:
		Phase.STILL, Phase.SEATED, Phase.LYING:
			_leave()
		Phase.WALK, Phase.WAIT_LINK:
			_stop_waiting()
			_lane = RID()
			_start_walk()


## On the way somewhere or into or out of a spot; otherwise settled in `spot`.
func is_walking() -> bool:
	return phase not in [Phase.STILL, Phase.SEATED, Phase.LYING]


## A meeting's gesture over the pose for `seconds` (ambient): nod, shake, lookup, lean, back (a
## lean back with a shake of the head), watch (a look at the watch), notes (writing on the table),
## pen (the head's wobble as the pen goes down; MeetingCast moves the pen and the lean). A new one
## replaces the one under way.
func gesture(gesture_name: String, seconds: float) -> void:
	_gesture_name = gesture_name
	_gesture_len = seconds
	_gesture_left = _gesture_len


## Where this person's head is, for others to look at.
func head_position() -> Vector3:
	return _skel.global_transform * _skel.get_bone_global_pose(_head_bone).origin


func _physics_process(delta: float) -> void:
	_prev_pos = position
	_prev_yaw = rotation.y
	var dt := delta * k
	var seated := phase in DOWN
	_squeeze = maxf(0.0, _squeeze - dt)
	_agent.avoidance_enabled = visible and not seated and _squeeze == 0.0 and k <= OfficeConstants.AVOID_MAX_K
	var steering := phase in [Phase.WALK, Phase.WAIT_LINK]
	_agent.avoidance_priority = PRIORITY_WALK if steering else PRIORITY_HOLD
	_agent.neighbor_distance = 3.0 * maxf(1.0, k)
	if not steering and not seated:
		# Others steer round where this person is going, or round where they stand.
		_agent.velocity = _velocity if phase == Phase.FOLLOW else Vector3.ZERO
	if phase in MOVING:
		_accel = move_toward(_accel, 1.0, dt / XFADE)
	else:
		_accel = 0.0
	match phase:
		Phase.WALK:
			_step_walk(delta)
		Phase.FOLLOW:
			_step_follow(dt)
		Phase.TURN:
			_t += dt / FACE_S
			rotation.y = lerp_angle(_turn_from, _turn_to, smoothstep(0.0, 1.0, minf(1.0, _t)))
			if _t >= 1.0:
				_settle()
		Phase.SIT_DOWN:
			_t += dt
			position = _from.lerp(_to, smoothstep(0.0, 1.0, minf(1.0, _t / _sit_s)))
			if _t >= _sit_s:
				if _here.pose == "lie" and is_same(spot, _here):
					_t = 0.0
					_from = position
					_playback.travel(&"sleep")
					phase = Phase.LIE_DOWN
				else:
					_down(Phase.SEATED)
		Phase.STAND_UP:
			_t += dt
			position = _from.lerp(_exit, smoothstep(0.0, 1.0, minf(1.0, _t / _stand_s)))
			if _t >= _stand_s:
				_walk_out()
		Phase.LIE_DOWN:
			_t += dt
			_on_bed(_bed(_here), ease(minf(1.0, _t / LIE_S), 2.0), minf(1.0, _t / LIE_XFADE))
			if _t >= LIE_S:
				_down(Phase.LYING)
		Phase.GET_UP:
			var slid := _t >= LIE_S - LIE_XFADE
			_t += dt
			if not slid and _t >= LIE_S - LIE_XFADE:
				_playback.travel(&"seated")
			_on_bed(_seat(_here), ease(minf(1.0, _t / LIE_S), 0.5), clampf((_t - LIE_S + LIE_XFADE) / LIE_XFADE, 0.0, 1.0))
			if _t >= LIE_S:
				phase = Phase.SEATED
				_leave()
		Phase.WAIT_LINK:
			if _can_enter(_lane, _link_path[0]):
				_stop_waiting()
				_follow = _link_path
				_enter_lane()
			else:
				var d := _wait_at - position
				d.y = 0.0
				_go_towards(d if d.length() > 0.15 else Vector3.ZERO, 0.5, delta)


func _step_walk(delta: float) -> void:
	# Before the navigation map's first sync there is no path yet.
	if NavigationServer3D.map_get_iteration_id(_agent.get_navigation_map()) == 0:
		return
	if _agent.is_navigation_finished():
		_end_walk()
		return
	# Handed a link's mouth: the link takes the walker from here.
	if phase != Phase.WALK:
		return
	var left := _agent.distance_to_target()
	if left < _stall_best - STALL_GAIN:
		_stall_best = left
		_stall = 0.0
	elif k > 0.0:
		_stall += delta
	if _stall * k > STALL_S and _stall > STALL_MIN_S:
		_stall = 0.0
		_stall_best = INF
		if left < JAM_NEAR:
			_last_metres()
			return
		if _people.any(func(p: OfficePerson) -> bool: return p.visible and p.phase == Phase.STILL and p.position.distance_to(position) < 1.0):
			_squeeze = SQUEEZE_S
		else:
			_agent.target_position = _agent.target_position
	if _agent.avoidance_enabled:
		var next := _agent.get_next_path_position()
		_go_towards(Vector3(next.x - position.x, 0.0, next.z - position.z), 1.0, delta)
		return
	# Along the path by the tick's walk, round as many corners as it takes: the agent hands on each
	# point reached, and says when it is a link's.
	var budget := WALK_SPEED * delta * k * _accel
	var dir := Vector3.ZERO
	while budget > 0.0 and not _agent.is_navigation_finished():
		var next := _agent.get_next_path_position()
		if phase != Phase.WALK:
			break
		var d := Vector3(next.x - position.x, 0.0, next.z - position.z)
		if d.length() < 0.001:
			break
		dir = d.normalized()
		var go := minf(budget, d.length())
		_stride(dir * go)
		budget -= go
	if phase == Phase.WALK:
		_velocity = dir * (WALK_SPEED * k * _accel - budget / delta)


## Towards the end of the flat `d` at `share` of full speed, asking for no step past it: steered by
## the avoidance, or with it off (fast, or squeezing past), straight.
func _go_towards(d: Vector3, share: float, delta: float) -> void:
	var speed := minf(WALK_SPEED * k * share * _accel, d.length() / delta)
	if _agent.avoidance_enabled:
		_agent.max_speed = WALK_SPEED * k
		_agent.velocity = d.normalized() * speed
		return
	_velocity = d.normalized() * speed
	if speed > 0.0:
		_stride(_velocity * delta)


func _process(delta: float) -> void:
	if not visible:
		return
	# The root moves at the physics tick; the body is drawn between the last two ticks.
	var f := Engine.get_physics_interpolation_fraction()
	var shown := _prev_pos.lerp(position, f)
	_ease_hands(delta * minf(k, OfficeConstants.ANIM_LOOP_MAX))
	_body.position = (shown - position).rotated(Vector3.UP, -rotation.y) + Vector3(0.0, 0.0, _slide)
	_body.rotation.y = angle_difference(rotation.y, lerp_angle(_prev_yaw, rotation.y, f))
	# Paused (k = 0), the pose holds with the root, so it carries on from where it stopped.
	_pose_dt += delta * k
	if _gesture_left > 0.0:
		_gesture_left = maxf(0.0, _gesture_left - delta * k)
		if _gesture_left == 0.0:
			_gesture_name = ""
	var every := _lod_every()
	if Engine.get_process_frames() % every != _pose_slot % every:
		return
	_pose(_pose_dt)
	_pose_dt = 0.0


## The act done by hand now, for the posture the body is in; empty when there is none.
func _hand_act() -> Dictionary:
	if phase == Phase.SEATED:
		var a: Dictionary = SEAT_HANDS.get(act, {})
		return a.merged(GESTURE_HANDS[_gesture_name], true) if GESTURE_HANDS.has(_gesture_name) else a
	if phase == Phase.STILL and _here.get("pose", "") == "stand":
		return STAND_HANDS.get(act, {})
	return {}


## Hands, lean, bow, turn and slide eased `by` towards the act's (by INF: at once).
func _ease_hands(by: float) -> void:
	var a := _hand_act()
	for side in 2:
		var target: Variant = a.get(["left", "right"][side])
		if target != null:
			# A hand coming from the clip starts at its place; one already held moves over.
			_hand_at[side] = target if _hand_w[side] == 0.0 or by == INF else _hand_at[side].move_toward(target, by * HAND_MOVE)
		_hand_w[side] = move_toward(_hand_w[side], 1.0 if target != null else 0.0, by * HAND_EASE)
		var pole: Vector3 = a.get("poles", POLES)[side]
		_poles[side].position = pole if by == INF else _poles[side].position.move_toward(pole, by * HAND_MOVE)
	_lean = move_toward(_lean, a.get("lean", 0.0), by * HAND_EASE * 0.4)
	_nod = move_toward(_nod, a.get("nod", 0.0), by * HAND_EASE * 0.4)
	_slide = move_toward(_slide, a.get("slide", 0.0), by * HAND_EASE * 0.2)
	_turn = move_toward(_turn, a.get("turn", 0.0), by * HAND_EASE * 0.4)
	var held: Array = a.get("props", [])
	for prop_name: String in PROPS:
		if held.has(prop_name):
			prop(prop_name).visible = true
		elif _props.has(prop_name):
			_props[prop_name].visible = false


## Moves the pose on by `dt`: the hands and bends of the act, the walk space, the clips.
func _pose(dt: float) -> void:
	# Loops (the idles, the stride, the hands' motions) show at most ANIM_LOOP_MAX times their own
	# speed; the state machine's one-shots and fades keep k, in step with the phases that time them.
	var loop := minf(1.0, OfficeConstants.ANIM_LOOP_MAX / k) if k > 0.0 else 1.0
	_clock += dt * loop
	var a := _hand_act()
	var motion: String = a.get("motion", "")
	for side in 2:
		_iks[side].active = _hand_w[side] > 0.0
		_iks[side].influence = smoothstep(0.0, 1.0, _hand_w[side])
		var offset := Vector3.ZERO
		if motion == "tap":
			offset = Vector3.UP * maxf(0.0, sin(_clock * HAND_TAP_RATE + side * PI + _pose_slot)) * HAND_TAP
		elif motion == "write" and side == 1:
			offset = Vector3(cos(_clock * HAND_WRITE_RATE), 0.0, sin(_clock * HAND_WRITE_RATE)) * HAND_WRITE
		_hands[side].position = _hand_at[side] + offset
	var g := _gesture_offsets()
	_lean_eased = move_toward(_lean_eased, lean_bias, dt * HAND_EASE * 0.4)
	_look = _look.lerp(_look_target(), minf(1.0, dt * LOOK_EASE))
	_gesture.lean = _lean + _lean_eased + g.x
	_gesture.nod = _nod + (sin(_clock * HAND_NOD_RATE) * HAND_NOD if motion == "nod" else 0.0)
	_gesture.turn = _turn * sin(_clock * HAND_LOOK_RATE + _pose_slot)
	_gesture.look_pitch = _look.y + g.y
	_gesture.look_yaw = _look.x + g.z
	if k > 0.0:
		# The walk space follows the root's own speed, so setting off and slowing in a crowd blend.
		var moving := phase in MOVING
		var v := global_basis.inverse() * _velocity / (WALK_SPEED * k)
		var local := Vector2(v.x, v.z).limit_length(1.0) if moving else Vector2.ZERO
		_blend = _blend.move_toward(local, dt / XFADE)
		_tree.set(_walk_param, _blend)
		# The stride keeps up with the root, to the loops' cap.
		var stride := minf(maxf(0.6 * k, _velocity.length() / CLIP_PACE), OfficeConstants.ANIM_LOOP_MAX) / k
		_tree.set(&"parameters/move/pace/scale", stride if moving else loop)
		if loop != _loop:
			_loop = loop
			for pace: StringName in LOOP_PACES:
				_tree.set(pace, loop)
	_tree.advance(dt)
	_skel.advance(dt)


## The head's way to the one it looks at: (to the body's left, down), within LOOK_YAW and
## LOOK_PITCH; ahead, tilted by head_bias, when it looks at no one.
func _look_target() -> Vector2:
	if look_at == null or not look_at.visible:
		return Vector2(0.0, head_bias)
	var from := head_position()
	var to := look_at.head_position()
	var yaw := wrapf(atan2(to.x - from.x, to.z - from.z) - rotation.y, -PI, PI)
	var pitch := -atan2(to.y - from.y, Vector2(to.x - from.x, to.z - from.z).length())
	return Vector2(clampf(yaw, -LOOK_YAW, LOOK_YAW), clampf(pitch, -LOOK_PITCH, LOOK_PITCH))


## The gesture under way as (lean, head down, head to the left), eased in and out over its length.
func _gesture_offsets() -> Vector3:
	if _gesture_name.is_empty():
		return Vector3.ZERO
	var u := 1.0 - _gesture_left / _gesture_len
	var e := clampf(minf(u, 1.0 - u) / GESTURE_EDGE, 0.0, 1.0)
	var shake := sin(u * PI * 6.0) * 0.22 * e
	match _gesture_name:
		"nod":
			return Vector3(0.0, maxf(0.0, sin(u * PI * 6.0)) * 0.28 * e, 0.0)
		"shake":
			return Vector3(0.0, 0.0, shake)
		"lookup":
			return Vector3(0.0, -0.26 * e, 0.0)
		"lean":
			return Vector3(0.25 * e, 0.0, 0.0)
		"back":
			return Vector3(-0.24 * e, 0.0, shake)
		"watch":
			return Vector3(0.0, 0.34 * e, 0.3 * e)
		"pen":
			return Vector3(0.0, 0.0, sin(u * PI * 5.0) * 0.14 * (1.0 - u))
	return Vector3.ZERO


func _lod_every() -> int:
	if full_rate:
		return 1
	var camera := get_viewport().get_camera_3d()
	var middle := global_position + Vector3.UP * BODY_HEIGHT * 0.5
	for plane: Plane in camera.get_frustum():
		if plane.distance_to(middle) > BODY_HEIGHT * 0.5:
			return OFF_SCREEN
	var px := BODY_HEIGHT * get_viewport().get_visible_rect().size.y / camera.size
	if phase == Phase.LYING or (phase == Phase.SEATED and _slide == _hand_act().get("slide", 0.0)):
		px = minf(px, LOD[-1][0])
	for tier: Array in LOD:
		if px >= tier[0]:
			return tier[1]
	return LOD[-1][1]


func _start_walk() -> void:
	_goal = spot
	_hold = 0.0
	_agent.target_position = _tail(spot)[0]
	_stall = 0.0
	_stall_best = INF
	phase = Phase.WALK
	_playback.travel(&"move")


## The floor walk is over: the spot's last metres, or, when the floor never reached its way in,
## stand here and say so.
func _end_walk() -> void:
	var way: Vector3 = _tail(_goal)[0]
	if Vector2(way.x - position.x, way.z - position.z).length() <= UNREACHED:
		# The last metres start one at a time: the walker holds at their mouth, avoiding, while
		# someone else sets off along them there or, at a door, is on them coming out.
		var door: bool = _goal.pose == "out"
		var reach: float = _goal.pos.distance_to(way) + RADIUS * 2.0
		if _hold < (DOOR_WAIT if door else FOLLOW_WAIT) and _people.any(func(p: OfficePerson) -> bool:
				return p != self and p.visible and p.phase in [Phase.FOLLOW, Phase.TURN] \
					and (p.position.distance_to(way) < FOLLOW_CLEAR \
					or (door and is_same(p._here, _goal) and p.position.distance_to(_goal.pos) < reach))):
			_hold += get_physics_process_delta_time() * k
			_agent.velocity = Vector3.ZERO
			_velocity = Vector3.ZERO
			return
		_last_metres()
		return
	_agent.velocity = Vector3.ZERO
	_velocity = Vector3.ZERO
	_here = {"pos": position, "face": rotation.y, "pose": "stand", "chain": PackedVector3Array()}
	spot = _here
	phase = Phase.STILL
	_playback.travel(&"stand")


## Straight to the way in, then along the spot's own last metres.
func _last_metres() -> void:
	_agent.velocity = Vector3.ZERO
	_velocity = Vector3.ZERO
	_hold = 0.0
	_follow = PackedVector3Array(_tail(_goal))
	_follow.append(_goal.pos if _goal.pose in ["stand", "out"] else _approach(_goal))
	# Pushed past the way in (a crowd at a door), a walker goes on from where it is, not back.
	while _follow.size() > 1 and position.distance_to(_follow[1]) < _follow[0].distance_to(_follow[1]):
		_follow.remove_at(0)
	_after_follow = Phase.TURN
	phase = Phase.FOLLOW


func _begin_turn() -> void:
	_here = _goal
	if not is_same(spot, _here):
		_leave()
		return
	# Out through a door there is nothing to face, and the next one waits on this one.
	if _here.pose == "out":
		_settle()
		return
	_turn_from = rotation.y
	_turn_to = _here.face
	_t = 0.0
	phase = Phase.TURN


## Faced the spot: sit, lie, act, or vanish through an exit; or, sent elsewhere meanwhile, leave.
func _settle() -> void:
	if not is_same(spot, _here):
		_leave()
		return
	_t = 0.0
	_from = position
	_set_act(act)
	match spot.pose:
		"sit", "lie":
			_to = _seat(spot)
			_playback.travel(&"sit_down")
			phase = Phase.SIT_DOWN
		"out":
			visible = false
			phase = Phase.STILL
		_:
			_playback.travel(&"stand")
			phase = Phase.STILL


## Seated or lying at `_here`; sent elsewhere meanwhile, gets straight up again.
func _down(now: Phase) -> void:
	phase = now
	if is_same(spot, _here):
		_set_act(act)
	else:
		_leave()


## Out of `_here` towards `spot`: up from a seat or bed to where it was entered from, then back
## along the way in to the floor.
func _leave() -> void:
	_t = 0.0
	_from = position
	_out = PackedVector3Array(_tail(_here).slice(1))
	_out.reverse()
	_out.append(_tail(_here)[0])
	match phase:
		Phase.SEATED:
			_exit = _approach(_here)
			_playback.travel(&"stand_up")
			phase = Phase.STAND_UP
		Phase.LYING:
			phase = Phase.GET_UP
		_:
			_walk_out()


func _walk_out() -> void:
	_hold = 0.0
	_playback.travel(&"move")
	_follow = _out
	_after_follow = Phase.WALK
	phase = Phase.FOLLOW


## Straight steps along `_follow` (a link, a walk out or a spot's last metres), facing the way.
## Off a link or a walk out, a fresh path from where it ends.
func _step_follow(dt: float) -> void:
	if _follow.is_empty():
		_leave_lane()
		if _after_follow == Phase.TURN:
			_begin_turn()
		else:
			_start_walk()
		return
	var d := _follow[0] - position
	# Held by someone ahead for at most FOLLOW_WAIT a stretch, so a knot always comes undone; into
	# a door the one ahead goes through it, so the wait there is longer.
	var wait := DOOR_WAIT if _after_follow == Phase.TURN and _goal.pose == "out" else FOLLOW_WAIT
	# The tick's walk, past as many points as it reaches.
	var step := WALK_SPEED * dt * _accel
	if not _lane.is_valid() and _hold < wait and _blocked(d, step):
		_hold += dt
		_accel = 0.0
		_velocity = Vector3.ZERO
		return
	while d.length() <= step:
		position = _follow[0]
		step -= d.length()
		_follow.remove_at(0)
		_hold = 0.0
		if _follow.is_empty():
			return
		d = _follow[0] - position
	_velocity = d.normalized() * WALK_SPEED * k * _accel
	position += d.normalized() * step
	var flat := Vector2(d.x, d.z)
	if flat.length() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(d.x, d.z), minf(1.0, dt * TURN_RATE))


## Someone on their feet within FOLLOW_CLEAR and the tick's `step` ahead along `d` (inside 60
## degrees of it); head on, one walking out of a spot goes before one walking in, and of two walking
## into the same spot the nearer goes first.
func _blocked(d: Vector3, step: float) -> bool:
	var ahead := Vector3(d.x, 0.0, d.z).normalized()
	for p: OfficePerson in _people:
		if p == self or not p.visible or p.phase in DOWN:
			continue
		var gap := p.position - position
		gap.y = 0.0
		if gap.length() < FOLLOW_CLEAR + step and gap.dot(ahead) > gap.length() * 0.5:
			if p.phase == Phase.FOLLOW and p._after_follow == Phase.TURN and _after_follow == Phase.WALK:
				continue
			if p.phase == Phase.FOLLOW and is_same(p._goal, _goal) \
					and p.position.distance_to(_goal.pos) > position.distance_to(_goal.pos):
				continue
			return true
	return false


func _on_safe_velocity(v: Vector3) -> void:
	# The avoidance answers a tick late: a velocity asked for before a pause or a slow down arrives
	# after it, and is held to the speed now.
	if phase not in [Phase.WALK, Phase.WAIT_LINK] or k == 0.0:
		return
	_velocity = v.limit_length(WALK_SPEED * k)
	_stride(_velocity * get_physics_process_delta_time())


## A step `by` across the floor, turning the way it goes.
func _stride(by: Vector3) -> void:
	var dt := get_physics_process_delta_time()
	position += by
	# Kept on the floor: up and down its ramps and steps, and back from a wall avoidance pushed
	# it into, by at most half the step.
	var ground := NavigationServer3D.map_get_closest_point(_agent.get_navigation_map(), position + Vector3.UP * NAV_LIFT) - Vector3.UP * NAV_LIFT
	var off := Vector3(ground.x - position.x, 0.0, ground.z - position.z)
	# A link's mouth may lie a little off the floor: near the next point of the way, no pull.
	if position.distance_to(_agent.get_next_path_position()) > 1.0:
		position += off.limit_length(by.length() * 0.5)
	position.y = move_toward(position.y, ground.y, maxf(FLOOR_EASE, by.length() * 0.5))
	if by.length() > 0.05 * dt:
		rotation.y = lerp_angle(rotation.y, atan2(by.x, by.z), minf(1.0, dt * k * TURN_RATE))


func _on_link_reached(details: Dictionary) -> void:
	# Packed arrays are shared: the walk eats its own copy.
	var path: PackedVector3Array = (_links[details.rid].path as PackedVector3Array).duplicate()
	if details.link_entry_position.distance_to(path[0]) > details.link_entry_position.distance_to(path[-1]):
		path.reverse()
	_lane = details.rid
	_velocity = Vector3.ZERO
	_link_path = path
	if _can_enter(_lane, path[0]):
		_follow = path
		_enter_lane()
		return
	var l: Dictionary = _lanes[_lane]
	if (l.entry as Vector3).distance_to(path[0]) < 0.5:
		# Behind someone going the same way: wait on the spot for the gap.
		_wait_at = position
	else:
		# Against the lane: out of the mouth, in a queue, and no one else goes in the other way.
		l.held = true
		var line: Array = _waiting.get_or_add(_lane, [])
		line.append(self)
		var back := Vector3(path[1].x - path[0].x, 0.0, path[1].z - path[0].z).normalized()
		_wait_at = path[0] - back * (LANE_BACK + (line.size() - 1) * RADIUS * 2.0)
		_wait_at.y = position.y
	phase = Phase.WAIT_LINK


static func _can_enter(lane: RID, entry: Vector3) -> bool:
	if not _lanes.has(lane):
		return true
	var l: Dictionary = _lanes[lane]
	if (l.entry as Vector3).distance_to(entry) >= 0.5 or l.held:
		return false
	var last: OfficePerson = l.people[-1]
	return (last.global_position - entry).dot(l.dir) >= LANE_GAP


func _enter_lane() -> void:
	if not _lanes.has(_lane):
		var dir := _link_path[1] - _link_path[0]
		_lanes[_lane] = {"entry": _link_path[0], "dir": Vector3(dir.x, 0.0, dir.z).normalized(), "people": [], "held": false}
	_lanes[_lane].people.append(self)
	_after_follow = Phase.WALK
	phase = Phase.FOLLOW


func _leave_lane() -> void:
	if _lanes.has(_lane):
		_lanes[_lane].people.erase(self)
		if _lanes[_lane].people.is_empty():
			_lanes.erase(_lane)
	_lane = RID()


func _stop_waiting() -> void:
	if _waiting.has(_lane):
		_waiting[_lane].erase(self)
		if _waiting[_lane].is_empty():
			_waiting.erase(_lane)


## Where a spot is walked to on the floor, then the design's points from there to the spot's
## way in; [way in] when the way in is on the floor. OfficePeople marks off-floor points.
func _tail(to: Dictionary) -> Array:
	return to.get("tail", [way_in(to)])


## Where a spot is entered from: the first point of its chain (the design's way to it), else the
## spot itself.
static func way_in(at: Dictionary) -> Vector3:
	var chain: PackedVector3Array = at.chain
	return chain[0] if not chain.is_empty() else at.pos


## `region`'s floor is built into its navigation map, with a way from `from` to `to` (points on the
## drawn floor): a region joins the map before its floor does.
static func floor_ready(region: NavigationRegion3D, from: Vector3, to: Vector3) -> bool:
	var map := region.get_navigation_map()
	if not NavigationServer3D.map_get_regions(map).has(region.get_rid()):
		return false
	var lift := Vector3.UP * NAV_LIFT
	return not NavigationServer3D.map_get_path(map, from + lift, to + lift, true).is_empty()


## The drawn floor under the baked floor's point nearest `at`, when that lies within `reach` of it
## across and FLOOR_RISE up or down; else Vector3.INF.
static func floor_near(map: RID, at: Vector3, reach: float) -> Vector3:
	var lift := Vector3.UP * NAV_LIFT
	var near := NavigationServer3D.map_get_closest_point(map, at + lift) - lift
	if Vector2(near.x - at.x, near.z - at.z).length() <= reach and absf(near.y - at.y) < FLOOR_RISE:
		return near
	return Vector3.INF


## Between sat on a bed's end and lying along it. The body lies back before sliding up, and slides
## down before sitting up (`slide` eased), so the legs clear the end; the root rises or sinks with
## the pose's blend (`pose`), which keeps the hips on the mattress.
func _on_bed(to: Vector3, slide: float, pose: float) -> void:
	position = _from.lerp(to, slide)
	position.y = lerpf(_from.y, to.y, pose)


## The root lying in a bed.
func _bed(at: Dictionary) -> Vector3:
	var ahead := Vector3(sin(at.face), 0.0, cos(at.face))
	return at.pos - ahead * BED_HEAD + Vector3(ahead.z, 0.0, -ahead.x) * BED_SIDE + Vector3.DOWN * BED_SINK


## The root sat on a chair, or on a bed's end.
func _seat(at: Dictionary) -> Vector3:
	var ahead := Vector3(sin(at.face), 0.0, cos(at.face))
	if at.pose == "lie":
		return at.pos + ahead * BED_END + Vector3.DOWN * BED_SIT_DROP
	return at.pos + ahead * SEAT_FORWARD


## Where a seat or bed is entered from: behind it, towards its way in.
func _approach(at: Dictionary) -> Vector3:
	var way := way_in(at)
	var back: Vector3 = way - at.pos
	back.y = 0.0
	return Vector3(at.pos.x, way.y, at.pos.z) + back.normalized() * SEAT_BACK if back.length() > SEAT_BACK else way


func _set_act(what: String) -> void:
	if spot.get("pose", "") == "sit":
		_tree.set("parameters/seated/act/transition_request", what if SEAT_ACTS.has(what) else "idle")
	else:
		_tree.set("parameters/stand/act/transition_request", what if STAND_ACTS.has(what) else "idle")


static func _libraries() -> Dictionary:
	if _libs.is_empty():
		for key: String in LIBS:
			_libs[key] = load(LIBS[key])
		for clip: String in LOOPED:
			var parts := clip.split("/")
			(_libs[parts[0]] as AnimationLibrary).get_animation(parts[1]).loop_mode = Animation.LOOP_LINEAR
		_sit_s = (_libs.ual1 as AnimationLibrary).get_animation("Sitting_Enter").length
		_stand_s = (_libs.ual1 as AnimationLibrary).get_animation("Sitting_Exit").length
	return _libs


## The shared graph: move (gait → 8-way walk space → pace), sit down → seated → stand up,
## stand (acts), seated ⇄ sleep (a bed); each looped state out through its own pace. One-shots hand
## on at their end.
static func _state_machine() -> AnimationNodeStateMachine:
	if _tree_root:
		return _tree_root
	var sm := AnimationNodeStateMachine.new()
	var move := AnimationNodeBlendTree.new()
	var gait := AnimationNodeTransition.new()
	gait.xfade_time = XFADE
	move.add_node(&"gait", gait)
	for g in GAITS.size():
		gait.add_input("g%d" % g)
		var space := AnimationNodeBlendSpace2D.new()
		space.add_blend_point(_clip(STAND_ACTS.idle), Vector2.ZERO)
		space.add_blend_point(_clip(GAITS[g]), Vector2(0, 1))
		space.add_blend_point(_clip("m2m/Walk_Backwards"), Vector2(0, -1))
		space.add_blend_point(_clip("m2m/Strafe_left"), Vector2(1, 0))
		space.add_blend_point(_clip("m2m/Strafe_right"), Vector2(-1, 0))
		move.add_node(StringName("walk_%d" % g), space)
		move.connect_node(&"gait", g, StringName("walk_%d" % g))
	sm.add_node(&"move", _paced(move, &"gait"))
	sm.add_node(&"stand", _acts(STAND_ACTS))
	sm.add_node(&"seated", _acts(SEAT_ACTS))
	var sleep := AnimationNodeBlendTree.new()
	sleep.add_node(&"clip", _clip("m2m/Sleeping"))
	sm.add_node(&"sleep", _paced(sleep, &"clip"))
	for s: Array in [["sit_down", "ual1/Sitting_Enter"], ["stand_up", "ual1/Sitting_Exit"]]:
		sm.add_node(StringName(s[0]), _clip(s[1]))
	for t: Array in [["move", "stand", false], ["stand", "move", false], ["move", "sit_down", false],
			["sit_down", "seated", true], ["seated", "stand_up", false], ["stand_up", "move", true],
			["seated", "sleep", false], ["sleep", "seated", false]]:
		var hop := AnimationNodeStateMachineTransition.new()
		hop.xfade_time = LIE_XFADE if "sleep" in t else XFADE
		if t[2]:
			hop.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
			hop.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
		sm.add_transition(StringName(t[0]), StringName(t[1]), hop)
	_tree_root = sm
	return sm


static func _acts(acts: Dictionary) -> AnimationNodeBlendTree:
	var tree := AnimationNodeBlendTree.new()
	var pick := AnimationNodeTransition.new()
	pick.xfade_time = XFADE
	tree.add_node(&"act", pick)
	var i := 0
	for name: String in acts:
		pick.add_input(name)
		tree.add_node(StringName(name), _clip(acts[name]))
		tree.connect_node(&"act", i, StringName(name))
		i += 1
	return _paced(tree, &"act")


## `tree` out through `node` and a TimeScale, `pace`: a looped state's own speed (LOOP_PACES; the
## walk's follows its stride).
static func _paced(tree: AnimationNodeBlendTree, node: StringName) -> AnimationNodeBlendTree:
	tree.add_node(&"pace", AnimationNodeTimeScale.new())
	tree.connect_node(&"pace", 0, node)
	tree.connect_node(&"output", 0, &"pace")
	return tree


static func _clip(name: String) -> AnimationNodeAnimation:
	var node := AnimationNodeAnimation.new()
	node.animation = StringName(name)
	return node


## The prop `prop_name`'s node (PROPS), made the first time it is wanted: on its hand bone or in
## the body's frame.
func prop(prop_name: String) -> Node3D:
	if not _props.has(prop_name):
		var spec: Dictionary = PROPS[prop_name]
		var mi := MeshInstance3D.new()
		mi.mesh = OfficeBody.block(spec.size, Color(spec.color))
		mi.material_override = OfficeBody.material
		mi.position = spec.at
		mi.rotation.x = spec.get("tilt", 0.0)
		if spec.has("bone"):
			var holder := BoneAttachment3D.new()
			_skel.add_child(holder)
			holder.bone_name = spec.bone
			holder.add_child(mi)
		else:
			_body.add_child(mi)
		_props[prop_name] = mi
	return _props[prop_name]
