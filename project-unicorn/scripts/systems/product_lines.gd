class_name ProductLines
extends RefCounted

# GDD — ÜRÜN MODÜLÜ rev 6 §12 · HAT MODELİ.
#
# Alt-tip başına 9 hat: 5 kimlik + 4 paylaşılan platform hattı (§12.2). Her hat 3
# isimli kademeden oluşur ve kademe kendinden öncekini DEĞİŞTİRİR, üstüne EKLEMEZ
# (§12.4). Ürünün bir hattaki durumu tek değerdir: 0 (boş) · 1 · 2 · 3.
#
# VERİ GÜDÜMLÜ, çünkü §12.11 yeni bir alt-tip için "yalnız içerik dosyası eklenir"
# diyor: hatlar data/product/lines/*.json içinde yaşar; bu dosya yalnız ŞEMA,
# DOĞRULAMA ve MERDİVEN KURALLARIDIR.
#
# Oyuncu-yüzü metin BURADA YOK (§12.12): ad ve açıklama hat kimliğinden türetilen
# lokalizasyon anahtarlarından okunur. JSON yalnız kimlik, sayı ve gereksinim taşır.

const LINES_DIR := "res://data/product/lines/"
const SHARED_FILE := "shared.json"

const TIER_MAX := 3

## §12.4 — Kano ağırlıkları 10 / 8 / 12, §11.2'nin katsayı hâli. Ağırlık ile puan
## İKİ KEZ çarpılmaz: gizil zincir yalnız bu katsayıyı kullanır.
const KANO_COEF := {"k1": 1.0, "k2": 0.8, "k3": 1.2}

## §12.4 — efor bantları. Banda uymayan kademe yüklenmez.
const EFFORT_BANDS := {"k1": [5, 7], "k2": [7, 9], "k3": [9, 12]}

## §10 — kullanım ağırlığı; yük katsayısının girdisi. Temel özellik 0-1, ağır
## işlem/AI 2-3.
const USAGE_WEIGHT_MIN := 0
const USAGE_WEIGHT_MAX := 3

## Ar-Ge'nin kademe kaydına tutunan üç etkisi. Sayı kaydın içinde yaşadığı için düğüm
## bir sabiti değil ERİŞİMCİYİ değiştirir; kart ve tahsilat aynı erişimciden okur
## (§12.9: "oyuncu ekranda gördüğü sayıyı alır").
const RND_LICENSE_MULT := 0.60             # model_optimization (Ar-Ge §4.2) — lisans −%40
const RND_EXPERIENCE_EFFORT_MULT := 0.80   # design_system (Ar-Ge §4.4) — Deneyim eforu −%20
const RND_AI_USAGE_RELIEF := 1             # edge_inference (Ar-Ge §4.1) — AI kademesi ağırlık −1

## §12.12 + §5 — her yükseltme anlamlı bir kazanç olmalı. Kısıt HAM PUANA değil
## AĞIRLIKLI KATKIYA uygulanır: mühürlü merkezler 4 · 9 · 12 ham puanken ağırlıklı
## katkıları 4,0 · 7,2 · 14,4 eder (oranlar 1,80 ve 2,00). Ham okunsaydı K3'ün 14,4
## ham puan olması gerekirdi, ki bu mühürlü 12 merkezini kırardı.
const UPGRADE_RATIO_MIN := 1.6

## §12.2 — kimlik hatlarının eksen dağılımı: 2 İnovasyon · 1 Kararlılık · 2 Deneyim.
## Paylaşılanlarla birlikte toplam her eksende 3 hat eder.
const IDENTITY_AXIS_SHAPE := {"innovation": 2, "stability": 1, "experience": 2}
const IDENTITY_LINE_COUNT := 5
const LINES_PER_SUBTYPE := 9

