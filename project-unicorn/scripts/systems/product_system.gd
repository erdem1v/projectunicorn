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
# - Faz bantları: %0-20 TASARIM, %20-80 GELİŞTİRME, %80-100 BETA. Software Inc. segment
#   grameri (Build Bar, 2026-08-19): TASARIM turları KENDİLİĞİNDEN zincirlenir — tur 1 =
#   tasarım bandının kendisi, dolunca tur 2 hemen başlar, ITER_ROUND_DAYS'lik her turun
#   sonunda kazanç uygulanır ve bir sonraki tur başlar, ITER_MAX_ROUNDS'a kadar (tavanda
#   park). Oyuncunun TASARIM'daki tek kararı "Geliştirmeye geç" (enter_development) —
#   tur 1 bitince açılır, YARIM TUR kazançsız terk edilir. Ek turlar eksenleri EKİP
#   tavanlarına doğru büyütür (iteration_axis_ceilings + QualityModel.grow).
#   GELİŞTİRME bandı dolunca build PARK eder (%80'de efor donuk, süre/burn akar), çıkış
#   "Beta'ya geç" (enter_beta) — oyuncunun kararı, otomatik geçiş yok. Beta'daki tek
#   aksiyon "Yayınla" (launch) — build %100'de Beta'da SÜRESİZ park eder, auto-ship YOK.
#   (Eski player-gated tur parkı ve dev→beta ratchet'i bu turda emekli oldu; consult
#   "do not touch #2" görev metniyle bilerek aşıldı — yönetmen kararı.)
# - Eksenler commit'te projected_axes ile damgalanır (katkı toplamları); build boyunca
#   yalnız event dimension_delta VE iterasyon tur kazançları oynatır. Eski "önizleme ==
#   ship" yapısal garantisi (Director decision 1, 2026-07-17) bu restorasyonla
#   "ship ≥ preview"e yumuşadı — tavan yasası yalnız TUR kazançlarını bağlar, commit
#   damgası ve event delta'ları serbest kalır.
# - Bug kanalı aynen: commit'te complexity tohumu, GELİŞTİRME bandında saatlik
#   birikim, dev→beta geçişinde tech-debt, BETA'da bul/çöz (bekleyen temiz ship'ler).
# - Ship moment narrative-only kalır — launch() durumu damgalar, modal seçimi
#   ship_active_build'i çağırır. Kalan açık bug'lar mvp_live_bug_count'a taşınır
#   → post-ship şikayet boru hattı (effective_stability → satisfaction → event).

# ==========  Rev3 EFOR/HIZ ENGINE (working values — Erdem balance-pass)  ==========
# Hız yasası (HR Coupling): speed = (FOUNDER_SPEED_COEF × kurucu Teknoloji
#                                    + EMPLOYEE_SPEED_COEF × Σ o fazın ekibinin HIZ'ı)
#                                   × koordinasyon çarpanı(sorumlu)
# ÇALIŞANLAR ARASINDA AĞIRLIK YOK (design doc §4): eski lead/assist ayrımı kalktı, sorumlunun
# kalitesi artık koordinasyon çarpanında görünüyor. İki katsayının VAR OLMA SEBEBİ iltimas
# değil, ÖLÇEK: kurucu aynı 0-9 cetvelinin 0-3 bandında (onboarding 6 puan / skill başına 3),
# çalışan dosyaları 5-8 bandında. Tek katsayı iki bandı birlikte servis edemez — biri diğerini
# ezer. Bu iki değer eşdeğerlik çıpalarından TÜRETİLDİ, seçilmedi:
#   kurucu tech-3 solo    → 1.00 × 3 = 3.0 efor/gün   (migration öncesiyle birebir)
#   pace-4 çalışan katkısı → 0.25 × 4 = 1.0 efor/gün  (eski 0.5 × tech-2 ile birebir)
## Kurucunun alan puanı başına efor/gün. 1,0'dı ve kurucu 0–5 cetvelindeydi; cetvel
## birleşince değer ikiye katlandı, katsayı yarıya indi — "kurucu tech-3 solo = 3,0
## efor/gün" çapası birebir korunuyor. Çalışan katsayısının (0,25) tam iki katı olması
## da artık düz okunuyor: aynı cetvelde kurucunun puanı çalışanınkinin iki katı sayılır.
const FOUNDER_SPEED_COEF := 0.5
const EMPLOYEE_SPEED_COEF := 0.25   # çalışanın HIZ puanı başına efor/gün
const SPEED_MIN := 1.0              # HIZ-0 ekip bile günde 1 efor ilerler (sonsuz build imkansız)
const STRENGTHEN_EFOR := 5          # bir güçlendirme pick'inin eforu (~orta feature)
const STRENGTHEN_AXIS_BONUS := 4.0  # ship'te pick'in dominant eksenine düz bonus
# Ürün Yöneticisi UZMANLIK'ı → Deneyim ekip bonusu (design doc §5, working tavan +3).
# YÜKSEK KALDIRAÇLI: quality_model.gd'nin duran balance flag'i v1 kompozitlerinin ~7-12'de
# oturduğunu söylüyor, yani üç eksenden birine düz +3 normalize kalitede ~%10-15'lik bir
# hareket demek. Tasarımın working tavanıyla gönderiliyor, ölçülen kayma done message'da.
const PM_EXPERIENCE_PER_POINT := 0.5
const PM_EXPERIENCE_CAP := 3.0
# --- Faz bantları: toplam eforun oranı. Dev→beta sınırda OTOMATİK; iterasyon→dev
#     OYUNCU KARARI (aşağıdaki iterasyon döngüsü bloğu) ---
const PHASE_DESIGN_END := 0.20      # Tasarım  ("iteration"):    [0.00, 0.20)
const PHASE_DEV_END := 0.80         # Geliştirme ("development"): [0.20, 0.80); Beta ("bugfix"): [0.80, 1.0]+
# --- İterasyon döngüsü (player-gated restore) + ekip kalite tavanı — ALL WORKING ---
# Tasarım bandı (tur 1) dolunca build karar bekleyerek PARK eder; her ek tur
# ITER_ROUND_DAYS takvim günü sürer (ekip hızından BİLİNÇLİ bağımsız — tasarım turu
# bir takvim ritüeli, bedeli "N gün" olarak okunmalı; working karar) ve eksenleri
# tavanlarına doğru büyütür. ITER_MAX_ROUNDS tur sayısı tavanı (güvenlik değil, gramer):
# Software Inc. tasarımı dört iterasyonda keser; azalan getiri eğrisi de dördün ötesini
# ödüllendirmez (kalibrasyon kanunu 2) — tavanda yalnız "Geliştirmeye geç" kalır.
const ITER_ROUND_DAYS := 4          # WORKING — bir ek turun takvim günü (dafd33c ITERATION_LENGTH_DAYS halefi)
const ITER_MAX_ROUNDS := 4          # yönetmen kararı 2026-08-19 (12→4): tur sayacı tavanı (tur 1 = tasarım bandının kendisi)
# Tavan formülü: eksen tavanı = ITER_CEIL_FOUNDER_COEF × kurucunun o alandaki puanı
#              + min(rolün aktif UZMANLIK toplamı × ITER_CEIL_ROLE_COEF, ITER_CEIL_ROLE_CAP)
# İki katsayı ARTIK AYNI CETVELİ okuyor. Eskiden farklı olmalarının sebebi ölçekti —
# kurucu 0-3, çalışan 5-8 bandında yaşıyordu; cetvel birleşince o gerekçe düştü ve
# kurucu katsayısı yarıya indi (4,0 → 2,0), yani tavan çapaları kıpırdamadı. Çıpalar: tech-2 solo → tavan 8 (v1
# damgalarının ~5-12 bandının içi — solo kurucu biraz cilalar, elite'e İTEREMEZ);
# + UZMANLIK-7 Tasarımcı → 8+14 = 22 (bir sürümlük tasarım payı — işe alım fantezisi).
const ITER_CEIL_FOUNDER_COEF := 2.0   # WORKING — kurucu alan puanı başına taban tavan
const ITER_CEIL_ROLE_COEF := 2.0      # WORKING — alan puanı başına tavan katkısı
const ITER_CEIL_ROLE_CAP := 18.0      # WORKING — terimin üst sınırı (çoklu işe alım istifi)
# Hangi ALAN hangi kalite ekseninin tavanını yükseltir (2026-08-21; eskiden rol tablosuydu).
# Deneyim→Tasarım rev 2 §2'de AÇIKÇA yazıyor ("Tasarım ... Deneyim ekseni"); diğer ikisi
# aynı sütundan çıkarım ve Erdem 2026-08-21'de onayladı:
#   İnovasyon ← Ürün      (§2: "özellik kararları")
#   Kararlılık ← Yazılım  (§2: "bug oranı")
# Bu, eski rol tablosunun bir ROTASYONUDUR (designer→developer→PM sırası değişti), yani
# bilinçli bir denge değişikliğidir; kalibrasyon turu bunu ölçecek.
const ITER_CEIL_AXIS_AREA := {
	"innovation": "product",
	"stability": "engineering",
	"experience": "design",
}
# Tur başına ham kazanç (QualityModel.grow raw'ı), eksen başına — tasarım BİRİNCİL
# kaldıraç (Erdem kararı 2026-08-06: üç eksen de oynar, tasarım ağırlıklı; üç rolün
# tavanı da ilk günden gerçek olsun diye Kararlılık/Deneyim sıfır DEĞİL).
const ITER_ROUND_RAW := {"innovation": 3.0, "stability": 1.0, "experience": 1.0}  # WORKING

# =========================================================================
#  GDD ÜRÜN rev 6.1 §5 · CİLA MERDİVENİ (MÜHÜRLÜ)
# =========================================================================
# Tamamlanan TASARIM turu sayısı → sürümün gerçekleşme çarpanı.
#
# rev 6.1 bu tabloyu TERS ÇEVİRDİ. Eskisi {1: 0,55 · 2: 0,78 · 3: 0,92 · 4: 1,00}
# idi ve bir turu TAMAMLAYAN oyuncudan sürümün neredeyse yarısını alıyordu — yani
# işini yapan cezalandırılıyordu. Software Inc'in grameri doğrusudur: tasarım fazı
# ulaşılabilir kalitenin TAVANINI belirler; tamamlanmış tasarım ödül vermez, EKSİK
# tasarım tavanı düşürür. Taban bu yüzden 1 turda ×1,00'dir.
#
# Üç ekstra tur eforun %24'ünü yakar (3 × DESIGN_TURN_COST) ve karşılığında %15
# verir; "hep 4 tur" otomatik doğru cevap değildir.
const DESIGN_TURN_MULT := {0: 0.75, 1: 1.00, 2: 1.06, 3: 1.11, 4: 1.15}
const DESIGN_TURN_MAX := 4
## Her TASARIM turunun yaktığı efor, EforTavanı'nın oranı olarak (§5).
const DESIGN_TURN_COST := 0.08


## §5 — the realization multiplier a version stamps onto every step it ships.
## Turn counts above the cap read as the cap; below zero read as the rush value.
static func design_turn_mult(turns_completed: int) -> float:
	return float(DESIGN_TURN_MULT.get(clampi(turns_completed, 0, DESIGN_TURN_MAX), 1.0))
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
# Yazılımcı UZMANLIK'ı tohumu ne kadar oynatır. PIVOT cetvelin ortası: orada çarpan tam 1.0,
# altında bug artar, üstünde azalır. Yazılımcısı olmayan bir ekipte de tam 1.0 — bu yüzden
# migration öncesi tohum sayıları (feature_bug_seed_by_complexity) bire bir korundu.
const SEED_EXPERTISE_PIVOT := 5.0
const SEED_EXPERTISE_SLOPE := 0.12   # UZMANLIK puanı başına ±%12
const SEED_EXPERTISE_MULT_MIN := 0.5
const SEED_EXPERTISE_MULT_MAX := 1.6

# Bonus bug count applied at launch when the player left a critical bug
# in (ev_mvp_bugfix_001_critical_bug "Bırak, gönder" choice → flag).
const CRITICAL_BUG_LAUNCH_PENALTY := 5

# --- Beta (BETA testi arka planda kendi kendine koşar) ---
# BETA: test gizli bug'ları bulur (find) ve bulunanları çözer (fix: mevcut
# POLISH_BUG_FIX_PER_DAY hızı). working value — Erdem balance-pass.
const BETA_BUG_FIND_PER_DAY := 6.0
## §7 [K] — günlük keşif = 6 × 0,85^(beta_günü). İlk günler çok bulur, sonra tek tük.
## Ar-Ge `test_automation` düğümü bu sönümü 0,85 → 0,90'a çeker (Ar-Ge §4.3 · §13).
## SABİT SİLİNMEDİ, İKİZLENDİ: araştırılmamış taban burada durur, araştırılmış değer
## yanında, ve hangisinin okunacağına `beta_find_decay()` karar verir. Böylece "Ar-Ge
## gelmeden önceki oyun" bir tek satır bile kaymadan aynı sayıyı okur.
const BETA_FIND_DECAY := 0.85
const BETA_FIND_DECAY_RESEARCHED := 0.90


