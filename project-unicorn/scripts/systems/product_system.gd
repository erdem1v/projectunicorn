class_name ProductSystem
extends RefCounted

# Slot 1 daily tick per TECH_SPEC §8.2. Pure logic (TECH_SPEC §8.3).
#
# Rev3 efor/hız build akışı (Product Tab Rev3, üç faz):
#   planning → iteration (TASARIM) → development (GELİŞTİRME) → bugfix (BETA) → shipped.
# Görünen adlar TR (TASARIM/GELİŞTİRME/BETA); iç faz string'leri DEĞİŞMEDİ —
# event trigger'ları (ev_mvp_*), PromiseRegistry ve capacity_demand aynı id'leri okur.
#
# - Süre: build'in toplam işi EFOR (feature efor toplamı); ekip HIZI (sorumlu +
#   asistanların tech'i) her saat taze hesaplanıp efor_spent'e harcanır. Süre
#   türetilir (~N gün = kalan efor / hız), sabit gün sayısı yok.
# - Fazlar OTOMATİK: %0-20 TASARIM, %20-80 GELİŞTİRME, %80-100 BETA (ratchet,
#   geri gitmez). Oyuncunun tek faz aksiyonu Beta'daki "Yayınla" (launch) —
#   build %100'de Beta'da SÜRESİZ park eder, auto-ship YOK.
# - Eksenler DETERMİNİSTİK: commit'te projected_axes ile damgalanır (katkı
#   toplamları), build boyunca SABİT — yalnız event dimension_delta oynatır.
#   Önizleme == ship, yapısal garanti (Director decision 1, 2026-07-17).
# - Bug kanalı aynen: commit'te complexity tohumu, GELİŞTİRME bandında saatlik
#   birikim, dev→beta geçişinde tech-debt, BETA'da bul/çöz (bekleyen temiz ship'ler).
# - Ship moment narrative-only kalır — launch() durumu damgalar, modal seçimi
#   ship_active_build'i çağırır. Kalan açık bug'lar mvp_live_bug_count'a taşınır
#   → post-ship şikayet boru hattı (effective_stability → satisfaction → event).

# ==========  Rev3 EFOR/HIZ ENGINE (working values — Erdem balance-pass)  ==========
const SPEED_LEAD_WEIGHT := 1.0      # sorumlu (lead) tech skill ağırlığı
const SPEED_ASSIST_WEIGHT := 0.5    # diğer her ekip üyesinin tech ağırlığı
const SPEED_MIN := 1.0              # tech-0 ekip bile günde 1 efor ilerler (sonsuz build imkansız)
const ENGINEER_DEFAULT_TECH := 2    # role_stats.tech taşımayan çalışan (0-5 skala; kurucu cap 3)
const STRENGTHEN_EFOR := 5          # bir güçlendirme pick'inin eforu (~orta feature)
const STRENGTHEN_AXIS_BONUS := 4.0  # ship'te pick'in dominant eksenine düz bonus
# --- Faz bantları: toplam eforun oranı; sınırda OTOMATİK geçiş, oyuncu faz-aksiyonu yok ---
const PHASE_DESIGN_END := 0.20      # Tasarım  ("iteration"):    [0.00, 0.20)
const PHASE_DEV_END := 0.80         # Geliştirme ("development"): [0.20, 0.80); Beta ("bugfix"): [0.80, 1.0]+
# --- Canlı ürün sağlık/trend türetmeleri (Ürün Detayı verisi) ---
const BUG_HISTORY_DAYS := 7         # mvp_bug_history penceresi (günlük örnek sayısı)
const TREND_DELTA := 2              # |son - ilk| >= bu → ARTIYOR/AZALIYOR; altı SABİT
const TREND_SPIKE := 4              # keskin artış eşiği → sağlık Riskli
const HEALTH_EFF_STAB_RATIO := 0.5  # effective/raw stability >= bu → Sağlıklı adayı
const BUG_RISK_ORTA := 0.5          # canlı bug / toplam complexity >= bu → Orta
const BUG_RISK_YUKSEK := 1.5        # canlı bug / toplam complexity >= bu → Yüksek

# Pool-deepening (feature-exhaustion unlock): when the pool is exhausted the player
# STRENGTHENS existing features instead of adding new ones. Cap on picks per version.
const STRENGTHEN_MAX_PER_VERSION := 2
const POLISH_BUG_FIX_PER_DAY := 4        # bugs cleared per day during bugfix
const HOURS_PER_BUILD_DAY := 24          # efor/bugs accrue hourly (~daily rate / 24)

# --- Development bug accrual (Blok C: complexity-driven, tech reduces NOT zeros) ---
# Per-HOUR fractional bug rate = max(BUG_FLOOR, Σcomplexity·COEF − tech·REDUCER).
# Complex product + low tech = bug rain; simple + high tech = clean-but-few (never 0).
# All BALANCE-TUNABLE.
const BUG_COMPLEXITY_COEF := 0.006
const BUG_TECH_REDUCER := 0.005
const BUG_FLOOR := 0.010
# Tech-debt taken via dev events converts to real bugs at development→bugfix.
const TECH_DEBT_BUG_PENALTY := 5
# At-commit bug seed ("Yeni feature = yeni bug", Package 5): each NEW feature entering a
# build adds bugs ∝ its complexity. Separate channel from the hourly dev-phase accrual
# above; a hardening build (no new features) seeds nothing. BALANCE-TUNABLE.
const FEATURE_BUG_SEED_COEF := 1.0

# Bonus bug count applied at launch when the player left a critical bug
# in (ev_mvp_bugfix_001_critical_bug "Bırak, gönder" choice → flag).
const CRITICAL_BUG_LAUNCH_PENALTY := 5

# --- Beta (BETA testi arka planda kendi kendine koşar) ---
# BETA: test gizli bug'ları bulur (find) ve bulunanları çözer (fix: mevcut
# POLISH_BUG_FIX_PER_DAY hızı). working value — Erdem balance-pass.
const BETA_BUG_FIND_PER_DAY := 6.0
# Build iptali: ilk gün "bedelsiz" sayılır (onay metni basit — yanlış-tık affı);
# sonrasında onay yanan gün/parayı söyler. Mekanik refund yok (yanan yanmıştır).
# working value — Erdem balance-pass.
const CANCEL_FREE_DAYS := 1

