class_name SprintCard
extends PanelContainer

# Ürün sprint ekranının tek kartı: aday listesi, bu sprint, sonraki sprint ve çeyrek sütunu aynı
# sahneyi kullanır. Kart yalnız sözlüğünü çizer: hangi düğmenin olduğu (`buttons`) ve "+"nın
# açıklığı (`can_add`) modelden gelir.

enum State { ADAY, ADAY_ALINMIS, SPRINT_PLAN, SPRINT_AKTIF, BITTI, DEVREDEN, PLANLANAN, KILITLI, BETA_BEKLIYOR }

## args her eylemde {card_id}; karar düğmesi "decide" yayar.
signal action(kind: String, args: Dictionary)

## Aday kartında düğmeler hep görünür; sprint ve sonraki sütun kartında hover'da çıkar.
const BUTTONS_ALWAYS := [State.ADAY, State.KILITLI]
const BUTTONS_ON_HOVER := [State.SPRINT_PLAN, State.SPRINT_AKTIF, State.PLANLANAN, State.DEVREDEN]
const PHASE_KEYS := ["PRODUCT_PHASE_DESIGN", "PRODUCT_PHASE_DEV", "PRODUCT_PHASE_TEST"]

@export var state: State
## Çeyrek sütununun mini kartı: ikon, iki satıra sarılan ad, düz efor sayısı.
@export var compact := false

var _card: Dictionary
var _hover_bar: HBoxContainer   # sonraki ve sprint kartının hover'da beliren düğmeleri
## HoverEffort: efor dökümü; sütunun kırpmasından kaçsın diye top_level yüzer.
var _effort_box: PanelContainer
var _effort_parts: PackedStringArray
var _column: Control   # kutunun sığacağı kaydırma sütunu; kutu her belirişte bir kez bulunur
var _hovered := false
var _forced := false


func setup(card: Dictionary, can_add: bool) -> void:
	_card = card
	state = card.state
	if state == State.ADAY_ALINMIS or state == State.KILITLI:
		modulate.a = UiTokens.PRODUCT_FADED_ALPHA
	if state == State.KILITLI:
		tooltip_text = card.locked_node
	# Devreden kart sonraki sütunda kalan puanıyla durur.
	var points: int = int(card.remaining) if int(card.remaining) >= 0 else int(card.effort)
	var line := HBoxContainer.new()
	line.add_theme_constant_override(&"separation", UiTokens.SPACE_M)
	add_child(line)
	if compact:
		var title := _add_title(line, &"RowMetaStrong")
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.max_lines_visible = 2
		line.add_child(SprintUiShared.stamp(str(points), &"RowMetaStrong"))
	else:
		_build_full(line, can_add, points)
	_paint()


## Çeyrek sütunu kartı ağaca kurulduktan sonra girer; motor _ready'de işlemeyi yeniden açar.
func _ready() -> void:
	_paint()


## Fikstür hover'ı (`ui.hover_card`): efor kutusu ve amber kenar, düğmeler olmadan.
func show_effort() -> void:
	_forced = true
	_paint()


