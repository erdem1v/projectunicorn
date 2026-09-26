class_name RnDDetailPanel
extends Control

# ============================================================================
# AR-GE → DÜĞÜM KARTI (§8). Kutu RnDTreeView'ın (sabit yükseklik, seçili sütunun
# x'i ve genişliği); BU DOSYA yalnız o kutunun İÇİNİ doldurur ve içeriğin boyu
# düzeni etkilemez: her şey bir ScrollContainer'da.
#
# ÜST KENAR AYRI DÜĞÜMDÜR: bir `StyleBoxFlat` tek bir kenara farklı renk veremez,
# durum rengini taşıyan 2px şerit bu yüzden kendi Panel'i.
#
# Durumlar: araştırılabilir · nakit engeli · koşuyor · donmuş · tamamlandı · çapraz
# eksik; artı `user_research`ta kadroda PM/Tasarımcı yokken CANLI uyarı (§6.2) ve
# açılmamış bir çocukta "Önce {düğüm}." (§7).
#
# PALET: bu sayfanın TEK KIRMIZISI nakit engeli satırıdır. Yeşil hiç yok.
# ============================================================================

## Atama paneli açılıp kapandı — kutu değişmez, ama tuval kılavuz çizgisini
## yeniden çizsin diye haber veriyoruz.
signal assign_visibility_changed

const EDGE_H := 2

var _node_id: String = ""
var _assign_open: bool = false
var _content: VBoxContainer = null
var _edge: Panel = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP   # panelin altındaki tuvale tıklama sızmasın
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
	_rebuild()


## Kartın her satırı bir motor okumasıdır ve kart tek bir düğümlük, yani yeniden
## kurmak bedava. Atama paneli AÇIKKEN dokunulmaz — oyuncunun seçim listesi uçmasın.
func repaint() -> void:
	if _node_id != "" and not _assign_open:
		_rebuild()


# ---------------------------------------------------------------- çizim

func _rebuild() -> void:
	for c in _content.get_children():
		_content.remove_child(c)
		c.queue_free()

	var state: String = RnDUiShared.tile_state(_node_id)
	var esb := StyleBoxFlat.new()
	esb.bg_color = RnDUiShared.state_edge_color(state)
	esb.anti_aliasing = false
	_edge.add_theme_stylebox_override("panel", esb)

	_content.add_child(_head_row(state))

	if _assign_open:
		var assign := RnDAssignPanel.new()
		assign.started.connect(_set_assign_open.bind(false))
		assign.closed.connect(_set_assign_open.bind(false))
		_content.add_child(assign)
		assign.setup(_node_id)
		return

	_add_line(RnDUiShared.t("PROD_RND_NODE_%s_DESC" % _node_id.to_upper()), null, &"CaptionMuted")
	_add_unlocks()
	_add_state_body(state)
	_add_blockers(state)
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


## "Açtığı şey:" + düğümün kendi cümlesi (§8).
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


## Durumun gövde satırı: alan parçaları + duruma göre gereksinim, canlı gidiş ya da
## açtığı kapı. Parçalar "·" ile birleşir (ayraç bir cümle değil, YAPI).
func _add_state_body(state: String) -> void:
	var parts: PackedStringArray = RnDUiShared.area_parts(_node_id)
	match state:
		RnDUiShared.TILE_RUNNING, RnDUiShared.TILE_FROZEN:
			# Gereksinimin YERİNE atananlar + kalan gün.
			var ids: Array = RnDSystem.assigned(_node_id)
			var names := PackedStringArray()
			for cid in ids:
				var c: Character = CharacterRegistry.get_character(String(cid))
				if c != null:
					names.append(c.character_name)
			if not names.is_empty():
				parts.append(", ".join(names))
			var days: float = RnDSystem.days_estimate(_node_id, ids)
			if days > 0.0:
				parts.append(RnDUiShared.days_text(days))
		RnDUiShared.TILE_DONE:
			# Süre parçası (`RND_DAYS_TAKEN`) yok: RnDSystem tamamlanma gününü saklamıyor
			# ve sayı efordan ya da tahminden uydurulmaz.
			var opened: Array = ResearchTree.children_of(_node_id)
			if opened.size() >= 2:
				parts.append(RnDUiShared.t("RND_COMPLETED_UNLOCKED_TWO"))
			elif opened.size() == 1:
				parts.append(RnDUiShared.t("RND_COMPLETED_UNLOCKED_ONE").format({
					"node": ResearchSeam.node_name(String(opened[0]))}))
		_:
			parts.append(RnDUiShared.t("RND_REQ_STARS").format({"n": ResearchTree.stars_of(_node_id)}))
			# -1.0 = "katkı yok" (§5.5): sayı yoksa parça da yok, asla ∞ yazılmaz.
			var solo: float = RnDSystem.days_estimate_solo(_node_id)
			if solo > 0.0:
				parts.append(RnDUiShared.t("RND_DAYS_SOLO").format({"n": RnDUiShared.whole_days(solo)}))
			var cash: int = ResearchTree.cash_of(_node_id)
			if cash > 0:
				# §8 — bazı düğümlerin adlandırılmış maliyet etiketi var ("GPU kirası $600").
				# Metni yazılmamışsa çıplak tutara düşer, ham anahtar ekrana çıkmaz.
				var text: String = RnDUiShared.t("RND_REQ_CASH")
				if ResearchTree.has_cost_label(_node_id):
					text = RnDUiShared.t_or("PROD_RND_NODE_%s_COST" % _node_id.to_upper(), text)
				parts.append(text.format({"money": Fmt.money(cash)}))
	_add_line(" · ".join(parts), UiTokens.INK_MUTED)


