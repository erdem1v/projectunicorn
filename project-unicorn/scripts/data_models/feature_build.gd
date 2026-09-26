class_name FeatureBuild
extends Resource

# Tek bir ürün yapımı (v1 ya da sürüm). Durumunu ProductSystem yazar; SaveCodec @export
# alanlarını jenerik gezer, ayrı codec yok. Ship MRR üretmez: eksenleri ve mvp_* bayraklarını
# yazar, ekonomik delta yoktur.

@export var id: String = ""
@export var sub_product_type_id: String = ""
@export var product_name: String = ""   # boşsa ekranda tip adı
@export var feature_ids: Array[String] = []
## Ship'te mvp_components'e yazılan liste (feature_ids ile aynı küme).
@export var component_ids: Array[String] = []
@export var assigned_engineer_id: String = ""
@export var lead_engineer_id: String = ""
@export var start_day: int = 0
@export var is_mvp: bool = false
## v2+: eksenleri canlı üründen tohumlar ve yayında mvp_version'ı artırır.
@export var is_version_build: bool = false

## planning / iteration / development / bugfix / shipped / cancelled.
@export var current_phase: String = "planning"
## current_phase'in eski dört değerli aynası (_sync_status_from_phase); kayıtta taşınır.
@export var status: String = "planning"

# Eksenler commit'te seçili katkılardan damgalanır (ProductSystem.projected_axes) ve yapım
# boyunca yalnız olay dimension_delta'sı oynatır. `quality` onlardan türetilen tamsayı aynadır.
@export var innovation: float = 0.0
@export var stability: float = 0.0
@export var experience: float = 0.0
@export var quality: int = 50
## Olay kaynaklı eksen sapmaları. Hat modelinde eksenler yayında hat durumlarından yeniden
## türetildiği (§11.2) için doğrudan b.innovation'a yazılan etki silinirdi; bu defter onu
## ship'in üstüne taşır.
@export var axis_event_delta: Dictionary = {}
## Seçilen özelliklerden (⊆ feature_ids) GÜÇLENDİRİLENLER: her biri baskın eksenine
## commit'te STRENGTHEN_AXIS_BONUS ekler.
@export var strengthened_feature_ids: Array[String] = []

# Efor motoru: ilerleme = efor_spent / total_efor.
@export var total_efor: float = 0.0
@export var efor_spent: float = 0.0

# Bug'lar. bug_count TÜM açık bug'lardır (gizli + bulunmuş-çözülmemiş), o yüzden
# effective_stability ve diğer tüketiciler onu okur. Gizli = bug_count − (found − fixed);
# KALAN = found − fixed; bir fix bugs_fixed'i artırır VE bug_count'u düşürür.
@export var bug_count: int = 0
@export var bug_progress: float = 0.0   # kesirli birikim; 1,0'ı geçtikçe bug_count artar
@export var bugs_found: int = 0
@export var bugs_fixed: int = 0
@export var bug_find_progress: float = 0.0
@export var bug_fix_progress: float = 0.0
## ÜRÜN rev 6.1 §7 — beta keşfi güne göre azalır (6 × 0,85^gün); girişte damgalanır.
@export var beta_entered_day: int = 0

## ÜRÜN rev 6.1 §12 — bu sürümün aldığı kademeler. Hat durumları yalnız YAYINDA güncellenir,
## o yüzden §12.3 kural 4 ("iptal edilen sürümün kademeleri hiç yapılmamış sayılır")
## özel durumsuz doğrudur: iptal geri alacak bir şey bulmaz.
@export var planned_step_ids: Array[String] = []
## §5 — tamamlanan tasarım turu; yayında kademelere damgalanan cila çarpanını seçer
## (0 tur ×0,75 · 1 ×1,00 · … · 4 ×1,15).
@export var design_turns_completed: int = 0
## §5 — tasarım turlarının yaktığı efor. EforTavanı'nın üstüne biner, efor_spent'ten ayrıdır:
## geliştirme barı tavanın %100'üne kadar dolar (§6.0), tur maliyeti barı değil runway'i kısaltır.
@export var design_efor_spent: float = 0.0
## §2 — oyuncunun duraklatması. Oto-duraklamadan ayrıdır: bar ikisini farklı söyler (oto
## cümleyle, manuel glifle) ve ikisi bir arada görünmez.
@export var manually_paused: bool = false

# İterasyon döngüsü: tasarım bandı dolunca decision_pending yanar (build parkta, efor donuk);
# her "Bir tur daha" count'u artırıp round_days'i kurar. Tur 1 = tasarım bandının kendisi.
@export var iteration_count: int = 0
@export var iteration_round_days: float = 0.0   # koşan ek turun kalan günü; 0 = tur yok
@export var iteration_decision_pending: bool = false

# Kayıt biçiminin parçası; bugün hiçbir sistem okumaz. is_bug_sprint hep false'tur (sprint
# durumu ProductSystem'in mvp_sprint_* bayraklarında).
@export var is_bug_sprint: bool = false
@export var total_days: int = 12
@export var days_remaining: int = 12
@export var min_estimation_days: int = 0
@export var equity_impact: float = 0.0
@export var revenue_share: float = 1.0
@export var tags: Array[String] = []
@export var quality_modifiers: Array = []
@export var iteration_days_in_current: float = 0.0
@export var development_days_total: int = 0
@export var development_days_elapsed: float = 0.0
@export var iteration_duration_days: int = 0
@export var polish_duration_days: int = 3
@export var polish_days_remaining: int = 0


func get_total_complexity() -> int:
	var total: int = 0
	for fid in feature_ids:
		total += int(ProductCatalog.get_feature_by_id(fid).get("complexity", 0))
	return total


func _sync_status_from_phase() -> void:
	match current_phase:
		"iteration", "development", "bugfix": status = "in_progress"
		"shipped": status = "shipped"
		"cancelled": status = "cancelled"
		_: status = "planning"
