class_name ProductLines
extends RefCounted

# GDD — ÜRÜN MODÜLÜ rev 6 §12 · HAT MODELİ.
#
# Alt-tip başına 9 hat: 5 kimlik + 4 paylaşılan platform hattı (§12.2). Her hat 3
# isimli kademeden oluşur ve kademe kendinden öncekini DEĞİŞTİRİR, üstüne EKLEMEZ
# (§12.4). Ürünün bir hattaki durumu tek değerdir: 0 (boş) · 1 · 2 · 3.
#
# Düz 12'lik katalog kaldırıldı (§12.1). Gerekçe belgede: tek üründe onlarca sürüm
# çıkarılan bir oyunda tek seferlik tüketilen katalog üçüncü sürümde tükenir.
#
# VERİ GÜDÜMLÜ, ve bu bir gerekliliktir: §12.11 dördüncü B2B alt-tipini ruling'e
# bırakıyor ve "yalnız içerik dosyası eklenir" diyor. O yüzden hatlar burada değil
# data/product/lines/*.json içinde yaşar; bu dosya yalnız ŞEMA, DOĞRULAMA ve
# MERDİVEN KURALLARIDIR.
#
# Oyuncu-yüzü metin BURADA YOK (§12.12): ad ve açıklama türetilmiş lokalizasyon
# anahtarlarından okunur. JSON yalnız kimlik, sayı ve gereksinim taşır.

const LINES_DIR := "res://data/product/lines/"
const SHARED_ID := "shared"

const TIER_EMPTY := 0
const TIER_MAX := 3

## §12.4 — Kano ağırlıkları 10 / 8 / 12, §11.2'nin katsayı hâli. Ağırlık ile puan
## İKİ KEZ çarpılmaz: gizil zincir yalnız bu katsayıyı kullanır.
const KANO_COEF := {"k1": 1.0, "k2": 0.8, "k3": 1.2}
const KANO_WEIGHT := {"k1": 10, "k2": 8, "k3": 12}

## §12.4 — efor bantları. Doğrulama bunu ZORLAR; banda uymayan kademe yüklenmez.
const EFFORT_BANDS := {"k1": [5, 7], "k2": [7, 9], "k3": [9, 12]}

## §10 — kullanım ağırlığı; yük katsayısının girdisi. Temel özellik 0-1, ağır
## işlem/AI 2-3.
const USAGE_WEIGHT_MIN := 0
const USAGE_WEIGHT_MAX := 3

## §12.5 (rev 6.1) — düğüm kimliklerinin TEK KAYNAĞI Ar-Ge GDD §4'tür ve o tablo
## `ResearchSeam.NODES`'ta yaşar. Burada ikinci bir liste TUTULMAZ; eskiden tutulan
## altı isimlik liste iki düğümü (data_model · security_cert) kaçırıyordu.

## Ar-Ge'nin ERİŞİMCİ SEVİYESİNDE tutunan üç etkisi. Ötekilerin aksine bunların
## bugün bir tabanı yok — sayı kademe kaydının içinde yaşıyor, o yüzden düğüm bir
## sabiti değil ERİŞİMCİYİ değiştirir. Üçünün de tek darboğazı vardır ve çarpan
## orada, TEK YERDE uygulanır (§12.9'un "oyuncu ekranda gördüğü sayıyı alır"
## kuralı: kart ve tahsilat aynı fonksiyondan okur).
const RND_LICENSE_MULT := 0.60             # model_optimization (Ar-Ge §4.2) — lisans −%40
const RND_EXPERIENCE_EFFORT_MULT := 0.80   # design_system (Ar-Ge §4.4) — Deneyim eforu −%20
const RND_AI_USAGE_RELIEF := 1             # edge_inference (Ar-Ge §4.1) — AI kademesi ağırlık −1

## §12.12 + §5 — bir yükseltme her zaman anlamlı bir kazanç olmalı. Kısıt HAM PUANA
## değil AĞIRLIKLI KATKIYA uygulanır (direktör hükmü, 2026-08-25): mühürlü merkezler
## 4 · 9 · 12 ham puanken ağırlıklı katkıları 4,0 · 7,2 · 14,4 eder ve oranlar 1,80
## ile 2,00 çıkar. Ham okunsaydı K3'ün 14,4 ham puan olması gerekirdi, ki bu mühürlü
## 12 merkezini kırardı. §12.9'un kart kuralı da aynı yöne bakıyor: kartta ham puan
## değil, Kano katsayısı uygulanmış gerçek değer yazılıdır.
const UPGRADE_RATIO_MIN := 1.6

