extends RefCounted

# BuildBarModel — Build Bar KARTININ (onaylı sayfa rev 3, 2026-08-21) TÜRETİLMİŞ veri
# nesnesi. Oyun durumu DEĞİLDİR: her çağrıda ProductSystem'in seam'lerinden yeniden
# hesaplanır. Üç ev sahibi (tracker kartı, ODA monitörü, Ürün sayfası) aynı BuildBar
# sahnesini kurar; sahne bu modeli KENDİSİ türetir → ev sahipleri birbirinden kopamaz.
# Smoke `build_bar_hosts_agree` üçünün fingerprint()'ini karşılaştırır.
#
# HİÇBİR ŞEY SAKLANMAZ, HER ŞEY SORULUR. Meşguliyet özellikle: kart "kim boşta"nın
# kendi kopyasını tutsaydı, atama değiştiği anda gerçekten kopardı ve bu denetimin
# "UI, state'in tersini iddia ediyor" sınıfının ta kendisi olurdu.
#
# BİLİNÇLİ class_name YOK: hosts/smoke `preload` eder. Paylaşılan checkout'ta yeni bir
# class_name, öteki oturumların headless koşularını global class-cache yarım kalınca
# düşürüyor (center_viewport.gd:21 / product_tab.gd:6 ile aynı ihtiyat).
#
# STATİK içinde tr() YOK (loc_residue [static-tr]): sözcükler BuildBar'da çözülür,
# burada yalnız sayılar, kimlikler ve ANAHTAR ADLARI var.
#
# Godot kavramı: RefCounted — sahne ağacına girmeyen, referans sayımıyla ölen düz veri
# sınıfı. Node değil, çünkü çizen/işaret alan bir şey değil; sırf değer taşır.

const PHASE_DESIGN := &"design"          # ProductSystem "iteration"
const PHASE_DEVELOPMENT := &"development"
const PHASE_BETA := &"beta"              # ProductSystem "bugfix"
const PHASE_SUPPORT := &"support"        # YAYINLANDI DEĞİL — ürün yaşadıkça yaşayan hâl

var phase: StringName = PHASE_DESIGN
var product_name: String = ""

# --- her fazın ortak dili (kart bunları çizer) ---
var fill: float = 0.0           # faz satırının zemin dolumu 0-1
var percent: int = 0            # aynı ilerlemenin hassas değeri; bakış ve okuma iki iş
var paused: bool = false        # R2: taşıyabilecek kimse boş değil
var pause_note_key: String = "" # "" | BUILD_BUSY_NOBODY | BUILD_BUSY_ELSEWHERE | BUILD_BUSY_FIX_RUN
## §2 — duraklamanın TÜRÜ. "" · "auto" · "manual". Oto-duraklama CÜMLEYLE konuşur
## (pause_note_key dolu), manuel duraklama GLİFLE (pause_note_key BOŞ). İkisi bir
## arada asla görünmez; bar bu alandan hangisini çizeceğini bilir.
var pause_kind: String = ""
## §3 — lidersiz yapımın notu ("Lider yok."). Duraklama notundan AYRI satır: yapım
## durmuyor, yalnız liderlik çarpanı 1,0'a düştü.
var lead_note_key: String = ""
## Ekip §12.1 — taşıyıcı iki iş tutuyor, bar YAVAŞ akıyor. `lead_note_key` ile aynı
## DURAKLATMAYAN kanal; ikisi de "bar duruyor" demez, "bar neden böyle" der.
var split_note_key: String = ""
## §7 — BETA satırı YÜZDE TAŞIMAZ (mühürlü): havuz tükenmez olduğu için yüzde sahte
## bir tamamlanma iması olurdu. Satır sayaçları ve GEÇEN GÜNÜ gösterir.
var show_percent: bool = true
var beta_day: int = 0
## §5 — tamamlanan tasarım turu. "Tur 2/4" metninin ilk sayısı bundan türer.
var design_turns: int = 0
var decision_key: String = ""   # "" = karar satırı YOK (koşu sürerken düşer)
var decision_enabled: bool = false
## Karar satırının hover metni ve — kilitli kapıda — satır altına düşen gerekçe.
## GDD ÜRÜN rev 6.1 §6.4: "'Beta'ya geç →' bar doluncaya dek KİLİTLİDİR ve
## GEREKÇESİNİ GÖSTERİR." §7: yayın eylemi "{n} hata canlıya taşınır" tooltip'i
## taşır, ve o sayı KRİTİK-HATA CEZASI EKLENDİKTEN SONRAKİ sayıdır.
## Zaten çözülmüş metin taşır (format uygulanmış), çünkü {n} yalnız burada bilinir.
var decision_tooltip: String = ""

