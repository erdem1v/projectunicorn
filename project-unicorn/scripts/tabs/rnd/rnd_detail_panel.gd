class_name RnDDetailPanel
extends Control

# ============================================================================
# AR-GE → DÜĞÜM KARTI (§8). Kutu RnDTreeView'ın (sabit yükseklik, iki sütun genişlik);
# BU DOSYA yalnız o kutunun İÇİNİ doldurur ve içeriğin boyu düzeni etkilemez: her şey
# kartın kendi kaydırmasında. Kart bir belgedir (NodeCard, kesik köşe).
#
# Durumlar: araştırılabilir · nakit engeli · koşuyor · donmuş · tamamlandı · çapraz
# eksik; artı `user_research`ta kadroda PM/Tasarımcı yokken CANLI uyarı (§6.2) ve
# açılmamış bir çocukta "Önce {düğüm}." (§7). Başka bir araştırma koşarken araştırılabilir
# kart Başlat'ın onu durduracağını söyler (§5.7). Karar beklerken eylemler kapalı, gerekçesi
# yanında.
#
# PALET: bu sayfanın TEK TEHLİKESİ kasanın karşılayamadığı bedeldir (bedel çipi).
# ============================================================================

const INFO := "res://assets/icons/util/info.svg"
const WARN := "res://assets/icons/util/warn.svg"
const CLOCK := "res://assets/icons/util/clock.svg"

var _node_id: String = ""
var _assign_open: bool = false
var _assign: RnDAssignPanel = null
var _content: VBoxContainer = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP   # kartın altındaki tuvale tıklama sızmasın
	var card := PanelContainer.new()
	card.theme_type_variation = &"NodeCard"
	card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(card)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card.add_child(scroll)
	_content = SprintUiShared.column(UiTokens.SPACE_L)
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
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
## kurmak bedava. Atama paneli AÇIKKEN liste kurulmaz — oyuncunun seçimi uçmasın; yalnız
## alt bandı (tahmin, eylem, gerekçe) yeniden okunur.
func repaint() -> void:
	if _node_id == "":
		return
	if _assign_open:
		_assign.refresh_footer()
	else:
		_rebuild()


# ---------------------------------------------------------------- çizim

func _rebuild() -> void:
	UiFactory.clear(_content)
	var state: String = RnDUiShared.tile_state(_node_id)
	_content.add_child(_head_row(state))
	if _assign_open:
		_assign = RnDAssignPanel.new()
		_assign.name = "AssignPanel"
		_assign.started.connect(_set_assign_open.bind(false))
		_assign.closed.connect(_set_assign_open.bind(false))
		_content.add_child(_assign)
		_assign.setup(_node_id, _switch_note())
		return
	_content.add_child(SprintUiShared.prose(RnDUiShared.t("PROD_RND_NODE_%s_DESC" % _node_id.to_upper()), &"DataText"))
	_content.add_child(_unlocks())
	var chips: HFlowContainer = _chips(state)
	if chips.get_child_count() > 0:
		_content.add_child(chips)
	for line: Control in _lines(state):
		_content.add_child(line)
	var gap := Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_child(gap)
	var acts: Control = _actions(state)
	if acts != null:
		_content.add_child(acts)


