class_name DisplaySettings
extends RefCounted

# ============================================================================
# DisplaySettings — the live display engine (window mode / resolution / vsync /
# UI scale). All static; holds no state of its own.
# ============================================================================
# OWNERSHIP mirrors the split AudioManager's header documents: **Settings
# persists, DisplaySettings applies.** Every function here reads the value from
# the Settings autoload and pushes it at the DisplayServer / the root Window.
# Nothing here writes a preference except the one place the engine must correct
# the player (an illegal UI-scale step after a resolution change — see
# apply_ui_scale), and that correction goes back through Settings.set_value.
#
# THE HARNESS RULE (non-negotiable): the debug screenshot runners and the smoke
# suite OWN the window. --tab-shot/--modal-shot/--oda-shot/… all set
# `get_window().size = Vector2i(1920, 1080)` by hand so their frames are
# comparable, and --endgame-smoke runs headless. If this file resized or
# fullscreened the window at boot, it would silently invalidate 14 screenshot
# runners and the whole smoke suite. is_inert() is that guard, and every
# DisplayServer/Window call in this file sits behind it.
# ============================================================================

# --- Window mode ------------------------------------------------------------
# Godot's naming is a trap worth spelling out: WINDOW_MODE_FULLSCREEN is the
# BORDERLESS windowed-fullscreen mode (alt-tab friendly, no mode switch), while
# WINDOW_MODE_EXCLUSIVE_FULLSCREEN is real exclusive fullscreen. The player-facing
# TR labels map to the modes the words actually mean, not to the enum spelling.
const MODE_FULLSCREEN := "fullscreen"     # Tam ekran   → EXCLUSIVE_FULLSCREEN
const MODE_BORDERLESS := "borderless"     # Kenarlıksız → FULLSCREEN (borderless windowed)
const MODE_WINDOWED := "windowed"         # Pencereli   → WINDOWED

# Display order in the dropdown; index ↔ id conversion for the OptionButton.
const MODE_ORDER: Array[String] = [MODE_FULLSCREEN, MODE_BORDERLESS, MODE_WINDOWED]
const MODE_KEYS: Array[String] = ["SET_WINDOW_FULLSCREEN", "SET_WINDOW_BORDERLESS", "SET_WINDOW_WINDOWED"]

# --- Resolutions ------------------------------------------------------------
# docs/TECH_SPEC.md §14.1's supported list, in order. 1280×720 is the documented
# MINIMUM, so it is never filtered away even on a smaller-than-expected screen.
## §14.1 zaten 16:10 ve 32:9'u DESTEKLENİYOR diye sayıyordu ama listede ikisinden
## de tek satır yoktu — spec ile kod bu noktada ayrışmıştı. Eklendi. Yine de bu
## tablo tek başına yeterli DEĞİL: gerçek panel boyutları (dizüstü 2880x1800,
## 3024x1964 vb.) hiçbir sabit listeye sığmaz, o yüzden available_resolutions()
## ölçülen native'i listeye AYRICA ekler.
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1680, 1050),   # 16:10
	Vector2i(1920, 1080),
	Vector2i(1920, 1200),   # 16:10
	Vector2i(2560, 1080),   # 21:9
	Vector2i(2560, 1440),
	Vector2i(2560, 1600),   # 16:10
	Vector2i(3440, 1440),   # 21:9
	Vector2i(3840, 1600),   # 21:9 UWQHD+
	Vector2i(3840, 2160),
	Vector2i(3840, 2400),   # 16:10
	Vector2i(5120, 1440),   # 32:9
]

# --- UI scale ---------------------------------------------------------------
# Applied through the root Window's content_scale_factor, which multiplies the
# canvas_items stretch the project already runs (project.godot: stretch mode
# "canvas_items", aspect "expand", base 1920×1080).
## %150 KALDIRILDI (Erdem 2026-08-18). Gerekçe ölçüldü: content_scale_factor
## mantıksal viewport'u KÜÇÜLTÜR, yani 1920×1080 pencere %150'de 1280×720 raporlar —
## SettingsModal'ın SABİT yükseklikli CenterPanel'i oraya sığmıyor ve Footer'daki
## KAPAT butonu ekranın altında kalıyordu. Panel bu turda 860→820'ye indi, ama
## adımın kendisi de gitti: merdivenin tavanı artık %125.
## Bu liste ADIMLARIN TEK KAYNAĞI — is_step_allowed üyelik kapısını buradan okur,
## yani buraya eklenmeyen bir değer (elle düzenlenmiş settings.json, eski kayıt)
## uygulanamaz ve clamp_step onu merdivene geri çeker.
const UI_SCALE_STEPS: Array[float] = [0.75, 0.90, 1.00, 1.10, 1.25]