# TASARIM
var round_index: int = 1        # 1-tabanlı; RENGİ seçer, EKRANA YAZILMAZ
var round_max: int = 1          # ProductSystem.ITER_MAX_ROUNDS (harness/smoke okur)
var round_progress: float = 0.0 # koşan turun dolumu 0-1
var at_cap: bool = false        # tavan parkı (tüm turlar bitti, karar bekliyor)
var show_gain: bool = false     # kazanç satırı yalnız tur ≥2'de
var gain: int = 0
var gain_left: int = 0

# GELİŞTİRME
var phase_progress: float = 0.0 # bant içi dolum 0-1 (build_percent ile nicelenmiş)
var dev_days_left: int = 0      # geliştirme PARKINA kalan gün (100%'e değil)
var dev_parked: bool = false    # ProductSystem.can_enter_beta()
var half_speed: bool = false    # kapasite bölünmüş (hata sprinti / aktif yapım)
var dev_bugs: int = 0           # "8 hata" — geliştirmede biriken açık hata

# BETA
var bugs_remaining: int = 0     # bug_count — TÜM açık (gizli + bulunmuş-çözülmemiş)
var bugs_start: int = 0         # bug_count_at_bugfix_start_<id> bayrağı
var bugs_found: int = 0
var bugs_fixed: int = 0
var bugs_left: int = 0          # KALAN — BULUNAN − ÇÖZÜLEN, `bug_count` DEĞİL

# DESTEK
var live_bugs: int = 0          # DOĞRULANMIŞ — yayındaki ürünün açık hata sayısı
var sprint_running: bool = false