## §12.10 — eksen sahipleri. Kapı-üstü bonusunun (§12.8) hangi alanı okuyacağını
## ve demo çapalarını bu tablo belirler.
const AXIS_OWNER_AREA := {
	"innovation": "product",
	"stability": "qa",
	"experience": "design",
}

static var _lines: Dictionary = {}        # line_id -> line record
static var _steps: Dictionary = {}        # step_id -> step record
static var _by_subtype: Dictionary = {}   # subtype -> Array of line ids
static var _subtypes: Array[String] = []
static var _loaded := false
static var _load_errors: Array[String] = []


## Lazy load. Every public accessor goes through this, so a caller can never read
## a half-built table.
static func ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_load_all()


## Forget everything, runtime lines included, and re-read from disk.
static func reload() -> void:
	_lines.clear()
	_steps.clear()
	_by_subtype.clear()
	_subtypes.clear()
	_load_errors.clear()
	_loaded = false
	ensure_loaded()


static func load_errors() -> Array[String]:
	ensure_loaded()
	return _load_errors.duplicate()


# ---------------------------------------------------------------- loading

static func _load_all() -> void:
	var shared: Dictionary = _read_json(LINES_DIR + SHARED_FILE)
	if shared.is_empty():
		_fail("%s missing or unreadable" % SHARED_FILE)
		return
	var files: PackedStringArray = DirAccess.get_files_at(LINES_DIR)
	files.sort()
	for f in files:
		if f.ends_with(".json") and f != SHARED_FILE:
			_load_subtype(LINES_DIR + f, shared)


static func _load_subtype(path: String, shared: Dictionary) -> void:
	var doc: Dictionary = _read_json(path)
	var subtype: String = String(doc.get("subtype", ""))
	if subtype == "":
		_fail("%s is unreadable or has no subtype id" % path)
		return
	if _by_subtype.has(subtype):
		_fail("duplicate subtype %s" % subtype)
		return

	var identity: Array = doc.get("lines", []) as Array
	if identity.size() != IDENTITY_LINE_COUNT:
		_fail("%s has %d identity lines, expected %d"
			% [subtype, identity.size(), IDENTITY_LINE_COUNT])
		return
	var ids: Array[String] = []
	var axis_tally: Dictionary = {}
	for raw in identity:
		var rec: Dictionary = _build_line(raw as Dictionary, subtype, false)
		if rec.is_empty():
			return
		ids.append(rec["id"])
		axis_tally[rec["axis"]] = int(axis_tally.get(rec["axis"], 0)) + 1
	if axis_tally != IDENTITY_AXIS_SHAPE:
		_fail("%s identity axis shape is %s, §12.2 wants %s"
			% [subtype, axis_tally, IDENTITY_AXIS_SHAPE])
		return

	# §12.10 ekip telegrafları paylaşılan bir kademenin kapısını alt-tipe göre
	# değiştirebilir (ERP'nin Güvenlik & Yetki K3'ü). İskelet ve ad ortak kalır;
	# değişen yalnız gereksinim bloğudur.
	var gate_overrides: Dictionary = doc.get("shared_gate_overrides", {}) as Dictionary
	for raw in shared.get("lines", []) as Array:
		var rec: Dictionary = _build_line(raw as Dictionary, subtype, true, gate_overrides)
		if rec.is_empty():
			return
		ids.append(rec["id"])
	if ids.size() != LINES_PER_SUBTYPE:
		_fail("%s resolved %d lines, expected %d" % [subtype, ids.size(), LINES_PER_SUBTYPE])
		return

	_by_subtype[subtype] = ids
	_subtypes.append(subtype)


