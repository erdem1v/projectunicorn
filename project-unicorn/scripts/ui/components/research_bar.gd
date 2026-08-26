extends Control

# ============================================================================
# ResearchBar — ARAŞTIRMA çubuğu (Ar-Ge GDD §5.6). Yapım kartının kardeşi, kopyası
# DEĞİL: yapım üç satırlık bir KART, araştırma iki satırlık bir ÇUBUKTUR (76px).
# İkisi aynı anda görünür ve §5.0'ın öğrettiği an tam olarak orada okunur —
# araştırma akarken yapım "Kimse üzerinde değil." diyor.
#
# İKİ SATIR:
#   başlık : altıgen glif + düğüm adı + sağda TEK DURUM DİZGİSİ — koşarken
#            "~{n} gün kaldı", duraklamışken meşguliyet cümlesi (build_bar.gd'nin
#            `_busy_label` reçetesi). İkisi asla bir arada olamaz: katkı sıfırken
#            gün tahmini zaten -1'dir, yani aynı yuvayı paylaşmaları bir sıkıştırma
#            değil bir GERÇEK.
#   faz    : SATIRIN KENDİ ZEMİNİ İLERLEMEDİR — ayrı çubuk yok. ARAŞTIRMA + alan +
#            yüzde + iki bağ (duraklat · ata).
#
# GÜN SAYISI NEDEN BAŞLIK SATIRINDA — ÖLÇÜLDÜ, TERCİH EDİLMEDİ. İlk kurulumda
# "{alan} alanı · ~{n} gün kaldı" tek parça hâlinde faz satırındaydı ve --modal-shot
# karesi satırın 360px kartı ~30px TAŞIRDIĞINI gösterdi: `duraklat` ile `ata`
# kırpılıyordu, yani kartın İKİ TIKLANABİLİR ŞEYİ ekranın dışında kalıyordu. Beş öğe
# bu genişliğe sığmıyor (mono yüzün ilerlemesi ~0,73em; satır ~460px istiyor).
# Bölünen parça GÜN oldu çünkü §5.5 onu "kartın TEK sayısı" diye adlandırıyor —
# taşan satırda daralmaya bırakılsaydı elipsle YENEN ilk şey o olurdu.
# Üstünde 2px KAPAK ÇİZGİSİ: durumun taşıyıcısı (amber koşuyor · nötr donmuş).
#
# %100'DE ÇUBUK KAYBOLUR. Araştırmanın DESTEK gibi kalıcı bir satırı YOKTUR:
# tamamlanma ekonomik delta üretmez (§5.8), yerine keşif kartı düşer. Model
# %100'de false döner, `fingerprint()` "" olur, ev sahibi kartı kaldırır.
#
# DURAKLAMIŞTA AMBER GİDER, İLERLEME YANMAZ. Kapak ve dolgu nötrleşir; yüzde
# olduğu yerde durur çünkü motor da progress'i korur (§5.7 "yanacak olsa kimse
# başlamaz").
#
# `ata` BAĞI SEKMEYE GİDER, PANEL AÇMAZ. Akordeon Ar-Ge sayfasında yaşıyor; bu
# çubuk her sayfanın üstünde yüzüyor, yani paneli kendi içinde açsaydı aynı panel
# iki yerde iki hâlde bulunurdu. Önce `tab_changed("rnd")`, sonra
# `rnd_node_requested(node_id, true)` — sayfa açılır, düğüm kendini açar.
#
# GRUP ADI &"research_bar", &"build_bar" DEĞİL ve bu bilinçli: smoke'un
# `_case_build_bar_hosts_agree` case'i o grubun TAM OLARAK 3 üyesi olduğunu
# doğruluyor. Buraya katılmak o assert'i "koşuya göre 3 ya da 4" yapardı, yani
# bir doğrulamayı süse çevirirdi.
#
# TEMA-BAĞIMSIZ, BİLEREK: her ölçü ve renk UiTokens'tan, yazı tipi BarKit
# üzerinden ThemeDB'den. Sebep BuildBar'ınkiyle aynı ve ölçülmüş (ODA alt ağacı
# kendi DONDURULMUŞ temasını çözer) — çubuk bugün monitörde değil ama tema
# bağımsızlığı çubukların ortak sözleşmesidir, ev sahibine göre değişmez.
#
# Godot kavramı: PROCESS_MODE_ALWAYS — ağaç duraklıyken (oyuncu karar verirken)
# bile gui_input dağıtılsın. Varsayılan INHERIT'te çubuk ÇİZİLİR ama her tıklamayı
# YUTAR; editörde görünmez, yalnız çalışma anında ortaya çıkar.
# ============================================================================

