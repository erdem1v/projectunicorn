class_name QualityModel
extends RefCounted

# Product Lifecycle Part 1 — the SINGLE choke point between open-ended,
# multi-dimensional quality and the ratio-based economy (SalesSystem).
#
# Three canonical, engine-internal axes (never localized — presentation renames
# happen via ProductCatalog quality_axes[].display_label):
#   innovation — distinctiveness / tech wow / premium pricing power
#   stability  — bug-freeness / crash resistance / low churn
#   experience — ease of use / onboarding / satisfaction (Rev3 renamed third axis)
#
# Each axis is OPEN-ENDED (floor 0, NO upper clamp). Player axes are DETERMINISTIC
# sums of feature contributions since Rev3 (ProductSystem.projected_axes); grow()'s
# diminishing-returns law still ceilings RIVAL advancement (rival_registry.gd tier
# asymptotes keep the giant band structurally out of reach).
#
# Pure statics (RefCounted, no state) — matches ProductSystem / SalesSystem /
# ProductCatalog convention. Runs on BOTH quality surfaces:
#   - live build:  dims_from_build(FeatureBuild)
#   - post-ship:   dims_from_flags()  (mvp_innovation/stability/experience)
# Every consumer calls QualityModel.x(); nobody re-derives quality inline, so the
# 12-consumer rewrite is safe and R1/R6 cannot drift.
#
# NOTE (Erdem decision): axes are BORN AT 0 — a v1 product is genuinely raw and
# climbs into the startup league hour by hour. The old baseline-50 feel is gone.

# --- Canonical axes (engine ids) ---
const AXES := ["innovation", "stability", "experience"]

# Fallback weights + labels when a sub-type omits quality_axes (equal blend).
const DEFAULT_AXES := [
	# Labels come from ProductCatalog.axis_label(axis) — the words live in strings.csv.
	{"axis": "innovation", "weight": 1.0},
	{"axis": "stability",  "weight": 1.0},
	{"axis": "experience", "weight": 1.0},
]

# --- BALANCE-TUNABLE constants (Erdem tunes at the last pass) ---
# Saturation half-point: the composite value that maps to normalized 50. This is
# the knob that decides where a shipped v1 lands on the 0-100 market-quality band.
# CALIBRATION ROUND A §1 (2026-08-19): 50 → 25. The BALANCE FLAG that stood here since
# Rev3 said it plainly — contribution-sum v1 composites (~7-12) normalized to ~12-20 under
# 50 where the retired grown axes produced ~25-35, so every quality reader (audience,
# product_value, satisfaction seed, the B2B satisfaction TARGET) read a played product
# as worse than any bar authored for it: axis(13) was 20.6 against B2B tolerances of
# 40-50, and the retention loop was the default state of competent play. At 25 a
# stability-competent v1 (raw 17-20 from the catalog, before build events) lands at
# 40-44 — the middle of the re-seated tolerance band (B2BConstants). Moved TOGETHER with
# the tolerance re-seat, the saas_ops_field research unlock, SalesSystem's B2C
# satisfaction gate and the rival scale bridge below; the four are one decision.
const NORMALIZE_HALF_SAT := 25.0
# RIVAL SCALE BRIDGE. RivalCatalog.TEMPLATE (startups raw 30-82, asymptote 100) and its
# momentum were authored on the RETIRED grown scale; they are inputs on the same raw axis,
# and halving the player's half-point alone would double every rival's lead in normalized
# space (a played v1's rival-relative q ≈ 22 → churn ~8 %/day, B2C dead by construction).
# Until the rival table is re-authored for the deterministic scale (the world/rival
# session's job, Layer B), rivals keep normalizing at the half-point they were tuned for.
# The ONE reader is SalesSystem._rival_relative_quality. Raw-vs-raw comparisons
# (RivalRegistry ranking, the "seni geçti" strip) are unaffected either way.
const RIVAL_TEMPLATE_HALF_SAT := 50.0
# (PHASE1_AXIS_ASYMPTOTE deleted — Rev3 deterministic sums bypass grow() for the
# player; the ceiling is now the catalog pool sums + strengthen accretion.)
# How much each open (launch) bug erodes the Stability axis the economy reads.
# Bugs are the live face of Stability (Erdem decision): features feed it, bugs eat it.
# Part 2B: softened 1.5→0.8 so a few bugs are tolerable, heavy neglect still bites (global —
# also softens the in-build/launch bug penalty, intended).
const BUG_STABILITY_COEF := 0.8


# =========================================================================
#  Core math
# =========================================================================

# Diminishing-returns accumulator — THE structural-ceiling primitive.
# Positive raw is scaled by remaining headroom so `current` asymptotes below
# `asymptote` forever (for any raw < asymptote). Negative raw (a penalty) applies
# fully, floored at 0. Used by BOTH player growth and rival advancement.
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
	var c := maxf(0.0, composite)
	return 100.0 * c / (c + NORMALIZE_HALF_SAT)