## Aktif build'den (ya da yayındaki üründen) kendini doldurur. Bar'a değmeyecek
## durumlarda false döner ve çağıran modeli atar. (Instance metodu, static değil:
## sınıf-adı olmayan bir script static'inden kendini kuramaz — `Model.new().derive()`.)
func derive() -> bool:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null:
		return _derive_support()
	var m := self
	m.product_name = _build_title(b)
	m.paused = ProductSystem.build_paused()
	m.pause_note_key = ProductSystem.pause_note_key()
	m.pause_kind = ProductSystem.pause_kind()
	m.lead_note_key = ProductSystem.lead_note_key()
	m.split_note_key = ProductSystem.split_note_key()
	m.show_percent = true
	# HAT MODELİ YOLU — bant aritmetiği değişti (§5, §6.0): TASARIM turlarının maliyeti
	# ayrı bir sayaçta durduğu için GELİŞTİRME barı EforTavanı'nın %100'üne kadar dolar.
	# Eski yol (düz katalog) aşağıda olduğu gibi kalıyor: cutover, silmeden yan yana.
	if ProductSystem.is_line_build():
		return _derive_line(b)
	match b.current_phase:
		"iteration":
			m.phase = PHASE_DESIGN
			m.round_index = maxi(1, b.iteration_count)
			m.round_max = ProductSystem.ITER_MAX_ROUNDS
			m.at_cap = b.iteration_decision_pending
			if m.at_cap:
				m.round_progress = 1.0
			elif b.iteration_count <= 1:
				# Tur 1 = tasarım bandı: efor / (PHASE_DESIGN_END·total). Yüzdenin tek evi
				# UiTokens.build_percent — dolgu yazıyla asla çelişmesin.
				var band: float = maxf(0.001, ProductSystem.PHASE_DESIGN_END * b.total_efor)
				m.round_progress = float(UiTokens.build_percent(b.efor_spent / band)) / 100.0
			else:
				# Tur ≥2: takvim geri sayımı (ITER_ROUND_DAYS), aynı nicemleme.
				var days: float = float(ProductSystem.ITER_ROUND_DAYS)
				m.round_progress = float(UiTokens.build_percent(
					1.0 - b.iteration_round_days / maxf(0.001, days))) / 100.0
			m.show_gain = b.iteration_count >= 2 and not m.at_cap
			if m.show_gain:
				_derive_gain(b)
			m.fill = m.round_progress
			m.decision_key = "PROD_TO_DEVELOPMENT_PLAIN"
			m.decision_enabled = ProductSystem.can_enter_development()
		"development":
			m.phase = PHASE_DEVELOPMENT
			var lo: float = ProductSystem.PHASE_DESIGN_END
			var hi: float = ProductSystem.PHASE_DEV_END
			var frac: float = ProductSystem.build_progress()
			m.phase_progress = float(UiTokens.build_percent(
				clampf((frac - lo) / maxf(0.001, hi - lo), 0.0, 1.0))) / 100.0
			m.dev_parked = ProductSystem.can_enter_beta()
			# Parka kalan gün: estimated_days_remaining'in aynası, ama %100'e değil DEV
			# CAP'e (parkta "hazır" derken "~3 gün" yazan bir kart olmasın).
			var dev_cap: float = hi * b.total_efor
			var rate: float = ProductSystem.team_speed(b) * ProductSystem.capacity_speed_factor()
			m.dev_days_left = int(ceil(maxf(0.0, dev_cap - b.efor_spent) / maxf(0.01, rate)))
			m.half_speed = ProductSystem.capacity_speed_factor() < 1.0
			m.dev_bugs = maxi(0, b.bug_count)
			m.fill = m.phase_progress
			m.decision_key = "PROD_TO_BETA_PLAIN"
			m.decision_enabled = m.dev_parked
			# §6.4 — kilitli kapı gerekçesini SÖYLER. Oyuncu neden basamadığını
			# tahmin etmez; S6 bu satırı barın altına, hover'da da tooltip'e koyuyor.
			if not m.decision_enabled:
				m.decision_tooltip = TranslationServer.translate("BUILD_BETA_GATE_LOCKED")
		"bugfix":
			m.phase = PHASE_BETA
			m.bugs_remaining = maxi(0, b.bug_count)
			m.bugs_start = maxi(0, int(GameState.get_flag(
				"bug_count_at_bugfix_start_%s" % b.id, b.bug_count)))
			m.bugs_found = maxi(0, b.bugs_found)
			m.bugs_fixed = maxi(0, b.bugs_fixed)
			# KALAN = BULUNAN − ÇÖZÜLEN (sayfanın aritmetiği: 20 − 14 = 6).
			# `bug_count` HENÜZ BULUNMAMIŞ hataları da sayar, yani onu basmak KALAN'ı
			# BULUNAN'dan BÜYÜK gösterebiliyordu — doğru olamayacak bir sayaç.
			# Dolgu da `bug_count` OKUR ama artık onu ÇEVİRİR (D3): çubuk BOŞALMAZ, dolar.
			m.bugs_left = maxi(0, m.bugs_found - m.bugs_fixed)
			m.fill = beta_fill()
			m.decision_key = "PROD_LAUNCH_PLAIN"
			m.decision_enabled = true
			# §7 — DÜRÜST SAYI, ve nihayet ÇİZİLİYOR. projected_launch_bugs() kritik-hata
			# cezasını ekledikten SONRA hesaplıyor ve doğru cevabı bir süredir veriyordu;
			# eksik olan tüketiciydi. BuildBar reworkü iki tooltip ev sahibini silince
			# BUILD_SHIP_TOOLTIP_BUGS öksüz bir anahtar olarak kalmıştı, yani oyuncuya
			# canlıya kaç hata taşıdığı HİÇ söylenmiyordu. Satır burada geri bağlanıyor.
			m.decision_tooltip = TranslationServer.translate("BUILD_SHIP_TOOLTIP_BUGS") \
				.format({"n": ProductSystem.projected_launch_bugs()})
		_:
			# planning / cancelled: kart yok. `shipped` buraya DÜŞMEZ — active_build o anda
			# zaten null'a çekilmiştir (ship_active_build), yani DESTEK yolundan geçer.
			return false
	m.percent = UiTokens.build_percent(m.fill)
	if m.paused:
		m.decision_enabled = m.decision_enabled   # duraklama kararı KİLİTLEMEZ: iş durdu, kapı değil
	return true


