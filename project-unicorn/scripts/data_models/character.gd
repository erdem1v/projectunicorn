class_name Character
extends Resource

# Karakter veri modeli (çalışan, kurucu, mentor, NPC). Sahnesiz düz veri; CharacterRegistry'de
# durur ve yalnız onun seam'lerinden yazılır. Her @export alanı SaveCodec taşır.
#
# role_stats: çalışan tam olarak HRConstants.EMPLOYEE_SKILL_KEYS, kurucu tam olarak
# FounderConstants.SKILLS taşır; CharacterRegistry iki anahtar kümesini de kilitler.
# traits: çalışan HRConstants.TRAITS'ten, kurucu FounderConstants.TRAITS'ten.
#
# Rozet alanı yoktur (§15.1): rozetler moral/durum/atamadan her çizimde türetilir.
# Node `name`'i ayırdığı için ad alanı `character_name`'dir.

# --- Kimlik ---
@export var id: String = ""               # "char_<slug>" prefix
@export var character_name: String = ""   # NOT `name` — Node reserves it
@export var role: String = ""             # typed id (HRConstants.ROLE_*) — never free text
@export var category: String = "employee" # "founder" | "employee" | "mentor" | "npc"
# Boş olması normaldir (GDD 14 §7): çalışanların yüzü yok, baş harfle çizilirler; portresi
# olanlar Frank ve adlı müşteri/yatırımcı karakterleridir.
@export var portrait_path: String = ""
# Grup saklanmaz; `role`'dan HRConstants.ROLE_GROUP ile türetilir.

# --- Maaş (Finance CharacterRegistry'den çeker) ---
@export var monthly_salary: int = 0

# --- Moral (0..100) ---
# §7: moral hedefe doğru sürüklenir (taban drift × saat çarpanı) ve adı olan olaylarla hareket eder; bkz. HRMoraleSystem.
@export var morale: int = 50

# --- Yetenek + özellik ---
@export var traits: Array[String] = []
# §4: yetenekler ALANDIR; herkes altı alanı + Liderlik'i taşır, kurucu ayrıca Karizma'yı.
# Tek cetvel, 0-10 (§4.1, §2.4).
@export var role_stats: Dictionary = {}

# --- §3 SEVİYE ---
# Rol terfide değişmez; seviye değişir. 0 Junior · 1 Orta · 2 Kıdemli (HRConstants.LEVEL_*).
# Unvan türetilir: HRConstants.job_title(role, level).
@export var level: int = 1

# §9.1 "Maaş hiçbir koşulda düşürülemez": sahip olunan en yüksek maaş.
@export var salary_floor: int = 0

# --- §9.2 / §9.3 bekleme süreleri ---
@export var last_raise_day: int = 0        # 0 = hiç zam almadı; §9.2 altı ay bundan okunur
@export var last_promotion_day: int = 0    # 0 = hiç terfi etmedi

# --- İstihdam durumu ---
@export var status: String = "active"        # STATUS_ACTIVE | STATUS_ON_LEAVE | STATUS_TRAINING
@export var hire_day: int = 0                # CharacterRegistry.add damgalar; 0 = işe alınmadı
@export var leave_until_day: int = 0         # izin GameState.day buna ulaşınca biter
@export var leave_taken_year: int = 0        # §11.4 "yılda bir" mandalı
@export var flight_risk_days: int = 0        # MORALE_FLIGHT_RISK altında art arda gün

# --- §12 GÖREV ATAMASI ---
# Atama birimi İŞTİR (HRConstants.JOBS); en fazla MAX_JOBS_PER_PERSON sürekli iş (§12.1).
# Boş dizi = "Boşta" (türetilir: HRSystem.is_idle).
# `assigned_jobs` işlerden TÜRETİLEN alan aynasıdır (HRConstants.AREAS alt kümesi); yalnız
# CharacterRegistry._sync_area_mirror yazar, alan okuyan yerler bunu okur.
@export var assigned_jobs: Array[String] = []
@export var assigned_job_ids: Array[String] = []
## Ar-Ge §5.0: dışlayıcı bir etkinliğin (araştırma) duraklattığı işler; o bitince geri döner.
## Duraklatma bir Ekip kavramı olduğu için Character'da durur, RnDSystem'de değil.
@export var paused_job_ids: Array[String] = []

# --- EĞİTİM ---
@export var trainings_done: Dictionary = {}  # {alan_id: kaç kez eğitildi}
@export var training_days_left: int = 0      # >0 iken eğitimde (edilgen); 0 = eğitimde değil
@export var training_area: String = ""       # bitince +1 alacak alan; "" = eğitimde değil

# --- §5.1 DENEYİM: tek bar ---
# Çizilen oran experience_raw / experience_threshold. Eşik gelişmişlikle büyür; her yıldız
# değişiminde yeniden hesaplanır, her çizimde değil.
@export var experience_raw: int = 0
@export var experience_threshold: int = 0   # 0 = henüz hesaplanmadı

# --- §8.1 kişisel çalışma saati istisnası ---
# 0 = istisna yok, kişi grubunu (o da yoksa şirketi) devralır. Tek çözümleyici WorkHoursSystem (§15.2).
@export var work_hours_override: int = 0

# --- §11.4 yaz izni ---
# Haziran–Ağustos penceresinde 0..12 hafta indeksi; -1 = henüz atanmadı.
@export var leave_week: int = -1
@export var leave_deferrals: int = 0        # §11.4: bu yıl kaç kez ertelendi, en fazla 2

# --- §7 moral hedefi ---
# "Hedefe doğru sürüklenir, anında sıçramaz": deltalar hedefe yazılır, görünen moral günde
# MORALE_EASE_PER_DAY yürür. -1 = tohumlanmadı (ilk tikte morale'den dolar). §15'in alan
# listesinde yok; §7 kişi başına ikinci bir sayı olmadan uygulanamıyor.
@export var morale_target: float = -1.0

# --- §15 employment_history: yalnız eklenir ---
# {day, kind, old, new}: zam, terfi, eğitim, izin. Okuyan en sonuncuyu alır.
@export var employment_history: Array[Dictionary] = []

# event_modal bunu bir pill olarak çizer.
@export var relationship: String = "neutral" # ally | friendly | neutral | wary | hostile