func _build_full(line: HBoxContainer, can_add: bool, points: int) -> void:
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override(&"separation", UiTokens.PRODUCT_CARD_ROW_GAP)
	line.add_child(body)

	var head := HBoxContainer.new()
	head.add_theme_constant_override(&"separation", UiTokens.SPACE_S)
	body.add_child(head)
	# Dar sonraki sütunda uzun ad kesilmez, ikinci satıra iner.
	var title := _add_title(head, &"DataMono")
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.max_lines_visible = 2
	match state:
		State.PLANLANAN: head.add_child(SprintUiShared.stamp(tr("PRODUCT_PLANNED"), &"MicroLabel"))
		State.DEVREDEN: head.add_child(SprintUiShared.stamp(tr("PRODUCT_CARRIED"), &"StampAmber"))
		State.BETA_BEKLIYOR: head.add_child(SprintUiShared.stamp(tr("PRODUCT_BETA_WAITING"), &"Stamp"))
		State.KILITLI: head.add_child(HRUiShared.lock_glyph(UiTokens.PRODUCT_ICON_PX, UiTokens.INK_MUTED))
	# Söz verilmiş kademe her yerde etiketli: planlamada da, sprint sürerken de.
	if _card.effect.any(func(part: Dictionary) -> bool: return part.k == "promise"):
		head.add_child(SprintUiShared.stamp(tr("PRODUCT_PROMISED"), &"StampAmber"))
	if _card.urgent:
		_add_alarm(head, tr("PRODUCT_URGENT"))
	if _card.spills:
		_add_alarm(head, tr("PRODUCT_CARD_SPILLS"))
	for role in _card.roles:
		head.add_child(SprintUiShared.icon("role_" + String(role), UiTokens.PRODUCT_ICON_PX, UiTokens.INK_MUTED))
	head.add_child(SprintUiShared._square(UiFactory.make_label(str(points), &"DataMonoBox"), UiTokens.SPACE_XXL))

	if state == State.SPRINT_AKTIF or state == State.BITTI:
		body.add_child(_phase_row())
	else:
		body.add_child(SprintUiShared.effect_line(_card.effect, "card"))
	if _card.decision != null:
		body.add_child(_decision_row(_card.decision))

	# Kartın sağ ucu: sprinte alınmış adayın "Sprint N" damgası ve adayın hep görünen + →.
	if int(_card.tag_sprint) >= 0:
		line.add_child(SprintUiShared.stamp(tr("PRODUCT_TAG_SPRINT").format({"n": int(_card.tag_sprint)}), &"StampAmber"))
	var on_hover: bool = state in BUTTONS_ON_HOVER
	if on_hover or state in BUTTONS_ALWAYS:
		var host: HBoxContainer = line
		if on_hover:
			# Hover düğmeleri kartın sağ üstüne biner: satırı daraltıp adı kesmez, kart zıplamaz.
			host = HBoxContainer.new()
			host.size_flags_horizontal = Control.SIZE_SHRINK_END
			host.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			host.add_theme_constant_override(&"separation", 0)
			host.mouse_filter = Control.MOUSE_FILTER_IGNORE
			host.visible = false
			add_child(host)
			_hover_bar = host
		for kind in _card.buttons:
			var b := SprintUiShared.ink_button(kind, kind == "add" and (not can_add or state == State.KILITLI))
			b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			# STOP olsaydı imleç düğmeye geçince kart hover'ı biter, hover düğmeleri kaybolurdu.
			b.mouse_filter = Control.MOUSE_FILTER_PASS
			b.pressed.connect(action.emit.bind(kind, {"card_id": String(_card.id)}))
			host.add_child(b)

	var split: Array = _card.effort_split
	if not split.is_empty():
		var parts: PackedStringArray = [tr(Fmt.count_key("PRODUCT_EFFORT_POINTS", points)).format({"n": points})]
		for s in split:
			var weeks: int = int(s.weeks)
			parts.append(tr("PRODUCT_EFFORT_PERSON").format({"name": s.name,
				"weeks": tr(Fmt.count_key("PRODUCT_WEEKS", weeks)).format({"n": weeks})}))
		_effort_box = PanelContainer.new()
		_effort_box.theme_type_variation = &"HoverBox"
		_effort_box.top_level = true
		_effort_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_effort_parts = parts
		_effort_box.add_child(UiFactory.make_label(SprintUiShared.SEP.join(parts), &"DataMono"))
		add_child(_effort_box)
	if _effort_box != null or _hover_bar != null:
		mouse_entered.connect(_hover.bind(true))
		mouse_exited.connect(_hover.bind(false))


## Tür ikonu alan renginde ve ad: tam kartta ilk satırın, mini kartta tek satırın başı.
func _add_title(row: HBoxContainer, variation: StringName) -> Label:
	row.add_child(SprintUiShared.icon("kind_" + String(_card.kind), UiTokens.PRODUCT_ICON_PX, UiTokens.area_color(int(_card.slot))))
	var title := UiFactory.make_label(String(_card.name), variation)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(title)
	return title


## "! acil" ve "devreder": negatif anlamlı çip; fareyi geçirir ki kartın hover'ını kesmesin.
func _add_alarm(row: HBoxContainer, text: String) -> void:
	var chip := SprintUiShared.semantic_chip(text, &"negative")
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(chip)


## Sprint içi satırı: Tasarım · Geliştirme · Test noktaları, o haftanın atananları, bitince tik.
func _phase_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", UiTokens.SPACE_XS)
	var steps := HBoxContainer.new()
	steps.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	steps.add_theme_constant_override(&"separation", UiTokens.SPACE_S)
	row.add_child(steps)
	var phases: Array = _card.phases
	var all_done: bool = phases.count("done") == phases.size()
	for i in phases.size():
		var phase: String = phases[i]
		var ink: Color = UiTokens.INK_FAINT
		match phase:
			"done": ink = UiTokens.positive() if all_done else UiTokens.INK_MUTED
			"active": ink = UiTokens.ACCENT_DEEP
		if i > 0:
			var link := ColorRect.new()
			link.color = UiTokens.CARD_BORDER if phase == "waiting" else UiTokens.INK_MUTED
			link.custom_minimum_size = Vector2(UiTokens.SPACE_XXL, UiTokens.BORDER_HAIRLINE)
			link.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			link.mouse_filter = Control.MOUSE_FILTER_IGNORE
			steps.add_child(link)
		steps.add_child(SprintUiShared.phase_dot(phase, ink))
		steps.add_child(UiFactory.make_label(tr(PHASE_KEYS[i]), &"MicroLabel", ink))
	for a in _card.assignees:
		row.add_child(SprintUiShared.avatar(a.initials,
			tr("PRODUCT_PERSON_ROLE").format({"name": a.name, "role": a.role_text}), UiTokens.SPACE_XXL, false))
	if state == State.BITTI:
		var ring := StyleBoxFlat.new()
		ring.bg_color = UiTokens.positive_bg()
		ring.border_color = UiTokens.positive_rule()
		ring.set_border_width_all(UiTokens.BORDER_HAIRLINE)
		ring.set_corner_radius_all(UiTokens.RADIUS_PILL)
		var badge := PanelContainer.new()
		badge.custom_minimum_size = Vector2.ONE * UiTokens.PRODUCT_BADGE_PX
		badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_theme_stylebox_override(&"panel", ring)
		var tick := SprintUiShared.icon("tick", UiTokens.PRODUCT_ICON_PX, UiTokens.positive())
		tick.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		badge.add_child(tick)
		row.add_child(badge)
	return row


