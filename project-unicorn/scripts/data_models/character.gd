class_name Character
extends Resource

# Character data model per TECH_SPEC §7.
# Plain data container, no scene dependency. Stored in CharacterRegistry
# (employees, mentor, NPCs) and operated on by HRSystem and future systems.
#
# Used now (this turn):
#   - Identity: id, character_name, role, category
#   - Compensation: monthly_salary, equity_pct (feeds Finance via pull)
#   - Morale: morale (HRSystem applies baseline drift; range 0..100 clamped in
#     CharacterRegistry.set_morale)
#
# Reserved (declared with defaults so future systems plug in without
# retrofitting the model and so the save schema is forward-compatible):
#   - loyalty, relationship, trust_score, traits, role_stats, attention_flag
#
# Naming caution (TECH_SPEC §7): Node reserves `name`, so character names use
# the distinct field `character_name`. Watch for similar collisions in any
# future fields.

# --- Identity (used now) ---
@export var id: String = ""               # "char_<slug>" per TECH_SPEC §12 prefix
@export var character_name: String = ""   # NOT `name` — Node reserves it (TECH_SPEC §7)
@export var role: String = ""
@export var category: String = "employee" # "founder" | "employee" | "mentor" | "npc"

# --- Compensation (used now — feeds Finance via CharacterRegistry pull) ---
@export var monthly_salary: int = 0
@export var equity_pct: float = 0.0

# --- Morale (used now — HRSystem moves it; range 0..100) ---
@export var morale: int = 50

# --- Reserved for future systems (declared, not used this turn) ---
@export var loyalty: int = 50                # event-driven; future
@export var relationship: String = "neutral" # ally | friendly | neutral | wary | hostile
@export var trust_score: int = 0             # -100..100
@export var traits: Array[String] = []       # visible + hidden trait ids
@export var role_stats: Dictionary = {}      # e.g. {"tech": 60, "leadership": 30}
@export var attention_flag: String = ""      # FLIGHT_RISK | BURNING_OUT | OVERLOADED | PROMO | CO_FOUNDER_TRACK