## The readability floor, in PHYSICAL pixels. This is a decided design point:
## a 9px badge that the stretch has already shrunk is 9px on glass no matter what
## the layout thinks it is, so the check has to happen after BOTH multipliers.
## UiTokens.SIZE_MICRO is the smallest step in the type scale and is exactly 9,
## so the floor is "the PLAYER must never shrink the smallest type below its
## authored size". Consequence, deliberately: at 1920×1080 the 75% and 90% steps
## are DISABLED; 90% unlocks around 1200px of height, 75% at 1440p.
## It gates the reduction steps only — see is_step_allowed for why 100%+ is exempt.
const MIN_READABLE_FONT_PX := 9

# Float comparison guard. 9 * 0.75 * (1440.0/1080.0) evaluates to 8.999999999999998,
# i.e. the exact 1440p case the design intends to ALLOW would fail a naive `>=`.
const READABLE_EPSILON := 0.01

const BASE_VIEWPORT := Vector2(1920.0, 1080.0)

## Kabuğun HAYATTA KALDIĞI en küçük mantıksal viewport. Eskiden üst kapı
## BASE_VIEWPORT'a bakıyordu, yani 1080p'de %100 üstü HİÇBİR adım yasal değildi —
## Ayarlar açılır listesi tek seçenekten ibaretti ve bu bir arıza gibi okunuyordu.
## Kapının gerçek gerekçesi "tasarım genişliği" değil, "kabuk kırpılıyor" idi
## (şirket adı soldan, 3x/4x sağdan düşüyordu). Terminal reskin'iyle TopBar'a
## yoğunluk kademesi eklendi (top_bar.gd `_apply_density`, eşik 1600): dar
## viewport'ta ad gizlenir, sütun boşlukları 28→18 daralır, tarih kısalır ve HİÇBİR
## sayı ya da kontrol kaybolmaz. Ölçülen taban 1280×720 — TECH_SPEC §14.1'in
## belgelenmiş minimum penceresi. Bu yüzden kapı artık ORAYA bakıyor:
## 1920 pencere → %125 (1536×864) yasal. (%150 de bu kapıdan GEÇİYORDU — 1280×720
## tam sınırda — ama adım merdivenden kaldırıldı: kapı kabuğu ölçüyor, modalleri
## değil, ve SettingsModal 720px'e sığmıyordu. Bkz. UI_SCALE_STEPS.)
const MIN_CHROME_VIEWPORT := Vector2(1280.0, 720.0)

# Settings keys this file reads (declared in Settings.DEFAULTS).
const KEY_WINDOW_MODE := "window_mode"
const KEY_RES_W := "resolution_w"
const KEY_RES_H := "resolution_h"
const KEY_VSYNC := "vsync"
const KEY_UI_SCALE := "ui_scale"


# ============================================================================
# Harness guard
# ============================================================================

## True when something other than the player owns the window: the headless
## DisplayServer (smoke suite, theme generator) or any debug screenshot /
## instrumentation run. Every apply_* below no-ops in this state.
static func is_inert() -> bool:
	if DisplayServer.get_name() == "headless":
		return true
	for arg in OS.get_cmdline_args():
		if _is_harness_arg(String(arg)):
			return true
	# The MCP editor-run path passes --endgame-smoke through run/main_args rather
	# than the command line (the same dual source main.gd reads).
	var configured: String = String(ProjectSettings.get_setting("application/run/main_args", ""))
	return configured.contains("--endgame-smoke")


