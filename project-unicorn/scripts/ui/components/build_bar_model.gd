extends RefCounted

# BuildBarModel — Build Bar kartının TÜRETİLMİŞ verisi. Oyun durumu değildir: her çağrıda
# ProductSystem'in seam'lerinden yeniden hesaplanır. Üç ev sahibi (yüzen kart, ODA monitörü,
# Ürün sayfası) aynı BuildBar sahnesini kurar ve sahne bu modeli KENDİSİ türetir, yani ev
# sahipleri birbirinden kopamaz; smoke `build_bar_hosts_agree` üçünün fingerprint()'ini
# karşılaştırır.
#
# Hiçbir şey saklanmaz, her şey sorulur: kart "kim boşta"nın kendi kopyasını tutsaydı atama
# değiştiği anda state'in tersini iddia ederdi.
#
# BİLİNÇLİ class_name YOK: ev sahipleri ve smoke `preload` eder. Paylaşılan checkout'ta yeni
# bir class_name, öteki oturumların headless koşularını class-cache yarım kalınca düşürüyor.
#
# Sözcükler BuildBar'da çözülür; burada sayılar, kimlikler ve anahtar adları var. Tek istisna
# `decision_tooltip`: içindeki {n} yalnız burada bilindiği için çözülmüş metin taşır.

const PHASE_DESIGN := &"design"          # ProductSystem "iteration"
const PHASE_DEVELOPMENT := &"development"
const PHASE_BETA := &"beta"              # ProductSystem "bugfix"
const PHASE_SUPPORT := &"support"        # yayınlanmış ürün; son hâl değil, ürün yaşadıkça sürer

var phase: StringName = PHASE_DESIGN
var product_name: String = ""
var fill: float = 0.0            # faz satırının zemin dolumu 0-1
var percent: int = 0
## §7 — hat modelinde BETA satırı yüzde taşımaz (mühürlü): havuz tükenmez, yüzde sahte bir
## tamamlanma iması olurdu. Satır sayaçları ve geçen günü (`beta_day`) gösterir.
var show_percent: bool = true
var beta_day: int = 0
var paused: bool = false
## §2 — "" · "auto" · "manual". Oto-duraklama cümleyle (`pause_note_key`), manuel duraklama
## glifle konuşur; ikisi bir arada görünmez.
var pause_kind: String = ""
var pause_note_key: String = ""
## Duraklatmayan notlar: §3 lidersiz yapım (çarpan 1,0), Ekip §12.1 bölünmüş odak (bar yavaş).
var lead_note_key: String = ""
var split_note_key: String = ""
var decision_key: String = ""
var decision_enabled: bool = false
## Karar satırının hover metni. §6.4: kilitli kapı gerekçesini gösterir. §7: yayın eylemi
## "{n} hata canlıya taşınır" der ve o sayı kritik-hata cezası eklendikten SONRAKİ sayıdır.
var decision_tooltip: String = ""

var round_index: int = 1         # TASARIM turu, 1-tabanlı; rengi seçer, ekrana yazılmaz
var round_max: int = 1
var phase_progress: float = 0.0  # GELİŞTİRME bant içi dolumu 0-1
var dev_bugs: int = 0
var bugs_found: int = 0
var bugs_fixed: int = 0
var bugs_left: int = 0           # BULUNAN − ÇÖZÜLEN; `bug_count` henüz bulunmamışları da sayar
var live_bugs: int = 0           # DESTEK: doğrulanmış açık hata (§8.1)
var sprint_running: bool = false