## Ar-Ge §13 katsayı kancası. TEK OKUMA YERİ: aşağıdaki beta formülü buraya uzanır,
## sabite değil — yoksa düğüm tamamlandığında yalnız bazı çağrı yerleri değişirdi.
static func beta_find_decay() -> float:
	return BETA_FIND_DECAY_RESEARCHED if ResearchSeam.completed("test_automation") else BETA_FIND_DECAY
# TEST bölümü (design doc §5): bulma İSABETİ Test Uzmanı UZMANLIK'ından, bulma/çözme TEMPOSU
# Test Uzmanı + Yazılımcı HIZ karışımından, hata sprinti süresi Test Uzmanı ile kısalır.
# Üçü de PIVOT'lu: test uzmanı YOKKEN çarpanlar tam 1.0, yani bugünkü beta davranışı aynen
# korunur ve bir test uzmanı işe almak gerçek bir hızlanma olur.
const TESTER_FIND_PER_EXPERTISE := 0.08    # UZMANLIK puanı başına bulma isabeti (+%8)
const TESTER_FIND_MULT_MAX := 1.8
const TESTER_TEMPO_PER_PACE := 0.05        # Test Uzmanı HIZ puanı başına tempo (+%5)
const TESTER_TEMPO_MULT_MAX := 1.6
const TESTER_SPRINT_PER_EXPERTISE := 0.06  # UZMANLIK puanı başına sprint süresinden kısma
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
# `_iter_intro_shown` USED TO LIVE HERE — a static bool marking that the run's first
# iteration-decision beat had been shown once (Erdem kararı 2026-08-06: kalıcı gramer park +
# tracker butonları, modal yalnız ilk karşılaşmada). It existed because GameEvent.one_shot was
# inert on the injected path, and because it existed it had to be reset, serialised and
# restored — a private latch belonging to ONE card had reached the save file.
# `product.design_round_intro` declares `one_shot` and the engine owns it.


# --- Run boundary + save (SaveManager) ---

static func reset() -> void:
	# The in-place reset the header note above promised. Without it an in-place restart
	# (and every load) carried the previous run's BUILD into the new company: capacity_demand
	# counts it, _is_eligible suppresses every event that does not match its phase, and the
	# Product tab renders a tracker for a product nobody committed to. (The tutorial latch
	# that used to be reset on this line had the same leak in a milder form — a new founder
	# never got the teaching beat because a founder who no longer exists had seen it. It is
	# the engine's latch now, and EvLatches is cleared by the same run boundary.)
	active_build = null
	# DESTEK'in kesirli artığı da yeni koşuya taşınmaz: memnuniyet zararı kişi başına
	# ondalık birikiyor ve o tablo statiktir, yani sıfırlanmazsa önceki şirketin
	# borcunu yeni şirkete yazardı.
	SupportSystem.reset()
	ProductRead.reset()


static func to_dict() -> Dictionary:
	# The live product itself (axes, version, bug counts, shipped set) is NOT here: it lives
	# in GameState.flags under the mvp_* keys, which the GameState block already carries.
	# This is only the in-flight BUILD. `iter_intro_shown` was here until the event engine
	# took ownership of the latch; a v10 save does not carry it and a v10 load ignores it.
	return {
		"active_build": SaveCodec.res_to_dict(active_build) if active_build != null else null,
	}


static func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	var raw: Variant = d.get("active_build", null)
	if typeof(raw) == TYPE_DICTIONARY:
		active_build = SaveCodec.res_from_dict(raw as Dictionary, FeatureBuild) as FeatureBuild
	else:
		active_build = null


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
	# İzindeki çalışan SAYILMAZ (ücretli izin ama kapasite dışı — design doc §8).
	# TÜM Ürün Geliştirme rolleri sayılır, yalnız yazılımcılar değil: bir test uzmanı da bir
	# tasarımcı da build işinin içinde ve aynı anda başka bir işe koşulamaz. Eskiden yalnız
	# yazılımcı sayılıyordu, yani bir tasarımcı işe almak kapasiteye hiçbir şey katmıyordu.
	# §13.1: departman taksonomisi kalktı, kadro grubu kaldı. AYNI DÖRT ROL — product_dev
	# tam olarak product_design ∪ development'tı, o yüzden kapasite havuzu bir kişi bile
	# değişmedi; yalnız kimin kimle olduğunu söyleyen tablo tekleşti.
	#
	# ARAŞTIRAN KİŞİ HAVUZDA DEĞİLDİR (Ar-Ge §5.0). Yönetmen hükmü: §5.0'ın ruhu o kişinin
	# ÜRÜNÜN ÜZERİNDE OLMAMASIDIR, ve hiçbir katkı vermezken kapasiteyi şişirmek aynı yalanın
	# başka bir yerde söylenmiş hâlidir — bar "kimse üzerinde değil" derken bölen büyümüş
	# olurdu. Sayım artık grup sayacına delege edilmiyor; filtre burada, çünkü diğer
	# `count_active_in_groups` çağıranları (yok, ama olabilir) araştırmayı elemek zorunda
	# değil. KALİBRASYON NOTU: bu, süre tahminlerini araştırma sürerken uzatır. Beklenmedik
	# bir yöne oynarsa RAPOR EDİLİR, soğurulmaz — havuzun boyu tek kalibrasyon yüzeyidir.
	var n: int = 0
	for c in CharacterRegistry.get_active_employees():
		if c.assigned_job_ids.has(HRConstants.JOB_RESEARCH):
			continue
		var grp: String = String(HRConstants.ROLE_GROUP.get(c.role, ""))
		if grp == HRConstants.GROUP_PRODUCT_DESIGN or grp == HRConstants.GROUP_DEVELOPMENT:
			n += 1
	return CAPACITY_BASE + n


static func capacity_demand() -> int:
	var d: int = 0
	if GameState.get_flag("mvp_bug_sprint_active", false):
		d += 1
	# VC HAZIRLIĞI BURADAN ÇIKTI (H6, 2026-08-21). Yanlış aktördü: hazırlık YALNIZ
	# kurucuyu tutuyor, ama kapasite çarpanı YAPIMIN TAMAMINI yavaşlatıyordu — yapımı
	# çalışanlar taşırken kurucunun toplantı hazırlığı onların hızını düşürüyordu.
	# Artık kurucuyu MEŞGUL sayar (bkz. _is_free); tek taşıyıcı oysa yapım DURUR,
	# değilse hiçbir şey yavaşlamaz. Ara kademe yok.
	# BETA BURADAN ÇIKTI (Ürün rev 6.1 §7 · brief'in adlandırdığı ikinci kusur).
	#
	# Kapasite bir YAPIM bölenidir ve yapım eforunu Build işi taşır (Ekip §12.0:
	# Ürün · Tasarım · Yazılım). BETA'yı Test işi taşır ve BETA barı efor İLERLETMEZ —
	# sayaç tutar (§7). Yani BETA'da duran bir yapım hiçbir yapım kapasitesi tüketmiyor,
	# ama eskiden tam slot yiyordu: havuz tükenmez olduğu için (§7) BETA'nın doğal bir
	# sonu da yok, dolayısıyla hiç yayınlamayan oyuncu her hata sprintini KALICI olarak
	# yarı hıza düşürüyordu. Denetim bunu "neredeyse kesinlikle istenmeyen" diye
	# işaretlemişti ve koddaki tek yapım→destek cezası buydu.
	if active_build != null and active_build.current_phase in ["iteration", "development"]:
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

# Hangi rol hangi fazda çalışır (design doc §5). Faz bazlı: bir tasarımcı GELİŞTİRME fazında
# kod yazmıyor, bir yazılımcı TASARIM fazında ekran çizmiyor. Eski formül her fazda YALNIZ
# yazılımcı okuyordu — yani tasarımcı/test uzmanı/ürün yöneticisi hiçbir şeye katkı vermiyordu.
# Ürün Yöneticisi tasarım fazına İKİNCİL katkı verir (design doc §5: "Ürün Yöneticisi HIZ'ı
# ikincil katkı"), bu yüzden ağırlığı ayrı.
# 2026-08-21 (the areas model, rev 11 §4 + §12): the crew is no longer a ROLE list, it is an AREA list.
# Same three phases, same intent — "bir tasarımcı GELİŞTİRME fazında kod yazmıyor" — but the
# question changed from "is this person a designer?" to "which of this phase's areas is this
# person strongest in?". That is what lets rev 2 §2's one-person-team promise work: a
# Software Engineer with Tasarım 2 now contributes a little to the design phase instead of
# nothing at all, and a PM with Yazılım 1 limps through development rather than vanishing.
# WHO is in the room is decided by the BUILD JOB assignment (rev 2 §4), not by job title.
const PHASE_AREAS := {
	"iteration": ["product", "design"],
	"development": ["engineering"],
	"bugfix": ["qa", "engineering"],
}
## Üç fazın alanlarının birleşimi: "bu sürümün üzerinde çalışılıyor" demenin alan
## karşılığı. Emekli `build` işinin tastamam kadrosu; tek farkı artık üç ayrı sütun olması.
const BUILD_AREAS := ["product", "design", "engineering"]


static func _phase_areas(phase: String) -> Array:
	# Bilinmeyen/planning faz → geliştirme (commit öncesi projeksiyonun varsayılanı).
	return PHASE_AREAS.get(phase, PHASE_AREAS["development"])


## KURUCUYU AKTİF FAZIN ALANINA OTURT (H4, 2026-08-21). Oyuncunun kurucuyu atayacak
## bir kapısı yok (R1: Görevler matrisinde satırı bile yok), ama ATAMA HÂLÂ VAR —
## çünkü hız terimi, kalite ortalaması ve eksen tavanı üçü de `assigned_jobs`'ı okuyor.
## Yani kurucu ARTIK MOTORUN ATADIĞI biri: faz değiştikçe o fazın alanına taşınır.
##
## ch. 02 §5'in TEK ALAN kilidi ayakta: önce boşaltılır, sonra atanır. Kilit artık
## oyuncuya değil KENDİ YAZARINA karşı duruyor — tek yazar burada.
# ======================= Meşguliyet ve duraklama (R2 · H5) ====================
# "Kurucu her şeyi yapabilir, ama aynı anda değil." Kural KİŞİ BAŞINA işler ve
# kurucuya özel DEĞİLDİR — kurucu yalnız var olma sebebi.
#
# MEŞGUL KÜMESİ, bugün kodda gerçekten var olan durumlardan (uydurma yok):
#   herkes  · STATUS_ON_LEAVE          — izinde
#   herkes  · STATUS_TRAINING          — eğitimde
#   kurucu  · pitch_prep_active        — VC toplantısına hazırlanıyor
#   kurucu  · sales_meeting_active     — bir satış masasında oturuyor (Satış §5.0)
# Kurucunun kodda BAŞKA faaliyeti yok: VC toplantısının kendisi ve olay modalları
# ağacı zaten duraklatıyor, yani ayrı bir meşguliyet değiller.


## Bu kişi BUGÜN işe girebilir mi.
static func _is_free(c: Character) -> bool:
	if c == null or c.status != HRConstants.STATUS_ACTIVE:
		return false
	if c.category == "founder" and GameState.get_flag("pitch_prep_active", false):
		return false
	# Satış rev 6 §5.0 — kurucu bir satış toplantısında; atlanan iki saatte katkısı sıfırdır.
	# Sonucu Ekip §2.1'in kendi cümlesidir: ekipte boş biri varsa yapım AKAR, kurucu tek
	# işçiyse DURAKLAR. İkinci bir "yetişme" formülü yazılmadı — ikinci simülasyon yolu bir
	# sapma fabrikasıdır.
	if c.category == "founder" and GameState.get_flag("sales_meeting_active", false):
		return false
	return true


## Bu fazı TAŞIYABİLECEK herkes — durumuna BAKMADAN. "Kimse yok" ile "herkes meşgul"
## arasındaki farkı söyleyebilmenin tek yolu bu: HRSystem.assigned_to zaten
## STATUS_ACTIVE filtreliyor, yani izindekini hiç görmez ve iki hâl aynı görünürdü.
static func phase_assignees(phase: String) -> Array[Character]:
	var out: Array[Character] = []
	for area_key in _phase_areas(phase):
		for c in CharacterRegistry.get_all():
			if c == null or out.has(c):
				continue
			if c.category != "employee" and c.category != "founder":
				continue
			if c.assigned_jobs.has(String(area_key)):
				out.append(c)
	return out


## AKTİF YAPIM DURDU MU. Oyuncu duraklatmadı — bu bir SONUÇ ve raporlanıyor, teklif
## edilmiyor. Türetilmiş, saklanmıyor: kart her boyamada soruyor ve cevap her zaman
## bugünün gerçeği ("render state, never store it").
## §2 — DURAKLAMA İKİ TÜRDÜR ve bar ikisini AYIRT EDER. Oto-duraklama bir kontrol
## değil BİLDİRİLEN BİR DURUMDUR ve cümleyle konuşur; manuel duraklama oyuncunun
## kendi kararıdır ve glifle görünür. İKİSİ BİR ARADA ASLA GÖRÜNMEZ (S6).
const PAUSE_NONE := ""
const PAUSE_AUTO := "auto"
const PAUSE_MANUAL := "manual"


