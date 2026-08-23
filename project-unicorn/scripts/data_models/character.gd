class_name Character
extends Resource

# Character data model per TECH_SPEC §7.
# Plain data container, no scene dependency. Stored in CharacterRegistry
# (employees, mentor, NPCs) and operated on by HRSystem and future systems.
#
# Used now:
#   - Identity: id, character_name, role (typed id — HRConstants.ROLE_*), category
#   - Compensation: monthly_salary, equity_pct (feeds Finance via pull)
#   - Morale: morale (HR Core moves it from played causes only; range 0..100 clamped
#     in CharacterRegistry.set_morale)
#   - HR Core employment state: status, hire_day, leave_*, flight_risk_days, overtime_days
#   - role_stats: employees hold EXACTLY HRConstants.EMPLOYEE_SKILL_KEYS (0-9); the founder holds
#     EXACTLY FounderConstants.SKILLS. The two key sets never mix — CharacterRegistry.add
#     key-locks both and push_errors on a mismatch.
#   - traits: employees draw from HRConstants.TRAITS, the founder from
#     FounderConstants.TRAITS. Separate catalogs, separate validators.
#
# Reserved (declared with defaults so future systems plug in without
# retrofitting the model and so the save schema is forward-compatible):
#   - loyalty, relationship, trust_score, attention_flag
#
# Naming caution (TECH_SPEC §7): Node reserves `name`, so character names use
# the distinct field `character_name`. Watch for similar collisions in any
# future fields.

# --- Identity (used now) ---
@export var id: String = ""               # "char_<slug>" per TECH_SPEC §12 prefix
@export var character_name: String = ""   # NOT `name` — Node reserves it (TECH_SPEC §7)
@export var role: String = ""             # typed id (HRConstants.ROLE_*) — never free text
@export var category: String = "employee" # "founder" | "employee" | "mentor" | "npc"
# Portre yolu — BOŞ olması normal ve çoğunluk hâlidir. Portre politikası (GDD 14 §7):
# çalışanların yüzü YOKTUR, baş harfleriyle görünürler; portresi olanlar Frank ve
# müşteri/yatırımcı tarafındaki adlı karakterlerdir. Boş bırakıldığında her çizim yeri
# baş harflere düşer, yani mevcut kayıtlar ve her yeni işe alım hiçbir şey yapmadan
# bugünkü davranışı korur.
@export var portrait_path: String = ""
# NOTE: `department` is deliberately NOT stored — it is derived from `role` via
# HRConstants.department_of() / section_of() so the two can never fall out of sync.

# --- Compensation (used now — feeds Finance via CharacterRegistry pull) ---
@export var monthly_salary: int = 0
@export var equity_pct: float = 0.0       # hires get 0.0: employee equity is not in the HR design

# --- Morale (used now — range 0..100) ---
# There is NO autonomous drift. Morale moves only from played causes: overtime,
# overload, events, player actions and leave return (HR design doc §6).
@export var morale: int = 50

# --- Skills + traits (used now; see the header note on the key-lock) ---
@export var traits: Array[String] = []       # HRConstants.TRAITS ids (employees); no hidden traits
# GDD v2 ch. 07 rev 2 §2: skills are AREAS, and everyone carries all six plus Liderlik.
# Employee = HRConstants.EMPLOYEE_SKILL_KEYS (7) | founder = FounderConstants.SKILLS (8,
# the same six areas + Liderlik + Karizma). One ruler, 0-9, both sides.
@export var role_stats: Dictionary = {}

# --- §3 SEVİYE (rev 11) ---
# Rol FONKSİYONDUR ve terfide DEĞİŞMEZ; seviye terfinin değiştirdiği alandır.
# 0 Junior · 1 Orta · 2 Kıdemli (HRConstants.LEVEL_*). Unvan TÜRETİLİR ve saklanmaz —
# HRConstants.job_title(role, level). Üstte kasten boşluk bırakılır: Kıdemli tavandır.
@export var level: int = 1

