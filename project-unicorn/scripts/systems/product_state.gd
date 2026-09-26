class_name ProductState
extends RefCounted

# GDD — ÜRÜN MODÜLÜ rev 6.1 · CANLI ÜRÜNÜN DURUMU, tek okuma/yazma yüzeyi.
#
# Durum GameState'in TİPLİ bayrak tablosunda yaşar (mvp_*), çünkü kayıt yolu zaten
# oradan geçiyor ve v9 şeması onu taşıyor (§22.5). Bu dosya o bayrakların ADLARININ
# TEK EVİdir: hiçbir sistem `get_flag("mvp_...")` yazmaz, buraya sorar.
#
# Neden bir katman: §18 tek kaynak kuralları. "Hat durumları → tek kaynak; Konsept
# ekranı, monitör, talep üreteci ve olay koşulları aynı tabloyu okur." Bayrak adını
# dört yere kopyalamak o kuralı ilk yeniden adlandırmada bozar.
#
# WRITE-THROUGH: yazan seam'ler burada; kimse ham bayrağa uzanmaz (CLAUDE.md).

const LINE_TIERS := "mvp_line_tiers"
const STEP_REALIZATION := "mvp_step_realization"
const HIDDEN_LINES := "mvp_hidden_lines"
const DESIGN_TURNS := "mvp_design_turns"
const REPORTS_INCOMING := "mvp_reports_incoming"
const REPORTS_PROGRESS := "mvp_reports_progress"
const BUGS_CONFIRMED := "mvp_bugs_confirmed"
const VALIDATION_PROGRESS := "mvp_validation_progress"
const FIX_RUN_ACTIVE := "mvp_fix_run_active"
const FIX_RUN_FIXED := "mvp_fix_run_fixed"
const FIX_RUN_PROGRESS := "mvp_fix_run_progress"
const VERSION_LAUNCH_DAY := "mvp_version_launch_day"
const INTEREST := "mvp_interest"
const INFRA_PROVIDER := "mvp_infra_provider"
const INFRA_UNITS := "mvp_infra_units"
## §9 — "yeni kod terimi": son sürümün efor büyüklüğü. Sürüm yaşıyla (τ=21 gün)
## söner, yani YENİ SÜRÜM SIFIRDAN HAVUZ YARATMAZ — yalnız bu terim sıfırlanır ve
## olgun ürün altta durur. Yayın anında damgalanır.
const NEW_CODE_EFFORT := "mvp_new_code_effort"

## §9 — her yayın ilgiyi buraya tazeler.
const INTEREST_MAX := 100.0


# ------------------------------------------------------------ identity

static func is_live() -> bool:
	return bool(GameState.get_flag("mvp_shipped", false))


static func subtype() -> String:
	return String(GameState.get_flag("mvp_sub_product_type_id", ""))


static func market_type() -> String:
	return String(GameState.get_flag("mvp_market_type", ""))


static func version() -> int:
	return int(GameState.get_flag("mvp_version", 0))


static func product_name() -> String:
	return String(GameState.get_flag("mvp_product_name", ""))


## Is this feature live in the product? The ONE answer for both catalogues: a flat
## feature id (the retired saas_* pools, still used by fixtures) is live when it sits
## in `mvp_components`; a LINE STEP id is live when its line has reached the step's
## tier. Before this existed every reader asked `mvp_components` only — and a line
## product never writes step ids there, so no promise about a line step could ever be
## kept.
static func is_feature_live(feature_id: String) -> bool:
	if feature_id == "":
		return false
	if (GameState.get_flag("mvp_components", []) as Array).has(feature_id):
		return true
	var s: Dictionary = ProductLines.step(feature_id)
	if s.is_empty():
		return false
	return line_tier(String(s.get("line_id", ""))) >= int(s.get("tier", ProductLines.TIER_MAX + 1))


# ------------------------------------------------------- §12 line tiers

## {line_id: 0|1|2|3}. A line absent from the dictionary is empty.
static func line_tiers() -> Dictionary:
	return (GameState.get_flag(LINE_TIERS, {}) as Dictionary).duplicate()


static func line_tier(line_id: String) -> int:
	return int((GameState.get_flag(LINE_TIERS, {}) as Dictionary).get(line_id, 0))


## §12.3 — ladder rules are NOT re-checked here; ProductLines.ladder_refusal owns
## them and the caller must have asked. This is the write, not the decision.
static func set_line_tier(line_id: String, tier: int) -> void:
	var d: Dictionary = (GameState.get_flag(LINE_TIERS, {}) as Dictionary).duplicate()
	d[line_id] = clampi(tier, 0, ProductLines.TIER_MAX)
	GameState.set_flag(LINE_TIERS, d)


## §11.2 — the multiplier a step shipped with. Missing reads 1.0, which is the
## §5 baseline, so an un-stamped fixture behaves as a one-turn version.
static func step_realization() -> Dictionary:
	return (GameState.get_flag(STEP_REALIZATION, {}) as Dictionary).duplicate()


static func stamp_step(step_id: String, mult: float) -> void:
	var d: Dictionary = (GameState.get_flag(STEP_REALIZATION, {}) as Dictionary).duplicate()
	d[step_id] = mult
	GameState.set_flag(STEP_REALIZATION, d)


