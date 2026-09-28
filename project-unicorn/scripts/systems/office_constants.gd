class_name OfficeConstants
extends RefCounted

# The office ladder's catalog and the rhythm of the people in it. No figure is the GDD's: each one,
# the office design's or the people's rhythm, is a [WORKING] value awaiting the owner.
# Rent, deposit and movers are shown on the city map and charged nowhere: tying them to the economy
# is an open owner decision.

## OFFICE_MAP_SUB spells this out as "a week": a change here changes that row too.
const MOVE_WEEKS := 1                       # [WORKING] weeks from move_to to arrival

## Where the founder's trip to an outside meeting drives on the city map, per office: a
## building across the road, its box from the design's (ground corner, then width, height and
## depth). [WORKING]
const MEETING_TARGET := {
	"home": AABB(Vector3(-83.0, 0.0, -12.0), Vector3(15.5, 12.8, 15.0)),
	"ishani": AABB(Vector3(-70.0, 0.0, 13.0), Vector3(13.0, 16.0, 13.0)),
	"plaza": AABB(Vector3(22.0, 0.0, -38.0), Vector3(16.0, 16.0, 16.0)),
	"loft": AABB(Vector3(40.0, 0.0, -40.0), Vector3(14.0, 12.8, 18.0)),
}

## id -> {tier_key, name_key, desc_key, desks, rent, deposit, move_cost, room_keys, reqs}.
## A req is {kind, value}: angel (Frank's cheque taken, value true), or team (headcount), cash
## and brand, each met at >= value.
const CATALOG := {
	"home": {
		"tier_key": "OFFICE_TIER_HOME",
		"name_key": "OFFICE_NAME_HOME",
		"desc_key": "OFFICE_DESC_HOME",
		"desks": 1,                         # [WORKING]
		"rent": 0,                          # [WORKING]
		"deposit": 0,                       # [WORKING]
		"move_cost": 0,                     # [WORKING]
		"room_keys": ["OFFICE_ROOM_STUDY_CORNER", "OFFICE_ROOM_KITCHEN_CORNER",
			"OFFICE_ROOM_BEDROOM", "OFFICE_ROOM_BATHROOM", "OFFICE_ROOM_BALCONY"],
		"reqs": [],
	},
	"ishani": {
		"tier_key": "OFFICE_TIER_ISHANI",
		"name_key": "OFFICE_NAME_ISHANI",
		"desc_key": "OFFICE_DESC_ISHANI",
		"desks": 10,                        # [WORKING]
		"rent": 2_500,                      # [WORKING]
		"deposit": 5_000,                   # [WORKING]
		"move_cost": 1_500,                 # [WORKING]
		"room_keys": ["OFFICE_ROOM_OPEN_OFFICE", "OFFICE_ROOM_MEETING_ROOM",
			"OFFICE_ROOM_FOUNDER_GLASS", "OFFICE_ROOM_KITCHEN", "OFFICE_ROOM_RESTROOM"],
		"reqs": [
			{"kind": "angel", "value": true},
			{"kind": "cash", "value": 6_500},       # [WORKING]
		],
	},
	"plaza": {
		"tier_key": "OFFICE_TIER_PLAZA",
		"name_key": "OFFICE_NAME_PLAZA",
		"desc_key": "OFFICE_DESC_PLAZA",
		"desks": 36,                        # [WORKING]
		"rent": 18_000,                     # [WORKING]
		"deposit": 36_000,                  # [WORKING]
		"move_cost": 9_000,                 # [WORKING]
		"room_keys": ["OFFICE_ROOM_RECEPTION", "OFFICE_ROOM_MEETING_ROOMS_2",
			"OFFICE_ROOM_BOARD_ROOM", "OFFICE_ROOM_DEPARTMENT_PODS",
			"OFFICE_ROOM_PHONE_BOOTHS", "OFFICE_ROOM_CAFE_GAMES"],
		"reqs": [
			{"kind": "team", "value": 12},          # [WORKING]
			{"kind": "cash", "value": 45_000},      # [WORKING]
			{"kind": "brand", "value": 40},         # [WORKING]
		],
	},
	"loft": {
		"tier_key": "OFFICE_TIER_LOFT",
		"name_key": "OFFICE_NAME_LOFT",
		"desc_key": "OFFICE_DESC_LOFT",
		"desks": 64,                        # [WORKING]
		"rent": 45_000,                     # [WORKING]
		"deposit": 90_000,                  # [WORKING]
		"move_cost": 20_000,                # [WORKING]
		"room_keys": ["OFFICE_ROOM_RECEPTION_SECURITY", "OFFICE_ROOM_STAGE",
			"OFFICE_ROOM_MEETING_ROOMS_3", "OFFICE_ROOM_PHONE_BOOTHS", "OFFICE_ROOM_GAMES",
			"OFFICE_ROOM_VP_OFFICES", "OFFICE_ROOM_EXECUTIVE", "OFFICE_ROOM_FOUNDER_OFFICE"],
		"reqs": [
			{"kind": "team", "value": 35},          # [WORKING]
			{"kind": "cash", "value": 110_000},     # [WORKING]
			{"kind": "brand", "value": 70},         # [WORKING]
		],
	},
}