## §12.2 — paylaşılan hatların iskeleti ve kademe adları her alt-tipte ORTAKTIR;
## alt-tipe göre değişen yalnız tek satırlık açıklamadır.
const SHARED_LINE_IDS := ["line_shared_integrations", "line_shared_security",
	"line_shared_durability", "line_shared_mobile"]

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


## Test/debug seam: forget everything and re-read from disk.
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
	var shared: Dictionary = _read_json(LINES_DIR + SHARED_ID + ".json")
	if shared.is_empty():
		_fail("shared.json missing or unreadable")
		return

	var dir := DirAccess.open(LINES_DIR)
	if dir == null:
		_fail("cannot open %s" % LINES_DIR)
		return
	var files: Array[String] = []
	dir.list_dir_begin()
	var filename: String = dir.get_next()
	while filename != "":
		if not dir.current_is_dir() and filename.ends_with(".json") \
				and filename != SHARED_ID + ".json":
			files.append(filename)
		filename = dir.get_next()
	dir.list_dir_end()
	files.sort()

	for f in files:
		_load_subtype(LINES_DIR + f, shared)


static func _load_subtype(path: String, shared: Dictionary) -> void:
	var doc: Dictionary = _read_json(path)
	if doc.is_empty():
		_fail("unreadable subtype file %s" % path)
		return
	var subtype: String = String(doc.get("subtype", ""))
	if subtype == "":
		_fail("%s has no subtype id" % path)
		return
	if _by_subtype.has(subtype):
		_fail("duplicate subtype %s" % subtype)
		return

	var ids: Array[String] = []
	var axis_tally: Dictionary = {"innovation": 0, "stability": 0, "experience": 0}

	# --- 5 kimlik hattı ------------------------------------------------
	var identity: Array = doc.get("lines", []) as Array
	if identity.size() != IDENTITY_LINE_COUNT:
		_fail("%s has %d identity lines, expected %d"
			% [subtype, identity.size(), IDENTITY_LINE_COUNT])
		return
	for raw in identity:
		var rec: Dictionary = _build_line(raw as Dictionary, subtype, false, {})
		if rec.is_empty():
			return
		ids.append(String(rec["id"]))
		axis_tally[rec["axis"]] = int(axis_tally[rec["axis"]]) + 1

	# --- 4 paylaşılan hat, alt-tipe özel açıklamalarla ------------------
	# §12.10 ekip telegrafları paylaşılan bir kademenin kapısını alt-tipe göre
	# değiştirebilir (ERP'nin Güvenlik & Yetki K3'ü). İskelet ve ad ortak kalır;
	# değişen yalnız gereksinim bloğudur.
	var overrides: Dictionary = doc.get("shared_descriptions", {}) as Dictionary
	var gate_overrides: Dictionary = doc.get("shared_gate_overrides", {}) as Dictionary
	for raw_shared in (shared.get("lines", []) as Array):
		var rec_s: Dictionary = _build_line(raw_shared as Dictionary, subtype, true,
			overrides, gate_overrides)
		if rec_s.is_empty():
			return
		ids.append(String(rec_s["id"]))

	if ids.size() != LINES_PER_SUBTYPE:
		_fail("%s resolved %d lines, expected %d" % [subtype, ids.size(), LINES_PER_SUBTYPE])
		return
	for axis in IDENTITY_AXIS_SHAPE:
		if int(axis_tally[axis]) != int(IDENTITY_AXIS_SHAPE[axis]):
			_fail("%s identity axis shape is %s, §12.2 wants %s"
				% [subtype, axis_tally, IDENTITY_AXIS_SHAPE])
			return

	_by_subtype[subtype] = ids
	_subtypes.append(subtype)


