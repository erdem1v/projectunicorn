class_name QualityModel
extends RefCounted

# The single choke point between open-ended, multi-dimensional quality and the
# ratio-based economy (SalesSystem). Every consumer calls QualityModel; nobody
# re-derives quality inline.
#
# Three engine-internal axes (never localized; display names come from ProductCatalog):
#   innovation — distinctiveness / tech wow / premium pricing power
#   stability  — bug-freeness / crash resistance / low churn
#   experience — ease of use / onboarding / satisfaction
# Each axis is born at 0 and is open-ended (no upper clamp). grow()'s diminishing
# returns ceilings rival advancement (rival_registry.gd tier asymptotes keep the giant
# band structurally out of reach).

const AXES := ["innovation", "stability", "experience"]

# Equal blend when a sub-type omits quality_axes.
const DEFAULT_AXES := [
	{"axis": "innovation", "weight": 1.0},
	{"axis": "stability",  "weight": 1.0},
	{"axis": "experience", "weight": 1.0},
]

# Saturation half-point: the composite that maps to normalized 50, i.e. where a shipped
# v1 lands on the 0-100 market band. At 25 a stability-competent v1 (raw 17-20) reads
# 40-44, the middle of the B2B tolerance band (B2BConstants). Tuned together with those
# tolerances, the saas_ops_field research unlock, SalesSystem's B2C satisfaction gate and
# RIVAL_TEMPLATE_HALF_SAT: the four are one decision.
const NORMALIZE_HALF_SAT := 25.0
# Rival scale bridge. RivalCatalog.TEMPLATE and its momentum were authored for a
# half-point of 50; normalizing rivals at the player's 25 would double every rival's
# lead in normalized space. Rivals keep 50 until the rival table is re-authored.
# The one reader is SalesSystem._rival_relative_quality; raw-vs-raw comparisons
# (RivalRegistry ranking) are unaffected.
const RIVAL_TEMPLATE_HALF_SAT := 50.0
# How much each open bug erodes the Stability the economy reads: features feed the
# axis, bugs eat it. Also the in-build/launch bug penalty.
const BUG_STABILITY_COEF := 0.8


# =========================================================================
#  Core math
# =========================================================================

# Diminishing-returns accumulator — THE structural-ceiling primitive.
# Positive raw is scaled by remaining headroom so `current` asymptotes below
# `asymptote` forever (for any raw < asymptote). Negative raw (a penalty) applies
# fully, floored at 0.
static func grow(current: float, raw: float, asymptote: float) -> float:
	if raw <= 0.0:
		return maxf(0.0, current + raw)
	return current + raw * maxf(0.0, 1.0 - current / asymptote)


# Open-ended type-weighted composite of the three axes.
static func composite_quality(dims: Dictionary, quality_axes: Array = []) -> float:
	var axes: Array = quality_axes if not quality_axes.is_empty() else DEFAULT_AXES
	var acc := 0.0
	var wsum := 0.0
	for a in axes:
		var w := float(a.get("weight", 0.0))
		acc += w * float(dims.get(String(a.get("axis", "")), 0.0))
		wsum += w
	return acc / wsum if wsum > 0.0 else 0.0


# Saturation: open-ended composite → the ~0-100 band the ratio economy expects.
# Strictly < 100 for every finite input, so conversion_rate's optimal/price and
# similar ratios never blow up when dims run open-ended.
static func normalized_quality(composite: float) -> float:
	return _saturate(composite, NORMALIZE_HALF_SAT)


## A RIVAL's composite on the 0-100 band — same curve, the template's own half-point.
## Never use for the player's product.
static func normalized_quality_rival(composite: float) -> float:
	return _saturate(composite, RIVAL_TEMPLATE_HALF_SAT)


static func _saturate(composite: float, half_sat: float) -> float:
	var c := maxf(0.0, composite)
	return 100.0 * c / (c + half_sat)


static func normalized_from_dims(dims: Dictionary, quality_axes: Array = []) -> float:
	return normalized_quality(composite_quality(dims, quality_axes))


# Single-axis 0-100 score. Pass economy dims when you want bug-eroded stability.
static func axis_score(dims: Dictionary, axis: String) -> float:
	return normalized_quality(float(dims.get(axis, 0.0)))


static func effective_stability(stability: float, bug_count: int) -> float:
	return maxf(0.0, stability - BUG_STABILITY_COEF * float(bug_count))


# =========================================================================
#  Surface adapters — the SAME math runs live (build) and post-ship (flags)
# =========================================================================

# Raw design-time dims (no bug erosion).
static func dims_from_build(b: FeatureBuild) -> Dictionary:
	return {"innovation": b.innovation, "stability": b.stability, "experience": b.experience}


