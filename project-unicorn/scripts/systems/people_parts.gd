class_name PeopleParts
extends RefCounted

# The office people's wardrobe: which Quaternius part (assets/art/people/q22) can be a head, top,
# bottom or shoes, what each of its surfaces is, which roles wear which pieces, and the colours a
# person is drawn in. A part is "<file>/<kind>", kind one of Head, Body, Legs, Feet. Surface names
# come from the source files and mean different things in different files, so every part lists its
# own. The colours are 3D scene colours (sRGB), not UI tokens: an office's quiet palette, so no one
# stands out but the founder.

const KINDS := ["Head", "Body", "Legs", "Feet"]

## part -> {surface name: role}. Roles: skin, skin_shade, hair, hair_shade, brow, eye, beard,
## top, top_shade, top2, tie, belt, bottom, bottom_shade, shoe, shoe_shade, sole; "drop" leaves the
## surface out (hats, crowns, earrings, headsets).
const SURFACES := {
	"m_suit/Head": {"Skin": "skin", "Hair": "hair", "Eyebrows": "brow", "Eye": "eye"},
	"m_casual/Head": {"Skin": "skin", "Skin_Darker": "skin_shade", "Hair": "hair", "Eyebrows": "brow", "Eye": "eye"},
	"m_hoodie/Head": {"Skin": "skin", "Hair": "hair", "Eyebrows": "brow", "Eye": "eye"},
	"m_beach/Head": {"Skin": "skin", "Hair": "hair", "Eyebrows": "brow", "Eye": "eye", "Earrings": "drop"},
	"m_adventurer/Head": {"Skin": "skin", "Hair": "hair", "Eyebrows": "brow", "Eye": "eye"},
	"m_king/Head": {"Skin": "skin", "Hair_White": "hair", "Eye": "eye", "Gold": "drop"},
	"m_worker/Head": {"Skin": "skin", "Moustache": "beard", "Eyebrows": "brow", "Eye": "eye", "Worker_Yellow": "drop"},
	"w_suit/Head": {"Skin": "skin", "Hair_Blond": "hair", "Hair_Brown": "hair_shade", "Brown": "eye"},
	"w_formal/Head": {"Skin": "skin", "Red": "hair", "Brown": "eye"},
	"w_adventurer/Head": {"Skin": "skin", "Hair_Brown": "hair", "Brown": "eye"},
	"w_soldier/Head": {"Skin": "skin", "Hair_Brown": "hair", "Brown": "eye"},
	"w_worker/Head": {"Skin": "skin", "DarkBrown": "hair", "Brown": "eye", "Worker_Yellow": "drop"},
	"m_farmer/Head": {"Skin": "skin", "Eyebrows": "hair", "Eye": "eye", "Beige": "drop", "Red": "drop"},
	"w_scifi/Head": {"Skin": "skin", "Hair_Black": "hair", "Blue": "drop", "Black": "drop", "Brown": "eye"},
	"w_witch/Head": {"Skin": "skin", "Hair_Black": "hair", "Brown": "eye", "Purple": "drop", "Gold": "drop"},

	"m_suit/Body": {"Suit": "top", "White": "top2", "Tie": "tie", "Skin": "skin"},
	"m_casual/Body": {"LightBrown": "top", "Skin": "skin"},
	"m_hoodie/Body": {"Purple": "top", "Skin": "skin"},
	"m_punk/Body": {"Black": "top2", "White": "top", "Skin": "skin"},
	"w_suit/Body": {"Black": "top", "White": "top2", "Skin": "skin"},
	"w_casual/Body": {"White": "top", "Skin": "skin"},
	"w_formal/Body": {"LimeGreen": "top", "Gold": "belt", "Skin": "skin"},
	"w_soldier/Body": {"Black": "top", "Swat": "top2", "Skin": "skin"},
	"m_adventurer/Body": {"Green": "top_shade", "LightGreen": "top", "Skin": "skin"},
	"m_farmer/Body": {"Beige": "top", "LightBlue": "bottom", "Brown": "skin", "Skin": "skin"},

	"m_suit/Legs": {"Suit": "bottom"},
	"m_casual/Legs": {"LightBlue": "bottom"},
	"m_worker/Legs": {"Brown": "bottom", "Brown2": "belt"},
	"w_suit/Legs": {"Black": "bottom"},
	"w_casual/Legs": {"Orange": "bottom"},
	"w_formal/Legs": {"LimeGreen": "bottom", "Skin": "skin"},
	"w_soldier/Legs": {"Swat": "bottom", "Black": "bottom_shade", "Grey": "bottom_shade"},
	"m_adventurer/Legs": {"Brown": "bottom", "Brown2": "bottom_shade"},
	"m_farmer/Legs": {"LightBlue": "bottom"},
	"m_punk/Legs": {"LightBlue": "bottom", "Skin": "skin"},
	"w_punk/Legs": {"Black": "bottom", "Skin": "skin"},
	"w_worker/Legs": {"Brown2": "bottom", "Brown_02": "bottom_shade"},

	"m_suit/Feet": {"Black": "shoe"},
	"m_casual/Feet": {"Red_Dark": "shoe", "White": "sole"},
	"m_hoodie/Feet": {"Purple": "shoe", "White": "sole"},
	"m_worker/Feet": {"Grey": "shoe", "Black": "sole"},
	"w_suit/Feet": {"Black": "shoe", "Skin": "skin"},
	"w_casual/Feet": {"Grey": "shoe", "Skin": "skin"},
	"w_formal/Feet": {"Red": "shoe", "Skin": "skin"},
	"w_soldier/Feet": {"Grey": "shoe", "Black": "sole"},
	"m_adventurer/Feet": {"Black": "shoe", "Grey": "shoe_shade"},
	"m_farmer/Feet": {"Brown": "shoe", "Brown2": "shoe_shade"},
	"m_punk/Feet": {"Black": "shoe", "Skin": "skin"},
	"w_punk/Feet": {"Black": "shoe", "Grey": "shoe_shade"},
	"w_worker/Feet": {"Black": "shoe", "Skin": "skin"},
}

