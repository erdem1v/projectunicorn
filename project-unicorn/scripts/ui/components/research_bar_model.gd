extends RefCounted

# ============================================================================
# ResearchBarModel — ARAŞTIRMA çubuğunun TÜRETİLMİŞ veri nesnesi (Ar-Ge GDD §5.6).
# BuildBarModel'in ikizi ve onun sözleşmesini taşır.
#
# HİÇBİR ŞEY SAKLANMAZ, HER ŞEY SORULUR. `derive()` her çağrıda RnDSystem'e
# baştan sorar; ne ilerleme ne atama ne de donmuşluk burada bir kopya olarak
# yaşar. Kopya tutulsaydı bir atama değişikliği çubuğu state'in tersini iddia
# eder hâle getirirdi.
#
# ÇİZİLECEK BİR ŞEY YOKSA false. Aktif araştırma yoksa VEYA %100'e varmışsa
# `derive()` false döner ve çubuk KAYBOLUR. Araştırmanın DESTEK gibi kalıcı bir
# satırı yoktur (§5.8): tamamlanma ekonomik delta üretmez, yerine keşif kartı
# düşer. Dolmuş ve orada duran bir çubuk, olmayan bir ödülü bekletirdi.
#
# BİLİNÇLİ class_name YOK: çubuk `preload` eder. Yeni bir class_name, global
# class-cache tazelenene dek headless koşuları düşürür (BuildBarModel'le aynı ihtiyat).
#
# SÖZCÜKLER: `node_name`, `area_line` ve `pause_note` çözülmüş metindir çünkü üçü de bir
# KİMLİKTEN türüyor ve o çeviriyi yapan tek yer ResearchSeam/HRConstants/RnDSystem.
# Çeviri `tr()` değil `TranslationServer.translate` ile, ki bu kod statiğe taşınırsa
# loc_residue [static-tr] tetiklenmesin.
# ============================================================================

## RnDSystem.weeks_estimate -1.0 döndüğünde (katkı yok) bu değer taşınır. Çubuk sayı
## yerine "katkı yok" yazar.
const NO_WEEKS := -1

var node_id: String = ""
var node_name: String = ""
var area_line: String = ""        # "{area} alanı" — çözülmüş
var fill: float = 0.0             # araştırmanın ilerlemesi 0-1
var percent: int = 0              # ekrana yazılan yüzde, 0-99
var weeks_left: int = NO_WEEKS
var paused: bool = false          # §5.7 donmuş = aktif araştırma, üstünde kimse yok
var pause_note: String = ""       # donmanın sebep cümlesi; koşarken ""
var assignee_names: Array[String] = []


## true = çizilecek bir şey var. false = çubuk yok.
func derive() -> bool:
	var id: String = RnDSystem.active()
	if id == "":
		return false
	var p: float = RnDSystem.progress(id)
	if p >= 1.0:
		return false   # %100 → keşif kartı düşer, çubuk kaybolur (§5.8)

	node_id = id
	node_name = ResearchSeam.node_name(id)
	fill = clampf(p, 0.0, 1.0)
	# 100 GÖSTERİLMEZ: yukarıdaki kapı fill < 1.0 garantiliyor, yani ekrandaki 100
	# yalnızca yuvarlamadan gelebilirdi ve dolmamış bir çubuğun üstünde yalan olurdu.
	percent = mini(UiTokens.build_percent(fill), 99)

	# İLK ALAN ailenin kendi alanıdır (ResearchTree bunu yüklemede doğruluyor). Devam
	# düğümlerinin ikinci alanı atama panelinin işi: tek satırlık bir meta iki alanı
	# taşıyamaz ve panel zaten ikisini de yazıyor.
	area_line = TranslationServer.translate("RND_AREA_OF").format({
		"area": HRConstants.area_label(String(ResearchTree.areas_of(id)[0]))})

	paused = RnDSystem.is_frozen()
	# DONMA SEBEBİ MOTORDAN OKUNUR (§5.6.1), burada tahmin edilmez.
	pause_note = RnDSystem.freeze_note()

	var ids: Array = RnDSystem.assigned(id)
	for cid in ids:
		var c: Character = CharacterRegistry.get_character(String(cid))
		if c != null:
			assignee_names.append(c.character_name)

	var est: float = RnDSystem.weeks_estimate(id, ids)
	# -1.0 = "katkı yok" (§5.5). Sıfıra bölme ya da ∞ ekranda ASLA olmaz; sayı
	# yerine sebep satırı konuşur.
	weeks_left = NO_WEEKS if est < 0.0 else RnDUiShared.whole_weeks(est)
	return true


## Durum parmak izi — ev sahibi "çizilecek bir şey var mı"yı bundan okur.
## BuildBarModel.fingerprint()'in eşitlik sözleşmesi: iki modelin aynı parmak izi =
## aynı resim.
func fingerprint() -> String:
	return "%s|%.3f|%d|%d|%d|%s|%d" % [
		node_id, fill, percent, weeks_left, int(paused), pause_note,
		assignee_names.size()]
