class_name ProductSystem
extends RefCounted

# Canlı ürün. Saf mantık: TimeManager saatlik (hourly_tick) ve günlük (daily_tick, slot 1)
# sürer; durum GameState.flags'teki mvp_* anahtarlarındadır. Yapım sprint motorundadır
# (SprintSystem); burada yayındaki ürünün aşınması ve sağlık türetmeleri var.

# --- Canlı ürün ---
# Aşınma: kullanıcı ve karmaşıklık saatlik hata biriktirir; Test uzmanlığı düşürür ama WEAR_FLOOR'un
# altına indiremez. İhmal edilen ürün hatayı günler içinde biriktirir. Katsayılar takvim saati
# başınadır; saatlik tik yedi takvim saati taşır.
const WEAR_AUD_COEF := 0.00004       # kullanıcı başına / saat
const WEAR_CPLX_COEF := 0.0012       # toplam karmaşıklık puanı başına / saat
const WEAR_TECH_REDUCER := 0.005
const WEAR_FLOOR := 0.002
## Aşınmanın uzmanlık ortalamasında kurucunun ağırlığı; çalışan 1 sayılır. Solo kurucuda
## ortalama kurucunun kendi puanıdır, bu yüzden WEAR_TECH_REDUCER ölçeklenmez.
const FOUNDER_EXPERTISE_WEIGHT := 1.5
# Ürün sağlığı ve trend türetmeleri.
const BUG_HISTORY_WEEKS := 2        # mvp_bug_history penceresi (tik başına bir örnek)
const TREND_DELTA := 2              # |son − ilk| >= bu → artıyor/azalıyor, altı sabit
const TREND_SPIKE := 4              # keskin artış → sağlık riskli
const HEALTH_EFF_STAB_RATIO := 0.5  # effective/raw stability >= bu → sağlıklı adayı
const BUG_RISK_ORTA := 0.5          # canlı hata / toplam karmaşıklık
const BUG_RISK_YUKSEK := 1.5


# --- Koşu sınırı ve kayıt ---

static func reset() -> void:
	# Yeniden başlatma ve yükleme, önceki koşunun DESTEK artığını ve okuma kenarlarını yeni şirkete
	# taşımasın. Kayıttaki gizli hatları RnDSystem geri açar.
	ProductLines.reload()
	SupportSystem.reset()
	ProductRead.reset()


static func to_dict() -> Dictionary:
	# Canlı ürün GameState.flags'teki mvp_* anahtarlarında; burada DESTEK artığı.
	return {"support": SupportSystem.to_dict()}


static func from_dict(d: Dictionary) -> void:
	SupportSystem.from_dict(d.get("support", {}) as Dictionary)


static func daily_tick() -> void:
	# Canlı ürünün haftalık hata örneği; bug_trend() ve health_state() bu pencereyi okur.
	if not ProductState.is_live():
		return
	var hist: Array = GameState.get_flag("mvp_bug_history", [])
	hist.append(int(GameState.get_flag("mvp_live_bug_count", 0)))
	while hist.size() > TimeModel.ticks(BUG_HISTORY_WEEKS):
		hist.pop_front()
	GameState.set_flag("mvp_bug_history", hist)


# --- Meşguliyet ---
# "Kurucu her şeyi yapabilir, ama aynı anda değil." Kural kişi başınadır; meşgul `HRSystem.is_busy`'dir.

## Bu kişi bugün işe girebilir mi.
static func _is_free(c: Character) -> bool:
	return c != null and c.status == HRConstants.STATUS_ACTIVE and not HRSystem.is_busy(c)


## Kurucu ürünün üzerinde mi: iş başında ve yapım alanlarından birine atanmış. Satıştaki ya da
## eğitimdeki kurucu ürünün kalitesine karışmaz.
static func _founder_on_build() -> bool:
	var founder: Character = CharacterRegistry.get_founder()
	if not _is_free(founder):
		return false
	for area_key in HRConstants.JOB_AREAS[HRConstants.JOB_BUILD]:
		if founder.assigned_jobs.has(String(area_key)):
			return true
	return false


## Alanın uzmanlık ortalaması. Ortalama, toplam değil: iyi kurucu + zayıf ekip ortalamayı düşürür.
## Kurucu ürünün üzerindeyse ortalamaya girer, değilse ürünün kalitesine karışmaz.
static func _team_area_avg(area_key: String) -> float:
	var weight_sum: float = 0.0
	var weighted: float = 0.0
	if _founder_on_build():
		weight_sum = FOUNDER_EXPERTISE_WEIGHT
		weighted = FOUNDER_EXPERTISE_WEIGHT * float(GameState.get_founder_skill(area_key))
	for c in HRSystem.assigned_to(area_key):
		if c.category == "founder":
			continue
		weighted += float(int(c.role_stats.get(area_key, 0)))
		weight_sum += 1.0
	return weighted / weight_sum if weight_sum > 0.0 else 0.0


