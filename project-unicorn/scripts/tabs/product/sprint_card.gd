class_name SprintCard
extends PanelContainer

# Ürün sprint ekranının tek kartı, küçük bir belge: aday listesi, bu sprint, sonraki sprint ve çeyrek
# sütunu aynı sahneyi kullanır. Kart yalnız sözlüğünü çizer: hangi düğmenin olduğu (`buttons`) ve
# "+"nın açıklığı (`addable`) modelden gelir. Sonraki sprinte planlanmış kart kesikli kenarlıdır.

enum State { ADAY, ADAY_ALINMIS, SPRINT_PLAN, SPRINT_AKTIF, BITTI, DEVREDEN, PLANLANAN, KILITLI }
## WIDE orta sütun; NARROW sonraki sütun (ad iki satıra iner, durum etiketleri kendi satırında); LOW açık
## alan satırının içindeki dar kart; MINI çeyrek sütunu.
enum Look { WIDE, NARROW, LOW, MINI }

## args her eylemde {card_id}; karar satırının düğmesi "decide" ({card_id, item}), araştırma kilidinin
## bağlantısı "rnd" ({card_id, node}) yayar.
signal action(kind: String, args: Dictionary)

## Aday ve kilitli kartın düğmeleri üst satırda, hep parlak; sprint ve sonraki sütun kartınınkiler altta, sönük,
## fare kartın üstüne gelince parlak.
const BUTTONS_ALWAYS := [State.ADAY, State.KILITLI]
const BUTTONS_DIM := [State.SPRINT_PLAN, State.SPRINT_AKTIF, State.PLANLANAN, State.DEVREDEN]
const PLANNED := [State.PLANLANAN, State.DEVREDEN]
const PHASE_KEYS := ["PRODUCT_PHASE_DESIGN", "PRODUCT_PHASE_DEV", "PRODUCT_PHASE_TEST"]
const INBOX_GLYPH := "res://assets/icons/util/inbox.svg"
const MAIL_PANE := preload("res://scripts/tabs/events/mail_pane.gd")

@export var state: State

var _card: Dictionary
var _look := Look.WIDE
var _keys: HBoxContainer   # sprint ve sonraki sütun kartının sönük düğmeleri
## Efor dökümü: sütunun kırpmasından kaçsın diye top_level yüzer.
var _effort_box: PanelContainer
var _effort_parts: PackedStringArray
var _column: Control   # kutunun sığacağı kaydırma sütunu; kutu her belirişte bir kez bulunur
var _hovered := false
var _forced := false


## Geniş kartın adı ve hemen ardında durum etiketleri; yer daralınca etiketler kalır, ad üç noktayla
## kısalır. Kutu kapsayıcısı adı ya tam genişlettiği ya da en kısa hâline indirdiği için ayrı dizer.
class NameRow extends Container:
	func _get_minimum_size() -> Vector2:
		var least := Vector2(-UiTokens.SPACE_M, 0.0)
		for part: Control in get_children():
			var m := part.get_combined_minimum_size()
			least = Vector2(least.x + m.x + UiTokens.SPACE_M, maxf(least.y, m.y))
		return least

	func _notification(what: int) -> void:
		if what != NOTIFICATION_SORT_CHILDREN:
			return
		var title: Label = get_child(0)
		var room: float = size.x
		for i in range(1, get_child_count()):
			room -= get_child(i).get_combined_minimum_size().x + UiTokens.SPACE_M
		var x := 0.0
		for part: Control in get_children():
			var m := part.get_combined_minimum_size()
			if part == title:
				m.x = minf(ceilf(title.get_theme_font(&"font").get_string_size(title.text, HORIZONTAL_ALIGNMENT_LEFT, -1,
					title.get_theme_font_size(&"font_size")).x), room)
			fit_child_in_rect(part, Rect2(x, (size.y - m.y) / 2.0, m.x, m.y))
			x += m.x + UiTokens.SPACE_M


