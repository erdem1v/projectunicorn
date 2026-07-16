class_name ProductSystem
extends RefCounted

# Slot 1 daily tick per TECH_SPEC §8.2. Pure logic (TECH_SPEC §8.3).
#
# Dört-faz build akışı (Build Tracker Card spec, Software Inc. modeli):
#   planning → iteration (TASARIM) → development (GELİŞTİRME) → bugfix (BETA) → shipped.
# Görünen adlar TR (TASARIM/GELİŞTİRME/BETA/YAYINLANDI); iç faz string'leri
# değişmedi — event trigger'ları (ev_mvp_bugfix_*) current_phase ile eşleşiyor.
#
# - TASARIM: iterasyonlar OTOMATİK döner (1→2→3...), oyuncuya sorulmaz; her tur
#   inovasyon/kullanılabilirlik büyütür + runway yakar. Bug ÜRETİLMEZ. Oyuncu
#   tracker kartındaki "Geliştir →" ile fazdan çıkar (enter_development).
# - GELİŞTİRME: kod tabanı %0→100 (development_days_elapsed/total) otomatik dolar;
#   bug YALNIZ bu fazda üretilir. %100'de OTOMATİK beta'ya geçer (auto-ship yok).
#   Oyuncu erken "Yayınla" diyebilir (launch — bitmemiş kod bedeli + açık bug'lar canlıya).
# - BETA: eksenler KİLİTLİ (growth yok); test gizli bug'ları BULUR ve ÇÖZER
#   (bugs_found/bugs_fixed). Oyuncu ne kadar beklerse o kadar temiz ship.
# - Ship moment narrative-only kalır — launch() durumu damgalar, modal seçimi
#   ship_active_build'i çağırır. Kalan açık bug'lar mvp_live_bug_count'a taşınır
#   → post-ship şikayet boru hattı (effective_stability → satisfaction → event).

# --- Phase machinery ---
const ITERATION_LENGTH_DAYS := 4
const DEVELOPMENT_DAYS_BASE := 6
# Product Lifecycle Part 2B: total feature count a version build (v1 union + new) may carry.
const MAX_VERSION_FEATURES := 8
# Pool-deepening (feature-exhaustion unlock): when the pool is exhausted the player
# STRENGTHENS existing features instead of adding new ones. Cap on picks per version + a
# flat per-day growth bonus to each strengthened feature's dominant axis (on top of the
# weight redistribution in FeatureBuild) so the targeted axis visibly outgrows a plain
# rebuild. BALANCE-TUNABLE.
const STRENGTHEN_MAX_PER_VERSION := 2
const STRENGTHEN_FLAT_PER_DAY := 1.5
const POLISH_BUG_FIX_PER_DAY := 4        # bugs cleared per day during bugfix
const HOURS_PER_BUILD_DAY := 24          # quality/bugs accrue hourly (~daily_raw / 24)

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

# --- Multi-dimensional per-phase quality growth (Product Lifecycle Part 1) ---
# Per-tick raw growth per axis, routed through QualityModel.grow(_, _, ASYMPTOTE)
# so every gain is bounded below the structural ceiling (a Phase-1 build's each
# axis stays < PHASE1_AXIS_ASYMPTOTE forever). Shaped by the build's feature
# dimension mix (_shaped_raw). All BALANCE-TUNABLE (Erdem tunes last).
const ITER_INNO := 2.0            # iteration = design exploration → innovation
const ITER_USAB := 1.5            #            + usability
const DEV_STAB_BASE := 1.5        # development = build-out → stability (+ tech)
const DEV_USAB := 1.0             #            + usability
const TECH_STAB_COEF := 0.75      # founder tech skill → stability/tick
# BUGFIX_STAB/BUGFIX_USAB kaldırıldı (Tracker Card): BETA'da eksenler KİLİTLİ —
# "kilitli" chip'i yalan söylemesin; Karar%'ın beta'da toparlaması yine görünür
# çünkü effective stability bug düştükçe iyileşir. GERÇEK denge değişimi
# (eski bugfix 2.0/gün stability büyütüyordu) — Erdem balance-pass'te yargılar.
# Feature-mix shaping: effective raw = raw * (DIM_BASE_SHARE + DIM_FEATURE_SHARE *
# axis_share*3). Equal mix (share 1/3 → *3 = 1) → neutral 1.0; a favored axis grows
# faster, a starved one slower but never zero.
const DIM_BASE_SHARE := 0.5
const DIM_FEATURE_SHARE := 0.5