## DESTEK: yayınlanmış ürün, yapım yok. YAYINLANDI diye bir son hâl YOKTUR (R5) —
## kart ürün yaşadıkça yaşar ve dikkat maliyeti ödemeye devam eder.
func _derive_support() -> bool:
	if not bool(GameState.get_flag("mvp_shipped", false)):
		return false
	phase = PHASE_SUPPORT
	# İSİM DÜŞERSE ŞİRKETİN ADI: `mvp_product_name` yalnız yayında damgalanıyor,
	# yani boş kalabilen bir alan — kart o zaman " v1" diye başsız bir satır yazıyordu.
	var pname: String = String(GameState.get_flag("mvp_product_name", ""))
	if pname.strip_edges() == "":
		pname = GameState.company_name
	product_name = "%s v%d" % [pname, int(GameState.get_flag("mvp_version", 1))]
	# DESTEK ARTIK §8/§9'UN MOTORUNU OKUR, eski hata sprintini DEĞİL. Kart ile canlı
	# ürün sayfası aynı anda ekrandalar: biri "HATA SPRİNTİ / 5 hata" derken diğeri
	# "DÜZELTME BAŞLAT / DOĞRULANMIŞ 0" diyordu — tek şeyin iki gerçeği. Sayaç da
	# değişti: yayındaki açık hata artık DOĞRULANMIŞ HATA'dır (§8.1).
	live_bugs = ProductState.bugs_confirmed()
	sprint_running = ProductState.fix_run_active()
	# ÇUBUK: koşunun havuzu ne kadar erittiği. `FIX_RUN_PROGRESS` bunun için DEĞİLDİR —
	# o, BİR SONRAKİ hataya kalan kesirdir (0..1) ve çubuğa konsaydı her hata
	# çözüldüğünde sıfıra düşüp baştan dolardı.
	var pool: int = live_bugs + ProductState.fix_run_fixed()
	fill = 0.0 if pool <= 0 else float(ProductState.fix_run_fixed()) / float(pool)
	percent = UiTokens.build_percent(fill)
	# KOŞU SÜRERKEN KARAR SATIRI DÜŞMEZ, DEĞİŞİR: §8.4'te koşuyu BİTİREN oyuncudur
	# ("oyuncu koşuyu istediği an bitirir"), yani kartın basılabilir tek şeyi koşu
	# sırasında "Koşuyu bitir" olur.
	decision_key = "PROD_FIX_RUN_END" if sprint_running else "PROD_FIX_RUN_START"
	decision_enabled = sprint_running or SupportSystem.can_start_fix_run()
	# DESTEK duraklamaz: duraklama AKTİF YAPIMIN hâli, canlı ürünün değil.
	paused = false
	pause_note_key = ""
	# AMA DESTEK YAVAŞLAYABİLİR, ve dersin YARISI tam olarak burada yaşıyor: destekteki
	# kurucu yapıma başlayınca bildirimler doğrulanmaktan hızlı birikir, memnuniyet erir, ve
	# oyuncu işe alması gerektiğini kendisi anlar. O yarı bu bar söylemezse görünmez —
	# `_derive_support` not alanlarının kurulduğu bloktan ÖNCE erken dönüyor, yani bu kart
	# bugüne kadar HİÇ not taşımadı.
	for c in SupportSystem.desk_roster():
		if c != null and HRSystem.is_overloaded(c):
			split_note_key = "BUILD_SPLIT_FOCUS"
			break
	return true


