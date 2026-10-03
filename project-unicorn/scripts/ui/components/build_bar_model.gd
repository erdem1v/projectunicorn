extends RefCounted

# BuildBarModel — DESTEK kartının TÜRETİLMİŞ verisi: yayındaki ürün, doğrulanmış hatalar ve
# düzeltme koşusu. Oyun durumu değildir: her çağrıda seam'lerden yeniden hesaplanır. Hiçbir şey
# saklanmaz, her şey sorulur: kart "kim boşta"nın kendi kopyasını tutsaydı atama değiştiği anda
# state'in tersini iddia ederdi.
#
# BİLİNÇLİ class_name YOK: BuildBar ve smoke `preload` eder. Paylaşılan checkout'ta yeni bir
# class_name, öteki oturumların headless koşularını class-cache yarım kalınca düşürüyor.
#
# Sözcükler BuildBar'da çözülür; burada sayılar, kimlikler ve anahtar adları var. İstisna
# `product_name` (ad + sürüm).

## Kapalı eylemin gerekçesi, motorun ret sebebinden. Kart yalnız yayındaki üründe var ve koşu
## sürerken eylem bitirmedir: geriye bu iki sebep kalır.
const REFUSAL_KEYS := {
	SupportSystem.REFUSAL_NO_BUGS: "FIX_RUN_REFUSED_NO_BUGS",
	SupportSystem.REFUSAL_DESK_SHUT: "BUILD_BUSY_NOBODY",
}

var product_name: String = ""
var fill: float = 0.0            # düzeltme koşusunun havuzu ne kadar erittiği 0-1
var percent: int = 0
## Ekip §12.1 bölünmüş odak: masadaki biri iki işteyse bildirimler doğrulanmaktan hızlı birikir
## ve oyuncu bunu ancak bu nottan görür.
var split_note_key: String = ""
var decision_key: String = ""
var decision_enabled: bool = false
var refusal_key: String = ""     # eylem kapalıyken gerekçesi
var live_bugs: int = 0           # doğrulanmış açık hata (§8.1)
var fix_run_active: bool = false


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
	# §8/§9 — çubuk, düzeltme koşusunun havuzu ne kadar erittiğidir. FIX_RUN_PROGRESS bir
	# sonraki hataya kalan kesirdir; çubuğa konsa her çözülen hatada sıfıra düşerdi.
	live_bugs = ProductState.bugs_confirmed()
	fix_run_active = ProductState.fix_run_active()
	var fixed: int = ProductState.fix_run_fixed()
	fill = 0.0 if live_bugs + fixed <= 0 else float(fixed) / float(live_bugs + fixed)
	# Dolum, yüzdenin tek evi UiTokens.build_percent'ten geçer: çubuk yanındaki sayıyla çelişmez.
	percent = UiTokens.build_percent(fill)
	# §8.4 — koşu sürerken eylem düğmesi düşmez, "bitir"e döner: koşuyu bitiren oyuncudur.
	decision_key = "PROD_FIX_RUN_END" if fix_run_active else "PROD_FIX_RUN_START"
	decision_enabled = fix_run_active or SupportSystem.can_start_fix_run()
	if not decision_enabled:
		refusal_key = REFUSAL_KEYS[SupportSystem.fix_run_refusal()]
	for c in SupportSystem.desk_roster():
		if HRSystem.is_overloaded(c):
			split_note_key = "BUILD_SPLIT_FOCUS"
			break
	return true


## Kartın çizdiği durumun parmak izi — yığın görünürlüğü ve smoke için.
func fingerprint() -> String:
	return "support|%.2f|%d|%s|%d|%d|%d" % [fill, percent, split_note_key, int(decision_enabled),
		live_bugs, int(fix_run_active)]
