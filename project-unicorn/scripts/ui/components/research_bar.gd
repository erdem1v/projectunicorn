extends PanelContainer

# ============================================================================
# ResearchBar — ARAŞTIRMA kartı (Ar-Ge GDD §5.6), DESTEK kartının altında aynı sütunda.
#
# DÖRT SATIR:
#   başlık   : ARAŞTIRMA + sağda TEK DURUM DİZGİSİ — koşarken "~{n} hafta kaldı",
#              duraklamışken sebep cümlesi (§5.6.1). İkisi asla bir arada olamaz: katkı
#              sıfırken hafta tahmini zaten -1'dir.
#   ad       : düğümün adı ve alanı; dar kartta kısalan alandır.
#   ilerleme : çubuk ve yüzde.
#   bağlar   : duraklat · ata.
#
# %100'DE KART KAYBOLUR (§5.8): model false döner, `fingerprint()` "" olur, ev
# sahibi kartı kaldırır. DURAKLAMIŞTA İLERLEME YANMAZ: dolgu nötrleşir, yüzde olduğu
# yerde durur çünkü motor da progress'i korur (§5.7); sebep cümlesi öne çıkar.
#
# `ata` BAĞI SEKMEYE GİDER, PANEL AÇMAZ. Akordeon Ar-Ge sayfasında yaşıyor; bu
# kart her sayfanın üstünde yüzüyor, yani paneli kendi içinde açsaydı aynı panel
# iki yerde iki hâlde bulunurdu.
# ============================================================================

const Model := preload("res://scripts/ui/components/research_bar_model.gd")
const BarKit := preload("res://scripts/ui/components/bar_kit.gd")
const RESEARCH_ICON := preload("res://assets/icons/rail/rnd.svg")

var _model: Model = null

var _title_label: Label = null
var _status_label: Label = null      # hafta tahmini VEYA duraklama sebebi
var _name_label: Label = null
var _area_label: Label = null
var _progress: ProgressBar = null
var _percent_label: Label = null
var _pause_link: Button = null
var _dot: Label = null
var _assign_link: Button = null


func _ready() -> void:
	# ALWAYS: ağaç duraklıyken (oyuncu karar verirken) de bağlar çalışsın.
	# Varsayılan INHERIT'te kart ÇİZİLİR ama her tıklamayı YUTAR.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_tree()
	var r1: Callable = refresh.unbind(1)
	EventBus.research_progress_changed.connect(refresh)
	EventBus.research_started.connect(r1)
	EventBus.research_completed.connect(r1)
	EventBus.research_frozen.connect(r1)
	EventBus.research_resumed.connect(r1)
	EventBus.day_advanced.connect(r1)
	EventBus.language_changed.connect(r1)
	# ATAMA AYNI KAREDE OKUNSUN (BuildBar'la aynı gerekçe): bir kişinin araştırmadan
	# düşmesi karta ancak BİR SONRAKİ oyun gününde ulaşsaydı oyuncu bunu takılma
	# diye okurdu.
	EventBus.assignment_changed.connect(r1)
	EventBus.employee_training_changed.connect(refresh.unbind(2))
	refresh()


## Modeli yeniden türet ve boya. Ev sahipleri bunu ÇAĞIRMAZ (widget kendi dinler).
func refresh() -> void:
	var m := Model.new()
	_model = m if m.derive() else null
	_repaint()


## Ev sahibi "çizilecek bir şey var mı"yı bundan okur ("" = yok).
func fingerprint() -> String:
	return "" if _model == null else _model.fingerprint()


# --- Ağaç ---------------------------------------------------------------------