# Economy dims — Stability replaced by effective_stability(bug_count). Everything
# the ECONOMY reads (audience, price, satisfaction) goes through this.
static func economy_dims_from_build(b: FeatureBuild) -> Dictionary:
	return {
		"innovation": b.innovation,
		"stability": effective_stability(b.stability, b.bug_count),
		"experience": b.experience,
	}


# Post-ship: the LIVE bug count (it keeps accruing after ship) erodes stability.
static func economy_dims_from_flags() -> Dictionary:
	return {
		"innovation": float(GameState.get_flag("mvp_innovation", 0.0)),
		"stability":  effective_stability(float(GameState.get_flag("mvp_stability", 0.0)),
			ProductSystem.live_bug_count()),
		"experience": float(GameState.get_flag("mvp_experience", 0.0)),
	}


# THE market-facing quality number. Audience and growth band both read this, so they
# cannot drift.
static func shipped_normalized() -> float:
	return normalized_quality(shipped_composite())


# Post-ship composite (effective) — for rival ranking after ship.
static func shipped_composite() -> float:
	var sub := String(GameState.get_flag("mvp_sub_product_type_id", ""))
	return composite_quality(economy_dims_from_flags(), ProductCatalog.get_quality_axes(sub))


# =========================================================================
#  GDD — ÜRÜN MODÜLÜ rev 6 §11.2 · §11.3 — HAT MODELİNİN OKUMA ZİNCİRİ
# =========================================================================
#
# §18: "Eksen okumaları → §11.2 zinciri; başka hiçbir sistem eksen hesaplamaz."
# Zincir tek yönlüdür ve tamamı burada:
#
#   gizil     = Σ (hattın mevcut kademesinin eksen puanı × Kano katsayısı)
#   ceza      = eksende hiç hat açılmamışsa ×0,6
#   gerçekleş = gizil × tur çarpanı × (1 + kapı-üstü bonusu)
#   okuma     = round(100 × gerçekleşen / çıta_faz), 0-120 arasına sıkıştırılır
#   Kararlılık okumasından ayrıca −2 × açık DOĞRULANMIŞ hata
#
# Eksenler yatırım kolu DEĞİLDİR (§11.1): slider yok, toplam tek skor yok. Bunlar
# skor tabelasıdır.

## §11.3 — pazar çıtası. Beklenen ham gizil değer, her faz geçişinde +%10.
## "Yerinde durmak görece gerilemektir."
const PHASE_BAR := {1: 12.0, 2: 13.2, 3: 14.5}

## 12,0 tam olarak EKSEN BAŞINA ÜÇ HAT'ın K1'idir (3 × 4 × 1,0); yayınlanmış her
## alt-tipte eksen başına üç hat var (§12.2). Gizli bir hat dördüncüyü eklediğinde
## çıta da büyümek zorunda, yoksa hattın tek başına K1'i Series A çıtasında ~+27
## okuma puanı eder.
const BASELINE_LINES_PER_AXIS := 3

## §12.4 — Basic yokluğu cezası. Bir eksende üç hat da boşsa o eksenin gizili
## ×0,6. Pratikte yalnız İKİNCİL puanla beslenen eksende ısırır: kendi hattı
## açılmamışken başka hattın taşmasıyla puan toplayan eksen tam kredi almaz.
const EMPTY_AXIS_PENALTY := 0.6

## §11.2 — Kararlılık okumasından her açık doğrulanmış hata için düşülen puan.
## GELEN BİLDİRİM değil, DOĞRULANMIŞ HATA sayılır (§8.1).
const CONFIRMED_BUG_READING_COST := 2.0

## §11.3 — gösterimde 0-120 arasına sıkıştırılır; üçgen geometrisi 100'ü TAM KENAR
## sayar, yani çıtanın üstündeki ürün kenarı taşırır.
const READING_MIN := 0.0
const READING_MAX := 120.0


