class_name RnDDetailPanel
extends Control

# ============================================================================
# AR-GE → DÜĞÜM KARTI (onaylı R2 · altı durum, artı GDD'nin eklediği iki tane).
#
# ÇAPA KURALI'nın yaşadığı yer burası değil — kutu RnDTreeView'ın (sabit
# yükseklik, seçili sütunun x'i, COL_W genişlik). BU DOSYA yalnız o kutunun
# İÇİNİ doldurur, ve içeriğin BOYU DÜZENİ ETKİLEMEZ: her şey bir
# ScrollContainer'da. R1'in "panelin yüksekliği ne olursa olsun düzen kaymaz"
# cümlesi ancak böyle doğru kalır.
#
# ÜST KENAR AYRI DÜĞÜMDÜR. Bir `StyleBoxFlat` tek bir kenara FARKLI renk
# veremez; durum rengini taşıyan 2px şerit bu yüzden kendi Panel'i
# (build_bar.gd'nin kapak çizgisi emsali).
#
# ALTI DURUM:
#   ARAŞTIRILABİLİR · NAKİT ENGELİ · KOŞUYOR · DONMUŞ · TAMAMLANDI · ÇAPRAZ EKSİK
# GDD'nin eklediği iki tanesi:
#   · `user_research`ta kadroda PM/Tasarımcı yokken CANLI uyarı (§6.2 — kapı
#     araştırmadan ÖNCE yazılır, 70 efor sonra keşfedilmez).
#   · Açılmamış bir çocukta "Önce {düğüm}." (§7).
#
# PALET (R8): bu sayfanın TEK KIRMIZISI nakit engeli satırıdır. Yeşil hiç yok.
# ============================================================================

## Atama paneli açılıp kapandı — kutu değişmez, ama tuval kılavuz çizgisini
## yeniden çizsin diye haber veriyoruz.
signal assign_visibility_changed

const EDGE_H := 2

var _node_id: String = ""
var _assign_open: bool = false
var _content: VBoxContainer = null
var _edge: Panel = null
var _assign: RnDAssignPanel = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP   # panelin altındaki tuvale tıklama sızmasın
	_build_shell()


func _build_shell() -> void:
	var card := PanelContainer.new()
	card.name = "Card"
	card.theme_type_variation = &"CardPanel"
	card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(card)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	card.add_child(col)

	_edge = Panel.new()
	_edge.name = "StateEdge"
	_edge.custom_minimum_size = Vector2(0, EDGE_H)
	_edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_edge)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)

	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", UiTokens.SPACE_M)
	scroll.add_child(_content)


# ---------------------------------------------------------------- public

func show_node(node_id: String, open_assign: bool = false) -> void:
	var changed: bool = node_id != _node_id
	_node_id = node_id
	if changed or open_assign:
		# Atama paneli DÜĞÜME BAĞLIDIR: başka bir düğüm seçilince kapanır,
		# yoksa oyuncu A düğümünün listesiyle B düğümünü başlatabilirdi.
		_assign_open = open_assign and _can_assign()
	visible = node_id != ""
	_rebuild()


func repaint() -> void:
	# Ucuz tazeleme yok: kartın her satırı bir motor okumasıdır ve kart tek bir
	# düğümlük (yirmi kartlık bir liste değil), yani yeniden kurmak bedava.
	# Atama paneli AÇIKKEN dokunmuyoruz — oyuncunun seçim listesi uçmasın.
	if _node_id == "" or _assign_open:
		return
	_rebuild()


func node_id() -> String:
	return _node_id


func assign_open() -> bool:
	return _assign_open


# ---------------------------------------------------------------- çizim

func _rebuild() -> void:
	if _content == null:
		return
	for c in _content.get_children():
		_content.remove_child(c)
		c.queue_free()
	_assign = null
	if _node_id == "":
		return

	var state: String = RnDUiShared.tile_state(_node_id)
	var esb := StyleBoxFlat.new()
	esb.bg_color = RnDUiShared.state_edge_color(state)
	esb.anti_aliasing = false
	_edge.add_theme_stylebox_override("panel", esb)

	_content.add_child(_head_row(state))

	if _assign_open:
		_assign = RnDAssignPanel.new()
		_assign.started.connect(_on_assign_committed)
		_assign.closed.connect(_on_assign_closed)
		_content.add_child(_assign)
		_assign.setup(_node_id)
		return

	_add_description()
	_add_unlocks()
	_add_state_body(state)
	_add_actions(state)