static func _is_harness_arg(s: String) -> bool:
	if not s.begins_with("--"):
		return false
	# Every screenshot runner in main.gd is spelled "--<something>-shot[=kind]"
	# (--tab-shot, --modal-shot, --onboard-shot, --probe-shot, --oda-shot,
	# --hr-shot, --finance-shot, --product-shot, --ending-shot, --pitch-shot …),
	# so match the family rather than a list that will fall behind.
	if s.contains("-shot"):
		return true
	return s.begins_with("--endgame-smoke") or s.begins_with("--font-spec") \
		or s.begins_with("--theme-audit") or s.begins_with("--tempo-probe") \
		or s.begins_with("--render-probe")


static func _root() -> Window:
	var loop: MainLoop = Engine.get_main_loop()
	var tree := loop as SceneTree
	return tree.root if tree != null else null


## Current window size in physical pixels (the number the readability floor and
## the stretch factor are both computed from). Falls back to the project's base
## viewport when there is no window to ask.
static func window_size() -> Vector2i:
	var win: Window = _root()
	if win == null:
		return Vector2i(int(BASE_VIEWPORT.x), int(BASE_VIEWPORT.y))
	return win.size


# ============================================================================
# Apply
# ============================================================================

## Push every persisted display value at the engine. Settings.apply_all() calls
## this at boot and after a reset.
static func apply_all() -> void:
	if is_inert():
		return
	apply_window_mode(get_window_mode())
	apply_vsync(get_vsync())
	apply_ui_scale(get_ui_scale())


static func get_window_mode() -> String:
	var mode: String = String(Settings.get_value(KEY_WINDOW_MODE, Settings.get_default(KEY_WINDOW_MODE)))
	return mode if mode in MODE_ORDER else MODE_BORDERLESS


static func set_window_mode(mode: String) -> void:
	if mode not in MODE_ORDER:
		push_warning("[DisplaySettings] unknown window mode: %s" % mode)
		return
	Settings.set_value(KEY_WINDOW_MODE, mode)
	apply_window_mode(mode)
	# Leaving Pencereli (or entering it) changes the window size, which can make
	# the current UI-scale step illegal. Re-run the gate against the new size.
	apply_ui_scale(get_ui_scale())


static func apply_window_mode(mode: String) -> void:
	if is_inert():
		return
	match mode:
		MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		MODE_BORDERLESS:
			# Godot's "fullscreen" IS borderless-windowed — no exclusive mode switch.
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			apply_resolution(get_resolution())


# --- Resolution -------------------------------------------------------------

# --- Ekran tespiti ----------------------------------------------------------
# Hepsi is_inert() arkasında: harness'lar pencerenin sahibidir, onlara ekran
# sorulmaz. `allow_hidpi` Godot 4'te varsayılan olarak açık (ProjectSettings'ten
# doğrulandı), yani screen_get_size GERÇEK fiziksel pikseli döndürür — Windows'ta
# %150 ölçeklenmiş bir 4K panel 2560x1440 değil 3840x2160 der.

## Bu pencerenin AÇILDIĞI monitörün native boyutu. Çok monitörlü kurulumda
## window_get_current_screen doğru olanı seçer — birincil ekran değil, oyunun
## bulunduğu ekran.
static func native_resolution() -> Vector2i:
	if is_inert():
		return Vector2i(int(BASE_VIEWPORT.x), int(BASE_VIEWPORT.y))
	return DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())


## Görev çubuğu düşülmüş kullanılabilir alan. Pencereli modun gerçek tavanı budur:
## native boyutta bir PENCERE ekrana sığmaz (başlık çubuğu + görev çubuğu taşırır).
static func usable_size() -> Vector2i:
	if is_inert():
		return native_resolution()
	return DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen()).size