# --- Post-ship wear (Product Lifecycle Part 2A) ---
# Live product accrues bugs hourly: more users = more edge cases; complex product
# wears faster; founder tech reduces but NEVER zeros (WEAR_FLOOR). BALANCE-TUNABLE.
# Part 2B rebalance: wear was too aggressive ("a bug every day, sprint every minute").
# Softened so bug accrual takes DAYS of neglect, and tech is now decisive (tech 0 drowns,
# high tech coasts, floor keeps it > 0 forever). All BALANCE-TUNABLE (Erdem tunes last).
const WEAR_AUD_COEF := 0.00004       # per audience member / hour
const WEAR_CPLX_COEF := 0.0012       # per total feature-complexity point / hour
const WEAR_TECH_REDUCER := 0.005     # founder tech skill → less wear (raised: tech now matters)
const WEAR_FLOOR := 0.002            # baseline wear (always > 0)
# Bug sprint (Part 2A): clears live bugs over a few days; duration scales with bugs.
# Part 2B: MIN dropped to 1 + slower per-day rate so 1 bug ≈ 1 day but 10+ bugs is visibly longer.
const SPRINT_BUG_FIX_PER_DAY := 4    # live bugs cleared per day during a sprint
const MIN_SPRINT_DAYS := 1
const MAX_SPRINT_DAYS := 7
# HR-bridge seed (light): too-frequent sprints → needs_engineer signal (no real hire).
const ENGINEER_SPRINT_THRESHOLD := 3   # sprints within the window → "need an engineer"
const ENGINEER_WINDOW_DAYS := 20
# --- Kapasite havuzu (sprint + version-build eşzamanlılığı) ---
# Kapasite = kurucu (her zaman 1) + mühendis sayısı. Sprint ve build'in her biri
# 1 kapasite talep eder; talep > kapasite → işler orantılı yavaşlar (2 iş / 1
# kişi → ikisi de yarı hız). Formül merkezi: capacity_speed_factor. working value.
const CAPACITY_BASE := 1

static var active_build: FeatureBuild = null


# --- Entry point (called by TimeManager._tick_product at slot 1) ---

static func daily_tick() -> void:
	# Rev3: canlı ürünün günlük bug örneği (mvp_bug_history, son BUG_HISTORY_DAYS gün)
	# — bug_trend() / health_state() bu pencereyi okur. Build ilerlemesi saatlik kalır.
	if not GameState.get_flag("mvp_shipped", false):
		return
	var hist: Array = GameState.get_flag("mvp_bug_history", [])
	hist.append(int(GameState.get_flag("mvp_live_bug_count", 0)))
	while hist.size() > BUG_HISTORY_DAYS:
		hist.pop_front()
	GameState.set_flag("mvp_bug_history", hist)


# --- Kapasite havuzu — tick'ler VE UI süre tahminleri aynı kaynaktan okur
#     (kalibrasyon tek yer). Faktör persist edilmez (türetilmiş değer).

static func capacity_total() -> int:
	# Kurucu hep var → min 1; kapasite 0 yapısal olarak imkansız.
	return CAPACITY_BASE + CharacterRegistry.count_engineers()


static func capacity_demand() -> int:
	var d: int = 0
	if GameState.get_flag("mvp_bug_sprint_active", false):
		d += 1
	if GameState.get_flag("pitch_prep_active", false):
		d += 1  # VC meeting prep occupies the founder (Spec 4 §3 — product slows, visible)
	if active_build != null and active_build.current_phase in ["iteration", "development", "bugfix"]:
		d += 1
	return d


static func capacity_speed_factor() -> float:
	# ŞU ANKİ hız çarpanı — her saat taze hesaplanır (mid-job hire anında etki eder).
	# demand <= capacity → 1.0; demand=2, capacity=1 → 0.5.
	var d: int = capacity_demand()
	if d <= 0:
		return 1.0
	return minf(1.0, float(capacity_total()) / float(d))


static func projected_speed_factor_with_extra_job() -> float:
	# UI ön-gösterimi: "bu iş de BAŞLARSA hangi hızda koşar?" — confirm öncesi
	# uzayan süre projeksiyonunun tek kaynağı ("~3 gün → ~6 gün" deseni).
	return minf(1.0, float(capacity_total()) / float(capacity_demand() + 1))


static func days_at_factor(days: int, f: float) -> int:
	# Nominal iş-günü → duvar-süresi (takvim günü) projeksiyonu.
	return int(ceil(float(days) / maxf(0.01, f)))


# =========================================================================
#  Ekip hızı (Rev3) — SORUMLU + asistanlar; saf, her çağrıda taze
# =========================================================================

static func _tech_of(member_id: String) -> int:
	# ""/"founder"/kurucu-id → kurucu tech'i (0-5); çalışan → role_stats.tech
	# (yoksa ENGINEER_DEFAULT_TECH). Bilinmeyen id kurucuya düşer (güvenli).
	var founder: Character = CharacterRegistry.get_founder()
	if member_id == "" or member_id == "founder" or (founder != null and member_id == founder.id):
		return GameState.get_founder_skill("tech")
	var c: Character = CharacterRegistry.get_character(member_id)
	if c == null:
		return GameState.get_founder_skill("tech")
	return int(c.role_stats.get("tech", ENGINEER_DEFAULT_TECH))


static func _speed_for_lead(lead_id: String) -> float:
	# Ekip = kurucu + TÜM istihdam edilen Engineer'lar; sorumlu LEAD ağırlığında,
	# kalan herkes otomatik asistan (working call). Floor SPEED_MIN.
	var founder: Character = CharacterRegistry.get_founder()
	var founder_id: String = founder.id if founder != null else "founder"
	if lead_id == "" or lead_id == "founder":
		lead_id = founder_id
	var speed: float = SPEED_LEAD_WEIGHT * float(_tech_of(lead_id))
	if lead_id != founder_id:
		speed += SPEED_ASSIST_WEIGHT * float(GameState.get_founder_skill("tech"))
	for c in CharacterRegistry.get_employees():
		if c.role == "Engineer" and c.id != lead_id:
			speed += SPEED_ASSIST_WEIGHT * float(int(c.role_stats.get("tech", ENGINEER_DEFAULT_TECH)))
	return maxf(SPEED_MIN, speed)