# --- Canlı ürün okumaları ---

## Yayındaki ürünün açık hata sayısı; her açık sürüm sıfırlar (SprintSystem).
static func live_bug_count() -> int:
	return maxi(0, int(GameState.get_flag("mvp_live_bug_count", 0)))


## Ürün B2B mi: tür Ürün sekmesinde seçildiği anda yazılır, kurucu kurumsal iş için o andan
## kadro kurabilir. SalesSystem.is_b2b_market()'ten ("kurumsal masa bugün çalışıyor mu") geniştir.
static func has_b2b_product() -> bool:
	return String(GameState.get_flag("mvp_market_type", "")) == "b2b"


# --- Saatlik tik ---
# Bir tik yedi takvim günü ve 24 saatlik tiktir: takvim saati başına katsayının tikteki payı
# per_tick(katsayı).

## Saatlik tikin kapsadığı saatin tik içindeki başlangıcı (0 ile 23/24). Yalnız saatlik tikte
## geçerlidir: 00:00'ın saatlik tiki devirden önce koşar, o saat biten tikin son saatidir.
static func hour_start_fraction() -> float:
	return float(posmod(GameState.current_hour - 1, TimeModel.HOURS_PER_DAY)) / float(TimeModel.HOURS_PER_DAY)


## Oyuncu eyleminin tik damgası, saat kesriyle: sürüm yaşı eylemin saatinden ölçülür.
static func clock_stamp() -> float:
	return float(GameState.day) + float(GameState.current_hour) / float(TimeModel.HOURS_PER_DAY)


static func hourly_tick(_hour: int) -> void:
	# Aşınma bir dünya olayıdır, iş değil: yayındaki ürün her saat yaşlanır.
	if ProductState.is_live():
		_post_ship_wear_hourly()


## Usage and complexity accrue live bugs hourly; QA expertise reduces the rate but never below
## WEAR_FLOOR. Live wear is the Test area's job (Ekip rev 2 §2).
static func _post_ship_wear_hourly() -> void:
	var audience: float = float(GameState.get_flag("b2c_audience", 0))
	var complexity: int = _shipped_total_complexity()
	var expertise: float = _team_area_avg(HRConstants.AREA_QA)
	var rate: float = maxf(WEAR_FLOOR, audience * WEAR_AUD_COEF + float(complexity) * WEAR_CPLX_COEF
		- expertise * WEAR_TECH_REDUCER)
	var prog: float = float(GameState.get_flag("mvp_live_bug_progress", 0.0)) + TimeModel.per_tick(rate)
	var count: int = int(GameState.get_flag("mvp_live_bug_count", 0))
	while prog >= 1.0:
		count += 1
		prog -= 1.0
	GameState.set_flag("mvp_live_bug_progress", prog)
	GameState.set_flag("mvp_live_bug_count", count)
	EventBus.build_progress_changed.emit()


static func _shipped_total_complexity() -> int:
	var total: int = 0
	for fid in GameState.get_flag("mvp_components", []):
		total += int(ProductCatalog.get_feature_by_id(String(fid)).get("complexity", 0))
	return total


# --- Canlı ürün sağlık türetmeleri: id döner, metni UI çözer ---

static func _bug_trend_delta() -> int:
	# Pencere uçlarının farkı; iki örnekten azsa trend yok.
	var hist: Array = GameState.get_flag("mvp_bug_history", [])
	if hist.size() < 2:
		return 0
	return int(hist[-1]) - int(hist[0])


static func bug_trend() -> String:
	var delta: int = _bug_trend_delta()
	if delta >= TREND_DELTA:
		return "artiyor"
	if delta <= -TREND_DELTA:
		return "azaliyor"
	return "sabit"


static func health_state() -> String:
	var raw: float = float(GameState.get_flag("mvp_stability", 0.0))
	var eff: float = QualityModel.effective_stability(raw, live_bug_count())
	if eff / maxf(raw, 0.001) >= HEALTH_EFF_STAB_RATIO and _bug_trend_delta() < TREND_SPIKE:
		return "saglikli"   # LOC-DATA health band id
	return "riskli"


static func product_bug_risk() -> String:
	var ratio: float = float(live_bug_count()) / float(maxi(1, _shipped_total_complexity()))
	if ratio >= BUG_RISK_YUKSEK:
		return "yuksek"   # LOC-DATA risk band id
	if ratio >= BUG_RISK_ORTA:
		return "orta"
	return "dusuk"   # LOC-DATA risk band id