## Returns the stored line record, or {} on the first validation failure.
## Shared lines are stored once PER SUBTYPE so their per-subtype description key
## resolves and so a line tier is always unambiguous in the save file.
static func _build_line(raw: Dictionary, subtype: String, is_shared: bool,
		overrides: Dictionary, gate_overrides: Dictionary = {}) -> Dictionary:
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

	var stored_id: String = line_id if not is_shared else "%s@%s" % [line_id, subtype]
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
		if is_shared and gate_overrides.has(step_id):
			step["requires"] = (gate_overrides[step_id] as Dictionary).duplicate(true)
		if not _validate_step(step, subtype, step_id, kano):
			return {}
		step["tier"] = tier
		step["kano"] = kano
		step["line_id"] = stored_id
		step["subtype"] = subtype
		step["axis"] = axis
		step["shared"] = is_shared
		# §12.12 — paylaşılan kademenin açıklaması alt-tipe göre yazılır; adı ortaktır.
		step["desc_key"] = _desc_key(line_id, kano, subtype, is_shared, overrides)
		step["name_key"] = _name_key(line_id, kano)
		var stored_step_id: String = step_id if not is_shared else "%s@%s" % [step_id, subtype]
		step["id"] = stored_step_id
		_steps[stored_step_id] = step
		step_ids.append(stored_step_id)

	# §12.5 — paylaşılan hatların K3 haritası BAĞLAYICIDIR ve üç alt-tipte de aynıdır.
	# Bir içerik dosyası bunu sessizce kaydıramaz.
	if is_shared and ResearchSeam.SHARED_LINE_NODES.has(line_id):
		var want_node: String = String(ResearchSeam.SHARED_LINE_NODES[line_id])
		var k3: Dictionary = _steps[step_ids[2]]
		var got_node: String = String((k3.get("requires", {}) as Dictionary).get("research", ""))
		if got_node != want_node:
			_fail("%s/%s K3 binds '%s'; §12.5's map says '%s'"
				% [subtype, line_id, got_node, want_node])
			return {}

	# §5 + §12.12 — her yükseltme anlamlı bir kazanç olmalı: bir kademenin AĞIRLIKLI
	# katkısı, altındakinin en az UPGRADE_RATIO_MIN katı. Ham puan değil ağırlıklı
	# değer, çünkü oyuncunun kartta gördüğü ve eksene giren sayı odur (§12.9).
	for i in range(1, step_ids.size()):
		var lo: float = weighted_points(String(step_ids[i - 1]))
		var hi: float = weighted_points(String(step_ids[i]))
		if lo > 0.0 and hi < lo * UPGRADE_RATIO_MIN - 0.0001:
			_fail("%s/%s K%d contributes %.2f, only %.2fx the %.2f below it (§12.12 wants %.2fx)"
				% [subtype, line_id, i + 1, hi, hi / lo, lo, UPGRADE_RATIO_MIN])
			return {}

	var rec := {
		"id": stored_id,
		"base_id": line_id,
		"axis": axis,
		"shared": is_shared,
		"subtype": subtype,
		"steps": step_ids,
		"name_key": _line_name_key(line_id),
		"runtime": false,
	}
	_lines[stored_id] = rec
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

	var secondary: Dictionary = step.get("axis_points_secondary", {}) as Dictionary
	for ax in secondary:
		if not QualityModel.AXES.has(String(ax)):
			_fail("%s/%s secondary axis '%s' unknown" % [subtype, step_id, ax])
			return false

	var usage: int = int(step.get("usage_weight", -1))
	if usage < USAGE_WEIGHT_MIN or usage > USAGE_WEIGHT_MAX:
		_fail("%s/%s usage weight %d outside §10 band %d-%d"
			% [subtype, step_id, usage, USAGE_WEIGHT_MIN, USAGE_WEIGHT_MAX])
		return false

	# Ar-Ge §4.1 `edge_inference` — "ai" kademenin İSTEĞE BAĞLI işaretidir; yokluğu
	# false demektir ve bugün hiçbir içerik dosyası taşımıyor. Varsa BOOL olmak
	# zorunda, ve bu tip kontrolü boşuna değil: `bool()` altında BOŞ OLMAYAN HER DİZGE
	# true'dur, yani `"ai": "false"` yazan bir içerik dosyası rahatlamayı sessizce
	# AÇARDI. Kaza yükleme anında ölür, oyunda değil.
	if step.has("ai") and typeof(step["ai"]) != TYPE_BOOL:
		_fail("%s/%s 'ai' marker must be a bool" % [subtype, step_id])
		return false

	var req: Dictionary = step.get("requires", {}) as Dictionary
	var node: String = String(req.get("research", ""))
	if node != "" and not ResearchSeam.is_node(node):
		_fail("%s/%s names research node '%s', which is not in Ar-Ge §4's twenty"
			% [subtype, step_id, node])
		return false
	# Ar-Ge §3.1 ADALET KURALI — görünür bir K3 asla DEVAM düğümüne bağlanmaz.
	# Telegraflanmış bir şeyi ulaşılmaz yapmak yasak: kök ya da dal, en fazla iki
	# araştırma uzakta. Devam düğümleri vaat edilmemiş içerik getirir (§12.1).
	if node != "" and not ResearchSeam.may_gate_visible_step(node):
		_fail("%s/%s binds a VISIBLE step to '%s', a %s node — Ar-Ge §3.1 forbids it"
			% [subtype, step_id, node, ResearchSeam.placement(node)])
		return false
	# §12.5 — K3 Ar-Ge düğümü + yıldız taşır; K1 çoğunlukla kilitsizdir.
	if kano == "k3" and node == "":
		_fail("%s/%s is a K3 with no research node (§12.5)" % [subtype, step_id])
		return false
	if kano != "k3" and node != "":
		_fail("%s/%s is a %s carrying a research node; §12.5 puts those on K3"
			% [subtype, step_id, kano.to_upper()])
		return false
	if not _validate_gate_list(req.get("person", []) as Array, subtype, step_id, "person"):
		return false
	if not _validate_gate_list(req.get("total", []) as Array, subtype, step_id, "total"):
		return false
	# §12.6 — en fazla üç parça.
	var parts: int = (1 if node != "" else 0) \
		+ (req.get("person", []) as Array).size() \
		+ (req.get("total", []) as Array).size()
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
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[ProductLines] cannot open %s (err %d)" % [path, FileAccess.get_open_error()])
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[ProductLines] JSON parse failed: %s" % path)
		return {}
	return parsed as Dictionary


