class_name LineGates
extends RefCounted

# GDD — ÜRÜN MODÜLÜ rev 6 §12.5 · §12.6 · §12.7 · §12.8 — GEREKSİNİM DOĞRULAYICI.
#
# §18 TEK KAYNAK KURALI: "Gereksinim kontrolü → tek doğrulayıcı; kart, Konsept
# onayı ve tooltip aynı fonksiyonu okur." Bu o fonksiyondur. Başka hiçbir yerde
# yıldız karşılaştırması yazılmaz.
#
# KAPSAM (§12.7): kapılar ŞİRKET GENELİNDEN okunur — aktif çalışanlar + kurucu, ve
# İZİNDEKİ/EĞİTİMDEKİ kişinin yıldızı DA sayılır (bilgi kaybı yoktur, Ekip §5.7).
# Bu yüzden burada `HRSystem.effective_skill` DEĞİL, ham `HRSystem.skill` okunur:
# effective_skill izindekine 0 döner, o da kapıyı yanlış kapatırdı.
#
# Kontrol Konsept onayında yapılır; yapım sürerken birinin ayrılması yapımı geriye
# dönük bozmaz (§12.7).

## §12.8 — kapı-üstü bonusu. Fazladan ilk yıldız +%8, ikincisi +%4, sonrası fark
## yaratmaz. Tooltip niteliksel kalır; bu sayılar ekrana yazılmaz.
const ABOVE_GATE_FIRST := 0.08
const ABOVE_GATE_SECOND := 0.04

const KIND_RESEARCH := "research"
const KIND_PERSON := "person"
const KIND_TOTAL := "total"


## §12.7 — the gate roster. Employees at ANY status plus the founder. A mentor or
## npc is not staff and never counts.
static func roster() -> Array[Character]:
	var out: Array[Character] = CharacterRegistry.get_employees()
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null:
		out.append(founder)
	return out


## Best whole-and-half star any single person holds in an area.
static func best_stars(area: String) -> float:
	var best: float = 0.0
	for c in roster():
		best = maxf(best, HRConstants.stars_for(HRSystem.skill(c, area)))
	return best


## §12.6 — company total for an area. "Oyuncunun buçukları toplam kapılarında yüz
## değerinden sayılır (2,5★ + 3★ = 5,5 ≥ ★5 ✓)": halves count toward TOTALS, and
## only toward totals.
static func total_stars(area: String) -> float:
	var total: float = 0.0
	for c in roster():
		total += HRConstants.stars_for(HRSystem.skill(c, area))
	return total


## A person gate reads the best single person, a total gate the company sum. A person
## gate ★N needs one person at N whole stars: a 2,5★ never meets ★3.
static func _have(kind: String, area: String) -> float:
	return best_stars(area) if kind == KIND_PERSON else total_stars(area)


## The whole evaluation of one step's requirement block.
## Returns {"unlocked": bool, "parts": Array} where each part is
## {kind, area, node, stars, have, met}.
static func evaluate(step_id: String) -> Dictionary:
	var step: Dictionary = ProductLines.step(step_id)
	if step.is_empty():
		return {"unlocked": false, "parts": []}
	var req: Dictionary = step.get("requires", {}) as Dictionary
	var parts: Array = []
	var node: String = String(req.get("research", ""))
	if node != "":
		parts.append({"kind": KIND_RESEARCH, "node": node, "area": "", "stars": 0,
			"have": 0.0, "met": ResearchSeam.completed(node)})
	for kind in [KIND_PERSON, KIND_TOTAL]:
		for d in (req.get(kind, []) as Array):
			var area: String = String(d.get("area", ""))
			var want: int = int(d.get("stars", 0))
			var have: float = _have(kind, area)
			parts.append({"kind": kind, "node": "", "area": area, "stars": want,
				"have": have, "met": have >= float(want)})
	var unlocked := true
	for p in parts:
		unlocked = unlocked and bool(p["met"])
	return {"unlocked": unlocked, "parts": parts}


static func is_unlocked(step_id: String) -> bool:
	return bool(evaluate(step_id)["unlocked"])


## §12.9 — the lock line names ONLY the unmet item; a met requirement is drawn nowhere.
## (§12.9's format example ticks a met part, but its prose and the approved component
## frame both say otherwise, so they win.)
static func unmet_parts(step_id: String) -> Array:
	return (evaluate(step_id)["parts"] as Array).filter(
		func(p: Dictionary) -> bool: return not bool(p["met"]))


# ------------------------------------------------------- §12.8 above the gate
# "Erişim ikilidir. Kapının üstünde: eksen sahibinin fazladan ilk yıldızı
# gerçekleşmeye +%8, ikincisi +%4; fazladan Yazılım yıldızları hızı aynı kademeyle
# çarpar; +2'den sonrası fark yaratmaz."
#
# The excess is measured against THE STEP'S OWN GATE on that area; a step that does
# not gate on the area earns nothing from it. Reading it against an axis-wide
# reference would pay every product for stars no step asked for, which "kapı-üstü"
# cannot mean. Both bonuses run through `_excess_ladder`.

static func _excess_ladder(excess_stars: float) -> float:
	if excess_stars >= 2.0:
		return ABOVE_GATE_FIRST + ABOVE_GATE_SECOND
	if excess_stars >= 1.0:
		return ABOVE_GATE_FIRST
	return 0.0


## How far past its own gate the company stands on `area` for one step; negative when
## the step does not gate on that area.
static func _excess_for(step_id: String, area: String) -> float:
	var req: Dictionary = ProductLines.step(step_id).get("requires", {}) as Dictionary
	var excess: float = -1.0
	for kind in [KIND_PERSON, KIND_TOTAL]:
		for d in (req.get(kind, []) as Array):
			if String(d.get("area", "")) == area:
				excess = maxf(excess, _have(kind, area) - float(int(d.get("stars", 0))))
	return excess


## §11.2's `(1 + kapı-üstü bonusu)` term for one step, driven by the axis owner
## (§12.10: İnovasyon → Ürün · Kararlılık → Test · Deneyim → Tasarım).
static func above_gate_bonus(step_id: String) -> float:
	var axis: String = String(ProductLines.step(step_id).get("axis", ""))
	var owner: String = String(ProductLines.AXIS_OWNER_AREA.get(axis, ""))
	if owner == "":
		return 0.0
	return _excess_ladder(_excess_for(step_id, owner))


## §12.8 — extra Yazılım stars multiply SPEED at the same ladder: the best excess over
## any engineering gate the version's steps carry. Not yet applied by ProductSystem.
static func speed_bonus_for(step_ids: Array) -> float:
	var best: float = -1.0
	for sid in step_ids:
		best = maxf(best, _excess_for(String(sid), HRConstants.AREA_ENGINEERING))
	return _excess_ladder(best)