## The palette each colour slot of a top takes, by top part; "tee" unless listed. The shirt under
## the dungarees is dark, or a pale one reads as bare arms.
const TOP_PALETTES := {
	"m_suit": {"top": "jacket", "top2": "shirt"},
	"w_suit": {"top": "jacket", "top2": "shirt"},
	"m_punk": {"top2": "jacket"},
	"w_soldier": {"top2": "jacket"},
	"m_farmer": {"top": "jacket"},
}
## Dress parts: the legs of a dress wear the top's colour.
const DRESSES := {"w_formal": true}
## Suits: trousers take the jacket's colour this often.
const SUIT_MATCH := 0.7

## How low each trouser part reaches and how high each shoe part rises, metres (from the meshes).
## A shoe must rise to the hem, or the ankle shows as a gap: tucked trousers need boots.
const HEM := {
	"m_suit": 0.141, "m_casual": 0.132, "m_worker": 0.137, "m_adventurer": 0.137, "m_farmer": 0.124, "m_punk": 0.122,
	"w_suit": 0.148, "w_casual": 0.146, "w_formal": 0.179, "w_worker": 0.146, "w_soldier": 0.333, "w_punk": 0.372,
}
const SHOE_TOP := {
	"m_suit": 0.169, "m_casual": 0.244, "m_hoodie": 0.134, "m_worker": 0.273, "m_adventurer": 0.22, "m_farmer": 0.212,
	"m_punk": 0.201, "w_suit": 0.192, "w_casual": 0.184, "w_formal": 0.182, "w_worker": 0.197, "w_soldier": 0.429,
	"w_punk": 0.429,
}