static func pause_kind() -> String:
	if active_build == null:
		return PAUSE_NONE
	if not PHASE_AREAS.has(active_build.current_phase):
		return PAUSE_NONE
	# MANUEL ÖNCE: oyuncu duraklattıysa bar onun kararını gösterir, ekibin durumunu
	# değil. Aksi hâlde kendi bastığı düğmenin yerine "Kimse üzerinde değil." okurdu.
	if active_build.manually_paused:
		return PAUSE_MANUAL
	# §8.4 — "Düzeltme koşusu başlatmak aktif yapımı duraklatır." Aynı eller iki işi
	# birden yapmaz: koşuyu Destek'e atananların Yazılım çıktısı sürer ve o çıktı
	# yapımdan çekilir. Bu, modülün merkez baskısının yapım tarafındaki yarısıdır.
	if SupportSystem.fix_run_pauses_build():
		return PAUSE_AUTO
	for c in phase_assignees(active_build.current_phase):
		if _is_free(c):
			return PAUSE_NONE
	return PAUSE_AUTO


static func build_paused() -> bool:
	return pause_kind() != PAUSE_NONE


## §2 — oyuncu her fazda duraklatabilir. "İlerleme korunur, SÜRÜM YAŞI AKMAYA DEVAM
## EDER" — yani duraklatmak zamanı durdurmaz, yalnız işi durdurur.
static func set_manual_pause(paused: bool) -> void:
	if active_build == null:
		return
	if active_build.manually_paused == paused:
		return
	active_build.manually_paused = paused
	EventBus.build_progress_changed.emit()


static func is_manually_paused() -> bool:
	return active_build != null and active_build.manually_paused


## §3 — "Lider yapım sürerken ayrılırsa/çıkarılırsa: yapım LİDERSİZ sürer (liderlik
## çarpanı 1,0), bar notu düşer, oyuncu yeni lider atayabilir. Yapım geriye dönük
## BOZULMAZ." Çarpanın 1,0'a düşmesi build_effort_per_day'de zaten oluyor (lider
## null → leadership 0); burada eksik olan yalnız BAR NOTUYDU.
static func lead_missing() -> bool:
	if active_build == null or active_build.lead_engineer_id == "":
		return false
	var lead: Character = CharacterRegistry.get_character(active_build.lead_engineer_id)
	return lead == null or lead.status != HRConstants.STATUS_ACTIVE


## Duraklamanın TÜRÜ, iki dizgeden hangisinin basılacağını seçer. KİŞİ ADI ASLA
## GEÇMEZ: not ekibin durumu hakkında, bir kişinin değil.
static func pause_note_key() -> String:
	# §2 — MANUEL DURAKLAMA CÜMLE TAŞIMAZ, glif taşır. Oyuncu neden durduğunu zaten
	# biliyor; ona bir sebep cümlesi yazmak, kendi kararını bir arıza gibi gösterirdi.
	if pause_kind() != PAUSE_AUTO:
		return ""
	# Düzeltme koşusu KENDİ cümlesini taşır. "Ekip başka işte." doğru ama belirsiz
	# olurdu; §2 duraklamanın BİLDİRİLEN BİR DURUM olmasını istiyor, ve oyuncunun
	# az önce bastığı düğmenin sonucunu adıyla görmesi o kuralın kendisidir.
	if SupportSystem.fix_run_pauses_build():
		return "BUILD_BUSY_FIX_RUN"
	# ARAŞTIRMA DA KENDİ CÜMLESİNİ TAŞIR — düzeltme koşusunun precedent'i simetrik
	# uygulandı. Duraklamış bar DURUMUNU değil SEBEBİNİ söylemek zorunda (§2): araştırmaya
	# geçen kurucunun yapımı "Ekip başka işte." okusaydı oyuncu az önce kendi bastığı
	# düğmenin sonucunu göremezdi. Ar-Ge §5.0 bunu barlarda görmeyi açıkça şart koşuyor.
	if _paused_by_research():
		return "BUILD_BUSY_RESEARCH"
	if phase_assignees(active_build.current_phase).is_empty():
		return "BUILD_BUSY_NOBODY"
	return "BUILD_BUSY_ELSEWHERE"


## Yapımı durduran şey ARAŞTIRMA mı. İki kapı, çünkü iki farklı hâl aynı cümleyi hak eder:
## fazı taşıyabilecek birinin araştırmaya geçmesi (ekip hâli) ve kurucunun araştırmaya
## geçmesi (tek kişilik hâl). İkincisi ayrı sorulmak zorunda: kurucu araştırmaya geçince
## alan aynası boşalıyor (HRConstants.areas_for_jobs'un `continue`'u) ve `phase_assignees`
## onu ARTIK GÖRMÜYOR — yani yalnız ilk kapıyla tam olarak asıl vakayı kaçırırdık.
static func _paused_by_research() -> bool:
	for c in phase_assignees(active_build.current_phase):
		if c != null and c.assigned_job_ids.has(HRConstants.JOB_RESEARCH):
			return true
	var founder: Character = CharacterRegistry.get_founder()
	return founder != null and founder.assigned_job_ids.has(HRConstants.JOB_RESEARCH)


## §3 — lidersiz yapımın bar notu. Duraklama notundan AYRI bir satır: yapım durmuyor,
## yalnız liderlik çarpanı düşüyor.
## Aktif yapımın FAZ ADI anahtarı. Portföy rozeti bunu okuyor; build_bar kendi
## Model faz sabitlerinden aynı anahtarları çözüyor. Sözcük CSV'de, kod state'te —
## bu fonksiyon bir CONST OLAMAZ: const dosya yüklenirken değerlenir ve o an henüz
## bir dil seçilmemiştir.
static func phase_label_key() -> String:
	if active_build == null:
		return "BUILD_PHASE_SUPPORT" if ProductState.is_live() else ""
	match active_build.current_phase:
		"iteration": return "BUILD_PHASE_DESIGN"
		"development": return "BUILD_PHASE_DEVELOPMENT"
		"bugfix": return "BUILD_PHASE_BETA"
		_: return ""


## YAVAŞLAYAN BAR SEBEBİNİ SÖYLER — duraklamış bir bar gibi (§5.6.1'in grameri, bir adım
## ötede). `lead_note_key` ile AYNI KANALDA yaşar: ikisi de DURAKLATMAYAN nottur, bar akmaya
## devam eder ve not neden yavaş olduğunu yazar. Duraklama kanalı (`pause_note_key`) buna
## karışmaz.
##
## Koşul Ekip §12.1'in kendisidir: iki iş taşıyan biri her iki işe de 0,50 verir. Yani
## "yavaş" burada bir tahmin değil, taşıyıcının defterinden okunan bir olgudur.
##
## NOT TEK CÜMLEDİR VE YALNIZ BÖLÜNMEYİ İDDİA EDER. §12.1'in kanonik cümlesi iki bedeli
## birden sayar ("...ve morali normalden hızlı erir"), ama o cümle KADRO hover'ınındır ve
## kurucu için YANLIŞTIR: kurucunun moral bandı yoktur (Ekip §4.5), yani iki bedelden yalnız
## birini öder. Barda moral iddia etmek, §12.1'in "tek bir etki anlatılıp diğeri gizlenmez"
## yasasını tam da onu onurlandırmaya çalışırken çiğnerdi.
static func split_note_key() -> String:
	if active_build == null:
		return ""
	if not PHASE_AREAS.has(active_build.current_phase):
		return ""
	for c in phase_assignees(active_build.current_phase):
		if c != null and HRSystem.is_overloaded(c):
			return "BUILD_SPLIT_FOCUS"
	return ""


static func lead_note_key() -> String:
	return "BUILD_NO_LEAD" if lead_missing() else ""


## §3 — "Lider yapım sürerken ayrılırsa/çıkarılırsa … oyuncu ekip panelinden YENİ LİDER
## ATAYABİLİR. Yapım geriye dönük bozulmaz." Bu, o cümlenin seam'i: liderlik yalnız
## BUGÜNKÜ hıza girer (build_effort_per_day her gün yeniden okur), o yüzden lideri
## değiştirmek dünkü ilerlemeye dokunmaz — geriye-dönük-bozmama yapısaldır.
##
## Boş dize meşru bir değerdir: lidersiz yapım, çarpan 1,0.
static func set_build_lead(lead_id: String) -> void:
	if active_build == null:
		return
	if active_build.lead_engineer_id == lead_id:
		return
	active_build.lead_engineer_id = lead_id
	active_build.assigned_engineer_id = lead_id
	EventBus.build_progress_changed.emit()


# ============================ DESTEK okuma seam'leri (B4) ====================
# ÜÇÜ de bugün HAM BAYRAK olarak okunuyordu, altı ayrı yerde ve iki farklı fallback
# deyimiyle. Kart bayrak okumaz, seam okur.

## Yayındaki ürünün AÇIK hata sayısı — DOĞRULANMIŞ sayacının ta kendisi.
static func live_bug_count() -> int:
	return maxi(0, int(GameState.get_flag("mvp_live_bug_count",
		GameState.get_flag("mvp_bug_count_at_launch", 0))))


static func is_sprint_running() -> bool:
	return bool(GameState.get_flag("mvp_bug_sprint_active", false))


## Koşan düzeltmenin dolumu 0-1; koşu yoksa 0.
static func sprint_progress() -> float:
	if not is_sprint_running():
		return 0.0
	var total: float = float(GameState.get_flag("mvp_sprint_days_total", 0))
	if total <= 0.0:
		return 0.0
	return clampf(float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0)) / total, 0.0, 1.0)


static func _reseat_founder(phase: String) -> void:
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return
	# ARAŞTIRAN KURUCUYA DOKUNULMAZ (Ar-Ge §5.0). Bu fonksiyon her faz geçişinde
	# `clear_areas` + `assign_area` koşuyor ve dört yerden çağrılıyor; korumasız bırakılırsa
	# oyuncu hiçbir şey yapmadan, hiçbir cümle görmeden, bir faz sınırında kurucunun
	# araştırma ataması SİLİNİRDİ. §5.0 duraklamanın bile bir SONUÇ olarak görünmesini
	# şart koşuyor; sessizce silinmesi onun tam tersi. Araştırma bitince kurucu bir sonraki
	# faz geçişinde zaten yerine oturur.
	if founder.assigned_job_ids.has(HRConstants.JOB_RESEARCH):
		return
	if not PHASE_AREAS.has(phase):
		return   # shipped / cancelled / planning: oturacağı bir faz alanı yok, yerinde kalır
	var area: String = _founder_phase_area(phase)
	if founder.assigned_jobs.has(area) and founder.assigned_jobs.size() == 1:
		return
	CharacterRegistry.clear_areas(founder.id)
	var refusal: String = CharacterRegistry.assign_area(founder.id, area)
	if refusal != "":
		push_error("[ProductSystem] founder refused '%s' for phase '%s': %s" % [
			area, phase, refusal])


static func _founder_on_build() -> bool:
	## Kurucu bu sürümün üzerinde mi çalışıyor — yani üç build alanından (Ürün · Tasarım ·
	## Yazılım) birine atanmış mı. ch. 02 §5'in tek-alan kilidi burada da geçerli: satıştaki
	## kurucu ne hıza ne tavana dokunur.
	# DURUM KAPISI (2026-08-21): burası kurucunun `status`'una HİÇ bakmıyordu, yani
	# eğitimdeki bir kurucu tam hızla katkı vermeye devam ediyordu — çalışanlar
	# HRSystem.assigned_to'nun filtresinden geçerken kurucu geçmiyordu. Duraklama
	# kuralının kapısı da tam burası.
	var founder: Character = CharacterRegistry.get_founder()
	if not _is_free(founder):
		return false
	for area_key in BUILD_AREAS:
		if founder.assigned_jobs.has(String(area_key)):
			return true
	return false


static func _founder_phase_area(phase: String) -> String:
	## Kurucunun bu faza hangi alandan girdiği: atandığı alan bu fazın alanlarından biriyse
	## o, değilse fazın ilk alanı (eski davranışın birebir devamı).
	var areas: Array = _phase_areas(phase)
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null:
		for area_key in areas:
			if founder.assigned_jobs.has(String(area_key)):
				return String(area_key)
	return String(areas[0]) if not areas.is_empty() else HRConstants.AREA_ENGINEERING


static func _phase_crew(phase: String) -> Array:
	## Bu fazın alanlarından BİRİNE atanmış herkes, ve her birinin bu faza hangi alandan
	## katıldığı — atandığı faz alanları içinde EN GÜÇLÜ olduğu.
	##
	## BİR KİŞİ BİR KEZ SAYILIR. İki faz alanına birden atanmış biri (ör. Ürün + Tasarım)
	## toplama iki kez girseydi aşırı yük bir CEZA değil ÖDÜL olurdu — §5'in söylediğinin
	## tam tersi. Bedeli output_mult_for_area zaten kesiyor.
	var best_area: Dictionary = {}
	var who: Dictionary = {}
	for area_key in _phase_areas(phase):
		for c in HRSystem.assigned_to(String(area_key)):
			var v: int = int(c.role_stats.get(String(area_key), 0))
			if not best_area.has(c.id) \
					or v > int(c.role_stats.get(String(best_area[c.id]), 0)):
				best_area[c.id] = String(area_key)
				who[c.id] = c
	var out: Array = []
	for id in who:
		out.append({"c": who[id], "area": String(best_area[id])})
	return out