static func team_speed(b: FeatureBuild) -> float:
	# SAF FONKSİYON, her çağrıda taze (mid-build hire/fire anında etki —
	# capacity_speed_factor ile aynı tazelik sözleşmesi; capacity_split smoke kanunu).
	return _speed_for_lead(b.lead_engineer_id)


# =========================================================================
#  Süre API'si (Rev3) — "~N gün"ün TEK kaynağı (in-tab tracker + slim HUD)
# =========================================================================

static func estimated_days_remaining(b: FeatureBuild) -> int:
	# Kalan efor / (ekip hızı × şu anki kapasite çarpanı), yukarı yuvarlanır.
	if b == null:
		return -1
	var rate: float = team_speed(b) * capacity_speed_factor()
	return int(ceil(maxf(0.0, b.total_efor - b.efor_spent) / maxf(0.01, rate)))


static func estimate_build_days(new_ids: Array, strengthen_ids: Array, sorumlu_id: String) -> int:
	# Commit ÖNCESİ projeksiyon (version_dev_days halefi): toplam efor / (hipotetik
	# hız × projected_speed_factor_with_extra_job — bu iş de başlarsa kapasite).
	var total: float = float(ProductCatalog.sum_efor(new_ids) + STRENGTHEN_EFOR * strengthen_ids.size())
	if total <= 0.0:
		return 0
	var rate: float = _speed_for_lead(sorumlu_id) * projected_speed_factor_with_extra_job()
	return int(ceil(total / maxf(0.01, rate)))


static func build_progress() -> float:
	# İnce UI static'i: aktif build'in efor oranı (0.0 güvenli — build yokken).
	if active_build == null or active_build.total_efor <= 0.0:
		return 0.0
	return clampf(active_build.efor_spent / active_build.total_efor, 0.0, 1.0)


static func build_days_remaining() -> int:
	# İnce UI static'i: aktif build'in ~kalan günü (-1 güvenli — build yokken).
	if active_build == null:
		return -1
	return estimated_days_remaining(active_build)


# =========================================================================
#  Hourly tick (Rev3 çekirdek) — efor harcaması + otomatik faz bantları
# =========================================================================

static func hourly_tick(_hour: int) -> void:
	# Kapasite çarpanı HER SAAT taze hesaplanır (mid-job hire/fire anında etki eder).
	# Zaman dilatasyonu: çarpan işin TÜM saatlik çıktısına uygulanır (efor + bug
	# üretimi + beta find/fix) — tek başına koşan işin toplam çıktısı bit-bit aynı
	# kalır, paralel işler aynı çıktıyı daha uzun duvar-saatine yayar.
	var f: float = capacity_speed_factor()
	# 1) CANLI SÜRÜM yaşam döngüsü — build pipeline'ından BAĞIMSIZ (tasarım kanonu:
	#    ship edilmiş sürüm, sonraki sürüm gelişirken de yaşar; wear/erozyon durmaz).
	#    Sprint aktifken canlı bug'ların sahibi sprint'tir — wear'la aynı saatte
	#    aynı flag'e iki yazar olmasın diye karşılıklı-dışlama korunur.
	if GameState.get_flag("mvp_shipped", false):
		if GameState.get_flag("mvp_bug_sprint_active", false):
			_tick_live_sprint_hourly(f)
		else:
			_post_ship_wear_hourly()   # wear DÜNYA olayıdır, iş değil — çarpan uygulanmaz
	# 2) BUILD PIPELINE (varsa) — tek slot yalnız GERÇEK build'ler için
	#    (sprint slot kullanmaz; saf canlı-durum aksiyonu).
	if active_build == null:
		return
	if active_build.current_phase in ["iteration", "development", "bugfix"]:
		_tick_build_hourly(f)
		EventBus.build_progress_changed.emit()


static func _tick_build_hourly(f: float) -> void:
	var b := active_build
	# 1) Efor harcaması (%100'de durur; build Beta'da SÜRESİZ bekleyebilir — auto-ship YOK).
	if b.efor_spent < b.total_efor:
		b.efor_spent = minf(b.total_efor, b.efor_spent + team_speed(b) * f / float(HOURS_PER_BUILD_DAY))
	# 2) Faz sınırı OTOMATİK geçişleri (ratchet — asla geri gitmez, apply_speed_bonus
	#    totali büyütse bile).
	var frac: float = b.efor_spent / maxf(0.001, b.total_efor)
	if b.current_phase == "iteration" and frac >= PHASE_DESIGN_END:
		b.current_phase = "development"
		b._sync_status_from_phase()
		EventBus.build_phase_changed.emit("development")
	if b.current_phase == "development" and frac >= PHASE_DEV_END:
		_apply_tech_debt_due(b)                        # borç beta girişinde düşer (mevcut kural)
		b.current_phase = "bugfix"
		b._sync_status_from_phase()
		# Beta sayaçları sıfırdan başlar; dev'in ürettiği bug'lar "gizli" havuz olarak
		# bug_count içinde durur, test onları BULUR.
		b.bugs_found = 0
		b.bugs_fixed = 0
		b.bug_find_progress = 0.0
		b.bug_fix_progress = 0.0
		# Snapshot bug count at bugfix entry so the tracker can read
		# "started with M, shipped with N". Keyed by build id.
		GameState.set_flag("bug_count_at_bugfix_start_%s" % b.id, b.bug_count)
		_sync_legacy_quality(b)
		EventBus.build_phase_changed.emit("bugfix")
		if OS.is_debug_build():
			print("[ProductSystem] Development band complete → BETA. hidden_bugs=%d" % b.bug_count)
	# 3) Faz-bantlı yan süreçler.
	if b.current_phase == "development":
		_accrue_bugs_hourly(f)          # saatlik dev-bug birikimi → Geliştirme bandı (KEEP)
	elif b.current_phase == "bugfix":
		_tick_beta_hourly(f)            # arka-plan sertleştirme (find/fix), Beta'da süresiz (KEEP)


static func _apply_tech_debt_due(b: FeatureBuild) -> void:
	# Dev event'lerinde alınan tech-debt gerçek bug'a döner — dev→beta geçişinde
	# uygulanır (borçtan kaçış yok; erken-ship yolu Rev3'te kapandı).
	if GameState.get_flag("tech_debt_birikti", false):
		b.bug_count += TECH_DEBT_BUG_PENALTY
		GameState.set_flag("tech_debt_birikti", false)


