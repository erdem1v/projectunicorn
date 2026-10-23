class_name ProductSystem
extends RefCounted

# Canlı ürün. Saf mantık: TimeManager günlük tiki (daily_tick, slot 1) sürer; durum GameState.flags'teki
# mvp_* anahtarlarındadır. Yapım sprint motorundadır (SprintSystem), hata deposu ProductState'te, akış
# SupportSystem'de; burada koşu sınırı, haftalık açık hata görüntüsü ve saat damgaları var.


# --- Koşu sınırı ve kayıt ---

static func reset() -> void:
	# Yeniden başlatma ve yükleme, önceki koşunun DESTEK artığını ve okuma kenarlarını yeni şirkete
	# taşımasın. Kayıttaki gizli hatları RnDSystem geri açar.
	ProductLines.reload()
	SupportSystem.reset()
	ProductRead.reset()
	ProductState.bugs_free = false


static func to_dict() -> Dictionary:
	# Canlı ürün GameState.flags'teki mvp_* anahtarlarında; burada DESTEK artığı.
	return {"support": SupportSystem.to_dict()}


static func from_dict(d: Dictionary) -> void:
	SupportSystem.from_dict(d.get("support", {}) as Dictionary)


static func daily_tick() -> void:
	# Açık hata görüntüsü haftanın ilk işidir: sprint kapanışı ve yeni hatalar ondan sonra gelir.
	if ProductState.is_live():
		ProductState.snapshot_open_bugs()


## Ürün B2B mi: tür Ürün sekmesinde seçildiği anda yazılır, kurucu kurumsal iş için o andan
## kadro kurabilir. SalesSystem.is_b2b_market()'ten ("kurumsal masa bugün çalışıyor mu") geniştir.
static func has_b2b_product() -> bool:
	return String(GameState.get_flag("mvp_market_type", "")) == "b2b"


# --- Saat damgası ---

## Oyuncu eyleminin tik damgası, saat kesriyle: sürüm yaşı eylemin saatinden ölçülür.
static func clock_stamp() -> float:
	return float(GameState.day) + float(GameState.current_hour) / float(TimeModel.HOURS_PER_DAY)