## Returns the stored line record, or {} on the first validation failure.
## Shared lines are stored once PER SUBTYPE (`id@subtype`) so their per-subtype
## description key resolves and a line tier is always unambiguous in the save file.
static func _build_line(raw: Dictionary, subtype: String, is_shared: bool,
		gate_overrides: Dictionary = {}) -> Dictionary:
	var line_id: String = String(raw.get("id", ""))
	if line_id == "":
		_fail("%s has a line with no id" % subtype)
		return {}
	var axis: String = String(raw.get("axis", ""))
	if not QualityModel.AXES.has(axis):
		_fail("%s/%s has unknown axis '%s'" % [subtype, line_id, axis])
		return {}
	var steps_raw: Array = raw.get("steps", []) as Array
	if steps_raw.size() != TIER_MAX:
		_fail("%s/%s has %d steps, expected %d" % [subtype, line_id, steps_raw.size(), TIER_MAX])
		return {}

	var suffix: String = "@" + subtype if is_shared else ""
	# §12.12 — anahtarlar hat kimliğinden türetilir; paylaşılan kademenin adı ortak,
	# açıklaması alt-tipe göre yazılır.
	var key_stem: String = line_id.trim_prefix("line_").to_upper()
	var step_ids: Array[String] = []
	for i in steps_raw.size():
		var step: Dictionary = (steps_raw[i] as Dictionary).duplicate(true)
		var tier: int = i + 1
		var kano: String = "k%d" % tier
		var step_id: String = String(step.get("id", ""))
		if step_id != "%s_%s" % [line_id, kano]:
			_fail("%s/%s step %d id is '%s', §12.12 wants '%s_%s'"
				% [subtype, line_id, tier, step_id, line_id, kano])
			return {}
		if gate_overrides.has(step_id):
			step["requires"] = (gate_overrides[step_id] as Dictionary).duplicate(true)
		if not _validate_step(step, subtype, step_id, kano):
			return {}
		var name_key: String = "PROD_STEP_%s_%s" % [key_stem, kano.to_upper()]
		step.merge({
			"id": step_id + suffix,
			"tier": tier,
			"kano": kano,
			"line_id": line_id + suffix,
			"subtype": subtype,
			"axis": axis,
			"name_key": name_key,
			"desc_key": name_key + ("_%s_DESC" % subtype.to_upper() if is_shared else "_DESC"),
		}, true)
		_steps[step["id"]] = step
		step_ids.append(step["id"])

	# §12.5 — paylaşılan hatların K3 haritası BAĞLAYICIDIR ve üç alt-tipte de aynıdır.
	# Bir içerik dosyası bunu sessizce kaydıramaz.
	if ResearchSeam.SHARED_LINE_NODES.has(line_id):
		var want_node: String = String(ResearchSeam.SHARED_LINE_NODES[line_id])
		var got_node: String = String(
			((_steps[step_ids[2]] as Dictionary).get("requires", {}) as Dictionary).get("research", ""))
		if got_node != want_node:
			_fail("%s/%s K3 binds '%s'; §12.5's map says '%s'"
				% [subtype, line_id, got_node, want_node])
			return {}

	# §5 + §12.12 — her kademenin AĞIRLIKLI katkısı, altındakinin en az
	# UPGRADE_RATIO_MIN katı. Ağırlıklı, çünkü kartta görünen ve eksene giren sayı odur (§12.9).
	for i in range(1, step_ids.size()):
		var lo: float = weighted_points(step_ids[i - 1])
		var hi: float = weighted_points(step_ids[i])
		if hi < lo * UPGRADE_RATIO_MIN - 0.0001:
			_fail("%s/%s K%d contributes %.2f, only %.2fx the %.2f below it (§12.12 wants %.2fx)"
				% [subtype, line_id, i + 1, hi, hi / lo, lo, UPGRADE_RATIO_MIN])
			return {}

	var rec := {
		"id": line_id + suffix,
		"axis": axis,
		"shared": is_shared,
		"steps": step_ids,
		"name_key": _line_name_key(line_id),
		"runtime": false,
	}
	_lines[rec["id"]] = rec
	return rec