static func _tick_beta_hourly(f: float = 1.0) -> void:
	# BETA (iç faz "bugfix"): test gizli bug'ları BULUR, bulunanları ÇÖZER — ikisi de
	# otomatik; oyuncunun kararı ne kadar bekleyeceği. İnvaryant: gizli = bug_count -
	# (found - fixed); fix bug_count'u düşürür → effective_stability ve tüm mevcut
	# tüketiciler değişmeden çalışır. Hızlar working — Erdem balance-pass.
	var b := active_build
	var hidden: int = b.bug_count - (b.bugs_found - b.bugs_fixed)
	if hidden > 0:
		b.bug_find_progress += BETA_BUG_FIND_PER_DAY * f / float(HOURS_PER_BUILD_DAY)
		while b.bug_find_progress >= 1.0 and hidden > 0:
			b.bugs_found += 1
			hidden -= 1
			b.bug_find_progress -= 1.0
	if b.bugs_found - b.bugs_fixed > 0:
		b.bug_fix_progress += float(POLISH_BUG_FIX_PER_DAY) * f / float(HOURS_PER_BUILD_DAY)
		while b.bug_fix_progress >= 1.0 and b.bugs_found - b.bugs_fixed > 0:
			b.bugs_fixed += 1
			b.bug_count -= 1
			b.bug_fix_progress -= 1.0
	b.bug_count = max(0, b.bug_count)
	_sync_legacy_quality(b)


static func _accrue_bugs_hourly(f: float = 1.0) -> void:
	# Complexity-driven, tech reduces but never zeros (BUG_FLOOR). Fractional bugs
	# accumulate on bug_progress and tick bug_count up as they cross 1.0.
	var b := active_build
	var tech: int = GameState.get_founder_skill("tech")
	var rate: float = maxf(BUG_FLOOR, float(b.get_total_complexity()) * BUG_COMPLEXITY_COEF - float(tech) * BUG_TECH_REDUCER)
	b.bug_progress += rate * f
	while b.bug_progress >= 1.0:
		b.bug_count += 1
		b.bug_progress -= 1.0
	_sync_legacy_quality(b)


# --- At-commit feature bug seed (Package 5) ---

static func _seed_feature_bugs(feature_ids: Array) -> int:
	# "Yeni feature = yeni bug": each feature's complexity seeds bugs at build commit.
	# Flows into b.bug_count → effective_stability → mvp_live_bug_count (same channel as
	# every other bug). Duration is unaffected (that reads efor, not bugs).
	var seeded: int = 0
	for fid in feature_ids:
		var cx: int = int(ProductCatalog.get_feature_by_id(String(fid)).get("complexity", 0))
		seeded += int(round(float(cx) * FEATURE_BUG_SEED_COEF))
	return seeded


# --- Post-ship wear (Product Lifecycle Part 2A) ---

static func _post_ship_wear_hourly() -> void:
	# Live product accrues bugs from usage (audience) + complexity, minus founder
	# tech, floored positive. Fractional on mvp_live_bug_progress → mvp_live_bug_count
	# ticks up smoothly. Audience/MRR then erode automatically (economy reads live bug).
	var audience: float = float(GameState.get_flag("b2c_audience", 0))
	var complexity: int = _shipped_total_complexity()
	var tech: int = GameState.get_founder_skill("tech")
	var rate: float = maxf(WEAR_FLOOR, audience * WEAR_AUD_COEF + float(complexity) * WEAR_CPLX_COEF - float(tech) * WEAR_TECH_REDUCER)
	var prog: float = float(GameState.get_flag("mvp_live_bug_progress", 0.0)) + rate
	var count: int = int(GameState.get_flag("mvp_live_bug_count", 0))
	while prog >= 1.0:
		count += 1
		prog -= 1.0
	GameState.set_flag("mvp_live_bug_progress", prog)
	GameState.set_flag("mvp_live_bug_count", count)
	EventBus.build_progress_changed.emit()   # canlı durum blokları saatlik repaint


static func _shipped_total_complexity() -> int:
	var total: int = 0
	for fid in GameState.get_flag("mvp_components", []):
		total += int(ProductCatalog.get_feature_by_id(String(fid)).get("complexity", 0))
	return total


# --- Bug sprint (Product Lifecycle Part 2A) — the founder's repair action ---

static func sprint_duration_for(bug_count: int) -> int:
	# Days to clear `bug_count` at the sprint rate, clamped. Shown pre-commit (§10).
	return clampi(int(ceil(float(bug_count) / float(SPRINT_BUG_FIX_PER_DAY))), MIN_SPRINT_DAYS, MAX_SPRINT_DAYS)


static func start_bug_sprint() -> bool:
	# Kurucu kararı — SAF CANLI-DURUM aksiyonu (yaşam-döngüsü fix'i): sprint artık
	# FeatureBuild taşıyıcısı/build slotu KULLANMAZ, durumu mvp_sprint_* flag'lerinde
	# yaşar. Böylece v3 geliştirilirken de sprint başlatılabilir (kanon: canlı sürümün
	# tam yaşam döngüsü — sprint erişilebilirliği dahil — build'den bağımsız).
	if GameState.get_flag("mvp_bug_sprint_active", false):
		push_warning("[ProductSystem] start_bug_sprint while a sprint is already running")
		return false
	if not GameState.get_flag("mvp_shipped", false):
		return false
	var bugs: int = int(GameState.get_flag("mvp_live_bug_count", 0))
	if bugs <= 0:
		return false
	GameState.set_flag("mvp_bug_sprint_active", true)   # bedel: kapasite havuzu — build'le paralelse ikisi de yavaşlar (capacity_speed_factor)
	GameState.set_flag("mvp_sprint_days_total", sprint_duration_for(bugs))
	GameState.set_flag("mvp_sprint_days_elapsed", 0.0)
	GameState.set_flag("mvp_sprint_fix_progress", 0.0)
	_record_sprint_and_check_engineer()
	if OS.is_debug_build():
		print("[ProductSystem] Bug sprint started: %d bugs, %d days" % [bugs, int(GameState.get_flag("mvp_sprint_days_total", 0))])
	return true