## Ad, bittiyse onay glifi; sağda "{aile} · {mertebe}".
func _head_row(state: String) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.add_child(SprintUiShared.label(ResearchSeam.node_name(_node_id), &"NameTitle"))
	if state == RnDUiShared.TILE_DONE:
		row.add_child(UiFactory.make_glyph(RnDTreeView.CHECK, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	row.add_child(RnDUiShared.spacer())
	row.add_child(SprintUiShared.label(Fmt.upper(RnDUiShared.t("RND_NODE_META").format({
		"family": RnDUiShared.family_name(ResearchSeam.family(_node_id)),
		"tier": RnDUiShared.tier_caption(_node_id),
	})), &"KeySmall"))
	return row


## "Açtığı şey" + düğümün kendi cümlesi (§8).
func _unlocks() -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	var key := UiFactory.make_label(Fmt.upper(RnDUiShared.t("RND_UNLOCKS_PREFIX")), &"KeyLabel")
	key.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(key)
	row.add_child(SprintUiShared.prose(RnDUiShared.t("PROD_RND_NODE_%s_UNLOCK" % _node_id.to_upper()), &"DataText"))
	return row


## The requirement in chips (§5.5): each area's stars, the weeks it takes and the cost; a running or frozen
## research shows its area and the weeks left instead.
func _chips(state: String) -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", UiTokens.SPACE_M)
	flow.add_theme_constant_override("v_separation", UiTokens.SPACE_M)
	if state == RnDUiShared.TILE_DONE:
		return flow
	for area in ResearchTree.areas_of(_node_id):
		flow.add_child(_chip(RnDUiShared.with_stars(RnDUiShared.t("RND_REQ_STARS").format(
			{"area": HRConstants.area_label(String(area))}), ResearchTree.stars_of(_node_id), &"DataMedium")))
	if state in [RnDUiShared.TILE_RUNNING, RnDUiShared.TILE_FROZEN]:
		var left: float = RnDSystem.weeks_estimate(_node_id, RnDSystem.assigned(_node_id))
		if left > 0.0:
			flow.add_child(_chip(_glyph_text(CLOCK, RnDUiShared.weeks_text(left))))
		return flow
	# -1.0 = "katkı yok" (§5.5): sayı yoksa çip de yok, asla ∞ yazılmaz.
	var solo: float = RnDSystem.weeks_estimate_solo(_node_id)
	if solo > 0.0:
		flow.add_child(_chip(_glyph_text(CLOCK, RnDUiShared.weeks_line("RND_WEEKS_SOLO", solo))))
	var cash: int = ResearchTree.cash_of(_node_id)
	if cash > 0:
		# §8 — bazı düğümlerin adlandırılmış maliyet etiketi var ("GPU kirası $600"). Metni yazılmamışsa
		# çıplak tutara düşer, ham anahtar ekrana çıkmaz.
		var text: String = RnDUiShared.t("RND_REQ_CASH")
		if ResearchTree.has_cost_label(_node_id):
			text = RnDUiShared.t_or("PROD_RND_NODE_%s_COST" % _node_id.to_upper(), text)
		var cost: HBoxContainer = UiFactory.D_cost(text.format({"money": Fmt.money(cash)}), &"DataMedium", UiTokens.D_ICON_ROW)
		var chip := _chip(cost)
		if _refusal() == RnDSystem.REFUSE_CASH:
			chip.theme_type_variation = UiTokens.D_variation(&"ReqChipRisk")
			cost.get_child(1).add_theme_color_override("font_color", UiTokens.D_neg_ink())
		flow.add_child(chip)
	return flow


func _chip(part: Control) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.theme_type_variation = &"ReqChip"
	chip.add_child(part)
	return chip


func _glyph_text(glyph: String, text: String) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_S)
	row.add_child(UiFactory.make_glyph(glyph, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	row.add_child(SprintUiShared.label(text, &"DataMedium"))
	return row


## The card's notes under the chips: who is on a running research, why a frozen one stands, the door a
## finished one opened, what holds a closed one back, the switch Başlat would make, and §6.2's live warning.
func _lines(state: String) -> Array:
	var out: Array = []
	match state:
		RnDUiShared.TILE_RUNNING:
			var names := PackedStringArray()
			for cid in RnDSystem.assigned(_node_id):
				# Someone who left stays on the research until its next tick prunes them.
				var c: Character = CharacterRegistry.get_character(String(cid))
				if c != null:
					names.append(c.character_name)
			out.append(SprintUiShared.label(", ".join(names), &"MetaMuted"))
		RnDUiShared.TILE_FROZEN:
			# §5.6.1 — duraklamanın SEBEBİ yazılır, çubukla aynı motor okumasından.
			var why := _note(RnDUiShared.PAUSE, RnDUiShared.t(RnDSystem.freeze_note_key()), UiTokens.D_INK_2)
			why.add_child(SprintUiShared.label("·", &"CaptionFaint"))
			why.add_child(SprintUiShared.label(RnDUiShared.t("RND_FROZEN_KEEPS"), &"MetaMuted"))
			out.append(why)
		RnDUiShared.TILE_DONE:
			# Süre parçası yok: RnDSystem tamamlanma tikini saklamıyor ve sayı efordan ya da
			# tahminden uydurulmaz.
			var opened: Array = ResearchTree.children_of(_node_id)
			if opened.size() == 1:
				out.append(_note(INFO, RnDUiShared.t("RND_COMPLETED_UNLOCKED_ONE").format({
					"node": ResearchSeam.node_name(String(opened[0]))})))
			elif opened.size() >= 2:
				out.append(_note(INFO, RnDUiShared.t("RND_COMPLETED_UNLOCKED_TWO")))
		RnDUiShared.TILE_LOCKED:
			# Açılmamış çocuk derin bağdan seçilebilir ve kart kendini "Önce {düğüm}." diye açıklar (§7).
			out.append(RnDUiShared.refusal_line(_node_id, _refusal(), &"MetaMuted"))
		_:
			var note: String = _switch_note()
			if note != "":
				out.append(_note(INFO, note))
	# §6.2 — CANLI uyarı: `user_research` kadroda yazacak kimse yokken de araştırılabilir, ama aylık
	# rapor SESSİZCE ATLANIR. Kapı araştırmadan ÖNCE yazılır.
	if _node_id == RnDSystem.NODE_USER_RESEARCH and RnDSystem.note_author() == null:
		out.append(_note(WARN, RnDUiShared.t("RND_NOTE_NO_WRITER"), UiTokens.D_warn()))
	return out


## §5.7 — starting this one stops the running research, whose progress stays; "" when nothing else runs.
func _switch_note() -> String:
	var running: String = RnDSystem.active()
	if running == "" or running == _node_id:
		return ""
	return RnDUiShared.t("RND_SWITCH_NOTE").format({"node": ResearchSeam.node_name(running)})


func _note(glyph: String, text: String, ink: Variant = null) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	row.add_child(UiFactory.make_glyph(glyph, UiTokens.D_ICON_ROW, ink if ink != null else UiTokens.D_INK_4))
	row.add_child(SprintUiShared.label(text, &"MetaMuted", ink))
	return row


# ---------------------------------------------------------------- eylemler

## The card's foot: Başlat for a research to start (it opens the assignment), with what holds it back beside it;
## the research's own links while it runs or stands frozen. Off while a decision waits.
func _actions(state: String) -> Control:
	var gated: bool = EventGate.active_id() != ""
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.add_child(RnDUiShared.spacer())
	match state:
		RnDUiShared.TILE_RUNNING, RnDUiShared.TILE_FROZEN:
			row.add_child(RnDUiShared.links(state == RnDUiShared.TILE_FROZEN, gated, func() -> void: RnDSystem.pause(),
				_set_assign_open.bind(true)))
		RnDUiShared.TILE_AVAILABLE:
			var refusal: String = _refusal()
			if gated:
				row.add_child(SprintUiShared.label(RnDUiShared.t("GATE_ANSWER_FIRST"), &"NoteMuted"))
			elif refusal != RnDSystem.REFUSE_NOBODY:
				row.add_child(RnDUiShared.refusal_line(_node_id, refusal, &"NoteMuted"))
			var start := SprintUiShared.button(RnDUiShared.t("RND_START"), &"PrimaryButtonDark", _set_assign_open.bind(true))
			start.disabled = gated or refusal != RnDSystem.REFUSE_NOBODY
			row.add_child(start)
		_:
			return null   # TAMAMLANDI ve KİLİTLİ'de eylem yok
	return row


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