## A RIVAL's composite on the 0-100 band — same curve, the template's own half-point
## (see RIVAL_TEMPLATE_HALF_SAT). Never use for the player's product.
static func normalized_quality_rival(composite: float) -> float:
	var c := maxf(0.0, composite)
	return 100.0 * c / (c + RIVAL_TEMPLATE_HALF_SAT)


static func normalized_from_dims(dims: Dictionary, quality_axes: Array = []) -> float:
	return normalized_quality(composite_quality(dims, quality_axes))


# Single-axis 0-100 score (R2 experience seed, R3 stability gate, R5 per-axis lines,
# BuildHUD gauges). Pass economy dims when you want bug-eroded stability.
static func axis_score(dims: Dictionary, axis: String) -> float:
	return normalized_quality(float(dims.get(axis, 0.0)))


# Bugs are the live face of Stability: the economy reads THIS, not the raw axis.
static func effective_stability(stability: float, bug_count: int) -> float:
	return maxf(0.0, stability - BUG_STABILITY_COEF * float(bug_count))


# =========================================================================
#  Surface adapters — the SAME math runs live (build) and post-ship (flags)
# =========================================================================

# Raw design-time dims (no bug erosion). Use for pure per-axis design display.
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


static func dims_from_flags() -> Dictionary:
	return {
		"innovation": float(GameState.get_flag("mvp_innovation", 0.0)),
		"stability":  float(GameState.get_flag("mvp_stability", 0.0)),
		"experience": float(GameState.get_flag("mvp_experience", 0.0)),
	}


static func economy_dims_from_flags() -> Dictionary:
	# Product Lifecycle Part 2A: reads the LIVE bug count (accrues post-ship via
	# wear), not the frozen launch snapshot. Falls back to the snapshot for any
	# pre-Part-2A shipped state that lacks the live flag.
	var bugs: int = int(GameState.get_flag("mvp_live_bug_count", GameState.get_flag("mvp_bug_count_at_launch", 0)))
	return {
		"innovation": float(GameState.get_flag("mvp_innovation", 0.0)),
		"stability":  effective_stability(float(GameState.get_flag("mvp_stability", 0.0)), bugs),
		"experience": float(GameState.get_flag("mvp_experience", 0.0)),
	}


# THE market-facing quality number. R1 (_tick_b2c_audience) and R6 (growth_band)
# BOTH call this → they cannot drift. Post-ship snapshot, effective stability.
static func shipped_normalized() -> float:
	var sub := String(GameState.get_flag("mvp_sub_product_type_id", ""))
	return normalized_from_dims(economy_dims_from_flags(), ProductCatalog.get_quality_axes(sub))


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

## PHASE_BAR'ın içindeki gizli çarpan, artık açık: 12,0 tam olarak EKSEN BAŞINA
## ÜÇ HAT'ın K1'idir (3 × 4 × 1,0). Yayınlanmış her alt-tipte eksen başına tam
## üç hat var (§12.2, doğrulandı). Gizli bir hat dördüncüyü eklediğinde çıta da
## büyümek zorunda; büyümezse hattın tek başına K1'i Series A çıtasında ~+27 okuma
## puanı eder ve bu kalibre edilmemiş bir hediyedir.
const BASELINE_LINES_PER_AXIS := 3

## §12.4 — Basic yokluğu cezası. Bir eksende üç hat da boşsa o eksenin gizili
## ×0,6. Pratikte yalnız İKİNCİL puanla beslenen eksende ısırır: kendi hattı
## açılmamışken başka hattın taşmasıyla puan toplayan eksen tam kredi almaz.
const EMPTY_AXIS_PENALTY := 0.6

## §11.2 — Kararlılık okumasından her açık doğrulanmış hata için düşülen puan.
## GELEN BİLDİRİM değil, DOĞRULANMIŞ HATA sayılır (§8.1).
const CONFIRMED_BUG_READING_COST := 2.0

## §11.3 — gösterimde 0-120 arasına sıkıştırılır; üçgen geometrisi 100'ü TAM KENAR
## sayar, yani çıtanın üstündeki ürün kenarı taşırır. Bu bir hata değil, okumanın
## kendisidir.
const READING_MIN := 0.0
const READING_MAX := 120.0


## The bar for a phase (1 Bootstrap · 2 Traction · 3 Series A). Defaults to the
## live phase. Stays PUBLIC and un-scaled: this is the market bar itself, which
## `axis_bar` below scales per axis. Callers that want "what does the market
## expect of a three-line axis" want this one.
static func phase_bar(phase: int = -1) -> float:
	var p: int = phase if phase > 0 else GameState.phase
	return float(PHASE_BAR.get(p, PHASE_BAR[1]))