# Bonus bug count applied at launch when the player left a critical bug
# in (ev_mvp_bugfix_001_critical_bug "Bırak, gönder" choice → flag).
const CRITICAL_BUG_LAUNCH_PENALTY := 5

# --- Beta + erken-ship (Build Tracker Card, dört-faz akış) ---
# BETA: test gizli bug'ları bulur (find) ve bulunanları çözer (fix: mevcut
# POLISH_BUG_FIX_PER_DAY hızı). working value — Erdem balance-pass.
const BETA_BUG_FIND_PER_DAY := 6.0
# Erken ship (development'tan Yayınla): bitmemiş kod oranı kadar tüm eksenlerden
# kesinti — kod %0'da %50 kesinti, %100'de 0. working value — Erdem balance-pass.
const EARLY_SHIP_AXIS_HAIRCUT := 0.5
# Build iptali: ilk gün "bedelsiz" sayılır (onay metni basit — yanlış-tık affı);
# sonrasında onay yanan gün/parayı söyler. Mekanik refund yok (yanan yanmıştır).
# working value — Erdem balance-pass.
const CANCEL_FREE_DAYS := 1

# --- v2+ süre modeli ---
# v2 build TÜM ürünü yeniden yazmaz — süre YENİ işe dayanır: taban (entegrasyon +
# regresyon maliyeti) + yeni/güçlendirilen feature karmaşıklığı × faktör (yaşayan
# koda dokunmak yeşil alandan pahalı → "2 günde feature" çıkmaz). Eski model
# (taban + TÜM union) tam v1-rebuild gibi okunuyordu: +4g'lik tek feature için
# "~14 gün" — oyuncuya saçma. working values — Erdem balance-pass.
const V2_DEV_DAYS_BASE := 3
const V2_COMPLEXITY_FACTOR := 1.5

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
	# B2: build phase progress is HOURLY now (hourly_tick) so it reads smooth,
	# not day-jumps. Nothing product-side is genuinely daily anymore — this slot-1
	# entry is kept as a stub for any future daily product logic.
	pass


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


# --- Hourly phase-progress helpers (B2: formerly the daily _tick_*_day funcs) ---
# One in-game hour = 1/HOURS_PER_BUILD_DAY of a day, so a 4-day iteration drains
# over 96 hourly steps — SAME total duration, smooth motion. Transitions fire on
# the hour the fractional counter crosses its threshold.

static func _advance_iteration_hour(f: float = 1.0) -> void:
	# Auto-iterasyon (Tracker Card spec): tur dolunca OYUNCUYA SORMADAN yeni tura
	# geçer (sayaç kesiri korunur — += ile). Fazdan çıkış (enter_development)
	# oyuncunun kartta "Geliştir →" kararı; tur-içi ilerleme otomatik.
	active_build.iteration_days_in_current -= f / float(HOURS_PER_BUILD_DAY)
	if active_build.iteration_days_in_current <= 0.0:
		active_build.iteration_count += 1
		# Yeni tur standart uzunlukta başlar — event uzatması SONRAKI tura taşınmaz.
		active_build.iteration_round_days = float(ITERATION_LENGTH_DAYS)
		active_build.iteration_days_in_current += float(ITERATION_LENGTH_DAYS)
		if OS.is_debug_build():
			print("[ProductSystem] iteration auto-advance → iter %d" % active_build.iteration_count)


static func _apply_tech_debt_due(b: FeatureBuild) -> void:
	# Dev event'lerinde alınan tech-debt gerçek bug'a döner — hem normal dev→beta
	# geçişinde hem erken ship'te uygulanır (borçtan ship'le kaçılamaz).
	if GameState.get_flag("tech_debt_birikti", false):
		b.bug_count += TECH_DEBT_BUG_PENALTY
		GameState.set_flag("tech_debt_birikti", false)


