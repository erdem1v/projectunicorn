class_name SprintCard
extends PanelContainer

# Ürün sprint ekranının sonraki sprint sütununun ve ÇEYREK sütunlarının kartı, küçük bir belge. Kart yalnız sözlüğünü çizer: hangi
# düğmenin olduğu (`buttons`) modelden gelir. Sonraki sprinte planlanmış kart kesikli kenarlıdır.

enum State { SPRINT_PLAN, SPRINT_AKTIF, BITTI, DEVREDEN, PLANLANAN, KILITLI }
## NARROW sonraki sütun (ad iki satıra iner, durum etiketleri kendi satırında); MINI çeyrek sütunu.
enum Look { NARROW, MINI }

## args her eylemde {card_id}; araştırma kilidinin bağlantısı "rnd" ({card_id, node}) yayar.
signal action(kind: String, args: Dictionary)

## Kilitli kartın düğmesi üst satırda, hep parlak; sonraki sütun kartınınkiler altta, sönük, fare kartın üstüne gelince parlak.
const BUTTONS_ALWAYS := [State.KILITLI]
const BUTTONS_DIM := [State.PLANLANAN, State.DEVREDEN]
const PLANNED := [State.PLANLANAN, State.DEVREDEN]

@export var state: State

var _card: Dictionary
var _look := Look.NARROW
var _keys: HBoxContainer   # sonraki sütun kartının sönük düğmeleri
var _hovered := false


func setup(card: Dictionary, look: Look) -> void:
	_card = card
	state = card.state
	_look = look
	if state in PLANNED:
		HRUiShared.D_dashed(self)
	# Devreden kart sonraki sütunda kalan puanıyla durur.
	var points: float = card.remaining if card.remaining >= 0 else card.effort
	var body := SprintUiShared.column(UiTokens.SPACE_M)
	add_child(body)
	var top := SprintUiShared.box(UiTokens.SPACE_M if look != Look.MINI else UiTokens.SPACE_S)
	body.add_child(top)
	var ink := _ink()
	top.add_child(UiFactory.make_glyph(SprintUiShared.KIND_ICON % _card.kind,
		UiTokens.D_ICON_PART if look == Look.MINI else UiTokens.D_ICON_ROW, ink.glyph))
	var title := UiFactory.make_label(String(_card.name), &"CaptionStrong" if look == Look.MINI else ink.title, ink.name)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.max_lines_visible = 2
	top.add_child(title)
	var tags: Array = [] if look == Look.MINI else _tags()
	if look == Look.MINI:
		top.add_child(_points(points))
		_align(top)
		_paint()
		return
	var roles := SprintUiShared.box(UiTokens.SPACE_XS)
	for role in _card.roles:
		roles.add_child(UiFactory.make_glyph(SprintUiShared.ROLE_ICONS[String(role)], UiTokens.D_ICON_ROW, ink.glyph))
	top.add_child(roles)
	top.add_child(_points(points))
	if state in BUTTONS_ALWAYS:
		var acts := SprintUiShared.box(UiTokens.SPACE_XS)
		for kind in _card.buttons:
			# Kilitli kart iki sprinte de gidemez.
			acts.add_child(_key(kind, kind != "remove"))
		top.add_child(acts)
	_align(top)
	if not tags.is_empty():
		var row := HFlowContainer.new()
		row.add_theme_constant_override("h_separation", UiTokens.SPACE_S)
		for t in tags:
			row.add_child(t)
		body.add_child(row)

	if not _card.effect.is_empty():
		body.add_child(SprintUiShared.effect_line(_card.effect))
	if state == State.KILITLI:
		# Kartın altında kilit ve gerekçesi; araştırma kilidinde Ar-Ge'ye bağlantı da.
		var lock := HFlowContainer.new()
		lock.add_theme_constant_override("h_separation", UiTokens.SPACE_S)
		lock.add_child(UiFactory.make_glyph(SprintUiShared.LOCK, UiTokens.D_ICON_PART, UiTokens.D_INK_3))
		lock.add_child(SprintUiShared.label(String(_card.locked_node), &"Caption"))
		if _card.locked_rnd != "":
			var go := SprintUiShared.button(tr("PRODUCT_GO_RND"), &"FloatLink",
				action.emit.bind("rnd", {"card_id": String(_card.id), "node": String(_card.locked_rnd)}))
			go.mouse_filter = Control.MOUSE_FILTER_PASS   # STOP kartın hover'ını bitirirdi
			lock.add_child(go)
		body.add_child(lock)
	if state in BUTTONS_DIM:
		_foot(body)
	if _keys != null:
		mouse_entered.connect(_hover.bind(true))
		mouse_exited.connect(_hover.bind(false))
	_paint()