static func _validate_step(step: Dictionary, subtype: String, step_id: String,
		kano: String) -> bool:
	var effort: int = int(step.get("effort", 0))
	var band: Array = EFFORT_BANDS[kano]
	if effort < int(band[0]) or effort > int(band[1]):
		_fail("%s/%s effort %d outside §12.4 band %s" % [subtype, step_id, effort, band])
		return false

	if int(step.get("axis_points", 0)) <= 0:
		_fail("%s/%s has no axis points" % [subtype, step_id])
		return false

	for ax in step.get("axis_points_secondary", {}) as Dictionary:
		if not QualityModel.AXES.has(String(ax)):
			_fail("%s/%s secondary axis '%s' unknown" % [subtype, step_id, ax])
			return false

	var usage: int = int(step.get("usage_weight", -1))
	if usage < USAGE_WEIGHT_MIN or usage > USAGE_WEIGHT_MAX:
		_fail("%s/%s usage weight %d outside §10 band %d-%d"
			% [subtype, step_id, usage, USAGE_WEIGHT_MIN, USAGE_WEIGHT_MAX])
		return false

	# Ar-Ge §4.1 — isteğe bağlı "ai" işareti BOOL olmak zorunda: `bool()` altında boş
	# olmayan her dizge true'dur, yani `"ai": "false"` rahatlamayı sessizce açardı.
	if step.has("ai") and typeof(step["ai"]) != TYPE_BOOL:
		_fail("%s/%s 'ai' marker must be a bool" % [subtype, step_id])
		return false

	var req: Dictionary = step.get("requires", {}) as Dictionary
	var node: String = String(req.get("research", ""))
	if node != "":
		if not ResearchSeam.is_node(node):
			_fail("%s/%s names research node '%s', which is not in Ar-Ge §4's twenty"
				% [subtype, step_id, node])
			return false
		# Ar-Ge §3.1 ADALET KURALI — görünür bir kademe DEVAM düğümüne bağlanmaz:
		# telegraflanmış hiçbir şey ulaşılmaz olamaz.
		if not ResearchSeam.may_gate_visible_step(node):
			_fail("%s/%s binds a VISIBLE step to '%s', a %s node — Ar-Ge §3.1 forbids it"
				% [subtype, step_id, node, ResearchSeam.placement(node)])
			return false
	# §12.5 — Ar-Ge düğümünü K3 taşır, yalnız K3.
	if (kano == "k3") != (node != ""):
		_fail("%s/%s: §12.5 puts a research node on every K3 and on nothing else"
			% [subtype, step_id])
		return false
	var person: Array = req.get("person", []) as Array
	var total: Array = req.get("total", []) as Array
	if not _validate_gate_list(person, subtype, step_id, "person") \
			or not _validate_gate_list(total, subtype, step_id, "total"):
		return false
	# §12.6 — en fazla üç parça.
	var parts: int = int(node != "") + person.size() + total.size()
	if parts > 3:
		_fail("%s/%s requirement has %d parts, §12.6 allows 3" % [subtype, step_id, parts])
		return false
	return true


static func _validate_gate_list(list: Array, subtype: String, step_id: String,
		kind: String) -> bool:
	for entry in list:
		var d: Dictionary = entry as Dictionary
		var area: String = String(d.get("area", ""))
		if not HRConstants.AREAS.has(area):
			_fail("%s/%s %s gate names unknown area '%s'" % [subtype, step_id, kind, area])
			return false
		var stars: int = int(d.get("stars", 0))
		# §12.6 — gereksinimler DAİMA tam yıldız yazılır.
		if stars < 1 or stars > HRConstants.STAR_MAX:
			_fail("%s/%s %s gate wants %d stars; §12.6 allows 1-%d whole"
				% [subtype, step_id, kind, stars, HRConstants.STAR_MAX])
			return false
	return true


static func _read_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


static func _fail(reason: String) -> void:
	_load_errors.append(reason)
	push_error("[ProductLines] %s" % reason)


static func _line_name_key(base_line_id: String) -> String:
	return "PROD_LINE_%s" % base_line_id.trim_prefix("line_").to_upper()