## The office people's day: arrivals and departures run on the game clock, the rest on ambient
## seconds (real seconds times k, the visual speed). [WORKING], each awaiting the owner.
const VISUAL_CAP := 2.0                     # people move at most this many times their 1× pace
const ARRIVE_JITTER := Vector2(0.0, 60.0)   # game minutes after the start someone is due in
const LATE_SHARE := 0.1                     # this share of days someone is late, by LATE_EXTRA more
const LATE_EXTRA := Vector2(30.0, 75.0)
const LEAVE_JITTER := Vector2(0.0, 45.0)    # game minutes before the end someone is gone
const ARRIVE_LATE_OK := 90.0                # a walk in that would land later than this past due is
                                            # cut in at the morning opening instead
const EXIT_SLACK := 1.5                     # the walk out starts this many times its length early:
                                            # the door takes one at a time
const MIN_PRESENCE := 0.5                   # a share of their hours; in for less, they stay seated
                                            # for the night's cut instead of walking out
const DOOR_CLEAR := 0.9                     # metres the last one in is from the door before the next
const DOOR_S := 0.5                         # ambient seconds between two people out through the door
const NIGHT_WAIT_S := 3.5                   # real seconds the night waits for the office to empty
const FIRST_BREAK := Vector2(10.0, 30.0)    # ambient seconds at the desk before the first break
const TRIP_EVERY := Vector2(25.0, 60.0)     # and between breaks
const POSTPONE := Vector2(15.0, 30.0)       # a break put off by a full line comes back this much later
## How often each break is drawn, staff and founder (a founder's visit is the round of the desks);
## booths are the sales reps'.
const BREAK_WEIGHTS := {"coffee": Vector2i(3, 2), "wc": Vector2i(2, 1), "visit": Vector2i(1, 4),
	"booth": Vector2i(2, 0)}
## Ambient seconds at a break, by kind.
const STAYS := {"coffee": Vector2(6.0, 10.0), "wc": Vector2(5.0, 8.0), "booth": Vector2(10.0, 16.0),
	"visit": Vector2(5.0, 8.0), "eat": Vector2(15.0, 25.0)}
const LUNCH_WINDOW := Vector2(720.0, 810.0) # game minutes (12:00 to 13:30): lunch is taken once
const DESK_IDLE_EVERY := Vector2(12.0, 30.0)  # ambient seconds of work between small idles
const DESK_IDLE_S := Vector2(4.0, 8.0)
const MEETING_EVERY := Vector2(40.0, 80.0)  # ambient seconds between team meetings, per room
const MEETING_LEN := Vector2(20.0, 30.0)
const MEETING_ACT_S := 5.0                  # a seat at the table changes what it does this often
const MEETING_FOUNDER := 0.3                # the chance the founder sits in on a team meeting
const ALL_HANDS_MINUTE := 1020.0            # the loft's all-hands, once a week at 17:00 game time
const ALL_HANDS_S := 20.0
# The floor rings under the office people, the founder's and the selected person's: 3D scene
# colours with the design's opacity in alpha, not UI theme tokens.
const FOUNDER_RING := Color("#f0b429e6")
const SELECT_RING := Color("#fffffff2")