## Pencereli modun ÖLÇÜLEN varsayılanı: kullanılabilir alana sığan en büyük
## desteklenen boyut. Sabit 1920x1080 literali buydu; 1440p bir monitörde yalan
## söylüyordu ve oyuncu Pencereli'yi seçer seçmez onu 1080p'ye düşürüyordu.
## EN-BOY, ALANDAN ÖNCE GELİR. Ham "sığan en büyük alan" kuralı bu makinede
## 2560x1440 bir panele 2560x1080'i (21:9) seçiyordu: alanı daha büyük, ama şekli
## monitörün şekli değil — oyuncuya sebepsiz mektup kutusu bir pencere verirdi.
## Önce panelin oranına uyan adaylar arasından en büyüğü; hiç uymuyorsa sığan en
## büyüğe düşülür (alışılmadık panellerde liste zaten native'i içeriyor).
static func default_resolution() -> Vector2i:
	var fits: Vector2i = usable_size()
	var native: Vector2i = native_resolution()
	var want: float = float(native.x) / maxf(1.0, float(native.y))
	var best_match: Vector2i = Vector2i.ZERO
	var best_any: Vector2i = RESOLUTIONS[0]
	for r in available_resolutions():
		if r.x > fits.x or r.y > fits.y:
			continue
		if r.x * r.y > best_any.x * best_any.y:
			best_any = r
		if absf(float(r.x) / maxf(1.0, float(r.y)) - want) <= ASPECT_EPSILON \
				and r.x * r.y > best_match.x * best_match.y:
			best_match = r
	return best_match if best_match != Vector2i.ZERO else best_any


## 16:9 (1.778) ile 16:10 (1.600) arasını ayıracak kadar dar, aynı ailedeki küçük
## yuvarlama farklarını (1366x768 = 1.779) yutacak kadar geniş.
const ASPECT_EPSILON := 0.05


## The §14.1 list filtered to what this screen can actually show, PLUS the screen's
## own native mode. The filter used to be subtractive only, so a panel whose native
## size was not one of the hardcoded entries (every 16:10, 32:9 and laptop panel)
## simply could not be selected. The minimum (1280×720) always survives so the
## dropdown is never empty.
static func available_resolutions() -> Array[Vector2i]:
	var screen: Vector2i = native_resolution()
	var out: Array[Vector2i] = []
	for r in RESOLUTIONS:
		if r.x <= screen.x and r.y <= screen.y:
			out.append(r)
	if not out.has(screen) and screen.x > 0 and screen.y > 0:
		out.append(screen)
	if out.is_empty():
		out.append(RESOLUTIONS[0])
	out.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x * a.y < b.x * b.y)
	return out


## Saklanmış bir değer YOKSA varsayılan ÖLÇÜLÜR (Settings.DEFAULTS'taki literal
## yalnız headless yedeğidir). İlk açılış ve "varsayılana döndür" sonrası aynı
## yoldan geçer: reset anahtarı siler, burası yeniden tespit eder.
static func get_resolution() -> Vector2i:
	if not (Settings.has_stored(KEY_RES_W) and Settings.has_stored(KEY_RES_H)):
		return default_resolution()
	return Vector2i(
		int(Settings.get_value(KEY_RES_W, Settings.get_default(KEY_RES_W))),
		int(Settings.get_value(KEY_RES_H, Settings.get_default(KEY_RES_H))))


static func set_resolution(res: Vector2i) -> void:
	Settings.set_value(KEY_RES_W, res.x)
	Settings.set_value(KEY_RES_H, res.y)
	apply_resolution(res)
	apply_ui_scale(get_ui_scale())   # the new size can invalidate the current step


## Resolution is a WINDOWED-mode concept: in either fullscreen mode the window
## already fills the screen and the canvas_items stretch does the fitting, so the
## dropdown row is disabled there (SET_RESOLUTION_LOCKED explains why).
static func apply_resolution(res: Vector2i) -> void:
	if is_inert() or get_window_mode() != MODE_WINDOWED:
		return
	DisplayServer.window_set_size(res)
	# Re-center: a resize anchors at the top-left and can push the title bar off
	# the top of the screen on the larger steps.
	var screen: Vector2i = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	var origin: Vector2i = DisplayServer.screen_get_position(DisplayServer.window_get_current_screen())
	DisplayServer.window_set_position(origin + (screen - res) / 2)


static func is_resolution_editable() -> bool:
	return get_window_mode() == MODE_WINDOWED


## Ekranda GERÇEKTEN geçerli olan çözünürlük. İki tam-ekran modunda bu, saklanan
## pencereli tercih DEĞİL, monitörün native boyutudur — pencere onu kaplar.
## Ayarlar satırı bunu göstermeli: aksi hâlde oyun 2560x1440'ta koşarken kilitli
## satır "1920 × 1080" yazar ve panel yine yalan söylemiş olur. Pencereli modda
## saklanan tercih zaten geçerli olandır.
static func effective_resolution() -> Vector2i:
	return get_resolution() if get_window_mode() == MODE_WINDOWED else native_resolution()


