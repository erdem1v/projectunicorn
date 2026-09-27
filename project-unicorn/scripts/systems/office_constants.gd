class_name OfficeConstants
extends RefCounted

# The office ladder's catalog. Every figure is the office design's, not the GDD's, so each one
# is a [WORKING] value awaiting the owner. Rent, deposit and movers are shown on the city map and
# charged nowhere: tying them to the economy is an open owner decision.

## OFFICE_MAP_SUB spells this out as "a week": a change here changes that row too.
const MOVE_DAYS := 7                        # [WORKING] calendar days from move_to to arrival

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

# The office people's clothing colours: 3D scene colours, not UI theme tokens.
const ROLE_COLORS := {
	"dev": Color("#4f7fd1"),
	"pm": Color("#5fae6e"),
	"des": Color("#c768a8"),
	"sales": Color("#e58a3a"),
	"qa": Color("#3fb3b0"),
	# [WORKING] The design has no support role; violet sits clear of every hue here, on the
	# cream walls and on the teal carpet.
	"cs": Color("#8a63d2"),
	"founder": Color("#f4c430"),
}

## HRConstants role id -> the design's role key (ROLE_COLORS).
const ROLE_KEYS := {
	HRConstants.ROLE_DEVELOPER: "dev",
	HRConstants.ROLE_PRODUCT_MANAGER: "pm",
	HRConstants.ROLE_DESIGNER: "des",
	HRConstants.ROLE_SALES_REP: "sales",
	HRConstants.ROLE_TESTER: "qa",
	HRConstants.ROLE_CUSTOMER_REP: "cs",
	HRConstants.ROLE_FOUNDER: "founder",
}

# The floor rings under the office people, the founder's and the selected person's: 3D scene
# colours with the design's opacity in alpha, not UI theme tokens.
const FOUNDER_RING := Color("#f0b429e6")
const SELECT_RING := Color("#fffffff2")