static func _best_phase_area(c: Character, phase: String) -> String:
	# Bu kişi bu fazı HANGİ alandan çalışıyor: fazın alanları içinde en güçlü olduğu.
	var best: String = ""
	var best_v: int = -1
	for area_key in _phase_areas(phase):
		var v: int = int(c.role_stats.get(String(area_key), 0))
		if v > best_v:
			best_v = v
			best = String(area_key)
	return best


static func _lead_coordination(lead_id: String) -> float:
	# Koordinasyon çarpanı sorumludan gelir ve artık İKİ TARAF DA LİDERLİK okuyor: rev 2 §2
	# Liderlik'i herkese verdi ve UYUM'u sayı olmaktan çıkardı, yani "çalışan → UYUM" yolunun
	# okuyacağı bir sayı kalmadı. Kurucu kendi nötr-sıfırda eğrisini korur (o VARSAYILAN
	# sorumludur ve bir varsayılan ceza olmamalı); seçilmiş bir çalışan iki yönlü eğriyi
	# alır, yani düşük Liderlikli birini sorumlu yapmak hâlâ gerçek bir bahistir.
	# STALE LEAD: commit'ten sonra lead_engineer_id'yi kimse yeniden yazmıyor, yani sorumlu
	# işten çıkarılmış ya da izne çıkmış olabilir. Eskiden bu SESSİZCE kurucu tech'ine
	# düşüyordu; artık açıkça kurucu-sorumlu olarak çözülüyor, çünkü sessiz bir yanlış
	# çarpan sessiz bir yanlış hızdan daha zor fark edilir.
	var founder: Character = CharacterRegistry.get_founder()
	var founder_id: String = founder.id if founder != null else "founder"
	if lead_id != "" and lead_id != "founder" and lead_id != founder_id:
		var lead: Character = CharacterRegistry.get_character(lead_id)
		# `coordination_bonus` EMEKLİ (2026-08-21): sekiz trait'lik sette o eksen yok.
		# Kurucu dalıyla birlikte A5'in ikinci kırığı da kapanıyor — `trait_has` kurucunun
		# id'lerini ÇALIŞAN tablosunda arıyordu ve DAİMA false dönüyordu, yani bonusun
		# kurucu dalı başından beri ölü koddu.
		if lead != null and lead.category == "employee" and lead.status == HRConstants.STATUS_ACTIVE:
			return HRConstants.coordination_for_lead(
				int(lead.role_stats.get(HRConstants.SKILL_LEADERSHIP, 0)), false)
	return HRConstants.coordination_for_founder(
		GameState.get_founder_skill("leadership"), false)


static func _phase_area_sum(phase: String, lead_id: String) -> float:
	# BUILD İŞİNE atanmış İŞ BAŞINDAKİ herkesin, bu fazı çalıştıkları alandaki puan toplamı.
	# Sorumlu da normal bir üye olarak sayılır (ağırlık yok) — sorumlu olmanın etkisi
	# koordinasyon çarpanında. İzindeki/eğitimdeki çalışan katkı VERMEZ.
	#
	# ATAMA KAPISI BURADA: eskiden "Ürün Geliştirme rolündeki herkes" otomatik olarak her
	# build'e katılıyordu. Artık yalnız BU FAZIN ALANLARINA atanmış olanlar — iterasyon
	# Ürün+Tasarım, geliştirme Yazılım, hata sprinti Test+Yazılım. Bugün davranış aynı
	# (işe alım kişiyi kendi ana alanına koyuyor), ama ch. 03 §8'in "yeni sürüme başlayınca
	# ekip destekten çekilir" gerilimi ancak bu kapı varken kurulabilir.
	var total: float = 0.0
	for row in _phase_crew(phase):
		var c: Character = row["c"]
		if c.category == "founder":
			continue   # kurucunun katkısı _speed_for_phase'de kendi katsayısıyla ayrı
		var area_key: String = String(row["area"])
		# §4.5 KANONİK FORMÜL, İKİ YARISIYLA. Burada ayrı bir hız hesabı KURULMAZ — alan
		# katsayısı, odak, moral bandı ve huy çarpanları effective_skill'in içinde; kişinin
		# o gün KAÇ SAAT çalıştığı daily_contribution'ın ikinci yarısında (§8.4: "getiri
		# saatin kendisidir"). Çarpan BU FAZIN alanından ölçülüyor, işin genelinden değil.
		total += HRSystem.daily_contribution(c, area_key)
	return total


static func _speed_for_phase(phase: String, lead_id: String) -> float:
	# THE hız yasası. Kurucu her zaman tam katsayıyla katılır (o hep odadadır); çalışanlar
	# fazlarına göre. Floor SPEED_MIN — HIZ-0 bir ekiple bile build ilerler.
	# Kurucu build işine ATANMIŞSA katılır (ch. 02 §5). Bugün her koşuda atanmış doğuyor,
	# yani bu satır davranışı değiştirmiyor; değiştireceği an, oyuncunun kurucuyu satışa
	# aldığı andır — Bootstrap baskısının tam olarak istenen yeri.
	var speed: float = 0.0
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null and _founder_on_build():
		# §8.3: "Kurucu kısa günün moral faydasından yararlanmaz; ÇIKTISI YİNE DE SAATLE
		# ORANTILI DÜŞER." Çalışan terimi oranı daily_contribution'ın içinde taşıyor; kurucu
		# terimi kendi katsayısıyla ayrı hesaplandığı için oranı burada alır. Bu satır
		# olmadan on bir saatlik bir gün ekibin yalnız bir kısmını hızlandırıyor ve §8.4'ün
		# "orantılı olarak daha fazla" cümlesi ölçüldüğünde tutmuyor (1,118 × yerine 1,375 ×).
		# ODAK BÖLÜNMESİ KURUCUYA DA İŞLER (Ekip §4.5: "Kurucu için moral bandı uygulanmaz;
		# DİĞER BÜTÜN ÇARPANLAR AYNEN GEÇERLİDİR"). Çalışan terimi bölünmeyi
		# daily_contribution → effective_skill içinde zaten taşıyor; kurucu terimi seam'in
		# dışında hesaplandığı için onu BURADA almak zorunda. Bu satır olmadan DESTEK'teki
		# bir kurucu yapıma başladığında bu yol TAM HIZDA koşuyordu — yani modülün öğretmek
		# istediği tek şey, "ikisi de yavaşlar", tam olarak burada yalan oluyordu. Görünür
		# sonucu da vardı: barın gün tahmini bu yolu çağırıyor (build_bar_model), yani tahmin
		# tam hız derken canlı hat yapımı yarı hızda akıyordu.
		speed = FOUNDER_SPEED_COEF * float(GameState.get_founder_skill(_founder_phase_area(phase))) \
			* HRConstants.hours_output_mult(WorkHoursSystem.hours_for(founder)) \
			* HRConstants.focus_mult(HRSystem.job_count(founder))
	speed += EMPLOYEE_SPEED_COEF * _phase_area_sum(phase, lead_id)
	return maxf(SPEED_MIN, speed * _lead_coordination(lead_id))


static func _speed_for_lead(lead_id: String) -> float:
	# Faz bilmeyen çağıranlar için (commit öncesi projeksiyon): geliştirme fazı varsayılanı.
	return _speed_for_phase("development", lead_id)


# =========================================================================
#  GDD ÜRÜN rev 6.1 §6.1 · EFOR MODELİ — EKİP SEAM'İ ÜSTÜNDE
# =========================================================================
# kişinin günlük katkısı = hr.effective_skill(kişi, taşıyıcı alanı) × saat/8
# yapım hızı (efor/gün)  = Σ(build ekibindeki taşıyıcılar) × K_EFOR
#
# BURADA İKİNCİ BİR HIZ FORMÜLÜ YOK ve olamaz (§18): alan katsayısı, odak, moral
# bandı, liderlik ve huy çarpanlarının hepsi Ekip §4.5'in içinde. Belge ayrıca
# "İkinci bir görünmez çarpan (iletişim/Brooks terimi) yoktur" diyor — o yüzden
# eski `_lead_coordination` eğrisi (COORD_MIN…COORD_MAX) bu yola GİRMEZ; liderlik
# Ekip'in kendi seam'inden, ALANIN TOPLAMINA uygulanır (Ekip §4.2).

## §6.1 [K] — saat normalizasyonu birleştirildikten sonraki katsayı. Eski yazım
## `× ham saat × 1/12` idi; rev 6.1 her formülü `saat/8`e çevirdi ve farkı buraya
## soğurdu. İki yazım HER SAAT DEĞERİNDE cebirsel olarak özdeştir:
##   skill × (h/8) × (8/12) ≡ skill × h/12
## yani birleştirme sıfır kalibrasyon sapmasıyla yapıldı (5-11 saat aralığında
## ölçüldü).
const K_EFOR := 8.0 / 12.0

## §6.3 [K] — hata/efor birimi = clamp(0,45 − 0,05 × ekibin etkin Yazılım ortalaması).
## Tavanı Ar-Ge `cicd` düğümü 0,45 → 0,35'e çeker (Ar-Ge §4.3 · §13). BETA_FIND_DECAY ile
## AYNI DESEN: taban sabiti durur, araştırılmış değer yanına eklenir, seçimi fonksiyon yapar.
## TABAN ile KATSAYI dokunulmadı — düğüm yalnız tavanı indiriyor, eğrinin eğimini değil.
const BUG_RATE_CEIL := 0.45
const BUG_RATE_CEIL_RESEARCHED := 0.35
const BUG_RATE_FLOOR := 0.10
const BUG_RATE_SKILL_COEF := 0.05


## Ar-Ge §13 katsayı kancası. İKİ ÇAĞRI YERİ VAR ve ikisi de buradan okur: taşıyıcısı
## olmayan ekibin döndüğü değer, ve clamp'in ÜST SINIRI. Yalnız birini çevirmek düğümü
## yarım açardı — tavan inerken clamp hâlâ 0,45'e izin verirdi.
static func bug_rate_ceil() -> float:
	return BUG_RATE_CEIL_RESEARCHED if ResearchSeam.completed("cicd") else BUG_RATE_CEIL


## §6.2 — Build işini Ürün · Tasarım · Yazılım taşır. Bir kişi bu üç alandan
## HANGİSİNDE en verimliyse oradan katkı verir: bir mühendis Yazılım'dan, bir
## tasarımcı Tasarım'dan, kurucu en güçlü olduğu alandan. Test build TAŞIMAZ —
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


## The people actually carrying the build today — Build işine ATANMIŞ olanlar.
## Ünvan hiçbir kapıyı açmaz (Ekip §12.0); atama açar.
static func build_carriers() -> Array[Character]:
	return HRSystem.assigned_to_job(HRConstants.JOB_BUILD)


## §6.1 — yapım hızı, efor/gün. Kurucu herkes gibi sayılır.
static func build_effort_per_day(lead_id: String = "") -> float:
	var total: float = 0.0
	for c in build_carriers():
		var area: String = build_carrier_area(c)
		if area == "":
			continue
		# daily_contribution = effective_skill × saat/8 — §6.1'in ilk satırı, birebir.
		total += HRSystem.daily_contribution(c, area)
	# Ekip §4.2: liderlik ALANIN TOPLAMINA uygulanır, kişi başına değil.
	#
	# §3 — LİDER AYRILIRSA YAPIM LİDERSİZ SÜRER, çarpan 1,0. Buradaki STATUS kontrolü
	# o cümlenin kendisidir ve gerçek bir kusuru kapatıyor: kayıt kişiyi silmediği için
	# `get_character` izindeki/ayrılmış lideri hâlâ döndürüyor ve liderlik bonusu
	# masada olmayan birinden okunmaya devam ediyordu. Kişi taşıyıcı listesinden
	# (assigned_to_job STATUS_ACTIVE filtreliyor) düşüyor ama bonusu kalıyordu.
	var lead: Character = CharacterRegistry.get_character(lead_id) if lead_id != "" else null
	var leadership: int = 0
	if lead != null and lead.status == HRConstants.STATUS_ACTIVE:
		leadership = HRSystem.skill(lead, HRConstants.SKILL_LEADERSHIP)
	return total * HRSystem.leadership_output_mult(leadership) * K_EFOR


## §6.3 — hata birikimi. Hatalar GELİŞTİRME'de birikir, BETA'da bulunur.
## Ekibin etkin YAZILIM ortalaması oranı düşürür ama SIFIRLAMAZ (taban 0,10).
static func line_bug_rate_per_effort() -> float:
	var carriers: Array[Character] = build_carriers()
	var ceil_now: float = bug_rate_ceil()
	if carriers.is_empty():
		return ceil_now
	var sum: float = 0.0
	for c in carriers:
		sum += HRSystem.effective_skill(c, HRConstants.AREA_ENGINEERING)
	var avg: float = sum / float(carriers.size())
	return clampf(ceil_now - BUG_RATE_SKILL_COEF * avg, BUG_RATE_FLOOR, ceil_now)