static func _advance_development_hour(f: float = 1.0) -> void:
	active_build.development_days_elapsed += f / float(HOURS_PER_BUILD_DAY)
	if active_build.development_days_elapsed >= float(active_build.development_days_total):
		_apply_tech_debt_due(active_build)
		active_build.current_phase = "bugfix"
		active_build._sync_status_from_phase()
		active_build.bug_progress = 0.0
		# Beta sayaçları sıfırdan başlar; dev'in ürettiği bug'lar "gizli" havuz olarak
		# bug_count içinde durur, test onları BULUR (working call — Erdem gözden geçirir:
		# alternatif, bir kısmını önceden-bulunmuş saymaktı).
		active_build.bugs_found = 0
		active_build.bugs_fixed = 0
		active_build.bug_find_progress = 0.0
		active_build.bug_fix_progress = 0.0
		# Snapshot bug count at bugfix entry so PostShipView / HUD can read
		# "started with M, shipped with N". Keyed by build id.
		GameState.set_flag("bug_count_at_bugfix_start_%s" % active_build.id, active_build.bug_count)
		_sync_legacy_quality(active_build)
		EventBus.build_phase_changed.emit("bugfix")
		if OS.is_debug_build():
			print("[ProductSystem] Development complete → BETA. quality=%d hidden_bugs=%d" % [active_build.quality, active_build.bug_count])


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


# --- Hourly tick (Product Lifecycle Part 1): smooth quality + bug accrual ---
# Called by TimeManager._tick_product_hourly. Quality breathes hour by hour (from
# 0), instead of jumping on day boundaries.

static func hourly_tick(_hour: int) -> void:
	# Kapasite çarpanı HER SAAT taze hesaplanır (mid-job hire/fire anında etki eder).
	# Zaman dilatasyonu: çarpan işin TÜM saatlik çıktısına uygulanır (süre + kalite +
	# bug üretimi + strengthen + beta find/fix) — tek başına koşan işin toplam çıktısı
	# bit-bit aynı kalır, paralel işler aynı çıktıyı daha uzun duvar-saatine yayar.
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
	#    (sprint artık slot kullanmaz; saf canlı-durum aksiyonu).
	if active_build == null:
		return
	match active_build.current_phase:
		"iteration":
			# TASARIM: auto-döngü + tasarım eksenleri büyür. Bug ÜRETİLMEZ
			# (Tracker Card spec: bug yalnız GELİŞTİRME fazında doğar).
			_advance_iteration_hour(f)
			_grow_hourly(active_build, "innovation", ITER_INNO, f)
			_grow_hourly(active_build, "usability", ITER_USAB, f)
		"development":
			var tech: int = GameState.get_founder_skill("tech")
			_grow_hourly(active_build, "stability", DEV_STAB_BASE + float(tech) * TECH_STAB_COEF, f)
			_grow_hourly(active_build, "usability", DEV_USAB, f)
			_accrue_bugs_hourly(f)
			_advance_development_hour(f)   # may transition to bugfix (BETA)
		"bugfix":
			# BETA: eksenler KİLİTLİ (growth yok — kart "kilitli" chip'i doğruyu
			# söyler); test bug bulur + çözer.
			_tick_beta_hourly(f)
		_:
			return
	# Pool-deepening: strengthened features push their dominant axis a little every growth
	# hour (no-op unless this is a strengthen build). "bugfix" listede YOK — beta'da
	# eksenler kilitli (Tracker Card).
	if active_build.current_phase in ["iteration", "development"]:
		_apply_strengthen_growth_hourly(active_build, f)
	EventBus.build_progress_changed.emit()


static func _grow_hourly(b: FeatureBuild, axis: String, daily_raw: float, f: float = 1.0) -> void:
	_grow_build(b, axis, _shaped_raw(b, axis, daily_raw) * f / float(HOURS_PER_BUILD_DAY))


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
	# every other bug). Duration is unaffected (that reads get_total_complexity, not bugs).
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
	EventBus.build_progress_changed.emit()   # PostShip status block repaints hourly


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
	# Flag-bazlı sprint tiki (eski carrier'lı _tick_bug_sprint_hourly +
	# _advance_bug_sprint_hour birleşimi): canlı bug'ları düzgünce temizler,
	# süre dolunca sprint'i kapatır. Build pipeline'ına hiç dokunmaz.
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
	EventBus.build_progress_changed.emit()   # PostShip sprint banner'ı saatlik akar


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