# --- §9.1 "Maaş hiçbir koşulda düşürülemez" ---
# Bu kuralı TAŞIYAN alan: sahip olunan en yüksek maaş. Zam ve terfi ikisini de yükseltir;
# hiçbir yol bunu düşüremez.
@export var salary_floor: int = 0

# --- §9.2 / §9.3 bekleme süreleri ---
@export var last_raise_day: int = 0        # 0 = hiç zam almadı; §9.2 altı ay bundan okunur
@export var last_promotion_day: int = 0    # 0 = hiç terfi etmedi

# --- HR Core employment state (used now) ---
@export var status: String = "active"        # STATUS_ACTIVE | STATUS_ON_LEAVE | STATUS_TRAINING
@export var hire_day: int = 0                # stamped in CharacterRegistry.add; 0 = never hired
@export var leave_month: int = 0             # 1-12, assigned at hire; 0 = none
@export var leave_until_day: int = 0         # on_leave ends when GameState.day reaches this
@export var leave_taken_year: int = 0        # once-per-year latch (manual vacation consumes it too)
@export var flight_risk_days: int = 0        # consecutive days under MORALE_FLIGHT_RISK
@export var overtime_days: int = 0           # days worked in the CURRENT overtime block

# --- GÖREV ATAMASI (GDD v2 ch. 07 rev 2 §4) ---
# Kişi bir ya da birden fazla İŞE atanır (alana değil — §4 tablosunun başlığı "İş" ve
# kurucu maddesi "bir işe atandığında" diyor). Alanlar üç şey yapar: kim uygun, formül
# hangi sayıyı okur, ve o iş kişinin ana alanı mı (normal) ikincil alanı mı (§5, yorucu).
# BOŞ dizi = "Boşta": kişi durur ve maaş yer. Bu bir TÜRETİLMİŞ durumdur, saklanan bir
# bayrak değil — HRSystem.is_idle. Kurucu 0 ya da 1 iş taşır (ch. 02 §5, sert kilit);
# çalışan 1'den fazlasını taşıyabilir ve o AŞIRI YÜKLENMEDİR.
@export var assigned_jobs: Array[String] = []   # HRConstants.ASSIGNABLE alt kümesi
@export var overload_days: int = 0              # 2+ işte geçirilen ardışık gün; 1 ya da 0 işte sıfırlanır

# --- §12.0 ATANMIŞ İŞLER (rev 11) ---
# ATAMA BİRİMİ ARTIK İŞ. Beş iş var (HRConstants.JOBS) ve en fazla İKİSİ tutulabilir
# (MAX_JOBS_PER_PERSON, §12.1 — bir tavan, öneri değil).
#
# Yukarıdaki `assigned_jobs` ALAN id'si taşımaya DEVAM EDER ve bilerek eder: sekiz yer onu
# doğrudan okuyor, ve anlamını yerinde değiştirmek hepsini DERLENMEYE DEVAM EDERKEN
# ÇALIŞMAZ hâle getirirdi — mümkün olan en kötü kırılma biçimi. CharacterRegistry onu
# buradan TÜRETİR (iş → taşıyıcı alanları, kişinin gerçekten taşıdığı alanlara daraltılmış);
# eski okuyucular tam olarak eskisini görür. Ayna Faz 7'de, son okuyucu çevrildiğinde ölür.
@export var assigned_job_ids: Array[String] = []