## §12 + §11.2 — YAYIN ANI. Hat durumları YALNIZ BURADA ilerler ve her kademe
## yayınlandığı sürümün cilasını damgalar.
##
## Damganın kademe başına olması §11.2'nin sözü ("Çarpan hat başına değil kademe
## başına saklanır") ve aynı zamanda §2/§12.3'ün geriye-dönük-bozma yasağının
## taşıyıcısı: sonraki bir sürümün tur sayısı önceki sürümün işini değiştiremez.
static func _apply_line_plan_at_ship(b: FeatureBuild) -> void:
	if b == null or b.planned_step_ids.is_empty():
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
		# §12.8 kapı-üstü bonusu KADEME BAŞINA ölçülür (kademenin kendi kapısına göre).
		var stamp: float = QualityModel.realization_stamp(
			turn_mult, LineGates.above_gate_bonus(sid))
		ProductState.set_line_tier(line_id, tier)
		ProductState.stamp_step(sid, stamp)
		# §19 — üç sinyal, tek emitter. line_completed hattın SON kademesinde,
		# delighter_shipped ise §12.4'ün "K3 yayınlandığında" tetiği (övgü olayı).
		EventBus.line_upgraded.emit(line_id, tier)
		if tier >= ProductLines.TIER_MAX:
			EventBus.line_completed.emit(line_id)
			EventBus.delighter_shipped.emit(sid)
	# §11.2/§11.3 — canlı eksenler hat modelinden YENİDEN türetilir. Ekonominin
	# okuduğu mvp_* alanları buradan beslenir, yani "önizleme == ship" garantisi
	# hat modelinde de aynen sürer.
	var dims: Dictionary = ProductState.realized_dims()
	# Olay delta'ları hat türevinin ÜSTÜNE biner (apply_dimension_delta'nın defteri).
	# Böylece "önizleme == ship" garantisi korunur VE olayın vaat ettiği etki hayatta
	# kalır; ikisi ayrı defterde durmasa biri diğerini siliyordu.
	for axis in QualityModel.AXES:
		var extra: float = float(b.axis_event_delta.get(axis, 0.0))
		GameState.set_flag("mvp_%s" % axis, maxf(0.0, float(dims.get(axis, 0.0)) + extra))


# Bug ve wear'in kaynağı: ekibin UZMANLIK AĞIRLIKLI ORTALAMASI (design doc §4) —
# sorumlu ×1.5, diğerleri ×1.0, kurucu Teknoloji'siyle ortalamaya girer.
# ORTALAMA, TOPLAM DEĞİL: iki yönlü keser. İyi kurucu + zayıf ekip → ortalama düşer, bug artar;
# zayıf kurucu + iyi ekip → ekip taşır. Kurucu kendini sorumlu yaptığında hız cezası yemez ama
# en iyi yazılımcısının ×1.5 kalite ağırlığını kaybeder — karar gerçek ve iki uçlu.
#
# EŞDEĞERLİK: kurucu YALNIZ (normal bir oyunun başlangıcı — DEBUG_SEED kapalı) ve sorumlu iken
# ortalama = (1.5 × tech) / 1.5 = tech, yani migration öncesi founder-only okumayla BİREBİR.
# Bu yüzden BUG_TECH_REDUCER / WEAR_TECH_REDUCER yeniden ölçeklenMEDİ.
const LEAD_EXPERTISE_WEIGHT := 1.5
const MEMBER_EXPERTISE_WEIGHT := 1.0


# BU ORTALAMA İKİYE BÖLÜNDÜ (2026-08-21). Tek bir "uzmanlık ortalaması" iki ayrı şeyi
# besliyordu — commit anındaki hata tohumu ve yayın sonrası aşınma — ve rev 2 §2 bu ikisini
# AYRI alanlara veriyor: "bug oranı" Yazılım'ın, "canlı bug aşınması" Test'in. Aynı sayıyı
# iki yere vermek, alan modelinin ayırdığı iki şeyi tekrar birleştirmek olurdu.
static func _team_area_avg(area_key: String, lead_id: String) -> float:
	var founder: Character = CharacterRegistry.get_founder()
	var founder_id: String = founder.id if founder != null else "founder"
	var lead_is_founder: bool = lead_id == "" or lead_id == "founder" or lead_id == founder_id
	var weight_sum: float = 0.0
	var weighted: float = 0.0
	# Kurucu build'deyse kalitesinden sorumludur; değilse ürünün kalitesine de karışmaz.
	if founder != null and _founder_on_build():
		weight_sum = LEAD_EXPERTISE_WEIGHT if lead_is_founder else MEMBER_EXPERTISE_WEIGHT
		weighted = weight_sum * float(GameState.get_founder_skill(area_key))
	for c in HRSystem.assigned_to(area_key):
		if c.category == "founder":
			continue
		var w: float = LEAD_EXPERTISE_WEIGHT if c.id == lead_id else MEMBER_EXPERTISE_WEIGHT
		weighted += w * float(int(c.role_stats.get(area_key, 0)))
		weight_sum += w
	if weight_sum <= 0.0:
		return 0.0
	return weighted / weight_sum


static func _area_sum(area_id: String) -> float:
	# `_active_role_sum`ın halefi: ROL değil ATAMA sayar (rev 2 §4) ve §5 çarpanlarını
	# uygular. Tek satırlık bir sarmalayıcı, çünkü ölçü HRSystem'in sözleşmesidir.
	return HRSystem.area_sum_for(area_id)


static func tester_find_mult() -> float:
	# Bulma isabeti: kaç gizli bug'ın gün içinde yüzeye çıktığı. TEST işine atanmış kimse
	# yoksa 1.0 — rev 2 §4 Test'i kendi işi yaptı, yani "test uzmanım var ama build'de"
	# artık gerçek ve anlamlı bir durum.
	return minf(1.0 + _area_sum(HRConstants.AREA_QA)
		* TESTER_FIND_PER_EXPERTISE, TESTER_FIND_MULT_MAX)


static func tester_tempo_mult() -> float:
	# Bulma/çözme temposu, aynı Test alanından. (Yazılım beta'ya team_speed üzerinden zaten
	# giriyor — PHASE_AREAS["bugfix"] hem qa hem engineering içerir.)
	return minf(1.0 + _area_sum(HRConstants.AREA_QA)
		* TESTER_TEMPO_PER_PACE, TESTER_TEMPO_MULT_MAX)


static func team_speed(b: FeatureBuild) -> float:
	# SAF FONKSİYON, her çağrıda taze (mid-build hire/fire anında etki —
	# capacity_speed_factor ile aynı tazelik sözleşmesi; capacity_split smoke kanunu).
	# Faz DUYARLI: build'in o anki fazı hangi rollerin çalıştığını belirler, yani aynı ekip
	# TASARIM'da ve GELİŞTİRME'de farklı hızda koşar (design doc §5).
	return _speed_for_phase(b.current_phase, b.lead_engineer_id)


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
	# Commit öncesi henüz faz yok; GELİŞTİRME hızıyla projekte edilir (eforun %60'ı o bantta,
	# üç fazın en uzunu — tek sayı gösterilecekse en temsili olan o).
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


## Hat modeliyle mi koşuyor? Plan doluysa evet. Düz katalog yolu planı boş bırakır.
static func is_line_build() -> bool:
	return active_build != null and not active_build.planned_step_ids.is_empty()


## §5 — TASARIM turunun maliyeti, efor cinsinden. EforTavanı'nın ÜSTÜNE biner.
static func design_turn_cost() -> float:
	return 0.0 if active_build == null else DESIGN_TURN_COST * active_build.total_efor


## §5 — koşan turun dolumu 0-1 (bar bunu çizer, "Tur 2/4" metnini de o taşır).
static func design_turn_progress() -> float:
	if not is_line_build():
		return 0.0
	var cost: float = design_turn_cost()
	if cost <= 0.0:
		return 0.0
	var into: float = active_build.design_efor_spent - float(active_build.design_turns_completed) * cost
	return clampf(into / cost, 0.0, 1.0)


## §5 — "Geliştirmeye geç →" ilk günden basılabilir, ama tur 1 dolmamışsa ONAY ister:
## "Tasarım turu tamamlanmadı. Bu sürüm potansiyelinin dörtte üçünü taşıyacak."
static func needs_design_confirm() -> bool:
	return is_line_build() and active_build.current_phase == "iteration" \
		and active_build.design_turns_completed < 1


## §5 — TASARIM tavanı doldu mu (dört tur). Dolduysa tur akışı parkta.
static func design_turns_maxed() -> bool:
	return is_line_build() and active_build.design_turns_completed >= DESIGN_TURN_MAX


# =========================================================================
#  §5 · §6 — HAT MODELİNİN SAATLİK TİKİ
# =========================================================================
# Düz katalog yolundan AYRI bir gövde, ve bilerek: bant modeli değişti. Eski yol
# tek `efor_spent` üzerinde üç bant taşıyordu (TASARIM [0, 0,20) · GELİŞTİRME
# [0,20, 0,80) · BETA). rev 6.1 §6.0 GELİŞTİRME barını EforTavanı'nın %100'üne
# kadar doldurur ve §5 TASARIM turlarının maliyetini o tavanın ÜSTÜNE bindirir —
# yani tasarım artık geliştirme barından çalmıyor, runway'den çalıyor.
static func _tick_line_build_hourly(f: float) -> void:
	var b := active_build
	if build_paused():
		return   # duraklama efor İŞLETMEZ; süre (burn) yine akar
	var rate: float = build_effort_per_day(b.lead_engineer_id) * f / float(HOURS_PER_BUILD_DAY)
	if rate <= 0.0:
		return
	match b.current_phase:
		"iteration":
			var cost: float = design_turn_cost()
			var ceiling: float = cost * float(DESIGN_TURN_MAX)
			if cost <= 0.0 or b.design_efor_spent >= ceiling - 0.0001:
				return   # dört tur doldu: TASARIM parkta, oyuncu geçmeyi seçecek
			b.design_efor_spent = minf(ceiling, b.design_efor_spent + rate)
			var done: int = mini(int(floor(b.design_efor_spent / cost + 0.0001)), DESIGN_TURN_MAX)
			if done > b.design_turns_completed:
				b.design_turns_completed = done
				EventBus.build_progress_changed.emit()
		"development":
			if b.efor_spent >= b.total_efor - 0.0001:
				return   # §6.4 — bar dolu, kapı açık, iş bitti
			var before: float = b.efor_spent
			b.efor_spent = minf(b.total_efor, b.efor_spent + rate)
			# §6.3 — hata/EFOR BİRİMİ. Hatalar harcanan işle doğar, geçen zamanla değil:
			# yavaş bir ekip aynı işi daha uzun sürede yapar ama daha çok hata üretmez.
			_accrue_line_bugs(b.efor_spent - before)
		"bugfix":
			_tick_beta_hourly(f)


static func _accrue_line_bugs(effort_delta: float) -> void:
	if effort_delta <= 0.0:
		return
	var b := active_build
	b.bug_progress += line_bug_rate_per_effort() * effort_delta
	while b.bug_progress >= 1.0:
		b.bug_count += 1
		b.bug_progress -= 1.0


static func _tick_build_hourly(f: float) -> void:
	var b := active_build
	if is_line_build():
		_tick_line_build_hourly(f)
		return
	# 1) Efor harcaması (%100'de durur; build Beta'da SÜRESİZ bekleyebilir — auto-ship YOK).
	#    İTERASYON BEKLEMESİ: ek tur koşarken ya da tavan parkında efor DONUK — tasarım
	#    bandı dolu, motorun harcayacağı iş yok; süre (burn) yine akar, bekleme bedava değil.
	var in_iter_hold: bool = b.current_phase == "iteration" \
		and (b.iteration_decision_pending or b.iteration_round_days > 0.0)
	# Bant sınırında TAŞMA YOK: TASARIM parkı tam PHASE_DESIGN_END·total, GELİŞTİRME
	# parkı tam PHASE_DEV_END·total — smoke ikisini de eşitlikle assert edebilir.
	# apply_speed_bonus totali büyütse bile aşağıdaki alt-makine frac'a değil ALANLARA
	# baktığı için park bozulmaz (total büyürse iş yeniden açılır ve yeni cap'te durur).
	var cap: float = b.total_efor
	if b.current_phase == "iteration":
		cap = minf(cap, PHASE_DESIGN_END * b.total_efor)
	elif b.current_phase == "development":
		cap = minf(cap, PHASE_DEV_END * b.total_efor)
	# Kapı cap'e bakar, total'e değil: dışarıdan (debug fikstürü) cap üstüne zorlanmış
	# bir efor'u minf'in sessizce AŞAĞI çekmesi ratchet'i bozardı — accrual o durumda
	# hiç koşmaz, alt-makine build'i olduğu yerden karara düşürür.
	# DURAKLAMA BURADA ISIRIR (R2): taşıyabilecek kimse boş değilse efor İŞLEMEZ.
	# SÜRE (burn) yine akar — park grameriyle aynı: beklemek bedava değil.
	var working: bool = b.efor_spent < cap and not in_iter_hold and not build_paused()
	if working:
		# §8.4: EK MESAİ HIZ BONUSU YOK. "Getiri saatin kendisidir. Ayrı bir hız çarpanı
		# yoktur, ayrı bir bonus yoktur. ... eski koddaki +%30/+%15 hız bonusu
		# kaldırılmıştır." Saatin getirisi artık team_speed'in İÇİNDE: her kişinin katkısı
		# HRSystem.daily_contribution'dan geliyor ve o, kişinin devraldığı saatle orantılı.
		# Blok çarpanı buna EKLENSEYDİ aynı saat iki kez ödüllendirilirdi.
		b.efor_spent = minf(cap,
			b.efor_spent + team_speed(b) * f / float(HOURS_PER_BUILD_DAY))
	# 2a) İterasyon alt-makinesi (Software Inc. segment grameri): turlar KENDİLİĞİNDEN
	#     zincirlenir; FAZ FLIP YOK — iterasyondan tek çıkış enter_development() seam'i.
	if b.current_phase == "iteration":
		if b.iteration_round_days > 0.0:
			# Ek tur geri sayımı: kapasite çarpanı süreyi esnetir (sprint grameri) — bir
			# takvim ritüeli bile paralel iş baskısında uzar; ekip hızı BİLEREK girmiyor.
			b.iteration_round_days = maxf(0.0, b.iteration_round_days - f / float(HOURS_PER_BUILD_DAY))
			if b.iteration_round_days == 0.0:
				_apply_iteration_round_gains(b)
				_end_round(b)
		elif b.iteration_count == 1 and not b.iteration_decision_pending \
				and b.efor_spent >= PHASE_DESIGN_END * b.total_efor - 0.0001:
			_end_round(b)   # tur 1 = tasarım bandının kendisi; dolunca tur 2 hemen başlar
		elif b.iteration_decision_pending and b.iteration_count < ITER_MAX_ROUNDS:
			# Kayıt göçü: eski (oyuncu-kapılı) grameriyle tavan altında park etmiş bir save
			# yüklendiğinde park kendiliğinden çözülür — pending yalnız TAVANDA yasal.
			_start_next_round(b)
		return   # dev/beta bant kontrolleri ve yan süreçler iterasyonu ilgilendirmez
	# 2b) Dev→beta OTOMATİK DEĞİL (Build Bar, 2026-08-19): geliştirme bandı dolunca build
	#     %80'de PARK eder; çıkış yalnız enter_beta() (oyuncunun "Beta'ya geç" kararı).
	# 3) Faz-bantlı yan süreçler.
	if b.current_phase == "development":
		# Dev-bug birikimi yalnız KOD YAZILIRKEN: parkta kimse çalışmıyor, bug da doğmuyor
		# (tasarım parkının aynası — bekleme süre/burn yakar, hata üretmez).
		if working:
			_accrue_bugs_hourly(f)      # saatlik dev-bug birikimi → Geliştirme bandı (KEEP)
	elif b.current_phase == "bugfix":
		_tick_beta_hourly(f)            # arka-plan sertleştirme (find/fix), Beta'da süresiz (KEEP)