## GDD ÜRÜN rev 6.1 — HAT MODELİNİN BAR GRAMERİ.
##
## Üç fark eski yoldan: TASARIM turu CİLA merdivenini sayar (tur 1 taban, dördü tavan)
## ve dolumu kendi maliyet sayacından okur; GELİŞTİRME barı EforTavanı'nın %100'üne
## kadar dolar (§6.0) ve BETA kapısı orada açılır (§6.4); BETA satırı YÜZDE TAŞIMAZ,
## sayaç ve GÜN taşır (§7, mühürlü).
func _derive_line(b: FeatureBuild) -> bool:
	var m := self
	match b.current_phase:
		"iteration":
			m.phase = PHASE_DESIGN
			# "Tur 2/4": koşan tur, tamamlananın bir fazlası (tavanda tavanın kendisi).
			m.design_turns = b.design_turns_completed
			m.at_cap = ProductSystem.design_turns_maxed()
			m.round_index = mini(b.design_turns_completed + (0 if m.at_cap else 1),
				ProductSystem.DESIGN_TURN_MAX)
			m.round_max = ProductSystem.DESIGN_TURN_MAX
			m.round_progress = 1.0 if m.at_cap \
				else float(UiTokens.build_percent(ProductSystem.design_turn_progress())) / 100.0
			# Eski "bu turun kazancı" önizlemesi hat modelinde YOK: kazanç kademenin
			# kendi puanıdır ve Konsept'te okunur (§5'in taban-seviye önizlemesi).
			m.show_gain = false
			m.fill = m.round_progress
			m.decision_key = "PROD_TO_DEVELOPMENT_PLAIN"
			# §5 — ilk günden basılabilir. Tur 1 dolmadan onay diyaloğu çıkar; kapı
			# KAPALI DEĞİL, o yüzden burada enabled kalıyor.
			m.decision_enabled = ProductSystem.can_enter_development()
			if ProductSystem.needs_design_confirm():
				m.decision_tooltip = TranslationServer.translate("BUILD_DESIGN_RUSH_CONFIRM")
		"development":
			m.phase = PHASE_DEVELOPMENT
			# §6.0 — tavanın %100'ü. Eski (frac − 0,20)/0,60 aritmetiği emekli.
			m.phase_progress = float(UiTokens.build_percent(
				clampf(b.efor_spent / maxf(0.001, b.total_efor), 0.0, 1.0))) / 100.0
			m.dev_parked = ProductSystem.can_enter_beta()
			var rate: float = ProductSystem.build_effort_per_day(b.lead_engineer_id) \
				* ProductSystem.capacity_speed_factor()
			m.dev_days_left = int(ceil(maxf(0.0, b.total_efor - b.efor_spent) / maxf(0.01, rate)))
			m.half_speed = ProductSystem.capacity_speed_factor() < 1.0
			m.dev_bugs = maxi(0, b.bug_count)
			m.fill = m.phase_progress
			m.decision_key = "PROD_TO_BETA_PLAIN"
			m.decision_enabled = m.dev_parked
			if not m.decision_enabled:
				m.decision_tooltip = TranslationServer.translate("BUILD_BETA_GATE_LOCKED")
		"bugfix":
			m.phase = PHASE_BETA
			m.bugs_remaining = maxi(0, b.bug_count)
			m.bugs_found = maxi(0, b.bugs_found)
			m.bugs_fixed = maxi(0, b.bugs_fixed)
			m.bugs_left = maxi(0, m.bugs_found - m.bugs_fixed)
			# §7 — YÜZDE YOK. Havuz tükenmez, dolayısıyla "ne kadarı bitti" sorusunun
			# dürüst bir cevabı yok; satır sayaçları ve kaçıncı beta günü olduğunu yazar.
			m.show_percent = false
			m.fill = 0.0
			m.beta_day = maxi(1, GameState.day - b.beta_entered_day + 1)
			m.decision_key = "PROD_LAUNCH_PLAIN"
			m.decision_enabled = true
			m.decision_tooltip = TranslationServer.translate("BUILD_SHIP_TOOLTIP_BUGS") \
				.format({"n": ProductSystem.projected_launch_bugs()})
		_:
			return false
	m.percent = UiTokens.build_percent(m.fill) if m.show_percent else 0
	return true


