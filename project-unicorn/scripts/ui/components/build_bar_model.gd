extends RefCounted

# BuildBarModel — Build Bar'ın (Software Inc. segment grameri, 2026-08-19) TÜRETİLMİŞ
# veri nesnesi. Oyun durumu DEĞİLDİR: her çağrıda ProductSystem'in mevcut alanlarından
# yeniden hesaplanır (aktif build + statik seam'ler + tek bayrak). Üç ev sahibi (BuildHUD,
# tracker kartı, ODA monitörü) aynı BuildBar sahnesini kurar; sahne bu modeli kendisi
# türetir → ev sahipleri birbirinden kopamaz. Smoke `build_bar_hosts_agree` üç barın
# fingerprint()'ini karşılaştırır.
#
# BİLİNÇLİ class_name YOK: hosts/smoke `preload` eder. Paylaşılan checkout'ta yeni bir
# class_name, öteki oturumların headless koşularını global class-cache yarım kalınca
# düşürüyor (center_viewport.gd:21 / product_tab.gd:6 ile aynı ihtiyat).
#
# STATİK içinde tr() YOK (loc_residue [static-tr]): sözcükler BuildBar._draw'da çözülür,
# burada yalnız sayılar ve faz kimliği var.
#
# Godot kavramı: RefCounted — sahne ağacına girmeyen, referans sayımıyla ölen düz veri
# sınıfı. Node değil, çünkü çizen/işaret alan bir şey değil; sırf değer taşır.

const PHASE_DESIGN := &"design"          # ProductSystem "iteration"
const PHASE_DEVELOPMENT := &"development"
const PHASE_BETA := &"beta"              # ProductSystem "bugfix"

var phase: StringName = PHASE_DESIGN

# TASARIM
var round_index: int = 1        # 1-tabanlı; tur 1 = tasarım bandının kendisi
var round_max: int = 1          # ProductSystem.ITER_MAX_ROUNDS (harness/smoke okur; ARTIK ÇİZİLMİYOR)
var round_progress: float = 0.0 # koşan turun dolumu 0-1
var at_cap: bool = false        # tavan parkı (tüm turlar bitti, karar bekliyor)
var show_gain: bool = false     # kazanç satırı yalnız tur ≥2'de (tur 1 kazanç üretmez)
var gain: int = 0               # bu turun sonunda üç eksenin toplam kazancı (yuvarlanmış)
var gain_left: int = 0          # bu turdan sonra kalan toplam tavan payı (yuvarlanmış)

# GELİŞTİRME
var phase_progress: float = 0.0 # bant içi dolum 0-1 (build_percent ile nicelenmiş)
var dev_days_left: int = 0      # geliştirme PARKINA kalan gün (100%'e değil)
var dev_parked: bool = false    # ProductSystem.can_enter_beta()
var half_speed: bool = false    # kapasite bölünmüş (sprint / pitch prep)

# BETA
var bugs_remaining: int = 0     # bug_count — TÜM açık (gizli + bulunmuş-çözülmemiş); launch bunu canlıya taşır
var bugs_start: int = 0         # bug_count_at_bugfix_start_<id> bayrağı (enter_beta damgalar)


## Aktif build'den kendini doldurur. Bar'a değmeyecek durumlarda (build yok / sprint /
## shipped) false döner ve çağıran modeli atar. (Instance metodu, static değil: sınıf-
## adı olmayan bir script static'inden kendini kuramaz — çağıran `Model.new().derive()`.)
func derive() -> bool:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null or b.is_bug_sprint:
		return false
	var m := self
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
				# UiTokens.build_percent — çubuk yazıyla asla çelişmesin.
				var band: float = maxf(0.001, ProductSystem.PHASE_DESIGN_END * b.total_efor)
				m.round_progress = float(UiTokens.build_percent(b.efor_spent / band)) / 100.0
			else:
				# Tur ≥2: takvim geri sayımı (ITER_ROUND_DAYS), aynı nicemleme.
				var days: float = float(ProductSystem.ITER_ROUND_DAYS)
				m.round_progress = float(UiTokens.build_percent(
					1.0 - b.iteration_round_days / maxf(0.001, days))) / 100.0
			# Kazanç bütçesi (consult R4 etiketi): bu turun sonunda üç eksenin toplam
			# kazancı + sonrasında kalan toplam pay. grow asimptotik → tavan aşımı yok;
			# tavanı 0 olan eksen katkı vermez (_apply_iteration_round_gains aynası).
			m.show_gain = b.iteration_count >= 2 and not m.at_cap
			if m.show_gain:
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
				m.gain = int(round(g_sum))
				m.gain_left = int(round(left_sum))
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
		"bugfix":
			m.phase = PHASE_BETA
			m.bugs_remaining = maxi(0, b.bug_count)
			m.bugs_start = maxi(0, int(GameState.get_flag(
				"bug_count_at_bugfix_start_%s" % b.id, b.bug_count)))
		_:
			return false
	return true


## Beta çubuğunun dolumu: kalan / başlangıç, 0-1 (event bug ekleyip başlangıcı aşarsa 1'e kırpılır).
func beta_fill() -> float:
	return clampf(float(bugs_remaining) / float(maxi(1, bugs_start)), 0.0, 1.0)


## Durum parmak izi — smoke (üç ev sahibi aynı mı?) ve harness çıktısı için.
func fingerprint() -> String:
	return "%s|%d/%d|%.2f|%d|%d|%d|%d|%.2f|%d|%d|%d|%d/%d" % [
		String(phase), round_index, round_max, round_progress, int(at_cap),
		int(show_gain), gain, gain_left, phase_progress, dev_days_left, int(dev_parked),
		int(half_speed), bugs_remaining, bugs_start]