static func _apply_tech_debt_due(b: FeatureBuild) -> void:
	# Dev event'lerinde alınan tech-debt gerçek bug'a döner — dev→beta geçişinde
	# uygulanır (borçtan kaçış yok; erken-ship yolu Rev3'te kapandı).
	if GameState.get_flag("tech_debt_birikti", false):
		b.bug_count += TECH_DEBT_BUG_PENALTY
		GameState.set_flag("tech_debt_birikti", false)


# =========================================================================
#  İterasyon döngüsü (Software Inc. segment grameri, 2026-08-19) + ekip kalite tavanı
# =========================================================================
# Turlar kendiliğinden zincirlenir (_end_round → _start_next_round), tavanda park
# (_pend_iteration_decision); fazdan çıkış YALNIZ oyuncunun "Geliştirmeye geç"
# kararı (enter_development, tur 1 bitince açılır). Geliştirme bandı da parkla biter:
# çıkış "Beta'ya geç" (enter_beta). Eski advance_iteration/can_advance_iteration
# çifti emekli — "Bir tur daha" butonu yok, tur zaten kendi kendine dönüyor.

static func iteration_axis_ceilings() -> Dictionary:
	# Eksen başına iterasyon-kazanç tavanı: KİM çalışıyorsa o belirler, kaç tur
	# döndüğün değil. Kurucu tabanı EKSENİN KENDİ ALANINDAN okunur (eskiden her eksende
	# aynı `tech`ti — kurucu artık altı alan taşıdığı için tek bir sayıya bakmak onun
	# profilini düzleştirirdi). Build ekibinin o alandaki toplamı eksenini yükseltir,
	# terim CAP'te kesilir (PM_EXPERIENCE_CAP grameri: cap TERİME, eksene değil).
	# O alanda kimse yok → terim 0 → tavan = kurucu taban (zero-staff neutrality).
	var out := {}
	for ax in QualityModel.AXES:
		var area_key: String = String(ITER_CEIL_AXIS_AREA.get(ax, ""))
		var base: float = ITER_CEIL_FOUNDER_COEF * float(_founder_build_area(area_key))
		var term: float = minf(
			_build_area_sum(area_key) * ITER_CEIL_ROLE_COEF, ITER_CEIL_ROLE_CAP)
		out[ax] = base + term
	return out


static func _founder_build_area(area_key: String) -> int:
	# Kurucunun bir alandaki puanı, YALNIZ build işindeyse. Değilse 0: ch. 02 §5'in
	# "tek iş" kilidi burada da geçerli — satıştaki kurucu tasarım tavanını yükseltmez.
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null or not _founder_on_build():
		return 0
	return int(founder.role_stats.get(area_key, 0))


static func _build_area_sum(area_key: String) -> float:
	# O ALANA atanmış ÇALIŞANLARIN toplamı, §5 çarpanlarıyla. Kurucu ayrı saydığı için
	# (bkz. _founder_build_area) burada dışarıda.
	var total: float = 0.0
	for c in HRSystem.assigned_to(area_key):
		if c.category == "founder":
			continue
		total += HRSystem.daily_contribution(c, area_key)   # §4.5 + §8.4
	return total


static func _end_round(b: FeatureBuild) -> void:
	# Bir tur bitti (tur 1 = tasarım bandı, tur ≥2 = ITER_ROUND_DAYS geri sayımı).
	# Tavan altındaysa bir sonraki tur HEMEN başlar; tavanda park (yalnız "Geliştirmeye
	# geç" kalır). Run'ın İLK tur sonunda bir kez öğretici moment (turların kendi
	# kendine döndüğünü ve "yeter" demenin oyuncuda olduğunu öğretir).
	# The one-shot is the CARD's. `_iter_intro_shown` was a static bool that also had to be
	# serialised (a private latch for one card had reached the save file), and it existed
	# only because one_shot was inert on the injected path.
	EventGate.request("product.design_round_intro")
	if b.iteration_count < ITER_MAX_ROUNDS:
		_start_next_round(b)
	else:
		_pend_iteration_decision(b)


static func _start_next_round(b: FeatureBuild) -> void:
	# ITER_ROUND_DAYS'lik yeni tur; kazanç tur SONUNDA uygulanır (_tick_build_hourly geri
	# sayar → _apply_iteration_round_gains → _end_round). pending(false) emit'i kayıt
	# göçü yolunun (eski park) dinleyicilerini de temizler.
	b.iteration_count += 1
	b.iteration_round_days = float(ITER_ROUND_DAYS)
	b.iteration_decision_pending = false
	EventBus.build_iteration_decision_pending.emit(false)
	EventBus.build_progress_changed.emit()
	if OS.is_debug_build():
		print("[ProductSystem] Iteration round %d started (%d days)" % [b.iteration_count, ITER_ROUND_DAYS])


static func can_enter_development() -> bool:
	# UI kapısı: TASARIM'da, tur 1 bittikten sonra (tur 2 başlamış ya da tavan parkı).
	# Tur ortasında da basılabilir — yarım tur kazançsız terk edilir (Build Bar tooltip'i
	# bunu söyler: BUILD_HALF_ROUND_TOOLTIP).
	# §5 (rev 6.1) — HAT MODELİNDE İLK GÜNDEN İTİBAREN BASILABİLİR. Eski kural turun
	# bitmesini bekliyordu; yeni cila merdiveni bunu gereksiz kılıyor çünkü acele
	# etmenin bedeli artık bir KİLİT değil bir ÇARPAN (×0,75) ve oyuncu onu onay
	# diyaloğunda okuyor (needs_design_confirm).
	if is_line_build():
		return active_build.current_phase == "iteration"
	return active_build != null and active_build.current_phase == "iteration" \
		and (active_build.iteration_count >= 2 or active_build.iteration_decision_pending)


static func enter_development() -> void:
	# Oyuncu kararı: "Geliştirmeye geç." İterasyondan TEK çıkış — otomatik yol yok.
	# Koşan yarım tur terk edilir: kazanç yalnız tur SONUNDA uygulandığından, burada
	# hiçbir eksen oynamaz (determinizm case'leri "sıfır bedava kalite" sözleşmesi).
	if not can_enter_development():
		push_warning("[ProductSystem] enter_development before the first design round ended")
		return
	var b := active_build
	b.iteration_decision_pending = false
	b.iteration_round_days = 0.0
	b.current_phase = "development"
	b._sync_status_from_phase()
	EventBus.build_iteration_decision_pending.emit(false)
	_reseat_founder("development")
	EventBus.build_phase_changed.emit("development")


static func can_enter_beta() -> bool:
	# GDD ÜRÜN rev 6.1 §6.4 — %100 KAPISI GERİ GELDİ.
	#
	# H1 (2026-08-22) bu eşiği kaldırmış ve kaldırırken kendi gerekçesinde bedelinin
	# olmadığını yazmıştı: hatalar yalnız GELİŞTİRME'de birikiyor, yani erken geçmek
	# daha az hata VE daha kısa yapım demekti — bedelsiz baskın strateji. §6.4 kapıyı
	# geri koyuyor ve neden borç yerine kapı olduğunu söylüyor: teknoloji borcu demo
	# dışı (§1), o yüzden eksik geliştirme cezalandırılamaz; cezalandırılamayan şey
	# yasaklanır. "Erken faz atlama yoktur."
	#
	# Kapı KAPALIYKEN gerekçesini gösterir (§6.4, S6'nın çizdiği satır):
	# "GELİŞTİRME %100 olmadan BETA'ya geçilemez."
	return active_build != null and active_build.current_phase == "development" \
		and development_band_complete()


static func development_band_complete() -> bool:
	## "Geliştirme bandı doldu mu" — H1 ÖNCESİ `can_enter_beta`'nın GÖVDESİ.
	##
	## Kapı açıldı (oyuncu her yüzdede beta'ya geçebilir) ama bandın KENDİSİ duruyor:
	## efor `PHASE_DEV_END`'de park ediyor ve orada hata birikmiyor. İki soru aynı
	## ifadeyle soruluşu TESADÜFTİ — "basılabilir mi" ile "iş bitti mi" aynı şey değil.
	##
	## OKUYUCULARI SÜRÜCÜLER: smoke fixture'ları ve `run_probe` TEMSİLÎ bir oyuncuyu
	## oynuyor; baskın ama bugün bedelsiz olan erken çıkışı almaları, kalibrasyonla
	## ilgisi olmayan bir sebeple bütün sayılarını değiştirirdi.
	# §6.0/§6.4 (rev 6.1) — HAT MODELİNDE BAR EforTavanı'NIN %100'ÜNE KADAR DOLAR.
	# Eski model üç bandı tek sayaca sığdırdığı için geliştirme %80'de parkediyordu;
	# yeni modelde TASARIM'ın maliyeti ayrı bir sayaçta (design_efor_spent) durduğu
	# için geliştirme barı tavanın tamamını kullanabiliyor.
	if is_line_build():
		return active_build.current_phase == "development" \
			and active_build.efor_spent >= active_build.total_efor - 0.0001
	return active_build != null and active_build.current_phase == "development" \
		and active_build.efor_spent >= PHASE_DEV_END * active_build.total_efor - 0.0001


static func enter_beta() -> void:
	# Oyuncu kararı: "Beta'ya geç." Geliştirme parkından TEK çıkış (eski otomatik
	# dev→beta ratchet'inin gövdesi buraya taşındı — davranış aynı, tetik oyuncuda).
	if not can_enter_beta():
		push_warning("[ProductSystem] enter_beta outside the development phase")
		return
	var b := active_build
	_apply_tech_debt_due(b)                        # borç beta girişinde düşer (mevcut kural)
	b.current_phase = "bugfix"
	b._sync_status_from_phase()
	# Beta sayaçları sıfırdan başlar; dev'in ürettiği bug'lar "gizli" havuz olarak
	# bug_count içinde durur, test onları BULUR.
	b.bugs_found = 0
	b.bugs_fixed = 0
	b.bug_find_progress = 0.0
	b.bug_fix_progress = 0.0
	# §7 — keşif sönümünün başlangıç noktası. Gün damgası burada alınır, çünkü sönüm
	# BETA'da geçirilen günü okur, yapımın toplam yaşını değil.
	b.beta_entered_day = GameState.day
	# Snapshot bug count at bugfix entry so the tracker can read
	# "started with M, shipped with N". Keyed by build id. Build Bar'ın BETA çubuğu
	# bunu payda olarak okur (bug_count / bug_count_at_bugfix_start).
	GameState.set_flag("bug_count_at_bugfix_start_%s" % b.id, b.bug_count)
	_sync_legacy_quality(b)
	_reseat_founder("bugfix")
	EventBus.build_phase_changed.emit("bugfix")
	if OS.is_debug_build():
		print("[ProductSystem] Development band complete → BETA. hidden_bugs=%d" % b.bug_count)


static func _pend_iteration_decision(b: FeatureBuild) -> void:
	# Tavan parkı: ITER_MAX_ROUNDS'a gelindi, tur kalmadı — efor donuk, süre akar,
	# tek çıkış enter_development().
	b.iteration_decision_pending = true
	EventBus.build_iteration_decision_pending.emit(true)
	EventBus.build_progress_changed.emit()