# --- VSync ------------------------------------------------------------------

static func get_vsync() -> bool:
	return bool(Settings.get_value(KEY_VSYNC, Settings.get_default(KEY_VSYNC)))


static func set_vsync(on: bool) -> void:
	Settings.set_value(KEY_VSYNC, on)
	apply_vsync(on)


static func apply_vsync(on: bool) -> void:
	if is_inert():
		return
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if on else DisplayServer.VSYNC_DISABLED)


# --- UI scale ---------------------------------------------------------------

## Physical pixels the SMALLEST type step lands on at `step`, for a window of
## `win`. Both multipliers are in play: the project's canvas_items stretch
## (window ÷ 1920×1080, min of the two axes because aspect="expand" letterboxes
## on the tighter one) and the player's chosen content_scale_factor.
static func effective_micro_px(step: float, win: Vector2i) -> float:
	var stretch: float = minf(float(win.x) / BASE_VIEWPORT.x, float(win.y) / BASE_VIEWPORT.y)
	return float(UiTokens.SIZE_MICRO) * step * stretch


## Readability gate for one dropdown row. `win` defaults to the live window
## (ZERO is the sentinel — a default argument must not depend on call-time state).
##
## 100% IS ALWAYS LEGAL, and that exemption is load-bearing rather than a softening
## of the floor. The canvas_items stretch below 1080p is the ENGINE's designed answer
## to a small window, not a preference the player picked; 100% is by definition the
## authored baseline. Gating it produces an actively worse outcome than the small type
## it was meant to prevent: at the enforced minimum window (1280×720, main.gd:65) the
## stretch is 0.667, so a floor applied to 100% would reject the ONE step that is
## guaranteed renderable there — and it has nowhere safe to go, because every
## enlargement step shrinks the logical viewport further (%110 → 1163×654, %125 →
## 1024×576, both under MIN_CHROME_VIEWPORT). The player would be left with a clamp
## that cannot satisfy its own gate.
## (This passage used to argue the same point through %150 and "1.5 × 0.667 = 1.0".
## That step no longer exists — see UI_SCALE_STEPS — so the worked example moved to
## the steps that do.)
## So the floor guards only what it was written to guard: the player choosing to
## shrink the type BELOW the authored design. 75% and 90% stay gated by physical
## pixels exactly as specified.
##
## ÜYELİK KAPISI ÖNCE GELİR. Merdivende OLMAYAN bir değer yasadışıdır, çünkü aşağıdaki
## iki test SALT GEOMETRİK: %150 kaldırıldıktan sonra bile `_fits_design_width(1.5,
## 1920×1080)` 1280×720 hesaplayıp TRUE döner, yani settings.json'da duran eski bir
## 1.5 uygulanmaya devam ederdi — üstelik açılır listede artık o adım olmadığı için
## oyuncunun geri dönüş yolu da kalmazdı (Ayarlar'ın KAPAT'ı ekran dışında). Üyelik
## kapısı bunu kapatır: clamp_step değeri merdivene çeker, apply_ui_scale düzeltmeyi
## Settings'e geri yazar. Göç kodu YOK — mevcut mekanizma yeterli.
static func is_step_allowed(step: float, win: Vector2i = Vector2i.ZERO) -> bool:
	if not _is_ladder_step(step):
		return false
	var w: Vector2i = window_size() if win == Vector2i.ZERO else win
	if step > 1.0:
		return _fits_design_width(step, w)
	if step == 1.0:
		return true
	return effective_micro_px(step, w) >= float(MIN_READABLE_FONT_PX) - READABLE_EPSILON


## Epsilon karşılaştırması, `Array.has` DEĞİL: değer JSON'dan geçip geliyor ve ondalık
## bir basamak kayması (0.8999999) adımı listede yokmuş gibi gösterirdi.
static func _is_ladder_step(step: float) -> bool:
	for s in UI_SCALE_STEPS:
		if is_equal_approx(s, step):
			return true
	return false