func _build_tree() -> void:
	var pad := MarginContainer.new()
	pad.add_theme_constant_override(&"margin_left", UiTokens.SPACE_XL)
	pad.add_theme_constant_override(&"margin_top", UiTokens.SPACE_L)
	pad.add_theme_constant_override(&"margin_right", UiTokens.SPACE_XL)
	pad.add_theme_constant_override(&"margin_bottom", UiTokens.SPACE_L)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pad)
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", UiTokens.SPACE_M)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(col)

	var head := BarKit.line()
	col.add_child(head)
	head.add_child(BarKit.glyph(RESEARCH_ICON, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	_title_label = UiFactory.make_label("", &"FloatKey")
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_title_label)
	_status_label = UiFactory.make_label("", &"Caption")
	head.add_child(_status_label)

	var names := BarKit.line()
	col.add_child(names)
	_name_label = UiFactory.make_label("", &"SubjectStrong")
	names.add_child(_name_label)
	_area_label = BarKit.filler(&"Caption")
	names.add_child(_area_label)

	var bar := BarKit.line()
	bar.add_theme_constant_override(&"separation", UiTokens.SPACE_L)
	col.add_child(bar)
	_progress = ProgressBar.new()
	_progress.show_percentage = false
	_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(_progress)
	_percent_label = UiFactory.make_label("", &"KeyText")
	bar.add_child(_percent_label)

	var links := BarKit.line()
	links.add_theme_constant_override(&"separation", UiTokens.SPACE_XS)
	col.add_child(links)
	_pause_link = _link(_on_pause)
	links.add_child(_pause_link)
	_dot = UiFactory.make_label("·", &"CaptionFaint")
	links.add_child(_dot)
	_assign_link = _link(_on_assign)
	links.add_child(_assign_link)


## Bağ: metin tuşu. Odak yok: game_shell Space'i hız tuşu olarak okur.
func _link(handler: Callable) -> Button:
	var b := Button.new()
	b.theme_type_variation = &"FloatLink"
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(handler)
	return b


# --- Boyama -------------------------------------------------------------------

func _repaint() -> void:
	visible = _model != null
	if _model == null:
		return
	var m := _model
	_title_label.text = Fmt.upper(tr("RND_BAR_TITLE"))
	_status_label.text = _status_text(m)
	_status_label.visible = _status_label.text != ""
	_status_label.theme_type_variation = &"CaptionPrimary" if m.paused else &"Caption"
	_name_label.text = m.node_name
	_area_label.text = m.area_line
	_progress.value = m.percent
	_progress.theme_type_variation = &"ProgressPaused" if m.paused else &""
	_percent_label.text = tr("PROD_PERCENT").format({"n": m.percent})
	# DURAKLAMIŞTA `duraklat` DÜŞER: donmuş bir araştırmayı duraklatmak boş bir
	# tıklamadır; sürdürmenin gerçek yolu birini oturtmaktır, yani `ata`.
	_pause_link.text = tr("RND_BAR_PAUSE")
	_pause_link.visible = not m.paused
	_dot.visible = not m.paused
	_assign_link.text = tr("RND_ASSIGN_TITLE")
	_assign_link.tooltip_text = "" if m.assignee_names.is_empty() \
		else tr("RND_WHO").format({"who": ", ".join(PackedStringArray(m.assignee_names))})


## Başlık satırının sağ yuvası. Duraklamışsa SEBEP CÜMLESİ, koşarken
## "~{n} hafta kaldı". Katkı sıfırken (weeks_left == NO_WEEKS) sayı UYDURULMAZ; o
## hâlin sebebini zaten sebep cümlesi söylüyor.
func _status_text(m: Model) -> String:
	if m.pause_note_key != "":
		return tr(m.pause_note_key)
	if m.weeks_left == Model.NO_WEEKS:
		return ""
	return RnDUiShared.weeks_text(m.weeks_left)


# --- Bağlar ---------------------------------------------------------------------

func _on_pause() -> void:
	# WRITE-THROUGH: kart hiçbir alanı kendi yazmaz, sistemin seam'ini çağırır.
	RnDSystem.pause()
	refresh()


func _on_assign() -> void:
	# SIRA ÖNEMLİ: önce sayfa açılır, sonra düğüm kendini açar. Ters sırada
	# `rnd_node_requested` henüz monte olmamış bir akordeona düşerdi.
	EventBus.tab_changed.emit("rnd")
	EventBus.rnd_node_requested.emit(_model.node_id, true)
