class_name ProductSystem
extends RefCounted

# Ürün yapımı ve canlı ürün. Saf mantık: TimeManager saatlik (hourly_tick) ve günlük (daily_tick,
# slot 1) sürer; durum `active_build` ile GameState.flags'teki mvp_* anahtarlarındadır.
#
# Fazlar: iteration (TASARIM) → development (GELİŞTİRME) → bugfix (BETA) → shipped. İç faz adları
# olay tetikleri, PromiseRegistry ve capacity_demand tarafından okunur. Her faz geçişi oyuncunun
# kararıdır (enter_development, enter_beta, launch): dolu bir bar parkta bekler, süre ve burn akar.
#
# İki yapım yolu var:
# - Hat modeli (start_line_build, Ürün rev 6.1 §5-§12) — oyunun yolu. TASARIM turları EforTavanı'nın
#   üstüne binen ayrı bir sayaç yakar, GELİŞTİRME barı tavanın %100'üne dolar, hatalar harcanan
#   eforla doğar, eksenler yayında hat durumlarından türetilir.
# - Düz katalog (start_build / start_version_build) — smoke ve probe fikstürlerinin yolu. Efor tek
#   sayaçta üç banda bölünür, TASARIM turları kendiliğinden zincirlenip eksenleri ekip tavanlarına
#   doğru büyütür, eksenler commit'te damgalanır.
#
# Yayında kalan açık hatalar mvp_live_bug_count'a taşınır; canlı aşınma ve memnuniyet oradan okur.

# --- Yapım hızı (düz yol) ---
# hız = (FOUNDER_SPEED_COEF × kurucunun faz alanı puanı + EMPLOYEE_SPEED_COEF × Σ faz ekibinin katkısı)
#       × sorumlunun koordinasyon çarpanı. Aynı cetvelde kurucunun puanı çalışanınkinin iki katı sayılır.
const FOUNDER_SPEED_COEF := 0.5
const EMPLOYEE_SPEED_COEF := 0.25
const SPEED_MIN := 1.0              # HIZ-0 ekip bile günde 1 efor ilerler
const STRENGTHEN_EFOR := 5          # bir güçlendirme seçiminin eforu (~orta feature)
const STRENGTHEN_AXIS_BONUS := 4.0  # güçlendirilen feature'ın baskın eksenine düz bonus
const STRENGTHEN_MAX_PER_VERSION := 2
# Ekibin Tasarım katkısı commit'te Deneyim'e bonus olarak girer; tavan terime uygulanır. Yüksek
# kaldıraç: v1 kompozitleri ~7-12'de oturur, +3 normalize kalitede ~%10-15 eder.
const PM_EXPERIENCE_PER_POINT := 0.5
const PM_EXPERIENCE_CAP := 3.0

# --- Faz bantları ve TASARIM turları (düz yol) ---
const PHASE_DESIGN_END := 0.20      # TASARIM [0, 0,20) — tur 1 bu bandın kendisidir
const PHASE_DEV_END := 0.80         # GELİŞTİRME [0,20, 0,80) · BETA [0,80, 1,0]
# Tur 1 dolunca turlar kendiliğinden zincirlenir. Her ek tur ITER_ROUND_DAYS takvim günü sürer
# (ekip hızından bilinçli bağımsız: bedeli "N gün" olarak okunur) ve sonunda eksenleri büyütür.
# ITER_MAX_ROUNDS'ta park eder; azalan getiri dördün ötesini ödüllendirmez.
const ITER_ROUND_DAYS := 4
const ITER_MAX_ROUNDS := 4
# Eksen tavanı = ITER_CEIL_FOUNDER_COEF × kurucunun eksen alanındaki puanı
#              + min(ekibin o alandaki katkısı × ITER_CEIL_ROLE_COEF, ITER_CEIL_ROLE_CAP).
# Çapalar: alan puanı 4 olan solo kurucu → 8 (cilalar, elite'e iteremez); + Tasarım 7 → 22.
const ITER_CEIL_FOUNDER_COEF := 2.0
const ITER_CEIL_ROLE_COEF := 2.0
const ITER_CEIL_ROLE_CAP := 18.0
# Hangi alan hangi eksenin tavanını yükseltir (Ekip rev 2 §2).
const ITER_CEIL_AXIS_AREA := {
	"innovation": "product",
	"stability": "engineering",
	"experience": "design",
}
# Tur başına ham kazanç (QualityModel.grow): İnovasyon birincil, diğer ikisi de sıfır değil.
const ITER_ROUND_RAW := {"innovation": 3.0, "stability": 1.0, "experience": 1.0}

# --- Ürün rev 6.1 §5 · cila merdiveni (MÜHÜRLÜ) ---
# Tamamlanan TASARIM turu → sürümün gerçekleşme çarpanı. Tamamlanmış tasarım ödül değildir, eksik
# tasarım tavanı düşürür: taban 1 turda ×1,00. Üç ek tur eforun %24'ünü yakar ve %15 verir, yani
# "hep 4 tur" otomatik doğru cevap değildir.
const DESIGN_TURN_MULT := {0: 0.75, 1: 1.00, 2: 1.06, 3: 1.11, 4: 1.15}
const DESIGN_TURN_MAX := 4
## Her TASARIM turunun yaktığı efor, EforTavanı'nın oranı olarak (§5).
const DESIGN_TURN_COST := 0.08

# --- Ürün rev 6.1 §6 · efor modeli (hat yolu) ---
# kişinin günlük katkısı = HRSystem.effective_skill × saat/8; yapım hızı = Σ taşıyıcılar × liderlik
# × K_EFOR. İkinci bir hız formülü yoktur: alan, odak, moral, liderlik ve huy çarpanları Ekip §4.5'te.
## §6.1 [K] — saat/8 normalizasyonunun katsayısı: skill × (h/8) × (8/12) ≡ skill × h/12.
const K_EFOR := 8.0 / 12.0
## §6.3 [K] — hata/efor = clamp(tavan − 0,05 × ekibin etkin Yazılım ortalaması, 0,10, tavan).
## Ar-Ge `cicd` düğümü yalnız tavanı 0,45 → 0,35'e indirir (Ar-Ge §4.3 · §13).
const BUG_RATE_CEIL := 0.45
const BUG_RATE_CEIL_RESEARCHED := 0.35
const BUG_RATE_FLOOR := 0.10
const BUG_RATE_SKILL_COEF := 0.05

# --- Hatalar (düz yol) ---
# GELİŞTİRME'de saatlik oran = max(BUG_FLOOR, Σkarmaşıklık × COEF − Yazılım uzmanlığı × REDUCER):
# karmaşık ürün + zayıf ekip = hata yağmuru, sade + güçlü ekip = az ama sıfır değil.
const BUG_COMPLEXITY_COEF := 0.006
const BUG_TECH_REDUCER := 0.005
const BUG_FLOOR := 0.010
const TECH_DEBT_BUG_PENALTY := 5    # olaylarda alınan teknik borç BETA girişinde hataya döner
# Commit'te her YENİ feature karmaşıklığı kadar hata tohumlar; sertleştirme sürümü tohum atmaz.
const FEATURE_BUG_SEED_COEF := 1.0
# Yazılım'a atanmış çalışanların uzmanlık ortalaması tohumu oynatır: PIVOT'ta ×1,0, puan başına
# ±%12. Yazılım'a atanmış çalışan yoksa da ×1,0.
const SEED_EXPERTISE_PIVOT := 5.0
const SEED_EXPERTISE_SLOPE := 0.12
const SEED_EXPERTISE_MULT_MIN := 0.5
const SEED_EXPERTISE_MULT_MAX := 1.6
# Hata/aşınma uzmanlık ortalamasında sorumlunun ağırlığı. Solo kurucu sorumluyken ortalama kurucunun
# kendi puanıdır, bu yüzden BUG_TECH_REDUCER / WEAR_TECH_REDUCER ölçeklenmez.
const LEAD_EXPERTISE_WEIGHT := 1.5
const MEMBER_EXPERTISE_WEIGHT := 1.0
# "Bırak, gönder" (ev_mvp_bugfix_001_critical_bug) seçildiyse yayında eklenen hata.
const CRITICAL_BUG_LAUNCH_PENALTY := 5

# --- BETA: test gizli hataları bulur, bulunanları çözer ---
## §7 [K] — günlük keşif = BETA_BUG_FIND_PER_DAY × sönüm^(beta günü). Ar-Ge `test_automation`
## düğümü sönümü 0,85 → 0,90'a çeker (Ar-Ge §4.3 · §13).
const BETA_BUG_FIND_PER_DAY := 6.0
const BETA_FIND_DECAY := 0.85
const BETA_FIND_DECAY_RESEARCHED := 0.90
const POLISH_BUG_FIX_PER_DAY := 4   # BETA'da günlük çözülen hata
# Test alanı bulma isabetini ve bulma/çözme temposunu artırır, hata sprintini kısaltır. Test'e
# kimse atanmamışsa çarpanlar ×1,0.
const TESTER_FIND_PER_EXPERTISE := 0.08
const TESTER_FIND_MULT_MAX := 1.8
const TESTER_TEMPO_PER_PACE := 0.05
const TESTER_TEMPO_MULT_MAX := 1.6
const TESTER_SPRINT_PER_EXPERTISE := 0.06