## Ağaca kurulumdan sonra giren kartta motor işlemeyi _ready'de yeniden açar.
func _ready() -> void:
	_paint()


## {glyph, name, title}: kilitli kart kapalı mürekkepte, biten kart ikincil mürekkepte okunur.
func _ink() -> Dictionary:
	match state:
		State.KILITLI:
			return {"glyph": UiTokens.D_INK_OFF, "name": UiTokens.D_INK_OFF, "title": &"DataStrong"}
		State.BITTI:
			return {"glyph": UiTokens.D_INK_3, "name": UiTokens.D_INK_3, "title": &"DataStrong"}
	return {"glyph": UiTokens.D_INK_3, "name": UiTokens.D_INK_1 if _look == Look.MINI else null, "title": &"DataStrong"}


func _points(points: float) -> Label:
	var pts := UiFactory.make_label(SprintUiShared.points(points), &"PtsBox")
	pts.custom_minimum_size.x = UiTokens.D_W_PTS
	pts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return pts


## Durum etiketleri: devreden, öncelikli (uyarı üçgeniyle) ve verilmiş söz nötr; önden hazırlanan kart hazır payını ("%40 hazır",
## tamamsa "Geliştirmeye hazır") taşır. "Planlanan" etiketi yok: kesikli kenar söyler.
func _tags() -> Array:
	var out: Array = []
	if _card.priority:
		out.append(UiFactory.D_glyph_tag(SprintUiShared.WARN, tr("PRODUCT_PRIORITY"), &"warn"))
	for row in [[state == State.DEVREDEN, "PRODUCT_CARRIED"],
			[_card.effect.any(func(p: Dictionary) -> bool: return p.k == "promise"), "PRODUCT_PROMISED"]]:
		if row[0]:
			out.append(UiFactory.D_tag(tr(row[1]), &"outline"))
	if _card.ready >= 0.0:
		out.append(UiFactory.D_tag(tr("PRODUCT_CARD_READY") if _card.ready >= 1.0 else tr("PRODUCT_CARD_READY_PCT").format(
			{"pct": Fmt.percent(floorf(_card.ready * 100.0), 0)}), &"outline"))
	return out


## Ad iki satıra inebilir: satırın öbür parçaları üste yaslanır.
func _align(top: HBoxContainer) -> void:
	for part: Control in top.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_BEGIN


func _key(kind: String, disabled: bool) -> Button:
	var b := SprintUiShared.key_button(kind, disabled)
	# STOP olsaydı imleç düğmeye geçince kartın hover'ı biter, düğmeler sönerdi.
	b.mouse_filter = Control.MOUSE_FILTER_PASS
	b.pressed.connect(action.emit.bind(kind, {"card_id": String(_card.id)}))
	return b


## Sönük düğmeler kendi satırında sağa yaslı durur: etki parçaları bölünmez.
func _foot(body: VBoxContainer) -> void:
	_keys = SprintUiShared.box(UiTokens.SPACE_XS)
	for kind in _card.buttons:
		_keys.add_child(_key(kind, false))
	_keys.size_flags_horizontal = Control.SIZE_SHRINK_END
	body.add_child(_keys)


func _hover(on: bool) -> void:
	_hovered = on
	_paint()


## Hover bir kenardır: düz kartta açık kenar, kesikli kart kesik kalır; sönük düğmeler kartla birlikte parlar.
func _paint() -> void:
	if _keys != null:
		var kinds: Array = _card.buttons
		for i in kinds.size():
			(_keys.get_child(i) as Button).theme_type_variation = SprintUiShared.key_variation(kinds[i], _hovered)
	if _look == Look.MINI:
		theme_type_variation = &"SprintCardMiniPlanned" if state in PLANNED else &"SprintCardMini"
	elif state in PLANNED:
		theme_type_variation = &"SprintCardPlanned"
	else:
		theme_type_variation = &"SprintCardHover" if _hovered else &"SprintCard"