## Style -> sex -> kind -> parts. Heads are anyone's.
const STYLES := {
	"casual": {
		"m": {"Body": ["m_casual", "m_hoodie", "m_punk", "m_adventurer", "m_farmer"],
			"Legs": ["m_casual", "m_worker", "m_adventurer", "m_farmer", "m_punk"],
			"Feet": ["m_casual", "m_hoodie", "m_worker", "m_adventurer", "m_farmer", "m_punk"]},
		"w": {"Body": ["w_casual", "w_soldier"], "Legs": ["w_casual", "w_soldier", "w_punk", "w_worker"],
			"Feet": ["w_casual", "w_soldier", "w_punk", "w_worker"]},
	},
	"smart": {
		"m": {"Body": ["m_casual", "m_hoodie", "m_adventurer"], "Legs": ["m_suit", "m_casual"], "Feet": ["m_suit", "m_casual"]},
		"w": {"Body": ["w_suit", "w_casual", "w_formal"], "Legs": ["w_suit", "w_casual"], "Feet": ["w_suit", "w_casual"]},
	},
	"jacket": {
		"m": {"Body": ["m_suit"], "Legs": ["m_suit"], "Feet": ["m_suit"]},
		"w": {"Body": ["w_suit"], "Legs": ["w_suit"], "Feet": ["w_suit", "w_formal"]},
	},
}
## Role -> style: builders dress casually, sales in a jacket, the rest in between. The people
## across a meeting's table (CounterpartSystem) have roles here too.
const ROLE_STYLES := {
	HRConstants.ROLE_DEVELOPER: "casual",
	HRConstants.ROLE_TESTER: "casual",
	HRConstants.ROLE_DESIGNER: "casual",
	HRConstants.ROLE_PRODUCT_MANAGER: "smart",
	HRConstants.ROLE_CUSTOMER_REP: "smart",
	HRConstants.ROLE_SALES_REP: "jacket",
	CounterpartSystem.ROLE_LEAD: "jacket",
	CounterpartSystem.ROLE_PARTNER: "jacket",
	CounterpartSystem.ROLE_ANALYST: "smart",
	CounterpartSystem.ROLE_BUYER: "smart",
	CounterpartSystem.ROLE_USER: "casual",
	CounterpartSystem.ROLE_FINANCE: "jacket",
}
const HEADS := {
	"m": ["m_suit", "m_casual", "m_hoodie", "m_beach", "m_adventurer", "m_king", "m_worker", "m_farmer"],
	"w": ["w_suit", "w_formal", "w_adventurer", "w_soldier", "w_worker", "w_scifi", "w_witch"],
}

const PALETTES := {
	"skin": ["#f3d6bf", "#e2b896", "#c89672", "#a6704d", "#7e4f35", "#5a3826"],
	"hair": ["#1d1a18", "#2f2219", "#4a3322", "#6b4a2f", "#8c6a44", "#c3a06a", "#7d3a22", "#8f8a85"],
	# No tee near a skin tone: from the office camera it reads as bare skin.
	"tee": ["#e9e6df", "#c9c6bf", "#8d9096", "#3a3d42", "#2f3c52", "#4f6a88", "#8aa7c2", "#6f8a6a",
		"#4a5a3a", "#7a3a40", "#c09a52", "#5d4a6e"],
	"shirt": ["#f1efe9", "#cfdbe6", "#e6d6d3", "#d9d4c8", "#a8b3bf", "#26272b"],
	"jacket": ["#262c38", "#2e3035", "#4a4e55", "#1d1e21", "#6a5240", "#34433a", "#5b4f45", "#6f7a6e"],
	"bottom": ["#3d5470", "#28374d", "#1f2024", "#3a3d42", "#9c8c6e", "#262f40", "#676b71", "#4b5140", "#7a6a55"],
	"shoe": ["#ecebe7", "#1d1e21", "#4f3627", "#7d5d42", "#5e6167", "#2a3243"],
	"tie": ["#3a1f28", "#23324a", "#2e2f33", "#4a3a2a", "#3c4a3c"],
}
## How often each hair colour is drawn, in PALETTES.hair order: mostly dark, a few fair, red and grey.
const HAIR_WEIGHTS := [4, 4, 3, 2, 1, 1, 1, 1]
## Fixed tones: eyes, belts, soles and glasses do not vary by person.
const EYE := "#1c1614"
const BELT := "#2a211c"
const SOLE := "#efece4"
const GLASSES := "#1f1d1c"


## A look's trousers wear its top's colour: a matched suit (bottom -1) or a dress.
static func bottom_is_top(look: Dictionary) -> bool:
	return look.bottom < 0 or DRESSES.has(look.legs)


## The palette slot `slot` of a look's top part takes.
static func top_palette(body: String, slot: String) -> String:
	return TOP_PALETTES.get(body, {}).get(slot, "tee")