func _derive_gain(b: FeatureBuild) -> void:
	# Kazanç bütçesi: bu turun sonunda üç eksenin toplam kazancı + sonrasında kalan pay.
	# grow asimptotik → tavan aşımı yok; tavanı 0 olan eksen katkı vermez.
	var ceilings: Dictionary = ProductSystem.iteration_axis_ceilings()
	var cur := {"innovation": b.innovation, "stability": b.stability, "experience": b.experience}
	var g_sum: float = 0.0
	var left_sum: float = 0.0
	for ax in QualityModel.AXES:
		var c: float = float(ceilings.get(ax, 0.0))
		if c <= 0.0:
			continue
		var v: float = float(cur[ax])
		var raw: float = float(ProductSystem.ITER_ROUND_RAW.get(ax, 0.0))
		var g: float = QualityModel.grow(v, raw, c) - v
		g_sum += g
		left_sum += maxf(0.0, c - v - g)
	gain = int(round(g_sum))
	gain_left = int(round(left_sum))


func _build_title(b: FeatureBuild) -> String:
	# "Pulse v3" — ürün adı + sürüm. Faz adı BURADA TEKRAR EDİLMEZ (2i: ürün satırı
	# hangi yapım olduğunu söyler, fazı faz satırı söyler).
	var pname: String = String(GameState.get_flag("mvp_product_name", ""))
	if pname == "":
		pname = b.product_name if "product_name" in b else ""
	var version: int = int(GameState.get_flag("mvp_version", 0)) + 1
	if pname == "":
		return "v%d" % version
	return "%s v%d" % [pname, version]


## Beta İLERLEMESİ: 1 − kalan/başlangıç. YÜKSELEN çubuk (D3, 2026-08-22).
##
## ÖNCESİ `bugs_remaining / bugs_start` idi — BOŞALAN bir çubuk. Beta açılır açılmaz
## %100, biterken %0 yazıyordu; diğer üç fazın tam TERSİ yönü. Aynı dolgudan türeyen
## yüzde etiketi de o yüzden geriye sayıyordu. Kart tek bir gramer konuşmak zorunda:
## dolu = iş bitti.
##
## Event yeni hata ekleyip başlangıcı aşarsa oran 1'i geçer ve kırpılır — yani çubuk
## GERİ DÜŞEBİLİR ama negatife inmez. Gerçekten de iş artmıştır; çubuk yalan söylemez.
func beta_fill() -> float:
	return clampf(1.0 - float(bugs_remaining) / float(maxi(1, bugs_start)), 0.0, 1.0)


## Turun rengi — RAMPA B. Tur SAYISI hiçbir yerde çizilmez, renk tek göstergedir (2i).
## DESTEK ve duraklamış hâlin kendi renkleri var; burası yalnız koşan yapım için.
func ramp_color() -> Color:
	if phase == PHASE_SUPPORT:
		return UiTokens.POSITIVE
	if phase == PHASE_DESIGN:
		return UiTokens.build_ramp(round_index)
	return UiTokens.ACCENT


## Kapak çizgisi (2px): grubun durumu. Başka hiçbir satır bunu söylemez.
func cap_color() -> Color:
	if paused:
		return UiTokens.NEGATIVE
	if phase == PHASE_SUPPORT:
		return UiTokens.POSITIVE
	return ramp_color()


## Durum parmak izi — smoke (üç ev sahibi aynı mı?) ve harness çıktısı için.
func fingerprint() -> String:
	return "%s|%d/%d|%.2f|%d|%d|%d|%d|%.2f|%d|%d|%d|%d/%d|%d|%s|%d|%d|%d|%s|%s" % [
		String(phase), round_index, round_max, round_progress, int(at_cap),
		int(show_gain), gain, gain_left, phase_progress, dev_days_left, int(dev_parked),
		int(half_speed), bugs_remaining, bugs_start,
		int(paused), pause_note_key, live_bugs, int(sprint_running), bugs_left,
		lead_note_key, split_note_key]