func setup(card: Dictionary, look := Look.WIDE) -> void:
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
	var tags: Array = [] if look == Look.MINI else _tags()
	if look == Look.WIDE:
		title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		var name_row := NameRow.new()
		name_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_row.add_child(title)
		for t in tags:
			name_row.add_child(t)
		top.add_child(name_row)
	else:
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.max_lines_visible = 2
		top.add_child(title)
	if look == Look.MINI:
		top.add_child(_points(points))
		_align(top)
		_paint()
		return
	if state == State.BITTI:
		top.add_child(UiFactory.D_stamp(Fmt.upper(tr("PRODUCT_STATUS_DONE"))))
	else:
		var roles := SprintUiShared.box(UiTokens.SPACE_XS)
		for role in _card.roles:
			roles.add_child(UiFactory.make_glyph(SprintUiShared.ROLE_ICONS[String(role)], UiTokens.D_ICON_ROW, ink.glyph))
		top.add_child(roles)
	top.add_child(_points(points))
	if state in BUTTONS_ALWAYS:
		var acts := SprintUiShared.box(UiTokens.SPACE_XS)
		for kind in _card.buttons:
			# Kilitli kart iki sprinte de gidemez.
			acts.add_child(_key(kind, (state == State.KILITLI and kind != "remove") or (kind == "add" and not _card.addable)))
		top.add_child(acts)
	if int(_card.tag_sprint) >= 0:
		top.add_child(UiFactory.D_tag(tr("PRODUCT_TAG_SPRINT").format({"n": int(_card.tag_sprint)}), &"outline"))
	_align(top)
	if look != Look.WIDE and not tags.is_empty():
		var row := HFlowContainer.new()
		row.add_theme_constant_override("h_separation", UiTokens.SPACE_S)
		for t in tags:
			row.add_child(t)
		body.add_child(row)

	if state == State.SPRINT_AKTIF or state == State.BITTI:
		body.add_child(_phase_row())
	elif not _card.effect.is_empty():
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
	if _card.decision != null:
		_decision_rows(body, _card.decision)
	if state in BUTTONS_DIM:
		_foot(body)
	_effort(points)
	if _effort_box != null or _keys != null:
		mouse_entered.connect(_hover.bind(true))
		mouse_exited.connect(_hover.bind(false))
	_paint()


## Ağaca kurulumdan sonra giren kartta motor işlemeyi _ready'de yeniden açar.
func _ready() -> void:
	_paint()


## Fikstür hover'ı (`ui.hover_card`): efor kutusu, hover kenarı ve parlak düğmeler.
func show_effort() -> void:
	_forced = true
	_hover(true)


## {glyph, name, title}: alınmış aday ikincil mürekkepte, kilitli kart kapalı mürekkepte okunur.
func _ink() -> Dictionary:
	match state:
		State.ADAY_ALINMIS:
			return {"glyph": UiTokens.D_INK_4, "name": UiTokens.D_INK_3, "title": &"DataMedium"}
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


## Durum etiketleri: devreder ("devreder · 2,75/3"), başlamaz ve öncelikli (uyarı üçgeniyle), ötekiler
## nötr; önden hazırlanan kart hazır payını ("%40 hazır", tamamsa "Geliştirmeye hazır") taşır. "Planlanan"
## etiketi yok: kesikli kenar söyler.
func _tags() -> Array:
	var out: Array = []
	if _card.spills:
		out.append(UiFactory.D_tag(tr("PRODUCT_CARD_SPILLS_PTS").format({"done": SprintUiShared.points(_card.planned_done),
			"total": SprintUiShared.points(_card.effort)}), &"warn"))
	if int(_card.no_start) >= 0:
		out.append(UiFactory.D_tag(tr("PRODUCT_CARD_NO_START").format({"n": int(_card.no_start)}), &"warn"))
	if _card.priority:
		out.append(UiFactory.D_glyph_tag(SprintUiShared.WARN, tr("PRODUCT_PRIORITY"), &"warn"))
	for row in [[state == State.DEVREDEN, "PRODUCT_CARRIED"],
			[_card.queued, "PRODUCT_QUEUED"], [_card.decision != null, "PRODUCT_DECISION_HALTED"],
			[_card.effect.any(func(p: Dictionary) -> bool: return p.k == "promise"), "PRODUCT_PROMISED"]]:
		if row[0]:
			out.append(UiFactory.D_tag(tr(row[1]), &"outline"))
	if _card.ready >= 0.0:
		out.append(UiFactory.D_tag(tr("PRODUCT_CARD_READY") if _card.ready >= 1.0 else tr("PRODUCT_CARD_READY_PCT").format(
			{"pct": Fmt.percent(floorf(_card.ready * 100.0), 0)}), &"outline"))
	return out