## Durum satırları: donmuşun sebebi, açılmamış ya da araştırılabilir düğümün engeli
## ve §6.2 uyarısı.
func _add_blockers(state: String) -> void:
	if state == RnDUiShared.TILE_FROZEN:
		_add_line(RnDUiShared.t("RND_FROZEN_KEEPS"), UiTokens.INK_MUTED)
		# §5.6.1 — duraklamanın SEBEBİ yazılır, çubukla aynı motor okumasından.
		_add_line(RnDUiShared.t(RnDSystem.freeze_note_key()), UiTokens.ACCENT)
	elif state == RnDUiShared.TILE_LOCKED or state == RnDUiShared.TILE_AVAILABLE:
		var reason: String = _refusal()
		if reason != RnDSystem.REFUSE_NOBODY:
			# Nakit engeli SAYFANIN TEK KIRMIZISI. Açılmamış çocuk derin bağdan
			# seçilebilir ve kart kendini "Önce {düğüm}." diye açıklar (§7).
			_add_line(RnDUiShared.refusal_text(_node_id, reason),
				UiTokens.negative() if reason == RnDSystem.REFUSE_CASH else UiTokens.INK_MUTED)
	# §6.2 — CANLI uyarı: `user_research` kadroda yazacak kimse yokken de
	# araştırılabilir, ama aylık rapor SESSİZCE ATLANIR. Kapı araştırmadan ÖNCE
	# yazılır. Amber, kırmızı değil: bu bir engel değil bir uyarı.
	if _node_id == RnDSystem.NODE_USER_RESEARCH and RnDSystem.note_author() == null:
		_add_line(RnDUiShared.t("RND_NOTE_NO_WRITER"), UiTokens.ACCENT)


## `color` null = varyasyonun kendi rengi (UiFactory.make_label'ın sözleşmesi).
func _add_line(text: String, color: Variant, variation: StringName = &"RowMeta") -> void:
	var lbl := UiFactory.make_label(text, variation, color)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_child(lbl)


# ---------------------------------------------------------------- eylemler

func _add_actions(state: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	match state:
		RnDUiShared.TILE_RUNNING, RnDUiShared.TILE_FROZEN:
			# `duraklat` / `ata` BAĞDIR, buton değil. Donmuşta duraklatılacak bir şey yok.
			if state == RnDUiShared.TILE_RUNNING:
				var pause_link := RnDUiShared.link(RnDUiShared.t("RND_BAR_PAUSE"))
				pause_link.clicked.connect(_on_pause)
				row.add_child(pause_link)
			var assign_link := RnDUiShared.link(RnDUiShared.t("RND_ASSIGN_TITLE"))
			assign_link.clicked.connect(_set_assign_open.bind(true))
			row.add_child(assign_link)
		RnDUiShared.TILE_AVAILABLE:
			var reason: String = _refusal()
			if reason == RnDSystem.REFUSE_NOBODY:
				# Tek geçerli "engel yok" cevabı: kimse seçilmedi daha. Başlat atama
				# panelini AÇAR, araştırmayı başlatmaz.
				row.add_child(HRUiShared.action_button(
					RnDUiShared.t("RND_START"), _set_assign_open.bind(true), true))
			else:
				row.add_child(HRUiShared.disabled_button(
					RnDUiShared.t("RND_START"), RnDUiShared.refusal_text(_node_id, reason)))
		_:
			return   # TAMAMLANDI ve KİLİTLİ'de eylem yok
	_content.add_child(row)


## BOŞ LİSTEYLE sorulur, ve bu bilinçli: `start_refusal`ın sırası
## kapalı → kilitli → tamam → ÇAPRAZ → NAKİT → YILDIZ → kimse-yok, yani boş
## liste tam olarak "insan dışındaki her engel" sorusunu sorar. REFUSE_NOBODY
## dönmesi "başka engel yok" demektir — kartın ARAŞTIRILABİLİR hâli budur.
func _refusal() -> String:
	return RnDSystem.start_refusal(_node_id, [])


func _can_assign() -> bool:
	match RnDUiShared.tile_state(_node_id):
		RnDUiShared.TILE_RUNNING, RnDUiShared.TILE_FROZEN:
			return true
		RnDUiShared.TILE_AVAILABLE:
			return _refusal() == RnDSystem.REFUSE_NOBODY
	return false


## Atama panelini aç/kapat. ERTELENMİŞ: paneli kendi `pressed`/`gui_input`'ı hâlâ
## akarken yıkmak düğümü sinyalin altından çeker. Başlat/Uygula işlediğinde motorun
## sinyali (research_started · assignment_changed) sayfayı zaten yeniden kuruyor;
## burada yalnız panel kapanır ki o kurulum kartı doğru hâlde bulsun.
func _set_assign_open(open: bool) -> void:
	_assign_open = open
	_rebuild.call_deferred()
	assign_visibility_changed.emit()


func _on_pause() -> void:
	RnDSystem.pause()