const Model := preload("res://scripts/ui/components/research_bar_model.gd")
const BarKit := preload("res://scripts/ui/components/bar_kit.gd")

# Onaylı ölçüler (360px tracker). TOPLAM 76 = 2 + 32 + 1 + 41.
const CAP_H := 2
const ROW_TITLE_H := 32
const HAIR_H := 1
const ROW_PHASE_H := 41
const CARD_H := CAP_H + ROW_TITLE_H + HAIR_H + ROW_PHASE_H   # 76
const PAD_X := 12
const GAP := 8
const HEX_PX := 14
const NAME_SEP := ", "     # atama tooltip'inin ad ayracı

var _model = null
var _font: Font = null

var _cap: Panel = null
var _hex: Control = null
var _name_label: Label = null
var _status_label: Label = null      # gün tahmini VEYA meşguliyet cümlesi
var _phase_row: Control = null
var _fill: Panel = null
var _title_label: Label = null
var _area_label: Label = null
var _percent_label: Label = null
var _pause_link: Label = null
var _assign_link: Label = null

# Bağlantılar bir kez kurulur ve AYNI callable'larla sökülür.
var _wires: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_PASS   # bağlar tıklanabilir; çubuk kendisi değil
	add_to_group(&"research_bar")
	_font = BarKit.resolve_font(self)
	_build_tree()
	var r1: Callable = refresh.unbind(1)
	_wires = [
		[EventBus.research_progress_changed, Callable(self, "refresh")],
		[EventBus.research_started, r1],
		[EventBus.research_completed, r1],
		[EventBus.research_frozen, r1],
		[EventBus.research_resumed, r1],
		[EventBus.day_advanced, r1],
		[EventBus.language_changed, r1],
		# ATAMA AYNI KAREDE OKUNSUN (BuildBar B3'ün aynı gerekçesi): bir kişinin
		# araştırmadan düşmesi çubuğa ancak BİR SONRAKİ oyun gününde ulaşsaydı
		# oyuncu bunu takılma diye okurdu.
		[EventBus.assignment_changed, r1],
		[EventBus.employee_training_changed, refresh.unbind(2)],
		[EventBus.palette_changed, r1],
	]
	for w in _wires:
		(w[0] as Signal).connect(w[1])
	refresh()


func _exit_tree() -> void:
	for w in _wires:
		var s: Signal = w[0]
		if s.is_connected(w[1]):
			s.disconnect(w[1])
	_wires.clear()


## Modeli yeniden türet ve boya. Ev sahipleri bunu ÇAĞIRMAZ (widget kendi dinler).
func refresh() -> void:
	var m = Model.new()
	_model = m if m.derive() else null
	_repaint()


func fingerprint() -> String:
	return "" if _model == null else _model.fingerprint()


## Harness çıktısı (call_group ile çağrılır; normal F5'te sessiz).
func debug_print() -> void:
	print("[ResearchBar] path=%s rect=%s model=%s" % [
		str(get_path()), str(get_global_rect()), fingerprint()])


# --- Ağaç ---------------------------------------------------------------------

func _build_tree() -> void:
	for c in get_children():
		c.queue_free()

	var shell := PanelContainer.new()
	shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shell_sb := StyleBoxFlat.new()
	shell_sb.bg_color = UiTokens.BG_ART            # #10161C
	shell_sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	shell_sb.border_color = UiTokens.SURFACE_SUNKEN  # #232C34
	shell_sb.set_corner_radius_all(UiTokens.RADIUS_S)
	shell_sb.corner_radius_top_left = 0
	shell_sb.corner_radius_top_right = 0
	shell_sb.anti_aliasing = false
	shell.add_theme_stylebox_override(&"panel", shell_sb)
	add_child(shell)

	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 0)
	shell.add_child(col)

	_cap = BarKit.cap(CAP_H)
	col.add_child(_cap)
	col.add_child(_build_title_row())
	col.add_child(BarKit.hairline())
	col.add_child(_build_phase_row())