static func _fail(reason: String) -> void:
	_load_errors.append(reason)
	push_error("[ProductLines] %s" % reason)


# ------------------------------------------------- localization key derivation
# §12.12 — anahtarlar/kimlikler İngilizce, içerik TR + EN. Ekrana sabit metin
# gömülmez. Anahtar hat kimliğinden TÜRETİLİR, ayrıca saklanmaz.

static func _line_name_key(base_line_id: String) -> String:
	return "PROD_LINE_%s" % base_line_id.trim_prefix("line_").to_upper()


static func _name_key(base_line_id: String, kano: String) -> String:
	return "PROD_STEP_%s_%s" % [base_line_id.trim_prefix("line_").to_upper(), kano.to_upper()]


static func _desc_key(base_line_id: String, kano: String, subtype: String,
		is_shared: bool, overrides: Dictionary) -> String:
	if not is_shared:
		return "%s_DESC" % _name_key(base_line_id, kano)
	# Paylaşılan kademe: alt-tip başına bir açıklama satırı. Dosya açıkça bir
	# anahtar verirse o kazanır; vermezse şemadan türetilir.
	var explicit: String = String(overrides.get("%s_%s" % [base_line_id, kano], ""))
	if explicit != "":
		return explicit
	return "PROD_STEP_%s_%s_%s_DESC" % [
		base_line_id.trim_prefix("line_").to_upper(), kano.to_upper(), subtype.to_upper()]


# ---------------------------------------------------------------- accessors

static func subtypes() -> Array[String]:
	ensure_loaded()
	return _subtypes.duplicate()


static func has_subtype(subtype: String) -> bool:
	ensure_loaded()
	return _by_subtype.has(subtype)


## The nine line ids of a subtype: five identity lines in file order, then the
## four shared ones in §12.2's order. Empty for an unknown subtype — the fourth
## B2B slot is exactly that until its content file lands (§12.11).
static func line_ids(subtype: String) -> Array:
	ensure_loaded()
	return (_by_subtype.get(subtype, []) as Array).duplicate()


