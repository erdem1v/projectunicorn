extends Control

# ============================================================================
# AR-GE KARTI — TEK RENDERER, İKİ YÜK. `populate("discovery"|"note", data)`.
#
#   R5 · KEŞİF KARTI (640): bir düğüm tamamlandı. Başlık · düğüm adı · anın kendi
#        cümlesi · açtığı şey · (varsa) açılan hat satırı · Tamam.
#   R7 · AYLIK ÜRÜN NOTU (720): üç sinyal, hüküm yok, üç eşit ağırlıklı çıkış.
#
# ————————————————————————————————————————————————————————————————————————————
#  BU YÜZEYDE ETKİ ROZETİ YOKTUR. DELTA ETİKETİ YOKTUR. PARA / MARKA / MRR
#  SATIRI YOKTUR. VE HİÇBİR YERİNDE YEŞİL YOKTUR.
#
#  Bu bir üslup tercihi değil, §5.8 ile R5'in ortak hükmüdür: BİR ARAŞTIRMANIN
#  TAMAMLANMASI EKONOMİK DELTA ÜRETMEZ. Motor da böyle davranıyor —
#  `RnDSystem._complete()` nakit, marka ve MRR'a hiç dokunmaz; açtığı KAPI ödülün
#  kendisidir. Buraya bir "+$" çipi, bir yeşil ok ya da bir "etki" rozeti eklemek,
#  motorun vermediği bir şeyi vaat eder ve oyuncunun bir daha güvenmeyeceği türden
#  bir yalan olur. SONRAKİ OTURUM: bu kartı "zenginleştirmek" için gelen her fikir
#  bu paragrafta durur.
# ————————————————————————————————————————————————————————————————————————————
#
# KATMAN SEÇİMİ ÖLÇÜLMÜŞ BİR KARARDIR: PanelLayer (layer 9), ModalLayer (layer 10)
# DEĞİL. ModalLayer Space ve 1-3'ü YUTUYOR, yani saat, oyuncunun duraklatamadığı
# bir kararın üstünde koşmaya devam ederdi. Bedeli: game_shell.gd:164-168'in Guard
# 3'ü Esc'i PanelLayer sakinine HANDLED İŞARETLEMEDEN devrediyor — o yüzden kapanış
# bu dosyanın kendi `_unhandled_input`'undadır (hr_popover.gd'nin reçetesi).
#
# MONTAJ SIRASI: `add_child` ÖNCE, `populate` SONRA (ev konvansiyonu — _ready
# referansları ancak ağaca girdikten sonra dolu). hr_tab._open_hours_modal'ın
# birebir kalıbı.
#
# process_mode = ALWAYS: saat duruyorken de tıklanabilir olmalı.
# ============================================================================

const KIND_DISCOVERY := "discovery"
const KIND_NOTE := "note"

## R5 640 · R7 720. İki yükün TEK farkı budur; gövde ikisinde de aynı gramerde.
const W_DISCOVERY := 640
const W_NOTE := 720

const PAD_X := 28
const PAD_Y := 24
const GAP := 12
const SEP := " · "

var _kind: String = ""
var _panel: PanelContainer = null
var _body: VBoxContainer = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.color = UiTokens.SCRIM_MODAL
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	_panel = PanelContainer.new()
	_panel.theme_type_variation = &"ModalPanel"
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", PAD_X)
	margin.add_theme_constant_override("margin_right", PAD_X)
	margin.add_theme_constant_override("margin_top", PAD_Y)
	margin.add_theme_constant_override("margin_bottom", PAD_Y)
	_panel.add_child(margin)

	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", GAP)
	margin.add_child(_body)


## Ev sahibi ÖNCE add_child eder, SONRA burayı çağırır (ev kuralı).
func populate(kind: String, data: Dictionary) -> void:
	if not is_node_ready():
		await ready
	_kind = kind
	for c in _body.get_children():
		c.queue_free()
	match kind:
		KIND_DISCOVERY:
			_panel.custom_minimum_size = Vector2(W_DISCOVERY, 0)
			_build_discovery(data)
		KIND_NOTE:
			_panel.custom_minimum_size = Vector2(W_NOTE, 0)
			_build_note(data)
		_:
			push_error("[RnDCardModal] bilinmeyen kart türü: '%s'" % kind)
			queue_free()


# --- R5 · KEŞİF ----------------------------------------------------------------

