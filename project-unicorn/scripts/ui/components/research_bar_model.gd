extends RefCounted

# ============================================================================
# ResearchBarModel — ARAŞTIRMA çubuğunun TÜRETİLMİŞ veri nesnesi (Ar-Ge GDD §5.6).
# BuildBarModel'in ikizi ve onun sözleşmesini birebir taşır.
#
# HİÇBİR ŞEY SAKLANMAZ, HER ŞEY SORULUR. `derive()` her çağrıda RnDSystem'e
# baştan sorar; ne ilerleme ne atama ne de donmuşluk burada bir kopya olarak
# yaşar. Kopya tutulsaydı bir atama değişikliği çubuğu state'in tersini iddia
# eder hâle getirirdi — denetimin "UI, state'in tersini söylüyor" sınıfının ta
# kendisi.
#
# ÇİZİLECEK BİR ŞEY YOKSA false. Aktif araştırma yoksa VEYA %100'e varmışsa
# `derive()` false döner ve çubuk KAYBOLUR. Araştırmanın DESTEK gibi kalıcı bir
# satırı yoktur (§5.8): tamamlanma ekonomik delta üretmez, yerine keşif kartı
# düşer. Dolmuş ve orada duran bir çubuk, olmayan bir ödülü bekletirdi.
#
# BİLİNÇLİ class_name YOK: çubuk `preload` eder (build_bar_model.gd:13-15'in
# gerekçelendirdiği class-cache ihtiyatı).
#
# SÖZCÜKLER: `pause_note_key` bir ANAHTAR'dır ve çubukta çözülür (BuildBarModel'in
# grameri). `node_name` ile `area_line` çözülmüş metindir çünkü ikisi de bir
# KİMLİKTEN türüyor (düğüm id'si · alan id'si) ve o çeviriyi yapan tek yer
# ResearchSeam/HRConstants; ikinci bir eşleme tablosu yazmak yerine sonucu
# taşıyor. Çeviri `TranslationServer.translate` ile alınıyor — `tr()` değil —
# ki bu dosya bir gün statik'e taşınırsa loc_residue [static-tr] tetiklenmesin.
#
# Godot kavramı: RefCounted — sahne ağacına girmeyen, referans sayımıyla ölen düz
# veri sınıfı. Node değil; sırf değer taşır.
# ============================================================================

## RnDSystem.days_estimate -1.0 döndüğünde (katkı yok) bu değer taşınır. Çubuk
## gün satırını hiç yazmaz; sebebi başlık satırındaki meşguliyet cümlesidir.
const NO_DAYS := -1

var node_id: String = ""
var node_name: String = ""
var area_line: String = ""        # "{area} alanı" — çözülmüş
var fill: float = 0.0             # faz satırının zemin dolumu 0-1
var percent: int = 0              # aynı ilerlemenin hassas değeri
var days_left: int = NO_DAYS
var paused: bool = false          # §5.7 donmuş = aktif araştırma, üstünde kimse yok
var pause_note_key: String = ""   # "" | BUILD_BUSY_NOBODY
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
	percent = clampi(int(round(fill * 100.0)), 0, 99)

	var areas: Array = ResearchTree.areas_of(id)
	if not areas.is_empty():
		# İLK ALAN, ailenin kendi alanıdır (ResearchTree RULE 5 bunu doğruluyor).
		# Devam düğümlerinin ikinci alanı atama panelinin işi, çubuğun değil:
		# tek satırlık bir meta iki alanı taşıyamaz ve panel zaten ikisini de yazıyor.
		area_line = TranslationServer.translate("RND_AREA_OF").format({
			"area": HRConstants.area_label(String(areas[0]))})

	paused = RnDSystem.is_frozen()
	# AYNI CÜMLE, İKİ ÇUBUKTA. "Kimse üzerinde değil." yapım çubuğunda da bunu der;
	# §5.0'ın öğrettiği şey tam olarak o eşleşmedir (araştırma insan ve zaman ile
	# ödenen bir bahistir — birini araştırmaya alırsan yapımda o kişi yoktur).
	# DONMA SEBEBİ MOTORDAN OKUNUR, burada tahmin edilmez: oyuncu insanları çektiyse
	# "Kimse üzerinde değil." (yapım barıyla AYNI cümle — §5.0'ın öğretici anını taşıyan
	# şey tam olarak o aynılık), taşıyıcı sürekli bir işe geçtiyse "Ekip yapımda."
	pause_note_key = RnDSystem.freeze_note_key()

	var ids: Array = RnDSystem.assigned(id)
	assignee_names.clear()
	for cid in ids:
		var c: Character = CharacterRegistry.get_character(String(cid))
		if c != null:
			assignee_names.append(c.character_name)

	var est: float = RnDSystem.days_estimate(id, ids)
	# -1.0 = "katkı yok" (§5.5). Sıfıra bölme ya da ∞ ekranda ASLA olmaz; sayı
	# yerine sebep satırı konuşur.
	days_left = NO_DAYS if est < 0.0 else maxi(1, int(ceil(est)))
	return true


## Durum parmak izi — ev sahibi "çizilecek bir şey var mı"yı bundan okur ve
## harness çıktısı bunu basar. BuildBarModel.fingerprint()'in eşitlik sözleşmesi:
## iki modelin aynı parmak izi = aynı resim.
func fingerprint() -> String:
	return "%s|%.3f|%d|%d|%d|%s|%d" % [
		node_id, fill, percent, days_left, int(paused), pause_note_key,
		assignee_names.size()]