static func _tick_live_sprint_hourly(f: float = 1.0) -> void:
	# Flag-bazlı sprint tiki: canlı bug'ları düzgünce temizler, süre dolunca
	# sprint'i kapatır. Build pipeline'ına hiç dokunmaz.
	var prog: float = float(GameState.get_flag("mvp_sprint_fix_progress", 0.0))
	var count: int = int(GameState.get_flag("mvp_live_bug_count", 0))
	prog -= f * float(SPRINT_BUG_FIX_PER_DAY) / float(HOURS_PER_BUILD_DAY)
	while prog <= -1.0 and count > 0:
		count -= 1
		prog += 1.0
	GameState.set_flag("mvp_sprint_fix_progress", prog)
	GameState.set_flag("mvp_live_bug_count", max(0, count))
	GameState.set_flag("mvp_live_bug_progress", 0.0)
	var elapsed: float = float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0)) + f / float(HOURS_PER_BUILD_DAY)
	GameState.set_flag("mvp_sprint_days_elapsed", elapsed)
	if elapsed >= float(GameState.get_flag("mvp_sprint_days_total", 1)):
		GameState.set_flag("mvp_bug_sprint_active", false)
		GameState.set_flag("bug_sprint_just_done", true)   # one-shot, consumed by Frank
		if OS.is_debug_build():
			print("[ProductSystem] Bug sprint complete. live_bug now %d" % int(GameState.get_flag("mvp_live_bug_count", 0)))
	EventBus.build_progress_changed.emit()   # sprint banner'ı saatlik akar


static func _record_sprint_and_check_engineer() -> void:
	# HR-bridge seed (light): remember recent sprint days; too many in the window → a
	# needs_engineer signal + Frank line. NO real hire (separate HR task).
	var history: Array = GameState.get_flag("bug_sprint_days", [])
	var recent: Array = []
	for d in history:
		if GameState.day - int(d) < ENGINEER_WINDOW_DAYS:
			recent.append(int(d))
	recent.append(GameState.day)
	GameState.set_flag("bug_sprint_days", recent)
	if recent.size() >= ENGINEER_SPRINT_THRESHOLD:
		GameState.set_flag("needs_engineer", true)


# =========================================================================
#  Deterministik eksenler (Rev3, Director decision 1)
# =========================================================================

static func projected_axes(new_feature_ids: Array, strengthen_ids: Array, base_dims: Dictionary) -> Dictionary:
	# TEK kaynak: kurma-ekranı radar önizlemesi + commit damgası + v2 önizleme —
	# hepsi BU fonksiyonu okur → önizleme == ship yapısal garanti.
	# v1: base = sıfırlar. v2+: base = canlı mvp_* değerleri.
	# Her feature: dimension_contribution'daki 1-2 eksene TAM SAYI katkı.
	# Her strengthen pick: dominant eksenine (_dominant_axis_of) STRENGTHEN_AXIS_BONUS.
	var out := {
		"innovation": float(base_dims.get("innovation", 0.0)),
		"stability": float(base_dims.get("stability", 0.0)),
		"experience": float(base_dims.get("experience", 0.0)),
	}
	for fid in new_feature_ids:
		var dc: Dictionary = ProductCatalog.get_feature_by_id(String(fid)).get("dimension_contribution", {})
		for ax in QualityModel.AXES:
			out[ax] = float(out[ax]) + float(dc.get(ax, 0))
	for sid in strengthen_ids:
		var ax_s: String = _dominant_axis_of(String(sid))
		out[ax_s] = float(out[ax_s]) + STRENGTHEN_AXIS_BONUS
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


static func _sync_legacy_quality(b: FeatureBuild) -> void:
	# Keep the derived legacy `quality` int aligned with the normalized economy
	# composite (effective stability) so any not-yet-migrated b.quality reader works.
	var axes: Array = ProductCatalog.get_quality_axes(b.sub_product_type_id)
	b.quality = int(round(QualityModel.normalized_from_dims(QualityModel.economy_dims_from_build(b), axes)))


# --- Yayınla (Rev3: yalnız BETA'dan; erken-ship yolu kapandı) ---

static func launch() -> void:
	# Player pressed Yayınla on the tracker. Stamp launch state, fire ship
	# moment cinematic, then ship_active_build clears active_build when the
	# player dismisses the modal (via the choice's ship_active_build modifier).
	# Rev3: YALNIZ Beta'dan ("bugfix") çağrılabilir — erken ship kesintisi öldü;
	# Beta içinde erken basmanın bedeli zaten açık bug'lar (effective_stability).
	if active_build == null:
		push_warning("[ProductSystem] launch called with no active build")
		return
	if active_build.current_phase != "bugfix":
		push_warning("[ProductSystem] launch outside beta phase ignored (was %s)" % active_build.current_phase)
		return
	# Apply critical-bug penalty if the player chose to ship with an unfixed
	# bug (set by ev_mvp_bugfix_001_critical_bug "Bırak, gönder"). Per-run flag
	# is consumed here.
	if GameState.get_flag("critical_bug_unfixed", false):
		active_build.bug_count += CRITICAL_BUG_LAUNCH_PENALTY
		GameState.set_flag("critical_bug_unfixed", false)
	# Product Lifecycle Part 2B: is this a v2+ ship (increment version, merge axes) or
	# the first launch (version 1)? Captured before the snapshot below.
	var is_ver: bool = active_build.is_version_build
	# Display-only: snapshot the PREVIOUS version's axes BEFORE overwriting, so the
	# detail view can show a version-over-version delta ("this version grew İnovasyon
	# +2"). First launch has no prior flag → default to the new value → delta 0.
	GameState.set_flag("mvp_innovation_prev", GameState.get_flag("mvp_innovation", active_build.innovation))
	GameState.set_flag("mvp_stability_prev", GameState.get_flag("mvp_stability", active_build.stability))
	GameState.set_flag("mvp_experience_prev", GameState.get_flag("mvp_experience", active_build.experience))
	# Deterministik eksen damgası: build'in commit'te sabitlenen (+ event delta'lı)
	# değerleri canlıya yazılır. v2+ için bu, önceki canlı + yeni katkılar toplamıdır
	# (start_version_build zaten canlıdan seed'ledi) = merge.
	GameState.set_flag("mvp_innovation", active_build.innovation)
	GameState.set_flag("mvp_stability", active_build.stability)
	GameState.set_flag("mvp_experience", active_build.experience)
	GameState.set_flag("mvp_bug_count_at_launch", active_build.bug_count)   # frozen historical snapshot
	# Product Lifecycle Part 2A: the LIVE bug count starts at launch value, then
	# accrues via post-ship wear (economy reads this one).
	GameState.set_flag("mvp_live_bug_count", active_build.bug_count)
	GameState.set_flag("mvp_live_bug_progress", 0.0)
	# Part 2B: v2+ increments the version (title shows "· v2 · canlı"); first launch = 1.
	if is_ver:
		GameState.set_flag("mvp_version", int(GameState.get_flag("mvp_version", 1)) + 1)
	else:
		GameState.set_flag("mvp_version", 1)
	# Backward-compat bridge: derived normalized composite (economy dims) so any
	# not-yet-migrated get_flag("mvp_quality", …) reader can't silently fall to 50.
	var launch_axes: Array = ProductCatalog.get_quality_axes(active_build.sub_product_type_id)
	GameState.set_flag("mvp_quality", int(round(
		QualityModel.normalized_from_dims(QualityModel.economy_dims_from_build(active_build), launch_axes))))
	GameState.set_flag("mvp_product_name", active_build.product_name)
	# PostShip sales model selectors — SalesSystem / detail view branch on these.
	GameState.set_flag("mvp_sub_product_type_id", active_build.sub_product_type_id)
	GameState.set_flag("mvp_market_type", ProductCatalog.get_market_type(active_build.sub_product_type_id))
	_trigger_ship_moment(is_ver)