func _build_discovery(data: Dictionary) -> void:
	var node_id: String = String(data.get("node", ""))
	_body.add_child(UiFactory.make_label(tr("RND_DISCOVERY_TITLE"), &"SectionAmber"))
	_body.add_child(UiFactory.make_label(ResearchSeam.node_name(node_id), &"ModalTitleSerif"))

	# ANIN KENDİ CÜMLESİ. Sekiz devam düğümü Erken Erişim'e ertelendi ve kartları
	# YAZILMADI; anahtarı çözülmeyen düğümde gövde SATIRI HİÇ ÇİZİLMEZ. Ekrana ham
	# anahtar basmak (PROD_RND_NODE_X_DISCOVERY) hiçbir koşulda kabul edilmez.
	var body: String = _resolved("PROD_RND_NODE_%s_DISCOVERY" % node_id.to_upper())
	if body != "":
		var prose := UiFactory.make_label(body, &"QuoteSerif")
		prose.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		prose.custom_minimum_size = Vector2(W_DISCOVERY - 2 * PAD_X, 0)
		_body.add_child(prose)

	_body.add_child(_hairline())

	# AÇTIĞI ŞEY. Parçalar " · " ile birleşir; tek parça da aynı yoldan geçer, yani
	# iki ayrı satır grameri doğmuyor.
	var opened: Array[String] = []
	var unlock: String = _resolved("PROD_RND_NODE_%s_UNLOCK" % node_id.to_upper())
	if unlock != "":
		opened.append(unlock)
	# Kök ve dal düğümleri iki çocuk açar; o iki yuvanın ADLANDIĞINI söyleyen cümle
	# kartın kendi cümlesidir, ağacınki değil.
	if ResearchTree.children_of(node_id).size() == 2:
		opened.append(tr("RND_COMPLETED_UNLOCKED_TWO"))
	var opened_row := UiFactory.make_label(
		"%s %s" % [tr("RND_OPENED_PREFIX"), SEP.join(PackedStringArray(opened))], &"BodySerif")
	opened_row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	opened_row.custom_minimum_size = Vector2(W_DISCOVERY - 2 * PAD_X, 0)
	_body.add_child(opened_row)

	# TEK İSTEĞE BAĞLI SATIR, HER ZAMAN KURULUR, `visible` İLE AÇILIR/KAPANIR.
	# İki yerleşim böylece TEK satır farkla ayrışır ve hiçbir şey yeniden akmaz —
	# satırı koşullu olarak EKLESEYDİM kartın yüksekliği düğüme göre zıplardı.
	var extra := UiFactory.make_label("", &"BodySerif", UiTokens.INK_MUTED)
	extra.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	extra.custom_minimum_size = Vector2(W_DISCOVERY - 2 * PAD_X, 0)
	extra.visible = false
	_body.add_child(extra)
	var line_id: String = String(data.get("line", ResearchTree.opens_line_of(node_id)))
	if line_id != "":
		if ResearchTree.hidden_line_authored(line_id):
			var line_name: String = _line_name(line_id)
			if line_name != "":
				extra.text = tr("RND_HIDDEN_LINE_OPENED").format({"line": line_name})
				extra.visible = true
		else:
			# §12.1 / direktör hükmü R4 — hat İLAN EDİLDİ, KAYIT EDİLMEDİ. Kart bunu
			# dürüstçe söyler; sessizce boş bırakmak "duyurulmuş ama ulaşılmaz"ın ta
			# kendisi olurdu (§3.1).
			extra.text = tr("RND_EA_LINE_NOTE")
			extra.visible = true

	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", UiTokens.SPACE_M)
	bar.alignment = BoxContainer.ALIGNMENT_END
	_body.add_child(bar)
	bar.add_child(_button(tr("RND_OK"), _close))


# --- R7 · AYLIK ÜRÜN NOTU --------------------------------------------------------

