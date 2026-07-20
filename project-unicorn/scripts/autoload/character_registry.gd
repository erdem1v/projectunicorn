extends Node

# Character registry per TECH_SPEC §6.1.
# Single source of truth for all characters — employees, mentor, NPCs — and
# their relationships, traits, morale, and compensation.
#
# Mutations route through registry methods. State changes emit on EventBus
# (TECH_SPEC §13) so scenes (RightPanel, future HR Tab) update themselves
# without the registry knowing who is listening.
#
# Tick interaction (TECH_SPEC §8.2):
#   - HRSystem.daily_tick (slot 3) reads employees and writes morale via set_morale
#   - FinanceSystem.daily_tick (slot 5) pulls get_total_monthly_salaries
#   The pull pattern keeps systems decoupled — Sales (slot 4) will slot in
#   between without changing any wiring.
#
# Naming caution: get_character (not get) — `Object.get(prop)` is reserved
# and shadowing it produces subtle bugs (TECH_SPEC §7 naming-collision note).

# Manual toggle for deliberate registry integration testing. Off in normal runs
# so a fresh game starts with zero employees and zero salary burn (Economic
# Outcome Principle, PROJECT_SPEC §10). With this off, the mentor is still
# provisioned by ensure_mentor() during GameState.initialize_run — no regression
# to onboarding or the RightPanel mentor section. Flip to true to restore the
# Debug Engineer A / Debug Designer B placeholders for HR/Finance pipeline tests.
const DEBUG_SEED := false

var _characters: Dictionary = {}  # id (String) -> Character


func _ready() -> void:
	if DEBUG_SEED:
		_seed_debug_characters()


# --- Read API ---

func get_character(id: String) -> Character:
	return _characters.get(id, null)


func get_all() -> Array[Character]:
	var out: Array[Character] = []
	for c in _characters.values():
		out.append(c)
	return out


func get_employees() -> Array[Character]:
	var out: Array[Character] = []
	for c in _characters.values():
		if c.category == "employee":
			out.append(c)
	return out


const ROLE_CUSTOMER_SUCCESS := "Müşteri Başarı"  # CS role string (TR — also the on-screen label)


func get_customer_success() -> Array[Character]:
	# Customer Success reps — a hired employee type (category "employee") so they count
	# toward payroll + run_hires + morale drift, distinguished by role (not category).
	var out: Array[Character] = []
	for c in _characters.values():
		if c.category == "employee" and c.role == ROLE_CUSTOMER_SUCCESS:
			out.append(c)
	return out


func count_customer_success() -> int:
	return get_customer_success().size()


func count_engineers() -> int:
	# Kapasite havuzu (ProductSystem.capacity_total): kurucu + mühendis sayısı.
	# Role string konvansiyonu "Engineer" (debug seed / smoke ile aynı, büyük-küçük
	# harf duyarlı) — hire flow gelince tek sabite bağlanmalı.
	var n: int = 0
	for c in get_employees():
		if c.role == "Engineer":
			n += 1
	return n


func get_mentor() -> Character:
	for c in _characters.values():
		if c.category == "mentor":
			return c
	return null


func get_founder() -> Character:
	# Player avatar — written once by GameState.initialize_run on onboarding
	# completion. Null before that (registry empty / debug-seed only).
	for c in _characters.values():
		if c.category == "founder":
			return c
	return null


# --- System seed (idempotent) ---

func ensure_mentor() -> void:
	# Called from GameState.initialize_run. Idempotent: _seed_debug_characters
	# already places Frank from _ready, but this defensive call keeps the
	# state-write seam self-contained — if the debug seed is ever removed
	# the mentor still gets created during onboarding completion.
	# Direct insert (no add()) so character_added does not fire for the
	# system-seeded mentor; UI fixtures read get_mentor() at _ready.
	if get_mentor() != null:
		return
	var m := Character.new()
	m.id = "char_mentor_frank"
	m.character_name = "Frank Köseoğlu"
	m.role = "Operating Partner"
	m.category = "mentor"
	m.monthly_salary = 0
	m.equity_pct = 0.0
	m.morale = 50
	_characters[m.id] = m