# İptalin ilk günü bedelsizdir (yanlış tık affı); sonrasında onay yanan gün ve parayı söyler.
const CANCEL_FREE_DAYS := 1

# --- Canlı ürün ---
# Aşınma: kullanıcı ve karmaşıklık saatlik hata biriktirir; Test uzmanlığı düşürür ama WEAR_FLOOR'un
# altına indiremez. İhmal edilen ürün hatayı günler içinde biriktirir.
const WEAR_AUD_COEF := 0.00004       # kullanıcı başına / saat
const WEAR_CPLX_COEF := 0.0012       # toplam karmaşıklık puanı başına / saat
const WEAR_TECH_REDUCER := 0.005
const WEAR_FLOOR := 0.002
# Hata sprinti canlı hataları birkaç günde temizler; süre hata sayısıyla ölçeklenir.
const SPRINT_BUG_FIX_PER_DAY := 4
const MIN_SPRINT_DAYS := 1
const MAX_SPRINT_DAYS := 7
# Ürün Detayı sağlık ve trend türetmeleri.
const BUG_HISTORY_DAYS := 7         # mvp_bug_history penceresi (günlük örnek)
const TREND_DELTA := 2              # |son − ilk| >= bu → artıyor/azalıyor, altı sabit
const TREND_SPIKE := 4              # keskin artış → sağlık riskli
const HEALTH_EFF_STAB_RATIO := 0.5  # effective/raw stability >= bu → sağlıklı adayı
const BUG_RISK_ORTA := 0.5          # canlı hata / toplam karmaşıklık
const BUG_RISK_YUKSEK := 1.5

const HOURS_PER_BUILD_DAY := 24     # efor ve hatalar saatlik birikir (günlük oran / 24)
# Kapasite = kurucu + ürün kadrosu. Sprint ve build birer kapasite ister; talep aşarsa ikisi de
# orantılı yavaşlar (capacity_speed_factor).
const CAPACITY_BASE := 1

# Hangi fazı hangi alanlar taşır. Kişi fazın alanlarından en güçlü olduğuyla katılır; odada kimin
# olduğunu iş ataması belirler, ünvan değil (Ekip rev 2 §4).
const PHASE_AREAS := {
	"iteration": ["product", "design"],
	"development": ["engineering"],
	"bugfix": ["qa", "engineering"],
}
# §2 — oto-duraklama bildirilen bir durumdur ve cümleyle konuşur; manuel duraklama oyuncunun
# kararıdır ve glifle görünür. İkisi bir arada görünmez.
const PAUSE_NONE := ""
const PAUSE_AUTO := "auto"
const PAUSE_MANUAL := "manual"

static var active_build: FeatureBuild = null


## §5 — sürümün her kademesine damgalanan gerçekleşme çarpanı. Tavanın üstü tavanı, sıfırın altı
## acele değerini okur.
static func design_turn_mult(turns_completed: int) -> float:
	return float(DESIGN_TURN_MULT[clampi(turns_completed, 0, DESIGN_TURN_MAX)])


# --- Koşu sınırı ve kayıt ---

static func reset() -> void:
	# Yeniden başlatma ve yükleme, önceki koşunun build'ini ve DESTEK'in statik kesir artığını
	# yeni şirkete taşımasın.
	active_build = null
	SupportSystem.reset()
	ProductRead.reset()


static func to_dict() -> Dictionary:
	# Canlı ürün GameState.flags'teki mvp_* anahtarlarında; burada yalnız süren build.
	return {"active_build": SaveCodec.res_to_dict(active_build) if active_build != null else null}


static func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	var raw: Variant = d.get("active_build", null)
	active_build = SaveCodec.res_from_dict(raw as Dictionary, FeatureBuild) as FeatureBuild \
		if raw is Dictionary else null


static func daily_tick() -> void:
	# Canlı ürünün günlük hata örneği; bug_trend() ve health_state() bu pencereyi okur.
	if not ProductState.is_live():
		return
	var hist: Array = GameState.get_flag("mvp_bug_history", [])
	hist.append(int(GameState.get_flag("mvp_live_bug_count", 0)))
	while hist.size() > BUG_HISTORY_DAYS:
		hist.pop_front()
	GameState.set_flag("mvp_bug_history", hist)


# --- Kapasite havuzu: tick'ler ve UI süre tahminleri aynı kaynaktan okur ---

static func capacity_total() -> int:
	# Kurucu + iş başındaki ürün kadrosu. İzindeki çalışan sayılmaz; araştıran da sayılmaz (Ar-Ge
	# §5.0): bar "kimse üzerinde değil" derken böleni büyütmek aynı yalanı başka yerde söylemek olurdu.
	var n: int = 0
	for c in CharacterRegistry.get_active_employees():
		if c.assigned_job_ids.has(HRConstants.JOB_RESEARCH):
			continue
		var grp: String = String(HRConstants.ROLE_GROUP.get(c.role, ""))
		if grp == HRConstants.GROUP_PRODUCT_DESIGN or grp == HRConstants.GROUP_DEVELOPMENT:
			n += 1
	return CAPACITY_BASE + n


static func capacity_demand() -> int:
	# BETA kapasite istemez: yapım eforunu Build işi taşır, BETA'yı Test işi taşır ve BETA barı efor
	# ilerletmez (Ürün rev 6.1 §7). VC hazırlığı da talep değildir; kurucuyu meşgul sayar (_is_free).
	var d: int = 0
	if is_sprint_running():
		d += 1
	if active_build != null and active_build.current_phase in ["iteration", "development"]:
		d += 1
	return d


static func capacity_speed_factor() -> float:
	# Her saat taze: işin ortasındaki işe alım hemen etki eder. Talep 2, kapasite 1 → 0,5.
	var d: int = capacity_demand()
	if d <= 0:
		return 1.0
	return minf(1.0, float(capacity_total()) / float(d))


static func projected_speed_factor_with_extra_job() -> float:
	# Onay öncesi önizleme: bu iş de başlarsa hangi hızda koşar ("~3 gün → ~6 gün").
	return minf(1.0, float(capacity_total()) / float(capacity_demand() + 1))


# --- Meşguliyet ve duraklama ---
# "Kurucu her şeyi yapabilir, ama aynı anda değil." Kural kişi başınadır. Meşgul sayılanlar: izinde
# ya da eğitimde olan herkes; VC toplantısına hazırlanan ya da satış masasında oturan kurucu (Satış
# §5.0). VC toplantısının kendisi ve olay modalları zaten ağacı duraklatır.

static func _phase_areas(phase: String) -> Array:
	# Faz dışı (planning) → geliştirme: commit öncesi projeksiyonun varsayılanı.
	return PHASE_AREAS.get(phase, PHASE_AREAS["development"])


## Bu kişi bugün işe girebilir mi. Tek işçi meşgul kurucuysa yapım durur, ekipte boş biri varsa
## akar (Ekip §2.1).
static func _is_free(c: Character) -> bool:
	if c == null or c.status != HRConstants.STATUS_ACTIVE:
		return false
	return not (c.category == "founder" and (GameState.get_flag("pitch_prep_active", false)
		or GameState.get_flag("sales_meeting_active", false)))


## Bu fazı taşıyabilecek herkes, durumuna BAKMADAN. HRSystem.assigned_to STATUS_ACTIVE filtrelediği
## için "kimse yok" ile "herkes meşgul" ancak böyle ayrılır.
static func phase_assignees(phase: String) -> Array[Character]:
	var out: Array[Character] = []
	for area_key in _phase_areas(phase):
		for c in CharacterRegistry.get_all():
			if not out.has(c) and c.category in ["employee", "founder"] \
					and c.assigned_jobs.has(String(area_key)):
				out.append(c)
	return out


## Aktif yapım duruyor mu, hangi türde. Türetilir, saklanmaz: bar her boyamada sorar.
static func pause_kind() -> String:
	if active_build == null or not PHASE_AREAS.has(active_build.current_phase):
		return PAUSE_NONE
	# Manuel önce: bar oyuncunun kendi kararını gösterir, ekibin durumunu değil.
	if active_build.manually_paused:
		return PAUSE_MANUAL
	# §8.4 — düzeltme koşusu aynı ellerin Yazılım çıktısını yapımdan çeker.
	if SupportSystem.fix_run_pauses_build():
		return PAUSE_AUTO
	for c in phase_assignees(active_build.current_phase):
		if _is_free(c):
			return PAUSE_NONE
	return PAUSE_AUTO


static func build_paused() -> bool:
	return pause_kind() != PAUSE_NONE


## §2 — oyuncu her fazda duraklatabilir; ilerleme korunur, sürüm yaşı akmaya devam eder.
static func set_manual_pause(paused: bool) -> void:
	if active_build == null or active_build.manually_paused == paused:
		return
	active_build.manually_paused = paused
	EventBus.build_progress_changed.emit()