## Ad + sağda "{aile} · {mertebe}".
func _head_row(state: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var name_lbl := UiFactory.make_label(ResearchSeam.node_name(_node_id), &"RowName")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(name_lbl)
	if state == RnDUiShared.TILE_DONE:
		row.add_child(UiFactory.make_label(RnDUiShared.MARK_DONE, &"RowName", UiTokens.INK_DIM))
	var meta := UiFactory.make_label(RnDUiShared.t("RND_NODE_META").format({
		"family": RnDUiShared.family_name(ResearchSeam.family(_node_id)),
		"tier": RnDUiShared.tier_caption(_node_id),
	}), &"MicroLabel")
	meta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(meta)
	return row


func _add_description() -> void:
	var key: String = "PROD_RND_NODE_%s_DESC" % _node_id.to_upper()
	var lbl := UiFactory.make_label(RnDUiShared.t(key), &"CaptionMuted")
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_child(lbl)


## "Açtığı şey:" + düğümün kendi cümlesi (§4 "Açtığı şey" sütunu).
func _add_unlocks() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	row.add_child(UiFactory.make_label(
		RnDUiShared.t("RND_UNLOCKS_PREFIX"), &"MicroLabel", UiTokens.INK_DIM))
	var body := UiFactory.make_label(
		RnDUiShared.t("PROD_RND_NODE_%s_UNLOCK" % _node_id.to_upper()), &"RowMeta")
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(body)
	_content.add_child(row)


## Durumun gövdesi: gereksinim satırı VEYA onun yerine geçen canlı satır.
func _add_state_body(state: String) -> void:
	match state:
		RnDUiShared.TILE_RUNNING, RnDUiShared.TILE_FROZEN:
			# KOŞUYOR: gereksinim satırının YERİNE alan + atananlar + kalan gün.
			_add_line(_running_line(), UiTokens.INK_MUTED)
		RnDUiShared.TILE_DONE:
			_add_line(_completed_line(), UiTokens.INK_MUTED)
		_:
			_add_line(_requirement_line(), UiTokens.INK_MUTED)
	_add_blockers(state)


## Gereksinim satırı: parçalar "·" ile birleşir (finance_ozet_view'ın join
## kalıbı — ayraç bir cümle değil, YAPI).
func _requirement_line() -> String:
	var parts := PackedStringArray()
	for area in ResearchTree.areas_of(_node_id):
		parts.append(RnDUiShared.t("RND_AREA_OF").format({
			"area": RnDUiShared.area_label(String(area))}))
	parts.append(RnDUiShared.t("RND_REQ_STARS").format({"n": ResearchTree.stars_of(_node_id)}))
	var solo: float = RnDSystem.days_estimate_solo(_node_id)
	# -1.0 = "katkı yok" (§5.5). ASLA BÖLÜNMEZ ve asla ∞ yazılmaz: sayı yoksa
	# parça da yoktur.
	if solo > 0.0:
		parts.append(RnDUiShared.days_solo_text(solo))
	var cash: int = ResearchTree.cash_of(_node_id)
	if cash > 0:
		parts.append(_cash_part(cash))
	return " · ".join(parts)


## §8 — bazı düğümlerin adlandırılmış maliyet etiketi var ("GPU kirası $600");
## `has_cost_label` onu söylüyor. Metin yazılmamışsa çıplak tutara düşer, ham
## anahtar ekrana çıkmaz.
func _cash_part(cash: int) -> String:
	var money: String = RnDUiShared.money(cash)
	if ResearchTree.has_cost_label(_node_id):
		return RnDUiShared.t_or("PROD_RND_NODE_%s_COST" % _node_id.to_upper(),
			RnDUiShared.t("RND_REQ_CASH").format({"money": money})).format({"money": money})
	return RnDUiShared.t("RND_REQ_CASH").format({"money": money})


func _running_line() -> String:
	var parts := PackedStringArray()
	for area in ResearchTree.areas_of(_node_id):
		parts.append(RnDUiShared.t("RND_AREA_OF").format({
			"area": RnDUiShared.area_label(String(area))}))
	var names := PackedStringArray()
	for cid in RnDSystem.assigned(_node_id):
		var c: Character = CharacterRegistry.get_character(String(cid))
		if c != null:
			names.append(c.character_name)
	if not names.is_empty():
		parts.append(", ".join(names))
	var days: float = RnDSystem.days_estimate(_node_id, RnDSystem.assigned(_node_id))
	if days > 0.0:
		parts.append(RnDUiShared.days_text(days))
	return " · ".join(parts)


## TAMAMLANDI: alan + açtığı kapı.
##
## AÇIK İŞ, ve sessizce uydurmuyoruz: R2 burada "kaç günde bitti" istiyor
## (`RND_DAYS_TAKEN`), ama motor tamamlanma GÜNÜNÜ SAKLAMIYOR — RnDSystem'in
## kayıt listesinde (states/progress/paid/note_*) böyle bir alan yok. Sayıyı
## efordan ya da tahminden uydurmak bir YALAN olurdu (Kalibrasyon Yasası 3:
## sebep okunabilir olmalı), o yüzden satır o parçasız basılıyor ve eksik
## `completed_day(node)` seam'i rapora yazıldı.
func _completed_line() -> String:
	var parts := PackedStringArray()
	for area in ResearchTree.areas_of(_node_id):
		parts.append(RnDUiShared.t("RND_AREA_OF").format({
			"area": RnDUiShared.area_label(String(area))}))
	var opened := PackedStringArray()
	for child in ResearchTree.children_of(_node_id):
		opened.append(ResearchSeam.node_name(String(child)))
	if opened.size() >= 2:
		parts.append(RnDUiShared.t("RND_COMPLETED_UNLOCKED_TWO").format({
			"first": opened[0], "second": opened[1]}))
	elif opened.size() == 1:
		parts.append(RnDUiShared.t("RND_COMPLETED_UNLOCKED_ONE").format({"node": opened[0]}))
	return " · ".join(parts)


## Durum satırları: engel, not ve donmuş uyarısı.
func _add_blockers(state: String) -> void:
	if state == RnDUiShared.TILE_FROZEN:
		_add_line(RnDUiShared.t("RND_FROZEN_KEEPS"), UiTokens.INK_MUTED)
		_add_line(RnDUiShared.t("BUILD_BUSY_NOBODY"), UiTokens.ACCENT)
	elif state == RnDUiShared.TILE_LOCKED or state == RnDUiShared.TILE_AVAILABLE:
		var reason: String = _refusal()
		match reason:
			RnDSystem.REFUSE_CASH:
				# SAYFANIN TEK KIRMIZISI (R8).
				_add_line(RnDUiShared.t("RND_NEED_CASH").format({
					"money": RnDUiShared.money(ResearchTree.cash_of(_node_id))}),
					UiTokens.negative())
			RnDSystem.REFUSE_CROSS:
				var src: String = ResearchTree.cross_of(_node_id)
				_add_line(RnDUiShared.t("RND_NEED_CROSS_NAMED").format({
					"node": ResearchSeam.node_name(src),
					"family": RnDUiShared.family_name(ResearchSeam.family(src))}),
					UiTokens.INK_MUTED)
			RnDSystem.REFUSE_STARS:
				_add_line(RnDUiShared.t("RND_NEED_STARS").format({
					"n": ResearchTree.stars_of(_node_id),
					"area": RnDUiShared.area_label(String(_first_area()))}),
					UiTokens.INK_MUTED)
			RnDSystem.REFUSE_LOCKED:
				# §7 — açılmamış çocuk. Derin bağdan seçilebilir, ve panel
				# kendini açıklamak zorunda.
				_add_line(RnDUiShared.t("RND_NEED_PARENT").format({
					"node": ResearchSeam.node_name(ResearchTree.parent_of(_node_id))}),
					UiTokens.INK_MUTED)
			RnDSystem.REFUSE_CLOSED:
				_add_line(RnDUiShared.t("RND_TREE_CLOSED"), UiTokens.INK_MUTED)
	# §6.2 — CANLI uyarı: `user_research` kadroda yazacak kimse yokken de
	# araştırılabilir, ama aylık rapor SESSİZCE ATLANIR. Kapı araştırmadan ÖNCE
	# yazılır. Amber, kırmızı değil: bu bir engel değil bir uyarı.
	if _node_id == RnDSystem.NODE_USER_RESEARCH and not RnDSystem.note_author_available():
		_add_line(RnDUiShared.t("RND_NOTE_NO_WRITER"), UiTokens.ACCENT)


func _add_line(text: String, color: Color) -> void:
	if text == "":
		return
	var lbl := UiFactory.make_label(text, &"RowMeta", color)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_child(lbl)


# ---------------------------------------------------------------- eylemler

func _add_actions(state: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	match state:
		RnDUiShared.TILE_RUNNING:
			# `duraklat` / `ata` BAĞDIR, buton değil (R2) —
			# feature_lines_view.gd:355-362'nin reçetesi.
			var pause_link := RnDUiShared.link(RnDUiShared.t("RND_BAR_PAUSE"))
			pause_link.clicked.connect(_on_pause)
			row.add_child(pause_link)
			var assign_link := RnDUiShared.link(RnDUiShared.t("RND_ASSIGN_TITLE"))
			assign_link.clicked.connect(_on_open_assign)
			row.add_child(assign_link)
		RnDUiShared.TILE_FROZEN:
			var only_assign := RnDUiShared.link(RnDUiShared.t("RND_ASSIGN_TITLE"))
			only_assign.clicked.connect(_on_open_assign)
			row.add_child(only_assign)
		RnDUiShared.TILE_AVAILABLE:
			var reason: String = _refusal()
			if reason == RnDSystem.REFUSE_NOBODY:
				# Tek geçerli "engel yok" cevabı: kimseyi seçmedik daha. Başlat
				# atama panelini AÇAR, araştırmayı başlatmaz — R3'ün kapısı.
				row.add_child(HRUiShared.action_button(
					RnDUiShared.t("RND_START"), _on_open_assign, true))
			else:
				row.add_child(HRUiShared.disabled_button(
					RnDUiShared.t("RND_START"), _refusal_text(reason)))
		_:
			return   # TAMAMLANDI ve KİLİTLİ'de eylem yok
	_content.add_child(row)


## Kapalı Başlat'ın hover gerekçesi. Ekrandaki satırla AYNI cümle: iki farklı
## sebep metni tutmak ikisinin ayrışması demek.
func _refusal_text(reason: String) -> String:
	match reason:
		RnDSystem.REFUSE_CASH:
			return RnDUiShared.t("RND_NEED_CASH").format({
				"money": RnDUiShared.money(ResearchTree.cash_of(_node_id))})
		RnDSystem.REFUSE_CROSS:
			var src: String = ResearchTree.cross_of(_node_id)
			return RnDUiShared.t("RND_NEED_CROSS_NAMED").format({
				"node": ResearchSeam.node_name(src),
				"family": RnDUiShared.family_name(ResearchSeam.family(src))})
		RnDSystem.REFUSE_STARS:
			return RnDUiShared.t("RND_NEED_STARS").format({
				"n": ResearchTree.stars_of(_node_id),
				"area": RnDUiShared.area_label(String(_first_area()))})
		RnDSystem.REFUSE_LOCKED:
			return RnDUiShared.t("RND_NEED_PARENT").format({
				"node": ResearchSeam.node_name(ResearchTree.parent_of(_node_id))})
	return RnDUiShared.t("RND_TREE_CLOSED")


## BOŞ LİSTEYLE sorulur, ve bu bilinçli: `start_refusal`ın sırası
## kapalı → kilitli → tamam → ÇAPRAZ → NAKİT → YILDIZ → kimse-yok, yani boş
## liste tam olarak "insan dışındaki her engel" sorusunu sorar. REFUSE_NOBODY
## dönmesi "başka engel yok" demektir — kartın ARAŞTIRILABİLİR hâli budur.
func _refusal() -> String:
	return RnDSystem.start_refusal(_node_id, [])


func _first_area() -> String:
	var areas: Array = ResearchTree.areas_of(_node_id)
	return String(areas[0]) if not areas.is_empty() else ""


func _can_assign() -> bool:
	var state: String = RnDUiShared.tile_state(_node_id)
	if state == RnDUiShared.TILE_RUNNING or state == RnDUiShared.TILE_FROZEN:
		return true
	return state == RnDUiShared.TILE_AVAILABLE and _refusal() == RnDSystem.REFUSE_NOBODY


func _on_open_assign() -> void:
	_assign_open = true
	# ERTELENMİŞ: paneli kendi `pressed`/`gui_input`'ı hâlâ akarken yıkmak
	# düğümü sinyalin altından çeker (team_panel.gd:619-622 bunu yazıyor).
	_rebuild.call_deferred()
	assign_visibility_changed.emit()


func _on_assign_closed() -> void:
	_assign_open = false
	_rebuild.call_deferred()
	assign_visibility_changed.emit()


## Başlat/Uygula işledi. Motor sinyali (research_started / research_frozen)
## sayfanın yeniden kurulmasını zaten tetikliyor; burada yalnız paneli
## kapatıyoruz ki o yeniden kurulum kartı doğru hâlde bulsun.
func _on_assign_committed() -> void:
	_assign_open = false
	_rebuild.call_deferred()
	assign_visibility_changed.emit()


func _on_pause() -> void:
	RnDSystem.pause()
