extends PanelContainer

# ============================================================================
# ResearchBar — ARAŞTIRMA kartı (Ar-Ge GDD §5.6), DESTEK kartının altında aynı sütunda.
#
# DÖRT SATIR:
#   başlık   : ARAŞTIRMA + sağda TEK DURUM DİZGİSİ — koşarken "~{n} hafta kaldı",
#              duraklamışken sebep cümlesi (§5.6.1), atananların hepsi izinde ya da eğitimdeyse
#              "katkı yok" (§5.5). Sayı hiçbir hâlde uydurulmaz.
#   ad       : düğümün adı ve alanı; dar kartta kısalan alandır.
#   ilerleme : çubuk ve yüzde.
#   bağlar   : duraklat · ata, donmuşken vazgeç · ata ve altında vazgeçin notu; karar beklerken
#              kapalı, gerekçesi sağda.
#
# %100'DE KART KAYBOLUR (§5.8): model false döner, `fingerprint()` "" olur, ev
# sahibi kartı kaldırır. DURAKLAMIŞTA İLERLEME YANMAZ: dolgu nötrleşir, yüzde olduğu
# yerde durur çünkü motor da progress'i korur (§5.7); sebep cümlesi öne çıkar.
# Ar-Ge penceresi açıkken kart görünmez: aynı satır pencerenin şeridinde.
#
# `ata` BAĞI SEKMEYE GİDER, PANEL AÇMAZ. Akordeon Ar-Ge sayfasında yaşıyor; bu
# kart her sayfanın üstünde yüzüyor, yani paneli kendi içinde açsaydı aynı panel
# iki yerde iki hâlde bulunurdu.
# ============================================================================

const Model := preload("res://scripts/ui/components/research_bar_model.gd")
const BarKit := preload("res://scripts/ui/components/bar_kit.gd")
const RESEARCH_ICON := preload("res://assets/icons/rail/rnd.svg")

var _model: Model = null
var _tab := ""

var _title_label: Label = null
var _status_label: Label = null      # hafta tahmini VEYA duraklama sebebi
var _name_label: Label = null
var _area_label: Label = null
var _progress: ProgressBar = null
var _percent_label: Label = null
var _links: HBoxContainer = null
var _abandon_note: Label = null
var _share := 0.0                    # the founder's meeting share the estimate was painted at


func _ready() -> void:
	# ALWAYS: ağaç duraklıyken (oyuncu karar verirken) de kart canlı kalsın.
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
	EventBus.event_triggered.connect(r1)
	EventBus.event_resolved.connect(refresh.unbind(2))
	EventBus.event_set_aside.connect(r1)
	EventBus.tab_changed.connect(_on_tab_changed)
	EventBus.clock_batch_ended.connect(_on_clock_batch)
	refresh()


## Modeli yeniden türet ve boya. Ev sahipleri bunu ÇAĞIRMAZ (widget kendi dinler).
func refresh() -> void:
	_share = GameState.founder_meeting_share()
	var m := Model.new()
	_model = m if m.derive() else null
	_repaint()


## A clock batch can move the founder's meeting share, and the week estimate counts it.
func _on_clock_batch() -> void:
	if GameState.founder_meeting_share() != _share:
		refresh()


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

	_links = BarKit.line()
	col.add_child(_links)
	_abandon_note = SprintUiShared.prose("", &"Caption")
	col.add_child(_abandon_note)


# --- Boyama -------------------------------------------------------------------

func _repaint() -> void:
	visible = _model != null and _tab != "rnd"
	if _model == null:
		return
	var m := _model
	_title_label.text = Fmt.upper(tr("RND_BAR_TITLE"))
	_status_label.text = _status_text(m)
	_status_label.theme_type_variation = &"CaptionPrimary" if m.paused else &"Caption"
	_name_label.text = m.node_name
	_area_label.text = m.area_line
	_progress.value = m.percent
	_progress.theme_type_variation = &"ProgressPaused" if m.paused else &""
	_percent_label.text = tr("PROD_PERCENT").format({"n": m.percent})
	# Bağlar her boyamada yeniden kurulur: duraklamışta `duraklat` yerine `vazgeç` ve altında notu, karar
	# beklerken ikisi de kapalı ve gerekçe sağda (kabuğun tutulan Ofisi taşı düğmesi gibi).
	UiFactory.clear(_links)
	var gated: bool = EventGate.active_id() != ""
	var links := RnDUiShared.links(m.paused, gated, _on_pause, _on_assign)
	_links.add_child(links)
	_abandon_note.text = tr("RND_ABANDON_NOTE")
	_abandon_note.visible = m.paused
	var assign: Button = links.get_child(-1)
	assign.tooltip_text = "" if m.assignee_names.is_empty() \
		else tr("RND_WHO").format({"who": ", ".join(PackedStringArray(m.assignee_names))})
	if gated:
		_links.add_child(RnDUiShared.spacer())
		_links.add_child(UiFactory.make_label(tr("TOPBAR_GATE"), &"Caption"))


## Başlık satırının sağ yuvası. Duraklamışsa SEBEP CÜMLESİ, koşarken "~{n} hafta kaldı",
## kimse katkı vermiyorsa (weeks_left == NO_WEEKS) "katkı yok".
func _status_text(m: Model) -> String:
	if m.pause_note != "":
		return m.pause_note
	if m.weeks_left == Model.NO_WEEKS:
		return tr("RND_WEEKS_NONE")
	return RnDUiShared.weeks_text(m.weeks_left)


func _on_tab_changed(tab: String) -> void:
	_tab = tab
	_repaint()


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