# --- Public helpers ---

static func get_active_build() -> FeatureBuild:
	return active_build


static func start_build(
	sub_product_type_id: String,
	feature_ids: Array,
	assigned_engineer_id: String,
	product_name: String = ""
) -> bool:
	if active_build != null:
		push_warning("[ProductSystem] start_build called while build already active")
		return false
	# Validate sub-product type
	var sub_type: Dictionary = ProductCatalog.get_sub_product_type_by_id(sub_product_type_id)
	if sub_type.is_empty():
		push_warning("[ProductSystem] start_build invalid sub_product_type_id: %s" % sub_product_type_id)
		return false
	# Rev3: seçim limiti kalktı — tek feature meşru build; yalnız boş liste reddedilir.
	if feature_ids.is_empty():
		push_warning("[ProductSystem] start_build with empty feature list")
		return false
	# Validate all features belong to the sub-product type's pool
	var pool: Array = ProductCatalog.get_feature_pool(sub_product_type_id)
	var pool_ids: Array[String] = []
	for f in pool:
		pool_ids.append(String(f.get("id", "")))
	for fid in feature_ids:
		if not pool_ids.has(String(fid)):
			push_warning("[ProductSystem] start_build feature %s not in pool for %s" % [fid, sub_product_type_id])
			return false
	# Onboarding rework 2026-07-16: subgenre is no longer chosen at onboarding —
	# the committed product decides it (write-through via the GameState seam so
	# subgenre event conditions + Meridian dimension seeding keep working).
	var pool_key: String = ProductCatalog.get_pool_of(sub_product_type_id)
	if pool_key != "":
		GameState.set_subgenre(pool_key)
	var b: FeatureBuild = FeatureBuild.new()
	b.id = "mvp_build_001"
	b.sub_product_type_id = sub_product_type_id
	var typed_features: Array[String] = []
	for fid in feature_ids:
		typed_features.append(String(fid))
	b.feature_ids = typed_features
	b.assigned_engineer_id = assigned_engineer_id
	b.lead_engineer_id = assigned_engineer_id   # SORUMLU (Rev3: hız formülünün lead'i; boş → kurucu)
	var st_name: String = String(sub_type.get("name_human", sub_type.get("name", sub_product_type_id)))
	b.product_name = product_name.strip_edges() if product_name.strip_edges() != "" else st_name
	b.start_day = GameState.day
	# Rev3 deterministik eksenler: commit'te damgalanır (v1 base = sıfırlar),
	# build boyunca SABİT — yalnız event dimension_delta oynatır.
	var axes0: Dictionary = projected_axes(typed_features, [], {})
	b.innovation = float(axes0["innovation"])
	b.stability = float(axes0["stability"])
	b.experience = float(axes0["experience"])
	b.bug_count = _seed_feature_bugs(typed_features)   # v1: every selected feature is new
	b.bug_progress = 0.0
	b.is_mvp = true
	b.current_phase = "iteration"
	# Rev3 efor engine: süre türetilir (efor / hız), sabit gün modeli öldü.
	b.total_efor = float(ProductCatalog.sum_efor(typed_features))
	b.efor_spent = 0.0
	# Backward compat — populate the legacy component list.
	b.component_ids = typed_features
	b._sync_status_from_phase()
	_sync_legacy_quality(b)
	# Üçüncü-parti maliyet (API/lisans) commit'te BİR KEZ tahsil edilir (Write-Through:
	# Finance owns cash). Affordability gate yok — nakit eksiye düşebilir (iflas baskısı).
	FinanceSystem.apply_one_time_cost(ProductCatalog.sum_cost(typed_features), "build_commit")
	active_build = b
	EventBus.build_phase_changed.emit("iteration")
	if OS.is_debug_build():
		print("[ProductSystem] Build started: %s with %d features, total_efor=%.0f cost=$%d" % [
			b.id, b.feature_ids.size(), b.total_efor, ProductCatalog.sum_cost(typed_features)])
	return true


# --- Version build (Product Lifecycle Part 2B) — the growth arm ---