## The bar for ONE axis: the market bar scaled by the number of lines the product
## ACTUALLY HAS on that axis — not the number of lines that are OPEN.
##
## ÇITA ÜRÜNÜN SAHİP OLDUĞU HATLARI SAYAR. Katalog hatları HER ZAMAN sayılır:
## onlar pazarın taban beklentisidir, oyuncu o hatta hiç kademe yayınlamamış olsa
## bile pazar onları bekler. Gizli (runtime) bir hat sayıma ancak İLK KADEMESİ
## YAYINLANDIĞINDA girer (`line_tiers[line_id] >= 1`).
##
## BU KURAL TERSİNE OKUNUYOR VE BİR SONRAKİ OTURUM ONU "DÜZELTMEK" İSTEYECEK,
## O YÜZDEN GEREKÇE BURADA: AÇIK hatları saymak, çıtayı hat AÇILDIĞI AN
## yükseltiyordu — oyuncu içine henüz hiçbir şey gönderememişken. Ölçüldü:
## kararlılık okuması 82,8 → 62,1'e düşüyordu, tam da oyuncunun ağacın en iyi
## ödülünü bulduğu anda. İyi oynadığı için cezalandırılan bir oyuncu.
## Düzeltilmiş kuralda o çukur YOK: K1'i yayınlamak tam olarak NÖTR (ötekilerle
## aynı olgunlukta bir hat eklediniz, yani pazarın beklentisinin tam üstündesiniz),
## K2 ise +16,5 getirir — ve o hak edilmiştir. Kurgu da böyle daha doğru: pazar,
## ürününüzün sahip olmadığı bir yeteneği beklemez; onu eklediğiniz gün beklemeye
## başlar.
##
## ÖLÇEĞİ DEĞİŞEN OKUMA'DIR, DEĞER DEĞİL. `realized_dims` bilerek dokunulmadan
## bırakıldı: ekonominin doyum eğrisi MUTLAK bir sayı istiyor ve gizli hattın
## gerçek getirisi tam olarak orada yaşıyor. Burada değişen, o değerin pazar
## karşısında nasıl OKUNDUĞUDUR.
##
## `EventBus.phase_bar_raised(phase: int)` BU İŞ İÇİN KULLANILMAZ: yükü bir FAZ'dır,
## oysa bir hat açmak tek bir EKSENİ yükseltir. İkisi aynı sinyal değildir.
static func axis_bar(subtype: String, line_tiers: Dictionary, axis: String,
		phase: int = -1) -> float:
	var ids: Array = (ProductLines.line_ids_by_axis(subtype).get(axis, []) as Array)
	var counted: int = 0
	for line_id in ids:
		var lid: String = String(line_id)
		if not bool(ProductLines.line(lid).get("runtime", false)):
			counted += 1                                  # katalog hattı: her zaman sayılır
		elif int(line_tiers.get(lid, 0)) >= 1:
			counted += 1                                  # gizli hat: ilk kademesi çıktıysa
	if counted <= 0:
		# Bilinmeyen alt-tip ya da hiç hattı olmayan eksen — ölçülecek bir şey yok.
		# Sıfıra bölmek yerine çıplak pazar çıtasına düşülür (eski davranış).
		return phase_bar(phase)
	return phase_bar(phase) * float(counted) / float(BASELINE_LINES_PER_AXIS)


## §5 + §12.8 — the realization multiplier a version stamps onto every step it
## ships: the design-turn multiplier times the above-gate bonus.
##
## STAMPED PER STEP, not applied per read. §2 and §12.3 both rule that a finished
## version is never damaged retroactively ("Yapım geriye dönük bozulmaz"), so a
## later one-turn version must not degrade what a four-turn version already built.
## §11.2 writes the multiplier outside the sum, which reads the other way; the
## no-retroactive-damage rule appears twice and wins. FLAGGED.
static func realization_stamp(turn_multiplier: float, above_gate_bonus: float) -> float:
	return maxf(0.0, turn_multiplier) * (1.0 + maxf(0.0, above_gate_bonus))


## §11.2 — realized value of one axis. `line_tiers` maps line_id -> 0..3 and
## `line_realization` maps line_id -> the stamp that line's current step shipped
## with (missing = 1.0, which is what an un-stamped test fixture wants).
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
		var stamp: float = float(line_realization.get(lid, 1.0))
		total += points * coef * stamp
	if not own_axis_open:
		total *= EMPTY_AXIS_PENALTY
	return total


## §11.3 — the 0-120 reading. This is what the triangle draws, what
## `urun.axis_reading` returns and what the floor ladder (§14) compares against.
static func axis_reading(subtype: String, line_tiers: Dictionary,
		line_realization: Dictionary, axis: String, confirmed_bugs: int = 0,
		phase: int = -1) -> int:
	var realized: float = realized_axis(subtype, line_tiers, line_realization, axis)
	# Çıta EKSEN BAŞINA ölçeklenir (bkz. `axis_bar`): gizli bir hat ilk kademesini
	# yayınladığı gün pazarın beklentisi de büyür.
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