func _build_title_row() -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, ROW_TITLE_H)
	row.add_theme_constant_override(&"separation", GAP)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pad := MarginContainer.new()
	pad.add_theme_constant_override(&"margin_left", PAD_X)
	pad.add_theme_constant_override(&"margin_right", PAD_X)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(row)
	# ALTIGEN, ağaçtaki düğümün şekli. Kimliğin taşıyıcısı — durumun değil, o yüzden
	# kapak çizgisiyle birlikte renklenir ama cümle taşımaz.
	_hex = BarKit.hex(HEX_PX, UiTokens.ACCENT)
	row.add_child(_hex)
	# AD ESNEYEN ÖĞEDİR ve gerekirse ELİPSLE kısalır. BarKit'in clip_text = false
	# varsayılanı burada bilerek TERSİNE çevriliyor: o kural, YANINDA esneyen bir
	# boşluk düğümü olan sabit yazılar içindi (kapalı clip_text'te asgari genişlik
	# sıfıra iner ve boşluk bütün satırı yutar). Burada esneyen öğe LABEL'IN KENDİSİ
	# ve kalan her şey sabit genişlikte — yani daralan tek şey ad, durum dizgisi
	# hiçbir koşulda kesilmiyor.
	_name_label = BarKit.label(_font, UiTokens.SIZE_BODY, UiTokens.INK)
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_label.clip_text = true
	_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(_name_label)
	_status_label = BarKit.label(_font, UiTokens.SIZE_META, UiTokens.INK_MUTED)
	row.add_child(_status_label)
	return pad


func _build_phase_row() -> Control:
	_phase_row = Control.new()
	_phase_row.custom_minimum_size = Vector2(0, ROW_PHASE_H)
	_phase_row.clip_contents = true          # dolgu köşeden taşmasın
	_phase_row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# DOLGU: sola çapalı, genişliği YÜZDE. anchor_right kullanmak manuel yeniden
	# boyutlandırmayı tamamen kaldırıyor — çubuk genişleyince dolgu oranını korur.
	_fill = Panel.new()
	_fill.anchor_left = 0.0
	_fill.anchor_top = 0.0
	_fill.anchor_bottom = 1.0
	_fill.anchor_right = 0.0
	_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_phase_row.add_child(_fill)

	var pad := MarginContainer.new()
	pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pad.add_theme_constant_override(&"margin_left", PAD_X)
	pad.add_theme_constant_override(&"margin_right", PAD_X)
	pad.mouse_filter = Control.MOUSE_FILTER_PASS   # bağlar tıklamayı alsın
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	pad.add_child(row)
	_phase_row.add_child(pad)

	_title_label = BarKit.label(_font, UiTokens.SIZE_DATA, UiTokens.ACCENT)
	row.add_child(_title_label)
	# ALAN ESNEYEN ÖĞEDİR ve ayrı bir boşluk düğümü YOKTUR — o rolü bu label taşıyor.
	# Yüzde ve iki bağ sabit genişlikte kalır, yani sıkışan tek şey açıklamadır.
	_area_label = BarKit.label(_font, UiTokens.SIZE_MICRO, UiTokens.INK_MUTED)
	_area_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_area_label.clip_text = true
	_area_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(_area_label)
	_percent_label = BarKit.label(_font, UiTokens.SIZE_LEAD, UiTokens.INK)
	row.add_child(_percent_label)
	_pause_link = _make_link(_on_pause_input)
	row.add_child(_pause_link)
	_assign_link = _make_link(_on_assign_input)
	row.add_child(_assign_link)
	return _phase_row


## Bağ reçetesi, feature_lines_view'ın canlı bağlarıyla AYNI: amber + STOP + el
## imleci + gui_input. Düğme geometrisi YOK (kutu, kenar, dolgu) — çubuk üzerinde
## bir düğme, dolgunun sınırını ikinci bir kenar çizgisiyle keserdi.
func _make_link(handler: Callable) -> Label:
	var l := BarKit.label(_font, UiTokens.SIZE_META, UiTokens.ACCENT)
	l.mouse_filter = Control.MOUSE_FILTER_STOP
	l.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	l.gui_input.connect(handler)
	return l


# --- Boyama -------------------------------------------------------------------