# ---------------------------------------------------------------- accessors

static func subtypes() -> Array[String]:
	ensure_loaded()
	return _subtypes.duplicate()


static func has_subtype(subtype: String) -> bool:
	ensure_loaded()
	return _by_subtype.has(subtype)


## The nine line ids of a subtype: five identity lines in file order, then the
## four shared ones in §12.2's order, then any runtime line. Empty for an unknown
## subtype — the fourth B2B slot is exactly that until its content file lands (§12.11).
static func line_ids(subtype: String) -> Array:
	ensure_loaded()
	return (_by_subtype.get(subtype, []) as Array).duplicate()


## Line ids grouped by axis, in QualityModel.AXES order. This is what the line list renders.
static func line_ids_by_axis(subtype: String) -> Dictionary:
	var out: Dictionary = {}
	for axis in QualityModel.AXES:
		out[axis] = []
	for lid in line_ids(subtype):
		(out[_lines[lid]["axis"]] as Array).append(lid)
	return out


static func line(line_id: String) -> Dictionary:
	ensure_loaded()
	return _lines.get(line_id, {}) as Dictionary


static func step(step_id: String) -> Dictionary:
	ensure_loaded()
	return _steps.get(step_id, {}) as Dictionary


## The step a line would take at `tier` (1-3), or {} if out of range.
static func step_at(line_id: String, tier: int) -> Dictionary:
	var rec: Dictionary = line(line_id)
	if rec.is_empty() or tier < 1 or tier > TIER_MAX:
		return {}
	return step(String((rec["steps"] as Array)[tier - 1]))


static func axis_of(line_id: String) -> String:
	return String(line(line_id).get("axis", ""))


## Ar-Ge §4.4 `design_system` — YALNIZ Deneyim ekseninin kademelerinde efor −%20.
## · `_validate_step` bandı HAM `effort` üstünden ölçer: indirim bir kademeyi
##   EFFORT_BANDS'ten dışarı itse de yükleme düşmez; doğrulama içeriğin sözleşmesidir.
## · `sum_effort` EforTavanı'nı besler ve tavan commit'te BİR KEZ damgalanır; yapım
##   ortasında biten araştırma koşan yapımı geriye dönük kısmaz (§2/§12.3).
## maxi(1, ...): indirim bir kademeyi bedava yapamaz.
static func effort_of(step_id: String) -> int:
	var s: Dictionary = step(step_id)
	var raw: int = int(s.get("effort", 0))
	if raw > 0 and String(s.get("axis", "")) == "experience" \
			and ResearchSeam.completed("design_system"):
		return maxi(1, int(round(float(raw) * RND_EXPERIENCE_EFFORT_MULT)))
	return raw


## Ar-Ge §4.1 `edge_inference` — `"ai": true` işaretli kademenin kullanım ağırlığı −1,
## §10'un USAGE_WEIGHT_MIN tabanının altına inmeden.
static func usage_weight_of(step_id: String) -> int:
	var s: Dictionary = step(step_id)
	var raw: int = int(s.get("usage_weight", 0))
	if raw > 0 and bool(s.get("ai", false)) and ResearchSeam.completed("edge_inference"):
		return maxi(USAGE_WEIGHT_MIN, raw - RND_AI_USAGE_RELIEF)
	return raw


## §12.9 — "Kartta ham puan değil, Kano katsayısı uygulanmış gerçek değer gösterilir
## — oyuncu ekranda gördüğü sayıyı alır." Bu o değerdir, ve §11.2'nin gizil
## toplamına giren de budur. Ham puan hiçbir yüzeyde tek başına çizilmez.
static func weighted_points(step_id: String) -> float:
	var s: Dictionary = step(step_id)
	return float(int(s.get("axis_points", 0))) * float(KANO_COEF.get(String(s.get("kano", "k1")), 1.0))


