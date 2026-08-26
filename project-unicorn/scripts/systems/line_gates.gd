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
const ABOVE_GATE_MAX_STARS := 2

const KIND_RESEARCH := "research"
const KIND_PERSON := "person"
const KIND_TOTAL := "total"


## §12.7 — the gate roster. Employees at ANY status plus the founder. A mentor or
## npc is not staff and never counts.
static func roster() -> Array[Character]:
	var out: Array[Character] = []
	for c in CharacterRegistry.get_employees():
		out.append(c)
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


## The whole evaluation of one step's requirement block.
## Returns {"unlocked": bool, "parts": Array} where each part is
## {kind, area, node, stars, have, met}.
static func evaluate(step_id: String) -> Dictionary:
	var step: Dictionary = ProductLines.step(step_id)
	if step.is_empty():
		return {"unlocked": false, "parts": []}
	var req: Dictionary = step.get("requires", {}) as Dictionary
	var parts: Array = []
	var unlocked := true

	var node: String = String(req.get("research", ""))
	if node != "":
		# §12.5 — Ar-Ge sistemi yokken bu daima false, ve bu SIRALAMADIR.
		var done: bool = ResearchSeam.completed(node)
		parts.append({
			"kind": KIND_RESEARCH, "node": node, "area": "", "stars": 0,
			"have": 0.0, "met": done,
		})
		unlocked = unlocked and done

	for entry in (req.get(KIND_PERSON, []) as Array):
		var d: Dictionary = entry as Dictionary
		var area: String = String(d.get("area", ""))
		var want: int = int(d.get("stars", 0))
		# §12.6 — ★N = ham puan ≥ 2N. Kişi kapısında BUÇUK SAYILMAZ: tek kişinin
		# tam yıldızı istenir.
		var have: float = best_stars(area)
		var met: bool = _person_has(area, want)
		parts.append({
			"kind": KIND_PERSON, "node": "", "area": area, "stars": want,
			"have": have, "met": met,
		})
		unlocked = unlocked and met

	for entry_t in (req.get(KIND_TOTAL, []) as Array):
		var dt: Dictionary = entry_t as Dictionary
		var area_t: String = String(dt.get("area", ""))
		var want_t: int = int(dt.get("stars", 0))
		var have_t: float = total_stars(area_t)
		var met_t: bool = have_t >= float(want_t)
		parts.append({
			"kind": KIND_TOTAL, "node": "", "area": area_t, "stars": want_t,
			"have": have_t, "met": met_t,
		})
		unlocked = unlocked and met_t

	return {"unlocked": unlocked, "parts": parts}


static func is_unlocked(step_id: String) -> bool:
	return bool(evaluate(step_id).get("unlocked", false))


## §12.9 — the lock line names ONLY the unmet item. A met requirement is drawn
## nowhere, and "Kilitsiz" is never written.
##
## RECONCILIATION, flagged: §12.9's prose says "karşılanan gereksinim gösterilmez"
## and the approved component frame (S9) says the same in stronger words ("yalnız
## karşılanmayan kalemi yazar ... karşılanan gereksinim hiçbir yerde çizilmez").
## The format EXAMPLE in the same §12.9 paragraph shows a met part with a tick.
## The sentence and the frame agree with each other, so they win over the example.
static func unmet_parts(step_id: String) -> Array:
	var out: Array = []
	for p in (evaluate(step_id).get("parts", []) as Array):
		if not bool((p as Dictionary).get("met", false)):
			out.append(p)
	return out


static func _person_has(area: String, want_stars: int) -> bool:
	var need_points: int = want_stars * HRConstants.POINTS_PER_STAR
	for c in roster():
		if HRSystem.skill(c, area) >= need_points:
			return true
	return false


# ------------------------------------------------------- §12.8 above the gate
# "Erişim ikilidir. Kapının üstünde: eksen sahibinin fazladan ilk yıldızı
# gerçekleşmeye +%8, ikincisi +%4; fazladan Yazılım yıldızları hızı aynı kademeyle
# çarpar; +2'den sonrası fark yaratmaz."
#
# INTERPRETATION, flagged: the excess is measured against THE STEP'S OWN GATE on
# that area. A step that does not gate on the area earns no bonus from it. The
# alternative reading (excess over some axis-wide reference) would hand every
# product a flat bonus for stars no step ever asked for, which "kapı-üstü" cannot
# mean. Both the realization bonus and the speed bonus run through
# `_excess_ladder`, so re-ruling this is a one-place change.

static func _excess_ladder(excess_stars: float) -> float:
	var n: int = mini(int(floor(maxf(0.0, excess_stars))), ABOVE_GATE_MAX_STARS)
	if n <= 0:
		return 0.0
	if n == 1:
		return ABOVE_GATE_FIRST
	return ABOVE_GATE_FIRST + ABOVE_GATE_SECOND


## How far past its own gate the company stands on `area`, for one step.
## Returns -1.0 when the step does not gate on that area at all.
static func _excess_for(step_id: String, area: String) -> float:
	var req: Dictionary = ProductLines.step(step_id).get("requires", {}) as Dictionary
	var found := false
	var excess: float = 0.0
	for entry in (req.get(KIND_PERSON, []) as Array):
		var d: Dictionary = entry as Dictionary
		if String(d.get("area", "")) != area:
			continue
		found = true
		excess = maxf(excess, best_stars(area) - float(int(d.get("stars", 0))))
	for entry_t in (req.get(KIND_TOTAL, []) as Array):
		var dt: Dictionary = entry_t as Dictionary
		if String(dt.get("area", "")) != area:
			continue
		found = true
		excess = maxf(excess, total_stars(area) - float(int(dt.get("stars", 0))))
	return excess if found else -1.0


## §11.2's `(1 + kapı-üstü bonusu)` term for one step, driven by the axis owner
## (§12.10: İnovasyon → Ürün · Kararlılık → Test · Deneyim → Tasarım).
static func above_gate_bonus(step_id: String) -> float:
	var axis: String = String(ProductLines.step(step_id).get("axis", ""))
	var owner: String = String(ProductLines.AXIS_OWNER_AREA.get(axis, ""))
	if owner == "":
		return 0.0
	var excess: float = _excess_for(step_id, owner)
	if excess < 0.0:
		return 0.0
	return _excess_ladder(excess)


## §12.8 — extra Yazılım stars multiply SPEED at the same ladder. Measured once per
## version against the largest engineering gate the version actually carries; a
## version that gates on engineering nowhere earns no speed bonus.
static func speed_bonus_for(step_ids: Array) -> float:
	var best_excess: float = -1.0
	for sid in step_ids:
		var e: float = _excess_for(String(sid), HRConstants.AREA_ENGINEERING)
		if e >= 0.0:
			best_excess = maxf(best_excess, e)
	if best_excess < 0.0:
		return 0.0
	return _excess_ladder(best_excess)