## Karar bekleyen kartın satırı: konuşan, cümlesi ve olay modalını açan düğme.
func _decision_row(d: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"DecisionRow"
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", UiTokens.SPACE_M)
	panel.add_child(row)
	row.add_child(SprintUiShared.avatar(d.initials, d.speaker, UiTokens.SPACE_XXL, false))
	row.add_child(SprintUiShared.stamp(tr("PRODUCT_DECISION_SPEAKER").format({"speaker": d.speaker}), &"RowMeta"))
	var quote := UiFactory.make_label(d.text, &"QuoteSerif")
	quote.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quote.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(quote)
	var go := Button.new()
	go.theme_type_variation = &"PrimaryButtonSmall"
	go.text = tr("PRODUCT_DECIDE")
	go.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	go.mouse_filter = Control.MOUSE_FILTER_PASS
	go.pressed.connect(action.emit.bind("decide", {"card_id": String(_card.id)}))
	row.add_child(go)
	return panel


func _hover(on: bool) -> void:
	_hovered = on
	if _hover_bar != null:
		_hover_bar.visible = on
	_paint()


## Hover kenarı: düz kartta PaperCardOpen, kesikli kartta _draw'daki amber kesik.
func _paint() -> void:
	var hot: bool = _hovered or _forced
	if _dashed():
		theme_type_variation = &"PaperCardDashed"
	else:
		theme_type_variation = &"PaperCardOpen" if hot else &"PaperCard"
	if _effort_box != null:
		_effort_box.visible = hot
		if not hot:
			_column = null
	set_process(hot and _effort_box != null)
	queue_redraw()


## HoverEffort kartın sağ üstünde durur ve sütunun dışına taşmaz; üstte yer yoksa kartın altına
## iner. Her karede yerleşir, çünkü sütun kaydıkça kartın ekrandaki yeri değişir.
func _process(_delta: float) -> void:
	if _column == null:
		_fit_effort()
	var bounds: Rect2 = _column.get_global_rect()
	var card: Rect2 = get_global_rect()
	var box: Vector2 = _effort_box.get_combined_minimum_size()
	var y: float = card.position.y - UiTokens.SPACE_S - box.y
	if y < bounds.position.y:
		y = card.end.y + UiTokens.SPACE_S
	_effort_box.size = box
	_effort_box.global_position = Vector2(
		clampf(card.end.x - UiTokens.SPACE_L - box.x, bounds.position.x, bounds.end.x - box.x), y)


## Kutu belirdikten sonraki ilk karede, sütun yerleşmişken bir kez: kartın kaydırma sütununu
## bulur; döküm sütuna tek satır sığmıyorsa parçalar alt alta dizilir, kutu sütundan taşmaz.
func _fit_effort() -> void:
	_column = get_parent_control()
	while not _column is ScrollContainer:
		_column = _column.get_parent_control()
	var effort := _effort_box.get_child(0) as Label
	var one_line: String = SprintUiShared.SEP.join(_effort_parts)
	var wide: float = effort.get_theme_font(&"font").get_string_size(one_line, HORIZONTAL_ALIGNMENT_LEFT, -1,
		effort.get_theme_font_size(&"font_size")).x + _effort_box.get_theme_stylebox(&"panel").get_minimum_size().x
	effort.text = one_line if wide <= _column.size.x else "\n".join(_effort_parts)


## Sol kenarda alan rengi; sonraki sütunun kartları kesikli kenarlı (devreden ve çeyrekte önerilen amber).
func _draw() -> void:
	if _dashed():
		var amber: bool = state == State.DEVREDEN or compact or _hovered or _forced
		RnDUiShared.draw_dashed_rect(self, Rect2(Vector2.ZERO, size).grow(-UiTokens.BORDER_HAIRLINE / 2.0),
			UiTokens.ACCENT_DEEP if amber else UiTokens.BORDER_DASHED)
	SprintUiShared.draw_edge(self, int(_card.slot))


func _dashed() -> bool:
	return state == State.PLANLANAN or state == State.DEVREDEN