static func _apply_iteration_round_gains(b: FeatureBuild) -> void:
	# Tur kazancı: her eksen KENDİ tavanına doğru azalan getiriyle (grow asimptotik —
	# tavan aşımı yapısal olarak imkânsız; damga tavanın üstündeyse kazanç tam 0 ve
	# damga asla geri alınmaz, grow pozitif raw'da current'ı düşürmez). Sıfır tavan
	# guard'ı grow'un bölenini korur (kurucu tech 0 + rolsüz ekip).
	# TAVAN YALNIZ iterasyon kazançlarına — commit damgası ve event dimension_delta bu
	# yasanın dışında (başlıktaki "ship ≥ preview" doktrin notu).
	var ceilings: Dictionary = iteration_axis_ceilings()
	var c_inno: float = float(ceilings.get("innovation", 0.0))
	var c_stab: float = float(ceilings.get("stability", 0.0))
	var c_exp: float = float(ceilings.get("experience", 0.0))
	if c_inno > 0.0:
		b.innovation = QualityModel.grow(b.innovation, float(ITER_ROUND_RAW["innovation"]), c_inno)
	if c_stab > 0.0:
		b.stability = QualityModel.grow(b.stability, float(ITER_ROUND_RAW["stability"]), c_stab)
	if c_exp > 0.0:
		b.experience = QualityModel.grow(b.experience, float(ITER_ROUND_RAW["experience"]), c_exp)
	_sync_legacy_quality(b)
	if OS.is_debug_build():
		print("[ProductSystem] Iteration round %d gains: I%.2f S%.2f E%.2f (tavan %.1f/%.1f/%.1f)" % [
			b.iteration_count, b.innovation, b.stability, b.experience, c_inno, c_stab, c_exp])


static func _tick_beta_hourly(f: float = 1.0) -> void:
	# BETA (iç faz "bugfix"): test gizli bug'ları BULUR, bulunanları ÇÖZER — ikisi de
	# otomatik; oyuncunun kararı ne kadar bekleyeceği. İnvaryant: gizli = bug_count -
	# (found - fixed); fix bug_count'u düşürür → effective_stability ve tüm mevcut
	# tüketiciler değişmeden çalışır. Hızlar working — Erdem balance-pass.
	var b := active_build
	var hidden: int = b.bug_count - (b.bugs_found - b.bugs_fixed)
	# §7 — KEŞİF KESKİN AZALIR ve HAVUZ TÜKENMEZ. İkisi tek karardır: düz bir oranın
	# tükenebilir bir havuzu, beklemeyi KESİN olarak kazançlı yapıyordu (sıfıra ulaşmak
	# yalnız takvim günü maliyetindeydi). Azalan oran + tükenmez havuz beklemeyi
	# kaybedilen bir yarışa çevirir, ve "9 açık hatayla yayınlamak" gerçek bir karar olur.
	# "Sıfıra asla ulaşılmaz ... Yayınlamak test etmekten hızlı hata bulur."
	var beta_day: int = maxi(0, GameState.day - b.beta_entered_day)
	var find_rate: float = BETA_BUG_FIND_PER_DAY * pow(beta_find_decay(), float(beta_day)) \
		* tester_find_mult() * tester_tempo_mult()
	b.bug_find_progress += find_rate * f / float(HOURS_PER_BUILD_DAY)
	while b.bug_find_progress >= 1.0:
		if hidden <= 0:
			# Havuz tükenmez: bulunacak bir şey hep vardır. Sayaç sahte bir tamamlanma
			# imasına düşmesin diye gizli havuz burada beslenir, BETA satırı da bu yüzden
			# yüzde taşımaz (§7, MÜHÜRLÜ).
			b.bug_count += 1
			hidden += 1
		b.bugs_found += 1
		hidden -= 1
		b.bug_find_progress -= 1.0
	if b.bugs_found - b.bugs_fixed > 0:
		b.bug_fix_progress += float(POLISH_BUG_FIX_PER_DAY) * tester_tempo_mult() * f / float(HOURS_PER_BUILD_DAY)
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
	# Eskiden burada YALNIZ kurucu tech'i okunuyordu — bir çalışan sorumlu olsa bile. Artık
	# GELİŞTİRME ekibinin UZMANLIK ağırlıklı ortalaması: düşük uzmanlıklı ekip aynı komplekste
	# daha çok bug üretir (design doc §5). Katsayı aynı kaldı, çünkü kurucu-yalnız hâli birebir.
	# rev 2 §2 verir: "bug oranı" YAZILIM alanının işidir.
	var expertise: float = _team_area_avg(HRConstants.AREA_ENGINEERING, b.lead_engineer_id)
	var rate: float = maxf(BUG_FLOOR, float(b.get_total_complexity()) * BUG_COMPLEXITY_COEF - expertise * BUG_TECH_REDUCER)
	# §8.4: EK MESAİ KALİTE CEZASI TAŞIMAZ. "Eski koddaki ×1,25 bug çarpanı kaldırılmıştır.
	# Gerekçe: §7 moralin kaliteye dokunmadığını söyler; ek mesainin dokunması aynı sınırı
	# ihlal ederdi. Ek mesainin bedeli NAKİT VE MORALDİR, o kadar."
	# TİTİZ: YAZILIM alanında çalışan her TİTİZ hata oranını düşürür. Çarpımsal ve
	# kişi başına: iki TİTİZ bir TİTİZ'den iyidir, ama getiri azalarak (0.5 × 0.5).
	# Alanın kendisi soruluyor çünkü rev 2 §2 hata oranını YAZILIM'a veriyor.
	for c in HRSystem.assigned_to(HRConstants.AREA_ENGINEERING):
		rate *= HRConstants.trait_mult(c.traits, "bug_rate_mult")
	rate = maxf(BUG_FLOOR, rate)
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
	# Bug TOHUMLAMA çarpanı Yazılımcı UZMANLIK ortalamasına bağlıdır (design doc §5).
	# PIVOT, ortalama değil: SEED_EXPERTISE_PIVOT'ta çarpan tam 1.0, yani "vasat bir ekip =
	# bugünkü davranış". Yazılımcı YOKKEN de tam 1.0 (aşağıdaki erken dönüş), bu yüzden
	# migration öncesi tohum sayıları bire bir korunur. Mesai çarpanı buraya GİRMEZ: tohum
	# commit anında bir kez atılır, yorgunluk ise bloğa yayılan saatlik bir maliyet.
	var mult: float = _seed_expertise_mult()
	var seeded: int = 0
	for fid in feature_ids:
		var cx: int = int(ProductCatalog.get_feature_by_id(String(fid)).get("complexity", 0))
		seeded += int(round(float(cx) * FEATURE_BUG_SEED_COEF * mult))
	return seeded


static func _seed_expertise_mult() -> float:
	# rev 2 §2: "bug oranı" YAZILIM'ın. YAZILIM alanına atanmış çalışanların ortalaması —
	# rol değil alan, ve rol değil ATAMA. Kimse atanmamışsa 1.0: kurucu tek başına yazıyor
	# ve bugünkü tohum aynen korunuyor.
	var crew: Array[Character] = []
	for c in HRSystem.assigned_to(HRConstants.AREA_ENGINEERING):
		if c.category != "founder":
			crew.append(c)
	if crew.is_empty():
		return 1.0
	var total: float = 0.0
	for c in crew:
		total += float(int(c.role_stats.get(HRConstants.AREA_ENGINEERING, 0)))
	var avg: float = total / float(crew.size())
	return clampf(1.0 + (SEED_EXPERTISE_PIVOT - avg) * SEED_EXPERTISE_SLOPE,
		SEED_EXPERTISE_MULT_MIN, SEED_EXPERTISE_MULT_MAX)


# --- Post-ship wear (Product Lifecycle Part 2A) ---

static func _post_ship_wear_hourly() -> void:
	# Live product accrues bugs from usage (audience) + complexity, minus founder
	# tech, floored positive. Fractional on mvp_live_bug_progress → mvp_live_bug_count
	# ticks up smoothly. Audience/MRR then erode automatically (economy reads live bug).
	var audience: float = float(GameState.get_flag("b2c_audience", 0))
	var complexity: int = _shipped_total_complexity()
	# rev 2 §2 verir: "canlı bug aşınması" TEST alanının işidir — commit anındaki hata
	# tohumundan (Yazılım) BİLEREK farklı bir alan. Bu iki okuma 2026-08-21'e kadar tek bir
	# "uzmanlık ortalaması"ydı; alan modeli onları ayırdı. Sorumlu yok (build bitti).
	var expertise: float = _team_area_avg(HRConstants.AREA_QA, "")
	var rate: float = maxf(WEAR_FLOOR, audience * WEAR_AUD_COEF + float(complexity) * WEAR_CPLX_COEF - expertise * WEAR_TECH_REDUCER)
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
	# Hata sprinti süresi Test Uzmanı ile KISALIR (design doc §5). Süre sprint başlarken bir
	# kez damgalanan bir flag, o yüzden okuma tick'te değil BURADA olmak zorunda.
	# Days to clear `bug_count` at the sprint rate, clamped. Shown pre-commit (§10).
	var rate: float = float(SPRINT_BUG_FIX_PER_DAY) * (1.0
		+ _area_sum(HRConstants.AREA_QA) * TESTER_SPRINT_PER_EXPERTISE)
	return clampi(int(ceil(float(bug_count) / maxf(0.01, rate))), MIN_SPRINT_DAYS, MAX_SPRINT_DAYS)


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
	# Sprint günlerini hatırlar. §17.6 BAYRAĞI ADIYLA KALDIRDI: "'Mühendise ihtiyaç var'
	# bayrağı — şirket çapında bir sinyali KİŞİ BAŞINA ROZET olarak çiziyor, yalnız developer
	# işe alınarak temizleniyor ve İngilizcede aşırı yük rozetiyle AYNI KELİMEYİ kullanıyor
	# (§16). Tamamen kaldırılır; anlatmak istediğini BUILD HIZI ve BUG BİRİKİMİ zaten söyler."
	# Sayaç kalıyor — bug sprint'lerinin sıklığı Ürün'ün kendi okuması.
	var history: Array = GameState.get_flag("bug_sprint_days", [])
	var recent: Array = []
	for d in history:
		if GameState.day - int(d) < ENGINEER_WINDOW_DAYS:
			recent.append(int(d))
	recent.append(GameState.day)
	GameState.set_flag("bug_sprint_days", recent)


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
	# TASARIM bölümünün kalite katkısı: Ürün Yöneticisi UZMANLIK'ı, commit anında Deneyim
	# eksenine ekip bonusu olarak girer (design doc §5). BURADA, damga yerinde DEĞİL: bu
	# fonksiyon aynı zamanda kurma ekranının radar önizlemesini de besliyor, bonusu yalnız
	# start_build/start_version_build'e koymak "önizleme == ship" yapısal garantisini kırardı.
	# Ekip commit anında belli olduğu için radar bonusu baştan gösterir.
	# TAVAN BONUS TERİMİNE uygulanır, eksen toplamına değil — aksi hâlde v2'de birikmiş
	# Deneyim tavana çarpar ve yeni bonus sessizce yutulur.
	out["experience"] = float(out["experience"]) + _pm_experience_bonus()
	return out


static func _pm_experience_bonus() -> float:
	# Build EKİBİNİN Tasarım alanı toplamı × katsayı, PM_EXPERIENCE_CAP'te kesilir.
	#
	# ALAN: TASARIM, Ürün değil. Bu bonus DENEYİM eksenine iniyor ve rev 2 §2 Deneyim
	# eksenini açıkça Tasarım'a veriyor — ITER_CEIL_AXIS_AREA da aynı eşlemeyi kullanıyor.
	# Aynı ekseni bir yerde Tasarım'dan, başka yerde Ürün'den beslemek iki farklı yasa olurdu.
	#
	# EKİP bonusu, kurucu DAHİL DEĞİL. Adı da bunu söylüyor ("ekip bonusu") ve eski hâlinde
	# yalnız Ürün Yöneticisi rolündeki ÇALIŞANLAR sayılıyordu. Kurucuyu eklemek onu iki kez
	# saydırırdı: kalite ortalamasına ve tavana zaten kendi alanlarıyla giriyor. Ekip yoksa
	# tam 0.0 — "PM'siz her mevcut smoke case'i bire bir aynı" sözleşmesi bu satırda yaşıyor.
	var total: float = _build_area_sum(HRConstants.AREA_DESIGN)
	if total <= 0.0:
		return 0.0
	return minf(total * PM_EXPERIENCE_PER_POINT, PM_EXPERIENCE_CAP)


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