## §3 — lider yapım sürerken ayrılırsa yapım lidersiz sürer (çarpan 1,0) ve bar not düşer.
static func lead_missing() -> bool:
	if active_build == null or active_build.lead_engineer_id == "":
		return false
	var lead: Character = CharacterRegistry.get_character(active_build.lead_engineer_id)
	return lead == null or lead.status != HRConstants.STATUS_ACTIVE


## Oto-duraklamanın sebep cümlesi; kişi adı geçmez. Manuel duraklama cümle değil glif taşır (§2):
## oyuncunun kendi kararını bir arıza gibi göstermesin.
static func pause_note_key() -> String:
	if pause_kind() != PAUSE_AUTO:
		return ""
	if SupportSystem.fix_run_pauses_build():
		return "BUILD_BUSY_FIX_RUN"
	# Araştırma kendi cümlesini taşır (Ar-Ge §5.0). Kurucu ayrıca sorulur: araştırmaya geçince alan
	# aynası boşalır ve phase_assignees onu artık görmez.
	var crew: Array[Character] = phase_assignees(active_build.current_phase)
	var founder: Character = CharacterRegistry.get_founder()
	var researching: bool = founder != null and founder.assigned_job_ids.has(HRConstants.JOB_RESEARCH)
	for c in crew:
		researching = researching or c.assigned_job_ids.has(HRConstants.JOB_RESEARCH)
	if researching:
		return "BUILD_BUSY_RESEARCH"
	if crew.is_empty():
		return "BUILD_BUSY_NOBODY"
	return "BUILD_BUSY_ELSEWHERE"


static func phase_label_key() -> String:
	if active_build == null:
		return "BUILD_PHASE_SUPPORT" if ProductState.is_live() else ""
	match active_build.current_phase:
		"iteration": return "BUILD_PHASE_DESIGN"
		"development": return "BUILD_PHASE_DEVELOPMENT"
		"bugfix": return "BUILD_PHASE_BETA"
		_: return ""


## Yavaşlayan barın notu (Ekip §12.1): iki iş taşıyan her işe 0,50 verir. Not yalnız bölünmeyi
## söyler; moral bedeli kurucuya işlemediği için (Ekip §4.5) barda iddia edilmez.
static func split_note_key() -> String:
	if active_build == null or not PHASE_AREAS.has(active_build.current_phase):
		return ""
	for c in phase_assignees(active_build.current_phase):
		if HRSystem.is_overloaded(c):
			return "BUILD_SPLIT_FOCUS"
	return ""


static func lead_note_key() -> String:
	return "BUILD_NO_LEAD" if lead_missing() else ""


## §3 — oyuncu yeni lider atayabilir. Liderlik yalnız bugünkü hıza girer, yani lideri değiştirmek
## dünkü ilerlemeye dokunmaz. Boş dize lidersiz yapımdır (çarpan 1,0).
static func set_build_lead(lead_id: String) -> void:
	if active_build == null or active_build.lead_engineer_id == lead_id:
		return
	active_build.lead_engineer_id = lead_id
	EventBus.build_progress_changed.emit()


# --- Canlı ürün okumaları ---

## Yayındaki ürünün açık hata sayısı.
static func live_bug_count() -> int:
	return maxi(0, int(GameState.get_flag("mvp_live_bug_count",
		GameState.get_flag("mvp_bug_count_at_launch", 0))))


static func is_sprint_running() -> bool:
	return bool(GameState.get_flag("mvp_bug_sprint_active", false))


# --- Ekip hızı (düz yol) ---

## Kurucuyu aktif fazın alanına oturtur. Oyuncunun kurucuyu atayacak bir kapısı yok, ama hız, kalite
## ortalaması ve eksen tavanı atamayı okur; tek yazar burası (tek alan kilidi, ch. 02 §5).
static func _reseat_founder(phase: String) -> void:
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null or not PHASE_AREAS.has(phase):
		return
	# Araştıran (Ar-Ge §5.0) ya da destek masasındaki kurucuya dokunulmaz: ataması faz sınırında
	# sessizce silinir, masa dolu görünürken üretim sıfıra düşerdi. İşten kalkınca bir sonraki faz
	# geçişinde yerine oturur.
	if founder.assigned_job_ids.has(HRConstants.JOB_RESEARCH) \
			or founder.assigned_job_ids.has(HRConstants.JOB_SUPPORT):
		return
	var area: String = _founder_phase_area(phase)
	if founder.assigned_jobs.has(area) and founder.assigned_jobs.size() == 1:
		return
	CharacterRegistry.clear_areas(founder.id)
	var refusal: String = CharacterRegistry.assign_area(founder.id, area)
	if refusal != "":
		push_error("[ProductSystem] founder refused '%s' for phase '%s': %s" % [area, phase, refusal])


## Kurucu bu sürümün üzerinde mi: iş başında ve build alanlarından birine atanmış. Satıştaki ya da
## eğitimdeki kurucu ne hıza ne tavana dokunur.
static func _founder_on_build() -> bool:
	var founder: Character = CharacterRegistry.get_founder()
	if not _is_free(founder):
		return false
	for area_key in HRConstants.JOB_AREAS[HRConstants.JOB_BUILD]:
		if founder.assigned_jobs.has(String(area_key)):
			return true
	return false


## Kurucunun bu faza girdiği alan: atandığı faz alanı, yoksa fazın ilk alanı.
static func _founder_phase_area(phase: String) -> String:
	var areas: Array = _phase_areas(phase)
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null:
		for area_key in areas:
			if founder.assigned_jobs.has(String(area_key)):
				return String(area_key)
	return String(areas[0])


## Bu fazın alanlarından birine atanmış herkes ve katıldığı alan (fazın alanları içinde en güçlü
## olduğu). Kişi bir kez sayılır: iki faz alanına birden atanmak ödül olmasın, bedelini odak keser.
static func _phase_crew(phase: String) -> Array:
	var best: Dictionary = {}   # id → {"c", "area"}
	for area_key in _phase_areas(phase):
		var area: String = String(area_key)
		for c in HRSystem.assigned_to(area):
			if not best.has(c.id) or int(c.role_stats.get(area, 0)) \
					> int(c.role_stats.get(String(best[c.id]["area"]), 0)):
				best[c.id] = {"c": c, "area": area}
	return best.values()


static func _lead_coordination(lead_id: String) -> float:
	# Koordinasyon çarpanı sorumlunun Liderlik'inden. Kurucu nötr-sıfırda eğrisini korur (varsayılan
	# sorumlu ceza olmamalı); seçilmiş çalışan iki yönlü eğriyi alır. Ayrılmış ya da izindeki sorumlu
	# açıkça kurucu-sorumlu olarak çözülür.
	var lead: Character = CharacterRegistry.get_character(lead_id)
	if lead != null and lead.category == "employee" and lead.status == HRConstants.STATUS_ACTIVE:
		return HRConstants.coordination_for_lead(
			int(lead.role_stats.get(HRConstants.SKILL_LEADERSHIP, 0)), false)
	return HRConstants.coordination_for_founder(GameState.get_founder_skill("leadership"), false)


## Faz ekibindeki çalışanların (kurucu hariç) katkı toplamı. Sorumlu ağırlıksız bir üyedir; etkisi
## koordinasyon çarpanındadır. Katkı Ekip §4.5 + §8.4'ün seam'inden gelir.
static func _phase_area_sum(phase: String, _lead_id: String) -> float:
	var total: float = 0.0
	for row in _phase_crew(phase):
		var c: Character = row["c"]
		if c.category != "founder":
			total += HRSystem.daily_contribution(c, String(row["area"]))
	return total


static func _speed_for_phase(phase: String, lead_id: String) -> float:
	var speed: float = 0.0
	if _founder_on_build():
		# Kurucu terimi Ekip seam'inin dışında hesaplandığı için saat oranını (§8.3) ve odak
		# bölünmesini (Ekip §4.5) burada alır; çalışan terimi ikisini daily_contribution'da taşır.
		var founder: Character = CharacterRegistry.get_founder()
		speed = FOUNDER_SPEED_COEF * float(GameState.get_founder_skill(_founder_phase_area(phase))) \
			* HRConstants.hours_output_mult(WorkHoursSystem.hours_for(founder)) \
			* HRConstants.focus_mult(HRSystem.job_count(founder))
	speed += EMPLOYEE_SPEED_COEF * _phase_area_sum(phase, lead_id)
	return maxf(SPEED_MIN, speed * _lead_coordination(lead_id))


## Faz duyarlı ve her çağrıda taze: aynı ekip TASARIM'da ve GELİŞTİRME'de farklı hızda koşar.
static func team_speed(b: FeatureBuild) -> float:
	return _speed_for_phase(b.current_phase, b.lead_engineer_id)


## Bir alana atanmış çalışanların (kurucu hariç) katkı toplamı.
static func _build_area_sum(area_key: String) -> float:
	var total: float = 0.0
	for c in HRSystem.assigned_to(area_key):
		if c.category != "founder":
			total += HRSystem.daily_contribution(c, area_key)
	return total


