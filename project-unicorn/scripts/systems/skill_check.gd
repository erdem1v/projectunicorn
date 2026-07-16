class_name SkillCheck
extends RefCounted

# Founder skill-check helper — PostShip spec §C. No skill-check existed before;
# the codebase only had bare randf() percentage gates. Disco-Elysium-flavored:
# the result carries a margin BAND so dialogue can comment on *how* it went
# ("kıl payı" / "akıcı") without changing the mechanical outcome.
#
# Pure static logic (no scene). chance = BASE + skill*step + bonus*step
# - difficulty*step, clamped. Founder skills (tech/sales/negotiation/leadership/
# influence — FounderConstants.SKILLS) are 0-3 at creation, ceiling 5, via
# GameState.get_founder_skill.

const BASE_CHANCE := 0.45
const SKILL_STEP := 0.15
const BONUS_STEP := 0.10
const DIFFICULTY_STEP := 0.15
const MIN_CHANCE := 0.05
const MAX_CHANCE := 0.95
const SALES_READ_THRESHOLD := 2   # Satış >= this "reads" a prospect (reveals budget/need)


static func chance_for(skill_name: String, difficulty: int, bonus: int = 0) -> float:
	var skill_val: int = GameState.get_founder_skill(skill_name)
	return clampf(
		BASE_CHANCE + skill_val * SKILL_STEP + bonus * BONUS_STEP - difficulty * DIFFICULTY_STEP,
		MIN_CHANCE, MAX_CHANCE)


## Additive breakdown of chance_for, for the Term Sheet Table's skill-split display (Spec 6 §5).
## Exposes the same terms chance_for sums, so the UI can render "temel %X · +%Y <skill>".
## Invariant: breakdown(...).total == chance_for(...) for all inputs.
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
		"total": clampf(base + skill + bon, MIN_CHANCE, MAX_CHANCE),
	}


## Roll against an explicitly-composed probability. The Term Sheet Table composes its own odds
## (base + skill + leverage − decay) OUTSIDE chance_for, so it rolls through here. Honors the
## debug force flag so the smoke suite stays deterministic — same override as resolve().
static func roll_against(chance: float) -> bool:
	var forced: String = String(GameState.get_flag("debug_skill_force", ""))
	if OS.is_debug_build() and forced == "pass":
		return true
	if OS.is_debug_build() and forced == "fail":
		return false
	return randf() < chance


static func resolve(skill_name: String, difficulty: int, bonus: int = 0) -> Dictionary:
	var chance: float = chance_for(skill_name, difficulty, bonus)
	# Deterministic override for runtime verification (debug builds only):
	# flags["debug_skill_force"] = "pass" | "fail" forces the roll.
	var roll: float
	var forced: String = String(GameState.get_flag("debug_skill_force", ""))
	if OS.is_debug_build() and forced == "pass":
		roll = 0.0
	elif OS.is_debug_build() and forced == "fail":
		roll = 1.0
	else:
		roll = randf()
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
	# High enough Satış to perceive a prospect's hidden budget/real need.
	return GameState.get_founder_skill("sales") >= SALES_READ_THRESHOLD