# --- DENEYİM / EĞİTİM (2026-08-08; alan başına ayrıldı 2026-08-21) ---
# rev 2 §8: "Learn-by-doing: ATANDIĞI ALANIN deneyimi yavaş yükselir." Tek bir sayaç bunu
# söyleyemez — iki işte dönüşümlü çalışan biri tek havuz biriktirirdi ve hangi alanda
# ilerlediği son atamasına kalırdı. Onun için alan başına sayaç: {alan_id: 0..100}.
# Dolduğunda o alan +1 olur ve sayaç sıfırlanır (ÜCRETSİZ kanal). Ücretli eğitim ayrı
# kanaldır: oyuncu alanı seçer, ücret kademelidir, deneyim şartı YOKTUR (§8).
# Kurucu HARİÇ (kurucu gelişimi ayrı, park edilmiş sistem).
@export var area_experience: Dictionary = {}    # {HRConstants.AREAS üyesi: 0..EXPERIENCE_MAX}
@export var trainings_done: Dictionary = {}     # {alan_id: kaç kez eğitildi} — §8 azalan getiri
@export var training_days_left: int = 0      # >0 iken çalışan EDİLGEN (İzinde gibi); 0 = eğitimde değil
@export var training_area: String = ""       # eğitim bitince hangi alan +1 olacak; "" = eğitimde değil

# --- §5.1 DENEYİM: TEK BAR (rev 11) ---
# Alan bazlı DEĞİL. Yukarıdaki area_experience, tüketicileri Faz 2c'de çevrilene kadar
# duruyor ve Faz 7'de silinir. Bar ekranda hep 0–100 çizilir; çizilen oran
# experience_raw / experience_threshold'dur. Eşik gelişmişlikle büyür (§5.1), o yüzden
# saklanır: her yıldız değişiminde yeniden hesaplanır, her çizimde değil.
@export var experience_raw: int = 0
@export var experience_threshold: int = 0   # 0 = henüz hesaplanmadı

# --- §8.1 kişisel çalışma saati istisnası ---
# 0 = istisna YOK, kişi grubunu (o da yoksa şirketi) devralır. Kişi grup değiştirse de
# istisna kendisiyle taşınır. Çözümleme HİÇBİR ZAMAN burada yapılmaz — tek çözümleyici
# hr.work_hours(kişi)'dir (§15.2).
@export var work_hours_override: int = 0

# --- §11.4 yaz izni (rev 11) ---
# Haziran–Ağustos penceresi içinde 0..12 hafta indeksi; -1 = henüz atanmadı. Yukarıdaki
# leave_month / leave_taken_year ay tabanlı eski modelin alanları ve Faz 7'de silinir.
@export var leave_week: int = -1
@export var leave_deferrals: int = 0        # §11.4: bu yıl kaç kez ertelendi, en fazla 2

# --- §7 moral hedefi ---
# §7 "hedefe doğru sürüklenir, anında sıçramaz". Olay deltaları HEDEFE yazılır; görünen
# moral hedefe doğru günde MORALE_EASE_PER_DAY kadar yürür. -1 = tohumlanmadı (ilk tikte
# morale'den doldurulur). §15'in alan listesinde YOK ve bu bilinçli bir ekleme: §7'nin
# cümlesi kişi başına ikinci bir sayı olmadan uygulanamıyor (plan §9b Q1).
@export var morale_target: float = -1.0

# --- §15 employment_history: YALNIZ EKLENEN kayıt ---
# {tarih, tür, eski, yeni} — zam, terfi, eğitim, izin. Hiçbir kayıt güncellenmez ya da
# silinmez; okuyan taraf en sonuncuyu alır.
@export var employment_history: Array[Dictionary] = []

# --- Reserved for future systems (declared, not used) ---
@export var loyalty: int = 50                # event-driven; future
@export var relationship: String = "neutral" # ally | friendly | neutral | wary | hostile
@export var trust_score: int = 0             # -100..100
# SUPERSEDED by HRSystem.badges_for(), which DERIVES badges from morale/status/capacity
# using this same vocabulary. Left unwritten on purpose: an employee can carry two
# badges at once (TÜKENİYOR + AŞIRI YÜKLÜ) and one String cannot hold both.
@export var attention_flag: String = ""      # FLIGHT_RISK | BURNING_OUT | OVERLOADED | PROMO | CO_FOUNDER_TRACK