## Alanın uzmanlık ortalaması, sorumlu ağırlıklı. Ortalama, toplam değil: iyi kurucu + zayıf ekip
## ortalamayı düşürür. Kurucu build'deyse ortalamaya girer, değilse ürünün kalitesine karışmaz.
static func _team_area_avg(area_key: String, lead_id: String) -> float:
	var weight_sum: float = 0.0
	var weighted: float = 0.0
	if _founder_on_build():
		var founder_id: String = CharacterRegistry.get_founder().id
		weight_sum = LEAD_EXPERTISE_WEIGHT if lead_id in ["", "founder", founder_id] \
			else MEMBER_EXPERTISE_WEIGHT
		weighted = weight_sum * float(GameState.get_founder_skill(area_key))
	for c in HRSystem.assigned_to(area_key):
		if c.category == "founder":
			continue
		var w: float = LEAD_EXPERTISE_WEIGHT if c.id == lead_id else MEMBER_EXPERTISE_WEIGHT
		weighted += w * float(int(c.role_stats.get(area_key, 0)))
		weight_sum += w
	return weighted / weight_sum if weight_sum > 0.0 else 0.0


# --- Ürün rev 6.1 §6 · hat yolunun hızı ve hatası ---

## §6.2 — kişi build'e üç build alanından en verimli olduğuyla katkı verir. Test build taşımaz;
## katkısı BETA'dadır (§7).
static func build_carrier_area(c: Character) -> String:
	var best_area := ""
	var best: float = 0.0
	for area in HRConstants.JOB_AREAS[HRConstants.JOB_BUILD]:
		var v: float = HRSystem.effective_skill(c, String(area))
		if v > best:
			best = v
			best_area = String(area)
	return best_area


## Build işine atanmış olanlar; ünvan kapı açmaz, atama açar (Ekip §12.0).
static func build_carriers() -> Array[Character]:
	return HRSystem.assigned_to_job(HRConstants.JOB_BUILD)


## §6.1 — yapım hızı, efor/gün. Kurucu herkes gibi sayılır.
static func build_effort_per_day(lead_id: String = "") -> float:
	var total: float = 0.0
	for c in build_carriers():
		var area: String = build_carrier_area(c)
		if area != "":
			total += HRSystem.daily_contribution(c, area)
	# Ekip §4.2: liderlik alanın toplamına uygulanır. §3: iş başında olmayan lider çarpan vermez.
	var lead: Character = CharacterRegistry.get_character(lead_id)
	var leadership: int = 0
	if lead != null and lead.status == HRConstants.STATUS_ACTIVE:
		leadership = HRSystem.skill(lead, HRConstants.SKILL_LEADERSHIP)
	return total * HRSystem.leadership_output_mult(leadership) * K_EFOR


## §6.3 — hatalar GELİŞTİRME'de harcanan eforla birikir; etkin Yazılım ortalaması oranı düşürür ama
## BUG_RATE_FLOOR'un altına indiremez.
static func line_bug_rate_per_effort() -> float:
	var ceil_now: float = BUG_RATE_CEIL_RESEARCHED if ResearchSeam.completed("cicd") else BUG_RATE_CEIL
	var carriers: Array[Character] = build_carriers()
	if carriers.is_empty():
		return ceil_now
	var sum: float = 0.0
	for c in carriers:
		sum += HRSystem.effective_skill(c, HRConstants.AREA_ENGINEERING)
	var avg: float = sum / float(carriers.size())
	return clampf(ceil_now - BUG_RATE_SKILL_COEF * avg, BUG_RATE_FLOOR, ceil_now)


static func tester_find_mult() -> float:
	return minf(1.0 + HRSystem.area_sum_for(HRConstants.AREA_QA) * TESTER_FIND_PER_EXPERTISE,
		TESTER_FIND_MULT_MAX)


static func tester_tempo_mult() -> float:
	return minf(1.0 + HRSystem.area_sum_for(HRConstants.AREA_QA) * TESTER_TEMPO_PER_PACE,
		TESTER_TEMPO_MULT_MAX)


# --- Süre: "~N gün"ün tek kaynağı ---

static func estimated_days_remaining(b: FeatureBuild) -> int:
	var rate: float = team_speed(b) * capacity_speed_factor()
	return int(ceil(maxf(0.0, b.total_efor - b.efor_spent) / maxf(0.01, rate)))


## Düz yolun commit öncesi projeksiyonu. GELİŞTİRME hızıyla: eforun %60'ı o bantta ve en uzun faz o.
static func estimate_build_days(new_ids: Array, strengthen_ids: Array, sorumlu_id: String) -> int:
	var total: float = float(ProductCatalog.sum_efor(new_ids) + STRENGTHEN_EFOR * strengthen_ids.size())
	if total <= 0.0:
		return 0
	var rate: float = _speed_for_phase("development", sorumlu_id) * projected_speed_factor_with_extra_job()
	return int(ceil(total / maxf(0.01, rate)))


static func build_progress() -> float:
	if active_build == null or active_build.total_efor <= 0.0:
		return 0.0
	return clampf(active_build.efor_spent / active_build.total_efor, 0.0, 1.0)


# --- Hat modelinin TASARIM okumaları (§5) ---

## Plan doluysa hat modeli; düz yol planı boş bırakır.
static func is_line_build() -> bool:
	return active_build != null and not active_build.planned_step_ids.is_empty()


## Bir TASARIM turunun efor maliyeti; EforTavanı'nın üstüne biner.
static func design_turn_cost() -> float:
	return 0.0 if active_build == null else DESIGN_TURN_COST * active_build.total_efor


## Koşan turun dolumu 0-1.
static func design_turn_progress() -> float:
	if not is_line_build():
		return 0.0
	var cost: float = design_turn_cost()
	if cost <= 0.0:
		return 0.0
	var into: float = active_build.design_efor_spent - float(active_build.design_turns_completed) * cost
	return clampf(into / cost, 0.0, 1.0)


## "Geliştirmeye geç" ilk günden basılabilir, ama tur 1 dolmadıysa onay ister.
static func needs_design_confirm() -> bool:
	return is_line_build() and active_build.current_phase == "iteration" \
		and active_build.design_turns_completed < 1


static func design_turns_maxed() -> bool:
	return is_line_build() and active_build.design_turns_completed >= DESIGN_TURN_MAX


# --- Saatlik tik ---

static func hourly_tick(_hour: int) -> void:
	# Kapasite çarpanı işin tüm saatlik çıktısına uygulanır (efor, hata, beta): tek başına koşan işin
	# toplam çıktısı aynı kalır, paralel işler aynı çıktıyı daha uzun süreye yayar.
	var f: float = capacity_speed_factor()
	# Canlı sürüm build'den bağımsız yaşar. Sprint sürerken canlı hataların tek yazarı sprinttir.
	# Aşınma bir dünya olayıdır, iş değil; çarpan almaz.
	if ProductState.is_live():
		if is_sprint_running():
			_tick_live_sprint_hourly(f)
		else:
			_post_ship_wear_hourly()
	if active_build == null or not PHASE_AREAS.has(active_build.current_phase):
		return
	if is_line_build():
		_tick_line_build_hourly(f)
	else:
		_tick_build_hourly(f)
	EventBus.build_progress_changed.emit()


## Hat yolu. TASARIM turları ayrı bir sayaç (design_efor_spent) yakar, GELİŞTİRME barı EforTavanı'nın
## tamamına dolar (§5, §6.0): tasarım geliştirme barından değil runway'den çalar.
static func _tick_line_build_hourly(f: float) -> void:
	var b := active_build
	if build_paused():
		return   # duraklama efor işletmez; süre ve burn akar
	if b.current_phase == "bugfix":
		_tick_beta_hourly(f)   # BETA'yı Test taşır ve efor ilerletmez (§7); Build hızına bağlı değil
		return
	var rate: float = build_effort_per_day(b.lead_engineer_id) * f / float(HOURS_PER_BUILD_DAY)
	if rate <= 0.0:
		return
	if b.current_phase == "iteration":
		var cost: float = design_turn_cost()
		var ceiling: float = cost * float(DESIGN_TURN_MAX)
		if cost <= 0.0 or b.design_efor_spent >= ceiling - 0.0001:
			return   # dört tur doldu; oyuncu geçmeyi seçecek
		b.design_efor_spent = minf(ceiling, b.design_efor_spent + rate)
		b.design_turns_completed = maxi(b.design_turns_completed,
			mini(int(floor(b.design_efor_spent / cost + 0.0001)), DESIGN_TURN_MAX))
	elif b.efor_spent < b.total_efor - 0.0001:   # §6.4 — dolu bar kapıda bekler
		var before: float = b.efor_spent
		b.efor_spent = minf(b.total_efor, b.efor_spent + rate)
		# §6.3 — hatalar harcanan işle doğar, geçen zamanla değil.
		_add_bug_progress(b, line_bug_rate_per_effort() * (b.efor_spent - before))