## Line ids grouped by axis, in QualityModel.AXES order. Three per axis by
## construction (§12.2). This is what the line list renders.
static func line_ids_by_axis(subtype: String) -> Dictionary:
	ensure_loaded()
	var out: Dictionary = {}
	for axis in QualityModel.AXES:
		out[axis] = []
	for lid in line_ids(subtype):
		var rec: Dictionary = _lines.get(lid, {}) as Dictionary
		if rec.is_empty():
			continue
		(out[rec["axis"]] as Array).append(lid)
	return out


static func line(line_id: String) -> Dictionary:
	ensure_loaded()
	return _lines.get(line_id, {}) as Dictionary


static func step(step_id: String) -> Dictionary:
	ensure_loaded()
	return _steps.get(step_id, {}) as Dictionary


## The step a line would take at `tier` (1-3), or {} if out of range.
static func step_at(line_id: String, tier: int) -> Dictionary:
	ensure_loaded()
	var rec: Dictionary = line(line_id)
	if rec.is_empty() or tier < 1 or tier > TIER_MAX:
		return {}
	return step(String((rec["steps"] as Array)[tier - 1]))


static func axis_of(line_id: String) -> String:
	return String(line(line_id).get("axis", ""))


## Ar-Ge §4.4 `design_system` — YALNIZ Deneyim ekseninin kademelerinde efor −%20.
## İki şey hataya benziyor ve ikisi de KASITLI, ölçüldü:
##   · `_validate_step` bandı HAM `effort` üstünden ölçüyor, bu fonksiyondan değil;
##     yani indirim bir kademeyi §12.4'ün EFFORT_BANDS'inden DIŞARI itemez ve kayıt
##     yeniden yüklendiğinde doğrulama düşmez. Doğrulama içeriğin sözleşmesini
##     ölçer, oyuncunun o günkü Ar-Ge durumunu değil.
##   · `sum_effort` sürümün EforTavanı'nı besler ve o tavan commit'te BİR KEZ
##     `FeatureBuild.total_efor`a damgalanır. Yani `design_system`'i yapım
##     ortasında bitirmek koşan yapımın tavanını geriye dönük KISMAZ — §2/§12.3'ün
##     "Yapım geriye dönük bozulmaz" kuralı bunu istiyor. İndirim bir SONRAKİ
##     sürümün konseptinde görünür.
## maxi(1, ...): indirimin bir kademeyi 0 efora düşürmesi (bedava kademe) yasak.
static func effort_of(step_id: String) -> int:
	var s: Dictionary = step(step_id)
	var raw: int = int(s.get("effort", 0))
	if raw <= 0 or String(s.get("axis", "")) != "experience":
		return raw
	if not ResearchSeam.completed("design_system"):
		return raw
	return maxi(1, int(round(float(raw) * RND_EXPERIENCE_EFFORT_MULT)))


## Ar-Ge §4.2 `model_optimization` — kademe lisans maliyeti −%40. `sum_license_cost`
## bu fonksiyonun TEK çağıranıdır, yani indirimin uygulandığı tek yer burasıdır ve
## commit'teki tahsilat ile kartta yazan sayı ayrışamaz. Lisansı olmayan kademe
## (raw ≤ 0) dokunulmadan geçer: %40'ı sıfırın sıfırdır, ama erken dönüş niyeti de
## belgeler — indirim bir maliyeti KISAR, yoktan maliyet YARATMAZ.
static func license_cost_of(step_id: String) -> int:
	var raw: int = int(step(step_id).get("license_cost", 0))
	if raw <= 0 or not ResearchSeam.completed("model_optimization"):
		return raw
	return int(round(float(raw) * RND_LICENSE_MULT))


## Ar-Ge §4.1 `edge_inference` — AI kademesinin kullanım ağırlığı −1 (§10'un
## USAGE_WEIGHT_MIN tabanının altına inmez). BUGÜN İÇERİKTE AI İŞARETİ YOK: işaret
## kademe kaydının isteğe bağlı `"ai": true` alanıdır, yokluğu false sayılır ve
## hat JSON'larına işaretleri koymak Ar-Ge içerik işinin parçasıdır. İşaretsiz
## kademede düğüm tamamlansa bile bu fonksiyon ham ağırlığı döndürür — bu bir kırık
## değil, içeriğin henüz konuşmamış olmasıdır.
static func usage_weight_of(step_id: String) -> int:
	var s: Dictionary = step(step_id)
	var raw: int = int(s.get("usage_weight", 0))
	if raw <= 0 or not bool(s.get("ai", false)):
		return raw
	if not ResearchSeam.completed("edge_inference"):
		return raw
	return maxi(USAGE_WEIGHT_MIN, raw - RND_AI_USAGE_RELIEF)