# --- Queries (consumed by FinanceSystem and future systems) ---

func get_total_monthly_salaries() -> int:
	# Sum payroll across employees only (mentor/NPC excluded).
	var total: int = 0
	for c in _characters.values():
		if c.category == "employee":
			total += c.monthly_salary
	return total


# --- Write API (public — for future hire/fire flow) ---

func add(character: Character) -> void:
	if character == null or character.id == "":
		push_warning("[CharacterRegistry] add() called with null or missing id")
		return
	if _characters.has(character.id):
		push_warning("[CharacterRegistry] add() id collision: %s" % character.id)
		return
	_characters[character.id] = character
	if character.category == "employee":
		# Run counter seam (Spec 3 §3): counted HERE, not at the add_character
		# event modifier, so the future hire flow counts automatically. Founder
		# (category "founder") is excluded; mentor never passes through add().
		GameState.run_hires += 1
	EventBus.character_added.emit(character.id)


func remove(id: String) -> void:
	if not _characters.has(id):
		return
	# Run counter seam (mirrors add()'s employee guard): read category BEFORE erase.
	# Reads 0 today — no fire/quit flow calls remove() with an employee yet; the seam
	# is here so a future departure flow counts automatically.
	var c: Character = _characters[id]
	if c != null and c.category == "employee":
		GameState.run_departures += 1
	_characters.erase(id)
	EventBus.character_removed.emit(id)


# --- Debug reset (onboarding re-trigger) ---
# Clears the roster so a re-triggered initialize_run re-provisions mentor + a fresh
# founder without the char_founder id-collision that add() would otherwise drop.
# Direct clear (no character_removed emits) — the shell is torn down alongside, so
# no listeners remain; mirrors ensure_mentor/_seed inserting directly without signals.
func reset() -> void:
	_characters.clear()


func set_morale(id: String, value: int) -> void:
	# Placeholder clamp range — spec leaves bounds undefined; 0..100 mirrors
	# brand (game_state.gd) and is the natural choice. See PROJECT_SPEC §9
	# if the designer later locks formal morale bounds.
	var c: Character = _characters.get(id, null)
	if c == null:
		push_warning("[CharacterRegistry] set_morale on unknown id: %s" % id)
		return
	var clamped: int = clampi(value, 0, 100)
	if c.morale == clamped:
		return  # No-op: don't emit a redundant signal
	c.morale = clamped
	EventBus.morale_changed.emit(id, clamped)


# --- Debug seed (writes directly to _characters; does NOT call add() so no
#     phantom character_added signals fire on startup) ---

func _seed_debug_characters() -> void:
	# DEBUG SEED — Frank Köseoğlu name placeholder originated in the RightPanel
	# turn. Not in PROJECT_SPEC; canonical mentor identity is a Content Phase
	# decision. Keep marker so future agents know this is unblessed.
	var mentor := Character.new()
	mentor.id = "char_mentor_frank"
	mentor.character_name = "Frank Köseoğlu"
	mentor.role = "Mentor"
	mentor.category = "mentor"
	mentor.monthly_salary = 0
	_characters[mentor.id] = mentor

	# DEBUG SEED — placeholder employees so HR + Finance integration can be
	# verified. Remove when data/characters/employees.json + hire flow exist.
	# Names use explicit DEBUG markers to prevent accidental canonization.
	# Starting morale chosen +/-10 from 50 so drift is visibly progressing
	# during dev verification (10 days of motion before convergence).
	var eng := Character.new()
	eng.id = "char_debug_eng_a"
	eng.character_name = "Debug Engineer A"
	eng.role = "Engineer"
	eng.category = "employee"
	eng.monthly_salary = 6000
	eng.morale = 60
	_characters[eng.id] = eng

	var des := Character.new()
	des.id = "char_debug_des_b"
	des.character_name = "Debug Designer B"
	des.role = "Designer"
	des.category = "employee"
	des.monthly_salary = 5000
	des.morale = 40
	_characters[des.id] = des