## Düz yol. Efor bant sınırında taşmadan park eder; ek TASARIM turu koşarken ya da tur tavanında
## efor donuktur. Park ve duraklama süre ve burn yakar, efor ve hata üretmez.
static func _tick_build_hourly(f: float) -> void:
	var b := active_build
	var cap: float = b.total_efor
	match b.current_phase:
		"iteration": cap *= PHASE_DESIGN_END
		"development": cap *= PHASE_DEV_END
	var in_iter_hold: bool = b.current_phase == "iteration" \
		and (b.iteration_decision_pending or b.iteration_round_days > 0.0)
	# Kapı cap'e bakar: fikstürün cap üstüne zorladığı efor aşağı çekilmez.
	var working: bool = b.efor_spent < cap and not in_iter_hold and not build_paused()
	if working:
		# §8.4 — ek mesainin getirisi saatin kendisidir ve team_speed'in içindedir; ayrı bonus yok.
		b.efor_spent = minf(cap, b.efor_spent + team_speed(b) * f / float(HOURS_PER_BUILD_DAY))
	match b.current_phase:
		"iteration":
			if b.iteration_round_days > 0.0:
				# Ek tur takvim ritüelidir: kapasite çarpanı süreyi esnetir, ekip hızı girmez.
				b.iteration_round_days = maxf(0.0, b.iteration_round_days - f / float(HOURS_PER_BUILD_DAY))
				if b.iteration_round_days == 0.0:
					_apply_iteration_round_gains(b)
					_end_round(b)
			elif b.iteration_count == 1 and not b.iteration_decision_pending \
					and b.efor_spent >= PHASE_DESIGN_END * b.total_efor - 0.0001:
				_end_round(b)   # tur 1 = tasarım bandı; dolunca tur 2 hemen başlar
			elif b.iteration_decision_pending and b.iteration_count < ITER_MAX_ROUNDS:
				_start_next_round(b)   # tavan altındaki park yalnız kayıttan gelebilir; kendiliğinden çözülür
		"development":
			if working:
				_accrue_bugs_hourly(f)   # parkta kimse kod yazmıyor, hata da doğmuyor
		"bugfix":
			_tick_beta_hourly(f)


# --- TASARIM turları (düz yol) ---

## Eksen başına tur kazancı tavanı: kaç tur döndüğün değil kimin çalıştığı belirler. O alanda kimse
## yoksa tavan kurucunun tabanıdır; build'de olmayan kurucu tavanı yükseltmez.
static func iteration_axis_ceilings() -> Dictionary:
	var founder: Character = CharacterRegistry.get_founder()
	var on_build: bool = _founder_on_build()
	var out := {}
	for ax in QualityModel.AXES:
		var area_key: String = String(ITER_CEIL_AXIS_AREA[ax])
		var founder_pts: int = int(founder.role_stats.get(area_key, 0)) if on_build else 0
		out[ax] = ITER_CEIL_FOUNDER_COEF * float(founder_pts) \
			+ minf(_build_area_sum(area_key) * ITER_CEIL_ROLE_COEF, ITER_CEIL_ROLE_CAP)
	return out


static func _end_round(b: FeatureBuild) -> void:
	# İlk tur sonunda bir kez öğretici kart (tekliği kartın one_shot'ı taşır): turlar kendiliğinden
	# döner, "yeter" demek oyuncudadır.
	EventGate.request("product.design_round_intro")
	if b.iteration_count < ITER_MAX_ROUNDS:
		_start_next_round(b)
	else:
		# Tavan parkı: tek çıkış enter_development().
		b.iteration_decision_pending = true
		EventBus.build_iteration_decision_pending.emit(true)


static func _start_next_round(b: FeatureBuild) -> void:
	# Kazanç tur SONUNDA uygulanır. pending(false) kayıttan gelen parkın dinleyicilerini de temizler.
	b.iteration_count += 1
	b.iteration_round_days = float(ITER_ROUND_DAYS)
	b.iteration_decision_pending = false
	EventBus.build_iteration_decision_pending.emit(false)


## Her eksen kendi tavanına doğru azalan getiriyle büyür (grow asimptotik; tavan üstündeki damga geri
## alınmaz). Tavan yalnız tur kazançlarını bağlar; commit damgası ve olay delta'ları serbesttir.
static func _apply_iteration_round_gains(b: FeatureBuild) -> void:
	var ceilings: Dictionary = iteration_axis_ceilings()
	for ax in QualityModel.AXES:
		var ceiling: float = float(ceilings[ax])
		if ceiling > 0.0:   # grow'un böleni
			b.set(ax, QualityModel.grow(float(b.get(ax)), float(ITER_ROUND_RAW[ax]), ceiling))


# --- Faz geçişleri (oyuncu kararları) ---

## TASARIM'dan çıkış. Hat modelinde ilk günden açıktır: acele etmenin bedeli kilit değil cila
## çarpanıdır (×0,75, §5) ve onay diyaloğunda okunur. Düz yolda tur 1 bitince açılır; koşan yarım tur
## kazançsız terk edilir.
static func can_enter_development() -> bool:
	if active_build == null or active_build.current_phase != "iteration":
		return false
	return is_line_build() or active_build.iteration_count >= 2 or active_build.iteration_decision_pending


static func enter_development() -> void:
	if not can_enter_development():
		push_warning("[ProductSystem] enter_development before the first design round ended")
		return
	var b := active_build
	b.iteration_decision_pending = false
	b.iteration_round_days = 0.0
	b.current_phase = "development"
	EventBus.build_iteration_decision_pending.emit(false)
	_reseat_founder("development")
	EventBus.build_phase_changed.emit("development")


## §6.4 — GELİŞTİRME %100 olmadan BETA'ya geçilemez. Teknik borç demo dışı olduğu için (§1) eksik
## geliştirme cezalandırılamaz; cezalandırılamayan erken geçiş yasaklanır. Hat modelinde bar
## EforTavanı'nın tamamına dolar (§6.0), düz yolda geliştirme bandı PHASE_DEV_END'de biter.
static func can_enter_beta() -> bool:
	if active_build == null or active_build.current_phase != "development":
		return false
	var band_end: float = active_build.total_efor if is_line_build() \
		else PHASE_DEV_END * active_build.total_efor
	return active_build.efor_spent >= band_end - 0.0001


static func development_band_complete() -> bool:
	return can_enter_beta()


static func enter_beta() -> void:
	if not can_enter_beta():
		push_warning("[ProductSystem] enter_beta outside the development phase")
		return
	var b := active_build
	if GameState.get_flag("tech_debt_birikti", false):
		b.bug_count += TECH_DEBT_BUG_PENALTY
		GameState.set_flag("tech_debt_birikti", false)
	b.current_phase = "bugfix"
	# Geliştirmenin hataları bug_count'ta gizli havuz olarak durur; test onları bulur.
	b.bugs_found = 0
	b.bugs_fixed = 0
	b.bug_find_progress = 0.0
	b.bug_fix_progress = 0.0
	# §7 — keşif sönümü BETA'da geçen günü okur, yapımın yaşını değil.
	b.beta_entered_day = GameState.day
	# BETA barının paydası.
	GameState.set_flag("bug_count_at_bugfix_start_%s" % b.id, b.bug_count)
	_reseat_founder("bugfix")
	EventBus.build_phase_changed.emit("bugfix")


# --- Hatalar ---

## BETA: test gizli hataları bulur, bulunanları çözer; ikisi de kendiliğinden, oyuncunun kararı ne
## kadar bekleyeceği. Gizli = bug_count − (bulunan − çözülen); çözüm bug_count'u düşürür.
static func _tick_beta_hourly(f: float) -> void:
	var b := active_build
	var hidden: int = b.bug_count - (b.bugs_found - b.bugs_fixed)
	# §7 — keşif keskin azalır ve havuz tükenmez: beklemek kaybedilen bir yarıştır ve "9 açık hatayla
	# yayınlamak" gerçek bir karardır. "Yayınlamak test etmekten hızlı hata bulur."
	var decay: float = BETA_FIND_DECAY_RESEARCHED if ResearchSeam.completed("test_automation") \
		else BETA_FIND_DECAY
	var beta_day: int = maxi(0, GameState.day - b.beta_entered_day)
	var find_rate: float = BETA_BUG_FIND_PER_DAY * pow(decay, float(beta_day)) \
		* tester_find_mult() * tester_tempo_mult()
	b.bug_find_progress += find_rate * f / float(HOURS_PER_BUILD_DAY)
	while b.bug_find_progress >= 1.0:
		if hidden > 0:
			hidden -= 1
		else:
			b.bug_count += 1   # havuz tükenmez; BETA satırı bu yüzden yüzde taşımaz (§7, MÜHÜRLÜ)
		b.bugs_found += 1
		b.bug_find_progress -= 1.0
	if b.bugs_found - b.bugs_fixed > 0:
		b.bug_fix_progress += float(POLISH_BUG_FIX_PER_DAY) * tester_tempo_mult() * f / float(HOURS_PER_BUILD_DAY)
		while b.bug_fix_progress >= 1.0 and b.bugs_found - b.bugs_fixed > 0:
			b.bugs_fixed += 1
			b.bug_count -= 1
			b.bug_fix_progress -= 1.0
	b.bug_count = maxi(0, b.bug_count)