## Dar kartta ad iki satıra inebilir: satırın öbür parçaları üste yaslanır.
func _align(top: HBoxContainer) -> void:
	for part: Control in top.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER if _look == Look.WIDE else Control.SIZE_SHRINK_BEGIN


func _key(kind: String, disabled: bool) -> Button:
	var b := SprintUiShared.key_button(kind, disabled)
	# STOP olsaydı imleç düğmeye geçince kartın hover'ı biter, düğmeler sönerdi.
	b.mouse_filter = Control.MOUSE_FILTER_PASS
	b.pressed.connect(action.emit.bind(kind, {"card_id": String(_card.id)}))
	return b


## Sönük düğmeler kendi yerini tutar ve ne etki satırını ne atananları örter: geniş kartta son satırın sağ ucunda,
## dar kartta (etki parçaları bölünmez) kendi satırında sağa yaslı.
func _foot(body: VBoxContainer) -> void:
	_keys = SprintUiShared.box(UiTokens.SPACE_XS)
	for kind in _card.buttons:
		_keys.add_child(_key(kind, false))
	if _look != Look.WIDE:
		_keys.size_flags_horizontal = Control.SIZE_SHRINK_END
		body.add_child(_keys)
		return
	var last: Control = body.get_child(-1)
	body.remove_child(last)
	last.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	last.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var foot := SprintUiShared.box(UiTokens.SPACE_M)
	foot.add_child(last)
	foot.add_child(_keys)
	body.add_child(foot)


## Sprint içi satırı: Tasarım, Geliştirme ve Test adımları (süren fazın yanında puanları, "1,4/1,8"), sağda o
## haftanın atananları.
func _phase_row() -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_S)
	var phases: Array = _card.phases
	for i in phases.size():
		var phase: String = phases[i]
		var ink: Color = {"done": UiTokens.D_INK_3, "active": UiTokens.D_INK_1}.get(phase, UiTokens.D_INK_4)
		if i > 0:
			var link := ColorRect.new()
			link.color = UiTokens.D_LINE_2
			link.custom_minimum_size = Vector2(UiTokens.D_PHASE_LINK, UiTokens.BORDER_HAIRLINE)
			link.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			link.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(link)
		row.add_child(SprintUiShared.phase_dot(phase == "waiting", ink))
		row.add_child(SprintUiShared.label(tr(PHASE_KEYS[i]), &"Caption", ink))
		if phase == "active":
			row.add_child(SprintUiShared.label("%s/%s" % [SprintUiShared.points(_card.phase_pts.done),
				SprintUiShared.points(_card.phase_pts.total)], &"Caption", ink))
	row.add_child(RnDUiShared.spacer())
	for a in _card.assignees:
		row.add_child(SprintUiShared.avatar(a, UiTokens.D_AVATAR_ROW_SM))
	return row