func _repaint() -> void:
	var live: bool = _model != null
	visible = live
	if not live:
		return
	var m = _model
	# DURAKLAMIŞTA AMBER GİDER. Kapak ve dolgu nötrleşir; renk durumun TEK
	# taşıyıcısı, ikinci bir rozet yok.
	var tone: Color = UiTokens.INK_MUTED if m.paused else UiTokens.ACCENT
	BarKit.paint_cap(_cap, UiTokens.SURFACE_SUNKEN if m.paused else UiTokens.ACCENT)
	BarKit.paint_hex(_hex, tone)

	_name_label.text = m.node_name
	# TEK YUVA, İKİ GERÇEK — ve ikisi asla çakışmaz (gerekçe dosya başlığında).
	_status_label.text = _status_text(m)
	_status_label.visible = _status_label.text != ""

	var fill_sb := StyleBoxFlat.new()
	# Duraklamışta DÜZ donuk zemin (yapım çubuğuyla aynı token); koşarken amberin
	# %13'ü. İki hâlin de KENARI YOK: sınır renk değişiminin kendisi.
	fill_sb.bg_color = UiTokens.BUILD_FILL_PAUSED if m.paused \
		else Color(UiTokens.ACCENT, UiTokens.BUILD_FILL_ALPHA)
	fill_sb.anti_aliasing = false
	_fill.add_theme_stylebox_override(&"panel", fill_sb)
	_fill.anchor_right = clampf(m.fill, 0.0, 1.0)

	_title_label.text = UiTokens.tr_upper(tr("RND_BAR_TITLE"))
	_title_label.add_theme_color_override(&"font_color", tone)
	# GİZLENMEZ, BOŞALIR: bu label satırın ESNEYEN öğesidir, yani `visible = false`
	# olsaydı genişleten hiçbir şey kalmaz ve iki bağ yüzdenin dibine kayardı.
	_area_label.text = m.area_line
	_percent_label.text = tr("PROD_PERCENT").format({"n": m.percent})
	_percent_label.add_theme_color_override(&"font_color",
		UiTokens.INK_MUTED if m.paused else UiTokens.INK)

	# DURAKLAMIŞTA `duraklat` DÜŞER. Donmuş bir araştırmayı duraklatmak boş bir
	# tıklamadır; sürdürmenin gerçek yolu birini oturtmaktır, yani `ata`. Görünmezlik
	# + STOP kalkışı BİRLİKTE: görünmeyen ama tıklanabilir bir bağ, process_mode
	# tuzağının ikizidir.
	_pause_link.text = tr("RND_BAR_PAUSE")
	_pause_link.visible = not m.paused
	_pause_link.mouse_filter = (Control.MOUSE_FILTER_IGNORE if m.paused
		else Control.MOUSE_FILTER_STOP)
	_assign_link.text = tr("RND_ASSIGN_TITLE")
	_assign_link.tooltip_text = "" if m.assignee_names.is_empty() \
		else tr("RND_WHO").format({"who": NAME_SEP.join(PackedStringArray(m.assignee_names))})


## Başlık satırının sağ yuvası. Duraklamışsa MEŞGULİYET CÜMLESİ, koşarken
## "~{n} gün kaldı". Katkı sıfırken (days_left == NO_DAYS) sayı UYDURULMAZ; o hâlin
## sebebini zaten meşguliyet cümlesi söylüyor.
func _status_text(m) -> String:
	if m.pause_note_key != "":
		return tr(m.pause_note_key)
	if m.days_left == Model.NO_DAYS:
		return ""
	return tr("RND_DAYS_LEFT").format({"days": m.days_left})


# --- Bağlar ---------------------------------------------------------------------

func _is_click(ev: InputEvent) -> bool:
	if not (ev is InputEventMouseButton):
		return false
	var mb := ev as InputEventMouseButton
	return mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed


func _on_pause_input(ev: InputEvent) -> void:
	if _model == null or _model.paused or not _is_click(ev):
		return
	# WRITE-THROUGH: çubuk hiçbir alanı kendi yazmaz, sistemin seam'ini çağırır.
	RnDSystem.pause()
	refresh()


func _on_assign_input(ev: InputEvent) -> void:
	if _model == null or not _is_click(ev):
		return
	# SIRA ÖNEMLİ: önce sayfa açılır, sonra düğüm kendini açar. Ters sırada
	# `rnd_node_requested` henüz monte olmamış bir akordeona düşerdi.
	EventBus.tab_changed.emit("rnd")
	EventBus.rnd_node_requested.emit(_model.node_id, true)