## Düz yolun GELİŞTİRME hatası. §8.4: ek mesai hata cezası taşımaz; bedeli nakit ve moraldir.
static func _accrue_bugs_hourly(f: float) -> void:
	var b := active_build
	var expertise: float = _team_area_avg(HRConstants.AREA_ENGINEERING, b.lead_engineer_id)
	var rate: float = maxf(BUG_FLOOR,
		float(b.get_total_complexity()) * BUG_COMPLEXITY_COEF - expertise * BUG_TECH_REDUCER)
	# Yazılım'daki her TİTİZ oranı çarpımsal düşürür: iki TİTİZ birinden iyidir, getiri azalarak.
	for c in HRSystem.assigned_to(HRConstants.AREA_ENGINEERING):
		rate *= HRConstants.trait_mult(c.traits, "bug_rate_mult")
	_add_bug_progress(b, maxf(BUG_FLOOR, rate) * f)


static func _add_bug_progress(b: FeatureBuild, amount: float) -> void:
	b.bug_progress += amount
	while b.bug_progress >= 1.0:
		b.bug_count += 1
		b.bug_progress -= 1.0


## "Yeni feature = yeni bug": commit'te her feature karmaşıklığı kadar hata tohumlar.
static func _seed_feature_bugs(feature_ids: Array) -> int:
	var mult: float = 1.0
	var skill_sum: float = 0.0
	var n: int = 0
	for c in HRSystem.assigned_to(HRConstants.AREA_ENGINEERING):
		if c.category != "founder":
			skill_sum += float(int(c.role_stats.get(HRConstants.AREA_ENGINEERING, 0)))
			n += 1
	if n > 0:
		mult = clampf(1.0 + (SEED_EXPERTISE_PIVOT - skill_sum / float(n)) * SEED_EXPERTISE_SLOPE,
			SEED_EXPERTISE_MULT_MIN, SEED_EXPERTISE_MULT_MAX)
	var seeded: int = 0
	for fid in feature_ids:
		var cx: int = int(ProductCatalog.get_feature_by_id(String(fid)).get("complexity", 0))
		seeded += int(round(float(cx) * FEATURE_BUG_SEED_COEF * mult))
	return seeded


# --- Canlı ürün: aşınma ve hata sprinti ---

## Usage and complexity accrue live bugs hourly; QA expertise reduces the rate but never below
## WEAR_FLOOR. Live wear is the Test area's job, the commit seed is Engineering's (Ekip rev 2 §2).
static func _post_ship_wear_hourly() -> void:
	var audience: float = float(GameState.get_flag("b2c_audience", 0))
	var complexity: int = _shipped_total_complexity()
	var expertise: float = _team_area_avg(HRConstants.AREA_QA, "")
	var rate: float = maxf(WEAR_FLOOR, audience * WEAR_AUD_COEF + float(complexity) * WEAR_CPLX_COEF
		- expertise * WEAR_TECH_REDUCER)
	var prog: float = float(GameState.get_flag("mvp_live_bug_progress", 0.0)) + rate
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


## Sprint süresi başlarken bir kez damgalanır; Test alanı kısaltır.
static func sprint_duration_for(bug_count: int) -> int:
	var rate: float = float(SPRINT_BUG_FIX_PER_DAY) * (1.0
		+ HRSystem.area_sum_for(HRConstants.AREA_QA) * TESTER_SPRINT_PER_EXPERTISE)
	return clampi(int(ceil(float(bug_count) / maxf(0.01, rate))), MIN_SPRINT_DAYS, MAX_SPRINT_DAYS)


## Canlı hataları temizleyen koşu. Build slotu kullanmaz, durumu mvp_sprint_* bayraklarındadır;
## bedeli kapasite havuzudur (build'le paralelse ikisi de yavaşlar).
static func start_bug_sprint() -> bool:
	if is_sprint_running():
		push_warning("[ProductSystem] start_bug_sprint while a sprint is already running")
		return false
	if not ProductState.is_live():
		return false
	var bugs: int = int(GameState.get_flag("mvp_live_bug_count", 0))
	if bugs <= 0:
		return false
	GameState.set_flag("mvp_bug_sprint_active", true)
	GameState.set_flag("mvp_sprint_days_total", sprint_duration_for(bugs))
	GameState.set_flag("mvp_sprint_days_elapsed", 0.0)
	GameState.set_flag("mvp_sprint_fix_progress", 0.0)
	return true


static func _tick_live_sprint_hourly(f: float) -> void:
	var prog: float = float(GameState.get_flag("mvp_sprint_fix_progress", 0.0))
	var count: int = int(GameState.get_flag("mvp_live_bug_count", 0))
	prog -= f * float(SPRINT_BUG_FIX_PER_DAY) / float(HOURS_PER_BUILD_DAY)
	while prog <= -1.0 and count > 0:
		count -= 1
		prog += 1.0
	GameState.set_flag("mvp_sprint_fix_progress", prog)
	GameState.set_flag("mvp_live_bug_count", count)
	GameState.set_flag("mvp_live_bug_progress", 0.0)
	var elapsed: float = float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0)) + f / float(HOURS_PER_BUILD_DAY)
	GameState.set_flag("mvp_sprint_days_elapsed", elapsed)
	if elapsed >= float(GameState.get_flag("mvp_sprint_days_total", 1)):
		GameState.set_flag("mvp_bug_sprint_active", false)
	EventBus.build_progress_changed.emit()


# --- Eksenler (düz yol) ---

## Commit damgası: taban + yeni feature katkıları + güçlendirme bonusları + ekip Tasarım bonusu.
## v1'de taban sıfır, v2+'da canlı mvp_* değerleri. Build boyunca yalnız olaylar ve TASARIM turları
## oynatır.
static func projected_axes(new_feature_ids: Array, strengthen_ids: Array, base_dims: Dictionary) -> Dictionary:
	var out := {}
	for ax in QualityModel.AXES:
		out[ax] = float(base_dims.get(ax, 0.0))
	for fid in new_feature_ids:
		var dc: Dictionary = ProductCatalog.get_feature_by_id(String(fid)).get("dimension_contribution", {})
		for ax in QualityModel.AXES:
			out[ax] = float(out[ax]) + float(dc.get(ax, 0))
	for sid in strengthen_ids:
		var ax_s: String = _dominant_axis_of(String(sid))
		out[ax_s] = float(out[ax_s]) + STRENGTHEN_AXIS_BONUS
	# Tavan bonus terimine uygulanır, eksene değil: v2'de birikmiş Deneyim yeni bonusu yutmasın.
	var design_sum: float = _build_area_sum(HRConstants.AREA_DESIGN)
	if design_sum > 0.0:
		out["experience"] = float(out["experience"]) \
			+ minf(design_sum * PM_EXPERIENCE_PER_POINT, PM_EXPERIENCE_CAP)
	return out


static func _dominant_axis_of(fid: String) -> String:
	# The axis a feature feeds most (deterministic inno→stab→experience tiebreak).
	var dc: Dictionary = ProductCatalog.get_feature_by_id(fid).get("dimension_contribution", {})
	var best: String = "innovation"
	var best_v: float = -INF
	for ax in QualityModel.AXES:
		var v: float = float(dc.get(ax, 0.0))
		if v > best_v:
			best_v = v
			best = ax
	return best


static func _set_axes(b: FeatureBuild, dims: Dictionary) -> void:
	for ax in QualityModel.AXES:
		b.set(ax, float(dims.get(ax, 0.0)))


# --- Yayın ---

## "Yayınla'ya basarsam kaç hata canlıya taşınır?" — kritik hata cezası dahil; launch() da buradan okur.
static func projected_launch_bugs() -> int:
	if active_build == null:
		return 0
	var n: int = active_build.bug_count
	if GameState.get_flag("critical_bug_unfixed", false):
		n += CRITICAL_BUG_LAUNCH_PENALTY
	return maxi(n, 0)


## Oyuncunun "Yayınla"sı, yalnız BETA'dan. Canlı durumu damgalar ve yayın kartını ister; kartın
## seçeneği ship_active_build'i çağırıp build'i kapatır. Erken basmanın bedeli açık hatalardır.
static func launch() -> void:
	if active_build == null:
		push_warning("[ProductSystem] launch called with no active build")
		return
	if active_build.current_phase != "bugfix":
		push_warning("[ProductSystem] launch outside beta phase ignored (was %s)" % active_build.current_phase)
		return
	var b := active_build
	if GameState.get_flag("critical_bug_unfixed", false):
		b.bug_count = projected_launch_bugs()
		GameState.set_flag("critical_bug_unfixed", false)
	# Düz yolda eksenler build'in damgasıdır (v2+'da build canlıdan tohumlandı, yani bu bir birleşme).
	for ax in QualityModel.AXES:
		GameState.set_flag("mvp_%s" % ax, float(b.get(ax)))
	GameState.set_flag("mvp_bug_count_at_launch", b.bug_count)
	GameState.set_flag("mvp_live_bug_count", b.bug_count)
	GameState.set_flag("mvp_live_bug_progress", 0.0)
	# §9 — sürüm yaşı, ilgi ve yeni-kod terimi yayında birlikte tazelenir. Taşınan hatalar
	# doğrulanmış doğmaz; zamanla yüzeye çıkar.
	ProductState.refresh_on_publish(b.total_efor)
	# §12 — hat modelinde eksenler hat durumlarından türetilir ve yukarıdaki damgayı ezer.
	_apply_line_plan_at_ship(b)
	GameState.set_flag("mvp_version",
		(int(GameState.get_flag("mvp_version", 1)) + 1) if b.is_version_build else 1)
	GameState.set_flag("mvp_product_name", b.product_name)
	GameState.set_flag("mvp_sub_product_type_id", b.sub_product_type_id)
	GameState.set_flag("mvp_market_type", ProductCatalog.get_market_type(b.sub_product_type_id))
	_trigger_ship_moment(b.is_version_build)