func _build_note(data: Dictionary) -> void:
	_body.add_child(UiFactory.make_label(tr("RND_NOTE_TITLE"), &"SectionAmber"))

	var who := HBoxContainer.new()
	who.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_body.add_child(who)
	who.add_child(UiFactory.make_label(
		tr("RND_NOTE_AUTHOR_META").format({"author": String(data.get("author_name", ""))}),
		&"BodySerif"))
	var role: String = String(data.get("author_role", ""))
	if role != "":
		who.add_child(UiFactory.make_label(
			UiTokens.tr_upper(HRConstants.role_label(role)), &"MicroLabel"))

	_body.add_child(_hairline())

	# ÜÇ SATIR, ÜÇÜ DE AYNI BİÇİMDE. Çip yok, vurgu yok, sıra ipucu yok: kart bir
	# TAVSİYE değil bir İKİLEM. Biri öne çıksaydı oyun kararı kendisi vermiş olurdu.
	# `market` (b2b/b2c) satırların ANAHTARINDA yaşıyor — RND_NOTE_*_B2B_* / *_B2C_* —
	# yani kart onu ayrıca etiketlemez ve burada okumaz. Bir gün kartın üstünde bir
	# pazar rozeti isterse, o rozet bu paragrafın izniyle gelir, sessizce değil.
	_body.add_child(_note_line(String(data.get("demand_key", "")),
		{"line": String(data.get("line", ""))}, "RND_NOTE_DEMAND_NONE"))
	_body.add_child(_note_line(String(data.get("rival_key", "")),
		{"rival": String(data.get("rival", ""))}, ""))
	_body.add_child(_note_line(String(data.get("tech_key", "")),
		{"node": ResearchSeam.node_name(String(data.get("node", "")))}, ""))

	# §6.1 — bu modal koşuda YALNIZ BİR KEZ açılır; sonraki her rapor sekmede bekler.
	# Cümlesi bu yüzden burada, sekmede değil.
	_body.add_child(UiFactory.make_label(tr("RND_NOTE_FIRST_HINT"), &"MicroLabel"))
	_body.add_child(_hairline())

	# ÜÇ EŞİT AĞIRLIKLI ÇIKIŞ. CommitButton (amber dolu) BİLEREK kullanılmadı:
	# doldurulmuş tek buton "doğru cevap bu" derdi ve kartın ikilem olduğu iddiası
	# orada biterdi. KARAR BUTONU YOKTUR.
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", UiTokens.SPACE_M)
	bar.alignment = BoxContainer.ALIGNMENT_END
	_body.add_child(bar)
	bar.add_child(_button(tr("RND_NOTE_GO_PRODUCT"), _go.bind("product")))
	bar.add_child(_button(tr("RND_NOTE_GO_TREE"), _go.bind("rnd")))
	bar.add_child(_button(tr("RND_NOTE_CLOSE"), _read_and_close))


## §6.4 — talep üreteci HENÜZ YOK, o yüzden `demand_key` boş geliyor ve satır
## belgelenmiş bozunmuş hâline düşüyor ("Bu ay kimse bir şey istemedi."). BU BİR
## HATA DEĞİL SIRALAMADIR; üreteç indiğinde anahtar dolar ve satır kendiliğinden
## konuşur. Rakip ve teknoloji satırlarının yedek cümlesi YOKTUR — anahtarları
## boşken satır KURULUR ama gizlenir, ki üç satırın biçimi (ve dolayısıyla kartın
## "hüküm yok" iddiası) tek bir yerde kalsın ve ham anahtar ekrana düşmesin.
func _note_line(key: String, args: Dictionary, fallback_key: String) -> Control:
	var lbl := UiFactory.make_label("", &"BodySerif")
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.custom_minimum_size = Vector2(W_NOTE - 2 * PAD_X, 0)
	var text: String = ""
	if key != "":
		text = _resolved(key)
		if text != "":
			text = text.format(args)
	elif fallback_key != "":
		text = tr(fallback_key)
	lbl.text = text
	lbl.visible = text != ""
	return lbl


func _go(tab_id: String) -> void:
	EventBus.tab_changed.emit(tab_id)
	_read_and_close()


## ÜÇÜNÜN DE OKUNDU İŞARETİ VAR. Rapor bir görev değil bir okuma: hangi çıkışı
## seçerse seçsin oyuncu notu GÖRDÜ, ve rozetin bunu bilmemesi için sebep yok.
func _read_and_close() -> void:
	RnDSystem.mark_note_read()
	_close()


# --- Ortak ----------------------------------------------------------------------

## Çözülmeyen anahtar "" döner. Ekrana ASLA ham anahtar basılmaz; çağıran satırı
## ya atlar ya gizler.
func _resolved(key: String) -> String:
	var out: String = tr(key)
	return "" if out == key else out


## product_lines.gd:387'nin anahtar sözleşmesi. Kayıtlı hattın kendi `name_key`'i
## varsa O okunur; EA'ya ertelenmiş (hiç kaydedilmemiş) hat için sözleşme yeniden
## kurulur — ve çözülmezse "" döner, çünkü ham hat kimliği ekrana yazılmaz.
func _line_name(line_id: String) -> String:
	var rec: Dictionary = ProductLines.line("%s@%s" % [line_id, ProductState.subtype()])
	var key: String = String(rec.get("name_key", ""))
	if key == "":
		key = "PROD_LINE_%s" % line_id.trim_prefix("line_").to_upper()
	return _resolved(key)


func _hairline() -> Control:
	var r := ColorRect.new()
	r.color = UiTokens.DIVIDER_LIGHT
	r.custom_minimum_size = Vector2(0, 1)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


func _button(text: String, handler: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(handler)
	return b


func _unhandled_input(event: InputEvent) -> void:
	# Guard 3 Esc'i BU KATMANA devrediyor ve HANDLED işaretlemiyor — kapatma
	# sorumluluğu bizde. Esc notu OKUNDU İŞARETLEMEZ: üç çıkış oyuncunun notla ne
	# yapacağına dair bir cevaptır, Esc ise cevabı ertelemektir; rapor sekmede
	# bekler ve rozeti durur.
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	queue_free()