static func start_version_build(new_feature_ids: Array, assigned_engineer_id: String = "", strengthen_feature_ids: Array = []) -> bool:
	# v2+ reuses the whole build flow, but SEEDS axes from the live product (not 0) and
	# unions new features onto the shipped set. KANON: v-build canlı ürünün ekonomisini
	# DONDURMAZ; §10 bedeli = süre + yeni bug'lar.
	# Pool-deepening: when the pool is exhausted, pass strengthen_feature_ids (⊆ mvp_components)
	# instead of new features → the build deepens those axes and never locks.
	if active_build != null:
		push_warning("[ProductSystem] start_version_build while a build is active")
		return false
	if not GameState.get_flag("mvp_shipped", false):
		push_warning("[ProductSystem] start_version_build with no live product")
		return false
	var sub_id: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	# Validate new features belong to the sub-type pool (mirror start_build).
	var pool_ids: Array[String] = []
	for f in ProductCatalog.get_feature_pool(sub_id):
		pool_ids.append(String(f.get("id", "")))
	# Union = existing shipped components + new (dedup, order-stable).
	var union_ids: Array[String] = []
	for fid in GameState.get_flag("mvp_components", []):
		union_ids.append(String(fid))
	var existing_count: int = union_ids.size()
	# Pool-deepening: strengthen picks must be EXISTING product features (⊆ mvp_components).
	# Validated here while union_ids is still exactly the shipped set. Dedup + clamp to the cap
	# (defense — the UI also enforces STRENGTHEN_MAX_PER_VERSION).
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
	# THE LOCK, CONDITIONAL: a new feature is required ONLY when not strengthening. When
	# the pool is exhausted the player strengthens instead → the version build never locks.
	# (Rev3: üst feature limiti kalktı — havuz boyutu doğal tavan.)
	if union_ids.size() <= existing_count and typed_strengthen.is_empty():
		push_warning("[ProductSystem] v2 needs >=1 new feature OR >=1 strengthen")
		return false

	var next_version: int = int(GameState.get_flag("mvp_version", 1)) + 1
	var b: FeatureBuild = FeatureBuild.new()
	b.id = "mvp_build_v%d" % next_version
	b.sub_product_type_id = sub_id
	b.feature_ids = union_ids
	b.component_ids = union_ids
	b.strengthened_feature_ids = typed_strengthen   # pool-deepening picks
	b.assigned_engineer_id = assigned_engineer_id
	b.lead_engineer_id = assigned_engineer_id
	b.product_name = String(GameState.get_flag("mvp_product_name", ""))
	b.start_day = GameState.day
	# KEY DIFFERENCE from start_build (base = zeros): v2 SEEDS axes from the live product;
	# yeni katkılar + strengthen bonusları üstüne biner → ship = önceki canlı + toplamlar.
	var base_dims := {
		"innovation": float(GameState.get_flag("mvp_innovation", 0.0)),
		"stability": float(GameState.get_flag("mvp_stability", 0.0)),
		"experience": float(GameState.get_flag("mvp_experience", 0.0)),
	}
	var axes2: Dictionary = projected_axes(typed_new, typed_strengthen, base_dims)
	b.innovation = float(axes2["innovation"])
	b.stability = float(axes2["stability"])
	b.experience = float(axes2["experience"])
	b.bug_count = int(GameState.get_flag("mvp_live_bug_count", 0))   # inherit live bugs (sprint first for a clean v2)
	b.bug_progress = 0.0
	b.bug_count += _seed_feature_bugs(typed_new)   # v2: ONLY newly-added features seed; hardening (typed_new empty) seeds 0
	b.is_mvp = true
	b.is_version_build = true
	b.current_phase = "iteration"
	# Rev3 efor: yalnız YENİ iş sayılır (yeni feature eforu + strengthen pick başına sabit).
	b.total_efor = float(ProductCatalog.sum_efor(typed_new) + STRENGTHEN_EFOR * typed_strengthen.size())
	b.efor_spent = 0.0
	b._sync_status_from_phase()
	_sync_legacy_quality(b)
	# Maliyet: YALNIZ yeni feature'lar (inherited/strengthen asla yeniden tahsil edilmez).
	FinanceSystem.apply_one_time_cost(ProductCatalog.sum_cost(typed_new), "version_build_commit")
	active_build = b
	EventBus.build_phase_changed.emit("iteration")
	if OS.is_debug_build():
		print("[ProductSystem] v%d build started: %d features (union), total_efor=%.0f, seeded I%d/S%d/E%d bugs=%d" % [
			next_version, b.feature_ids.size(), b.total_efor,
			int(b.innovation), int(b.stability), int(b.experience), b.bug_count])
	return true


static func cancel_build() -> void:
	if active_build == null:
		return
	active_build.current_phase = "cancelled"
	active_build._sync_status_from_phase()
	EventBus.build_phase_changed.emit("cancelled")
	active_build = null


# --- Event modifier hooks ---

static func apply_speed_bonus(days: int) -> void:
	# days is negative to speed up; positive to slow down. Rev3: "+N gün" mevcut
	# ekip hızında efora çevrilip TOPLAMA eklenir — faz sınırları (oranlar) kayar,
	# fazlar ratchet (geri gitmez). Floor: total asla harcananın (ve 1 eforun)
	# altına inmez — negatif bonus build'i en fazla "bitmiş"e çeker.
	if active_build == null:
		return
	var b := active_build
	b.total_efor = maxf(maxf(1.0, b.efor_spent), b.total_efor + float(days) * team_speed(b))


static func apply_quality_bonus(amount: int) -> void:
	# Legacy event modifier alias → innovation axis (flat add, floor 0).
	apply_dimension_delta("innovation", amount)


static func apply_dimension_delta(axis: String, amount: int) -> void:
	# Build-event modifier (Rev3): DÜZ ekleme, taban 0 — grow() yok (grow rakiplerde
	# yaşamaya devam eder). Build event'leri deterministik tabandan oynanan sapmalardır:
	# event delta'sı yoksa önizleme == ship; her delta event_modal'da görünür rozet taşır.
	if active_build == null:
		return
	if not (axis in QualityModel.AXES):
		axis = "innovation"
	match axis:
		"innovation": active_build.innovation = maxf(0.0, active_build.innovation + float(amount))
		"stability": active_build.stability = maxf(0.0, active_build.stability + float(amount))
		"experience": active_build.experience = maxf(0.0, active_build.experience + float(amount))
	_sync_legacy_quality(active_build)


static func apply_bug_delta(amount: int) -> void:
	# Build-event modifier: add (+) or clear (−) bugs directly.
	if active_build == null:
		return
	active_build.bug_count = max(0, active_build.bug_count + amount)
	_sync_legacy_quality(active_build)