## §12 + §11.2 — hat durumları yalnız yayında ilerler ve her kademe yayınlandığı sürümün cilasını
## damgalar. Kademe başına damga, sonraki bir sürümün tur sayısının önceki sürümün işini
## değiştirmesini engeller (§2, §12.3).
static func _apply_line_plan_at_ship(b: FeatureBuild) -> void:
	if b.planned_step_ids.is_empty():
		return
	var turn_mult: float = design_turn_mult(b.design_turns_completed)
	for raw_id in b.planned_step_ids:
		var sid: String = String(raw_id)
		var step: Dictionary = ProductLines.step(sid)
		if step.is_empty():
			push_error("[ProductSystem] shipped an unknown step '%s'" % sid)
			continue
		var line_id: String = String(step.get("line_id", ""))
		var tier: int = int(step.get("tier", 0))
		# §12.8 kapı-üstü bonusu kademenin kendi kapısına göre ölçülür.
		var stamp: float = QualityModel.realization_stamp(turn_mult, LineGates.above_gate_bonus(sid))
		ProductState.set_line_tier(line_id, tier)
		ProductState.stamp_step(sid, stamp)
		EventBus.line_upgraded.emit(line_id, tier)
		if tier >= ProductLines.TIER_MAX:
			EventBus.line_completed.emit(line_id)
			EventBus.delighter_shipped.emit(sid)   # §12.4 — K3 yayını övgü olayını tetikler
	# §11.2/§11.3 — canlı eksenler hat modelinden yeniden türetilir. Olay delta'ları ayrı defterde
	# tutulur ve türevin üstüne biner; yoksa yayında silinirlerdi.
	var dims: Dictionary = ProductState.realized_dims()
	for axis in QualityModel.AXES:
		var extra: float = float(b.axis_event_delta.get(axis, 0.0))
		GameState.set_flag("mvp_%s" % axis, maxf(0.0, float(dims.get(axis, 0.0)) + extra))


## Yayın kartının tek seçeneği çağırır: sürümü canlıya geçirir ve build'i kapatır. Ekonomik delta yok.
static func ship_active_build() -> void:
	if active_build == null:
		push_warning("[ProductSystem] ship_active_build called with no active build")
		return
	GameState.set_flag("mvp_shipped", true)
	var ship_ver: int = int(GameState.get_flag("mvp_version", 1))
	GameState.submit_month_highlight(
		TranslationServer.translate("PROD_SHIP_FIRST_TITLE") if ship_ver <= 1
		else TranslationServer.translate("PROD_SHIP_VERSION_TITLE").format({"version": ship_ver}), 50)
	# Ürünün canlı yaşı ilk yayından okunur; sonraki sürümler ezmez.
	if not GameState.has_flag("mvp_launch_day"):
		GameState.set_flag("mvp_launch_day", GameState.day)
	var vhist: Array = GameState.get_flag("mvp_version_history", [])
	vhist.append({"version": ship_ver, "day": GameState.day})
	GameState.set_flag("mvp_version_history", vhist)
	# Sürüm build'i birleşik feature kümesini taşır; aşınma yeni karmaşıklığı okur.
	GameState.set_flag("mvp_components", active_build.component_ids)
	active_build.current_phase = "shipped"
	EventBus.build_phase_changed.emit("shipped")
	active_build = null
	# §19 — sürümün canlıya geçtiği tek an; launch() yalnız damgalar.
	EventBus.version_shipped.emit(ship_ver)


## Kartlar tick:request ile istenir, version_shipped'e bağlanmaz: o sinyal kartın kendi seçeneğinin
## çağırdığı ship_active_build'in sonunda atılır, yani kart hep bir yayın geç kalırdı.
static func _trigger_ship_moment(is_version: bool) -> void:
	EventGate.request("product.version_ship" if is_version else "product.first_ship")


# --- Genel okumalar ---

## Is the company committed to a B2B product, shipped OR in build? Deliberately broader than
## SalesSystem.is_b2b_market() ("does the enterprise desk run today"): the founder may staff for
## enterprise work from the moment they commit, not only once the desk is already busy.
static func has_b2b_product() -> bool:
	if String(GameState.get_flag("mvp_market_type", "")) == "b2b":
		return true
	return active_build != null and active_build.sub_product_type_id != "" \
		and ProductCatalog.get_market_type(active_build.sub_product_type_id) == "b2b"


static func get_active_build() -> FeatureBuild:
	return active_build


# --- Ürün rev 6.1 §12 · hat modeli: Konsept'ten yapıma ---

## Konsept onayının tek doğrulayıcısı. "" = plan geçerli; aksi hâlde makine sebebi. Merdiven
## kuralları ProductLines'ta, kapılar LineGates'te (§18).
static func validate_line_plan(subtype: String, step_ids: Array) -> String:
	if step_ids.is_empty():
		return "empty_plan"
	if not ProductLines.has_subtype(subtype):
		return "unknown_subtype"
	var accepted: Array[String] = []
	for raw in step_ids:
		var sid: String = String(raw)
		var step: Dictionary = ProductLines.step(sid)
		if step.is_empty():
			return "unknown_step"
		if String(step.get("subtype", "")) != subtype:
			return "step_from_another_subtype"
		# §12.3 — merdiven: atlama yok, sürüm başına hat başına bir kademe, düşürme yok.
		var refusal: String = ProductLines.ladder_refusal(
			sid, ProductState.line_tier(String(step.get("line_id", ""))), accepted)
		if refusal != "":
			return refusal
		# §12.5/§12.7 — kapı şirket genelinden, Konsept onayında kontrol edilir.
		if not LineGates.is_unlocked(sid):
			return "locked"
		accepted.append(sid)
	return ""


## §6.0 — EforTavanı: seçilen kademelerin efor toplamı. TASARIM turları üstüne biner (§5).
static func effort_ceiling(step_ids: Array) -> int:
	return ProductLines.sum_effort(step_ids)


## Konsept önizlemesindeki "Süre ~N gün" (§3): tavan + tek TASARIM turu (taban cila ×1,00), bu iş de
## başlarsa kapasiteyle. Tur sayısı TASARIM'da belirlenir, Konsept onu bilemez.
static func estimate_line_build_days(step_ids: Array, lead_id: String = "") -> int:
	var ceiling: float = float(effort_ceiling(step_ids))
	if ceiling <= 0.0:
		return 0
	var design: float = DESIGN_TURN_COST * ceiling
	var rate: float = build_effort_per_day(lead_id) * projected_speed_factor_with_extra_job()
	return int(ceil((ceiling + design) / maxf(0.01, rate)))


## Konsept önizlemesi: net kazanç taban cilayla (×1,00) gösterilir (§5).
static func projected_line_dims(subtype: String, step_ids: Array) -> Dictionary:
	var tiers: Dictionary = ProductState.line_tiers()
	var stamps: Dictionary = ProductState.line_realization()
	for raw in step_ids:
		var step: Dictionary = ProductLines.step(String(raw))
		if step.is_empty():
			continue
		var line_id: String = String(step.get("line_id", ""))
		tiers[line_id] = int(step.get("tier", 0))
		stamps[line_id] = 1.00
	return QualityModel.realized_dims(subtype, tiers, stamps)