## The UPPER gate, and the mirror image of the readability floor.
##
## content_scale_factor > 1 does not magnify into a bigger window — it SHRINKS the
## logical viewport (measured: a 1920×1080 window at 150% reports a 1280×720 viewport
## and a 1280-wide TopBar). Everything in this project is authored against the 1920
## design width, and TECH_SPEC §14.4's compact-mode breakpoints were never built, so a
## logical viewport under 1920 overflows its chrome: at 150% on a 1080p screen the
## TopBar loses the company name off the left edge and the 3x/4x speed buttons off the
## right. Speed control disappearing is a functional loss, not a cosmetic one.
##
## So an enlargement step is legal only where the logical viewport still covers the
## design: 1920 window → 100% only; 2560 → up to 125%; 3840 → the whole ladder.
## This is a HARDWARE gate, not a permanent ceiling — it lifts on its own the day
## §14.4 responsive breakpoints land, with no change to this file.
static func _fits_design_width(step: float, win: Vector2i) -> bool:
	if win.x <= 0 or win.y <= 0:
		return true   # boyut henüz bilinmiyor (headless/erken boot) — kapıyı kapatma
	var logical := Vector2(float(win.x) / step, float(win.y) / step)
	return logical.x >= MIN_CHROME_VIEWPORT.x - 0.5 and logical.y >= MIN_CHROME_VIEWPORT.y - 0.5


## The disabled row's explanation, already formatted ("%d%% bu pencere boyutunda…").
## TranslationServer, not tr(): statics have no Object to translate through — the
## same reason UiTokens.net_runway_parts reaches for it.
static func step_blocked_note(step: float) -> String:
	# İKİ kapı var ve gerekçeleri zıt: küçültme adımı OKUNAKLILIK tabanına,
	# büyütme adımı KABUK genişliğine takılır. Tek metin ikisini de anlatamaz —
	# %125'in "okunmuyor" demesi düpedüz yanlış olurdu.
	var key: String = "SET_UI_SCALE_TOO_LARGE" if step > 1.0 else "SET_UI_SCALE_TOO_SMALL"
	return TranslationServer.translate(key).format({"pct": int(round(step * 100.0))})


## Nearest LEGAL step, moving TOWARD 100%. The direction is not a preference — each
## gate has only one safe escape:
##   • a reduction step blocked by the readability floor must grow (shrinking further
##     is exactly what the floor forbids);
##   • an enlargement step blocked by the design-width gate must shrink (growing
##     further crops more chrome).
## 100% is legal at every window size, so both walks terminate there at worst and the
## function can never return an illegal value.
static func clamp_step(step: float, win: Vector2i = Vector2i.ZERO) -> float:
	var w: Vector2i = window_size() if win == Vector2i.ZERO else win
	if is_step_allowed(step, w):
		return step
	if step < 1.0:
		for s in UI_SCALE_STEPS:                       # artan sırada: ilk yasal olan
			if s > step and is_step_allowed(s, w):
				return s
	else:
		for i in range(UI_SCALE_STEPS.size() - 1, -1, -1):   # azalan sırada
			var s: float = UI_SCALE_STEPS[i]
			if s < step and is_step_allowed(s, w):
				return s
	return 1.0


static func get_ui_scale() -> float:
	return float(Settings.get_value(KEY_UI_SCALE, Settings.get_default(KEY_UI_SCALE)))


static func set_ui_scale(step: float) -> void:
	Settings.set_value(KEY_UI_SCALE, step)
	apply_ui_scale(step)


## Apply the step, clamping upward first. When the clamp fires it writes the
## corrected value back through Settings — the dropdown must not keep showing a
## step the window can no longer render.
static func apply_ui_scale(step: float) -> void:
	if is_inert():
		return
	var win: Window = _root()
	if win == null:
		return
	var legal: float = clamp_step(step, win.size)
	if not is_equal_approx(legal, step):
		print("[DisplaySettings] UI ölçeği %d%% → %d%% (pencere %dx%d, %dpx okunabilirlik tabanı)" % [
			int(round(step * 100.0)), int(round(legal * 100.0)),
			win.size.x, win.size.y, MIN_READABLE_FONT_PX])
		Settings.set_value(KEY_UI_SCALE, legal)
	win.content_scale_factor = legal
