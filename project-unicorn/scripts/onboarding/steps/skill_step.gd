extends OnboardingStep

# Step 2 — Skill Allocation per PROJECT_SPEC §4.3.
# Self-Made's 6-point pool, max 3 per axis. Plus/minus buttons enforce the
# per-axis cap and the running total; the player cannot reach an invalid
# state through the UI.
#
# TODO: drag-drop interaction per PROJECT_SPEC §4.3 — content phase upgrade.

const TOTAL_POOL := 6
const AXIS_CAP := 3

const AXES := ["tech", "markets", "charisma", "politics"]
const AXIS_LABELS := {
	"tech": "Tech",
	"markets": "Markets",
	"charisma": "Charisma",
	"politics": "Politics",
}
const AXIS_TOOLTIPS := {
	"tech": "ürün build kalitesi, R&D hızı",
	"markets": "prospect quality, deal close oranı",
	"charisma": "pitch, scandal recovery, brand check",
	"politics": "VC negotiation, network leverage, media management",
}

var _alloc: Dictionary = {"tech": 0, "markets": 0, "charisma": 0, "politics": 0}

@onready var rows: Dictionary = {
	"tech": $List/TechRow,
	"markets": $List/MarketsRow,
	"charisma": $List/CharismaRow,
	"politics": $List/PoliticsRow,
}
@onready var counter_label: Label = $Header/CounterLabel


func _ready() -> void:
	for axis in AXES:
		var row: Control = rows[axis]
		var minus: Button = row.get_node("Minus")
		var plus: Button = row.get_node("Plus")
		minus.pressed.connect(_on_minus_pressed.bind(axis))
		plus.pressed.connect(_on_plus_pressed.bind(axis))
	_refresh_all()


# --- Mutations ---

func _on_plus_pressed(axis: String) -> void:
	if _total_used() >= TOTAL_POOL:
		return
	if int(_alloc[axis]) >= AXIS_CAP:
		return
	_alloc[axis] = int(_alloc[axis]) + 1
	_refresh_all()
	validity_changed.emit(is_valid())


func _on_minus_pressed(axis: String) -> void:
	if int(_alloc[axis]) <= 0:
		return
	_alloc[axis] = int(_alloc[axis]) - 1
	_refresh_all()
	validity_changed.emit(is_valid())


# --- View ---

func _refresh_all() -> void:
	for axis in AXES:
		var row: Control = rows[axis]
		var value_label: Label = row.get_node("Value")
		var minus: Button = row.get_node("Minus")
		var plus: Button = row.get_node("Plus")
		value_label.text = str(_alloc[axis])
		minus.disabled = int(_alloc[axis]) <= 0
		plus.disabled = int(_alloc[axis]) >= AXIS_CAP or _total_used() >= TOTAL_POOL
	var remaining: int = TOTAL_POOL - _total_used()
	counter_label.text = "Kalan: %d / %d" % [remaining, TOTAL_POOL]


func _total_used() -> int:
	var sum: int = 0
	for axis in AXES:
		sum += int(_alloc[axis])
	return sum


# --- OnboardingStep contract ---

func prefill(draft: Dictionary) -> void:
	var stored: Dictionary = draft.get("skill_alloc", {})
	for axis in AXES:
		_alloc[axis] = int(stored.get(axis, 0))
	if is_node_ready():
		_refresh_all()
		validity_changed.emit(is_valid())


func is_valid() -> bool:
	return _total_used() == TOTAL_POOL


func collect_payload() -> Dictionary:
	return {"skill_alloc": _alloc.duplicate()}