## The realization map keyed by LINE, which is the shape QualityModel reads: each
## live line contributes through the stamp its CURRENT step shipped with.
static func line_realization() -> Dictionary:
	var stamps: Dictionary = GameState.get_flag(STEP_REALIZATION, {}) as Dictionary
	var tiers: Dictionary = GameState.get_flag(LINE_TIERS, {}) as Dictionary
	var out: Dictionary = {}
	for line_id in tiers:
		var tier: int = int(tiers[line_id])
		if tier <= 0:
			continue
		var step_id: String = String(ProductLines.step_at(String(line_id), tier).get("id", ""))
		out[line_id] = float(stamps.get(step_id, 1.0))
	return out


## §12.1 — hidden lines opened by Ar-Ge continuation nodes. Persisted so a reload
## does not close a line the player has already been shown.
static func hidden_lines() -> Array:
	return (GameState.get_flag(HIDDEN_LINES, []) as Array).duplicate()


static func open_hidden_line(line_id: String) -> void:
	var a: Array = (GameState.get_flag(HIDDEN_LINES, []) as Array).duplicate()
	if not a.has(line_id):
		a.append(line_id)
		GameState.set_flag(HIDDEN_LINES, a)


## §12.10 — how many steps the product has shipped in total. The run profile
## (3-5 versions, 9-14 steps) is measured against this.
static func steps_shipped() -> int:
	var n: int = 0
	for line_id in line_tiers():
		n += int(line_tiers()[line_id])
	return n


static func lines_open() -> int:
	var n: int = 0
	var tiers: Dictionary = line_tiers()
	for line_id in tiers:
		if int(tiers[line_id]) > 0:
			n += 1
	return n


## §10 — yük katsayısının girdisi. TÜRETİLİR, saklanmaz: iki yerde tutulsaydı bir
## kademe yayınlandığında ikisi ayrışırdı.
static func usage_weight_total() -> int:
	var total: int = 0
	var tiers: Dictionary = line_tiers()
	for line_id in tiers:
		var tier: int = int(tiers[line_id])
		if tier <= 0:
			continue
		total += ProductLines.usage_weight_of(
			String(ProductLines.step_at(String(line_id), tier).get("id", "")))
	return total


# ------------------------------------------------------------ §8 DESTEK

static func reports_incoming() -> int:
	return int(GameState.get_flag(REPORTS_INCOMING, 0))


static func bugs_confirmed() -> int:
	return int(GameState.get_flag(BUGS_CONFIRMED, 0))


static func fix_run_active() -> bool:
	return bool(GameState.get_flag(FIX_RUN_ACTIVE, false))


static func fix_run_fixed() -> int:
	return int(GameState.get_flag(FIX_RUN_FIXED, 0))


# ------------------------------------------------------- §9 age, interest

## SÜRÜM yaşı, ürün yaşı DEĞİL (§17). Her yayında sıfırlanır.
static func version_age_days() -> int:
	if not is_live():
		return 0
	var stamped: int = int(GameState.get_flag(VERSION_LAUNCH_DAY, 0))
	if stamped <= 0:
		return 0
	return maxi(0, GameState.day - stamped)


static func interest() -> float:
	return float(GameState.get_flag(INTEREST, 0.0))


static func new_code_effort() -> float:
	return float(GameState.get_flag(NEW_CODE_EFFORT, 0.0))


## §9 — "her yayın ilgiyi 100'e tazeler". Sürüm yaşı, ilgi ve yeni-kod terimi
## BİRLİKTE burada sıfırlanır, çünkü üçü aynı olayın üç yüzüdür; ayrı yazılırlarsa
## ayrışırlar ve akış modeli sessizce yanlış bir yaşı okur.
static func refresh_on_publish(new_effort: float = 0.0) -> void:
	GameState.set_flag(VERSION_LAUNCH_DAY, GameState.day)
	GameState.set_flag(INTEREST, INTEREST_MAX)
	GameState.set_flag(NEW_CODE_EFFORT, maxf(0.0, new_effort))


# ------------------------------------------------------------ §10 infra

static func infra_provider() -> String:
	return String(GameState.get_flag(INFRA_PROVIDER, ""))


static func infra_units() -> int:
	return int(GameState.get_flag(INFRA_UNITS, 0))


## §10 — sağlayıcı ve kapasite WRITE-THROUGH. InfraSystem kararı verir, durum
## buradan yazılır ve sinyal buradan çıkar: repaint eden yüzeyler (kapasite bloğu,
## monitör, fatura satırı) tek bir yerden haber alsın diye.
static func set_infra_provider(provider_id: String) -> void:
	if String(GameState.get_flag(INFRA_PROVIDER, "")) == provider_id:
		return
	GameState.set_flag(INFRA_PROVIDER, provider_id)
	EventBus.infra_changed.emit()


static func set_infra_units(units: int) -> void:
	var clamped: int = maxi(0, units)
	if int(GameState.get_flag(INFRA_UNITS, 0)) == clamped:
		return
	GameState.set_flag(INFRA_UNITS, clamped)
	EventBus.infra_changed.emit()


# ------------------------------------------------------------ readings

## §11.2/§11.3 — the three 0-120 readings, assembled from the one true state.
## Every surface that draws an axis goes through here, never through the chain
## directly, so the triangle and the monitor cannot disagree.
static func axis_readings() -> Dictionary:
	return QualityModel.axis_readings(subtype(), line_tiers(), line_realization(),
		bugs_confirmed())


static func axis_reading(axis: String) -> int:
	return QualityModel.axis_reading(subtype(), line_tiers(), line_realization(),
		axis, bugs_confirmed())


## The raw realized values the economy's saturation curve reads.
static func realized_dims() -> Dictionary:
	return QualityModel.realized_dims(subtype(), line_tiers(), line_realization())