## Karar kartta cevaplanmaz: kağıt Olaylar'da bekler, satır göndericiyi, konuyu ve kalan süreyi söyler
## ve oraya götürür.
func _decision_rows(body: VBoxContainer, d: Dictionary) -> void:
	body.add_child(HSeparator.new())
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	row.add_child(MAIL_PANE.avatar(d.sender, UiTokens.D_AVATAR_ROW_SM))
	row.add_child(SprintUiShared.label(String(d.sender.name), &"KeyText"))
	row.add_child(SprintUiShared.label(SprintUiShared.SEP.strip_edges(), &"MetaMuted", UiTokens.D_INK_4))
	var subject := SprintUiShared.label(String(d.subject), &"TipTitle")
	subject.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subject.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(subject)
	var go := Button.new()
	go.theme_type_variation = &"SecondaryButtonSmall"
	go.text = tr("PRODUCT_GO_DECISION")
	go.icon = load(INBOX_GLYPH)
	go.focus_mode = Control.FOCUS_NONE
	go.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	go.mouse_filter = Control.MOUSE_FILTER_PASS
	go.pressed.connect(action.emit.bind("decide", {"card_id": String(_card.id), "item": String(d.item)}))
	row.add_child(go)
	body.add_child(row)
	var last: bool = bool(d.last)
	var ink: Color = UiTokens.D_warn() if last else UiTokens.D_INK_3
	var wait := SprintUiShared.box(UiTokens.SPACE_S)
	wait.add_child(UiFactory.make_glyph(INBOX_GLYPH, UiTokens.D_ICON_PART, UiTokens.D_INK_3))
	wait.add_child(SprintUiShared.label(tr("PRODUCT_DECISION_IN_INBOX"), &"Caption"))
	wait.add_child(SprintUiShared.label(SprintUiShared.SEP.strip_edges(), &"Caption", UiTokens.D_INK_4))
	wait.add_child(UiFactory.make_glyph(SprintUiShared.CLOCK, UiTokens.D_ICON_PART, ink))
	var weeks: int = int(d.weeks_left)
	wait.add_child(SprintUiShared.label(tr("DESK_PAPER_THIS_WEEK") if last
		else tr(Fmt.count_key("DESK_PAPER_WEEKS", weeks)).format({"n": weeks}), &"Caption", ink))
	body.add_child(SprintUiShared.pad(wait, Vector4i(UiTokens.D_AVATAR_ROW_SM + UiTokens.SPACE_M, 0, 0, 0)))


## Efor dökümü: "3 puan · Ece 1 hafta · Kaan 1 hafta", kartın üstüne gelince.
func _effort(points: float) -> void:
	var split: Array = _card.effort_split
	if split.is_empty():
		return
	var n: String = SprintUiShared.points(points)
	_effort_parts = [tr(SprintUiShared.points_key("PRODUCT_EFFORT_POINTS", n)).format({"n": n})]
	for s in split:
		var weeks: int = int(s.weeks)
		_effort_parts.append(tr("PRODUCT_EFFORT_PERSON").format({"name": s.name,
			"weeks": tr(Fmt.count_key("PRODUCT_WEEKS", weeks)).format({"n": weeks})}))
	_effort_box = PanelContainer.new()
	_effort_box.theme_type_variation = &"TooltipPanel"
	_effort_box.top_level = true
	_effort_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_effort_box.add_child(UiFactory.make_label(SprintUiShared.SEP.join(_effort_parts), &"TooltipLabel"))
	add_child(_effort_box)


func _hover(on: bool) -> void:
	_hovered = on
	_paint()


## Hover bir kenardır: düz kartta açık kenar, kesikli kart kesik kalır; sönük düğmeler kartla birlikte parlar.
func _paint() -> void:
	var hot: bool = _hovered or _forced
	if _keys != null:
		var kinds: Array = _card.buttons
		for i in kinds.size():
			(_keys.get_child(i) as Button).theme_type_variation = SprintUiShared.key_variation(kinds[i], hot)
	if _look == Look.MINI:
		theme_type_variation = &"SprintCardMiniPlanned" if state in PLANNED else &"SprintCardMini"
	elif state in PLANNED:
		theme_type_variation = &"SprintCardPlanned"
	else:
		theme_type_variation = StringName(("SprintCardLow" if _look == Look.LOW else "SprintCard") + ("Hover" if hot else ""))
	if _effort_box != null:
		_effort_box.visible = hot
		if not hot:
			_column = null
	set_process(hot and _effort_box != null)


## Efor kutusu kartın sağ üstünde durur ve sütunun dışına taşmaz; üstte yer yoksa kartın altına
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