## Hat modeliyle bir sürüm başlatır. Hat durumlarına yayında dokunulur, yani iptal hiçbir şeyi geri
## almak zorunda kalmaz (§12.3 kural 4).
static func start_line_build(subtype: String, step_ids: Array, lead_id: String = "",
		product_name: String = "") -> bool:
	if active_build != null:
		push_warning("[ProductSystem] start_line_build called while a build is active")
		return false
	var refusal: String = validate_line_plan(subtype, step_ids)
	if refusal != "":
		push_warning("[ProductSystem] start_line_build refused: %s" % refusal)
		return false
	# Taahhüt edilen ürün alt-türü seçer: subgenre olay koşulları, haber havuzu ve Meridian boyut
	# tohumlaması bunu okur.
	var pool_key: String = ProductCatalog.get_pool_of(subtype)
	if pool_key != "":
		GameState.set_subgenre(pool_key)
	var typed: Array[String] = []
	for raw in step_ids:
		typed.append(String(raw))
	var b := FeatureBuild.new()
	b.id = "mvp_build_v%d" % (int(GameState.get_flag("mvp_version", 0)) + 1)
	b.is_version_build = ProductState.is_live()
	b.sub_product_type_id = subtype
	b.planned_step_ids = typed
	b.lead_engineer_id = lead_id
	var trimmed: String = product_name.strip_edges()
	b.product_name = trimmed if trimmed != "" else ProductState.product_name()
	b.start_day = GameState.day
	b.current_phase = "iteration"
	b.iteration_count = 1
	# §6.0 — bar bu tavanın %100'üne dolar. §6.3 — hatalar commit'te tohumlanmaz, GELİŞTİRME'de birikir.
	b.total_efor = float(effort_ceiling(typed))
	# Önizleme eksenleri taban cilayla; kesin değer yayında damgalanır.
	_set_axes(b, projected_line_dims(subtype, typed))
	# Lisans maliyetleri commit'te bir kez tahsil edilir (§12.4).
	var cost: int = ProductLines.sum_license_cost(typed)
	if cost > 0:
		FinanceSystem.apply_one_time_cost(cost, "build_commit")
	active_build = b
	GameState.set_flag("mvp_sub_product_type_id", subtype)
	EventBus.build_started.emit(b.id)
	EventBus.build_phase_changed.emit(b.current_phase)
	EventBus.build_progress_changed.emit()
	return true


# --- Düz katalog yolu ---

static func start_build(
	sub_product_type_id: String,
	feature_ids: Array,
	assigned_engineer_id: String,
	product_name: String = ""
) -> bool:
	if active_build != null:
		push_warning("[ProductSystem] start_build called while build already active")
		return false
	if ProductCatalog.get_sub_product_type_by_id(sub_product_type_id).is_empty():
		push_warning("[ProductSystem] start_build invalid sub_product_type_id: %s" % sub_product_type_id)
		return false
	if feature_ids.is_empty():
		push_warning("[ProductSystem] start_build with empty feature list")
		return false
	var pool_ids: Array = ProductCatalog.get_feature_pool(sub_product_type_id).map(
		func(f: Dictionary) -> String: return String(f.get("id", "")))
	for fid in feature_ids:
		if not pool_ids.has(String(fid)):
			push_warning("[ProductSystem] start_build feature %s not in pool for %s" % [fid, sub_product_type_id])
			return false
	var pool_key: String = ProductCatalog.get_pool_of(sub_product_type_id)
	if pool_key != "":
		GameState.set_subgenre(pool_key)
	var typed_features: Array[String] = []
	for fid in feature_ids:
		typed_features.append(String(fid))
	var b := FeatureBuild.new()
	b.id = "mvp_build_001"
	b.sub_product_type_id = sub_product_type_id
	b.feature_ids = typed_features
	b.component_ids = typed_features
	b.lead_engineer_id = assigned_engineer_id
	var trimmed: String = product_name.strip_edges()
	b.product_name = trimmed if trimmed != "" else ProductCatalog.type_name(sub_product_type_id)
	b.start_day = GameState.day
	_set_axes(b, projected_axes(typed_features, [], {}))
	b.bug_count = _seed_feature_bugs(typed_features)   # v1: her seçilen feature yenidir
	b.current_phase = "iteration"
	b.iteration_count = 1
	b.total_efor = float(ProductCatalog.sum_efor(typed_features))
	# Üçüncü-parti maliyet commit'te bir kez; nakit eksiye düşebilir (iflas baskısı).
	FinanceSystem.apply_one_time_cost(ProductCatalog.sum_cost(typed_features), "build_commit")
	active_build = b
	_reseat_founder("iteration")
	EventBus.build_phase_changed.emit("iteration")
	return true


## v2+: canlı ürünün eksenlerinden tohumlanır ve yeni feature'ları yayınlanmış kümeyle birleştirir.
## Canlı ürünün ekonomisini dondurmaz; bedeli süre ve yeni hatalardır. Havuz tükendiyse yeni feature
## yerine mevcut feature'lar güçlendirilir, sürüm kilitlenmez.
static func start_version_build(new_feature_ids: Array, assigned_engineer_id: String = "",
		strengthen_feature_ids: Array = []) -> bool:
	if active_build != null:
		push_warning("[ProductSystem] start_version_build while a build is active")
		return false
	if not ProductState.is_live():
		push_warning("[ProductSystem] start_version_build with no live product")
		return false
	var sub_id: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var pool_ids: Array = ProductCatalog.get_feature_pool(sub_id).map(
		func(f: Dictionary) -> String: return String(f.get("id", "")))
	var union_ids: Array[String] = []
	for fid in GameState.get_flag("mvp_components", []):
		union_ids.append(String(fid))
	# Güçlendirme seçimleri yayınlanmış feature'lardan olmalı (union burada henüz tam o küme).
	var typed_strengthen: Array[String] = []
	for sid in strengthen_feature_ids:
		var ss: String = String(sid)
		if not union_ids.has(ss):
			push_warning("[ProductSystem] strengthen %s not in mvp_components" % ss)
			return false
		if not typed_strengthen.has(ss) and typed_strengthen.size() < STRENGTHEN_MAX_PER_VERSION:
			typed_strengthen.append(ss)
	var typed_new: Array[String] = []
	for fid in new_feature_ids:
		var s: String = String(fid)
		if not pool_ids.has(s):
			push_warning("[ProductSystem] v2 feature %s not in pool for %s" % [s, sub_id])
			return false
		if not union_ids.has(s):
			union_ids.append(s)
			typed_new.append(s)
	if typed_new.is_empty() and typed_strengthen.is_empty():
		push_warning("[ProductSystem] v2 needs >=1 new feature OR >=1 strengthen")
		return false
	var b := FeatureBuild.new()
	b.id = "mvp_build_v%d" % (int(GameState.get_flag("mvp_version", 1)) + 1)
	b.sub_product_type_id = sub_id
	b.feature_ids = union_ids
	b.component_ids = union_ids
	b.strengthened_feature_ids = typed_strengthen
	b.lead_engineer_id = assigned_engineer_id
	b.product_name = String(GameState.get_flag("mvp_product_name", ""))
	b.start_day = GameState.day
	var base_dims := {}
	for ax in QualityModel.AXES:
		base_dims[ax] = float(GameState.get_flag("mvp_%s" % ax, 0.0))
	_set_axes(b, projected_axes(typed_new, typed_strengthen, base_dims))
	# Canlı hatalar devralınır (temiz bir v2 için önce sprint); yalnız YENİ feature'lar tohum atar.
	b.bug_count = int(GameState.get_flag("mvp_live_bug_count", 0)) + _seed_feature_bugs(typed_new)
	b.is_version_build = true
	b.current_phase = "iteration"
	b.iteration_count = 1
	# Efor ve maliyet yalnız yeni işten; devralınan ve güçlendirilen feature yeniden ödenmez.
	b.total_efor = float(ProductCatalog.sum_efor(typed_new) + STRENGTHEN_EFOR * typed_strengthen.size())
	FinanceSystem.apply_one_time_cost(ProductCatalog.sum_cost(typed_new), "version_build_commit")
	active_build = b
	_reseat_founder("iteration")
	EventBus.build_phase_changed.emit("iteration")
	return true


static func cancel_build() -> void:
	if active_build == null:
		return
	active_build.current_phase = "cancelled"
	EventBus.build_phase_changed.emit("cancelled")
	active_build = null


# --- Olay efektleri ---

## "+N gün" yapımı ilerleten hızla efora çevrilip toplama eklenir (negatif hızlandırır). Toplam
## harcananın ve 1 eforun altına inmez.
static func apply_speed_bonus(days: int) -> void:
	if active_build == null:
		return
	var b := active_build
	var speed: float = build_effort_per_day(b.lead_engineer_id) if is_line_build() else team_speed(b)
	b.total_efor = maxf(maxf(1.0, b.efor_spent), b.total_efor + float(days) * speed)


## Düz ekleme, taban 0: olay delta'sı yoksa önizleme == ship ve her delta modalda rozet taşır.
static func apply_dimension_delta(axis: String, amount: int) -> void:
	if active_build == null:
		return
	if not (axis in QualityModel.AXES):
		axis = "innovation"
	# Hat modelinde eksenler yayında yeniden türetilir; delta ayrı defterde tutulmazsa olay rozeti
	# bir şey vaat edip hiçbir şey yapmazdı.
	if is_line_build():
		var d: Dictionary = active_build.axis_event_delta.duplicate()
		d[axis] = float(d.get(axis, 0.0)) + float(amount)
		active_build.axis_event_delta = d
	active_build.set(axis, maxf(0.0, float(active_build.get(axis)) + float(amount)))


static func apply_bug_delta(amount: int) -> void:
	if active_build != null:
		active_build.bug_count = maxi(0, active_build.bug_count + amount)


# --- Canlı ürün sağlık türetmeleri (Ürün Detayı): id döner, metni UI çözer ---

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