## §12.9's parenthesised net gain: what taking the next step is worth ON TOP of
## what the line already contributes. A line at tier 0 gains the whole step.
static func net_gain(line_id: String, current_tier: int) -> float:
	var nxt: int = next_tier(current_tier)
	if nxt == 0:
		return 0.0
	var gain: float = weighted_points(String(step_at(line_id, nxt).get("id", "")))
	if current_tier > 0:
		gain -= weighted_points(String(step_at(line_id, current_tier).get("id", "")))
	return gain


## §12.1 — GİZLİ HATLAR. Ar-Ge'nin devam düğümleri katalogda hiç görünmeyen hatlar
## açar; açıldığında hat listeye girer, K1'den başlar ve normal merdivene uyar.
## İÇERİK Ar-Ge paketinindir (Ar-Ge §4.5); burada yalnız çalışma anında ekleme kapısı var.
##
## `raw` shares the content-file line shape and is stored per subtype exactly like a
## shared line, so a hidden line behaves identically everywhere.
static func register_runtime_line(raw: Dictionary, subtype: String) -> bool:
	ensure_loaded()
	if not _by_subtype.has(subtype):
		_fail("cannot open a hidden line on unknown subtype '%s'" % subtype)
		return false
	var rec: Dictionary = _build_line(raw, subtype, true)
	if rec.is_empty():
		return false
	rec["runtime"] = true
	var ids: Array = _by_subtype[subtype] as Array
	if not ids.has(rec["id"]):
		ids.append(rec["id"])
	return true


## Which lines of a subtype arrived at runtime — the set the save file has to carry
## so a reload does not lose an opened hidden line.
static func runtime_line_ids(subtype: String) -> Array:
	var out: Array = []
	for lid in line_ids(subtype):
		if bool(_lines[lid]["runtime"]):
			out.append(lid)
	return out


## §6.0 — EforTavanı: sürümde seçilen kademelerin efor toplamı.
static func sum_effort(step_ids: Array) -> int:
	var total: int = 0
	for sid in step_ids:
		total += effort_of(String(sid))
	return total


## Lisans maliyetleri commit'te BİR KEZ tahsil edilir. Ar-Ge §4.2 `model_optimization`
## indirimi (−%40) YALNIZ burada uygulanır: tahsilat ile kartta yazan sayı ayrışamaz.
static func sum_license_cost(step_ids: Array) -> int:
	var discounted: bool = ResearchSeam.completed("model_optimization")
	var total: int = 0
	for sid in step_ids:
		var raw: int = int(step(String(sid)).get("license_cost", 0))
		total += int(round(float(raw) * RND_LICENSE_MULT)) if discounted else raw
	return total


# ------------------------------------------------------- §12.3 ladder rules
# MÜHÜRLÜ, ve TEK YERDE. Kart çizimi, Konsept onayı ve kayıt yüklemesi bu üç
# fonksiyonu okur; kendi kontrolünü kurmaz.

## The tier a line may take next, or 0 when the line is finished (§12.3: kademe
## 3'te biter — sayısal seviye ve sonsuz yükseltme yoktur).
static func next_tier(current_tier: int) -> int:
	return 0 if current_tier >= TIER_MAX else current_tier + 1


static func is_complete(current_tier: int) -> bool:
	return current_tier >= TIER_MAX


## §12.3 — atlama yok, sürüm başına hat başına en fazla bir kademe, düşürme yok.
## `planned` is the set of step ids already planned for THIS version.
## Returns "" when the step may be taken, or a machine reason id when it may not.
static func ladder_refusal(step_id: String, current_tier: int, planned: Array) -> String:
	var s: Dictionary = step(step_id)
	if s.is_empty():
		return "unknown_step"
	var tier: int = int(s["tier"])
	if tier <= current_tier:
		return "already_shipped"
	if tier != current_tier + 1:
		return "skips_tier"
	for pid in planned:
		if step(String(pid)).get("line_id", "") == s["line_id"]:
			return "line_already_planned"
	return ""
