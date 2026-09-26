class_name SkillCheck
extends RefCounted

# Founder skill-check. Disco-Elysium-flavored: the result carries a margin BAND so dialogue
# can comment on *how* it went ("kıl payı" / "akıcı") without changing the mechanical outcome.
#
# chance = BASE + skill*step + bonus*step - difficulty*step, clamped. Founder skills
# (FounderConstants.SKILLS) live on the SHARED 0–10 ruler, read via GameState.get_founder_skill.

const BASE_CHANCE := 0.45
## Kurucu değeri başına olasılık adımı. Cetvel 0–10 olduğu için 0–5 cetvelindeki adımın
## yarısıdır: aynı kurucu aynı olasılığı okur.
const SKILL_STEP := 0.075
const BONUS_STEP := 0.10
const DIFFICULTY_STEP := 0.15
const MIN_CHANCE := 0.05
const MAX_CHANCE := 0.95
## Satış >= bu değer ise aday müşteri "okunur" (bütçe/ihtiyaç açılır).
const SALES_READ_THRESHOLD := 4


static func _rng() -> RandomNumberGenerator:
	# The named `skill` stream, not the global one: the global generator's position cannot be
	# read back, so a save could never resume it — the pitch you reload would not be the pitch
	# you saved.
	return RngStreams.get_stream(RngStreams.STREAM_SKILL)


## Debug builds only: flags["debug_skill_force"] = "pass" | "fail" forces every roll, so the
## smoke suite stays deterministic.
static func _forced() -> String:
	return String(GameState.get_flag("debug_skill_force", "")) if OS.is_debug_build() else ""


static func chance_for(skill_name: String, difficulty: int, bonus: int = 0) -> float:
	return float(breakdown(skill_name, difficulty, bonus)["total"])


## Additive breakdown of chance_for, for the Term Sheet Table's "temel %X · +%Y <skill>" split.
static func breakdown(skill_name: String, difficulty: int, bonus: int = 0) -> Dictionary:
	var skill_val: int = GameState.get_founder_skill(skill_name)
	var base: float = BASE_CHANCE - difficulty * DIFFICULTY_STEP   # difficulty folded into "temel"
	var skill: float = skill_val * SKILL_STEP
	var bon: float = bonus * BONUS_STEP                            # at the table, bonus == leverage only
	return {
		"base": base,
		"skill": skill,
		"bonus": bon,
		"skill_name": skill_name,
		"skill_value": skill_val,
		# Summed in this order on purpose: rolls and seeded margins depend on these exact floats.
		"total": clampf(BASE_CHANCE + skill + bon - difficulty * DIFFICULTY_STEP, MIN_CHANCE, MAX_CHANCE),
	}


## Roll against an explicitly-composed probability (the Term Sheet Table composes its own odds).
static func roll_against(chance: float) -> bool:
	match _forced():
		"pass":
			return true
		"fail":
			return false
	return _rng().randf() < chance


static func resolve(skill_name: String, difficulty: int, bonus: int = 0) -> Dictionary:
	var chance: float = chance_for(skill_name, difficulty, bonus)
	var roll: float
	match _forced():
		"pass":
			roll = 0.0
		"fail":
			roll = 1.0
		_:
			roll = _rng().randf()
	var passed: bool = roll < chance
	var margin: float = chance - roll  # >0 comfortable pass; <0 how badly failed
	return {
		"passed": passed,
		"margin": margin,
		"band": _band(passed, margin),
		"chance": chance,
		"roll": roll,
		"skill": skill_name,
		"skill_value": GameState.get_founder_skill(skill_name),
	}


static func _band(passed: bool, margin: float) -> String:
	if passed:
		if margin >= 0.40:
			return "crit_success"
		if margin >= 0.15:
			return "success"
		return "near_pass"
	if margin <= -0.40:
		return "crit_fail"
	if margin <= -0.15:
		return "fail"
	return "near_miss"


static func can_read_prospect() -> bool:
	return GameState.get_founder_skill("sales") >= SALES_READ_THRESHOLD