# --- Multi-dimensional growth helpers (Product Lifecycle Part 1) ---

static func _grow_build(b: FeatureBuild, axis: String, raw: float) -> void:
	# Every axis gain flows through QualityModel.grow with the Phase-1 asymptote →
	# open-ended but structurally ceilinged (< PHASE1_AXIS_ASYMPTOTE forever).
	var a: float = QualityModel.PHASE1_AXIS_ASYMPTOTE
	match axis:
		"innovation": b.innovation = QualityModel.grow(b.innovation, raw, a)
		"stability":  b.stability = QualityModel.grow(b.stability, raw, a)
		"usability":  b.usability = QualityModel.grow(b.usability, raw, a)
	_sync_legacy_quality(b)


static func _shaped_raw(b: FeatureBuild, axis: String, raw: float) -> float:
	# Feature mix steers which axis climbs fastest. share*3 ≈ [0..3] (equal = 1).
	var share: float = float(b.get_dimension_weights().get(axis, 1.0 / 3.0)) * 3.0
	return raw * (DIM_BASE_SHARE + DIM_FEATURE_SHARE * share)


# --- Pool-deepening growth (feature-exhaustion unlock) ---

static func _dominant_axis_of(fid: String) -> String:
	# The axis a feature feeds most (deterministic inno→stab→usab tiebreak).
	var dc: Dictionary = ProductCatalog.get_feature_by_id(fid).get("dimension_contribution", {})
	var best: String = "innovation"
	var best_v: float = -INF
	for ax in QualityModel.AXES:
		var v: float = float(dc.get(ax, 0.0))
		if v > best_v:
			best_v = v
			best = ax
	return best


static func _apply_strengthen_growth_hourly(b: FeatureBuild, f: float = 1.0) -> void:
	# Flat additive deepening: each strengthened feature pushes its dominant axis a little
	# every growth hour, in EVERY growth phase → the targeted axis climbs where a plain
	# rebuild grows it by 0 (e.g. innovation in development). Bounded by grow()'s asymptote.
	if b.strengthened_feature_ids.is_empty():
		return
	for fid in b.strengthened_feature_ids:
		_grow_build(b, _dominant_axis_of(fid), STRENGTHEN_FLAT_PER_DAY * f / float(HOURS_PER_BUILD_DAY))


static func _sync_legacy_quality(b: FeatureBuild) -> void:
	# Keep the derived legacy `quality` int aligned with the normalized economy
	# composite (effective stability) so any not-yet-migrated b.quality reader works.
	var axes: Array = ProductCatalog.get_quality_axes(b.sub_product_type_id)
	b.quality = int(round(QualityModel.normalized_from_dims(QualityModel.economy_dims_from_build(b), axes)))


# --- Public phase-advance API (called by the Build Tracker Card buttons) ---
# advance_iteration() silindi (Tracker Card): iterasyonlar otomatik döner,
# oyuncunun tek tasarım-fazı kararı "Geliştir →" (enter_development).

static func enter_development() -> void:
	if active_build == null or active_build.current_phase != "iteration":
		push_warning("[ProductSystem] enter_development called outside iteration phase")
		return
	active_build.current_phase = "development"
	active_build.development_days_elapsed = 0
	active_build._sync_status_from_phase()
	EventBus.build_phase_changed.emit("development")
	if OS.is_debug_build():
		print("[ProductSystem] enter_development. dev_days_total=%d iter_count=%d" % [active_build.development_days_total, active_build.iteration_count])