static func kano_coef(step_id: String) -> float:
	return float(KANO_COEF.get(String(step(step_id).get("kano", "k1")), 1.0))


## §12.9 — "Kartta ham puan değil, Kano katsayısı uygulanmış gerçek değer gösterilir
## — oyuncu ekranda gördüğü sayıyı alır." Bu o değerdir, ve §11.2'nin gizil
## toplamına giren de budur. Ham puan hiçbir yüzeyde tek başına çizilmez.
static func weighted_points(step_id: String) -> float:
	return float(int(step(step_id).get("axis_points", 0))) * kano_coef(step_id)


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
## açar; açıldığında hat listeye girer ve K1'den başlar, normal merdiven kurallarına
## uyar. İÇERİK Ar-Ge paketinindir (Ar-Ge §4.5); burada yalnız hattın çalışma anında
## eklenebilmesi için gereken kapı var.
##
## `raw` shares the content-file line shape. The step ids are stored per subtype
## exactly like a shared line, so a hidden line behaves identically everywhere.
static func register_runtime_line(raw: Dictionary, subtype: String) -> bool:
	ensure_loaded()
	if not _by_subtype.has(subtype):
		_fail("cannot open a hidden line on unknown subtype '%s'" % subtype)
		return false
	var rec: Dictionary = _build_line(raw, subtype, true, {}, {})
	if rec.is_empty():
		return false
	rec["runtime"] = true
	var ids: Array = _by_subtype[subtype] as Array
	var stored_id: String = String(rec["id"])
	if not ids.has(stored_id):
		ids.append(stored_id)
	return true


## Which lines of a subtype arrived at runtime — the set the save file has to carry
## so a reload does not lose an opened hidden line.
static func runtime_line_ids(subtype: String) -> Array:
	ensure_loaded()
	var out: Array = []
	for lid in line_ids(subtype):
		if bool(line(String(lid)).get("runtime", false)):
			out.append(lid)
	return out


## §6.0 — EforTavanı: sürümde seçilen kademelerin efor toplamı.
static func sum_effort(step_ids: Array) -> int:
	var total: int = 0
	for sid in step_ids:
		total += effort_of(String(sid))
	return total


## Lisans maliyetleri commit'te BİR KEZ tahsil edilir.
static func sum_license_cost(step_ids: Array) -> int:
	var total: int = 0
	for sid in step_ids:
		total += license_cost_of(String(sid))
	return total


# ------------------------------------------------------- §12.3 ladder rules
# MÜHÜRLÜ, ve TEK YERDE. Kart çizimi, Konsept onayı ve kayıt yüklemesi bu üç
# fonksiyonu okur; kendi kontrolünü kurmaz.

## The tier a line may take next, or 0 when the line is finished (§12.3: kademe
## 3'te biter — sayısal seviye ve sonsuz yükseltme yoktur).
static func next_tier(current_tier: int) -> int:
	if current_tier >= TIER_MAX:
		return 0
	return current_tier + 1


static func is_complete(current_tier: int) -> bool:
	return current_tier >= TIER_MAX


## §12.3 — atlama yok, sürüm başına hat başına en fazla bir kademe, düşürme yok.
## `planned` is the set of step ids already planned for THIS version.
## Returns "" when the step may be taken, or a machine reason id when it may not.
static func ladder_refusal(step_id: String, current_tier: int, planned: Array) -> String:
	var s: Dictionary = step(step_id)
	if s.is_empty():
		return "unknown_step"
	var tier: int = int(s.get("tier", 0))
	if tier <= current_tier:
		return "already_shipped"
	if tier != current_tier + 1:
		return "skips_tier"
	var line_id: String = String(s.get("line_id", ""))
	for pid in planned:
		if String(step(String(pid)).get("line_id", "")) == line_id:
			return "line_already_planned"
	return ""