static func projected_launch_bugs() -> int:
	# "Yayınla'ya basarsam kaç hata canlıya taşınır?" — TEK cevap, TEK ev.
	# Yayınla tooltip'i iki ev sahibinde de ham `bug_count` yazıyordu, ama launch()
	# yazmadan hemen önce CRITICAL_BUG_LAUNCH_PENALTY ekliyor: yani sayı, riski göze
	# alıp "Bırak, gönder" diyen oyuncuda — tam da dürüst sayıya en çok ihtiyacı olan
	# oyuncuda — beş eksik çıkıyordu. Formatter'ı paylaştırma disiplini
	# UiTokens.build_percent ile aynı (S2-8); launch()'ın kendisi de buradan okur, böylece
	# ceza aritmetiği tek yerde kalır.
	if active_build == null:
		return 0
	var n: int = active_build.bug_count
	if GameState.get_flag("critical_bug_unfixed", false):
		n += CRITICAL_BUG_LAUNCH_PENALTY
	return maxi(n, 0)


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
		active_build.bug_count = projected_launch_bugs()   # ceza aritmetiği orada, tek ev
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
	# §9 — SÜRÜM YAŞI, İLGİ ve YENİ-KOD TERİMİ yayın anında birlikte tazelenir.
	# Bu satır olmadan version_age_days() kalıcı olarak 0 okur, yani yeni-kod terimi
	# hiç sönmez ve ilgi hiç düşmez — akış modelinin iki yarısı da sessizce ölür.
	# Taşınan hata sayısı DOĞRULANMIŞ'a YAZILMAZ: §9'a göre taşınan hatalar zamanla
	# YÜZEYE ÇIKAR (GELEN'i besler), doğrulanmış olarak doğmazlar.
	ProductState.refresh_on_publish(active_build.total_efor)
	# §12 — hat durumları ve cila damgaları. Eksenleri BU YAZAR (hat modeli varsa),
	# yani yukarıdaki build-türevli mvp_* damgasının üstüne geçer. Düz katalog yolu
	# planı boş bırakır ve hiçbir şey değişmez — cutover budur.
	_apply_line_plan_at_ship(active_build)
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

# Is the company committed to a B2B product — shipped OR currently building one?
#
# Deliberately BROADER than SalesSystem.is_b2b_market(), and the two are not
# interchangeable. That one asks "does the enterprise desk run today", so it reads the
# SHIPPED market only; this one asks "may the founder staff for enterprise work", and the
# answer becomes yes the moment they commit to building it — otherwise the roles would
# unlock only after the product ships, which is exactly when the desk is already busy.
static func has_b2b_product() -> bool:
	if String(GameState.get_flag("mvp_market_type", "")) == "b2b":
		return true
	var b: FeatureBuild = get_active_build()
	if b == null or b.sub_product_type_id == "":
		return false
	return ProductCatalog.get_market_type(b.sub_product_type_id) == "b2b"


static func get_active_build() -> FeatureBuild:
	return active_build


# =========================================================================
#  GDD ÜRÜN rev 6.1 §12 · HAT MODELİ YOLU — Konsept'ten yapıma
# =========================================================================
# Düz katalog yolu (`start_build` / `start_version_build`) hâlâ ağaçta ve hâlâ
# çalışıyor: cutover disiplini, yeşil bir şey yerine geçene kadar hiçbir şeyin
# silinmemesini istiyor. Yeni yol PLANI taşır, hat durumlarına YAYINDA dokunur.

## Konsept onayının tek doğrulayıcısı. "" = plan geçerli; aksi hâlde makine sebebi.
## Merdiven kurallarını ProductLines'a, kapıları LineGates'e sorar — burada üçüncü
## bir kopya YOK (§18).
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
		var line_id: String = String(step.get("line_id", ""))
		# §12.3 — merdiven: atlama yok, sürüm başına hat başına bir kademe, düşürme yok.
		var refusal: String = ProductLines.ladder_refusal(
			sid, ProductState.line_tier(line_id), accepted)
		if refusal != "":
			return refusal
		# §12.5/§12.7 — kapı ŞİRKET GENELİNDEN, Konsept ONAYINDA kontrol edilir.
		if not LineGates.is_unlocked(sid):
			return "locked"
		accepted.append(sid)
	return ""


## §6.0 — EforTavanı: sürümde seçilen kademelerin efor toplamı. TASARIM turlarının
## maliyeti bunun ÜSTÜNE biner (§5), bu yüzden tavana dahil DEĞİL.
static func effort_ceiling(step_ids: Array) -> int:
	return ProductLines.sum_effort(step_ids)


## §3'ün maliyet dürüstlüğü önizlemesindeki "Süre ~N gün".
##
## Düz katalog yolunun `estimate_build_days`'inin hat modelindeki karşılığı, ve
## şekli DEĞİŞTİ: tavan artık barın tamamı (§6.0) ve TASARIM turunun maliyeti onun
## ÜSTÜNE biniyor (§5). Önizleme TEK TUR varsayar — taban cila ×1,00 — çünkü tur
## sayısı TASARIM'da belirlenir ve Konsept onu bilemez; kart altbilgisi de zaten
## "Fazla tasarım turu cilayı artırır" diyor.
static func estimate_line_build_days(step_ids: Array, lead_id: String = "") -> int:
	var ceiling: float = float(effort_ceiling(step_ids))
	if ceiling <= 0.0:
		return 0
	var design: float = DESIGN_TURN_COST * ceiling
	var rate: float = build_effort_per_day(lead_id) * projected_speed_factor_with_extra_job()
	return int(ceil((ceiling + design) / maxf(0.01, rate)))


## Konsept önizlemesi — §5: net kazanç TABAN seviyede (×1,00) gösterilir, tam
## tasarımda değil, çünkü tur sayısı TASARIM'da belirlenir ve Konsept onu bilemez.
static func projected_line_dims(subtype: String, step_ids: Array) -> Dictionary:
	var tiers: Dictionary = ProductState.line_tiers()
	var stamps: Dictionary = ProductState.line_realization()
	for raw in step_ids:
		var step: Dictionary = ProductLines.step(String(raw))
		if step.is_empty():
			continue
		var line_id: String = String(step.get("line_id", ""))
		tiers[line_id] = int(step.get("tier", 0))
		stamps[line_id] = 1.00   # §5 tabanı
	return QualityModel.realized_dims(subtype, tiers, stamps)


## Hat modeliyle bir sürüm başlatır. `step_ids` Konsept'te seçilen kademelerdir;
## hat durumlarına DOKUNMAZ (yayında dokunulur), o yüzden iptal doğal olarak
## §12.3 kural 4'ü sağlar.
static func start_line_build(subtype: String, step_ids: Array, lead_id: String = "",
		product_name: String = "") -> bool:
	if active_build != null:
		push_warning("[ProductSystem] start_line_build called while a build is active")
		return false
	var refusal: String = validate_line_plan(subtype, step_ids)
	if refusal != "":
		push_warning("[ProductSystem] start_line_build refused: %s" % refusal)
		return false

	# Taahhüt edilen ürün alt-türü SEÇER (onboarding rework 2026-07-16). start_build
	# bunu yapıyordu, start_line_build YAPMIYORDU — ve düz akış emekli olduğu an
	# `GameState.subgenre` bir daha hiç yazılmayacaktı: subgenre olay koşulları,
	# haber havuzu (news_feed_system "ai"|"saas"|"social" bekler) ve Meridian
	# boyut tohumlaması sessizce açılış değerinde donardı.
	var pool_key: String = ProductCatalog.get_pool_of(subtype)
	if pool_key != "":
		GameState.set_subgenre(pool_key)

	var typed: Array[String] = []
	for raw in step_ids:
		typed.append(String(raw))

	var b := FeatureBuild.new()
	var next_version: int = int(GameState.get_flag("mvp_version", 0)) + 1
	b.id = "mvp_build_v%d" % next_version
	b.is_version_build = ProductState.is_live()
	b.sub_product_type_id = subtype
	b.planned_step_ids = typed
	b.lead_engineer_id = lead_id
	b.assigned_engineer_id = lead_id
	b.product_name = product_name.strip_edges() if product_name.strip_edges() != "" \
		else ProductState.product_name()
	b.start_day = GameState.day
	b.is_mvp = not b.is_version_build
	b.current_phase = "iteration"
	b.iteration_count = 1
	b.iteration_decision_pending = false
	b.iteration_round_days = 0.0
	b.design_turns_completed = 0
	b.design_efor_spent = 0.0
	# §6.0 — bar bu tavanın %100'üne kadar dolar (§6.4).
	b.total_efor = float(effort_ceiling(typed))
	b.efor_spent = 0.0
	# §6.3 — hatalar GELİŞTİRME'de BİRİKİR; commit'te tohumlanmazlar.
	b.bug_count = 0
	b.bug_progress = 0.0
	# Önizleme eksenleri taban cilayla; kesin değer yayında damgalanır.
	var dims: Dictionary = projected_line_dims(subtype, typed)
	b.innovation = float(dims.get("innovation", 0.0))
	b.stability = float(dims.get("stability", 0.0))
	b.experience = float(dims.get("experience", 0.0))

	# Lisans maliyetleri commit'te BİR KEZ tahsil edilir (§12.4).
	var cost: int = ProductLines.sum_license_cost(typed)
	if cost > 0:
		FinanceSystem.apply_one_time_cost(cost, "build_commit")

	active_build = b
	GameState.set_flag("mvp_sub_product_type_id", subtype)
	EventBus.build_started.emit(b.id)   # §19
	EventBus.build_phase_changed.emit(b.current_phase)
	EventBus.build_progress_changed.emit()
	return true


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
	var st_name: String = ProductCatalog.type_name(sub_product_type_id)
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
	# İterasyon döngüsü sayaçları: tur 1 = tasarım bandının kendisi.
	b.iteration_count = 1
	b.iteration_decision_pending = false
	b.iteration_round_days = 0.0
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
	_reseat_founder("iteration")
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
	# İterasyon döngüsü sayaçları v-build'de de sıfırdan: tur 1 = tasarım bandı.
	b.iteration_count = 1
	b.iteration_decision_pending = false
	b.iteration_round_days = 0.0
	# Rev3 efor: yalnız YENİ iş sayılır (yeni feature eforu + strengthen pick başına sabit).
	b.total_efor = float(ProductCatalog.sum_efor(typed_new) + STRENGTHEN_EFOR * typed_strengthen.size())
	b.efor_spent = 0.0
	b._sync_status_from_phase()
	_sync_legacy_quality(b)
	# Maliyet: YALNIZ yeni feature'lar (inherited/strengthen asla yeniden tahsil edilmez).
	FinanceSystem.apply_one_time_cost(ProductCatalog.sum_cost(typed_new), "version_build_commit")
	active_build = b
	_reseat_founder("iteration")
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




static func apply_dimension_delta(axis: String, amount: int) -> void:
	# Build-event modifier (Rev3): DÜZ ekleme, taban 0 — grow() yok (grow rakiplerde
	# yaşamaya devam eder). Build event'leri deterministik tabandan oynanan sapmalardır:
	# event delta'sı yoksa önizleme == ship; her delta event_modal'da görünür rozet taşır.
	if active_build == null:
		return
	if not (axis in QualityModel.AXES):
		axis = "innovation"
	# HAT MODELİNDE EVENT DELTA'SI AYRI DEFTERDE TUTULUR ve bu bir düzeltmedir:
	# yayında eksenler hat durumlarından YENİDEN türetiliyor (§11.2), yani doğrudan
	# b.innovation'a yazılan bir olay etkisi ship anında SESSİZCE SİLİNİRDİ. Olay
	# rozeti oyuncuya bir şey vaat edip hiçbir şey yapmazdı — "her olay iddiası
	# modifier'ıyla eşleşir" yasasının tam ihlali.
	if is_line_build():
		var d: Dictionary = active_build.axis_event_delta.duplicate()
		d[axis] = float(d.get(axis, 0.0)) + float(amount)
		active_build.axis_event_delta = d
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
		TranslationServer.translate("PROD_SHIP_FIRST_TITLE") if ship_ver <= 1
		else TranslationServer.translate("PROD_SHIP_VERSION_TITLE").format({"version": ship_ver}), 50)
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
	# §19 — sürüm CANLIYA çıktı. Tek emitter burasıdır: launch() yalnız damgalar,
	# gerçekten yayına geçiren adım budur.
	EventBus.version_shipped.emit(int(GameState.get_flag("mvp_version", 1)))

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
		return "saglikli"   # LOC-DATA health band id
	return "riskli"


static func product_bug_risk() -> String:
	# "dusuk" | "orta" | "yuksek" — canlı bug / ship edilmiş toplam complexity oranı.
	var ratio: float = float(int(GameState.get_flag("mvp_live_bug_count", 0))) / float(max(1, _shipped_total_complexity()))
	if ratio >= BUG_RISK_YUKSEK:
		return "yuksek"   # LOC-DATA risk band id
	if ratio >= BUG_RISK_ORTA:
		return "orta"
	return "dusuk"   # LOC-DATA risk band id


# --- The ship moment ---
#
# Three GameEvent builders lived here — the first ship, the version ship, and the teaching beat
# at the end of the first design round. All three are cards now, and one of them was carrying a
# defect the port surfaced: the version-ship card's single option is what CALLS
# ship_active_build, so classing it as a badge would have left `active_build` uncleared after
# every version. A card holding an irreversible state transition is not a notification.

static func _trigger_ship_moment(is_version: bool = false) -> void:
	# NAMED, not built. Both cards are `tick: request` rather than firing off
	# `version_shipped`, and that is not a preference: `version_shipped` is emitted at the END
	# of ship_active_build, which is what this card's own option CALLS. A card triggered by
	# its own consequence fires one ship late, forever.
	EventGate.request("product.version_ship" if is_version else "product.first_ship")