## The bar for ONE axis: the phase's market bar (live phase by default) scaled by the
## number of lines the product HAS on that axis — not the number that are OPEN.
##
## Katalog hatları HER ZAMAN sayılır: pazarın taban beklentisidir, oyuncu o hatta
## kademe yayınlamamış olsa bile. Gizli (runtime) bir hat sayıma ancak İLK KADEMESİ
## YAYINLANDIĞINDA girer. AÇIK hatları saymak çıtayı hat açıldığı an, oyuncu içine
## hiçbir şey gönderemeden yükseltirdi (kararlılık okuması 82,8 → 62,1): iyi oynadığı
## için cezalandırılan oyuncu. Bu kuralda K1'i yayınlamak tam NÖTR, K2 +16,5 getirir.
##
## Ölçeği değişen OKUMA'dır, değer değil: `realized_dims` bilerek dokunulmadan kalır,
## çünkü ekonominin doyum eğrisi MUTLAK bir sayı ister. `EventBus.phase_bar_raised`
## burada kullanılmaz: yükü bir FAZ, oysa bir hat tek bir EKSENİ yükseltir.
static func axis_bar(subtype: String, line_tiers: Dictionary, axis: String,
		phase: int = -1) -> float:
	var market_bar: float = float(PHASE_BAR.get(phase if phase > 0 else GameState.phase, PHASE_BAR[1]))
	var counted: int = 0
	for line_id in ProductLines.line_ids_by_axis(subtype).get(axis, []):
		var lid: String = String(line_id)
		if not bool(ProductLines.line(lid).get("runtime", false)) or int(line_tiers.get(lid, 0)) >= 1:
			counted += 1
	if counted <= 0:
		# Bilinmeyen alt-tip ya da hattı olmayan eksen: sıfıra bölmek yerine çıplak çıta.
		return market_bar
	return market_bar * float(counted) / float(BASELINE_LINES_PER_AXIS)


## §5 + §12.8 — the realization multiplier a version stamps onto every step it
## ships: the design-turn multiplier times the above-gate bonus.
##
## STAMPED PER STEP, not applied per read: §2 and §12.3 both rule that a finished
## version is never damaged retroactively ("Yapım geriye dönük bozulmaz"), so a later
## one-turn version must not degrade what a four-turn version already built. §11.2
## writes the multiplier outside the sum; the twice-stated no-retroactive rule wins.
static func realization_stamp(turn_multiplier: float, above_gate_bonus: float) -> float:
	return maxf(0.0, turn_multiplier) * (1.0 + maxf(0.0, above_gate_bonus))


## §11.2 — realized value of one axis. `line_tiers` maps line_id -> 0..3 and
## `line_realization` maps line_id -> the stamp that line's current step shipped
## with (missing = 1.0).
static func realized_axis(subtype: String, line_tiers: Dictionary,
		line_realization: Dictionary, axis: String) -> float:
	var total: float = 0.0
	var own_axis_open := false
	for line_id in ProductLines.line_ids(subtype):
		var lid: String = String(line_id)
		var tier: int = int(line_tiers.get(lid, 0))
		if tier <= 0:
			continue
		var step: Dictionary = ProductLines.step_at(lid, tier)
		if step.is_empty():
			continue
		var points: float = 0.0
		if String(step.get("axis", "")) == axis:
			points = float(int(step.get("axis_points", 0)))
			own_axis_open = true
		else:
			# §12.12 — a step may name an optional secondary axis.
			var secondary: Dictionary = step.get("axis_points_secondary", {}) as Dictionary
			points = float(int(secondary.get(axis, 0)))
		if points <= 0.0:
			continue
		var coef: float = float(ProductLines.KANO_COEF.get(String(step.get("kano", "k1")), 1.0))
		total += points * coef * float(line_realization.get(lid, 1.0))
	if not own_axis_open:
		total *= EMPTY_AXIS_PENALTY
	return total


## §11.3 — the 0-120 reading. This is what the triangle draws, what
## `urun.axis_reading` returns and what the floor ladder (§14) compares against.
static func axis_reading(subtype: String, line_tiers: Dictionary,
		line_realization: Dictionary, axis: String, confirmed_bugs: int = 0,
		phase: int = -1) -> int:
	var realized: float = realized_axis(subtype, line_tiers, line_realization, axis)
	var reading: float = 100.0 * realized / maxf(0.01, axis_bar(subtype, line_tiers, axis, phase))
	if axis == "stability":
		reading -= CONFIRMED_BUG_READING_COST * float(maxi(confirmed_bugs, 0))
	return int(round(clampf(reading, READING_MIN, READING_MAX)))


## All three readings at once — the triangle's feed.
static func axis_readings(subtype: String, line_tiers: Dictionary,
		line_realization: Dictionary, confirmed_bugs: int = 0, phase: int = -1) -> Dictionary:
	var out: Dictionary = {}
	for axis in AXES:
		out[axis] = axis_reading(subtype, line_tiers, line_realization,
			String(axis), confirmed_bugs, phase)
	return out


## The raw realized values, which are what the economy's saturation curve reads
## (`normalized_quality`). Kept separate from the reading on purpose: the reading
## is a comparison against the market bar, the economy wants an absolute.
static func realized_dims(subtype: String, line_tiers: Dictionary,
		line_realization: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for axis in AXES:
		out[axis] = realized_axis(subtype, line_tiers, line_realization, String(axis))
	return out