static func launch() -> void:
	# Player pressed Yayınla on the tracker card. Stamp launch state, fire ship
	# moment cinematic, then ship_active_build clears active_build when the
	# player dismisses the modal (via the choice's ship_active_build modifier).
	# Tracker Card: development'tan da çağrılabilir (ERKEN ship — bedeli var);
	# beta'dan (bugfix) her an çağrılabilir.
	if active_build == null:
		push_warning("[ProductSystem] launch called with no active build")
		return
	if active_build.current_phase not in ["development", "bugfix"]:
		push_warning("[ProductSystem] launch called outside development/bugfix phase (was %s)" % active_build.current_phase)
		return
	if active_build.current_phase == "development":
		# Erken ship: tech-debt borcu yine düşer (kaçış yok) + bitmemiş kod bedeli.
		_apply_tech_debt_due(active_build)
		# working formula — Erdem balance-pass: bitmemiş kod oranı kadar tüm
		# eksenlerden kesinti (kod %0'da %50, %100'de 0). Doğrudan çarpan — bu bir
		# ceza, büyüme değil; grow()/asimptotu bilinçli olarak bypass eder.
		var unfinished: float = clampf(
			1.0 - active_build.development_days_elapsed / maxf(1.0, float(active_build.development_days_total)),
			0.0, 1.0)
		var keep: float = 1.0 - EARLY_SHIP_AXIS_HAIRCUT * unfinished
		active_build.innovation *= keep
		active_build.stability *= keep
		active_build.usability *= keep
		_sync_legacy_quality(active_build)
		if OS.is_debug_build():
			print("[ProductSystem] EARLY ship from development: unfinished=%.2f keep=%.2f open_bugs=%d" % [unfinished, keep, active_build.bug_count])
	# Apply critical-bug penalty if the player chose to ship with an unfixed
	# bug (set by ev_mvp_bugfix_001_critical_bug "Bırak, gönder"). Per-run flag
	# is consumed here.
	if GameState.get_flag("critical_bug_unfixed", false):
		active_build.bug_count += CRITICAL_BUG_LAUNCH_PENALTY
		GameState.set_flag("critical_bug_unfixed", false)
	# Product Lifecycle Part 2B: is this a v2+ ship (increment version, merge grown axes) or
	# the first launch (version 1)? Captured before the snapshot below.
	var is_ver: bool = active_build.is_version_build
	# Redesign (display-only): snapshot the PREVIOUS version's axes BEFORE overwriting, so the
	# PostShip control panel can show a version-over-version delta ("this version grew İnovasyon
	# +2" — the visible proof a v-build/strengthen worked). First launch has no prior flag →
	# default to the new value → delta 0. No calculation reads these; pure display.
	GameState.set_flag("mvp_innovation_prev", GameState.get_flag("mvp_innovation", active_build.innovation))
	GameState.set_flag("mvp_stability_prev", GameState.get_flag("mvp_stability", active_build.stability))
	GameState.set_flag("mvp_usability_prev", GameState.get_flag("mvp_usability", active_build.usability))
	# Multi-dimensional snapshot (Product Lifecycle Part 1). Bug penalty above is
	# already applied, so effective stability reflects it downstream. For a version build
	# these axes are the GROWN values (seed + growth) written back over mvp_* = the merge.
	GameState.set_flag("mvp_innovation", active_build.innovation)
	GameState.set_flag("mvp_stability", active_build.stability)
	GameState.set_flag("mvp_usability", active_build.usability)
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
	GameState.set_flag("mvp_iteration_count", active_build.iteration_count)
	GameState.set_flag("mvp_product_name", active_build.product_name)
	# PostShip sales model selectors — SalesSystem / PostShipView branch on these.
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
	# Validate feature count
	if feature_ids.size() < 2 or feature_ids.size() > 4:
		push_warning("[ProductSystem] start_build invalid feature count: %d (want 2-4)" % feature_ids.size())
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
	var b: FeatureBuild = FeatureBuild.new()
	b.id = "mvp_build_001"
	b.sub_product_type_id = sub_product_type_id
	var typed_features: Array[String] = []
	for fid in feature_ids:
		typed_features.append(String(fid))
	b.feature_ids = typed_features
	b.assigned_engineer_id = assigned_engineer_id
	b.lead_engineer_id = assigned_engineer_id   # reserve seed; HR wires the real effect later
	var st_name: String = String(sub_type.get("name_human", sub_type.get("name", sub_product_type_id)))
	b.product_name = product_name.strip_edges() if product_name.strip_edges() != "" else st_name
	b.start_day = GameState.day
	# Axes born at 0 (Erdem) — a v1 is genuinely raw and climbs from nothing.
	b.innovation = 0.0
	b.stability = 0.0
	b.usability = 0.0
	b.bug_count = 0
	b.bug_progress = 0.0
	b.bug_count += _seed_feature_bugs(typed_features)   # v1: every selected feature is new
	b.is_mvp = true
	b.current_phase = "iteration"
	b.iteration_count = 1
	b.iteration_days_in_current = ITERATION_LENGTH_DAYS
	b.iteration_round_days = float(ITERATION_LENGTH_DAYS)
	b.iteration_decision_pending = false
	b.development_days_total = DEVELOPMENT_DAYS_BASE + b.get_total_complexity()
	b.development_days_elapsed = 0
	b.min_estimation_days = max(5, b.get_total_complexity() + 2)
	# Backward compat — populate legacy fields with sensible defaults
	b.component_ids = typed_features
	b.total_days = b.development_days_total
	b.days_remaining = b.development_days_total
	b._sync_status_from_phase()
	_sync_legacy_quality(b)   # derive legacy quality from the (zeroed) axes
	active_build = b
	EventBus.build_phase_changed.emit("iteration")
	if OS.is_debug_build():
		print("[ProductSystem] Build started: %s with %d features, dev_days_total=%d" % [b.id, b.feature_ids.size(), b.development_days_total])
	return true


