extends RefCounted

# BuildBarModel — DESTEK kartının TÜRETİLMİŞ verisi: yayındaki ürün ve tek açık hata sayısı. Oyun durumu
# değildir: her çağrıda seam'lerden yeniden hesaplanır. Hiçbir şey saklanmaz, her şey sorulur: kart "kim
# boşta"nın kendi kopyasını tutsaydı atama değiştiği anda state'in tersini iddia ederdi.
#
# BİLİNÇLİ class_name YOK: BuildBar ve smoke `preload` eder. Paylaşılan checkout'ta yeni bir
# class_name, öteki oturumların headless koşularını class-cache yarım kalınca düşürüyor.
#
# Sözcükler BuildBar'da çözülür; burada sayılar, kimlikler ve anahtar adları var. İstisna
# `product_name` (ad + sürüm).

var product_name: String = ""
## Ekip §12.1 bölünmüş odak: masadaki biri iki işteyse bildirimler doğrulanmaktan hızlı birikir
## ve oyuncu bunu ancak bu nottan görür.
var split_note_key: String = ""
var open_bugs: int = 0
## En çok açık hatası olan hat ve alanı, hata yoksa "": kart Ürün penceresini o alan açık açar, ipucu hattı söyler.
var worst_line: String = ""
var worst_area: String = ""


## Yayındaki üründen kendini doldurur; ürün yayında değilse çizilecek kart yok, false. YAYINLANDI
## diye bir son hâl yoktur (R5): kart ürün yaşadıkça yaşar.
## (Instance metodu: sınıf adı olmayan bir script static'inden kendini kuramaz.)
func derive() -> bool:
	if not bool(GameState.get_flag("mvp_shipped", false)):
		return false
	# `mvp_product_name` boş kalabilir; o zaman şirketin adı, yoksa satır başsız " v1" olurdu.
	var pname: String = String(GameState.get_flag("mvp_product_name", ""))
	if pname.strip_edges() == "":
		pname = GameState.company_name
	product_name = " ".join([pname, SprintSystem.version_label(ProductState.version())])
	open_bugs = ProductState.open_bugs()
	worst_line = ProductState.worst_bug_line()
	worst_area = SprintCatalog.area_of_line(worst_line)
	for c in SupportSystem.desk_roster():
		if HRSystem.is_overloaded(c):
			split_note_key = "BUILD_SPLIT_FOCUS"
			break
	return true


## Kartın çizdiği durumun parmak izi — yığın görünürlüğü ve smoke için.
func fingerprint() -> String:
	return "support|%s|%d|%s" % [split_note_key, open_bugs, worst_line]