## Aktif build'den ya da yayındaki üründen kendini doldurur; çizilecek kart yoksa false.
## (Instance metodu: sınıf adı olmayan bir script static'inden kendini kuramaz.)
func derive() -> bool:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null:
		return _derive_support()
	product_name = _build_title(b)
	paused = ProductSystem.build_paused()
	pause_kind = ProductSystem.pause_kind()
	pause_note_key = ProductSystem.pause_note_key()
	lead_note_key = ProductSystem.lead_note_key()
	split_note_key = ProductSystem.split_note_key()
	# Hat modeli (GDD ÜRÜN rev 6.1) ile düz katalog yolu yalnız dolum aritmetiğinde ayrışır.
	var line: bool = ProductSystem.is_line_build()
	match b.current_phase:
		"iteration":
			phase = PHASE_DESIGN
			if line:
				# §5 — "Tur 2/4": koşan tur tamamlananın bir fazlası, tavanda tavanın kendisi.
				var at_cap: bool = ProductSystem.design_turns_maxed()
				round_max = ProductSystem.DESIGN_TURN_MAX
				round_index = mini(b.design_turns_completed + (0 if at_cap else 1), round_max)
				fill = 1.0 if at_cap else _quantize(ProductSystem.design_turn_progress())
				# İlk günden basılabilir; tur 1 dolmadan geçmenin bedeli onay metninde.
				if ProductSystem.needs_design_confirm():
					decision_tooltip = TranslationServer.translate("BUILD_DESIGN_RUSH_CONFIRM")
			else:
				round_index = maxi(1, b.iteration_count)
				round_max = ProductSystem.ITER_MAX_ROUNDS
				if b.iteration_decision_pending:
					fill = 1.0
				elif b.iteration_count <= 1:
					# Tur 1 = tasarım bandı.
					fill = _quantize(b.efor_spent
						/ maxf(0.001, ProductSystem.PHASE_DESIGN_END * b.total_efor))
				else:
					# Tur ≥2: takvim geri sayımı.
					fill = _quantize(1.0 - b.iteration_round_days
						/ maxf(0.001, float(ProductSystem.ITER_ROUND_DAYS)))
			decision_key = "PROD_TO_DEVELOPMENT_PLAIN"
			decision_enabled = ProductSystem.can_enter_development()
		"development":
			phase = PHASE_DEVELOPMENT
			if line:
				# §6.0 — bar EforTavanı'nın %100'üne kadar dolar ve BETA kapısı orada açılır.
				phase_progress = _quantize(b.efor_spent / maxf(0.001, b.total_efor))
			else:
				var lo: float = ProductSystem.PHASE_DESIGN_END
				phase_progress = _quantize((ProductSystem.build_progress() - lo)
					/ maxf(0.001, ProductSystem.PHASE_DEV_END - lo))
			fill = phase_progress
			dev_bugs = maxi(0, b.bug_count)
			decision_key = "PROD_TO_BETA_PLAIN"
			decision_enabled = ProductSystem.can_enter_beta()
			# §6.4 — kilitli kapı gerekçesini söyler.
			if not decision_enabled:
				decision_tooltip = TranslationServer.translate("BUILD_BETA_GATE_LOCKED")
		"bugfix":
			phase = PHASE_BETA
			bugs_found = maxi(0, b.bugs_found)
			bugs_fixed = maxi(0, b.bugs_fixed)
			bugs_left = maxi(0, bugs_found - bugs_fixed)
			if line:
				show_percent = false
				beta_day = maxi(1, GameState.day - b.beta_entered_day + 1)
			else:
				# Düz katalog: YÜKSELEN çubuk, 1 − kalan/başlangıç (dolu = iş bitti). Olay
				# başlangıcı aşan hata eklerse çubuk geri düşer ama negatife inmez.
				var start: int = maxi(1, int(GameState.get_flag(
					"bug_count_at_bugfix_start_%s" % b.id, b.bug_count)))
				fill = clampf(1.0 - float(maxi(0, b.bug_count)) / float(start), 0.0, 1.0)
			decision_key = "PROD_LAUNCH_PLAIN"
			decision_enabled = true
			decision_tooltip = TranslationServer.translate("BUILD_SHIP_TOOLTIP_BUGS") \
				.format({"n": ProductSystem.projected_launch_bugs()})
		_:
			# planning / cancelled: kart yok. `shipped` buraya düşmez; active_build o anda
			# zaten null'dır ve DESTEK yolundan geçer.
			return false
	percent = UiTokens.build_percent(fill) if show_percent else 0
	return true