# --- Version build (Product Lifecycle Part 2B) — the growth arm ---

static func start_version_build(new_feature_ids: Array, assigned_engineer_id: String = "", strengthen_feature_ids: Array = []) -> bool:
	# v2+ reuses the whole build flow, but SEEDS axes from the live product (not 0) and
	# unions new features onto the shipped set. Tracker Card'ta normal build gibi akar.
	# KANON: v-build canlı ürünün ekonomisini DONDURMAZ (eski growth-freeze kaldırıldı);
	# §10 bedeli = süre + yeni bug'lar.
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
	# THE LOCK, now CONDITIONAL: a new feature is required ONLY when not strengthening. When
	# the pool is exhausted the player strengthens instead → the version build never locks.
	if union_ids.size() <= existing_count and typed_strengthen.is_empty():
		push_warning("[ProductSystem] v2 needs >=1 new feature OR >=1 strengthen")
		return false
	if union_ids.size() > MAX_VERSION_FEATURES:
		push_warning("[ProductSystem] v2 exceeds MAX_VERSION_FEATURES (%d)" % MAX_VERSION_FEATURES)
		return false

	var next_version: int = int(GameState.get_flag("mvp_version", 1)) + 1
	var b: FeatureBuild = FeatureBuild.new()
	b.id = "mvp_build_v%d" % next_version
	b.sub_product_type_id = sub_id
	b.feature_ids = union_ids
	b.component_ids = union_ids
	b.strengthened_feature_ids = typed_strengthen   # pool-deepening: amplifies these axes
	b.assigned_engineer_id = assigned_engineer_id
	b.lead_engineer_id = assigned_engineer_id
	b.product_name = String(GameState.get_flag("mvp_product_name", ""))
	b.start_day = GameState.day
	# KEY DIFFERENCE from start_build (axes born at 0): v2 SEEDS from the live product, so a
	# high axis has little grow() headroom and a weak axis has lots → feeding the weak axis
	# grows fastest (the intended "strengthen your weak side, pass the rival" loop).
	b.innovation = float(GameState.get_flag("mvp_innovation", 0.0))
	b.stability = float(GameState.get_flag("mvp_stability", 0.0))
	b.usability = float(GameState.get_flag("mvp_usability", 0.0))
	b.bug_count = int(GameState.get_flag("mvp_live_bug_count", 0))   # inherit live bugs (sprint first for a clean v2)
	b.bug_progress = 0.0
	b.bug_count += _seed_feature_bugs(typed_new)   # v2: ONLY newly-added features seed; hardening (typed_new empty) seeds 0
	b.is_mvp = true
	b.is_version_build = true
	b.current_phase = "iteration"
	b.iteration_count = 1
	b.iteration_days_in_current = ITERATION_LENGTH_DAYS
	b.iteration_round_days = float(ITERATION_LENGTH_DAYS)
	b.iteration_decision_pending = false
	# v2 süresi YENİ işe dayanır (union'ın tamamına DEĞİL) — display ile aynı
	# kaynak (version_dev_days) → rozet/süre uyumsuzluğu yapısal olarak imkansız.
	var effort_ids: Array = []
	effort_ids.append_array(typed_new)
	effort_ids.append_array(typed_strengthen)
	b.development_days_total = version_dev_days(effort_ids)
	b.development_days_elapsed = 0
	b.min_estimation_days = max(5, b.get_total_complexity() + 2)
	b.total_days = b.development_days_total
	b.days_remaining = b.development_days_total
	b._sync_status_from_phase()
	_sync_legacy_quality(b)
	active_build = b
	EventBus.build_phase_changed.emit("iteration")
	if OS.is_debug_build():
		print("[ProductSystem] v%d build started: %d features (union), dev_days_total=%d, seeded I%d/S%d/U%d bugs=%d" % [
			next_version, b.feature_ids.size(), b.development_days_total,
			int(b.innovation), int(b.stability), int(b.usability), b.bug_count])
	return true