static func ship_active_build() -> void:
	# Narrative-only — sets world-state flags, clears active build.
	# NO economic delta (no set_mrr / set_cash / set_brand / set_reputation).
	# Called via the ship_moment modal's ship_active_build modifier after the
	# player dismisses the cinematic.
	if active_build == null:
		push_warning("[ProductSystem] ship_active_build called with no active build")
		return
	GameState.set_flag("mvp_shipped", true)
	# AYIN OLAYI (Spec 3 §4, working copy) — version-aware ship line.
	var ship_ver: int = int(GameState.get_flag("mvp_version", 1))
	GameState.submit_month_highlight(
		"İlk versiyon yayında" if ship_ver <= 1 else "v%d yayında" % ship_ver, 50)
	# Display-only: stamp the FIRST ship day once, so the status chip can read the
	# product's live age ("N gün canlı"). Not overwritten on later versions.
	if not GameState.has_flag("mvp_launch_day"):
		GameState.set_flag("mvp_launch_day", GameState.day)
	# Rev3: SÜRÜMLER satırının verisi — her ship bir kayıt ekler [{version, day}].
	var vhist: Array = GameState.get_flag("mvp_version_history", [])
	vhist.append({"version": ship_ver, "day": GameState.day})
	GameState.set_flag("mvp_version_history", vhist)
	GameState.set_flag("mvp_components", active_build.component_ids)
	# Part 2B: a version build carried the union feature set → mvp_components now reflects the
	# larger product (wear reads the new complexity).
	active_build.status = "shipped"
	active_build.current_phase = "shipped"
	EventBus.build_phase_changed.emit("shipped")
	active_build = null
	if OS.is_debug_build():
		print("[ProductSystem] Build shipped. mvp_shipped flag set.")


# =========================================================================
#  Canlı ürün sağlık türetmeleri (Rev3 Ürün Detayı verisi) — id döner, UI TR'ler
# =========================================================================

static func _bug_trend_delta() -> int:
	# Pencere uçları farkı (son - ilk); <2 örnek → 0 (henüz trend yok).
	var hist: Array = GameState.get_flag("mvp_bug_history", [])
	if hist.size() < 2:
		return 0
	return int(hist[hist.size() - 1]) - int(hist[0])


static func bug_trend() -> String:
	# "artiyor" | "sabit" | "azaliyor" — |delta| >= TREND_DELTA yön verir.
	var delta: int = _bug_trend_delta()
	if delta >= TREND_DELTA:
		return "artiyor"
	if delta <= -TREND_DELTA:
		return "azaliyor"
	return "sabit"


static func health_state() -> String:
	# "saglikli" ⇔ effective/raw stability >= HEALTH_EFF_STAB_RATIO VE bug artışı
	# TREND_SPIKE altında; aksi "riskli".
	var raw: float = float(GameState.get_flag("mvp_stability", 0.0))
	var eff: float = QualityModel.effective_stability(raw, int(GameState.get_flag("mvp_live_bug_count", 0)))
	var ratio: float = eff / maxf(raw, 0.001)
	if ratio >= HEALTH_EFF_STAB_RATIO and _bug_trend_delta() < TREND_SPIKE:
		return "saglikli"
	return "riskli"


static func product_bug_risk() -> String:
	# "dusuk" | "orta" | "yuksek" — canlı bug / ship edilmiş toplam complexity oranı.
	var ratio: float = float(int(GameState.get_flag("mvp_live_bug_count", 0))) / float(max(1, _shipped_total_complexity()))
	if ratio >= BUG_RISK_YUKSEK:
		return "yuksek"
	if ratio >= BUG_RISK_ORTA:
		return "orta"
	return "dusuk"


# --- Synthetic ship-moment event ---

static func _trigger_ship_moment(is_version: bool = false) -> void:
	var ev: GameEvent = _build_version_ship_moment_event() if is_version else _build_ship_moment_event()
	EventManager.enqueue(ev)


static func _build_version_ship_moment_event() -> GameEvent:
	# Lighter, version-aware ship moment (Part 2B). Not one-shot — each v2/v3 fires it.
	var ev: GameEvent = GameEvent.new()
	ev.id = "ev_mvp_version_ship_moment"
	ev.category = "reactive"
	var ver: int = int(GameState.get_flag("mvp_version", 2))
	ev.title = "v%d yayında" % ver
	ev.subtitle = ""
	ev.illustration_path = ""
	ev.character_id = "char_mentor_frank"
	ev.body_text = "Yeni sürümü yayına gönderiyorsun. Frank ekrana bakıyor, başını hafifçe sallıyor.\n\n\"Büyüdü. Yeni özellikler tuttu — ama yeni yüzey, yeni hata demek. Gözünü ayırma.\"\n\nKullanıcılar farkı görecek. Rakipler de."
	ev.cooldown_days = 0
	ev.one_shot = false
	ev.priority = 10
	ev.tags = ["build_safe", "ship_moment"]
	ev.trigger_conditions = []
	var choice: EventChoice = EventChoice.new()
	choice.label = "Yayına devam"
	choice.modifiers = [{"type": "ship_active_build"}]
	choice.unlock_condition = {}
	choice.unlock_reason_text = ""
	var choices: Array[EventChoice] = []
	choices.append(choice)
	ev.choices = choices
	return ev


static func _build_ship_moment_event() -> GameEvent:
	var ev: GameEvent = GameEvent.new()
	ev.id = "ev_mvp_ship_moment"
	ev.category = "reactive"
	ev.title = "İlk versiyonun hazır"
	ev.subtitle = ""
	ev.illustration_path = ""
	ev.character_id = "char_mentor_frank"
	ev.body_text = "Demo'ya bir kez daha bakıyorsun. Frank arkanda duruyor, telefonuna bakmıyor.\n\n\"Tamam,\" diyor. \"Bu kadar kötü değil.\"\n\nYayına alıyorsun. Birkaç dakika sonra GitHub'da depo herkese açık, küçük bir açılış sayfası canlı, Frank elini cebine atıyor.\n\n\"Şimdi zor kısmı başlıyor. Bunun parasını verecek birini bulmamız lazım.\""
	ev.cooldown_days = 0
	ev.one_shot = true
	ev.priority = 10
	# build_safe so EventManager._is_eligible() doesn't suppress the ship
	# cinematic itself during the active build it's meant to close out.
	ev.tags = ["build_safe", "ship_moment"]
	ev.trigger_conditions = []
	var choice: EventChoice = EventChoice.new()
	choice.label = "Yayınla"
	choice.modifiers = [{"type": "ship_active_build"}]
	choice.unlock_condition = {}
	choice.unlock_reason_text = ""
	var choices: Array[EventChoice] = []
	choices.append(choice)
	ev.choices = choices
	return ev
