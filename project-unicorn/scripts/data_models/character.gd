class_name Character
extends Resource

# Character data model per TECH_SPEC §7.
# Plain data container, no scene dependency. Stored in CharacterRegistry
# (employees, mentor, NPCs) and operated on by HRSystem and future systems.
#
# Used now:
#   - Identity: id, character_name, role (typed id — HRConstants.ROLE_*), category
#   - Compensation: monthly_salary, equity_pct (feeds Finance via pull)
#   - Morale: morale (HR Core moves it from played causes only; range 0..100 clamped
#     in CharacterRegistry.set_morale)
#   - HR Core employment state: status, hire_day, leave_*, flight_risk_days, overtime_days
#   - role_stats: employees hold EXACTLY HRConstants.AXES (0-9); the founder holds
#     EXACTLY FounderConstants.SKILLS. The two key sets never mix — CharacterRegistry.add
#     key-locks both and push_errors on a mismatch.
#   - traits: employees draw from HRConstants.TRAITS, the founder from
#     FounderConstants.TRAITS. Separate catalogs, separate validators.
#
# Reserved (declared with defaults so future systems plug in without
# retrofitting the model and so the save schema is forward-compatible):
#   - loyalty, relationship, trust_score, attention_flag
#
# Naming caution (TECH_SPEC §7): Node reserves `name`, so character names use
# the distinct field `character_name`. Watch for similar collisions in any
# future fields.

# --- Identity (used now) ---
@export var id: String = ""               # "char_<slug>" per TECH_SPEC §12 prefix
@export var character_name: String = ""   # NOT `name` — Node reserves it (TECH_SPEC §7)
@export var role: String = ""             # typed id (HRConstants.ROLE_*) — never free text
@export var category: String = "employee" # "founder" | "employee" | "mentor" | "npc"
# NOTE: `department` is deliberately NOT stored — it is derived from `role` via
# HRConstants.department_of() / section_of() so the two can never fall out of sync.

# --- Compensation (used now — feeds Finance via CharacterRegistry pull) ---
@export var monthly_salary: int = 0
@export var equity_pct: float = 0.0       # hires get 0.0: employee equity is not in the HR design

# --- Morale (used now — range 0..100) ---
# There is NO autonomous drift. Morale moves only from played causes: overtime,
# overload, events, player actions and leave return (HR design doc §6).
@export var morale: int = 50

# --- Skills + traits (used now; see the header note on the key-lock) ---
@export var traits: Array[String] = []       # HRConstants.TRAITS ids (employees); no hidden traits
@export var role_stats: Dictionary = {}      # employee {expertise, pace, rapport} 0-9 | founder 5 skills

# --- HR Core employment state (used now) ---
@export var status: String = "active"        # HRConstants.STATUS_ACTIVE | STATUS_ON_LEAVE
@export var hire_day: int = 0                # stamped in CharacterRegistry.add; 0 = never hired
@export var leave_month: int = 0             # 1-12, assigned at hire; 0 = none
@export var leave_until_day: int = 0         # on_leave ends when GameState.day reaches this
@export var leave_taken_year: int = 0        # once-per-year latch (manual vacation consumes it too)
@export var flight_risk_days: int = 0        # consecutive days under MORALE_FLIGHT_RISK
@export var overtime_days: int = 0           # days worked in the CURRENT overtime block

# --- Reserved for future systems (declared, not used) ---
@export var loyalty: int = 50                # event-driven; future
@export var relationship: String = "neutral" # ally | friendly | neutral | wary | hostile
@export var trust_score: int = 0             # -100..100
# SUPERSEDED by HRSystem.badges_for(), which DERIVES badges from morale/status/capacity
# using this same vocabulary. Left unwritten on purpose: an employee can carry two
# badges at once (TÜKENİYOR + AŞIRI YÜKLÜ) and one String cannot hold both.
@export var attention_flag: String = ""      # FLIGHT_RISK | BURNING_OUT | OVERLOADED | PROMO | CO_FOUNDER_TRACK