static func version_dev_days(effort_feature_ids: Array) -> int:
	# v2+ geliştirme süresi: taban + yeni/güçlendirilen feature karmaşıklığı × faktör.
	# Hem start_version_build hem ProductTab'ın projeksiyon/commit gösterimleri
	# BU fonksiyonu kullanır — tek kaynak, gösterim/gerçek süre ayrışamaz.
	var comp: int = 0
	for fid in effort_feature_ids:
		comp += int(ProductCatalog.get_feature_by_id(String(fid)).get("complexity", 0))
	return V2_DEV_DAYS_BASE + int(ceil(float(comp) * V2_COMPLEXITY_FACTOR))


static func cancel_build() -> void:
	if active_build == null:
		return
	active_build.current_phase = "cancelled"
	active_build._sync_status_from_phase()
	EventBus.build_phase_changed.emit("cancelled")
	active_build = null


# --- Event modifier hooks ---

static func apply_speed_bonus(days: int) -> void:
	# days is negative to speed up; positive to slow down. Phase-aware — applies
	# to whichever phase counter is currently active. Bugfix is open-ended so
	# speed bonuses there are no-ops (player decides when to LAUNCH).
	if active_build == null:
		return
	match active_build.current_phase:
		"iteration":
			# +gün TUR TOPLAMINI uzatır (payda); geçen gün (pay) sabit kalır.
			# elapsed = round - remaining ⇒ ikisine birden ekle. Negatif = hızlanma.
			# (Eski kod yalnız KALAN sayaca ekliyordu → "Gün 2/4"+2 → "Gün 0/4"
			# geri-gitme bug'ı; şimdi "Gün 2/6".)
			var r := active_build
			if r.iteration_round_days <= 0.0:
				r.iteration_round_days = float(ITERATION_LENGTH_DAYS)   # eski-save fallback
			r.iteration_round_days = maxf(1.0, r.iteration_round_days + float(days))
			r.iteration_days_in_current = clampf(r.iteration_days_in_current + float(days), 0.0, r.iteration_round_days)
		"development":
			active_build.development_days_total = int(maxf(active_build.development_days_elapsed, float(active_build.development_days_total + days)))


static func apply_quality_bonus(amount: int) -> void:
	# Legacy event modifier alias → innovation axis (bounded via grow()).
	apply_dimension_delta("innovation", amount)


static func apply_dimension_delta(axis: String, amount: int) -> void:
	# Build-event modifier (Product Lifecycle Part 1): grow (+) or penalize (−) one
	# quality axis. grow() keeps positive gains bounded; negatives floor at 0.
	if active_build == null:
		return
	if not (axis in QualityModel.AXES):
		axis = "innovation"
	_grow_build(active_build, axis, float(amount))


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
	# Redesign (display-only): stamp the FIRST ship day once, so the PostShip status chip can
	# read the product's live age ("N gün canlı"). Not overwritten on later versions (product
	# age is from first ship). No calculation reads it; pure display.
	if not GameState.has_flag("mvp_launch_day"):
		GameState.set_flag("mvp_launch_day", GameState.day)
	# (dead `product_quality` write removed — nobody read it; mvp_* is canonical.)
	GameState.set_flag("mvp_components", active_build.component_ids)
	# Part 2B: a version build carried the union feature set → mvp_components now reflects the
	# larger product (wear reads the new complexity).
	active_build.status = "shipped"
	active_build.current_phase = "shipped"
	EventBus.build_phase_changed.emit("shipped")
	active_build = null
	if OS.is_debug_build():
		print("[ProductSystem] Build shipped. mvp_shipped flag set.")


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