## DESTEK: yayınlanmış ürün, yapım yok. YAYINLANDI diye bir son hâl yoktur (R5): kart ürün
## yaşadıkça yaşar.
func _derive_support() -> bool:
	if not bool(GameState.get_flag("mvp_shipped", false)):
		return false
	phase = PHASE_SUPPORT
	# `mvp_product_name` boş kalabilir; o zaman şirketin adı, yoksa satır başsız " v1" olurdu.
	var pname: String = String(GameState.get_flag("mvp_product_name", ""))
	if pname.strip_edges() == "":
		pname = GameState.company_name
	product_name = "%s v%d" % [pname, int(GameState.get_flag("mvp_version", 1))]
	# §8/§9 — çubuk, düzeltme koşusunun havuzu ne kadar erittiğidir. FIX_RUN_PROGRESS bir
	# sonraki hataya kalan kesirdir; çubuğa konsa her çözülen hatada sıfıra düşerdi.
	live_bugs = ProductState.bugs_confirmed()
	sprint_running = ProductState.fix_run_active()
	var fixed: int = ProductState.fix_run_fixed()
	fill = 0.0 if live_bugs + fixed <= 0 else float(fixed) / float(live_bugs + fixed)
	percent = UiTokens.build_percent(fill)
	# §8.4 — koşu sürerken karar satırı düşmez, "bitir"e döner: koşuyu bitiren oyuncudur.
	decision_key = "PROD_FIX_RUN_END" if sprint_running else "PROD_FIX_RUN_START"
	decision_enabled = sprint_running or SupportSystem.can_start_fix_run()
	# DESTEK duraklamaz (duraklama aktif yapımın hâli) ama yavaşlayabilir: masadaki biri iki
	# işteyse bildirimler doğrulanmaktan hızlı birikir ve oyuncu bunu ancak bu nottan görür.
	for c in SupportSystem.desk_roster():
		if HRSystem.is_overloaded(c):
			split_note_key = "BUILD_SPLIT_FOCUS"
			break
	return true


## "Pulse v3" — ürün adı + sürüm. Faz adı burada tekrar edilmez, onu faz satırı söyler.
func _build_title(b: FeatureBuild) -> String:
	var pname: String = String(GameState.get_flag("mvp_product_name", ""))
	if pname == "":
		pname = b.product_name
	var version: int = int(GameState.get_flag("mvp_version", 0)) + 1
	return "v%d" % version if pname == "" else "%s v%d" % [pname, version]


## Dolum, yüzdenin tek evi UiTokens.build_percent'ten geçer: çubuk yanındaki sayıyla çelişmez.
static func _quantize(progress: float) -> float:
	return float(UiTokens.build_percent(progress)) / 100.0


## Turun rengi (rampa B). Tur SAYISI hiçbir yerde çizilmez, renk tek göstergedir.
func ramp_color() -> Color:
	match phase:
		PHASE_SUPPORT:
			return UiTokens.positive()
		PHASE_DESIGN:
			return UiTokens.build_ramp(round_index)
	return UiTokens.ACCENT


## Kapak çizgisi (2px): grubun durumu — amber yapım · kırmızı durmuş · yeşil DESTEK.
func cap_color() -> Color:
	return UiTokens.negative() if paused else ramp_color()


## Kartın çizdiği durumun parmak izi — smoke (üç ev sahibi aynı mı?) ve harness çıktısı için.
func fingerprint() -> String:
	return "%s|%d/%d|%.2f|%d|%d|%d|%s|%s|%s|%s|%d|%d|%d|%d|%d|%d|%d" % [
		String(phase), round_index, round_max, fill, percent, int(show_percent), int(paused),
		pause_kind, pause_note_key, lead_note_key, split_note_key, int(decision_enabled),
		dev_bugs, bugs_found, bugs_fixed, bugs_left, live_bugs, int(sprint_running)]
